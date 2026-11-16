import { PHONE_EMAIL_DOMAIN } from '../services/auth/authAdmin';
import type { Caller } from '../shared/callable';

/** The parts of a Supabase Auth user the server reads. */
export interface AuthUserJson {
  id: string;
  email?: string | null;
  email_confirmed_at?: string | null;
  app_metadata?: { phone_e164?: unknown } | null;
}

/** Turns a Supabase Auth user into the caller the handlers see. */
export function callerFromAuthUser(user: AuthUserJson): Caller {
  const email = user.email ?? undefined;
  // Phone-login accounts have a placeholder address, which is never a verified email.
  const verifiedEmail =
    email && user.email_confirmed_at && !email.toLowerCase().endsWith(`@${PHONE_EMAIL_DOMAIN}`) ? email.toLowerCase() : undefined;
  const phone = user.app_metadata?.phone_e164;
  return { uid: user.id, phoneNumber: typeof phone === 'string' ? phone : undefined, verifiedEmail };
}

/**
 * Asks Supabase Auth who owns this access token. Authoritative (checks the
 * signature, expiry and sign-out), and works with every JWT signing-key setup.
 */
export function supabaseCallerResolver(url: string, anonKey: string, fetchFn: typeof fetch = fetch) {
  return async (accessToken: string): Promise<Caller | null> => {
    const response = await fetchFn(`${url}/auth/v1/user`, {
      headers: { apikey: anonKey, Authorization: `Bearer ${accessToken}` },
    });
    if (response.status === 401 || response.status === 403) return null;
    if (!response.ok) throw new Error(`Auth check failed: HTTP ${response.status}`);
    return callerFromAuthUser((await response.json()) as AuthUserJson);
  };
}
