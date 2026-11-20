import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config.freezed.dart';
part 'app_config.g.dart';

/// Every tunable number in the app.
///
/// Defaults live in `config/app_config_defaults.json`, which the server
/// also read. In production, Remote Config overrides individual keys.
@freezed
abstract class AppConfig with _$AppConfig {
  const factory AppConfig({
    required int discoveryRadiusKm,
    required int companionLocationSnapMeters,
    required int distanceLabelStepKm,
    required int discoverCallsPerMinute,
    required int discoverPageSize,
    required double maxPlausibleSpeedKmh,
    required LaunchCity launchCity,
    required String phoneCountryCode,
    required int phoneNationalNumberLength,
    required int otpResendSeconds,
    required bool phoneLoginEnabled,
    required int otpLength,
    required int otpValiditySeconds,
    required int otpMaxAttempts,
    required int otpRequestsPerPhonePerDay,
    required int otpRequestsPerIpPerHour,
    required int rulesVersion,
    required int signupBonusCredits,
    required int creditCostStartChat,
    required int creditCostBookSpot,
    required int creditCostInstantRequest,
    required List<PlanConfig> plans,
    required List<TopUpPack> topUpPacks,
    required int subscriptionPeriodDays,
    required int bookingDaysAhead,
    required int slotMinutesDefault,
    required int freeNowMaxHours,
    required int tonightStartHour,
    required int checkInWindowMinutesBefore,
    required int checkInWindowMinutesAfter,
    required int safetyCheckIntervalMinutes,
    required int safetyMissedCheckInsToEscalate,
    required int sosHoldSeconds,
    required String emergencyNumber,
    required String privacyPolicyUrl,
    required String termsUrl,
    required String supportEmail,

    /// Grievance Officer (India IT Rules 2021). Empty name: the support email is shown.
    required String grievanceOfficerName,
    required String grievanceOfficerEmail,
    required int autoCompleteGraceMinutes,
    required int moderationStrikesForReport,
    required int moderationStrikeWindowHours,
    required int chatMessageMaxLength,
    required int chatMessagesPageSize,
    required int reportsPerDay,
    required int reportDetailsMaxLength,
    required int verificationSessionMinutes,
    required int captureMaxDimension,
    required int captureJpegQuality,
    required int voiceIntroMaxSec,
    required int maxProfilePhotos,
    required int displayNameMaxLength,
    required int ageMinimum,
    required int ageMaximum,
    required int defaultAgeRangeMin,
    required int defaultAgeRangeMax,
    required double popularityHotThreshold,
    required double popularityBusyThreshold,
    required double maxTextScale,
    required int remoteConfigFetchTimeoutSeconds,
    required int remoteConfigMinimumFetchIntervalMinutes,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, Object?> json) => _$AppConfigFromJson(json);
}

@freezed
abstract class LaunchCity with _$LaunchCity {
  const factory LaunchCity({required String name, required double lat, required double lng, required String timezone}) =
      _LaunchCity;

  factory LaunchCity.fromJson(Map<String, Object?> json) => _$LaunchCityFromJson(json);
}

enum PlanTier { free, plus, premium }

@freezed
abstract class PlanConfig with _$PlanConfig {
  const factory PlanConfig({
    required PlanTier tier,
    required String? productId,
    required int monthlyCredits,

    /// Price shown until the store answers (the store's own price wins).
    String? price,
  }) = _PlanConfig;

  factory PlanConfig.fromJson(Map<String, Object?> json) => _$PlanConfigFromJson(json);
}

@freezed
abstract class TopUpPack with _$TopUpPack {
  const factory TopUpPack({required String productId, required int credits, String? price}) = _TopUpPack;

  factory TopUpPack.fromJson(Map<String, Object?> json) => _$TopUpPackFromJson(json);
}

/// Set once in `bootstrap()` through a provider override.
@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) => throw StateError('appConfigProvider is set in bootstrap(). Override it in tests.');
