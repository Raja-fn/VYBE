import type { OtpSender } from './otpSender';

/**
 * Test project without a Renflair key, and tests: no SMS is sent. The code
 * is kept in `sent` and written to the Edge Function log
 * (Supabase dashboard -> Edge Functions -> api -> Logs).
 */
export class FakeOtpSender implements OtpSender {
  readonly sent: { phone: string; code: string }[] = [];

  async send(phoneE164: string, code: string): Promise<void> {
    this.sent.push({ phone: phoneE164, code });
    console.log(`Test login code for ${phoneE164}: ${code}`);
  }
}
