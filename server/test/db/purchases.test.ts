import { defaultAppConfig } from '../../src/config/appConfig';
import {
  handleStoreNotificationLogic,
  NotificationRejected,
  purchaseDocId,
  renewSubscriptionsLogic,
  verifyPurchaseLogic,
} from '../../src/handlers/purchases';
import { FakePurchaseVerificationService } from '../../src/services/purchases/fakePurchaseVerificationService';
import { addPerson, connect, expectAppError, googleCaller, makeDeps, People, reset } from './helpers';

const DAY = 86_400_000;
const START = new Date('2026-11-12T10:00:00Z');
const sql = connect();
let people: People;
let now = START;

function deps() {
  const d = makeDeps(sql, {}, now);
  const config = defaultAppConfig;
  d.services.purchases = new FakePurchaseVerificationService({
    consumableProductIds: config.topUpPacks.map((p) => p.productId),
    subscriptionProductIds: config.plans.flatMap((p) => (p.productId ? [p.productId] : [])),
    subscriptionPeriodDays: config.subscriptionPeriodDays,
    now: () => now,
  });
  return d;
}

const uid = (name: string) => people.uid(name);
const token = (name: string, at: Date = now) => `fake-t${at.getTime()}-${name}`;
const buy = (name: string, productId: string, purchaseToken: string, platform: 'android' | 'ios' = 'android') =>
  verifyPurchaseLogic(deps(), googleCaller(uid(name)), { platform, productId, purchaseToken });
const balance = async (name: string) => (await sql<{ balance: number }[]>`select balance from credit_accounts where uid = ${uid(name)}`)[0].balance;
const subscription = async (name: string) => (await sql`select * from subscriptions where uid = ${uid(name)}`)[0];
const ledger = async (name: string) => sql`select * from credit_ledger where uid = ${uid(name)} order by created_at`;
const refund = (storeTransactionId: string) => handleStoreNotificationLogic(deps(), 'android', { fake: { type: 'refund', storeTransactionId } }, {});

beforeEach(async () => {
  await reset(sql);
  people = new People();
  now = START;
  for (const name of ['aarav', 'kiran']) await addPerson(sql, { uid: uid(name), name, gender: 'man' });
});

describe('top-up packs', () => {
  it('adds the pack credits once, with a ledger entry', async () => {
    const t = token('pack');
    await expect(buy('aarav', 'findx_credits_30', t)).resolves.toEqual({ status: 'granted', creditsAdded: 30, balance: 50, tier: 'free' });
    await expect(buy('aarav', 'findx_credits_30', t)).resolves.toMatchObject({ status: 'already_granted', creditsAdded: 0, balance: 50 });
    expect(await balance('aarav')).toBe(50);
    expect(await ledger('aarav')).toEqual([expect.objectContaining({ delta: 30, balance_after: 50, reason: 'purchase', ref_type: 'purchase' })]);
  });

  it('the same receipt sent twice at once is granted once', async () => {
    const t = token('pack');
    await Promise.all([buy('aarav', 'findx_credits_30', t), buy('aarav', 'findx_credits_30', t)]);
    expect(await balance('aarav')).toBe(50);
  });

  it('a receipt cannot be reused by another account', async () => {
    const t = token('shared');
    await buy('aarav', 'findx_credits_10', t);
    await expectAppError(buy('kiran', 'findx_credits_10', t), 'purchase_invalid');
    expect(await balance('kiran')).toBe(20);
  });

  it('forged receipts and unknown products are refused', async () => {
    await expectAppError(buy('aarav', 'findx_credits_10', 'real-looking-token'), 'purchase_invalid');
    await expectAppError(buy('aarav', 'findx_credits_999', token('x')), 'invalid_input');
    expect(await balance('aarav')).toBe(20);
  });

  it('a pending payment adds nothing yet', async () => {
    await expect(buy('aarav', 'findx_credits_10', `${token('slow')}-pending`)).resolves.toMatchObject({ status: 'pending', creditsAdded: 0, balance: 20 });
    expect(await ledger('aarav')).toEqual([]);
  });
});

describe('plans', () => {
  it('Plus adds 100 credits and becomes the active plan', async () => {
    await expect(buy('aarav', 'findx_plus_monthly', token('plus'))).resolves.toEqual({ status: 'granted', creditsAdded: 100, balance: 120, tier: 'plus' });
    const sub = await subscription('aarav');
    expect(sub).toMatchObject({ tier: 'plus', product_id: 'findx_plus_monthly', status: 'active', auto_renew: true });
    expect(sub.current_period_end).toEqual(new Date(START.getTime() + 30 * DAY));
  });

  it('upgrading to Premium mid-month adds 200 right away', async () => {
    await buy('aarav', 'findx_plus_monthly', token('plus'));
    now = new Date(START.getTime() + 10 * DAY);
    await expect(buy('aarav', 'findx_premium_monthly', token('premium'))).resolves.toMatchObject({
      status: 'granted',
      creditsAdded: 200,
      balance: 320,
      tier: 'premium',
    });
  });

  it('downgrading waits for the renewal, then grants the lower plan', async () => {
    await buy('aarav', 'findx_premium_monthly', token('premium'));
    now = new Date(START.getTime() + 10 * DAY);
    const plusToken = token('plus');
    await expect(buy('aarav', 'findx_plus_monthly', plusToken)).resolves.toMatchObject({ status: 'at_renewal', creditsAdded: 0, balance: 220, tier: 'premium' });
    await expect(buy('aarav', 'findx_plus_monthly', plusToken)).resolves.toMatchObject({ status: 'at_renewal', creditsAdded: 0 });
    expect(await subscription('aarav')).toMatchObject({ tier: 'premium', pending_tier: 'plus' });

    now = new Date(START.getTime() + 31 * DAY);
    await expect(renewSubscriptionsLogic(deps())).resolves.toEqual({ renewed: 1, ended: 0, failed: 0 });
    expect(await subscription('aarav')).toMatchObject({ tier: 'plus', pending_tier: null, status: 'active' });
    expect(await balance('aarav')).toBe(320);
  });

  it('each renewal grants the month once; unused credits are kept', async () => {
    await buy('aarav', 'findx_plus_monthly', token('plus'));
    now = new Date(START.getTime() + 31 * DAY);
    await renewSubscriptionsLogic(deps());
    await renewSubscriptionsLogic(deps());
    expect(await balance('aarav')).toBe(220);
    expect((await subscription('aarav')).current_period_end).toEqual(new Date(START.getTime() + 60 * DAY));
    expect((await ledger('aarav')).filter((e) => e.reason === 'subscription_grant')).toHaveLength(2);
  });

  it('a plan that was turned off goes back to Free and keeps the credits', async () => {
    await buy('aarav', 'findx_plus_monthly', `${token('plus')}-norenew`);
    now = new Date(START.getTime() + 31 * DAY);
    await expect(renewSubscriptionsLogic(deps())).resolves.toEqual({ renewed: 0, ended: 1, failed: 0 });
    expect(await subscription('aarav')).toMatchObject({ tier: 'free', status: 'expired', current_period_end: null });
    expect(await balance('aarav')).toBe(120);
  });

  it('plans not yet due are left alone', async () => {
    await buy('aarav', 'findx_plus_monthly', token('plus'));
    await expect(renewSubscriptionsLogic(deps())).resolves.toEqual({ renewed: 0, ended: 0, failed: 0 });
  });
});

describe('store refunds', () => {
  it('takes back a refunded pack, once', async () => {
    const t = token('pack');
    await buy('aarav', 'findx_credits_30', t);
    const txn = `fake-txn-${t}`;
    await expect(refund(txn)).resolves.toBe('refunded');
    await expect(refund(txn)).resolves.toBe('ignored');
    expect(await balance('aarav')).toBe(20);
    expect((await sql`select status from purchases where id = ${purchaseDocId('android', txn)}`)[0].status).toBe('refunded');
    expect((await ledger('aarav')).find((e) => e.reason === 'purchase_reversal')).toMatchObject({ delta: -30, balance_after: 20 });
  });

  it('never takes the balance below 0', async () => {
    const t = token('pack');
    await buy('aarav', 'findx_credits_30', t);
    await sql`update credit_accounts set balance = 7 where uid = ${uid('aarav')}`;
    await refund(`fake-txn-${t}`);
    expect(await balance('aarav')).toBe(0);
  });

  it('a refunded plan ends straight away', async () => {
    const t = token('plus');
    await buy('aarav', 'findx_plus_monthly', t);
    await refund(`fake-txn-${t}-p0`);
    expect(await subscription('aarav')).toMatchObject({ tier: 'free', status: 'refunded' });
    expect(await balance('aarav')).toBe(20);
  });

  it('unknown purchases are ignored and forged notifications rejected', async () => {
    await expect(refund('fake-txn-unknown')).resolves.toBe('ignored');
    await expect(handleStoreNotificationLogic(deps(), 'android', { forged: true }, {})).rejects.toBeInstanceOf(NotificationRejected);
  });
});
