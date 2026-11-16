/**
 * Fills the **test** Supabase project with the Mumbai test data: 15 people
 * (with sign-in accounts), 7 venues and their slots. Safe to run again: every
 * row has a fixed id and is overwritten.
 *
 * Run from your own terminal (the values are secrets; never paste them into
 * chats or files):
 *
 *   SUPABASE_URL=https://<ref>.supabase.co \
 *   SUPABASE_SERVICE_ROLE_KEY=<service_role / secret key> \
 *   SUPABASE_DB_URL=<Connect -> Session pooler connection string> \
 *   npm --prefix server run seed -- --test-project <ref>
 *
 * It refuses to run unless `--test-project` names the project in SUPABASE_URL,
 * and refuses the launch project (app_config.overrides.environment = "production").
 */
import postgres from 'postgres';

import { defaultAppConfig as config } from '../src/config/appConfig';
import { buildSlots } from '../src/domain/slots';
import { seedUid } from '../src/services/seedIds';
import type { Db } from '../src/shared/db';
import { ageOn, defaultWeeklyAvailability, members, venues, type SeedMember } from './fixtures';

/** Test sign-in for a seeded person: their first name (or business) @findx.test. */
export const testEmail = (displayName: string) => `${displayName.toLowerCase().replace(/[^a-z0-9]/g, '')}@findx.test`;

/** The shared password of every test account. Must match the app's `FINDX_TEST_PASSWORD`. */
export const TEST_PASSWORD = process.env.FINDX_TEST_PASSWORD ?? 'findx-test-2026';

export interface SeedAccount {
  uid: string;
  email: string;
  displayName: string;
}

/** Every sign-in account the seed needs. */
export function seedAccounts(): SeedAccount[] {
  return [
    ...members.map((m) => ({ uid: seedUid(m.uid), email: testEmail(m.displayName), displayName: m.displayName })),
    ...venues.map((v) => ({ uid: seedUid(v.ownerUid), email: testEmail(v.businessName), displayName: v.businessName })),
  ];
}

/** Writes every row. The sign-in accounts must already exist. */
export async function seedDatabase(sql: Db, now: Date): Promise<{ slots: number }> {
  return sql.begin(async (tx) => {
    for (const m of members) await writeMember(tx, m, now);
    let slots = 0;
    for (const v of venues) {
      const owner = seedUid(v.ownerUid);
      const verified = v.verificationStatus === 'verified';
      await tx`
        insert into users (id, account_type, display_name, active_mode, verification_status, verification_steps, account_status)
        values (${owner}, 'venue_partner', ${v.businessName}, 'seeker', ${verified ? 'approved' : 'pending'},
          ${tx.json({ phone: 'approved', selfie: 'approved', id: verified ? 'approved' : 'not_started' })}, 'active')
        on conflict (id) do update set account_type = excluded.account_type, display_name = excluded.display_name,
          verification_status = excluded.verification_status, verification_steps = excluded.verification_steps,
          account_status = excluded.account_status`;
      await tx`
        insert into venue_partners (uid, business_name, venue_ids, verification_status)
        values (${owner}, ${v.businessName}, ${[v.venueId]}, ${v.verificationStatus})
        on conflict (uid) do update set business_name = excluded.business_name, venue_ids = excluded.venue_ids,
          verification_status = excluded.verification_status`;
      const venueRow = {
        id: v.venueId,
        owner_uid: owner,
        name: v.name,
        category: v.category,
        address_line: v.addressLine,
        lat: v.lat,
        lng: v.lng,
        plan_types: v.planTypes,
        verification_status: v.verificationStatus,
        is_listed: v.isListed,
        perk: tx.json({ text: v.perk, updatedAt: now.toISOString() }),
        safety_checklist: tx.json({ publicSeating: true, staffBriefed: true, wellLit: true }),
        slot_template: tx.json(v.slotTemplate as never),
        updated_at: now,
      };
      await tx`
        insert into venues ${tx(venueRow)}
        on conflict (id) do update set owner_uid = excluded.owner_uid, name = excluded.name, category = excluded.category,
          address_line = excluded.address_line, lat = excluded.lat, lng = excluded.lng, plan_types = excluded.plan_types,
          verification_status = excluded.verification_status, is_listed = excluded.is_listed, perk = excluded.perk,
          safety_checklist = excluded.safety_checklist, slot_template = excluded.slot_template, updated_at = excluded.updated_at`;
      if (!verified) continue;
      for (const slot of buildSlots(v.slotTemplate, now, config.bookingDaysAhead, config.launchCity.timezone)) {
        // Existing slots keep their bookings; new days are added.
        await tx`
          insert into venue_slots (venue_id, id, day_key, start_at, end_at, capacity, booked, status)
          values (${v.venueId}, ${slot.slotId}, ${slot.dayKey}, ${slot.startAt}, ${slot.endAt}, ${slot.capacity}, 0, 'open')
          on conflict (venue_id, id) do nothing`;
        slots += 1;
      }
    }
    await tx`insert into admin_audit (action, details) values ('seed', ${tx.json({ members: members.length, venues: venues.length })})`;
    return { slots };
  });
}

async function writeMember(tx: postgres.TransactionSql, m: SeedMember, now: Date) {
  const uid = seedUid(m.uid);
  const verified = m.verification === 'approved';
  const age = ageOn(m.dateOfBirth, now);
  const steps = {
    phone: 'approved',
    selfie: verified ? 'approved' : m.verification === 'rejected' ? 'rejected' : 'not_started',
    id: verified ? 'approved' : 'not_started',
  };
  await tx`
    insert into users (id, account_type, display_name, active_mode, consent, verification_status, verification_steps,
      verification_reason, age_years, account_status, created_at, updated_at)
    values (${uid}, 'member', ${m.displayName}, ${m.companion ? 'companion' : 'seeker'},
      ${tx.json({ rulesVersion: config.rulesVersion, ageConfirmed: true, acceptedAt: now.toISOString() })},
      ${verified ? 'approved' : m.verification === 'rejected' ? 'rejected' : 'pending'}, ${tx.json(steps)},
      ${m.verification === 'rejected' ? 'fake_rejection' : null}, ${verified ? age : null},
      ${m.banned ? 'banned' : 'active'}, ${now}, ${now})
    on conflict (id) do update set display_name = excluded.display_name, active_mode = excluded.active_mode,
      consent = excluded.consent, verification_status = excluded.verification_status,
      verification_steps = excluded.verification_steps, verification_reason = excluded.verification_reason,
      age_years = excluded.age_years, account_status = excluded.account_status, updated_at = excluded.updated_at`;
  await tx`
    insert into private_profiles (id, phone_e164, email, date_of_birth, id_verification)
    values (${uid}, ${m.phoneE164}, ${testEmail(m.displayName)}, ${verified ? m.dateOfBirth : null},
      ${tx.json({ provider: 'fake', providerRef: `seed-${m.uid}`, status: m.verification })})
    on conflict (id) do update set phone_e164 = excluded.phone_e164, email = excluded.email,
      date_of_birth = excluded.date_of_birth, id_verification = excluded.id_verification`;
  await tx`
    insert into preferences (uid, gender, show_me, who_can_request, show_gender, age_min, age_max)
    values (${uid}, ${m.gender}, ${m.showMe}, ${m.whoCanRequest}, ${m.showGender}, ${m.ageMin}, ${m.ageMax})
    on conflict (uid) do update set gender = excluded.gender, show_me = excluded.show_me,
      who_can_request = excluded.who_can_request, show_gender = excluded.show_gender,
      age_min = excluded.age_min, age_max = excluded.age_max`;
  await tx`
    insert into user_locations (uid, lat, lng, accuracy_m, updated_at)
    values (${uid}, ${m.location.lat}, ${m.location.lng}, 20, ${now})
    on conflict (uid) do update set lat = excluded.lat, lng = excluded.lng, updated_at = excluded.updated_at`;
  // Credits and plan start fresh only the first time; testers keep what they bought or spent.
  await tx`insert into credit_accounts (uid, balance) values (${uid}, ${config.signupBonusCredits}) on conflict (uid) do nothing`;
  await tx`
    insert into credit_ledger (id, uid, delta, balance_after, reason, ref_type, ref_id, idempotency_key)
    values (${`signup_${uid}`}, ${uid}, ${config.signupBonusCredits}, ${config.signupBonusCredits}, 'signup_bonus', 'user',
      ${uid}, ${`signup_${uid}`})
    on conflict (id) do nothing`;
  await tx`insert into subscriptions (uid) values (${uid}) on conflict (uid) do nothing`;
  if (!m.companion) return;

  const freeNowUntil = m.companion.freeNowHours === null ? null : new Date(now.getTime() + m.companion.freeNowHours * 3_600_000);
  await tx`
    insert into companion_profiles (uid, about, activity_tags, plan_types, prompt, voice_intro, is_listed, free_now_until, updated_at)
    values (${uid}, ${m.companion.about}, ${m.companion.activityTags}, ${m.companion.planTypes}, ${tx.json(m.companion.prompt)},
      null, true, ${freeNowUntil}, ${now})
    on conflict (uid) do update set about = excluded.about, activity_tags = excluded.activity_tags,
      plan_types = excluded.plan_types, prompt = excluded.prompt, is_listed = true,
      free_now_until = excluded.free_now_until, updated_at = excluded.updated_at`;
  await tx`
    insert into availability (uid, weekly, exceptions, timezone)
    values (${uid}, ${tx.json(defaultWeeklyAvailability)}, '[]'::jsonb, ${config.launchCity.timezone})
    on conflict (uid) do update set weekly = excluded.weekly, exceptions = excluded.exceptions`;
  // Database triggers rebuild the discovery index from these rows.
}

/** Creates (or resets) one sign-in account through the Supabase Auth admin API. */
async function upsertAccount(url: string, key: string, account: SeedAccount): Promise<void> {
  const headers = { apikey: key, Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' };
  const body = {
    email: account.email,
    password: TEST_PASSWORD,
    email_confirm: true,
    user_metadata: { display_name: account.displayName },
  };
  const update = await fetch(`${url}/auth/v1/admin/users/${account.uid}`, { method: 'PUT', headers, body: JSON.stringify(body) });
  if (update.ok) return;
  const create = await fetch(`${url}/auth/v1/admin/users`, { method: 'POST', headers, body: JSON.stringify({ id: account.uid, ...body }) });
  if (!create.ok) throw new Error(`Could not create ${account.email}: HTTP ${create.status} ${await create.text()}`);
}

function argValue(flag: string): string | undefined {
  const i = process.argv.indexOf(flag);
  return i >= 0 ? process.argv[i + 1] : undefined;
}

async function main() {
  const url = process.env.SUPABASE_URL?.replace(/\/$/, '');
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const dbUrl = process.env.SUPABASE_DB_URL;
  if (!url || !key || !dbUrl) throw new Error('Set SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY and SUPABASE_DB_URL (see the top of seed/seed.ts).');
  const ref = new URL(url).hostname.split('.')[0];
  if (argValue('--test-project') !== ref) {
    throw new Error(`Refusing to seed. Run with "--test-project ${ref}" if ${ref} really is the TEST project.`);
  }

  const sql = postgres(dbUrl, { prepare: false, max: 1, onnotice: () => {} });
  try {
    const [row] = await sql<{ environment: string | null }[]>`select overrides ->> 'environment' as environment from app_config where id = 1`;
    if (row?.environment === 'production') throw new Error('This is the launch project (app_config.environment = production). Refusing to seed.');

    const accounts = seedAccounts();
    for (const account of accounts) await upsertAccount(url, key, account);
    const { slots } = await seedDatabase(sql, new Date());
    console.log(`Seeded ${members.length} members, ${venues.length} venues and ${slots} slots into ${ref}.`);
    console.log(`Test sign-in: <first name>@findx.test, e.g. ${testEmail('Aarav')}, password ${TEST_PASSWORD}`);
  } finally {
    await sql.end();
  }
}

if (require.main === module) {
  main().catch((error: unknown) => {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  });
}
