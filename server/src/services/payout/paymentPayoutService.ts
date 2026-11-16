export interface EarningQuote {
  amountMinor: number;
  currency: 'INR';
  quoteRef: string;
}

export interface PayoutResult {
  providerRef: string;
  status: 'pending' | 'paid' | 'failed';
}

/**
 * Companion earnings and payouts. The commission rate and payout provider are
 * NOT decided, so no rate exists anywhere in code or config: the amount
 * always comes from this service.
 */
export interface PaymentPayoutService {
  quoteEarning(input: { bookingId: string; companionUid: string; planType: string; creditCost: number }): Promise<EarningQuote>;
  payout(input: { uid: string; amountMinor: number; currency: 'INR'; idempotencyKey: string }): Promise<PayoutResult>;
}
