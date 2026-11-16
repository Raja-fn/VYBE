import { randomUUID } from 'node:crypto';

import { defaultAppConfig } from '../../src/config/appConfig';
import { requestLoginOtpLogic, verifyLoginOtpLogic, type PhoneLoginDeps } from '../../src/handlers/phoneLogin';
import type { AuthAdmin } from '../../src/services/auth/authAdmin';
import { OtpSendError, type OtpSender } from '../../src/services/otp/otpSender';
import { authUser, connect, expectAppError, reset } from './helpers';

const PHONE = '+919811122233';
const START = new Date('2026-11-12T10:00:00Z');
const sql = connect();

let now = START;
let sent: { phone: string; code: string }[] = [];
let failSending = false;

const sender: OtpSender = {
  send: async (phone, code) => {
    if (failSending) throw new OtpSendError('down');
    sent.push({ phone, code });
  },
};

/** Stands in for Supabase Auth: creates accounts and hands out a token naming the account. */
const authAdmin: AuthAdmin & { created: string[] } = {
  created: [],
  async createPhoneUser() {
    const uid = randomUUID();
    await authUser(sql, uid, null);
    this.created.push(uid);
    return uid;
  },
  async createSignInToken(uid: string) {
    return `token-for-${uid}`;
  },
  deleteUser: async () => {},
  deleteFiles: async () => {},
};

const config = { ...defaultAppConfig, phoneLoginEnabled: true };
const deps = (ip = '10.0.0.1', cfg = config): PhoneLoginDeps => ({ sql, authAdmin, config: cfg, sender, now: () => now, ip });
const request = (phone = PHONE, ip?: string) => requestLoginOtpLogic(deps(ip), { phone });
const verify = (code: string, phone = PHONE) => verifyLoginOtpLogic(deps(), { phone, code });
const lastCode = () => sent.at(-1)!.code;
const wrongCode = () => (lastCode() === '0000' ? '1111' : '0000');
const later = (seconds: number) => {
  now = new Date(now.getTime() + seconds * 1000);
};
const challenge = async () => (await sql`select * from otp_challenges where phone = ${PHONE}`)[0];

beforeEach(async () => {
  await reset(sql);
  now = START;
  sent = [];
  failSending = false;
  authAdmin.created = [];
});

describe('requestLoginOtp', () => {
  it('sends a 4-digit code and stores only its hash', async () => {
    await expect(request()).resolves.toEqual({ phone: PHONE, resendAfterSeconds: defaultAppConfig.otpResendSeconds });
    expect(sent).toEqual([{ phone: PHONE, code: expect.stringMatching(/^\d{4}$/) }]);
    const stored = await challenge();
    expect(JSON.stringify(stored)).not.toContain(`"${lastCode()}"`);
    expect(stored).toMatchObject({ attempts: 0 });
  });

  it('sends nothing while phone login is switched off', async () => {
    await expectAppError(requestLoginOtpLogic(deps('10.0.0.1', defaultAppConfig), { phone: PHONE }), 'invalid_input');
    expect(sent).toEqual([]);
  });

  it('refuses numbers that are not 10-digit Indian mobiles', async () => {
    await expectAppError(request('+91981112223'), 'invalid_input');
    await expectAppError(request('+14155550100'), 'invalid_input');
    expect(sent).toEqual([]);
  });

  it('waits between codes and caps codes per number per day', async () => {
    await request();
    await expectAppError(request(), 'rate_limited');
    for (let i = 1; i < defaultAppConfig.otpRequestsPerPhonePerDay; i++) {
      later(defaultAppConfig.otpResendSeconds);
      await request(PHONE, `10.0.0.${i + 1}`);
    }
    later(defaultAppConfig.otpResendSeconds);
    await expectAppError(request(PHONE, '10.9.9.9'), 'rate_limited');
    expect(sent).toHaveLength(defaultAppConfig.otpRequestsPerPhonePerDay);
  });

  it('caps requests from one network', async () => {
    for (let i = 0; i < defaultAppConfig.otpRequestsPerIpPerHour; i++) {
      await request(`+9198000${String(i).padStart(5, '0')}`, '10.1.1.1');
    }
    await expectAppError(request('+919899999999', '10.1.1.1'), 'rate_limited');
  });

  it('when the SMS cannot be sent, says so and keeps no code', async () => {
    failSending = true;
    await expectAppError(request(), 'otp_send_failed');
    expect(await challenge()).toBeUndefined();
  });
});

describe('verifyLoginOtp', () => {
  it('the right code signs in a new number as a new account', async () => {
    await request();
    const { tokenHash } = await verify(lastCode());
    expect(authAdmin.created).toHaveLength(1);
    expect(tokenHash).toBe(`token-for-${authAdmin.created[0]}`);
    expect(await challenge()).toBeUndefined();
  });

  it('an existing account keeps its uid', async () => {
    await request();
    const first = await verify(lastCode());
    later(defaultAppConfig.otpResendSeconds);
    await request();
    expect(await verify(lastCode())).toEqual(first);
    expect(authAdmin.created).toHaveLength(1);
  });

  it('a code works once', async () => {
    await request();
    const code = lastCode();
    await verify(code);
    await expectAppError(verify(code), 'otp_expired');
  });

  it(`${defaultAppConfig.otpMaxAttempts} wrong tries use the code up`, async () => {
    await request();
    const right = lastCode();
    for (let i = 1; i < defaultAppConfig.otpMaxAttempts; i++) await expectAppError(verify(wrongCode()), 'otp_wrong');
    await expectAppError(verify(wrongCode()), 'otp_expired');
    await expectAppError(verify(right), 'otp_expired');
  });

  it('an old code has expired', async () => {
    await request();
    later(defaultAppConfig.otpValiditySeconds + 1);
    await expectAppError(verify(lastCode()), 'otp_expired');
  });

  it('a code for one number does not work for another', async () => {
    await request();
    await expectAppError(verify(lastCode(), '+919811122299'), 'otp_expired');
  });

  it('badly formed codes are wrong without using a try', async () => {
    await request();
    await expectAppError(verify('12'), 'otp_wrong');
    await expectAppError(verify('abcd'), 'otp_wrong');
    expect((await challenge()).attempts).toBe(0);
  });

  it('a banned account cannot sign in', async () => {
    await request();
    await verify(lastCode());
    const uid = authAdmin.created[0];
    await sql`insert into users (id, account_status) values (${uid}, 'banned')`;
    later(defaultAppConfig.otpResendSeconds);
    await request();
    await expectAppError(verify(lastCode()), 'blocked');
  });
});
