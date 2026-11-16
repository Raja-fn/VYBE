import type { EarningQuote, PaymentPayoutService, PayoutResult } from './paymentPayoutService';

/**
 * Emulator stand-in. Quotes 0 for every meetup, because no rate has been
 * decided. Payouts succeed and are idempotent per key.
 */
export class FakePaymentPayoutService implements PaymentPayoutService {
  private readonly payouts = new Map<string, PayoutResult>();

  async quoteEarning(input: { bookingId: string }): Promise<EarningQuote> {
    return { amountMinor: 0, currency: 'INR', quoteRef: `fake-quote-${input.bookingId}` };
  }

  async payout(input: { idempotencyKey: string; amountMinor: number }): Promise<PayoutResult> {
    if (input.amountMinor < 0) throw new Error('Payout amount cannot be negative');
    const existing = this.payouts.get(input.idempotencyKey);
    if (existing) return existing;
    const result: PayoutResult = { providerRef: `fake-payout-${input.idempotencyKey}`, status: 'paid' };
    this.payouts.set(input.idempotencyKey, result);
    return result;
  }
}
