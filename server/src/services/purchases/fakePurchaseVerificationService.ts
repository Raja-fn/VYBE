import type {
  PurchaseClaim,
  PurchaseVerificationService,
  StorePlatform,
  StoreRefundNotice,
  VerifiedPurchase,
} from './purchaseVerificationService';

export interface FakePurchaseOptions {
  consumableProductIds: readonly string[];
  subscriptionProductIds: readonly string[];
  subscriptionPeriodDays: number;
  now?: () => Date;
}

/** Token prefix the fake accepts; anything else is treated as forged. */
export const FAKE_PURCHASE_TOKEN_PREFIX = 'fake-';
/** Purchase time inside a fake token: `fake-t<epoch ms>-…`. */
const FAKE_TIME = /^fake-t(\d{10,})-/;
/** A fake subscription the buyer has turned off: it ends after its first period. */
export const FAKE_NO_RENEW_MARKER = '-norenew';
/** A fake purchase still waiting for payment (e.g. a slow UPI payment). */
export const FAKE_PENDING_MARKER = '-pending';

const DAY_MS = 86_400_000;

/**
 * Emulator stand-in for Play / App Store receipt checks.
 *
 * Tokens are `fake-t<purchase time ms>-<anything>`. Subscriptions renew every
 * `subscriptionPeriodDays` from the purchase time unless the token contains
 * `-norenew`; each period gets its own transaction id (`…-p<n>`), like real
 * store orders.
 *
 * Refund notifications are JSON: `{ "fake": { "type": "refund", "storeTransactionId": "…" } }`.
 */
export class FakePurchaseVerificationService implements PurchaseVerificationService {
  constructor(private readonly options: FakePurchaseOptions) {}

  async verify(_uid: string, claim: PurchaseClaim): Promise<VerifiedPurchase> {
    const now = this.options.now?.() ?? new Date();
    const isSubscription = this.options.subscriptionProductIds.includes(claim.productId);
    const known = isSubscription || this.options.consumableProductIds.includes(claim.productId);
    const valid = known && claim.purchaseToken.startsWith(FAKE_PURCHASE_TOKEN_PREFIX);
    const base = {
      platform: claim.platform,
      productId: claim.productId,
      storeTransactionId: `fake-txn-${claim.purchaseToken}`,
      kind: isSubscription ? ('subscription' as const) : ('consumable' as const),
    };
    if (!valid) return { ...base, status: 'invalid' };
    if (claim.purchaseToken.includes(FAKE_PENDING_MARKER)) return { ...base, status: 'pending' };
    if (!isSubscription) return { ...base, status: 'valid' };

    const boughtAt = Number(FAKE_TIME.exec(claim.purchaseToken)?.[1] ?? now.getTime());
    const periodMs = this.options.subscriptionPeriodDays * DAY_MS;
    const renews = !claim.purchaseToken.includes(FAKE_NO_RENEW_MARKER);
    const elapsed = Math.max(0, now.getTime() - boughtAt);
    const period = renews ? Math.floor(elapsed / periodMs) : 0;
    const periodStart = new Date(boughtAt + period * periodMs);
    const expiresAt = new Date(periodStart.getTime() + periodMs);
    return {
      ...base,
      storeTransactionId: `${base.storeTransactionId}-p${period}`,
      status: expiresAt.getTime() > now.getTime() ? 'valid' : 'expired',
      periodStart,
      expiresAt,
      autoRenew: renews,
    };
  }

  async parseNotification(platform: StorePlatform, body: unknown): Promise<StoreRefundNotice | null> {
    const fake = (body as { fake?: { type?: unknown; storeTransactionId?: unknown } } | null)?.fake;
    if (!fake || typeof fake.storeTransactionId !== 'string') throw new Error('Not a store notification.');
    return fake.type === 'refund' ? { kind: 'refund', platform, storeTransactionId: fake.storeTransactionId } : null;
  }
}
