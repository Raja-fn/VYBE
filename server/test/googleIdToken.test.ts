import { generateKeyPairSync, createSign } from 'node:crypto';

import { googleIdTokenVerifier } from '../src/services/auth/googleIdToken';
import { createAdminSession, parseAdminEmails, readAdminSession } from '../src/shared/adminSession';

const CLIENT = 'client-123.apps.googleusercontent.com';
const NOW = new Date('2026-11-20T10:00:00Z');
const { privateKey, publicKey } = generateKeyPairSync('rsa', { modulusLength: 2048 });
const jwk = { ...(publicKey.export({ format: 'jwk' }) as JsonWebKey), kid: 'k1', alg: 'RS256', use: 'sig' };

const b64 = (value: unknown) => Buffer.from(JSON.stringify(value)).toString('base64url');
function token(claims: Record<string, unknown>, kid = 'k1') {
  const head = `${b64({ alg: 'RS256', kid, typ: 'JWT' })}.${b64(claims)}`;
  return `${head}.${createSign('RSA-SHA256').update(head).sign(privateKey).toString('base64url')}`;
}
const good = {
  iss: 'https://accounts.google.com',
  aud: CLIENT,
  exp: NOW.getTime() / 1000 + 600,
  email: 'Owner@Example.com',
  email_verified: true,
  name: 'Owner',
};
const verify = googleIdTokenVerifier(CLIENT, { fetchKeys: async () => [jwk], now: () => NOW });

describe('Google ID token check', () => {
  it('accepts a valid token and lower-cases the email', async () => {
    expect(await verify(token(good))).toEqual({ email: 'owner@example.com', name: 'Owner' });
  });

  it('refuses tokens for another app, expired, unverified or tampered with', async () => {
    expect(await verify(token({ ...good, aud: 'other' }))).toBeNull();
    expect(await verify(token({ ...good, iss: 'evil.com' }))).toBeNull();
    expect(await verify(token({ ...good, exp: NOW.getTime() / 1000 - 120 }))).toBeNull();
    expect(await verify(token({ ...good, email_verified: false }))).toBeNull();
    expect(await verify(token(good, 'unknown'))).toBeNull();
    const [h, , s] = token(good).split('.');
    expect(await verify(`${h}.${b64({ ...good, email: 'x@example.com' })}.${s}`)).toBeNull();
    expect(await verify('not-a-token')).toBeNull();
  });
});

describe('admin sessions', () => {
  it('round-trip, expire after 12 hours and need a listed email', () => {
    const { token: t } = createAdminSession('key', 'a@x.com', 'Ä Name', NOW);
    expect(readAdminSession('key', t, ['a@x.com'], NOW)?.name).toBe('Ä Name');
    expect(readAdminSession('other', t, ['a@x.com'], NOW)).toBeNull();
    expect(readAdminSession('key', t, ['b@x.com'], NOW)).toBeNull();
    expect(readAdminSession('key', t, ['a@x.com'], new Date(NOW.getTime() + 12 * 3_600_000 + 1))).toBeNull();
  });

  it('read the email list', () => {
    expect(parseAdminEmails(' A@x.com, b@y.com ,, nope')).toEqual(['a@x.com', 'b@y.com']);
    expect(parseAdminEmails(undefined)).toEqual([]);
  });
});
