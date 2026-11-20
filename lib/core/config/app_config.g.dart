// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => _AppConfig(
  discoveryRadiusKm: (json['discoveryRadiusKm'] as num).toInt(),
  companionLocationSnapMeters: (json['companionLocationSnapMeters'] as num)
      .toInt(),
  distanceLabelStepKm: (json['distanceLabelStepKm'] as num).toInt(),
  discoverCallsPerMinute: (json['discoverCallsPerMinute'] as num).toInt(),
  discoverPageSize: (json['discoverPageSize'] as num).toInt(),
  maxPlausibleSpeedKmh: (json['maxPlausibleSpeedKmh'] as num).toDouble(),
  launchCity: LaunchCity.fromJson(json['launchCity'] as Map<String, dynamic>),
  phoneCountryCode: json['phoneCountryCode'] as String,
  phoneNationalNumberLength: (json['phoneNationalNumberLength'] as num).toInt(),
  otpResendSeconds: (json['otpResendSeconds'] as num).toInt(),
  phoneLoginEnabled: json['phoneLoginEnabled'] as bool,
  otpLength: (json['otpLength'] as num).toInt(),
  otpValiditySeconds: (json['otpValiditySeconds'] as num).toInt(),
  otpMaxAttempts: (json['otpMaxAttempts'] as num).toInt(),
  otpRequestsPerPhonePerDay: (json['otpRequestsPerPhonePerDay'] as num).toInt(),
  otpRequestsPerIpPerHour: (json['otpRequestsPerIpPerHour'] as num).toInt(),
  rulesVersion: (json['rulesVersion'] as num).toInt(),
  signupBonusCredits: (json['signupBonusCredits'] as num).toInt(),
  creditCostStartChat: (json['creditCostStartChat'] as num).toInt(),
  creditCostBookSpot: (json['creditCostBookSpot'] as num).toInt(),
  creditCostInstantRequest: (json['creditCostInstantRequest'] as num).toInt(),
  plans: (json['plans'] as List<dynamic>)
      .map((e) => PlanConfig.fromJson(e as Map<String, dynamic>))
      .toList(),
  topUpPacks: (json['topUpPacks'] as List<dynamic>)
      .map((e) => TopUpPack.fromJson(e as Map<String, dynamic>))
      .toList(),
  subscriptionPeriodDays: (json['subscriptionPeriodDays'] as num).toInt(),
  bookingDaysAhead: (json['bookingDaysAhead'] as num).toInt(),
  slotMinutesDefault: (json['slotMinutesDefault'] as num).toInt(),
  freeNowMaxHours: (json['freeNowMaxHours'] as num).toInt(),
  tonightStartHour: (json['tonightStartHour'] as num).toInt(),
  checkInWindowMinutesBefore: (json['checkInWindowMinutesBefore'] as num)
      .toInt(),
  checkInWindowMinutesAfter: (json['checkInWindowMinutesAfter'] as num).toInt(),
  safetyCheckIntervalMinutes: (json['safetyCheckIntervalMinutes'] as num)
      .toInt(),
  safetyMissedCheckInsToEscalate:
      (json['safetyMissedCheckInsToEscalate'] as num).toInt(),
  sosHoldSeconds: (json['sosHoldSeconds'] as num).toInt(),
  emergencyNumber: json['emergencyNumber'] as String,
  privacyPolicyUrl: json['privacyPolicyUrl'] as String,
  termsUrl: json['termsUrl'] as String,
  supportEmail: json['supportEmail'] as String,
  grievanceOfficerName: json['grievanceOfficerName'] as String,
  grievanceOfficerEmail: json['grievanceOfficerEmail'] as String,
  autoCompleteGraceMinutes: (json['autoCompleteGraceMinutes'] as num).toInt(),
  moderationStrikesForReport: (json['moderationStrikesForReport'] as num)
      .toInt(),
  moderationStrikeWindowHours: (json['moderationStrikeWindowHours'] as num)
      .toInt(),
  chatMessageMaxLength: (json['chatMessageMaxLength'] as num).toInt(),
  chatMessagesPageSize: (json['chatMessagesPageSize'] as num).toInt(),
  reportsPerDay: (json['reportsPerDay'] as num).toInt(),
  reportDetailsMaxLength: (json['reportDetailsMaxLength'] as num).toInt(),
  verificationSessionMinutes: (json['verificationSessionMinutes'] as num)
      .toInt(),
  captureMaxDimension: (json['captureMaxDimension'] as num).toInt(),
  captureJpegQuality: (json['captureJpegQuality'] as num).toInt(),
  voiceIntroMaxSec: (json['voiceIntroMaxSec'] as num).toInt(),
  maxProfilePhotos: (json['maxProfilePhotos'] as num).toInt(),
  displayNameMaxLength: (json['displayNameMaxLength'] as num).toInt(),
  ageMinimum: (json['ageMinimum'] as num).toInt(),
  ageMaximum: (json['ageMaximum'] as num).toInt(),
  defaultAgeRangeMin: (json['defaultAgeRangeMin'] as num).toInt(),
  defaultAgeRangeMax: (json['defaultAgeRangeMax'] as num).toInt(),
  popularityHotThreshold: (json['popularityHotThreshold'] as num).toDouble(),
  popularityBusyThreshold: (json['popularityBusyThreshold'] as num).toDouble(),
  maxTextScale: (json['maxTextScale'] as num).toDouble(),
  remoteConfigFetchTimeoutSeconds:
      (json['remoteConfigFetchTimeoutSeconds'] as num).toInt(),
  remoteConfigMinimumFetchIntervalMinutes:
      (json['remoteConfigMinimumFetchIntervalMinutes'] as num).toInt(),
);

Map<String, dynamic> _$AppConfigToJson(
  _AppConfig instance,
) => <String, dynamic>{
  'discoveryRadiusKm': instance.discoveryRadiusKm,
  'companionLocationSnapMeters': instance.companionLocationSnapMeters,
  'distanceLabelStepKm': instance.distanceLabelStepKm,
  'discoverCallsPerMinute': instance.discoverCallsPerMinute,
  'discoverPageSize': instance.discoverPageSize,
  'maxPlausibleSpeedKmh': instance.maxPlausibleSpeedKmh,
  'launchCity': instance.launchCity,
  'phoneCountryCode': instance.phoneCountryCode,
  'phoneNationalNumberLength': instance.phoneNationalNumberLength,
  'otpResendSeconds': instance.otpResendSeconds,
  'phoneLoginEnabled': instance.phoneLoginEnabled,
  'otpLength': instance.otpLength,
  'otpValiditySeconds': instance.otpValiditySeconds,
  'otpMaxAttempts': instance.otpMaxAttempts,
  'otpRequestsPerPhonePerDay': instance.otpRequestsPerPhonePerDay,
  'otpRequestsPerIpPerHour': instance.otpRequestsPerIpPerHour,
  'rulesVersion': instance.rulesVersion,
  'signupBonusCredits': instance.signupBonusCredits,
  'creditCostStartChat': instance.creditCostStartChat,
  'creditCostBookSpot': instance.creditCostBookSpot,
  'creditCostInstantRequest': instance.creditCostInstantRequest,
  'plans': instance.plans,
  'topUpPacks': instance.topUpPacks,
  'subscriptionPeriodDays': instance.subscriptionPeriodDays,
  'bookingDaysAhead': instance.bookingDaysAhead,
  'slotMinutesDefault': instance.slotMinutesDefault,
  'freeNowMaxHours': instance.freeNowMaxHours,
  'tonightStartHour': instance.tonightStartHour,
  'checkInWindowMinutesBefore': instance.checkInWindowMinutesBefore,
  'checkInWindowMinutesAfter': instance.checkInWindowMinutesAfter,
  'safetyCheckIntervalMinutes': instance.safetyCheckIntervalMinutes,
  'safetyMissedCheckInsToEscalate': instance.safetyMissedCheckInsToEscalate,
  'sosHoldSeconds': instance.sosHoldSeconds,
  'emergencyNumber': instance.emergencyNumber,
  'privacyPolicyUrl': instance.privacyPolicyUrl,
  'termsUrl': instance.termsUrl,
  'supportEmail': instance.supportEmail,
  'grievanceOfficerName': instance.grievanceOfficerName,
  'grievanceOfficerEmail': instance.grievanceOfficerEmail,
  'autoCompleteGraceMinutes': instance.autoCompleteGraceMinutes,
  'moderationStrikesForReport': instance.moderationStrikesForReport,
  'moderationStrikeWindowHours': instance.moderationStrikeWindowHours,
  'chatMessageMaxLength': instance.chatMessageMaxLength,
  'chatMessagesPageSize': instance.chatMessagesPageSize,
  'reportsPerDay': instance.reportsPerDay,
  'reportDetailsMaxLength': instance.reportDetailsMaxLength,
  'verificationSessionMinutes': instance.verificationSessionMinutes,
  'captureMaxDimension': instance.captureMaxDimension,
  'captureJpegQuality': instance.captureJpegQuality,
  'voiceIntroMaxSec': instance.voiceIntroMaxSec,
  'maxProfilePhotos': instance.maxProfilePhotos,
  'displayNameMaxLength': instance.displayNameMaxLength,
  'ageMinimum': instance.ageMinimum,
  'ageMaximum': instance.ageMaximum,
  'defaultAgeRangeMin': instance.defaultAgeRangeMin,
  'defaultAgeRangeMax': instance.defaultAgeRangeMax,
  'popularityHotThreshold': instance.popularityHotThreshold,
  'popularityBusyThreshold': instance.popularityBusyThreshold,
  'maxTextScale': instance.maxTextScale,
  'remoteConfigFetchTimeoutSeconds': instance.remoteConfigFetchTimeoutSeconds,
  'remoteConfigMinimumFetchIntervalMinutes':
      instance.remoteConfigMinimumFetchIntervalMinutes,
};

_LaunchCity _$LaunchCityFromJson(Map<String, dynamic> json) => _LaunchCity(
  name: json['name'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  timezone: json['timezone'] as String,
);

Map<String, dynamic> _$LaunchCityToJson(_LaunchCity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'lat': instance.lat,
      'lng': instance.lng,
      'timezone': instance.timezone,
    };

_PlanConfig _$PlanConfigFromJson(Map<String, dynamic> json) => _PlanConfig(
  tier: $enumDecode(_$PlanTierEnumMap, json['tier']),
  productId: json['productId'] as String?,
  monthlyCredits: (json['monthlyCredits'] as num).toInt(),
  price: json['price'] as String?,
);

Map<String, dynamic> _$PlanConfigToJson(_PlanConfig instance) =>
    <String, dynamic>{
      'tier': _$PlanTierEnumMap[instance.tier]!,
      'productId': instance.productId,
      'monthlyCredits': instance.monthlyCredits,
      'price': instance.price,
    };

const _$PlanTierEnumMap = {
  PlanTier.free: 'free',
  PlanTier.plus: 'plus',
  PlanTier.premium: 'premium',
};

_TopUpPack _$TopUpPackFromJson(Map<String, dynamic> json) => _TopUpPack(
  productId: json['productId'] as String,
  credits: (json['credits'] as num).toInt(),
  price: json['price'] as String?,
);

Map<String, dynamic> _$TopUpPackToJson(_TopUpPack instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'credits': instance.credits,
      'price': instance.price,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Set once in `bootstrap()` through a provider override.

@ProviderFor(appConfig)
const appConfigProvider = AppConfigProvider._();

/// Set once in `bootstrap()` through a provider override.

final class AppConfigProvider
    extends $FunctionalProvider<AppConfig, AppConfig, AppConfig>
    with $Provider<AppConfig> {
  /// Set once in `bootstrap()` through a provider override.
  const AppConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appConfigHash();

  @$internal
  @override
  $ProviderElement<AppConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppConfig create(Ref ref) {
    return appConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppConfig>(value),
    );
  }
}

String _$appConfigHash() => r'7ce440e954d882d6affc3ce7cf567a1e20358ca7';
