import { generateKeyPairSync } from 'node:crypto';

import { defaultAppConfig } from '../src/config/appConfig';
import { createServices, ProviderNotConfiguredError } from '../src/services/factory';
import { GooglePlayPurchaseVerificationService } from '../src/services/purchases/googlePlayPurchaseVerificationService';

const NOW = new Date('2026-11-14T10:00:00Z');
const { privateKey } = generateKeyPairSync('rsa', { modulusLength: 2048 });
const serviceAccount = {
  client_email: 'play-checks@findx-prod.iam.gserviceaccount.com',
  private_key: privateKey.export({ type: 'pkcs8', format: 'pem' }).toString(),
};

type Reply = { status: number; body: unknown };

/** A stand-in for Google's token endpoint and the Play Developer API. */
function fakeGoogle(replies: Record<string, Reply>) {
  const calls: string[] = [];
  const fetchFn = (async (input: string | URL | Request, init?: RequestInit) => {
    const url = String(input);
    calls.push(url);
    if (url === 'https://oauth2.googleapis.com/token') {
      const assertion = new URLSearchParams(String(init?.body)).get('assertion') ?? '';
      const claims = JSON.parse(Buffer.from(assertion.split('.')[1], 'base64url').toString());
      expect(claims).toMatchObject({ iss: serviceAccount.client_email, scope: 'https://www.googleapis.com/auth/androidpublisher' });
      return new Response(JSON.stringify({ access_token: 'access-1', expires_in: 3600 }));
    }
    expect((init?.headers as Record<string, string>).Authorization).toBe('Bearer access-1');
    const key = Object.keys(replies).find((k) => url.includes(k));
    const reply = key ? replies[key] : { status: 404, body: { error: { code: 404 } } };
    return new Response(JSON.stringify(reply.body), { status: reply.status });
  }) as typeof fetch;
  return { fetchFn, calls };
}

function play(replies: Record<string, Reply>) {
  const google = fakeGoogle(replies);
  const service = new GooglePlayPurchaseVerificationService({
    packageName: 'com.findx.app',
    serviceAccount,
    consumableProductIds: ['findx_credits_10'],
    subscriptionProductIds: ['findx_plus_monthly'],
    notificationSecret: 'push-secret',
    fetchFn: google.fetchFn,
    now: () => NOW,
  });
  return { service, calls: google.calls };
}

const pack = (token = 'tok1') => ({ platform: 'android' as const, productId: 'findx_credits_10', purchaseToken: token });
const plan = (token = 'sub1') => ({ platform: 'android' as const, productId: 'findx_plus_monthly', purchaseToken: token });
const subscription = (state: string, expiry: string, autoRenew = true) => ({
  status: 200,
  body: {
    subscriptionState: state,
    latestOrderId: 'GPA.3333-4444-5555-66666..1',
    startTime: '2026-10-14T10:00:00Z',
    lineItems: [{ productId: 'findx_plus_monthly', expiryTime: expiry, autoRenewingPlan: { autoRenewEnabled: autoRenew } }],
  },
});

describe('Google Play receipts', () => {
  it('signs in once with the service account and accepts a paid credit pack', async () => {
    const { service, calls } = play({ 'products/findx_credits_10/tokens/tok1': { status: 200, body: { purchaseState: 0, orderId: 'GPA.1111' } } });
    await expect(service.verify('u1', pack())).resolves.toMatchObject({ status: 'valid', storeTransactionId: 'GPA.1111', kind: 'consumable' });
    await service.verify('u1', pack());
    expect(calls.filter((c) => c.includes('oauth2')).length).toBe(1);
    expect(calls[1]).toContain('/applications/com.findx.app/purchases/products/findx_credits_10/tokens/tok1');
  });

  it('a slow payment is pending, a cancelled or unknown token is refused', async () => {
    const { service } = play({
      'tokens/slow': { status: 200, body: { purchaseState: 2, orderId: 'GPA.2' } },
      'tokens/cancelled': { status: 200, body: { purchaseState: 1, orderId: 'GPA.3' } },
    });
    await expect(service.verify('u1', pack('slow'))).resolves.toMatchObject({ status: 'pending' });
    await expect(service.verify('u1', pack('cancelled'))).resolves.toMatchObject({ status: 'invalid' });
    await expect(service.verify('u1', pack('forged'))).resolves.toMatchObject({ status: 'invalid' });
  });

  it('refuses other stores and products FindX does not sell, without asking Google', async () => {
    const { service, calls } = play({});
    await expect(service.verify('u1', { ...pack(), platform: 'ios' })).resolves.toMatchObject({ status: 'invalid' });
    await expect(service.verify('u1', { ...pack(), productId: 'something_else' })).resolves.toMatchObject({ status: 'invalid' });
    expect(calls).toEqual([]);
  });

  it('a paid plan is valid with its period; a turned-off plan stays valid until it ends', async () => {
    const active = play({ 'subscriptionsv2/tokens/sub1': subscription('SUBSCRIPTION_STATE_ACTIVE', '2026-12-14T10:00:00Z') });
    await expect(active.service.verify('u1', plan())).resolves.toMatchObject({
      status: 'valid',
      kind: 'subscription',
      storeTransactionId: 'GPA.3333-4444-5555-66666..1',
      expiresAt: new Date('2026-12-14T10:00:00Z'),
      autoRenew: true,
    });
    const cancelled = play({ 'subscriptionsv2/tokens/sub1': subscription('SUBSCRIPTION_STATE_CANCELED', '2026-11-20T10:00:00Z', false) });
    await expect(cancelled.service.verify('u1', plan())).resolves.toMatchObject({ status: 'valid', autoRenew: false });
  });

  it('an ended or on-hold plan is expired; a plan awaiting payment is pending', async () => {
    const ended = play({ 'subscriptionsv2/tokens/sub1': subscription('SUBSCRIPTION_STATE_EXPIRED', '2026-11-01T10:00:00Z') });
    await expect(ended.service.verify('u1', plan())).resolves.toMatchObject({ status: 'expired' });
    const hold = play({ 'subscriptionsv2/tokens/sub1': subscription('SUBSCRIPTION_STATE_ON_HOLD', '2026-12-01T10:00:00Z') });
    await expect(hold.service.verify('u1', plan())).resolves.toMatchObject({ status: 'expired' });
    const pending = play({ 'subscriptionsv2/tokens/sub1': subscription('SUBSCRIPTION_STATE_PENDING', '2026-12-01T10:00:00Z') });
    await expect(pending.service.verify('u1', plan())).resolves.toMatchObject({ status: 'pending' });
  });

  it('a Google outage is an error (retry later), not a refusal', async () => {
    const { service } = play({ 'tokens/tok1': { status: 503, body: {} } });
    await expect(service.verify('u1', pack())).rejects.toThrow('HTTP 503');
  });
});

describe('Google Play refund notices', () => {
  const push = (payload: unknown) => ({ message: { data: Buffer.from(JSON.stringify(payload)).toString('base64') } });
  const voided = { packageName: 'com.findx.app', voidedPurchaseNotification: { purchaseToken: 't', orderId: 'GPA.1111' } };

  it('a refund with the right push token takes the credits back', async () => {
    const { service } = play({});
    await expect(service.parseNotification('android', push(voided), { 'x-findx-query-token': 'push-secret' })).resolves.toEqual({
      kind: 'refund',
      platform: 'android',
      storeTransactionId: 'GPA.1111',
    });
  });

  it('other notices need no action; forged, foreign and malformed ones are rejected', async () => {
    const { service } = play({});
    const ok = { 'x-findx-query-token': 'push-secret' };
    await expect(service.parseNotification('android', push({ packageName: 'com.findx.app', testNotification: {} }), ok)).resolves.toBeNull();
    await expect(service.parseNotification('android', push(voided), { 'x-findx-query-token': 'wrong' })).rejects.toThrow();
    await expect(service.parseNotification('android', push(voided), {})).rejects.toThrow();
    await expect(service.parseNotification('android', push({ ...voided, packageName: 'other.app' }), ok)).rejects.toThrow();
    await expect(service.parseNotification('android', { hello: 1 }, ok)).rejects.toThrow();
  });
});

describe('production services', () => {
  const settings = {
    identityAutoApprove: true,
    playPackageName: 'com.findx.app',
    playServiceAccountJson: JSON.stringify(serviceAccount),
    playNotificationSecret: 'push-secret',
  };

  it('use Google Play and never the test store or the made-up popularity', async () => {
    const services = createServices(defaultAppConfig, false, settings);
    expect(services.purchases).toBeInstanceOf(GooglePlayPurchaseVerificationService);
    expect(await services.places.getPopularity([{ venueId: 'v', lat: 0, lng: 0 }], NOW)).toEqual([{ venueId: 'v', score: 0 }]);
    await expect(services.payout.payout({ uid: 'u', amountMinor: 1, currency: 'INR', idempotencyKey: 'k' })).rejects.toThrow(
      ProviderNotConfiguredError,
    );
  });

  it('refuse to start without the owner switch for ID checks', () => {
    expect(() => createServices(defaultAppConfig, false, { ...settings, identityAutoApprove: false })).toThrow(ProviderNotConfiguredError);
  });

  it('without Google Play keys, refuse every purchase but keep the rest working', async () => {
    for (const playServiceAccountJson of [undefined, 'not json']) {
      const services = createServices(defaultAppConfig, false, { ...settings, playServiceAccountJson });
      await expect(services.purchases.verify('u', { platform: 'android', productId: 'findx_credits_10', purchaseToken: 't' })).rejects.toThrow(
        ProviderNotConfiguredError,
      );
      await expect(services.purchases.parseNotification('android', {}, {})).rejects.toThrow(ProviderNotConfiguredError);
      expect(await services.places.getPopularity([], NOW)).toEqual([]);
    }
  });
});
