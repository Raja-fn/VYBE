import { defaultAppConfig } from '../src/config/appConfig';
import { isActivePaidPlan, planChange, productFor, refundTakeBack, tierRank } from '../src/domain/credits';
import {
  FAKE_NO_RENEW_MARKER,
  FAKE_PENDING_MARKER,
  FakePurchaseVerificationService,
} from '../src/services/purchases/fakePurchaseVerificationService';

const config = defaultAppConfig;
const NOW = new Date('2026-11-12T10:00:00Z');
const DAY = 86_400_000;
const later = new Date(NOW.getTime() + 10 * DAY);
const earlier = new Date(NOW.getTime() - DAY);

describe('productFor', () => {
  it('finds top-up packs and plans from AppConfig', () => {
    expect(productFor(config, 'findx_credits_30')).toEqual({ kind: 'pack', productId: 'findx_credits_30', credits: 30 });
    expect(productFor(config, 'findx_premium_monthly')).toEqual({
      kind: 'plan',
      productId: 'findx_premium_monthly',
      tier: 'premium',
      monthlyCredits: 200,
    });
    expect(productFor(config, 'findx_plus_monthly')).toMatchObject({ monthlyCredits: 100 });
  });

  it('knows nothing else', () => {
    expect(productFor(config, 'findx_credits_999')).toBeNull();
  });
});

describe('plan changes (owner decisions)', () => {
  const plus = { tier: 'plus' as const, status: 'active', currentPeriodEnd: later };
  const premium = { tier: 'premium' as const, status: 'active', currentPeriodEnd: later };

  it('ranks free < plus < premium', () => {
    expect(tierRank(config, 'free')).toBeLessThan(tierRank(config, 'plus'));
    expect(tierRank(config, 'plus')).toBeLessThan(tierRank(config, 'premium'));
  });

  it('a first plan or an upgrade grants credits now', () => {
    expect(planChange(config, null, 'plus', NOW)).toBe('grant_now');
    expect(planChange(config, { tier: 'free', status: 'active', currentPeriodEnd: null }, 'plus', NOW)).toBe('grant_now');
    expect(planChange(config, plus, 'premium', NOW)).toBe('grant_now');
  });

  it('a downgrade waits for the renewal', () => {
    expect(planChange(config, premium, 'plus', NOW)).toBe('at_renewal');
  });

  it('a plan that has ended does not hold anything back', () => {
    expect(planChange(config, { ...premium, currentPeriodEnd: earlier }, 'plus', NOW)).toBe('grant_now');
    expect(planChange(config, { ...premium, status: 'expired' }, 'plus', NOW)).toBe('grant_now');
    expect(isActivePaidPlan({ ...premium, currentPeriodEnd: earlier }, NOW)).toBe(false);
  });
});

describe('refund take-back', () => {
  it('takes back what was granted, never below 0', () => {
    expect(refundTakeBack(30, 50)).toBe(30);
    expect(refundTakeBack(30, 12)).toBe(12);
    expect(refundTakeBack(30, 0)).toBe(0);
    expect(refundTakeBack(0, 10)).toBe(0);
  });
});

describe('fake store periods', () => {
  const fake = (now: Date) =>
    new FakePurchaseVerificationService({
      consumableProductIds: ['findx_credits_10'],
      subscriptionProductIds: ['findx_plus_monthly'],
      subscriptionPeriodDays: 30,
      now: () => now,
    });
  const bought = NOW.getTime();
  const claim = (purchaseToken: string) => ({ platform: 'android' as const, productId: 'findx_plus_monthly', purchaseToken });

  it('each paid period has its own transaction id', async () => {
    const first = await fake(NOW).verify('u', claim(`fake-t${bought}-a`));
    const second = await fake(new Date(bought + 31 * DAY)).verify('u', claim(`fake-t${bought}-a`));
    expect(first).toMatchObject({ status: 'valid', storeTransactionId: `fake-txn-fake-t${bought}-a-p0`, autoRenew: true });
    expect(second.storeTransactionId).toBe(`fake-txn-fake-t${bought}-a-p1`);
    expect(second.expiresAt).toEqual(new Date(bought + 60 * DAY));
  });

  it('a plan that was turned off expires after its period', async () => {
    const result = await fake(new Date(bought + 31 * DAY)).verify('u', claim(`fake-t${bought}${FAKE_NO_RENEW_MARKER}`));
    expect(result).toMatchObject({ status: 'expired', autoRenew: false });
  });

  it('pending payments are reported as pending', async () => {
    const result = await fake(NOW).verify('u', { ...claim(`fake-t${bought}${FAKE_PENDING_MARKER}`), productId: 'findx_credits_10' });
    expect(result.status).toBe('pending');
  });

  it('reads refund notifications and rejects anything else', async () => {
    await expect(fake(NOW).parseNotification('ios', { fake: { type: 'refund', storeTransactionId: 'x' } })).resolves.toEqual({
      kind: 'refund',
      platform: 'ios',
      storeTransactionId: 'x',
    });
    await expect(fake(NOW).parseNotification('ios', { fake: { type: 'renewal', storeTransactionId: 'x' } })).resolves.toBeNull();
    await expect(fake(NOW).parseNotification('ios', { forged: true })).rejects.toThrow();
  });
});
