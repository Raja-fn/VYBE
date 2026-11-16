
import { defaultAppConfig } from '../src/config/appConfig';
import { AppError, appError, ErrorCodes } from '../src/shared/errorCodes';
import { createServices, ProviderNotConfiguredError } from '../src/services/factory';
import { FAKE_DEFAULT_DATE_OF_BIRTH, FAKE_MODERATION_TERMS } from '../src/services/fakeFixtures';
import { seedUid } from '../src/services/seedIds';
import { FakeIdentityVerificationService } from '../src/services/identity/fakeIdentityVerificationService';
import { popularityLabel } from '../src/services/places/placesPopularityService';
import { FAKE_PURCHASE_TOKEN_PREFIX } from '../src/services/purchases/fakePurchaseVerificationService';

const services = createServices(defaultAppConfig, true);

describe('service factory', () => {
  it('refuses to hand out fakes unless they are allowed', () => {
    expect(() => createServices(defaultAppConfig, false)).toThrow(ProviderNotConfiguredError);
  });
});

describe('fake identity verification', () => {
  it('approves and reads a date of birth from the ID', async () => {
    const session = await services.identity.createSession('s_new', 'government_id');
    const result = await services.identity.getResult(session.providerRef);
    expect(result).toMatchObject({ decision: 'approved', dateOfBirth: FAKE_DEFAULT_DATE_OF_BIRTH });
  });

  it('does not return a date of birth for a selfie', async () => {
    const session = await services.identity.createSession('s_new', 'selfie');
    expect((await services.identity.getResult(session.providerRef)).dateOfBirth).toBeUndefined();
  });

  it('rejects the designated test account', async () => {
    const session = await services.identity.createSession(seedUid('u_rejected'), 'selfie');
    expect((await services.identity.getResult(session.providerRef)).decision).toBe('rejected');
  });

  it('is stateless: a fresh instance can decide a session another instance created', async () => {
    const options = { sessionMinutes: 15, dateOfBirthFor: () => '2000-01-01' };
    const session = await new FakeIdentityVerificationService(options).createSession('abc', 'selfie');
    expect((await new FakeIdentityVerificationService(options).getResult(session.providerRef)).decision).toBe('approved');
  });

  it('sets the session expiry from AppConfig', async () => {
    const now = new Date('2026-11-10T10:00:00Z');
    const fake = new FakeIdentityVerificationService({ sessionMinutes: 15, now: () => now, dateOfBirthFor: () => '2000-01-01' });
    const session = await fake.createSession('x', 'selfie');
    expect(session.expiresAt.toISOString()).toBe('2026-11-10T10:15:00.000Z');
  });

  it('fails on an unknown session', async () => {
    await expect(services.identity.getResult('nope')).rejects.toThrow();
  });
});

describe('fake payout', () => {
  it('quotes zero because no rate has been decided', async () => {
    const quote = await services.payout.quoteEarning({ bookingId: 'b1', companionUid: 'c', planType: 'coffee', creditCost: 5 });
    expect(quote.amountMinor).toBe(0);
  });

  it('is idempotent per key', async () => {
    const a = await services.payout.payout({ uid: 'c', amountMinor: 100, currency: 'INR', idempotencyKey: 'k1' });
    const b = await services.payout.payout({ uid: 'c', amountMinor: 100, currency: 'INR', idempotencyKey: 'k1' });
    expect(a).toEqual(b);
  });
});

describe('fake moderation', () => {
  it('flags the test term and allows ordinary text', async () => {
    expect(await services.moderation.checkText(`hello ${FAKE_MODERATION_TERMS[0].toUpperCase()}`)).toEqual({
      allowed: false,
      reason: 'explicit',
    });
    expect(await services.moderation.checkText('Coffee at 5?')).toEqual({ allowed: true });
  });
});

describe('fake places popularity', () => {
  it('is stable for the same venue and hour and stays in range', async () => {
    const at = new Date('2026-11-10T12:00:00Z');
    const input = [{ venueId: 'v1', lat: 0, lng: 0 }, { venueId: 'v2', lat: 0, lng: 0 }];
    const a = await services.places.getPopularity(input, at);
    const b = await services.places.getPopularity(input, at);
    expect(a).toEqual(b);
    expect(a.every((s) => s.score >= 0 && s.score < 1)).toBe(true);
  });

  it('labels scores with the AppConfig thresholds', () => {
    const t = { hot: defaultAppConfig.popularityHotThreshold, busy: defaultAppConfig.popularityBusyThreshold };
    expect(popularityLabel(0.9, t)).toBe('hot');
    expect(popularityLabel(0.5, t)).toBe('busy');
    expect(popularityLabel(0.1, t)).toBe('quiet');
  });
});

describe('fake purchase verification', () => {
  const token = `${FAKE_PURCHASE_TOKEN_PREFIX}abc`;

  it('accepts a known top-up pack', async () => {
    const result = await services.purchases.verify('u', { platform: 'android', productId: 'findx_credits_10', purchaseToken: token });
    expect(result).toMatchObject({ status: 'valid', kind: 'consumable' });
  });

  it('accepts a subscription and sets its expiry', async () => {
    const result = await services.purchases.verify('u', { platform: 'ios', productId: 'findx_plus_monthly', purchaseToken: token });
    expect(result.kind).toBe('subscription');
    expect(result.expiresAt).toBeInstanceOf(Date);
  });

  it('rejects unknown products and forged tokens', async () => {
    expect((await services.purchases.verify('u', { platform: 'android', productId: 'other', purchaseToken: token })).status).toBe('invalid');
    expect((await services.purchases.verify('u', { platform: 'android', productId: 'findx_credits_10', purchaseToken: 'real' })).status).toBe('invalid');
  });
});

describe('appError', () => {
  it('carries the code the app maps to a typed failure', () => {
    const error = appError(ErrorCodes.insufficientCredits, 'Not enough credits');
    expect(error).toBeInstanceOf(AppError);
    expect(error.status).toBe('failed-precondition');
    expect(error.code).toBe('insufficient_credits');
  });
});
