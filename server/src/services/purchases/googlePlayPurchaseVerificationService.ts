import { sameSecret } from '../../shared/constantTime';
import { ServiceAccountToken, type ServiceAccountKey } from '../google/serviceAccountToken';
import type {
  PurchaseClaim,
  PurchaseVerificationService,
  StorePlatform,
  StoreRefundNotice,
  VerifiedPurchase,
} from './purchaseVerificationService';

export type { ServiceAccountKey };

export interface GooglePlayOptions {
  /** Android application id, e.g. com.vybe.app. */
  packageName: string;
  serviceAccount: ServiceAccountKey;
  consumableProductIds: readonly string[];
  subscriptionProductIds: readonly string[];
  /**
   * Shared secret in the Pub/Sub push URL (`…/storeNotification?platform=android&token=<secret>`).
   * Notifications without it are rejected.
   */
  notificationSecret: string;
  fetchFn?: typeof fetch;
  now?: () => Date;
}

const API = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications';
const SCOPE = 'https://www.googleapis.com/auth/androidpublisher';

/** Google Play subscription states that still give the buyer their plan. */
const ACTIVE_STATES = new Set(['SUBSCRIPTION_STATE_ACTIVE', 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD', 'SUBSCRIPTION_STATE_CANCELED']);

/**
 * Real Google Play receipts, checked with the Play Developer API.
 *
 * - Credit packs: `purchases.products.get`; the order id is the transaction.
 * - Plans: `purchases.subscriptionsv2.get`; the latest order id changes every
 *   paid period, so each period is granted once.
 * - Refunds: Real-time developer notifications through a Pub/Sub push
 *   subscription (voided purchases).
 */
export class GooglePlayPurchaseVerificationService implements PurchaseVerificationService {
  private readonly token: ServiceAccountToken;
  private readonly fetchFn: typeof fetch;
  private readonly now: () => Date;

  constructor(private readonly options: GooglePlayOptions) {
    this.fetchFn = options.fetchFn ?? fetch;
    this.now = options.now ?? (() => new Date());
    this.token = new ServiceAccountToken(options.serviceAccount, SCOPE, this.fetchFn, this.now, 'Play checks');
  }

  /** An OAuth access token for the service account (cached until shortly before it expires). */
  private accessToken(): Promise<string> {
    return this.token.get();
  }

  private async get(path: string): Promise<{ status: number; json: Record<string, unknown> }> {
    const response = await this.fetchFn(`${API}/${encodeURIComponent(this.options.packageName)}/${path}`, {
      headers: { Authorization: `Bearer ${await this.accessToken()}` },
    });
    const json = (await response.json().catch(() => ({}))) as Record<string, unknown>;
    // 400/404/410: the token is not a purchase of this app (forged, wrong app, or long expired).
    if (response.status >= 500) throw new Error(`Google Play check failed: HTTP ${response.status}`);
    return { status: response.status, json };
  }

  async verify(_uid: string, claim: PurchaseClaim): Promise<VerifiedPurchase> {
    const isSubscription = this.options.subscriptionProductIds.includes(claim.productId);
    const known = isSubscription || this.options.consumableProductIds.includes(claim.productId);
    const invalid: VerifiedPurchase = {
      platform: claim.platform,
      productId: claim.productId,
      storeTransactionId: '',
      kind: isSubscription ? 'subscription' : 'consumable',
      status: 'invalid',
    };
    if (claim.platform !== 'android' || !known) return invalid;
    const token = encodeURIComponent(claim.purchaseToken);
    return isSubscription ? this.verifySubscription(claim, token, invalid) : this.verifyProduct(claim, token, invalid);
  }

  private async verifyProduct(claim: PurchaseClaim, token: string, invalid: VerifiedPurchase): Promise<VerifiedPurchase> {
    const { status, json } = await this.get(`purchases/products/${encodeURIComponent(claim.productId)}/tokens/${token}`);
    if (status !== 200 || typeof json.orderId !== 'string') return invalid;
    // 0 purchased, 1 cancelled, 2 pending.
    const state = json.purchaseState;
    const result = { ...invalid, storeTransactionId: json.orderId };
    if (state === 0) return { ...result, status: 'valid' };
    if (state === 2) return { ...result, status: 'pending' };
    return result;
  }

  private async verifySubscription(claim: PurchaseClaim, token: string, invalid: VerifiedPurchase): Promise<VerifiedPurchase> {
    const { status, json } = await this.get(`purchases/subscriptionsv2/tokens/${token}`);
    const lineItems = (json.lineItems as { productId?: string; expiryTime?: string; autoRenewingPlan?: { autoRenewEnabled?: boolean } }[]) ?? [];
    const item = lineItems.find((l) => l.productId === claim.productId);
    const orderId = json.latestOrderId;
    if (status !== 200 || !item || typeof orderId !== 'string') return invalid;

    const state = String(json.subscriptionState ?? '');
    const expiresAt = item.expiryTime ? new Date(item.expiryTime) : undefined;
    const result: VerifiedPurchase = {
      ...invalid,
      storeTransactionId: orderId,
      periodStart: typeof json.startTime === 'string' ? new Date(json.startTime) : undefined,
      expiresAt,
      autoRenew: item.autoRenewingPlan?.autoRenewEnabled ?? false,
      status: 'invalid',
    };
    if (state === 'SUBSCRIPTION_STATE_PENDING') return { ...result, status: 'pending' };
    const paidUp = expiresAt !== undefined && expiresAt.getTime() > this.now().getTime();
    if (ACTIVE_STATES.has(state) && paidUp) return { ...result, status: 'valid' };
    return { ...result, status: 'expired' };
  }

  async parseNotification(
    platform: StorePlatform,
    body: unknown,
    headers: Record<string, string | undefined>,
  ): Promise<StoreRefundNotice | null> {
    if (platform !== 'android') throw new Error('Only Google Play notifications are accepted.');
    if (!this.options.notificationSecret || !sameSecret(headers['x-findx-query-token'] ?? '', this.options.notificationSecret)) {
      throw new Error('Notification token is missing or wrong.');
    }
    const data = (body as { message?: { data?: unknown } } | null)?.message?.data;
    if (typeof data !== 'string') throw new Error('Not a Pub/Sub push message.');
    const payload = JSON.parse(atob(data)) as {
      packageName?: string;
      voidedPurchaseNotification?: { orderId?: string };
    };
    if (payload.packageName !== this.options.packageName) throw new Error('Notification for another app.');
    const orderId = payload.voidedPurchaseNotification?.orderId;
    // Other kinds (renewals, cancellations, test pings) need no action: renewals are re-checked hourly.
    return orderId ? { kind: 'refund', platform: 'android', storeTransactionId: orderId } : null;
  }
}
