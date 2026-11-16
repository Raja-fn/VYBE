export type StorePlatform = 'android' | 'ios';

export interface PurchaseClaim {
  platform: StorePlatform;
  productId: string;
  /** Play purchase token, or App Store signed transaction. */
  purchaseToken: string;
}

export interface VerifiedPurchase {
  platform: StorePlatform;
  productId: string;
  /**
   * The store's id for this payment. A subscription gets a new one for every
   * paid period (Play order id `GPA.…..N`, App Store transaction id), so each
   * period is granted exactly once.
   */
  storeTransactionId: string;
  kind: 'consumable' | 'subscription';
  /** `expired`: a subscription that is no longer paid for. */
  status: 'valid' | 'invalid' | 'pending' | 'expired';
  /** Subscriptions only: the paid period. */
  periodStart?: Date;
  expiresAt?: Date;
  autoRenew?: boolean;
}

/** A refund (voided purchase) reported by the store. */
export interface StoreRefundNotice {
  kind: 'refund';
  platform: StorePlatform;
  storeTransactionId: string;
}

/**
 * Checks store receipts before any credits are granted, and reads the
 * store's server-to-server notifications.
 */
export interface PurchaseVerificationService {
  verify(uid: string, claim: PurchaseClaim): Promise<VerifiedPurchase>;

  /**
   * Checks the notification really comes from the store and returns what it
   * reports, or null for kinds we do not act on (renewals are picked up by
   * re-verifying, see `renewSubscriptions`).
   * Throws when the notification cannot be authenticated.
   */
  parseNotification(platform: StorePlatform, body: unknown, headers: Record<string, string | undefined>): Promise<StoreRefundNotice | null>;
}
