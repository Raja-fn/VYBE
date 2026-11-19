/** The parts of a Google Cloud service-account key file we use. */
export interface ServiceAccountKey {
  client_email: string;
  private_key: string;
  token_uri?: string;
  project_id?: string;
}

const base64url = (bytes: Uint8Array) =>
  btoa(String.fromCharCode(...bytes)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
const base64urlJson = (value: unknown) => base64url(new TextEncoder().encode(JSON.stringify(value)));

/** Imports a PEM PKCS#8 private key for RS256 signing (Web Crypto: Node and Deno). */
async function importKey(pem: string): Promise<CryptoKey> {
  const body = pem.replace(/-----[^-]+-----/g, '').replace(/\s+/g, '');
  const der = Uint8Array.from(atob(body), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey('pkcs8', der, { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['sign']);
}

/** OAuth access tokens for a Google service account, cached until shortly before they expire. */
export class ServiceAccountToken {
  private token: { value: string; expiresAt: number } | undefined;
  private key: Promise<CryptoKey> | undefined;

  constructor(
    private readonly account: ServiceAccountKey,
    private readonly scope: string,
    private readonly fetchFn: typeof fetch = fetch,
    private readonly now: () => Date = () => new Date(),
    private readonly purpose = 'Google',
  ) {}

  async get(): Promise<string> {
    const nowMs = this.now().getTime();
    if (this.token && this.token.expiresAt - 60_000 > nowMs) return this.token.value;
    const tokenUri = this.account.token_uri ?? 'https://oauth2.googleapis.com/token';
    const iat = Math.floor(nowMs / 1000);
    const unsigned = `${base64urlJson({ alg: 'RS256', typ: 'JWT' })}.${base64urlJson({
      iss: this.account.client_email,
      scope: this.scope,
      aud: tokenUri,
      iat,
      exp: iat + 3600,
    })}`;
    this.key ??= importKey(this.account.private_key);
    const signature = new Uint8Array(
      await crypto.subtle.sign('RSASSA-PKCS1-v1_5', await this.key, new TextEncoder().encode(unsigned)),
    );
    const response = await this.fetchFn(tokenUri, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: `${unsigned}.${base64url(signature)}`,
      }).toString(),
    });
    if (!response.ok) throw new Error(`Google sign-in for ${this.purpose} failed: HTTP ${response.status}`);
    const json = (await response.json()) as { access_token: string; expires_in: number };
    this.token = { value: json.access_token, expiresAt: nowMs + json.expires_in * 1000 };
    return json.access_token;
  }
}
