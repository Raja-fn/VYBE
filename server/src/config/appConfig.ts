import { z } from 'zod';

import defaultsJson from './app_config_defaults.json';
import type { Sql } from '../shared/db';

/**
 * Server view of AppConfig. Mirrors lib/core/config/app_config.dart.
 * Defaults come from config/app_config_defaults.json (copied in by
 * `npm run sync-config`); overrides come from the `app_config` table, which
 * the app reads too.
 */
const planSchema = z.object({
  tier: z.enum(['free', 'plus', 'premium']),
  productId: z.string().nullable(),
  monthlyCredits: z.number().int().nonnegative(),
});

const topUpSchema = z.object({
  productId: z.string(),
  credits: z.number().int().positive(),
});

export const appConfigSchema = z.object({
  discoveryRadiusKm: z.number().int().positive(),
  companionLocationSnapMeters: z.number().int().positive(),
  distanceLabelStepKm: z.number().int().positive(),
  discoverCallsPerMinute: z.number().int().positive(),
  discoverPageSize: z.number().int().positive(),
  /** Adds the made-up sample profiles to Discover. Turn off before the public launch. */
  showSampleProfiles: z.boolean(),
  samplePhotoBaseUrl: z.string().url(),
  maxPlausibleSpeedKmh: z.number().positive(),
  launchCity: z.object({
    name: z.string(),
    lat: z.number(),
    lng: z.number(),
    timezone: z.string(),
  }),
  phoneCountryCode: z.string().regex(/^\+[1-9][0-9]{0,3}$/),
  phoneNationalNumberLength: z.number().int().positive(),
  otpResendSeconds: z.number().int().positive(),
  /** Phone OTP login (Renflair). Off for now: Google login only (owner decision). */
  phoneLoginEnabled: z.boolean(),
  otpLength: z.number().int().min(4).max(8),
  otpValiditySeconds: z.number().int().positive(),
  otpMaxAttempts: z.number().int().positive(),
  otpRequestsPerPhonePerDay: z.number().int().positive(),
  otpRequestsPerIpPerHour: z.number().int().positive(),
  rulesVersion: z.number().int().positive(),
  signupBonusCredits: z.number().int().nonnegative(),
  creditCostStartChat: z.number().int().nonnegative(),
  creditCostBookSpot: z.number().int().nonnegative(),
  creditCostInstantRequest: z.number().int().nonnegative(),
  plans: z.array(planSchema),
  topUpPacks: z.array(topUpSchema),
  subscriptionPeriodDays: z.number().int().positive(),
  bookingDaysAhead: z.number().int().positive(),
  slotMinutesDefault: z.number().int().positive(),
  /** OpenStreetMap places: area grid size (degrees), refresh age and request timeout. */
  placesCellDegrees: z.number().positive(),
  placesRefreshDays: z.number().int().positive(),
  placesImportTimeoutSeconds: z.number().positive(),
  /** Default slots for places without a venue partner (local hours, people per slot). */
  defaultSlotOpenHour: z.number().int().min(0).max(23),
  defaultSlotCloseHour: z.number().int().min(1).max(24),
  defaultSlotCapacity: z.number().int().positive(),
  /** At most this many spots in "Best spots to meet" and on the map. */
  venuesListLimit: z.number().int().positive(),
  freeNowMaxHours: z.number().int().positive(),
  tonightStartHour: z.number().int().min(0).max(23),
  checkInWindowMinutesBefore: z.number().int().nonnegative(),
  checkInWindowMinutesAfter: z.number().int().nonnegative(),
  safetyCheckIntervalMinutes: z.number().int().positive(),
  safetyMissedCheckInsToEscalate: z.number().int().positive(),
  sosHoldSeconds: z.number().int().positive(),
  /** Dialled by the SOS button (112 works in India, the EU and many other countries). */
  emergencyNumber: z.string().regex(/^[0-9]{2,6}$/),
  autoCompleteGraceMinutes: z.number().int().nonnegative(),
  moderationStrikesForReport: z.number().int().positive(),
  moderationStrikeWindowHours: z.number().int().positive(),
  chatMessageMaxLength: z.number().int().positive(),
  chatMessagesPageSize: z.number().int().positive(),
  reportsPerDay: z.number().int().positive(),
  reportDetailsMaxLength: z.number().int().positive(),
  verificationSessionMinutes: z.number().int().positive(),
  captureMaxDimension: z.number().int().positive(),
  captureJpegQuality: z.number().int().min(1).max(100),
  voiceIntroMaxSec: z.number().int().positive(),
  maxProfilePhotos: z.number().int().positive(),
  displayNameMaxLength: z.number().int().positive(),
  ageMinimum: z.number().int().positive(),
  ageMaximum: z.number().int().positive(),
  defaultAgeRangeMin: z.number().int().positive(),
  defaultAgeRangeMax: z.number().int().positive(),
  popularityHotThreshold: z.number().min(0).max(1),
  popularityBusyThreshold: z.number().min(0).max(1),
  maxTextScale: z.number().positive(),
  remoteConfigFetchTimeoutSeconds: z.number().int().positive(),
  remoteConfigMinimumFetchIntervalMinutes: z.number().int().positive(),
});

export type AppConfig = z.infer<typeof appConfigSchema>;
export type PlanTier = AppConfig['plans'][number]['tier'];

/** The bundled defaults, validated once at load. */
export const defaultAppConfig: AppConfig = appConfigSchema.parse(defaultsJson);

/** Merges overrides into the defaults; any invalid result keeps the defaults. */
export function mergeOverrides(overrides: Record<string, unknown>): AppConfig {
  const parsed = appConfigSchema.safeParse({ ...defaultAppConfig, ...overrides });
  return parsed.success ? parsed.data : defaultAppConfig;
}

const CACHE_MS = 60_000;
let cached: { config: AppConfig; at: number } | undefined;

/** Current AppConfig: defaults plus `app_config.overrides`, cached for a minute. */
export async function loadAppConfig(sql: Sql, now: number = Date.now()): Promise<AppConfig> {
  if (cached && now - cached.at < CACHE_MS) return cached.config;
  try {
    const [row] = await sql<{ overrides: Record<string, unknown> }[]>`select overrides from app_config where id = 1`;
    cached = { config: mergeOverrides(row?.overrides ?? {}), at: now };
  } catch {
    cached = { config: defaultAppConfig, at: now };
  }
  return cached.config;
}

/** Tests only: forget the cached config. */
export function clearAppConfigCache(): void {
  cached = undefined;
}
