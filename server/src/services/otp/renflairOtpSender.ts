import { OtpSendError, type OtpSender } from './otpSender';

/** Renflair SMS OTP API (https://renflair.in/OTP_API_DOCUMENTATION.pdf). */
export const RENFLAIR_ENDPOINT = 'https://sms.renflair.in/V1.php';
const TIMEOUT_MS = 10_000;
const COUNTRY_CODE = '+91';

/** Values of `status` that mean Renflair accepted the SMS. */
const ACCEPTED = new Set(['success', 'true', '1', 'ok', '200', 'sent']);

export interface FetchLike {
  (url: string, init?: { signal?: AbortSignal }): Promise<{ ok: boolean; status: number; text(): Promise<string> }>;
}

/**
 * Sends the code through Renflair. The API takes the 10-digit number without
 * +91 and a 4-digit code, and answers `{ "status": …, "message": … }`.
 * The API key is a secret: it is never logged or returned.
 */
export class RenflairOtpSender implements OtpSender {
  constructor(
    private readonly apiKey: string,
    private readonly fetchFn: FetchLike = fetch,
  ) {
    if (!apiKey) throw new OtpSendError('RENFLAIR_API_KEY is not set.');
  }

  async send(phoneE164: string, code: string): Promise<void> {
    if (!phoneE164.startsWith(COUNTRY_CODE)) throw new OtpSendError('Renflair only sends to Indian numbers.');
    const url = `${RENFLAIR_ENDPOINT}?${new URLSearchParams({ API: this.apiKey, PHONE: phoneE164.slice(COUNTRY_CODE.length), OTP: code })}`;

    let body: string;
    try {
      const response = await this.fetchFn(url, { signal: AbortSignal.timeout(TIMEOUT_MS) });
      body = await response.text();
      if (!response.ok) throw new OtpSendError(`Renflair HTTP ${response.status}`);
    } catch (error) {
      if (error instanceof OtpSendError) throw error;
      throw new OtpSendError(`Renflair unreachable: ${error instanceof Error ? error.name : 'error'}`);
    }

    let parsed: { status?: unknown; message?: unknown };
    try {
      parsed = JSON.parse(body) as { status?: unknown; message?: unknown };
    } catch {
      throw new OtpSendError('Renflair returned something that is not JSON.');
    }
    if (!ACCEPTED.has(String(parsed.status).trim().toLowerCase())) {
      throw new OtpSendError(`Renflair refused the SMS: ${String(parsed.message ?? parsed.status)}`);
    }
  }
}
