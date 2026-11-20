import { createHmac } from 'node:crypto';

import { sameSecret } from './constantTime';

/**
 * Admin panel sessions. After Google sign-in the server hands the panel a
 * token signed with FINDX_ADMIN_SECRET; the panel sends it with every admin
 * call. Nothing is stored: changing the secret signs everyone out, and
 * removing an email from FINDX_ADMIN_EMAILS locks that person out at once.
 */

export const ADMIN_SESSION_HOURS = 12;

export interface AdminSession {
  email: string;
  name: string;
  expiresAt: Date;
}

const toBase64Url = (bytes: Uint8Array) =>
  btoa(String.fromCharCode(...bytes)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

const sign = (key: string, payload: string) =>
  toBase64Url(new Uint8Array(createHmac('sha256', key).update(payload).digest()));

export function createAdminSession(key: string, email: string, name: string, now: Date): { token: string; expiresAt: Date } {
  const expiresAt = new Date(now.getTime() + ADMIN_SESSION_HOURS * 3_600_000);
  const payload = toBase64Url(new TextEncoder().encode(JSON.stringify({ e: email, n: name, x: expiresAt.getTime() })));
  return { token: `v1.${payload}.${sign(key, payload)}`, expiresAt };
}

/** The session behind [token], or null when it is forged, expired or not for a listed email. */
export function readAdminSession(key: string, token: string, allowedEmails: readonly string[], now: Date): AdminSession | null {
  const [version, payload, signature] = token.split('.');
  if (version !== 'v1' || !payload || !signature || !sameSecret(signature, sign(key, payload))) return null;
  try {
    const base64 = payload.replace(/-/g, '+').replace(/_/g, '/');
    const binary = atob(base64.padEnd(Math.ceil(base64.length / 4) * 4, '='));
    const data = JSON.parse(new TextDecoder().decode(Uint8Array.from(binary, (c) => c.charCodeAt(0)))) as {
      e?: unknown;
      n?: unknown;
      x?: unknown;
    };
    if (typeof data.e !== 'string' || typeof data.x !== 'number' || data.x <= now.getTime()) return null;
    if (!allowedEmails.includes(data.e)) return null;
    return { email: data.e, name: typeof data.n === 'string' ? data.n : data.e, expiresAt: new Date(data.x) };
  } catch {
    return null;
  }
}

/** FINDX_ADMIN_EMAILS: comma-separated Google accounts allowed into the panel. */
export const parseAdminEmails = (value: string | undefined): string[] =>
  (value ?? '')
    .split(',')
    .map((e) => e.trim().toLowerCase())
    .filter((e) => e.includes('@'));
