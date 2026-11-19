import { defaultAppConfig } from '../../src/config/appConfig';
import { handleApiRequest, type ApiContext } from '../../src/api/router';
import { adminDecideVerificationLogic, adminReviewQueueLogic, type AdminDeps } from '../../src/handlers/admin';
import { splitStoragePath } from '../../src/handlers/deps';
import { acceptRulesLogic, startVerificationLogic, submitVerificationLogic } from '../../src/handlers/onboarding';
import { notify, registerPushTokenLogic, unregisterPushTokenLogic } from '../../src/handlers/push';
import { createServices } from '../../src/services/factory';
import { ManualReviewIdentityService } from '../../src/services/identity/manualReviewIdentityService';
import { FakePushService } from '../../src/services/push/pushService';
import type { Caller } from '../../src/shared/callable';
import { authUser, connect, expectAppError, googleCaller, makeDeps, People, reset } from './helpers';

const NOW = new Date('2026-11-20T10:00:00Z');
const sql = connect();
let people: People;
let push: FakePushService;

function deps(): AdminDeps {
  const base = makeDeps(sql, {}, NOW);
  base.services.identity = new ManualReviewIdentityService({ sessionMinutes: 30, now: () => NOW });
  base.services.push = push;
  return { ...base, signUrl: async (path, seconds) => `https://signed.example/${path}?s=${seconds}` };
}

async function member(name: string, dateOfBirth = '2000-01-15'): Promise<Caller> {
  const uid = people.uid(name);
  await authUser(sql, uid);
  const caller = googleCaller(uid, `${name}@example.com`);
  await acceptRulesLogic(deps(), caller, { rulesVersion: defaultAppConfig.rulesVersion, ageConfirmed: true, dateOfBirth });
  return caller;
}

async function capture(caller: Caller, step: 'selfie' | 'id') {
  const session = await startVerificationLogic(deps(), caller, {
    step,
    ...(step === 'id' ? { documentType: 'passport' as const } : {}),
  });
  const { bucket, name } = splitStoragePath(session.uploadPath);
  await sql`insert into storage.objects (bucket_id, name) values (${bucket}, ${name})`;
  return submitVerificationLogic(deps(), caller, { sessionId: session.sessionId });
}

/** Signs up and sends both photos: now waiting for a reviewer. */
async function waiting(name: string, dateOfBirth?: string) {
  const caller = await member(name, dateOfBirth);
  await capture(caller, 'selfie');
  await capture(caller, 'id');
  return caller;
}

const user = async (caller: Caller) =>
  (await sql`select verification_status, verification_steps, verification_reason, age_years from users where id = ${caller.uid}`)[0];

beforeEach(async () => {
  await reset(sql);
  people = new People();
  push = new FakePushService();
});

describe('manual review', () => {
  it('the selfie moves on to the ID; the ID waits for a person', async () => {
    const caller = await member('asha');
    expect((await capture(caller, 'selfie')).stepStatus).toBe('approved');
    const id = await capture(caller, 'id');
    expect(id).toMatchObject({ stepStatus: 'in_review', verificationStatus: 'pending' });
  });

  it('lists who is waiting, with the typed date of birth and short-lived photo links', async () => {
    const caller = await waiting('asha', '1999-12-01');
    await member('notyet');
    const { items } = await adminReviewQueueLogic(deps());
    expect(items).toHaveLength(1);
    expect(items[0]).toMatchObject({
      uid: caller.uid,
      email: 'asha@example.com',
      dateOfBirth: '1999-12-01',
      ageFromDateOfBirth: 26,
      documentType: 'passport',
    });
    expect(items[0].selfieUrl).toMatch(/^https:\/\/signed\.example\/verification\/.+\?s=900$/);
    expect(items[0].idUrl).toMatch(/^https:\/\/signed\.example\/verification\//);
  });

  it('approving verifies the person with their real age and tells them', async () => {
    const caller = await waiting('asha', '1999-12-01');
    await registerPushTokenLogic(deps(), caller, { token: 'asha-phone-token' });
    expect(await adminDecideVerificationLogic(deps(), { uid: caller.uid, decision: 'approve' })).toEqual({
      verificationStatus: 'approved',
    });
    expect(await user(caller)).toMatchObject({
      verification_status: 'approved',
      verification_steps: { phone: 'approved', selfie: 'approved', id: 'approved' },
      age_years: 26,
    });
    expect(push.sent.at(-1)).toEqual({
      tokens: ['asha-phone-token'],
      message: expect.objectContaining({ title: "You're verified", route: '/discover' }),
    });
    expect(await adminReviewQueueLogic(deps())).toEqual({ items: [] });
    await expectAppError(adminDecideVerificationLogic(deps(), { uid: caller.uid, decision: 'approve' }), 'invalid_input');
    const [audit] = await sql`select action, details from admin_audit`;
    expect(audit).toMatchObject({ action: 'verification_approve', details: { uid: caller.uid, result: 'approved' } });
  });

  it('the reviewer can correct the date of birth from the ID; under 18 is a permanent no', async () => {
    const adult = await waiting('asha');
    await adminDecideVerificationLogic(deps(), { uid: adult.uid, decision: 'approve', dateOfBirth: '1995-03-03' });
    expect((await user(adult)).age_years).toBe(31);
    expect((await sql`select date_of_birth from private_profiles where id = ${adult.uid}`)[0].date_of_birth).toBe('1995-03-03');

    const minor = await waiting('kid');
    await adminDecideVerificationLogic(deps(), { uid: minor.uid, decision: 'approve', dateOfBirth: '2010-01-01' });
    expect(await user(minor)).toMatchObject({ verification_status: 'rejected', verification_reason: 'underage', age_years: null });
    await expectAppError(startVerificationLogic(deps(), minor, { step: 'selfie' }), 'invalid_input');
  });

  it('a rejected selfie means a new selfie and ID; a rejected ID only a new ID', async () => {
    const a = await waiting('asha');
    await adminDecideVerificationLogic(deps(), { uid: a.uid, decision: 'reject_selfie', note: 'Face not visible' });
    expect(await user(a)).toMatchObject({
      verification_status: 'pending',
      verification_steps: { selfie: 'rejected', id: 'not_started' },
      verification_reason: 'selfie_rejected',
    });
    await capture(a, 'selfie');
    expect((await capture(a, 'id')).stepStatus).toBe('in_review');

    const b = await waiting('bina');
    await adminDecideVerificationLogic(deps(), { uid: b.uid, decision: 'reject_id' });
    expect((await user(b)).verification_steps).toMatchObject({ selfie: 'approved', id: 'rejected' });
    expect((await capture(b, 'id')).stepStatus).toBe('in_review');
  });
});

describe('push tokens', () => {
  const tokens = async (caller: Caller) =>
    (await sql<{ fcm_tokens: string[] }[]>`select fcm_tokens from private_profiles where id = ${caller.uid}`)[0].fcm_tokens;

  it('keeps the last five phones, once each; a phone moves to whoever signs in on it', async () => {
    const a = await member('asha');
    const b = await member('bina');
    for (const t of ['token-one-1', 'token-two-2', 'token-one-1', 'token-3333', 'token-4444', 'token-5555', 'token-6666']) {
      await registerPushTokenLogic(deps(), a, { token: t });
    }
    expect(await tokens(a)).toEqual(['token-one-1', 'token-3333', 'token-4444', 'token-5555', 'token-6666']);
    await registerPushTokenLogic(deps(), b, { token: 'token-6666' });
    expect(await tokens(a)).not.toContain('token-6666');
    expect(await tokens(b)).toEqual(['token-6666']);
    await unregisterPushTokenLogic(deps(), b, { token: 'token-6666' });
    expect(await tokens(b)).toEqual([]);
  });

  it('forgets tokens the push service no longer knows, and never throws', async () => {
    const a = await member('asha');
    await registerPushTokenLogic(deps(), a, { token: 'token-good-1' });
    await registerPushTokenLogic(deps(), a, { token: 'token-gone-2' });
    push.invalid.add('token-gone-2');
    await notify(deps(), a.uid, { title: 't', body: 'b', route: '/' });
    expect(await tokens(a)).toEqual(['token-good-1']);

    const failing = deps();
    failing.services.push = { send: () => Promise.reject(new Error('down')) };
    await expect(notify(failing, a.uid, { title: 't', body: 'b', route: '/' })).resolves.toBeUndefined();
  });
});

describe('admin actions over HTTP', () => {
  const ctx = (adminSecret?: string): ApiContext => ({
    sql,
    resolveCaller: async () => null,
    services: (config) => createServices(config, true),
    authAdmin: {} as ApiContext['authAdmin'],
    otpSender: () => ({ send: async () => {} }),
    cronSecret: undefined,
    adminSecret,
    signStorageUrl: async (path) => `https://signed.example/${path}`,
    now: () => NOW,
  });
  const call = (headers: Record<string, string>, secret?: string, method = 'POST') =>
    handleApiRequest(
      new Request('http://localhost/api/adminReviewQueue', {
        method,
        headers: { 'Content-Type': 'application/json', ...headers },
        body: method === 'POST' ? '{}' : undefined,
      }),
      ctx(secret),
    );

  it('need the admin secret, and allow the local review page (CORS)', async () => {
    expect((await call({}, 'right-secret')).status).toBe(403);
    expect((await call({ 'x-admin-secret': 'wrong' }, 'right-secret')).status).toBe(403);
    expect((await call({ 'x-admin-secret': 'anything' })).status).toBe(403);
    const ok = await call({ 'x-admin-secret': 'right-secret' }, 'right-secret');
    expect(ok.status).toBe(200);
    expect(ok.headers.get('access-control-allow-origin')).toBe('*');
    expect(await ok.json()).toEqual({ items: [] });
    const preflight = await call({}, 'right-secret', 'OPTIONS');
    expect(preflight.status).toBe(204);
    expect(preflight.headers.get('access-control-allow-headers')).toContain('x-admin-secret');
  });
});
