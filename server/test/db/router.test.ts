import { defaultAppConfig } from '../../src/config/appConfig';
import { callerFromAuthUser } from '../../src/api/caller';
import { handleApiRequest, routeName, type ApiContext } from '../../src/api/router';
import { createServices } from '../../src/services/factory';
import { FakeOtpSender } from '../../src/services/otp/fakeOtpSender';
import { authUser, connect, googleCaller, People, reset } from './helpers';

const sql = connect();
let people: People;
const otp = new FakeOtpSender();

const ctx = (): ApiContext => ({
  sql,
  resolveCaller: async (token) => (token.startsWith('good-') ? googleCaller(token.slice(5), 'someone@example.com') : null),
  services: (config) => createServices(config, true),
  authAdmin: {
    createPhoneUser: async () => {
      await authUser(sql, people.uid('phone'), null);
      return people.uid('phone');
    },
    createSignInToken: async () => 'hash',
    deleteUser: async (uid: string) => {
      await sql`delete from auth.users where id = ${uid}`;
    },
    deleteFiles: async () => {},
  },
  otpSender: () => otp,
  cronSecret: 'cron-secret',
});

const call = (name: string, body: unknown, headers: Record<string, string> = {}, method = 'POST') =>
  handleApiRequest(
    new Request(`http://localhost/api/${name}`, {
      method,
      headers: { 'Content-Type': 'application/json', ...headers },
      body: method === 'GET' ? undefined : JSON.stringify(body),
    }),
    ctx(),
  );

beforeEach(async () => {
  await reset(sql);
  people = new People();
});

describe('api router', () => {
  it('reads the action from the last part of the path', () => {
    expect(routeName('https://x.supabase.co/functions/v1/api/startChat')).toBe('startChat');
    expect(routeName('http://localhost/api/acceptRules?x=1')).toBe('acceptRules');
  });

  it('runs a signed-in action and returns its result', async () => {
    const uid = people.uid('a');
    await authUser(sql, uid);
    const response = await call('acceptRules', { rulesVersion: defaultAppConfig.rulesVersion, ageConfirmed: true, dateOfBirth: '2000-01-15' }, { Authorization: `Bearer good-${uid}` });
    expect(response.status).toBe(200);
    expect(await response.json()).toEqual({ created: true });
  });

  it('refuses a missing or invalid sign-in with 401', async () => {
    for (const headers of [{}, { Authorization: 'Bearer bad' }] as Record<string, string>[]) {
      const response = await call('acceptRules', {}, headers);
      expect(response.status).toBe(401);
      expect(await response.json()).toEqual({ error: { status: 'unauthenticated', code: null, message: 'Sign in first.' } });
    }
  });

  it('sends app errors with their status and code', async () => {
    const uid = people.uid('a');
    const response = await call('discoverCompanions', {}, { Authorization: `Bearer good-${uid}` });
    expect(response.status).toBe(404);
    expect((await response.json()).error).toMatchObject({ status: 'not-found', code: 'not_found' });

    const bad = await call('acceptRules', { rulesVersion: 'one' }, { Authorization: `Bearer good-${uid}` });
    expect(bad.status).toBe(400);
    expect((await bad.json()).error).toMatchObject({ status: 'invalid-argument', code: 'invalid_input' });
  });

  it('answers unknown actions with 404 and non-POST with 405', async () => {
    expect((await call('dropTables', {}, { Authorization: 'Bearer good-x' })).status).toBe(404);
    expect((await call('acceptRules', undefined, {}, 'GET')).status).toBe(405);
  });

  it('runs the renewal job only with the cron secret', async () => {
    expect((await call('renewSubscriptions', {})).status).toBe(403);
    const ok = await call('renewSubscriptions', {}, { 'x-cron-secret': 'cron-secret' });
    expect(ok.status).toBe(200);
    expect(await ok.json()).toEqual({ renewed: 0, ended: 0, failed: 0 });
  });

  it('phone login works signed out, and is off by default', async () => {
    const off = await call('requestLoginOtp', { phone: '+919811122233' });
    expect(off.status).toBe(400);
    await sql`update app_config set overrides = '{"phoneLoginEnabled": true}'`;
    const { clearAppConfigCache } = await import('../../src/config/appConfig');
    clearAppConfigCache();
    const on = await call('requestLoginOtp', { phone: '+919811122233' }, { 'x-forwarded-for': '1.2.3.4, 10.0.0.1' });
    expect(on.status).toBe(200);
    const code = otp.sent.at(-1)!.code;
    const verified = await call('verifyLoginOtp', { phone: '+919811122233', code });
    expect(await verified.json()).toEqual({ tokenHash: 'hash' });
  });

  it('rejects forged store notifications with 401', async () => {
    const response = await handleApiRequest(
      new Request('http://localhost/api/storeNotification?platform=android', { method: 'POST', body: JSON.stringify({ forged: true }) }),
      ctx(),
    );
    expect(response.status).toBe(401);
  });
});

describe('who is calling', () => {
  it('trusts a confirmed email, but never a phone-login placeholder', () => {
    expect(callerFromAuthUser({ id: 'u1', email: 'A@Example.com', email_confirmed_at: '2026-01-01' })).toEqual({
      uid: 'u1',
      phoneNumber: undefined,
      verifiedEmail: 'a@example.com',
    });
    expect(callerFromAuthUser({ id: 'u1', email: 'a@example.com', email_confirmed_at: null }).verifiedEmail).toBeUndefined();
    expect(
      callerFromAuthUser({
        id: 'u2',
        email: '919811122233@phone.findx.invalid',
        email_confirmed_at: '2026-01-01',
        app_metadata: { phone_e164: '+919811122233' },
      }),
    ).toEqual({ uid: 'u2', phoneNumber: '+919811122233', verifiedEmail: undefined });
  });
});
