/**
 * End-to-end check of the bundled `api` Edge Function under Deno (the
 * Supabase runtime), without a Supabase project:
 *   - a throwaway local Postgres with every migration,
 *   - a tiny stand-in for Supabase Auth's "who is this token" endpoint,
 *   - supabase/functions/api/index.ts running in Deno,
 * then the main flows over HTTP, exactly as the app calls them.
 *
 *   npm --prefix server run build:edge && npm --prefix server run smoke:edge
 */
import { spawn, type ChildProcess } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { readdirSync, readFileSync, rmSync } from 'node:fs';
import { createServer } from 'node:http';
import { join } from 'node:path';

import postgres from 'postgres';

import { seedUid } from '../src/services/seedIds';
import { seedAccounts, seedDatabase } from '../seed/seed';

const PG_PORT = 54331;
const AUTH_PORT = 54401;
const API = 'http://127.0.0.1:8000/api';
const root = join(__dirname, '..', '..');
const dbUrl = `postgres://postgres:postgres@127.0.0.1:${PG_PORT}/postgres`;

let failures = 0;
function check(name: string, ok: boolean, detail?: unknown) {
  console.log(`${ok ? 'ok  ' : 'FAIL'} ${name}${ok ? '' : ` -> ${JSON.stringify(detail)}`}`);
  if (!ok) failures += 1;
}

/** Access tokens here are "<uid>|<email>"; the fake Auth answers like Supabase does. */
const token = (uid: string, email = `${uid}@example.com`) => `${uid}|${email}`;

async function call(name: string, body: unknown, accessToken?: string, query = '') {
  const response = await fetch(`${API}/${name}${query}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}) },
    body: JSON.stringify(body),
  });
  const text = await response.text();
  let json: unknown = text;
  try {
    json = JSON.parse(text);
  } catch {
    // plain text answer
  }
  return { status: response.status, json: json as Record<string, any> };
}

async function waitFor(url: string, timeoutMs: number) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    try {
      await fetch(url, { method: 'POST', body: '{}' });
      return;
    } catch {
      await new Promise((r) => setTimeout(r, 500));
    }
  }
  throw new Error(`Nothing answered at ${url}`);
}

async function main() {
  const load = new Function('m', 'return import(m)') as (m: string) => Promise<{ default: new (o: object) => any }>;
  const EmbeddedPostgres = (await load('embedded-postgres')).default;
  const dataDir = join(process.env.TEMP ?? '/tmp', 'findx-pg-smoke');
  rmSync(dataDir, { recursive: true, force: true });
  const pg = new EmbeddedPostgres({ databaseDir: dataDir, user: 'postgres', password: 'postgres', port: PG_PORT, persistent: false, onLog: () => {} });
  await pg.initialise();
  await pg.start();
  const sql = postgres(dbUrl, { onnotice: () => {}, max: 2 });

  const auth = createServer((req, res) => {
    const bearer = (req.headers.authorization ?? '').replace(/^Bearer /, '');
    const [uid, email] = bearer.split('|');
    if (req.url !== '/auth/v1/user' || !uid || !email) {
      res.writeHead(401).end('{"msg":"invalid JWT"}');
      return;
    }
    res.writeHead(200, { 'Content-Type': 'application/json' }).end(
      JSON.stringify({ id: uid, email, email_confirmed_at: '2026-11-13T00:00:00Z', app_metadata: { provider: 'google' } }),
    );
  });
  auth.listen(AUTH_PORT);

  let deno: ChildProcess | undefined;
  try {
    await sql.unsafe(readFileSync(join(__dirname, '..', 'test', 'db', 'supabaseShim.sql'), 'utf8'));
    for (const file of readdirSync(join(root, 'supabase', 'migrations')).sort()) {
      await sql.unsafe(readFileSync(join(root, 'supabase', 'migrations', file), 'utf8'));
    }
    for (const a of seedAccounts()) await sql`insert into auth.users (id, email, email_confirmed_at) values (${a.uid}, ${a.email}, now())`;
    await seedDatabase(sql, new Date());

    deno = spawn('npx', ['deno', 'run', '-A', '--no-prompt', join(root, 'supabase', 'functions', 'api', 'index.ts')], {
      env: {
        ...process.env,
        SUPABASE_URL: `http://127.0.0.1:${AUTH_PORT}`,
        SUPABASE_DB_URL: dbUrl,
        SUPABASE_SERVICE_ROLE_KEY: 'service-role-test',
        FINDX_FAKE_SERVICES: 'true',
        FINDX_CRON_SECRET: 'cron-test',
      },
      shell: true,
      stdio: ['ignore', 'inherit', 'inherit'],
    });
    await waitFor(`${API}/ping`, 120_000);

    // --- sign-up and verification ---
    const newUid = randomUUID();
    await sql`insert into auth.users (id, email, email_confirmed_at) values (${newUid}, 'new@example.com', now())`;
    const me = token(newUid, 'new@example.com');
    check('signed-out calls are refused with 401', (await call('acceptRules', { rulesVersion: 1, ageConfirmed: true })).status === 401);
    const accepted = await call('acceptRules', { rulesVersion: 1, ageConfirmed: true }, me);
    check('acceptRules creates the account', accepted.status === 200 && accepted.json.created === true, accepted);
    for (const step of ['selfie', 'id'] as const) {
      const started = await call('startVerification', { step, ...(step === 'id' ? { documentType: 'aadhaar' } : {}) }, me);
      const [bucket, ...rest] = String(started.json.uploadPath).split('/');
      await sql`insert into storage.objects (bucket_id, name) values (${bucket}, ${rest.join('/')})`;
      const submitted = await call('submitVerification', { sessionId: started.json.sessionId }, me);
      check(`${step} is approved by the fake check`, submitted.json.stepStatus === 'approved', submitted);
    }
    const [user] = await sql`select verification_status from users where id = ${newUid}`;
    check('the new account is verified', user.verification_status === 'approved', user);

    // --- discovery, chat and booking as seeded Aarav ---
    const aarav = token(seedUid('s_aarav'), 'aarav@findx.test');
    const found = await call('discoverCompanions', { planType: null }, aarav);
    const companions = (found.json.companions ?? []) as { uid: string; displayName: string }[];
    check('Aarav sees companions nearby', found.status === 200 && companions.length >= 3, found);
    const neha = companions.find((c) => c.displayName === 'Neha')!;
    const chat = await call('startChat', { companionUid: neha.uid }, aarav);
    check('starting a chat costs 1 credit', chat.json.charged === true && chat.json.balance === 19, chat);
    const sent = await call('sendMessage', { chatId: chat.json.chatId, text: 'Hi Neha!', clientId: 'smoke00001' }, aarav);
    check('a message is sent', sent.status === 200, sent);
    const blocked = await call('sendMessage', { chatId: chat.json.chatId, text: 'call me 98765 43210', clientId: 'smoke00002' }, aarav);
    check('a phone number is blocked by moderation', blocked.status === 400 && blocked.json.error?.code === 'moderation_blocked', blocked);

    const venues = await call('nearbyVenues', { planType: 'coffee', companionUid: neha.uid }, aarav);
    check('nearby venues are listed', venues.status === 200 && venues.json.venues.length > 0, venues);
    let booked = false;
    for (const venue of venues.json.venues as { venueId: string }[]) {
      for (let day = 0; day < 7 && !booked; day++) {
        const dayKey = new Date(Date.now() + 5.5 * 3_600_000 + day * 86_400_000).toISOString().slice(0, 10);
        const slots = await call('venueSlots', { venueId: venue.venueId, dayKey, companionUid: neha.uid }, aarav);
        const open = (slots.json.slots ?? []).find((s: { state: string }) => s.state === 'available');
        if (!open) continue;
        const request = await call(
          'requestBooking',
          { requestId: 'smokebooking01', companionUid: neha.uid, venueId: venue.venueId, slotId: open.slotId, planType: 'coffee', kind: 'scheduled' },
          aarav,
        );
        check('a booking is requested and charged 5 credits', request.status === 200 && request.json.balance === 14, request);
        booked = request.status === 200;
      }
      if (booked) break;
    }
    check('found a free slot to book', booked);

    // --- purchases ---
    const t = `fake-t${Date.now()}-smoke`;
    const bought = await call('verifyPurchase', { platform: 'android', productId: 'vybe_credits_30', purchaseToken: t }, aarav);
    check('a test-store pack adds 30 credits', bought.json.status === 'granted' && bought.json.creditsAdded === 30, bought);
    const refund = await call('storeNotification', { fake: { type: 'refund', storeTransactionId: `fake-txn-${t}` } }, undefined, '?platform=android');
    check('a store refund takes the credits back', refund.status === 200 && refund.json.outcome === 'refunded', refund);
    const forged = await call('storeNotification', { forged: true }, undefined, '?platform=android');
    check('a forged store notification is rejected', forged.status === 401, forged);

    // --- scheduled job and unknown actions ---
    check('the renewal job needs its secret', (await call('renewSubscriptions', {})).status === 403);
    const renew = await fetch(`${API}/renewSubscriptions`, { method: 'POST', headers: { 'x-cron-secret': 'cron-test' }, body: '{}' });
    check('the renewal job runs with its secret', renew.status === 200);
    check('unknown actions are 404', (await call('dropEverything', {}, aarav)).status === 404);
  } finally {
    deno?.kill();
    if (process.platform === 'win32' && deno?.pid) spawn('taskkill', ['/pid', String(deno.pid), '/T', '/F']);
    auth.close();
    await sql.end();
    await pg.stop();
  }
  console.log(failures === 0 ? '\nEdge Function smoke test passed.' : `\n${failures} check(s) failed.`);
  process.exitCode = failures === 0 ? 0 : 1;
}

main().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
