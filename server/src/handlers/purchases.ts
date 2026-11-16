import { createHash } from 'node:crypto';

import { z } from 'zod';

import type { PlanTier } from '../config/appConfig';
import { planChange, productFor, refundTakeBack, type CurrentSubscription, type StoreProduct } from '../domain/credits';
import type { PurchaseClaim, StorePlatform, VerifiedPurchase } from '../services/purchases/purchaseVerificationService';
import type { Caller } from '../shared/callable';
import type { Sql } from '../shared/db';
import { appError, ErrorCodes } from '../shared/errorCodes';
import type { Deps } from './deps';

/** Plans handled per run; the next run picks up the rest. */
const RENEWAL_BATCH_SIZE = 200;

export type VerifyStatus = 'granted' | 'already_granted' | 'pending' | 'at_renewal';

export interface VerifyPurchaseResult {
  status: VerifyStatus;
  creditsAdded: number;
  balance: number;
  tier: PlanTier;
}

/** Store transaction ids can contain characters we keep out of ids. */
export const purchaseDocId = (platform: StorePlatform, storeTransactionId: string) =>
  `${platform}_${storeTransactionId.replace(/[^A-Za-z0-9._-]/g, '_')}`;

const hashToken = (token: string) => createHash('sha256').update(token).digest('hex');

interface SubscriptionRow {
  uid: string;
  tier: PlanTier;
  status: string;
  current_period_end: Date | null;
  latest_purchase_id: string | null;
  pending_purchase_id: string | null;
}

function subscriptionFrom(row: SubscriptionRow | undefined): CurrentSubscription | null {
  if (!row) return null;
  return { tier: row.tier ?? 'free', status: row.status ?? 'active', currentPeriodEnd: row.current_period_end };
}

/**
 * Records one verified store payment and grants its credits, exactly once
 * per store transaction. A receipt used by one account can never grant
 * credits to another.
 *
 * `mode: 'renewal'` applies a plan period found by the renewal job, including
 * a downgrade that was waiting for the renewal.
 */
async function recordVerifiedPurchase(
  deps: Deps,
  uid: string,
  claim: PurchaseClaim,
  verified: VerifiedPurchase,
  product: StoreProduct,
  mode: 'client' | 'renewal',
): Promise<VerifyPurchaseResult> {
  const { config } = deps;
  const now = deps.now();
  const purchaseId = purchaseDocId(claim.platform, verified.storeTransactionId);
  const tokenHash = hashToken(claim.purchaseToken);

  return deps.sql.begin(async (tx) => {
    // One purchase at a time per account; the token check below covers other accounts.
    const [account] = await tx<{ balance: number }[]>`select balance from credit_accounts where uid = ${uid} for update`;
    const owners = await tx<{ id: string; uid: string; status: string }[]>`
      select id, uid, status from purchases where id = ${purchaseId} or token_hash = ${tokenHash} for update`;
    if (owners.some((p) => p.uid !== uid)) {
      throw appError(ErrorCodes.purchaseInvalid, 'This purchase belongs to another account.');
    }
    const purchase = owners.find((p) => p.id === purchaseId);
    const [sub] = await tx<SubscriptionRow[]>`select * from subscriptions where uid = ${uid} for update`;
    const balance = account?.balance ?? 0;
    const current = subscriptionFrom(sub);
    const currentTier = current?.tier ?? 'free';

    if (purchase && !(purchase.status === 'deferred' && mode === 'renewal')) {
      return {
        status: purchase.status === 'deferred' ? 'at_renewal' : 'already_granted',
        creditsAdded: 0,
        balance,
        tier: currentTier,
      };
    }

    const record = {
      id: purchaseId,
      uid,
      platform: claim.platform,
      product_id: claim.productId,
      kind: verified.kind,
      store_transaction_id: verified.storeTransactionId,
      purchase_token: claim.purchaseToken,
      token_hash: tokenHash,
      verified_at: now,
      period_start: verified.periodStart ?? null,
      period_end: verified.expiresAt ?? null,
    };
    const upsertPurchase = (status: string, credits: number, ledgerId: string | null) => tx`
      insert into purchases ${tx({ ...record, status, credits, ledger_id: ledgerId })}
      on conflict (id) do update set status = excluded.status, credits = excluded.credits, ledger_id = excluded.ledger_id,
        verified_at = excluded.verified_at, period_start = excluded.period_start, period_end = excluded.period_end`;

    if (product.kind === 'plan' && mode === 'client' && planChange(config, current, product.tier, now) === 'at_renewal') {
      await upsertPurchase('deferred', 0, null);
      await tx`
        update subscriptions set pending_tier = ${product.tier}, pending_product_id = ${product.productId},
          pending_purchase_id = ${purchaseId}, updated_at = ${now}
        where uid = ${uid}`;
      return { status: 'at_renewal', creditsAdded: 0, balance, tier: currentTier };
    }

    const credits = product.kind === 'pack' ? product.credits : product.monthlyCredits;
    const after = balance + credits;
    const ledgerId = `purchase_${purchaseId}`;
    await tx`
      insert into credit_accounts (uid, balance, updated_at) values (${uid}, ${after}, ${now})
      on conflict (uid) do update set balance = excluded.balance, updated_at = excluded.updated_at`;
    await tx`
      insert into credit_ledger (id, uid, delta, balance_after, reason, ref_type, ref_id, idempotency_key, created_at)
      values (${ledgerId}, ${uid}, ${credits}, ${after}, ${product.kind === 'pack' ? 'purchase' : 'subscription_grant'},
        'purchase', ${purchaseId}, ${ledgerId}, ${now})`;
    await upsertPurchase('granted', credits, ledgerId);

    if (product.kind === 'pack') return { status: 'granted', creditsAdded: credits, balance: after, tier: currentTier };

    await tx`
      insert into subscriptions as s (uid, tier, product_id, platform, status, current_period_end, auto_renew,
        last_grant_at, latest_purchase_id, pending_tier, pending_product_id, pending_purchase_id, updated_at)
      values (${uid}, ${product.tier}, ${product.productId}, ${claim.platform}, 'active', ${record.period_end},
        ${verified.autoRenew ?? true}, ${now}, ${purchaseId}, null, null, null, ${now})
      on conflict (uid) do update set tier = excluded.tier, product_id = excluded.product_id, platform = excluded.platform,
        status = excluded.status, current_period_end = excluded.current_period_end, auto_renew = excluded.auto_renew,
        last_grant_at = excluded.last_grant_at, latest_purchase_id = excluded.latest_purchase_id,
        pending_tier = null, pending_product_id = null, pending_purchase_id = null, updated_at = excluded.updated_at`;
    return { status: 'granted', creditsAdded: credits, balance: after, tier: product.tier };
  });
}

// ---------- verifyPurchase ----------

export const verifyPurchaseInput = z.object({
  platform: z.enum(['android', 'ios']),
  productId: z.string().min(1),
  purchaseToken: z.string().min(1),
});

async function balanceAndTier(sql: Sql, uid: string) {
  const [row] = await sql<{ balance: number | null; tier: PlanTier | null; status: string | null }[]>`
    select (select balance from credit_accounts where uid = ${uid}) as balance,
      (select tier from subscriptions where uid = ${uid}) as tier,
      (select status from subscriptions where uid = ${uid}) as status`;
  return { balance: row?.balance ?? 0, tier: row?.tier ?? 'free' };
}

/** The app sends each store purchase here; credits are added only after the store confirms it. */
export async function verifyPurchaseLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof verifyPurchaseInput>,
): Promise<VerifyPurchaseResult> {
  const product = productFor(deps.config, input.productId);
  if (!product) throw appError(ErrorCodes.invalidInput, 'Unknown product.');

  const verified = await deps.services.purchases.verify(caller.uid, input);
  if (verified.productId !== input.productId || verified.status === 'invalid' || verified.status === 'expired') {
    throw appError(ErrorCodes.purchaseInvalid, 'The store could not confirm this purchase.');
  }
  if (verified.status === 'pending') {
    const { balance, tier } = await balanceAndTier(deps.sql, caller.uid);
    return { status: 'pending', creditsAdded: 0, balance, tier };
  }
  return recordVerifiedPurchase(deps, caller.uid, input, verified, product, 'client');
}

// ---------- renewSubscriptions ----------

async function claimFrom(sql: Sql, purchaseId: string | null): Promise<PurchaseClaim | null> {
  if (!purchaseId) return null;
  const [row] = await sql<{ platform: StorePlatform; product_id: string; purchase_token: string }[]>`
    select platform, product_id, purchase_token from purchases where id = ${purchaseId}`;
  return row ? { platform: row.platform, productId: row.product_id, purchaseToken: row.purchase_token } : null;
}

/**
 * Re-checks one plan whose period has ended: a waiting downgrade first, then
 * the current plan. A new paid period grants its credits; otherwise the
 * person goes back to Free. Credits they already have are kept.
 */
async function renewOne(deps: Deps, sub: SubscriptionRow): Promise<'renewed' | 'ended'> {
  const now = deps.now();
  for (const purchaseId of [sub.pending_purchase_id, sub.latest_purchase_id]) {
    const claim = await claimFrom(deps.sql, purchaseId);
    const product = claim ? productFor(deps.config, claim.productId) : null;
    if (!claim || product?.kind !== 'plan') continue;
    const verified = await deps.services.purchases.verify(sub.uid, claim);
    if (verified.status === 'valid' && verified.expiresAt && verified.expiresAt.getTime() > now.getTime()) {
      await recordVerifiedPurchase(deps, sub.uid, claim, verified, product, 'renewal');
      return 'renewed';
    }
  }
  await deps.sql`
    update subscriptions set tier = 'free', product_id = null, status = 'expired', current_period_end = null,
      auto_renew = false, pending_tier = null, pending_product_id = null, pending_purchase_id = null, updated_at = ${now}
    where uid = ${sub.uid}`;
  return 'ended';
}

export async function renewSubscriptionsLogic(deps: Deps): Promise<{ renewed: number; ended: number; failed: number }> {
  const due = await deps.sql<SubscriptionRow[]>`
    select * from subscriptions where status = 'active' and current_period_end <= ${deps.now()}
    order by current_period_end limit ${RENEWAL_BATCH_SIZE}`;
  const counts = { renewed: 0, ended: 0, failed: 0 };
  for (const sub of due) {
    try {
      counts[await renewOne(deps, sub)] += 1;
    } catch (error) {
      counts.failed += 1;
      console.error('Subscription renewal failed', { uid: sub.uid, error: String(error) });
    }
  }
  return counts;
}

// ---------- storeNotification ----------

/** The notification could not be authenticated as coming from the store. */
export class NotificationRejected extends Error {}

/**
 * A store says it refunded a payment: take back what it granted, never
 * below 0 (owner decision, Phase 6). A refunded plan ends straight away.
 */
export async function handleStoreNotificationLogic(
  deps: Deps,
  platform: StorePlatform,
  body: unknown,
  headers: Record<string, string | undefined>,
): Promise<'refunded' | 'ignored'> {
  let notice;
  try {
    notice = await deps.services.purchases.parseNotification(platform, body, headers);
  } catch (error) {
    throw new NotificationRejected(String(error));
  }
  if (!notice) return 'ignored';

  const purchaseId = purchaseDocId(notice.platform, notice.storeTransactionId);
  const now = deps.now();
  return deps.sql.begin(async (tx) => {
    const [purchase] = await tx<{ uid: string; status: string; credits: number }[]>`
      select uid, status, credits from purchases where id = ${purchaseId} for update`;
    if (!purchase || purchase.status === 'refunded') return 'ignored';
    const uid = purchase.uid;
    const [account] = await tx<{ balance: number }[]>`select balance from credit_accounts where uid = ${uid} for update`;
    const [sub] = await tx<SubscriptionRow[]>`select * from subscriptions where uid = ${uid} for update`;

    const balance = account?.balance ?? 0;
    const granted = purchase.status === 'granted' ? purchase.credits : 0;
    const takeBack = refundTakeBack(granted, balance);
    if (takeBack > 0) {
      const after = balance - takeBack;
      const ledgerId = `refund_${purchaseId}`;
      await tx`update credit_accounts set balance = ${after}, updated_at = ${now} where uid = ${uid}`;
      await tx`
        insert into credit_ledger (id, uid, delta, balance_after, reason, ref_type, ref_id, idempotency_key, created_at)
        values (${ledgerId}, ${uid}, ${-takeBack}, ${after}, 'purchase_reversal', 'purchase', ${purchaseId}, ${ledgerId}, ${now})`;
    }
    await tx`
      update purchases set status = 'refunded', credits_taken_back = ${takeBack}, refunded_at = ${now} where id = ${purchaseId}`;

    if (sub?.latest_purchase_id === purchaseId) {
      await tx`
        update subscriptions set tier = 'free', product_id = null, status = 'refunded', current_period_end = null,
          auto_renew = false, updated_at = ${now}
        where uid = ${uid}`;
    } else if (sub?.pending_purchase_id === purchaseId) {
      await tx`
        update subscriptions set pending_tier = null, pending_product_id = null, pending_purchase_id = null, updated_at = ${now}
        where uid = ${uid}`;
    }
    return 'refunded';
  });
}
