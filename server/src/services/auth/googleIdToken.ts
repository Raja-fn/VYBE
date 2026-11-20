/**
 * Checks a Google Sign-In ID token (a JWT from Google Identity Services)
 * against Google's public keys. Works in Node and in the Supabase Edge
 * runtime (Web Crypto only).
 */

export interface GoogleIdentity {
  email: string;
  name: string;
}

/** Returns who signed in, or null when the token is not a valid Google token for [clientId]. */
export type GoogleIdTokenVerifier = (idToken: string) => Promise<GoogleIdentity | null>;

const CERTS_URL = 'https://www.googleapis.com/oauth2/v3/certs';
const ISSUERS = new Set(['accounts.google.com', 'https://accounts.google.com']);
/** Clock difference allowed between Google and this server. */
const SKEW_SECONDS = 60;

type Jwk = JsonWebKey & { kid?: string };

const fromBase64Url = (text: string): Uint8Array<ArrayBuffer> => {
  const base64 = text.replace(/-/g, '+').replace(/_/g, '/').padEnd(Math.ceil(text.length / 4) * 4, '=');
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes;
};

const decodeJson = (part: string): Record<string, unknown> | null => {
  try {
    const value: unknown = JSON.parse(new TextDecoder().decode(fromBase64Url(part)));
    return value && typeof value === 'object' ? (value as Record<string, unknown>) : null;
  } catch {
    return null;
  }
};

export function googleIdTokenVerifier(
  clientId: string,
  options: { fetchKeys?: () => Promise<Jwk[]>; now?: () => Date } = {},
): GoogleIdTokenVerifier {
  let cache: { keys: Jwk[]; until: number } | undefined;
  const now = options.now ?? (() => new Date());
  const fetchKeys =
    options.fetchKeys ??
    (async () => {
      const response = await fetch(CERTS_URL);
      if (!response.ok) throw new Error(`Google keys: HTTP ${response.status}`);
      return ((await response.json()) as { keys: Jwk[] }).keys;
    });

  const keyFor = async (kid: string): Promise<Jwk | undefined> => {
    if (!cache || cache.until < Date.now() || !cache.keys.some((k) => k.kid === kid)) {
      cache = { keys: await fetchKeys(), until: Date.now() + 60 * 60_000 };
    }
    return cache.keys.find((k) => k.kid === kid);
  };

  return async (idToken) => {
    const parts = idToken.split('.');
    if (parts.length !== 3 || !clientId) return null;
    const header = decodeJson(parts[0]);
    const claims = decodeJson(parts[1]);
    if (!header || !claims || header.alg !== 'RS256' || typeof header.kid !== 'string') return null;

    const jwk = await keyFor(header.kid);
    if (!jwk) return null;
    const key = await crypto.subtle.importKey('jwk', jwk, { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, [
      'verify',
    ]);
    const signed = new TextEncoder().encode(`${parts[0]}.${parts[1]}`);
    if (!(await crypto.subtle.verify('RSASSA-PKCS1-v1_5', key, fromBase64Url(parts[2]), signed))) return null;

    const seconds = now().getTime() / 1000;
    if (!ISSUERS.has(String(claims.iss)) || claims.aud !== clientId) return null;
    if (typeof claims.exp !== 'number' || claims.exp + SKEW_SECONDS < seconds) return null;
    if (claims.email_verified !== true || typeof claims.email !== 'string') return null;
    return {
      email: claims.email.toLowerCase(),
      name: typeof claims.name === 'string' && claims.name ? claims.name : claims.email,
    };
  };
}
