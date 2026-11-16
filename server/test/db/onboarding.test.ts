import { defaultAppConfig } from '../../src/config/appConfig';
import { splitStoragePath } from '../../src/handlers/deps';
import {
  acceptRulesLogic,
  startVerificationLogic,
  submitVerificationLogic,
  UNDERAGE_REASON,
} from '../../src/handlers/onboarding';
import { FakeIdentityVerificationService } from '../../src/services/identity/fakeIdentityVerificationService';
import type { Caller } from '../../src/shared/callable';
import { authUser, connect, expectAppError, googleCaller, makeDeps, People, phoneCaller, reset } from './helpers';

const NOW = new Date('2026-11-10T10:00:00Z');
const sql = connect();
let people: People;

function deps(overrides: { dateOfBirth?: string; reject?: string[]; now?: Date } = {}) {
  const now = overrides.now ?? NOW;
  const base = makeDeps(sql, {}, now);
  base.services.identity = new FakeIdentityVerificationService({
    sessionMinutes: defaultAppConfig.verificationSessionMinutes,
    now: () => now,
    rejectUids: new Set(overrides.reject ?? []),
    dateOfBirthFor: () => overrides.dateOfBirth ?? '2000-01-15',
  });
  return base;
}

async function newCaller(name: string, kind: 'phone' | 'google' = 'phone'): Promise<Caller> {
  const uid = people.uid(name);
  await authUser(sql, uid);
  return kind === 'phone' ? phoneCaller(uid, '+919700000001') : googleCaller(uid, `${name}@example.com`);
}

/** What the app's upload does: the file appears in Supabase Storage. */
async function upload(path: string) {
  const { bucket, name } = splitStoragePath(path);
  await sql`insert into storage.objects (bucket_id, name) values (${bucket}, ${name})`;
}

const accept = (caller: Caller, d = deps()) => acceptRulesLogic(d, caller, { rulesVersion: defaultAppConfig.rulesVersion, ageConfirmed: true });

async function verifyStep(caller: Caller, step: 'selfie' | 'id', d = deps()) {
  const session = await startVerificationLogic(d, caller, { step, ...(step === 'id' ? { documentType: 'aadhaar' as const } : {}) });
  await upload(session.uploadPath);
  return submitVerificationLogic(d, caller, { sessionId: session.sessionId });
}

const userRow = async (caller: Caller) => (await sql`select * from users where id = ${caller.uid}`)[0];

beforeEach(async () => {
  await reset(sql);
  people = new People();
});

describe('acceptRules', () => {
  it('creates the account with the signup bonus and a Free plan', async () => {
    const caller = await newCaller('a');
    expect(await accept(caller)).toEqual({ created: true });

    const user = await userRow(caller);
    expect(user.verification_status).toBe('pending');
    expect(user.verification_steps).toEqual({ phone: 'approved', selfie: 'not_started', id: 'not_started' });
    expect(user.account_type).toBe('member');
    expect((await sql`select balance from credit_accounts where uid = ${caller.uid}`)[0].balance).toBe(20);
    expect((await sql`select reason from credit_ledger where id = ${`signup_${caller.uid}`}`)[0].reason).toBe('signup_bonus');
    expect((await sql`select phone_e164 from private_profiles where id = ${caller.uid}`)[0].phone_e164).toBe(caller.phoneNumber);
    expect((await sql`select tier from subscriptions where uid = ${caller.uid}`)[0].tier).toBe('free');
  });

  it('is idempotent and never grants the bonus twice, even when called twice at once', async () => {
    const caller = await newCaller('a');
    const results = await Promise.all([accept(caller), accept(caller)]);
    expect(results.map((r) => r.created).sort()).toEqual([false, true]);
    expect(await accept(caller)).toEqual({ created: false });
    expect((await sql`select balance from credit_accounts where uid = ${caller.uid}`)[0].balance).toBe(20);
  });

  it('rejects an outdated rules version and a caller with neither a phone nor a verified email', async () => {
    const caller = await newCaller('a');
    await expectAppError(acceptRulesLogic(deps(), caller, { rulesVersion: 0, ageConfirmed: true }), 'invalid_input');
    await expectAppError(accept({ ...caller, phoneNumber: undefined }), 'invalid_input');
  });

  it('a Google sign-in creates the account and keeps the email privately', async () => {
    const caller = await newCaller('someone', 'google');
    expect(await accept(caller)).toEqual({ created: true });
    expect((await sql`select phone_e164, email from private_profiles where id = ${caller.uid}`)[0]).toEqual({
      phone_e164: null,
      email: 'someone@example.com',
    });
  });

  it('refuses a banned account', async () => {
    const caller = await newCaller('a');
    await accept(caller);
    await sql`update users set account_status = 'banned' where id = ${caller.uid}`;
    await expectAppError(accept(caller), 'blocked');
  });
});

describe('verification', () => {
  it('needs an account first', async () => {
    const caller = await newCaller('a');
    await expectAppError(startVerificationLogic(deps(), caller, { step: 'selfie' }), 'not_found');
  });

  it('runs the selfie before the ID, and the ID needs a document type', async () => {
    const caller = await newCaller('a');
    await accept(caller);
    await expectAppError(startVerificationLogic(deps(), caller, { step: 'id', documentType: 'passport' }), 'invalid_input');
    await verifyStep(caller, 'selfie');
    await expectAppError(startVerificationLogic(deps(), caller, { step: 'id' }), 'invalid_input');
  });

  it('approves the whole account after selfie and ID', async () => {
    const caller = await newCaller('a');
    await accept(caller);
    expect(await verifyStep(caller, 'selfie')).toEqual({ step: 'selfie', stepStatus: 'approved', verificationStatus: 'pending', reason: null });
    expect(await verifyStep(caller, 'id')).toEqual({ step: 'id', stepStatus: 'approved', verificationStatus: 'approved', reason: null });

    const user = await userRow(caller);
    expect(user.verification_status).toBe('approved');
    expect(user.age_years).toBe(26);
    expect((await sql`select date_of_birth from private_profiles where id = ${caller.uid}`)[0].date_of_birth).toBe('2000-01-15');
  });

  it('will not decide before the photo is uploaded, and never reuses a session', async () => {
    const caller = await newCaller('a');
    await accept(caller);
    const session = await startVerificationLogic(deps(), caller, { step: 'selfie' });
    await expectAppError(submitVerificationLogic(deps(), caller, { sessionId: session.sessionId }), 'invalid_input');
    await upload(session.uploadPath);
    await submitVerificationLogic(deps(), caller, { sessionId: session.sessionId });
    await expectAppError(submitVerificationLogic(deps(), caller, { sessionId: session.sessionId }), 'invalid_input');
  });

  it('a session submitted twice at once is decided once', async () => {
    const caller = await newCaller('a');
    await accept(caller);
    const session = await startVerificationLogic(deps(), caller, { step: 'selfie' });
    await upload(session.uploadPath);
    const results = await Promise.allSettled([1, 2].map(() => submitVerificationLogic(deps(), caller, { sessionId: session.sessionId })));
    expect(results.filter((r) => r.status === 'fulfilled')).toHaveLength(1);
  });

  it('rejects an expired session', async () => {
    const caller = await newCaller('a');
    await accept(caller);
    const session = await startVerificationLogic(deps(), caller, { step: 'selfie' });
    await upload(session.uploadPath);
    const later = new Date(NOW.getTime() + (defaultAppConfig.verificationSessionMinutes + 1) * 60_000);
    await expectAppError(submitVerificationLogic(deps({ now: later }), caller, { sessionId: session.sessionId }), 'invalid_input');
  });

  it("does not let one user submit another user's session", async () => {
    const owner = await newCaller('owner');
    const other = await newCaller('other');
    await accept(owner);
    await accept(other);
    const session = await startVerificationLogic(deps(), owner, { step: 'selfie' });
    await upload(session.uploadPath);
    await expectAppError(submitVerificationLogic(deps(), other, { sessionId: session.sessionId }), 'not_found');
  });

  it('lets a rejected selfie be retried', async () => {
    const caller = await newCaller('a');
    await accept(caller);
    expect((await verifyStep(caller, 'selfie', deps({ reject: [caller.uid] }))).stepStatus).toBe('rejected');
    expect((await verifyStep(caller, 'selfie')).stepStatus).toBe('approved');
  });

  it('permanently rejects anyone under 18', async () => {
    const caller = await newCaller('a');
    await accept(caller);
    await verifyStep(caller, 'selfie');
    expect(await verifyStep(caller, 'id', deps({ dateOfBirth: '2010-05-01' }))).toEqual({
      step: 'id',
      stepStatus: 'rejected',
      verificationStatus: 'rejected',
      reason: UNDERAGE_REASON,
    });
    await expectAppError(startVerificationLogic(deps(), caller, { step: 'id', documentType: 'aadhaar' }), 'invalid_input');
    expect((await userRow(caller)).verification_status).toBe('rejected');
  });

  it('stores the session with its upload path and expiry', async () => {
    const caller = await newCaller('a');
    await accept(caller);
    const result = await startVerificationLogic(deps(), caller, { step: 'selfie' });
    const [session] = await sql`select * from verification_sessions where id = ${result.sessionId}`;
    expect(session.upload_path).toBe(`verification/${caller.uid}/${result.sessionId}.jpg`);
    expect(session.provider).toBe('fake');
    expect((session.expires_at as Date).toISOString()).toBe(result.expiresAt);
  });
});
