/** Supabase Auth admin actions the server needs. Behind an interface for tests. */
export interface AuthAdmin {
  /** Creates an account for a phone-login person and returns its id. */
  createPhoneUser(phoneE164: string): Promise<string>;
  /** A one-time sign-in token hash the app exchanges with `verifyOTP(type: magiclink)`. */
  createSignInToken(uid: string): Promise<string>;
  /** Deletes the sign-in account; the database removes the person's rows with it. */
  deleteUser(uid: string): Promise<void>;
  /** Deletes stored files (photos, voice, ID images) from one bucket. */
  deleteFiles(bucket: string, names: string[]): Promise<void>;
}

/**
 * Phone-login accounts get a placeholder email (Supabase sign-in tokens are
 * email based). No email is ever sent to it, and the server never treats it
 * as a verified address.
 */
export const PHONE_EMAIL_DOMAIN = 'phone.findx.invalid';
export const phoneEmail = (phoneE164: string) => `${phoneE164.replace(/\D/g, '')}@${PHONE_EMAIL_DOMAIN}`;

type FetchFn = typeof fetch;

/** Talks to the Supabase Auth admin API with the service-role key. */
export class SupabaseAuthAdmin implements AuthAdmin {
  constructor(
    private readonly url: string,
    private readonly serviceRoleKey: string,
    private readonly fetchFn: FetchFn = fetch,
  ) {}

  private async call(path: string, body: unknown): Promise<Record<string, unknown>> {
    const response = await this.fetchFn(`${this.url}/auth/v1/admin/${path}`, {
      method: 'POST',
      headers: {
        apikey: this.serviceRoleKey,
        Authorization: `Bearer ${this.serviceRoleKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });
    const json = (await response.json().catch(() => ({}))) as Record<string, unknown>;
    if (!response.ok) throw new Error(`Auth admin ${path} failed: HTTP ${response.status} ${String(json.msg ?? json.error ?? '')}`);
    return json;
  }

  private get headers() {
    return { apikey: this.serviceRoleKey, Authorization: `Bearer ${this.serviceRoleKey}`, 'Content-Type': 'application/json' };
  }

  async deleteUser(uid: string): Promise<void> {
    const response = await this.fetchFn(`${this.url}/auth/v1/admin/users/${uid}`, { method: 'DELETE', headers: this.headers });
    // 404: already gone, which is the goal.
    if (!response.ok && response.status !== 404) throw new Error(`Account deletion failed: HTTP ${response.status}`);
  }

  async deleteFiles(bucket: string, names: string[]): Promise<void> {
    if (names.length === 0) return;
    const response = await this.fetchFn(`${this.url}/storage/v1/object/${bucket}`, {
      method: 'DELETE',
      headers: this.headers,
      body: JSON.stringify({ prefixes: names }),
    });
    if (!response.ok) throw new Error(`File deletion failed: HTTP ${response.status}`);
  }

  async createPhoneUser(phoneE164: string): Promise<string> {
    const user = await this.call('users', {
      email: phoneEmail(phoneE164),
      email_confirm: true,
      app_metadata: { phone_e164: phoneE164 },
    });
    return user.id as string;
  }

  async createSignInToken(uid: string): Promise<string> {
    const response = await this.fetchFn(`${this.url}/auth/v1/admin/users/${uid}`, {
      headers: { apikey: this.serviceRoleKey, Authorization: `Bearer ${this.serviceRoleKey}` },
    });
    if (!response.ok) throw new Error(`Auth admin lookup failed: HTTP ${response.status}`);
    const user = (await response.json()) as { email?: string };
    if (!user.email) throw new Error('This account has no sign-in address.');
    const link = await this.call('generate_link', { type: 'magiclink', email: user.email });
    const properties = (link.properties ?? link) as { hashed_token?: string };
    if (!properties.hashed_token) throw new Error('Auth admin returned no token.');
    return properties.hashed_token;
  }
}
