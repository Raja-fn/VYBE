import type { AppConfig } from '../config/appConfig';
import { env, fakeServicesAllowed } from '../config/env';
import { FakeIdentityVerificationService } from './identity/fakeIdentityVerificationService';
import type { IdentityVerificationService } from './identity/identityVerificationService';
import { FakeModerationService } from './moderation/fakeModerationService';
import type { ModerationService } from './moderation/moderationService';
import { FakePaymentPayoutService } from './payout/fakePaymentPayoutService';
import type { PaymentPayoutService } from './payout/paymentPayoutService';
import { FakePlacesPopularityService } from './places/fakePlacesPopularityService';
import type { PlacesPopularityService, PopularityInput, PopularityScore } from './places/placesPopularityService';
import { FakePurchaseVerificationService } from './purchases/fakePurchaseVerificationService';
import { GooglePlayPurchaseVerificationService, type ServiceAccountKey } from './purchases/googlePlayPurchaseVerificationService';
import type { PurchaseVerificationService } from './purchases/purchaseVerificationService';
import { NoPublicPlaces, type PublicPlacesSource } from './places/publicPlacesSource';
import { fakeDateOfBirthFor, FAKE_MODERATION_TERMS, FAKE_REJECTED_UIDS } from './fakeFixtures';

export interface Services {
  identity: IdentityVerificationService;
  payout: PaymentPayoutService;
  moderation: ModerationService;
  places: PlacesPopularityService;
  purchases: PurchaseVerificationService;
  /** Public places (cafes, parks, cinemas…) that become meeting spots. */
  publicPlaces: PublicPlacesSource;
}

export class ProviderNotConfiguredError extends Error {
  constructor(service: string) {
    super(`No production ${service} provider is configured yet.`);
  }
}

/** Production settings, from Edge Function secrets. */
export interface ProductionSettings {
  /** Owner decision (launch): approve selfie and ID checks automatically until a provider is chosen. */
  identityAutoApprove: boolean;
  /** Google Play: package name and service-account key (JSON). */
  playPackageName?: string;
  playServiceAccountJson?: string;
  /** Secret in the Play notification push URL. */
  playNotificationSecret?: string;
}

export function productionSettingsFromEnv(): ProductionSettings {
  return {
    identityAutoApprove: env('FINDX_IDENTITY_AUTO_APPROVE') === 'true',
    playPackageName: env('GOOGLE_PLAY_PACKAGE'),
    playServiceAccountJson: env('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON'),
    playNotificationSecret: env('FINDX_PLAY_NOTIFICATION_SECRET'),
  };
}

/** Venue popularity has no data source yet: every venue reads as quiet, so nothing is made up. */
class NoPopularityData implements PlacesPopularityService {
  async getPopularity(venues: PopularityInput[]): Promise<PopularityScore[]> {
    return venues.map((venue) => ({ venueId: venue.venueId, score: 0 }));
  }
}

/** Companion payouts are not part of the launch; any call fails loudly. */
class PayoutsNotAvailable implements PaymentPayoutService {
  quoteEarning(): Promise<never> {
    return Promise.reject(new ProviderNotConfiguredError('payout'));
  }

  payout(): Promise<never> {
    return Promise.reject(new ProviderNotConfiguredError('payout'));
  }
}

function productIds(config: AppConfig) {
  return {
    consumableProductIds: config.topUpPacks.map((p) => p.productId),
    subscriptionProductIds: config.plans.flatMap((p) => (p.productId ? [p.productId] : [])),
  };
}

/**
 * Fakes on the test project that allows them (and in tests).
 *
 * Production uses real providers, and a call fails loudly when one is not
 * configured instead of silently approving users, granting credits or paying out:
 * - purchases: Google Play (needs GOOGLE_PLAY_PACKAGE and GOOGLE_PLAY_SERVICE_ACCOUNT_JSON);
 * - identity: automatic approval only with FINDX_IDENTITY_AUTO_APPROVE=true (owner decision);
 * - moderation: VYBE's own rules (contact details are blocked in chat itself);
 * - places: no popularity data yet (all quiet); payouts: not offered.
 */
export function createServices(
  config: AppConfig,
  useFakes: boolean = fakeServicesAllowed(),
  production: ProductionSettings = productionSettingsFromEnv(),
): Services {
  if (useFakes) return fakeServices(config);

  if (!production.identityAutoApprove) throw new ProviderNotConfiguredError('identity');
  return {
    identity: new FakeIdentityVerificationService({
      sessionMinutes: config.verificationSessionMinutes,
      dateOfBirthFor: fakeDateOfBirthFor,
    }),
    payout: new PayoutsNotAvailable(),
    moderation: new FakeModerationService([]),
    places: new NoPopularityData(),
    purchases: googlePlay(config, production),
    // Public places are imported in bulk from the OpenStreetMap India file (server/scripts/import-places.ts):
    // the free public Overpass servers do not allow app traffic. A self-hosted Overpass can be
    // plugged in here later with new OpenStreetMapPlaces({ endpoints: [...] }).
    publicPlaces: new NoPublicPlaces(),
  };
}

/**
 * Google Play receipt checks. Until the Play keys are set, every purchase and
 * store notification is refused (nothing is granted), while the rest of the
 * app keeps working.
 */
function googlePlay(config: AppConfig, production: ProductionSettings): PurchaseVerificationService {
  let reason = '';
  let serviceAccount: ServiceAccountKey | undefined;
  if (!production.playPackageName || !production.playServiceAccountJson) {
    reason = 'purchases (Google Play keys are not set)';
  } else {
    try {
      serviceAccount = JSON.parse(production.playServiceAccountJson) as ServiceAccountKey;
    } catch {
      reason = 'purchases (GOOGLE_PLAY_SERVICE_ACCOUNT_JSON is not valid JSON)';
    }
  }
  if (!serviceAccount || !production.playPackageName) {
    return {
      verify: () => Promise.reject(new ProviderNotConfiguredError(reason)),
      parseNotification: () => Promise.reject(new ProviderNotConfiguredError(reason)),
    };
  }
  return new GooglePlayPurchaseVerificationService({
    packageName: production.playPackageName,
    serviceAccount,
    notificationSecret: production.playNotificationSecret ?? '',
    ...productIds(config),
  });
}

function fakeServices(config: AppConfig): Services {
  return {
    identity: new FakeIdentityVerificationService({
      sessionMinutes: config.verificationSessionMinutes,
      rejectUids: FAKE_REJECTED_UIDS,
      dateOfBirthFor: fakeDateOfBirthFor,
    }),
    payout: new FakePaymentPayoutService(),
    moderation: new FakeModerationService(FAKE_MODERATION_TERMS),
    places: new FakePlacesPopularityService(),
    purchases: new FakePurchaseVerificationService({
      ...productIds(config),
      subscriptionPeriodDays: config.subscriptionPeriodDays,
    }),
    publicPlaces: new NoPublicPlaces(),
  };
}
