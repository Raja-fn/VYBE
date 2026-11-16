import type { AppConfig, PlanTier } from '../config/appConfig';

export type StoreProduct =
  | { kind: 'pack'; productId: string; credits: number }
  | { kind: 'plan'; productId: string; tier: PlanTier; monthlyCredits: number };

/** The configured top-up pack or plan for a store product id, or null. */
export function productFor(config: AppConfig, productId: string): StoreProduct | null {
  const pack = config.topUpPacks.find((p) => p.productId === productId);
  if (pack) return { kind: 'pack', productId, credits: pack.credits };
  const plan = config.plans.find((p) => p.productId === productId);
  if (plan) return { kind: 'plan', productId, tier: plan.tier, monthlyCredits: plan.monthlyCredits };
  return null;
}

/** Plans are listed from lowest to highest in AppConfig. */
export const tierRank = (config: AppConfig, tier: PlanTier): number => config.plans.findIndex((p) => p.tier === tier);

export interface CurrentSubscription {
  tier: PlanTier;
  status: string;
  currentPeriodEnd: Date | null;
}

/** A paid plan that is still running at [now]. */
export const isActivePaidPlan = (sub: CurrentSubscription | null, now: Date): sub is CurrentSubscription & { currentPeriodEnd: Date } =>
  sub !== null &&
  sub.tier !== 'free' &&
  sub.status === 'active' &&
  sub.currentPeriodEnd !== null &&
  sub.currentPeriodEnd.getTime() > now.getTime();

/**
 * What a newly verified plan purchase does (owner decisions, Phase 6):
 * - no running paid plan, the same plan, or a higher plan: credits now;
 * - a lower plan while a higher one runs: starts at the next renewal.
 */
export function planChange(
  config: AppConfig,
  current: CurrentSubscription | null,
  incoming: PlanTier,
  now: Date,
): 'grant_now' | 'at_renewal' {
  if (!isActivePaidPlan(current, now)) return 'grant_now';
  return tierRank(config, incoming) < tierRank(config, current.tier) ? 'at_renewal' : 'grant_now';
}

/**
 * Credits taken back when the store refunds a purchase: what it gave, but
 * never more than the balance (owner decision: never below 0).
 */
export const refundTakeBack = (granted: number, balance: number): number => Math.max(0, Math.min(granted, balance));
