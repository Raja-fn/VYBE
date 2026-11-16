import { createHash, randomInt } from 'node:crypto';

import { z } from 'zod';

import type { AppConfig } from '../config/appConfig';
import type { AuthAdmin } from '../services/auth/authAdmin';
import { OtpSendError, type OtpSender } from '../services/otp/otpSender';
import type { Db } from '../shared/db';
import { sameSecret } from '../shared/constantTime';
import { appError, ErrorCodes } from '../shared/errorCodes';
import { consumeRateLimit } from '../shared/rateLimit';

const HOUR_MS = 3_600_000;
const DAY_MS = 24 * HOUR_MS;

export interface PhoneLoginDeps {
  sql: Db;
  authAdmin: AuthAdmin;
  config: AppConfig;
  sender: OtpSender;
  now: () => Date;
  /** Caller's IP address, for the per-network limit. */
  ip: string;
}

const phoneSchema = (config: AppConfig) =>
  z
    .string()
    .trim()
    .refine(
      (p) =>
        p.startsWith(config.phoneCountryCode) &&
        new RegExp(`^\\d{${config.phoneNationalNumberLength}}$`).test(p.slice(config.phoneCountryCode.length)),
      'Enter a valid mobile number.',
    );

const sha256 = (value: string) => createHash('sha256').update(value).digest('hex');
const codeHash = (salt: string, code: string) => sha256(`${salt}:${code}`);
const ipKey = (ip: string) => `otp_ip_${sha256(ip).slice(0, 32)}`;

// ---------- requestLoginOtp ----------

export const requestLoginOtpInput = z.object({ phone: z.string() });

/**
 * Creates a login code, keeps only its salted hash in `otp_challenges`
 * (server-only) and sends it by SMS. Limits: one code per `otpResendSeconds`,
 * `otpRequestsPerPhonePerDay` per number, `otpRequestsPerIpPerHour` per network.
 */
export async function requestLoginOtpLogic(
  deps: PhoneLoginDeps,
  input: { phone: string },
): Promise<{ phone: string; resendAfterSeconds: number }> {
  const { sql, config } = deps;
  if (!config.phoneLoginEnabled) throw appError(ErrorCodes.invalidInput, 'Phone login is not available yet.');
  const parsed = phoneSchema(config).safeParse(input.phone);
  if (!parsed.success) throw appError(ErrorCodes.invalidInput, 'Enter a valid mobile number.');
  const phone = parsed.data;
  const now = deps.now();

  const [existing] = await sql<{ sent_at: Date }[]>`select sent_at from otp_challenges where phone = ${phone}`;
  const lastSent = existing ? existing.sent_at.getTime() : 0;
  if (lastSent + config.otpResendSeconds * 1000 > now.getTime()) {
    throw appError(ErrorCodes.rateLimited, 'Wait a moment before asking for another code.');
  }
  await consumeRateLimit(sql, ipKey(deps.ip), config.otpRequestsPerIpPerHour, HOUR_MS, now);
  await consumeRateLimit(sql, `otp_phone_${phone}`, config.otpRequestsPerPhonePerDay, DAY_MS, now);

  const code = String(randomInt(0, 10 ** config.otpLength)).padStart(config.otpLength, '0');
  const salt = sha256(`${phone}:${now.getTime()}:${randomInt(0, 2 ** 47)}`);
  const expiresAt = new Date(now.getTime() + config.otpValiditySeconds * 1000);
  await sql`
    insert into otp_challenges (phone, code_hash, salt, attempts, sent_at, expires_at)
    values (${phone}, ${codeHash(salt, code)}, ${salt}, 0, ${now}, ${expiresAt})
    on conflict (phone) do update set code_hash = excluded.code_hash, salt = excluded.salt, attempts = 0,
      sent_at = excluded.sent_at, expires_at = excluded.expires_at`;

  try {
    await deps.sender.send(phone, code);
  } catch (error) {
    await sql`delete from otp_challenges where phone = ${phone}`;
    console.error('Login code not sent', { reason: error instanceof OtpSendError ? error.message : String(error) });
    throw appError(ErrorCodes.otpSendFailed, 'We could not send the SMS. Try again in a moment.');
  }
  return { phone, resendAfterSeconds: config.otpResendSeconds };
}

// ---------- verifyLoginOtp ----------

export const verifyLoginOtpInput = z.object({ phone: z.string(), code: z.string().trim() });

/**
 * Checks the code. `otpMaxAttempts` wrong tries or `otpValiditySeconds` end
 * the code. On success the code is used up and the person gets a one-time
 * sign-in token (a magic-link token hash, exchanged by the app with
 * `verifyOTP`) for the account with that phone number, created on first sign-in.
 */
export async function verifyLoginOtpLogic(
  deps: PhoneLoginDeps,
  input: { phone: string; code: string },
): Promise<{ tokenHash: string }> {
  const { sql, config } = deps;
  const parsed = phoneSchema(config).safeParse(input.phone);
  if (!parsed.success || !new RegExp(`^\\d{${config.otpLength}}$`).test(input.code)) {
    throw appError(ErrorCodes.otpWrong, 'That code is not right.');
  }
  const phone = parsed.data;
  const now = deps.now();
  await consumeRateLimit(sql, ipKey(deps.ip), config.otpRequestsPerIpPerHour * config.otpMaxAttempts, HOUR_MS, now);

  const outcome = await sql.begin(async (tx) => {
    const [challenge] = await tx<{ code_hash: string; salt: string; attempts: number; expires_at: Date }[]>`
      select code_hash, salt, attempts, expires_at from otp_challenges where phone = ${phone} for update`;
    if (!challenge) return 'expired' as const;
    if (challenge.expires_at.getTime() <= now.getTime() || challenge.attempts >= config.otpMaxAttempts) {
      await tx`delete from otp_challenges where phone = ${phone}`;
      return 'expired' as const;
    }
    if (!sameSecret(challenge.code_hash, codeHash(challenge.salt, input.code))) {
      const used = challenge.attempts + 1 >= config.otpMaxAttempts;
      if (used) await tx`delete from otp_challenges where phone = ${phone}`;
      else await tx`update otp_challenges set attempts = attempts + 1 where phone = ${phone}`;
      return used ? ('expired' as const) : ('wrong' as const);
    }
    await tx`delete from otp_challenges where phone = ${phone}`;
    return 'ok' as const;
  });
  if (outcome === 'expired') throw appError(ErrorCodes.otpExpired, 'This code has expired. Ask for a new one.');
  if (outcome === 'wrong') throw appError(ErrorCodes.otpWrong, 'That code is not right.');

  const uid = await uidForPhone(deps, phone);
  return { tokenHash: await deps.authAdmin.createSignInToken(uid) };
}

async function uidForPhone(deps: PhoneLoginDeps, phone: string): Promise<string> {
  const [known] = await deps.sql<{ uid: string; account_status: string | null }[]>`
    select l.uid, u.account_status from phone_logins l left join users u on u.id = l.uid where l.phone = ${phone}`;
  if (known) {
    if (known.account_status === 'banned') throw appError(ErrorCodes.blocked, 'This account is not available.');
    return known.uid;
  }
  const uid = await deps.authAdmin.createPhoneUser(phone);
  await deps.sql`insert into phone_logins (phone, uid) values (${phone}, ${uid}) on conflict (phone) do nothing`;
  const [row] = await deps.sql<{ uid: string }[]>`select uid from phone_logins where phone = ${phone}`;
  return row.uid;
}
