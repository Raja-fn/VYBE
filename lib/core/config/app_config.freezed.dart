// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppConfig {

 int get discoveryRadiusKm; int get companionLocationSnapMeters; int get distanceLabelStepKm; int get discoverCallsPerMinute; int get discoverPageSize; double get maxPlausibleSpeedKmh; LaunchCity get launchCity; String get phoneCountryCode; int get phoneNationalNumberLength; int get otpResendSeconds; bool get phoneLoginEnabled; int get otpLength; int get otpValiditySeconds; int get otpMaxAttempts; int get otpRequestsPerPhonePerDay; int get otpRequestsPerIpPerHour; int get rulesVersion; int get signupBonusCredits; int get creditCostStartChat; int get creditCostBookSpot; int get creditCostInstantRequest; List<PlanConfig> get plans; List<TopUpPack> get topUpPacks; int get subscriptionPeriodDays; int get bookingDaysAhead; int get slotMinutesDefault; int get freeNowMaxHours; int get tonightStartHour; int get checkInWindowMinutesBefore; int get checkInWindowMinutesAfter; int get safetyCheckIntervalMinutes; int get safetyMissedCheckInsToEscalate; int get sosHoldSeconds; String get emergencyNumber; String get privacyPolicyUrl; String get termsUrl; String get supportEmail;/// Grievance Officer (India IT Rules 2021). Empty name: the support email is shown.
 String get grievanceOfficerName; String get grievanceOfficerEmail; int get autoCompleteGraceMinutes; int get moderationStrikesForReport; int get moderationStrikeWindowHours; int get chatMessageMaxLength; int get chatMessagesPageSize; int get reportsPerDay; int get reportDetailsMaxLength; int get verificationSessionMinutes; int get captureMaxDimension; int get captureJpegQuality; int get voiceIntroMaxSec; int get maxProfilePhotos; int get displayNameMaxLength; int get ageMinimum; int get ageMaximum; int get defaultAgeRangeMin; int get defaultAgeRangeMax; double get popularityHotThreshold; double get popularityBusyThreshold; double get maxTextScale; int get remoteConfigFetchTimeoutSeconds; int get remoteConfigMinimumFetchIntervalMinutes;
/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppConfigCopyWith<AppConfig> get copyWith => _$AppConfigCopyWithImpl<AppConfig>(this as AppConfig, _$identity);

  /// Serializes this AppConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppConfig&&(identical(other.discoveryRadiusKm, discoveryRadiusKm) || other.discoveryRadiusKm == discoveryRadiusKm)&&(identical(other.companionLocationSnapMeters, companionLocationSnapMeters) || other.companionLocationSnapMeters == companionLocationSnapMeters)&&(identical(other.distanceLabelStepKm, distanceLabelStepKm) || other.distanceLabelStepKm == distanceLabelStepKm)&&(identical(other.discoverCallsPerMinute, discoverCallsPerMinute) || other.discoverCallsPerMinute == discoverCallsPerMinute)&&(identical(other.discoverPageSize, discoverPageSize) || other.discoverPageSize == discoverPageSize)&&(identical(other.maxPlausibleSpeedKmh, maxPlausibleSpeedKmh) || other.maxPlausibleSpeedKmh == maxPlausibleSpeedKmh)&&(identical(other.launchCity, launchCity) || other.launchCity == launchCity)&&(identical(other.phoneCountryCode, phoneCountryCode) || other.phoneCountryCode == phoneCountryCode)&&(identical(other.phoneNationalNumberLength, phoneNationalNumberLength) || other.phoneNationalNumberLength == phoneNationalNumberLength)&&(identical(other.otpResendSeconds, otpResendSeconds) || other.otpResendSeconds == otpResendSeconds)&&(identical(other.phoneLoginEnabled, phoneLoginEnabled) || other.phoneLoginEnabled == phoneLoginEnabled)&&(identical(other.otpLength, otpLength) || other.otpLength == otpLength)&&(identical(other.otpValiditySeconds, otpValiditySeconds) || other.otpValiditySeconds == otpValiditySeconds)&&(identical(other.otpMaxAttempts, otpMaxAttempts) || other.otpMaxAttempts == otpMaxAttempts)&&(identical(other.otpRequestsPerPhonePerDay, otpRequestsPerPhonePerDay) || other.otpRequestsPerPhonePerDay == otpRequestsPerPhonePerDay)&&(identical(other.otpRequestsPerIpPerHour, otpRequestsPerIpPerHour) || other.otpRequestsPerIpPerHour == otpRequestsPerIpPerHour)&&(identical(other.rulesVersion, rulesVersion) || other.rulesVersion == rulesVersion)&&(identical(other.signupBonusCredits, signupBonusCredits) || other.signupBonusCredits == signupBonusCredits)&&(identical(other.creditCostStartChat, creditCostStartChat) || other.creditCostStartChat == creditCostStartChat)&&(identical(other.creditCostBookSpot, creditCostBookSpot) || other.creditCostBookSpot == creditCostBookSpot)&&(identical(other.creditCostInstantRequest, creditCostInstantRequest) || other.creditCostInstantRequest == creditCostInstantRequest)&&const DeepCollectionEquality().equals(other.plans, plans)&&const DeepCollectionEquality().equals(other.topUpPacks, topUpPacks)&&(identical(other.subscriptionPeriodDays, subscriptionPeriodDays) || other.subscriptionPeriodDays == subscriptionPeriodDays)&&(identical(other.bookingDaysAhead, bookingDaysAhead) || other.bookingDaysAhead == bookingDaysAhead)&&(identical(other.slotMinutesDefault, slotMinutesDefault) || other.slotMinutesDefault == slotMinutesDefault)&&(identical(other.freeNowMaxHours, freeNowMaxHours) || other.freeNowMaxHours == freeNowMaxHours)&&(identical(other.tonightStartHour, tonightStartHour) || other.tonightStartHour == tonightStartHour)&&(identical(other.checkInWindowMinutesBefore, checkInWindowMinutesBefore) || other.checkInWindowMinutesBefore == checkInWindowMinutesBefore)&&(identical(other.checkInWindowMinutesAfter, checkInWindowMinutesAfter) || other.checkInWindowMinutesAfter == checkInWindowMinutesAfter)&&(identical(other.safetyCheckIntervalMinutes, safetyCheckIntervalMinutes) || other.safetyCheckIntervalMinutes == safetyCheckIntervalMinutes)&&(identical(other.safetyMissedCheckInsToEscalate, safetyMissedCheckInsToEscalate) || other.safetyMissedCheckInsToEscalate == safetyMissedCheckInsToEscalate)&&(identical(other.sosHoldSeconds, sosHoldSeconds) || other.sosHoldSeconds == sosHoldSeconds)&&(identical(other.emergencyNumber, emergencyNumber) || other.emergencyNumber == emergencyNumber)&&(identical(other.privacyPolicyUrl, privacyPolicyUrl) || other.privacyPolicyUrl == privacyPolicyUrl)&&(identical(other.termsUrl, termsUrl) || other.termsUrl == termsUrl)&&(identical(other.supportEmail, supportEmail) || other.supportEmail == supportEmail)&&(identical(other.grievanceOfficerName, grievanceOfficerName) || other.grievanceOfficerName == grievanceOfficerName)&&(identical(other.grievanceOfficerEmail, grievanceOfficerEmail) || other.grievanceOfficerEmail == grievanceOfficerEmail)&&(identical(other.autoCompleteGraceMinutes, autoCompleteGraceMinutes) || other.autoCompleteGraceMinutes == autoCompleteGraceMinutes)&&(identical(other.moderationStrikesForReport, moderationStrikesForReport) || other.moderationStrikesForReport == moderationStrikesForReport)&&(identical(other.moderationStrikeWindowHours, moderationStrikeWindowHours) || other.moderationStrikeWindowHours == moderationStrikeWindowHours)&&(identical(other.chatMessageMaxLength, chatMessageMaxLength) || other.chatMessageMaxLength == chatMessageMaxLength)&&(identical(other.chatMessagesPageSize, chatMessagesPageSize) || other.chatMessagesPageSize == chatMessagesPageSize)&&(identical(other.reportsPerDay, reportsPerDay) || other.reportsPerDay == reportsPerDay)&&(identical(other.reportDetailsMaxLength, reportDetailsMaxLength) || other.reportDetailsMaxLength == reportDetailsMaxLength)&&(identical(other.verificationSessionMinutes, verificationSessionMinutes) || other.verificationSessionMinutes == verificationSessionMinutes)&&(identical(other.captureMaxDimension, captureMaxDimension) || other.captureMaxDimension == captureMaxDimension)&&(identical(other.captureJpegQuality, captureJpegQuality) || other.captureJpegQuality == captureJpegQuality)&&(identical(other.voiceIntroMaxSec, voiceIntroMaxSec) || other.voiceIntroMaxSec == voiceIntroMaxSec)&&(identical(other.maxProfilePhotos, maxProfilePhotos) || other.maxProfilePhotos == maxProfilePhotos)&&(identical(other.displayNameMaxLength, displayNameMaxLength) || other.displayNameMaxLength == displayNameMaxLength)&&(identical(other.ageMinimum, ageMinimum) || other.ageMinimum == ageMinimum)&&(identical(other.ageMaximum, ageMaximum) || other.ageMaximum == ageMaximum)&&(identical(other.defaultAgeRangeMin, defaultAgeRangeMin) || other.defaultAgeRangeMin == defaultAgeRangeMin)&&(identical(other.defaultAgeRangeMax, defaultAgeRangeMax) || other.defaultAgeRangeMax == defaultAgeRangeMax)&&(identical(other.popularityHotThreshold, popularityHotThreshold) || other.popularityHotThreshold == popularityHotThreshold)&&(identical(other.popularityBusyThreshold, popularityBusyThreshold) || other.popularityBusyThreshold == popularityBusyThreshold)&&(identical(other.maxTextScale, maxTextScale) || other.maxTextScale == maxTextScale)&&(identical(other.remoteConfigFetchTimeoutSeconds, remoteConfigFetchTimeoutSeconds) || other.remoteConfigFetchTimeoutSeconds == remoteConfigFetchTimeoutSeconds)&&(identical(other.remoteConfigMinimumFetchIntervalMinutes, remoteConfigMinimumFetchIntervalMinutes) || other.remoteConfigMinimumFetchIntervalMinutes == remoteConfigMinimumFetchIntervalMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,discoveryRadiusKm,companionLocationSnapMeters,distanceLabelStepKm,discoverCallsPerMinute,discoverPageSize,maxPlausibleSpeedKmh,launchCity,phoneCountryCode,phoneNationalNumberLength,otpResendSeconds,phoneLoginEnabled,otpLength,otpValiditySeconds,otpMaxAttempts,otpRequestsPerPhonePerDay,otpRequestsPerIpPerHour,rulesVersion,signupBonusCredits,creditCostStartChat,creditCostBookSpot,creditCostInstantRequest,const DeepCollectionEquality().hash(plans),const DeepCollectionEquality().hash(topUpPacks),subscriptionPeriodDays,bookingDaysAhead,slotMinutesDefault,freeNowMaxHours,tonightStartHour,checkInWindowMinutesBefore,checkInWindowMinutesAfter,safetyCheckIntervalMinutes,safetyMissedCheckInsToEscalate,sosHoldSeconds,emergencyNumber,privacyPolicyUrl,termsUrl,supportEmail,grievanceOfficerName,grievanceOfficerEmail,autoCompleteGraceMinutes,moderationStrikesForReport,moderationStrikeWindowHours,chatMessageMaxLength,chatMessagesPageSize,reportsPerDay,reportDetailsMaxLength,verificationSessionMinutes,captureMaxDimension,captureJpegQuality,voiceIntroMaxSec,maxProfilePhotos,displayNameMaxLength,ageMinimum,ageMaximum,defaultAgeRangeMin,defaultAgeRangeMax,popularityHotThreshold,popularityBusyThreshold,maxTextScale,remoteConfigFetchTimeoutSeconds,remoteConfigMinimumFetchIntervalMinutes]);

@override
String toString() {
  return 'AppConfig(discoveryRadiusKm: $discoveryRadiusKm, companionLocationSnapMeters: $companionLocationSnapMeters, distanceLabelStepKm: $distanceLabelStepKm, discoverCallsPerMinute: $discoverCallsPerMinute, discoverPageSize: $discoverPageSize, maxPlausibleSpeedKmh: $maxPlausibleSpeedKmh, launchCity: $launchCity, phoneCountryCode: $phoneCountryCode, phoneNationalNumberLength: $phoneNationalNumberLength, otpResendSeconds: $otpResendSeconds, phoneLoginEnabled: $phoneLoginEnabled, otpLength: $otpLength, otpValiditySeconds: $otpValiditySeconds, otpMaxAttempts: $otpMaxAttempts, otpRequestsPerPhonePerDay: $otpRequestsPerPhonePerDay, otpRequestsPerIpPerHour: $otpRequestsPerIpPerHour, rulesVersion: $rulesVersion, signupBonusCredits: $signupBonusCredits, creditCostStartChat: $creditCostStartChat, creditCostBookSpot: $creditCostBookSpot, creditCostInstantRequest: $creditCostInstantRequest, plans: $plans, topUpPacks: $topUpPacks, subscriptionPeriodDays: $subscriptionPeriodDays, bookingDaysAhead: $bookingDaysAhead, slotMinutesDefault: $slotMinutesDefault, freeNowMaxHours: $freeNowMaxHours, tonightStartHour: $tonightStartHour, checkInWindowMinutesBefore: $checkInWindowMinutesBefore, checkInWindowMinutesAfter: $checkInWindowMinutesAfter, safetyCheckIntervalMinutes: $safetyCheckIntervalMinutes, safetyMissedCheckInsToEscalate: $safetyMissedCheckInsToEscalate, sosHoldSeconds: $sosHoldSeconds, emergencyNumber: $emergencyNumber, privacyPolicyUrl: $privacyPolicyUrl, termsUrl: $termsUrl, supportEmail: $supportEmail, grievanceOfficerName: $grievanceOfficerName, grievanceOfficerEmail: $grievanceOfficerEmail, autoCompleteGraceMinutes: $autoCompleteGraceMinutes, moderationStrikesForReport: $moderationStrikesForReport, moderationStrikeWindowHours: $moderationStrikeWindowHours, chatMessageMaxLength: $chatMessageMaxLength, chatMessagesPageSize: $chatMessagesPageSize, reportsPerDay: $reportsPerDay, reportDetailsMaxLength: $reportDetailsMaxLength, verificationSessionMinutes: $verificationSessionMinutes, captureMaxDimension: $captureMaxDimension, captureJpegQuality: $captureJpegQuality, voiceIntroMaxSec: $voiceIntroMaxSec, maxProfilePhotos: $maxProfilePhotos, displayNameMaxLength: $displayNameMaxLength, ageMinimum: $ageMinimum, ageMaximum: $ageMaximum, defaultAgeRangeMin: $defaultAgeRangeMin, defaultAgeRangeMax: $defaultAgeRangeMax, popularityHotThreshold: $popularityHotThreshold, popularityBusyThreshold: $popularityBusyThreshold, maxTextScale: $maxTextScale, remoteConfigFetchTimeoutSeconds: $remoteConfigFetchTimeoutSeconds, remoteConfigMinimumFetchIntervalMinutes: $remoteConfigMinimumFetchIntervalMinutes)';
}


}

/// @nodoc
abstract mixin class $AppConfigCopyWith<$Res>  {
  factory $AppConfigCopyWith(AppConfig value, $Res Function(AppConfig) _then) = _$AppConfigCopyWithImpl;
@useResult
$Res call({
 int discoveryRadiusKm, int companionLocationSnapMeters, int distanceLabelStepKm, int discoverCallsPerMinute, int discoverPageSize, double maxPlausibleSpeedKmh, LaunchCity launchCity, String phoneCountryCode, int phoneNationalNumberLength, int otpResendSeconds, bool phoneLoginEnabled, int otpLength, int otpValiditySeconds, int otpMaxAttempts, int otpRequestsPerPhonePerDay, int otpRequestsPerIpPerHour, int rulesVersion, int signupBonusCredits, int creditCostStartChat, int creditCostBookSpot, int creditCostInstantRequest, List<PlanConfig> plans, List<TopUpPack> topUpPacks, int subscriptionPeriodDays, int bookingDaysAhead, int slotMinutesDefault, int freeNowMaxHours, int tonightStartHour, int checkInWindowMinutesBefore, int checkInWindowMinutesAfter, int safetyCheckIntervalMinutes, int safetyMissedCheckInsToEscalate, int sosHoldSeconds, String emergencyNumber, String privacyPolicyUrl, String termsUrl, String supportEmail, String grievanceOfficerName, String grievanceOfficerEmail, int autoCompleteGraceMinutes, int moderationStrikesForReport, int moderationStrikeWindowHours, int chatMessageMaxLength, int chatMessagesPageSize, int reportsPerDay, int reportDetailsMaxLength, int verificationSessionMinutes, int captureMaxDimension, int captureJpegQuality, int voiceIntroMaxSec, int maxProfilePhotos, int displayNameMaxLength, int ageMinimum, int ageMaximum, int defaultAgeRangeMin, int defaultAgeRangeMax, double popularityHotThreshold, double popularityBusyThreshold, double maxTextScale, int remoteConfigFetchTimeoutSeconds, int remoteConfigMinimumFetchIntervalMinutes
});


$LaunchCityCopyWith<$Res> get launchCity;

}
/// @nodoc
class _$AppConfigCopyWithImpl<$Res>
    implements $AppConfigCopyWith<$Res> {
  _$AppConfigCopyWithImpl(this._self, this._then);

  final AppConfig _self;
  final $Res Function(AppConfig) _then;

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? discoveryRadiusKm = null,Object? companionLocationSnapMeters = null,Object? distanceLabelStepKm = null,Object? discoverCallsPerMinute = null,Object? discoverPageSize = null,Object? maxPlausibleSpeedKmh = null,Object? launchCity = null,Object? phoneCountryCode = null,Object? phoneNationalNumberLength = null,Object? otpResendSeconds = null,Object? phoneLoginEnabled = null,Object? otpLength = null,Object? otpValiditySeconds = null,Object? otpMaxAttempts = null,Object? otpRequestsPerPhonePerDay = null,Object? otpRequestsPerIpPerHour = null,Object? rulesVersion = null,Object? signupBonusCredits = null,Object? creditCostStartChat = null,Object? creditCostBookSpot = null,Object? creditCostInstantRequest = null,Object? plans = null,Object? topUpPacks = null,Object? subscriptionPeriodDays = null,Object? bookingDaysAhead = null,Object? slotMinutesDefault = null,Object? freeNowMaxHours = null,Object? tonightStartHour = null,Object? checkInWindowMinutesBefore = null,Object? checkInWindowMinutesAfter = null,Object? safetyCheckIntervalMinutes = null,Object? safetyMissedCheckInsToEscalate = null,Object? sosHoldSeconds = null,Object? emergencyNumber = null,Object? privacyPolicyUrl = null,Object? termsUrl = null,Object? supportEmail = null,Object? grievanceOfficerName = null,Object? grievanceOfficerEmail = null,Object? autoCompleteGraceMinutes = null,Object? moderationStrikesForReport = null,Object? moderationStrikeWindowHours = null,Object? chatMessageMaxLength = null,Object? chatMessagesPageSize = null,Object? reportsPerDay = null,Object? reportDetailsMaxLength = null,Object? verificationSessionMinutes = null,Object? captureMaxDimension = null,Object? captureJpegQuality = null,Object? voiceIntroMaxSec = null,Object? maxProfilePhotos = null,Object? displayNameMaxLength = null,Object? ageMinimum = null,Object? ageMaximum = null,Object? defaultAgeRangeMin = null,Object? defaultAgeRangeMax = null,Object? popularityHotThreshold = null,Object? popularityBusyThreshold = null,Object? maxTextScale = null,Object? remoteConfigFetchTimeoutSeconds = null,Object? remoteConfigMinimumFetchIntervalMinutes = null,}) {
  return _then(_self.copyWith(
discoveryRadiusKm: null == discoveryRadiusKm ? _self.discoveryRadiusKm : discoveryRadiusKm // ignore: cast_nullable_to_non_nullable
as int,companionLocationSnapMeters: null == companionLocationSnapMeters ? _self.companionLocationSnapMeters : companionLocationSnapMeters // ignore: cast_nullable_to_non_nullable
as int,distanceLabelStepKm: null == distanceLabelStepKm ? _self.distanceLabelStepKm : distanceLabelStepKm // ignore: cast_nullable_to_non_nullable
as int,discoverCallsPerMinute: null == discoverCallsPerMinute ? _self.discoverCallsPerMinute : discoverCallsPerMinute // ignore: cast_nullable_to_non_nullable
as int,discoverPageSize: null == discoverPageSize ? _self.discoverPageSize : discoverPageSize // ignore: cast_nullable_to_non_nullable
as int,maxPlausibleSpeedKmh: null == maxPlausibleSpeedKmh ? _self.maxPlausibleSpeedKmh : maxPlausibleSpeedKmh // ignore: cast_nullable_to_non_nullable
as double,launchCity: null == launchCity ? _self.launchCity : launchCity // ignore: cast_nullable_to_non_nullable
as LaunchCity,phoneCountryCode: null == phoneCountryCode ? _self.phoneCountryCode : phoneCountryCode // ignore: cast_nullable_to_non_nullable
as String,phoneNationalNumberLength: null == phoneNationalNumberLength ? _self.phoneNationalNumberLength : phoneNationalNumberLength // ignore: cast_nullable_to_non_nullable
as int,otpResendSeconds: null == otpResendSeconds ? _self.otpResendSeconds : otpResendSeconds // ignore: cast_nullable_to_non_nullable
as int,phoneLoginEnabled: null == phoneLoginEnabled ? _self.phoneLoginEnabled : phoneLoginEnabled // ignore: cast_nullable_to_non_nullable
as bool,otpLength: null == otpLength ? _self.otpLength : otpLength // ignore: cast_nullable_to_non_nullable
as int,otpValiditySeconds: null == otpValiditySeconds ? _self.otpValiditySeconds : otpValiditySeconds // ignore: cast_nullable_to_non_nullable
as int,otpMaxAttempts: null == otpMaxAttempts ? _self.otpMaxAttempts : otpMaxAttempts // ignore: cast_nullable_to_non_nullable
as int,otpRequestsPerPhonePerDay: null == otpRequestsPerPhonePerDay ? _self.otpRequestsPerPhonePerDay : otpRequestsPerPhonePerDay // ignore: cast_nullable_to_non_nullable
as int,otpRequestsPerIpPerHour: null == otpRequestsPerIpPerHour ? _self.otpRequestsPerIpPerHour : otpRequestsPerIpPerHour // ignore: cast_nullable_to_non_nullable
as int,rulesVersion: null == rulesVersion ? _self.rulesVersion : rulesVersion // ignore: cast_nullable_to_non_nullable
as int,signupBonusCredits: null == signupBonusCredits ? _self.signupBonusCredits : signupBonusCredits // ignore: cast_nullable_to_non_nullable
as int,creditCostStartChat: null == creditCostStartChat ? _self.creditCostStartChat : creditCostStartChat // ignore: cast_nullable_to_non_nullable
as int,creditCostBookSpot: null == creditCostBookSpot ? _self.creditCostBookSpot : creditCostBookSpot // ignore: cast_nullable_to_non_nullable
as int,creditCostInstantRequest: null == creditCostInstantRequest ? _self.creditCostInstantRequest : creditCostInstantRequest // ignore: cast_nullable_to_non_nullable
as int,plans: null == plans ? _self.plans : plans // ignore: cast_nullable_to_non_nullable
as List<PlanConfig>,topUpPacks: null == topUpPacks ? _self.topUpPacks : topUpPacks // ignore: cast_nullable_to_non_nullable
as List<TopUpPack>,subscriptionPeriodDays: null == subscriptionPeriodDays ? _self.subscriptionPeriodDays : subscriptionPeriodDays // ignore: cast_nullable_to_non_nullable
as int,bookingDaysAhead: null == bookingDaysAhead ? _self.bookingDaysAhead : bookingDaysAhead // ignore: cast_nullable_to_non_nullable
as int,slotMinutesDefault: null == slotMinutesDefault ? _self.slotMinutesDefault : slotMinutesDefault // ignore: cast_nullable_to_non_nullable
as int,freeNowMaxHours: null == freeNowMaxHours ? _self.freeNowMaxHours : freeNowMaxHours // ignore: cast_nullable_to_non_nullable
as int,tonightStartHour: null == tonightStartHour ? _self.tonightStartHour : tonightStartHour // ignore: cast_nullable_to_non_nullable
as int,checkInWindowMinutesBefore: null == checkInWindowMinutesBefore ? _self.checkInWindowMinutesBefore : checkInWindowMinutesBefore // ignore: cast_nullable_to_non_nullable
as int,checkInWindowMinutesAfter: null == checkInWindowMinutesAfter ? _self.checkInWindowMinutesAfter : checkInWindowMinutesAfter // ignore: cast_nullable_to_non_nullable
as int,safetyCheckIntervalMinutes: null == safetyCheckIntervalMinutes ? _self.safetyCheckIntervalMinutes : safetyCheckIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,safetyMissedCheckInsToEscalate: null == safetyMissedCheckInsToEscalate ? _self.safetyMissedCheckInsToEscalate : safetyMissedCheckInsToEscalate // ignore: cast_nullable_to_non_nullable
as int,sosHoldSeconds: null == sosHoldSeconds ? _self.sosHoldSeconds : sosHoldSeconds // ignore: cast_nullable_to_non_nullable
as int,emergencyNumber: null == emergencyNumber ? _self.emergencyNumber : emergencyNumber // ignore: cast_nullable_to_non_nullable
as String,privacyPolicyUrl: null == privacyPolicyUrl ? _self.privacyPolicyUrl : privacyPolicyUrl // ignore: cast_nullable_to_non_nullable
as String,termsUrl: null == termsUrl ? _self.termsUrl : termsUrl // ignore: cast_nullable_to_non_nullable
as String,supportEmail: null == supportEmail ? _self.supportEmail : supportEmail // ignore: cast_nullable_to_non_nullable
as String,grievanceOfficerName: null == grievanceOfficerName ? _self.grievanceOfficerName : grievanceOfficerName // ignore: cast_nullable_to_non_nullable
as String,grievanceOfficerEmail: null == grievanceOfficerEmail ? _self.grievanceOfficerEmail : grievanceOfficerEmail // ignore: cast_nullable_to_non_nullable
as String,autoCompleteGraceMinutes: null == autoCompleteGraceMinutes ? _self.autoCompleteGraceMinutes : autoCompleteGraceMinutes // ignore: cast_nullable_to_non_nullable
as int,moderationStrikesForReport: null == moderationStrikesForReport ? _self.moderationStrikesForReport : moderationStrikesForReport // ignore: cast_nullable_to_non_nullable
as int,moderationStrikeWindowHours: null == moderationStrikeWindowHours ? _self.moderationStrikeWindowHours : moderationStrikeWindowHours // ignore: cast_nullable_to_non_nullable
as int,chatMessageMaxLength: null == chatMessageMaxLength ? _self.chatMessageMaxLength : chatMessageMaxLength // ignore: cast_nullable_to_non_nullable
as int,chatMessagesPageSize: null == chatMessagesPageSize ? _self.chatMessagesPageSize : chatMessagesPageSize // ignore: cast_nullable_to_non_nullable
as int,reportsPerDay: null == reportsPerDay ? _self.reportsPerDay : reportsPerDay // ignore: cast_nullable_to_non_nullable
as int,reportDetailsMaxLength: null == reportDetailsMaxLength ? _self.reportDetailsMaxLength : reportDetailsMaxLength // ignore: cast_nullable_to_non_nullable
as int,verificationSessionMinutes: null == verificationSessionMinutes ? _self.verificationSessionMinutes : verificationSessionMinutes // ignore: cast_nullable_to_non_nullable
as int,captureMaxDimension: null == captureMaxDimension ? _self.captureMaxDimension : captureMaxDimension // ignore: cast_nullable_to_non_nullable
as int,captureJpegQuality: null == captureJpegQuality ? _self.captureJpegQuality : captureJpegQuality // ignore: cast_nullable_to_non_nullable
as int,voiceIntroMaxSec: null == voiceIntroMaxSec ? _self.voiceIntroMaxSec : voiceIntroMaxSec // ignore: cast_nullable_to_non_nullable
as int,maxProfilePhotos: null == maxProfilePhotos ? _self.maxProfilePhotos : maxProfilePhotos // ignore: cast_nullable_to_non_nullable
as int,displayNameMaxLength: null == displayNameMaxLength ? _self.displayNameMaxLength : displayNameMaxLength // ignore: cast_nullable_to_non_nullable
as int,ageMinimum: null == ageMinimum ? _self.ageMinimum : ageMinimum // ignore: cast_nullable_to_non_nullable
as int,ageMaximum: null == ageMaximum ? _self.ageMaximum : ageMaximum // ignore: cast_nullable_to_non_nullable
as int,defaultAgeRangeMin: null == defaultAgeRangeMin ? _self.defaultAgeRangeMin : defaultAgeRangeMin // ignore: cast_nullable_to_non_nullable
as int,defaultAgeRangeMax: null == defaultAgeRangeMax ? _self.defaultAgeRangeMax : defaultAgeRangeMax // ignore: cast_nullable_to_non_nullable
as int,popularityHotThreshold: null == popularityHotThreshold ? _self.popularityHotThreshold : popularityHotThreshold // ignore: cast_nullable_to_non_nullable
as double,popularityBusyThreshold: null == popularityBusyThreshold ? _self.popularityBusyThreshold : popularityBusyThreshold // ignore: cast_nullable_to_non_nullable
as double,maxTextScale: null == maxTextScale ? _self.maxTextScale : maxTextScale // ignore: cast_nullable_to_non_nullable
as double,remoteConfigFetchTimeoutSeconds: null == remoteConfigFetchTimeoutSeconds ? _self.remoteConfigFetchTimeoutSeconds : remoteConfigFetchTimeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,remoteConfigMinimumFetchIntervalMinutes: null == remoteConfigMinimumFetchIntervalMinutes ? _self.remoteConfigMinimumFetchIntervalMinutes : remoteConfigMinimumFetchIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LaunchCityCopyWith<$Res> get launchCity {
  
  return $LaunchCityCopyWith<$Res>(_self.launchCity, (value) {
    return _then(_self.copyWith(launchCity: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppConfig].
extension AppConfigPatterns on AppConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppConfig value)  $default,){
final _that = this;
switch (_that) {
case _AppConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int discoveryRadiusKm,  int companionLocationSnapMeters,  int distanceLabelStepKm,  int discoverCallsPerMinute,  int discoverPageSize,  double maxPlausibleSpeedKmh,  LaunchCity launchCity,  String phoneCountryCode,  int phoneNationalNumberLength,  int otpResendSeconds,  bool phoneLoginEnabled,  int otpLength,  int otpValiditySeconds,  int otpMaxAttempts,  int otpRequestsPerPhonePerDay,  int otpRequestsPerIpPerHour,  int rulesVersion,  int signupBonusCredits,  int creditCostStartChat,  int creditCostBookSpot,  int creditCostInstantRequest,  List<PlanConfig> plans,  List<TopUpPack> topUpPacks,  int subscriptionPeriodDays,  int bookingDaysAhead,  int slotMinutesDefault,  int freeNowMaxHours,  int tonightStartHour,  int checkInWindowMinutesBefore,  int checkInWindowMinutesAfter,  int safetyCheckIntervalMinutes,  int safetyMissedCheckInsToEscalate,  int sosHoldSeconds,  String emergencyNumber,  String privacyPolicyUrl,  String termsUrl,  String supportEmail,  String grievanceOfficerName,  String grievanceOfficerEmail,  int autoCompleteGraceMinutes,  int moderationStrikesForReport,  int moderationStrikeWindowHours,  int chatMessageMaxLength,  int chatMessagesPageSize,  int reportsPerDay,  int reportDetailsMaxLength,  int verificationSessionMinutes,  int captureMaxDimension,  int captureJpegQuality,  int voiceIntroMaxSec,  int maxProfilePhotos,  int displayNameMaxLength,  int ageMinimum,  int ageMaximum,  int defaultAgeRangeMin,  int defaultAgeRangeMax,  double popularityHotThreshold,  double popularityBusyThreshold,  double maxTextScale,  int remoteConfigFetchTimeoutSeconds,  int remoteConfigMinimumFetchIntervalMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that.discoveryRadiusKm,_that.companionLocationSnapMeters,_that.distanceLabelStepKm,_that.discoverCallsPerMinute,_that.discoverPageSize,_that.maxPlausibleSpeedKmh,_that.launchCity,_that.phoneCountryCode,_that.phoneNationalNumberLength,_that.otpResendSeconds,_that.phoneLoginEnabled,_that.otpLength,_that.otpValiditySeconds,_that.otpMaxAttempts,_that.otpRequestsPerPhonePerDay,_that.otpRequestsPerIpPerHour,_that.rulesVersion,_that.signupBonusCredits,_that.creditCostStartChat,_that.creditCostBookSpot,_that.creditCostInstantRequest,_that.plans,_that.topUpPacks,_that.subscriptionPeriodDays,_that.bookingDaysAhead,_that.slotMinutesDefault,_that.freeNowMaxHours,_that.tonightStartHour,_that.checkInWindowMinutesBefore,_that.checkInWindowMinutesAfter,_that.safetyCheckIntervalMinutes,_that.safetyMissedCheckInsToEscalate,_that.sosHoldSeconds,_that.emergencyNumber,_that.privacyPolicyUrl,_that.termsUrl,_that.supportEmail,_that.grievanceOfficerName,_that.grievanceOfficerEmail,_that.autoCompleteGraceMinutes,_that.moderationStrikesForReport,_that.moderationStrikeWindowHours,_that.chatMessageMaxLength,_that.chatMessagesPageSize,_that.reportsPerDay,_that.reportDetailsMaxLength,_that.verificationSessionMinutes,_that.captureMaxDimension,_that.captureJpegQuality,_that.voiceIntroMaxSec,_that.maxProfilePhotos,_that.displayNameMaxLength,_that.ageMinimum,_that.ageMaximum,_that.defaultAgeRangeMin,_that.defaultAgeRangeMax,_that.popularityHotThreshold,_that.popularityBusyThreshold,_that.maxTextScale,_that.remoteConfigFetchTimeoutSeconds,_that.remoteConfigMinimumFetchIntervalMinutes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int discoveryRadiusKm,  int companionLocationSnapMeters,  int distanceLabelStepKm,  int discoverCallsPerMinute,  int discoverPageSize,  double maxPlausibleSpeedKmh,  LaunchCity launchCity,  String phoneCountryCode,  int phoneNationalNumberLength,  int otpResendSeconds,  bool phoneLoginEnabled,  int otpLength,  int otpValiditySeconds,  int otpMaxAttempts,  int otpRequestsPerPhonePerDay,  int otpRequestsPerIpPerHour,  int rulesVersion,  int signupBonusCredits,  int creditCostStartChat,  int creditCostBookSpot,  int creditCostInstantRequest,  List<PlanConfig> plans,  List<TopUpPack> topUpPacks,  int subscriptionPeriodDays,  int bookingDaysAhead,  int slotMinutesDefault,  int freeNowMaxHours,  int tonightStartHour,  int checkInWindowMinutesBefore,  int checkInWindowMinutesAfter,  int safetyCheckIntervalMinutes,  int safetyMissedCheckInsToEscalate,  int sosHoldSeconds,  String emergencyNumber,  String privacyPolicyUrl,  String termsUrl,  String supportEmail,  String grievanceOfficerName,  String grievanceOfficerEmail,  int autoCompleteGraceMinutes,  int moderationStrikesForReport,  int moderationStrikeWindowHours,  int chatMessageMaxLength,  int chatMessagesPageSize,  int reportsPerDay,  int reportDetailsMaxLength,  int verificationSessionMinutes,  int captureMaxDimension,  int captureJpegQuality,  int voiceIntroMaxSec,  int maxProfilePhotos,  int displayNameMaxLength,  int ageMinimum,  int ageMaximum,  int defaultAgeRangeMin,  int defaultAgeRangeMax,  double popularityHotThreshold,  double popularityBusyThreshold,  double maxTextScale,  int remoteConfigFetchTimeoutSeconds,  int remoteConfigMinimumFetchIntervalMinutes)  $default,) {final _that = this;
switch (_that) {
case _AppConfig():
return $default(_that.discoveryRadiusKm,_that.companionLocationSnapMeters,_that.distanceLabelStepKm,_that.discoverCallsPerMinute,_that.discoverPageSize,_that.maxPlausibleSpeedKmh,_that.launchCity,_that.phoneCountryCode,_that.phoneNationalNumberLength,_that.otpResendSeconds,_that.phoneLoginEnabled,_that.otpLength,_that.otpValiditySeconds,_that.otpMaxAttempts,_that.otpRequestsPerPhonePerDay,_that.otpRequestsPerIpPerHour,_that.rulesVersion,_that.signupBonusCredits,_that.creditCostStartChat,_that.creditCostBookSpot,_that.creditCostInstantRequest,_that.plans,_that.topUpPacks,_that.subscriptionPeriodDays,_that.bookingDaysAhead,_that.slotMinutesDefault,_that.freeNowMaxHours,_that.tonightStartHour,_that.checkInWindowMinutesBefore,_that.checkInWindowMinutesAfter,_that.safetyCheckIntervalMinutes,_that.safetyMissedCheckInsToEscalate,_that.sosHoldSeconds,_that.emergencyNumber,_that.privacyPolicyUrl,_that.termsUrl,_that.supportEmail,_that.grievanceOfficerName,_that.grievanceOfficerEmail,_that.autoCompleteGraceMinutes,_that.moderationStrikesForReport,_that.moderationStrikeWindowHours,_that.chatMessageMaxLength,_that.chatMessagesPageSize,_that.reportsPerDay,_that.reportDetailsMaxLength,_that.verificationSessionMinutes,_that.captureMaxDimension,_that.captureJpegQuality,_that.voiceIntroMaxSec,_that.maxProfilePhotos,_that.displayNameMaxLength,_that.ageMinimum,_that.ageMaximum,_that.defaultAgeRangeMin,_that.defaultAgeRangeMax,_that.popularityHotThreshold,_that.popularityBusyThreshold,_that.maxTextScale,_that.remoteConfigFetchTimeoutSeconds,_that.remoteConfigMinimumFetchIntervalMinutes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int discoveryRadiusKm,  int companionLocationSnapMeters,  int distanceLabelStepKm,  int discoverCallsPerMinute,  int discoverPageSize,  double maxPlausibleSpeedKmh,  LaunchCity launchCity,  String phoneCountryCode,  int phoneNationalNumberLength,  int otpResendSeconds,  bool phoneLoginEnabled,  int otpLength,  int otpValiditySeconds,  int otpMaxAttempts,  int otpRequestsPerPhonePerDay,  int otpRequestsPerIpPerHour,  int rulesVersion,  int signupBonusCredits,  int creditCostStartChat,  int creditCostBookSpot,  int creditCostInstantRequest,  List<PlanConfig> plans,  List<TopUpPack> topUpPacks,  int subscriptionPeriodDays,  int bookingDaysAhead,  int slotMinutesDefault,  int freeNowMaxHours,  int tonightStartHour,  int checkInWindowMinutesBefore,  int checkInWindowMinutesAfter,  int safetyCheckIntervalMinutes,  int safetyMissedCheckInsToEscalate,  int sosHoldSeconds,  String emergencyNumber,  String privacyPolicyUrl,  String termsUrl,  String supportEmail,  String grievanceOfficerName,  String grievanceOfficerEmail,  int autoCompleteGraceMinutes,  int moderationStrikesForReport,  int moderationStrikeWindowHours,  int chatMessageMaxLength,  int chatMessagesPageSize,  int reportsPerDay,  int reportDetailsMaxLength,  int verificationSessionMinutes,  int captureMaxDimension,  int captureJpegQuality,  int voiceIntroMaxSec,  int maxProfilePhotos,  int displayNameMaxLength,  int ageMinimum,  int ageMaximum,  int defaultAgeRangeMin,  int defaultAgeRangeMax,  double popularityHotThreshold,  double popularityBusyThreshold,  double maxTextScale,  int remoteConfigFetchTimeoutSeconds,  int remoteConfigMinimumFetchIntervalMinutes)?  $default,) {final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that.discoveryRadiusKm,_that.companionLocationSnapMeters,_that.distanceLabelStepKm,_that.discoverCallsPerMinute,_that.discoverPageSize,_that.maxPlausibleSpeedKmh,_that.launchCity,_that.phoneCountryCode,_that.phoneNationalNumberLength,_that.otpResendSeconds,_that.phoneLoginEnabled,_that.otpLength,_that.otpValiditySeconds,_that.otpMaxAttempts,_that.otpRequestsPerPhonePerDay,_that.otpRequestsPerIpPerHour,_that.rulesVersion,_that.signupBonusCredits,_that.creditCostStartChat,_that.creditCostBookSpot,_that.creditCostInstantRequest,_that.plans,_that.topUpPacks,_that.subscriptionPeriodDays,_that.bookingDaysAhead,_that.slotMinutesDefault,_that.freeNowMaxHours,_that.tonightStartHour,_that.checkInWindowMinutesBefore,_that.checkInWindowMinutesAfter,_that.safetyCheckIntervalMinutes,_that.safetyMissedCheckInsToEscalate,_that.sosHoldSeconds,_that.emergencyNumber,_that.privacyPolicyUrl,_that.termsUrl,_that.supportEmail,_that.grievanceOfficerName,_that.grievanceOfficerEmail,_that.autoCompleteGraceMinutes,_that.moderationStrikesForReport,_that.moderationStrikeWindowHours,_that.chatMessageMaxLength,_that.chatMessagesPageSize,_that.reportsPerDay,_that.reportDetailsMaxLength,_that.verificationSessionMinutes,_that.captureMaxDimension,_that.captureJpegQuality,_that.voiceIntroMaxSec,_that.maxProfilePhotos,_that.displayNameMaxLength,_that.ageMinimum,_that.ageMaximum,_that.defaultAgeRangeMin,_that.defaultAgeRangeMax,_that.popularityHotThreshold,_that.popularityBusyThreshold,_that.maxTextScale,_that.remoteConfigFetchTimeoutSeconds,_that.remoteConfigMinimumFetchIntervalMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppConfig implements AppConfig {
  const _AppConfig({required this.discoveryRadiusKm, required this.companionLocationSnapMeters, required this.distanceLabelStepKm, required this.discoverCallsPerMinute, required this.discoverPageSize, required this.maxPlausibleSpeedKmh, required this.launchCity, required this.phoneCountryCode, required this.phoneNationalNumberLength, required this.otpResendSeconds, required this.phoneLoginEnabled, required this.otpLength, required this.otpValiditySeconds, required this.otpMaxAttempts, required this.otpRequestsPerPhonePerDay, required this.otpRequestsPerIpPerHour, required this.rulesVersion, required this.signupBonusCredits, required this.creditCostStartChat, required this.creditCostBookSpot, required this.creditCostInstantRequest, required final  List<PlanConfig> plans, required final  List<TopUpPack> topUpPacks, required this.subscriptionPeriodDays, required this.bookingDaysAhead, required this.slotMinutesDefault, required this.freeNowMaxHours, required this.tonightStartHour, required this.checkInWindowMinutesBefore, required this.checkInWindowMinutesAfter, required this.safetyCheckIntervalMinutes, required this.safetyMissedCheckInsToEscalate, required this.sosHoldSeconds, required this.emergencyNumber, required this.privacyPolicyUrl, required this.termsUrl, required this.supportEmail, required this.grievanceOfficerName, required this.grievanceOfficerEmail, required this.autoCompleteGraceMinutes, required this.moderationStrikesForReport, required this.moderationStrikeWindowHours, required this.chatMessageMaxLength, required this.chatMessagesPageSize, required this.reportsPerDay, required this.reportDetailsMaxLength, required this.verificationSessionMinutes, required this.captureMaxDimension, required this.captureJpegQuality, required this.voiceIntroMaxSec, required this.maxProfilePhotos, required this.displayNameMaxLength, required this.ageMinimum, required this.ageMaximum, required this.defaultAgeRangeMin, required this.defaultAgeRangeMax, required this.popularityHotThreshold, required this.popularityBusyThreshold, required this.maxTextScale, required this.remoteConfigFetchTimeoutSeconds, required this.remoteConfigMinimumFetchIntervalMinutes}): _plans = plans,_topUpPacks = topUpPacks;
  factory _AppConfig.fromJson(Map<String, dynamic> json) => _$AppConfigFromJson(json);

@override final  int discoveryRadiusKm;
@override final  int companionLocationSnapMeters;
@override final  int distanceLabelStepKm;
@override final  int discoverCallsPerMinute;
@override final  int discoverPageSize;
@override final  double maxPlausibleSpeedKmh;
@override final  LaunchCity launchCity;
@override final  String phoneCountryCode;
@override final  int phoneNationalNumberLength;
@override final  int otpResendSeconds;
@override final  bool phoneLoginEnabled;
@override final  int otpLength;
@override final  int otpValiditySeconds;
@override final  int otpMaxAttempts;
@override final  int otpRequestsPerPhonePerDay;
@override final  int otpRequestsPerIpPerHour;
@override final  int rulesVersion;
@override final  int signupBonusCredits;
@override final  int creditCostStartChat;
@override final  int creditCostBookSpot;
@override final  int creditCostInstantRequest;
 final  List<PlanConfig> _plans;
@override List<PlanConfig> get plans {
  if (_plans is EqualUnmodifiableListView) return _plans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_plans);
}

 final  List<TopUpPack> _topUpPacks;
@override List<TopUpPack> get topUpPacks {
  if (_topUpPacks is EqualUnmodifiableListView) return _topUpPacks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topUpPacks);
}

@override final  int subscriptionPeriodDays;
@override final  int bookingDaysAhead;
@override final  int slotMinutesDefault;
@override final  int freeNowMaxHours;
@override final  int tonightStartHour;
@override final  int checkInWindowMinutesBefore;
@override final  int checkInWindowMinutesAfter;
@override final  int safetyCheckIntervalMinutes;
@override final  int safetyMissedCheckInsToEscalate;
@override final  int sosHoldSeconds;
@override final  String emergencyNumber;
@override final  String privacyPolicyUrl;
@override final  String termsUrl;
@override final  String supportEmail;
/// Grievance Officer (India IT Rules 2021). Empty name: the support email is shown.
@override final  String grievanceOfficerName;
@override final  String grievanceOfficerEmail;
@override final  int autoCompleteGraceMinutes;
@override final  int moderationStrikesForReport;
@override final  int moderationStrikeWindowHours;
@override final  int chatMessageMaxLength;
@override final  int chatMessagesPageSize;
@override final  int reportsPerDay;
@override final  int reportDetailsMaxLength;
@override final  int verificationSessionMinutes;
@override final  int captureMaxDimension;
@override final  int captureJpegQuality;
@override final  int voiceIntroMaxSec;
@override final  int maxProfilePhotos;
@override final  int displayNameMaxLength;
@override final  int ageMinimum;
@override final  int ageMaximum;
@override final  int defaultAgeRangeMin;
@override final  int defaultAgeRangeMax;
@override final  double popularityHotThreshold;
@override final  double popularityBusyThreshold;
@override final  double maxTextScale;
@override final  int remoteConfigFetchTimeoutSeconds;
@override final  int remoteConfigMinimumFetchIntervalMinutes;

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppConfigCopyWith<_AppConfig> get copyWith => __$AppConfigCopyWithImpl<_AppConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppConfig&&(identical(other.discoveryRadiusKm, discoveryRadiusKm) || other.discoveryRadiusKm == discoveryRadiusKm)&&(identical(other.companionLocationSnapMeters, companionLocationSnapMeters) || other.companionLocationSnapMeters == companionLocationSnapMeters)&&(identical(other.distanceLabelStepKm, distanceLabelStepKm) || other.distanceLabelStepKm == distanceLabelStepKm)&&(identical(other.discoverCallsPerMinute, discoverCallsPerMinute) || other.discoverCallsPerMinute == discoverCallsPerMinute)&&(identical(other.discoverPageSize, discoverPageSize) || other.discoverPageSize == discoverPageSize)&&(identical(other.maxPlausibleSpeedKmh, maxPlausibleSpeedKmh) || other.maxPlausibleSpeedKmh == maxPlausibleSpeedKmh)&&(identical(other.launchCity, launchCity) || other.launchCity == launchCity)&&(identical(other.phoneCountryCode, phoneCountryCode) || other.phoneCountryCode == phoneCountryCode)&&(identical(other.phoneNationalNumberLength, phoneNationalNumberLength) || other.phoneNationalNumberLength == phoneNationalNumberLength)&&(identical(other.otpResendSeconds, otpResendSeconds) || other.otpResendSeconds == otpResendSeconds)&&(identical(other.phoneLoginEnabled, phoneLoginEnabled) || other.phoneLoginEnabled == phoneLoginEnabled)&&(identical(other.otpLength, otpLength) || other.otpLength == otpLength)&&(identical(other.otpValiditySeconds, otpValiditySeconds) || other.otpValiditySeconds == otpValiditySeconds)&&(identical(other.otpMaxAttempts, otpMaxAttempts) || other.otpMaxAttempts == otpMaxAttempts)&&(identical(other.otpRequestsPerPhonePerDay, otpRequestsPerPhonePerDay) || other.otpRequestsPerPhonePerDay == otpRequestsPerPhonePerDay)&&(identical(other.otpRequestsPerIpPerHour, otpRequestsPerIpPerHour) || other.otpRequestsPerIpPerHour == otpRequestsPerIpPerHour)&&(identical(other.rulesVersion, rulesVersion) || other.rulesVersion == rulesVersion)&&(identical(other.signupBonusCredits, signupBonusCredits) || other.signupBonusCredits == signupBonusCredits)&&(identical(other.creditCostStartChat, creditCostStartChat) || other.creditCostStartChat == creditCostStartChat)&&(identical(other.creditCostBookSpot, creditCostBookSpot) || other.creditCostBookSpot == creditCostBookSpot)&&(identical(other.creditCostInstantRequest, creditCostInstantRequest) || other.creditCostInstantRequest == creditCostInstantRequest)&&const DeepCollectionEquality().equals(other._plans, _plans)&&const DeepCollectionEquality().equals(other._topUpPacks, _topUpPacks)&&(identical(other.subscriptionPeriodDays, subscriptionPeriodDays) || other.subscriptionPeriodDays == subscriptionPeriodDays)&&(identical(other.bookingDaysAhead, bookingDaysAhead) || other.bookingDaysAhead == bookingDaysAhead)&&(identical(other.slotMinutesDefault, slotMinutesDefault) || other.slotMinutesDefault == slotMinutesDefault)&&(identical(other.freeNowMaxHours, freeNowMaxHours) || other.freeNowMaxHours == freeNowMaxHours)&&(identical(other.tonightStartHour, tonightStartHour) || other.tonightStartHour == tonightStartHour)&&(identical(other.checkInWindowMinutesBefore, checkInWindowMinutesBefore) || other.checkInWindowMinutesBefore == checkInWindowMinutesBefore)&&(identical(other.checkInWindowMinutesAfter, checkInWindowMinutesAfter) || other.checkInWindowMinutesAfter == checkInWindowMinutesAfter)&&(identical(other.safetyCheckIntervalMinutes, safetyCheckIntervalMinutes) || other.safetyCheckIntervalMinutes == safetyCheckIntervalMinutes)&&(identical(other.safetyMissedCheckInsToEscalate, safetyMissedCheckInsToEscalate) || other.safetyMissedCheckInsToEscalate == safetyMissedCheckInsToEscalate)&&(identical(other.sosHoldSeconds, sosHoldSeconds) || other.sosHoldSeconds == sosHoldSeconds)&&(identical(other.emergencyNumber, emergencyNumber) || other.emergencyNumber == emergencyNumber)&&(identical(other.privacyPolicyUrl, privacyPolicyUrl) || other.privacyPolicyUrl == privacyPolicyUrl)&&(identical(other.termsUrl, termsUrl) || other.termsUrl == termsUrl)&&(identical(other.supportEmail, supportEmail) || other.supportEmail == supportEmail)&&(identical(other.grievanceOfficerName, grievanceOfficerName) || other.grievanceOfficerName == grievanceOfficerName)&&(identical(other.grievanceOfficerEmail, grievanceOfficerEmail) || other.grievanceOfficerEmail == grievanceOfficerEmail)&&(identical(other.autoCompleteGraceMinutes, autoCompleteGraceMinutes) || other.autoCompleteGraceMinutes == autoCompleteGraceMinutes)&&(identical(other.moderationStrikesForReport, moderationStrikesForReport) || other.moderationStrikesForReport == moderationStrikesForReport)&&(identical(other.moderationStrikeWindowHours, moderationStrikeWindowHours) || other.moderationStrikeWindowHours == moderationStrikeWindowHours)&&(identical(other.chatMessageMaxLength, chatMessageMaxLength) || other.chatMessageMaxLength == chatMessageMaxLength)&&(identical(other.chatMessagesPageSize, chatMessagesPageSize) || other.chatMessagesPageSize == chatMessagesPageSize)&&(identical(other.reportsPerDay, reportsPerDay) || other.reportsPerDay == reportsPerDay)&&(identical(other.reportDetailsMaxLength, reportDetailsMaxLength) || other.reportDetailsMaxLength == reportDetailsMaxLength)&&(identical(other.verificationSessionMinutes, verificationSessionMinutes) || other.verificationSessionMinutes == verificationSessionMinutes)&&(identical(other.captureMaxDimension, captureMaxDimension) || other.captureMaxDimension == captureMaxDimension)&&(identical(other.captureJpegQuality, captureJpegQuality) || other.captureJpegQuality == captureJpegQuality)&&(identical(other.voiceIntroMaxSec, voiceIntroMaxSec) || other.voiceIntroMaxSec == voiceIntroMaxSec)&&(identical(other.maxProfilePhotos, maxProfilePhotos) || other.maxProfilePhotos == maxProfilePhotos)&&(identical(other.displayNameMaxLength, displayNameMaxLength) || other.displayNameMaxLength == displayNameMaxLength)&&(identical(other.ageMinimum, ageMinimum) || other.ageMinimum == ageMinimum)&&(identical(other.ageMaximum, ageMaximum) || other.ageMaximum == ageMaximum)&&(identical(other.defaultAgeRangeMin, defaultAgeRangeMin) || other.defaultAgeRangeMin == defaultAgeRangeMin)&&(identical(other.defaultAgeRangeMax, defaultAgeRangeMax) || other.defaultAgeRangeMax == defaultAgeRangeMax)&&(identical(other.popularityHotThreshold, popularityHotThreshold) || other.popularityHotThreshold == popularityHotThreshold)&&(identical(other.popularityBusyThreshold, popularityBusyThreshold) || other.popularityBusyThreshold == popularityBusyThreshold)&&(identical(other.maxTextScale, maxTextScale) || other.maxTextScale == maxTextScale)&&(identical(other.remoteConfigFetchTimeoutSeconds, remoteConfigFetchTimeoutSeconds) || other.remoteConfigFetchTimeoutSeconds == remoteConfigFetchTimeoutSeconds)&&(identical(other.remoteConfigMinimumFetchIntervalMinutes, remoteConfigMinimumFetchIntervalMinutes) || other.remoteConfigMinimumFetchIntervalMinutes == remoteConfigMinimumFetchIntervalMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,discoveryRadiusKm,companionLocationSnapMeters,distanceLabelStepKm,discoverCallsPerMinute,discoverPageSize,maxPlausibleSpeedKmh,launchCity,phoneCountryCode,phoneNationalNumberLength,otpResendSeconds,phoneLoginEnabled,otpLength,otpValiditySeconds,otpMaxAttempts,otpRequestsPerPhonePerDay,otpRequestsPerIpPerHour,rulesVersion,signupBonusCredits,creditCostStartChat,creditCostBookSpot,creditCostInstantRequest,const DeepCollectionEquality().hash(_plans),const DeepCollectionEquality().hash(_topUpPacks),subscriptionPeriodDays,bookingDaysAhead,slotMinutesDefault,freeNowMaxHours,tonightStartHour,checkInWindowMinutesBefore,checkInWindowMinutesAfter,safetyCheckIntervalMinutes,safetyMissedCheckInsToEscalate,sosHoldSeconds,emergencyNumber,privacyPolicyUrl,termsUrl,supportEmail,grievanceOfficerName,grievanceOfficerEmail,autoCompleteGraceMinutes,moderationStrikesForReport,moderationStrikeWindowHours,chatMessageMaxLength,chatMessagesPageSize,reportsPerDay,reportDetailsMaxLength,verificationSessionMinutes,captureMaxDimension,captureJpegQuality,voiceIntroMaxSec,maxProfilePhotos,displayNameMaxLength,ageMinimum,ageMaximum,defaultAgeRangeMin,defaultAgeRangeMax,popularityHotThreshold,popularityBusyThreshold,maxTextScale,remoteConfigFetchTimeoutSeconds,remoteConfigMinimumFetchIntervalMinutes]);

@override
String toString() {
  return 'AppConfig(discoveryRadiusKm: $discoveryRadiusKm, companionLocationSnapMeters: $companionLocationSnapMeters, distanceLabelStepKm: $distanceLabelStepKm, discoverCallsPerMinute: $discoverCallsPerMinute, discoverPageSize: $discoverPageSize, maxPlausibleSpeedKmh: $maxPlausibleSpeedKmh, launchCity: $launchCity, phoneCountryCode: $phoneCountryCode, phoneNationalNumberLength: $phoneNationalNumberLength, otpResendSeconds: $otpResendSeconds, phoneLoginEnabled: $phoneLoginEnabled, otpLength: $otpLength, otpValiditySeconds: $otpValiditySeconds, otpMaxAttempts: $otpMaxAttempts, otpRequestsPerPhonePerDay: $otpRequestsPerPhonePerDay, otpRequestsPerIpPerHour: $otpRequestsPerIpPerHour, rulesVersion: $rulesVersion, signupBonusCredits: $signupBonusCredits, creditCostStartChat: $creditCostStartChat, creditCostBookSpot: $creditCostBookSpot, creditCostInstantRequest: $creditCostInstantRequest, plans: $plans, topUpPacks: $topUpPacks, subscriptionPeriodDays: $subscriptionPeriodDays, bookingDaysAhead: $bookingDaysAhead, slotMinutesDefault: $slotMinutesDefault, freeNowMaxHours: $freeNowMaxHours, tonightStartHour: $tonightStartHour, checkInWindowMinutesBefore: $checkInWindowMinutesBefore, checkInWindowMinutesAfter: $checkInWindowMinutesAfter, safetyCheckIntervalMinutes: $safetyCheckIntervalMinutes, safetyMissedCheckInsToEscalate: $safetyMissedCheckInsToEscalate, sosHoldSeconds: $sosHoldSeconds, emergencyNumber: $emergencyNumber, privacyPolicyUrl: $privacyPolicyUrl, termsUrl: $termsUrl, supportEmail: $supportEmail, grievanceOfficerName: $grievanceOfficerName, grievanceOfficerEmail: $grievanceOfficerEmail, autoCompleteGraceMinutes: $autoCompleteGraceMinutes, moderationStrikesForReport: $moderationStrikesForReport, moderationStrikeWindowHours: $moderationStrikeWindowHours, chatMessageMaxLength: $chatMessageMaxLength, chatMessagesPageSize: $chatMessagesPageSize, reportsPerDay: $reportsPerDay, reportDetailsMaxLength: $reportDetailsMaxLength, verificationSessionMinutes: $verificationSessionMinutes, captureMaxDimension: $captureMaxDimension, captureJpegQuality: $captureJpegQuality, voiceIntroMaxSec: $voiceIntroMaxSec, maxProfilePhotos: $maxProfilePhotos, displayNameMaxLength: $displayNameMaxLength, ageMinimum: $ageMinimum, ageMaximum: $ageMaximum, defaultAgeRangeMin: $defaultAgeRangeMin, defaultAgeRangeMax: $defaultAgeRangeMax, popularityHotThreshold: $popularityHotThreshold, popularityBusyThreshold: $popularityBusyThreshold, maxTextScale: $maxTextScale, remoteConfigFetchTimeoutSeconds: $remoteConfigFetchTimeoutSeconds, remoteConfigMinimumFetchIntervalMinutes: $remoteConfigMinimumFetchIntervalMinutes)';
}


}

/// @nodoc
abstract mixin class _$AppConfigCopyWith<$Res> implements $AppConfigCopyWith<$Res> {
  factory _$AppConfigCopyWith(_AppConfig value, $Res Function(_AppConfig) _then) = __$AppConfigCopyWithImpl;
@override @useResult
$Res call({
 int discoveryRadiusKm, int companionLocationSnapMeters, int distanceLabelStepKm, int discoverCallsPerMinute, int discoverPageSize, double maxPlausibleSpeedKmh, LaunchCity launchCity, String phoneCountryCode, int phoneNationalNumberLength, int otpResendSeconds, bool phoneLoginEnabled, int otpLength, int otpValiditySeconds, int otpMaxAttempts, int otpRequestsPerPhonePerDay, int otpRequestsPerIpPerHour, int rulesVersion, int signupBonusCredits, int creditCostStartChat, int creditCostBookSpot, int creditCostInstantRequest, List<PlanConfig> plans, List<TopUpPack> topUpPacks, int subscriptionPeriodDays, int bookingDaysAhead, int slotMinutesDefault, int freeNowMaxHours, int tonightStartHour, int checkInWindowMinutesBefore, int checkInWindowMinutesAfter, int safetyCheckIntervalMinutes, int safetyMissedCheckInsToEscalate, int sosHoldSeconds, String emergencyNumber, String privacyPolicyUrl, String termsUrl, String supportEmail, String grievanceOfficerName, String grievanceOfficerEmail, int autoCompleteGraceMinutes, int moderationStrikesForReport, int moderationStrikeWindowHours, int chatMessageMaxLength, int chatMessagesPageSize, int reportsPerDay, int reportDetailsMaxLength, int verificationSessionMinutes, int captureMaxDimension, int captureJpegQuality, int voiceIntroMaxSec, int maxProfilePhotos, int displayNameMaxLength, int ageMinimum, int ageMaximum, int defaultAgeRangeMin, int defaultAgeRangeMax, double popularityHotThreshold, double popularityBusyThreshold, double maxTextScale, int remoteConfigFetchTimeoutSeconds, int remoteConfigMinimumFetchIntervalMinutes
});


@override $LaunchCityCopyWith<$Res> get launchCity;

}
/// @nodoc
class __$AppConfigCopyWithImpl<$Res>
    implements _$AppConfigCopyWith<$Res> {
  __$AppConfigCopyWithImpl(this._self, this._then);

  final _AppConfig _self;
  final $Res Function(_AppConfig) _then;

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? discoveryRadiusKm = null,Object? companionLocationSnapMeters = null,Object? distanceLabelStepKm = null,Object? discoverCallsPerMinute = null,Object? discoverPageSize = null,Object? maxPlausibleSpeedKmh = null,Object? launchCity = null,Object? phoneCountryCode = null,Object? phoneNationalNumberLength = null,Object? otpResendSeconds = null,Object? phoneLoginEnabled = null,Object? otpLength = null,Object? otpValiditySeconds = null,Object? otpMaxAttempts = null,Object? otpRequestsPerPhonePerDay = null,Object? otpRequestsPerIpPerHour = null,Object? rulesVersion = null,Object? signupBonusCredits = null,Object? creditCostStartChat = null,Object? creditCostBookSpot = null,Object? creditCostInstantRequest = null,Object? plans = null,Object? topUpPacks = null,Object? subscriptionPeriodDays = null,Object? bookingDaysAhead = null,Object? slotMinutesDefault = null,Object? freeNowMaxHours = null,Object? tonightStartHour = null,Object? checkInWindowMinutesBefore = null,Object? checkInWindowMinutesAfter = null,Object? safetyCheckIntervalMinutes = null,Object? safetyMissedCheckInsToEscalate = null,Object? sosHoldSeconds = null,Object? emergencyNumber = null,Object? privacyPolicyUrl = null,Object? termsUrl = null,Object? supportEmail = null,Object? grievanceOfficerName = null,Object? grievanceOfficerEmail = null,Object? autoCompleteGraceMinutes = null,Object? moderationStrikesForReport = null,Object? moderationStrikeWindowHours = null,Object? chatMessageMaxLength = null,Object? chatMessagesPageSize = null,Object? reportsPerDay = null,Object? reportDetailsMaxLength = null,Object? verificationSessionMinutes = null,Object? captureMaxDimension = null,Object? captureJpegQuality = null,Object? voiceIntroMaxSec = null,Object? maxProfilePhotos = null,Object? displayNameMaxLength = null,Object? ageMinimum = null,Object? ageMaximum = null,Object? defaultAgeRangeMin = null,Object? defaultAgeRangeMax = null,Object? popularityHotThreshold = null,Object? popularityBusyThreshold = null,Object? maxTextScale = null,Object? remoteConfigFetchTimeoutSeconds = null,Object? remoteConfigMinimumFetchIntervalMinutes = null,}) {
  return _then(_AppConfig(
discoveryRadiusKm: null == discoveryRadiusKm ? _self.discoveryRadiusKm : discoveryRadiusKm // ignore: cast_nullable_to_non_nullable
as int,companionLocationSnapMeters: null == companionLocationSnapMeters ? _self.companionLocationSnapMeters : companionLocationSnapMeters // ignore: cast_nullable_to_non_nullable
as int,distanceLabelStepKm: null == distanceLabelStepKm ? _self.distanceLabelStepKm : distanceLabelStepKm // ignore: cast_nullable_to_non_nullable
as int,discoverCallsPerMinute: null == discoverCallsPerMinute ? _self.discoverCallsPerMinute : discoverCallsPerMinute // ignore: cast_nullable_to_non_nullable
as int,discoverPageSize: null == discoverPageSize ? _self.discoverPageSize : discoverPageSize // ignore: cast_nullable_to_non_nullable
as int,maxPlausibleSpeedKmh: null == maxPlausibleSpeedKmh ? _self.maxPlausibleSpeedKmh : maxPlausibleSpeedKmh // ignore: cast_nullable_to_non_nullable
as double,launchCity: null == launchCity ? _self.launchCity : launchCity // ignore: cast_nullable_to_non_nullable
as LaunchCity,phoneCountryCode: null == phoneCountryCode ? _self.phoneCountryCode : phoneCountryCode // ignore: cast_nullable_to_non_nullable
as String,phoneNationalNumberLength: null == phoneNationalNumberLength ? _self.phoneNationalNumberLength : phoneNationalNumberLength // ignore: cast_nullable_to_non_nullable
as int,otpResendSeconds: null == otpResendSeconds ? _self.otpResendSeconds : otpResendSeconds // ignore: cast_nullable_to_non_nullable
as int,phoneLoginEnabled: null == phoneLoginEnabled ? _self.phoneLoginEnabled : phoneLoginEnabled // ignore: cast_nullable_to_non_nullable
as bool,otpLength: null == otpLength ? _self.otpLength : otpLength // ignore: cast_nullable_to_non_nullable
as int,otpValiditySeconds: null == otpValiditySeconds ? _self.otpValiditySeconds : otpValiditySeconds // ignore: cast_nullable_to_non_nullable
as int,otpMaxAttempts: null == otpMaxAttempts ? _self.otpMaxAttempts : otpMaxAttempts // ignore: cast_nullable_to_non_nullable
as int,otpRequestsPerPhonePerDay: null == otpRequestsPerPhonePerDay ? _self.otpRequestsPerPhonePerDay : otpRequestsPerPhonePerDay // ignore: cast_nullable_to_non_nullable
as int,otpRequestsPerIpPerHour: null == otpRequestsPerIpPerHour ? _self.otpRequestsPerIpPerHour : otpRequestsPerIpPerHour // ignore: cast_nullable_to_non_nullable
as int,rulesVersion: null == rulesVersion ? _self.rulesVersion : rulesVersion // ignore: cast_nullable_to_non_nullable
as int,signupBonusCredits: null == signupBonusCredits ? _self.signupBonusCredits : signupBonusCredits // ignore: cast_nullable_to_non_nullable
as int,creditCostStartChat: null == creditCostStartChat ? _self.creditCostStartChat : creditCostStartChat // ignore: cast_nullable_to_non_nullable
as int,creditCostBookSpot: null == creditCostBookSpot ? _self.creditCostBookSpot : creditCostBookSpot // ignore: cast_nullable_to_non_nullable
as int,creditCostInstantRequest: null == creditCostInstantRequest ? _self.creditCostInstantRequest : creditCostInstantRequest // ignore: cast_nullable_to_non_nullable
as int,plans: null == plans ? _self._plans : plans // ignore: cast_nullable_to_non_nullable
as List<PlanConfig>,topUpPacks: null == topUpPacks ? _self._topUpPacks : topUpPacks // ignore: cast_nullable_to_non_nullable
as List<TopUpPack>,subscriptionPeriodDays: null == subscriptionPeriodDays ? _self.subscriptionPeriodDays : subscriptionPeriodDays // ignore: cast_nullable_to_non_nullable
as int,bookingDaysAhead: null == bookingDaysAhead ? _self.bookingDaysAhead : bookingDaysAhead // ignore: cast_nullable_to_non_nullable
as int,slotMinutesDefault: null == slotMinutesDefault ? _self.slotMinutesDefault : slotMinutesDefault // ignore: cast_nullable_to_non_nullable
as int,freeNowMaxHours: null == freeNowMaxHours ? _self.freeNowMaxHours : freeNowMaxHours // ignore: cast_nullable_to_non_nullable
as int,tonightStartHour: null == tonightStartHour ? _self.tonightStartHour : tonightStartHour // ignore: cast_nullable_to_non_nullable
as int,checkInWindowMinutesBefore: null == checkInWindowMinutesBefore ? _self.checkInWindowMinutesBefore : checkInWindowMinutesBefore // ignore: cast_nullable_to_non_nullable
as int,checkInWindowMinutesAfter: null == checkInWindowMinutesAfter ? _self.checkInWindowMinutesAfter : checkInWindowMinutesAfter // ignore: cast_nullable_to_non_nullable
as int,safetyCheckIntervalMinutes: null == safetyCheckIntervalMinutes ? _self.safetyCheckIntervalMinutes : safetyCheckIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,safetyMissedCheckInsToEscalate: null == safetyMissedCheckInsToEscalate ? _self.safetyMissedCheckInsToEscalate : safetyMissedCheckInsToEscalate // ignore: cast_nullable_to_non_nullable
as int,sosHoldSeconds: null == sosHoldSeconds ? _self.sosHoldSeconds : sosHoldSeconds // ignore: cast_nullable_to_non_nullable
as int,emergencyNumber: null == emergencyNumber ? _self.emergencyNumber : emergencyNumber // ignore: cast_nullable_to_non_nullable
as String,privacyPolicyUrl: null == privacyPolicyUrl ? _self.privacyPolicyUrl : privacyPolicyUrl // ignore: cast_nullable_to_non_nullable
as String,termsUrl: null == termsUrl ? _self.termsUrl : termsUrl // ignore: cast_nullable_to_non_nullable
as String,supportEmail: null == supportEmail ? _self.supportEmail : supportEmail // ignore: cast_nullable_to_non_nullable
as String,grievanceOfficerName: null == grievanceOfficerName ? _self.grievanceOfficerName : grievanceOfficerName // ignore: cast_nullable_to_non_nullable
as String,grievanceOfficerEmail: null == grievanceOfficerEmail ? _self.grievanceOfficerEmail : grievanceOfficerEmail // ignore: cast_nullable_to_non_nullable
as String,autoCompleteGraceMinutes: null == autoCompleteGraceMinutes ? _self.autoCompleteGraceMinutes : autoCompleteGraceMinutes // ignore: cast_nullable_to_non_nullable
as int,moderationStrikesForReport: null == moderationStrikesForReport ? _self.moderationStrikesForReport : moderationStrikesForReport // ignore: cast_nullable_to_non_nullable
as int,moderationStrikeWindowHours: null == moderationStrikeWindowHours ? _self.moderationStrikeWindowHours : moderationStrikeWindowHours // ignore: cast_nullable_to_non_nullable
as int,chatMessageMaxLength: null == chatMessageMaxLength ? _self.chatMessageMaxLength : chatMessageMaxLength // ignore: cast_nullable_to_non_nullable
as int,chatMessagesPageSize: null == chatMessagesPageSize ? _self.chatMessagesPageSize : chatMessagesPageSize // ignore: cast_nullable_to_non_nullable
as int,reportsPerDay: null == reportsPerDay ? _self.reportsPerDay : reportsPerDay // ignore: cast_nullable_to_non_nullable
as int,reportDetailsMaxLength: null == reportDetailsMaxLength ? _self.reportDetailsMaxLength : reportDetailsMaxLength // ignore: cast_nullable_to_non_nullable
as int,verificationSessionMinutes: null == verificationSessionMinutes ? _self.verificationSessionMinutes : verificationSessionMinutes // ignore: cast_nullable_to_non_nullable
as int,captureMaxDimension: null == captureMaxDimension ? _self.captureMaxDimension : captureMaxDimension // ignore: cast_nullable_to_non_nullable
as int,captureJpegQuality: null == captureJpegQuality ? _self.captureJpegQuality : captureJpegQuality // ignore: cast_nullable_to_non_nullable
as int,voiceIntroMaxSec: null == voiceIntroMaxSec ? _self.voiceIntroMaxSec : voiceIntroMaxSec // ignore: cast_nullable_to_non_nullable
as int,maxProfilePhotos: null == maxProfilePhotos ? _self.maxProfilePhotos : maxProfilePhotos // ignore: cast_nullable_to_non_nullable
as int,displayNameMaxLength: null == displayNameMaxLength ? _self.displayNameMaxLength : displayNameMaxLength // ignore: cast_nullable_to_non_nullable
as int,ageMinimum: null == ageMinimum ? _self.ageMinimum : ageMinimum // ignore: cast_nullable_to_non_nullable
as int,ageMaximum: null == ageMaximum ? _self.ageMaximum : ageMaximum // ignore: cast_nullable_to_non_nullable
as int,defaultAgeRangeMin: null == defaultAgeRangeMin ? _self.defaultAgeRangeMin : defaultAgeRangeMin // ignore: cast_nullable_to_non_nullable
as int,defaultAgeRangeMax: null == defaultAgeRangeMax ? _self.defaultAgeRangeMax : defaultAgeRangeMax // ignore: cast_nullable_to_non_nullable
as int,popularityHotThreshold: null == popularityHotThreshold ? _self.popularityHotThreshold : popularityHotThreshold // ignore: cast_nullable_to_non_nullable
as double,popularityBusyThreshold: null == popularityBusyThreshold ? _self.popularityBusyThreshold : popularityBusyThreshold // ignore: cast_nullable_to_non_nullable
as double,maxTextScale: null == maxTextScale ? _self.maxTextScale : maxTextScale // ignore: cast_nullable_to_non_nullable
as double,remoteConfigFetchTimeoutSeconds: null == remoteConfigFetchTimeoutSeconds ? _self.remoteConfigFetchTimeoutSeconds : remoteConfigFetchTimeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,remoteConfigMinimumFetchIntervalMinutes: null == remoteConfigMinimumFetchIntervalMinutes ? _self.remoteConfigMinimumFetchIntervalMinutes : remoteConfigMinimumFetchIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LaunchCityCopyWith<$Res> get launchCity {
  
  return $LaunchCityCopyWith<$Res>(_self.launchCity, (value) {
    return _then(_self.copyWith(launchCity: value));
  });
}
}


/// @nodoc
mixin _$LaunchCity {

 String get name; double get lat; double get lng; String get timezone;
/// Create a copy of LaunchCity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaunchCityCopyWith<LaunchCity> get copyWith => _$LaunchCityCopyWithImpl<LaunchCity>(this as LaunchCity, _$identity);

  /// Serializes this LaunchCity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LaunchCity&&(identical(other.name, name) || other.name == name)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,lat,lng,timezone);

@override
String toString() {
  return 'LaunchCity(name: $name, lat: $lat, lng: $lng, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class $LaunchCityCopyWith<$Res>  {
  factory $LaunchCityCopyWith(LaunchCity value, $Res Function(LaunchCity) _then) = _$LaunchCityCopyWithImpl;
@useResult
$Res call({
 String name, double lat, double lng, String timezone
});




}
/// @nodoc
class _$LaunchCityCopyWithImpl<$Res>
    implements $LaunchCityCopyWith<$Res> {
  _$LaunchCityCopyWithImpl(this._self, this._then);

  final LaunchCity _self;
  final $Res Function(LaunchCity) _then;

/// Create a copy of LaunchCity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? lat = null,Object? lng = null,Object? timezone = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LaunchCity].
extension LaunchCityPatterns on LaunchCity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LaunchCity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LaunchCity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LaunchCity value)  $default,){
final _that = this;
switch (_that) {
case _LaunchCity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LaunchCity value)?  $default,){
final _that = this;
switch (_that) {
case _LaunchCity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double lat,  double lng,  String timezone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LaunchCity() when $default != null:
return $default(_that.name,_that.lat,_that.lng,_that.timezone);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double lat,  double lng,  String timezone)  $default,) {final _that = this;
switch (_that) {
case _LaunchCity():
return $default(_that.name,_that.lat,_that.lng,_that.timezone);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double lat,  double lng,  String timezone)?  $default,) {final _that = this;
switch (_that) {
case _LaunchCity() when $default != null:
return $default(_that.name,_that.lat,_that.lng,_that.timezone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LaunchCity implements LaunchCity {
  const _LaunchCity({required this.name, required this.lat, required this.lng, required this.timezone});
  factory _LaunchCity.fromJson(Map<String, dynamic> json) => _$LaunchCityFromJson(json);

@override final  String name;
@override final  double lat;
@override final  double lng;
@override final  String timezone;

/// Create a copy of LaunchCity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LaunchCityCopyWith<_LaunchCity> get copyWith => __$LaunchCityCopyWithImpl<_LaunchCity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LaunchCityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LaunchCity&&(identical(other.name, name) || other.name == name)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,lat,lng,timezone);

@override
String toString() {
  return 'LaunchCity(name: $name, lat: $lat, lng: $lng, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class _$LaunchCityCopyWith<$Res> implements $LaunchCityCopyWith<$Res> {
  factory _$LaunchCityCopyWith(_LaunchCity value, $Res Function(_LaunchCity) _then) = __$LaunchCityCopyWithImpl;
@override @useResult
$Res call({
 String name, double lat, double lng, String timezone
});




}
/// @nodoc
class __$LaunchCityCopyWithImpl<$Res>
    implements _$LaunchCityCopyWith<$Res> {
  __$LaunchCityCopyWithImpl(this._self, this._then);

  final _LaunchCity _self;
  final $Res Function(_LaunchCity) _then;

/// Create a copy of LaunchCity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? lat = null,Object? lng = null,Object? timezone = null,}) {
  return _then(_LaunchCity(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PlanConfig {

 PlanTier get tier; String? get productId; int get monthlyCredits;
/// Create a copy of PlanConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanConfigCopyWith<PlanConfig> get copyWith => _$PlanConfigCopyWithImpl<PlanConfig>(this as PlanConfig, _$identity);

  /// Serializes this PlanConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanConfig&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.monthlyCredits, monthlyCredits) || other.monthlyCredits == monthlyCredits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,productId,monthlyCredits);

@override
String toString() {
  return 'PlanConfig(tier: $tier, productId: $productId, monthlyCredits: $monthlyCredits)';
}


}

/// @nodoc
abstract mixin class $PlanConfigCopyWith<$Res>  {
  factory $PlanConfigCopyWith(PlanConfig value, $Res Function(PlanConfig) _then) = _$PlanConfigCopyWithImpl;
@useResult
$Res call({
 PlanTier tier, String? productId, int monthlyCredits
});




}
/// @nodoc
class _$PlanConfigCopyWithImpl<$Res>
    implements $PlanConfigCopyWith<$Res> {
  _$PlanConfigCopyWithImpl(this._self, this._then);

  final PlanConfig _self;
  final $Res Function(PlanConfig) _then;

/// Create a copy of PlanConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tier = null,Object? productId = freezed,Object? monthlyCredits = null,}) {
  return _then(_self.copyWith(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as PlanTier,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,monthlyCredits: null == monthlyCredits ? _self.monthlyCredits : monthlyCredits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanConfig].
extension PlanConfigPatterns on PlanConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanConfig value)  $default,){
final _that = this;
switch (_that) {
case _PlanConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanConfig value)?  $default,){
final _that = this;
switch (_that) {
case _PlanConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlanTier tier,  String? productId,  int monthlyCredits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanConfig() when $default != null:
return $default(_that.tier,_that.productId,_that.monthlyCredits);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlanTier tier,  String? productId,  int monthlyCredits)  $default,) {final _that = this;
switch (_that) {
case _PlanConfig():
return $default(_that.tier,_that.productId,_that.monthlyCredits);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlanTier tier,  String? productId,  int monthlyCredits)?  $default,) {final _that = this;
switch (_that) {
case _PlanConfig() when $default != null:
return $default(_that.tier,_that.productId,_that.monthlyCredits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanConfig implements PlanConfig {
  const _PlanConfig({required this.tier, required this.productId, required this.monthlyCredits});
  factory _PlanConfig.fromJson(Map<String, dynamic> json) => _$PlanConfigFromJson(json);

@override final  PlanTier tier;
@override final  String? productId;
@override final  int monthlyCredits;

/// Create a copy of PlanConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanConfigCopyWith<_PlanConfig> get copyWith => __$PlanConfigCopyWithImpl<_PlanConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanConfig&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.monthlyCredits, monthlyCredits) || other.monthlyCredits == monthlyCredits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,productId,monthlyCredits);

@override
String toString() {
  return 'PlanConfig(tier: $tier, productId: $productId, monthlyCredits: $monthlyCredits)';
}


}

/// @nodoc
abstract mixin class _$PlanConfigCopyWith<$Res> implements $PlanConfigCopyWith<$Res> {
  factory _$PlanConfigCopyWith(_PlanConfig value, $Res Function(_PlanConfig) _then) = __$PlanConfigCopyWithImpl;
@override @useResult
$Res call({
 PlanTier tier, String? productId, int monthlyCredits
});




}
/// @nodoc
class __$PlanConfigCopyWithImpl<$Res>
    implements _$PlanConfigCopyWith<$Res> {
  __$PlanConfigCopyWithImpl(this._self, this._then);

  final _PlanConfig _self;
  final $Res Function(_PlanConfig) _then;

/// Create a copy of PlanConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tier = null,Object? productId = freezed,Object? monthlyCredits = null,}) {
  return _then(_PlanConfig(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as PlanTier,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,monthlyCredits: null == monthlyCredits ? _self.monthlyCredits : monthlyCredits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TopUpPack {

 String get productId; int get credits;
/// Create a copy of TopUpPack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopUpPackCopyWith<TopUpPack> get copyWith => _$TopUpPackCopyWithImpl<TopUpPack>(this as TopUpPack, _$identity);

  /// Serializes this TopUpPack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopUpPack&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.credits, credits) || other.credits == credits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,credits);

@override
String toString() {
  return 'TopUpPack(productId: $productId, credits: $credits)';
}


}

/// @nodoc
abstract mixin class $TopUpPackCopyWith<$Res>  {
  factory $TopUpPackCopyWith(TopUpPack value, $Res Function(TopUpPack) _then) = _$TopUpPackCopyWithImpl;
@useResult
$Res call({
 String productId, int credits
});




}
/// @nodoc
class _$TopUpPackCopyWithImpl<$Res>
    implements $TopUpPackCopyWith<$Res> {
  _$TopUpPackCopyWithImpl(this._self, this._then);

  final TopUpPack _self;
  final $Res Function(TopUpPack) _then;

/// Create a copy of TopUpPack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? credits = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,credits: null == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TopUpPack].
extension TopUpPackPatterns on TopUpPack {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopUpPack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopUpPack() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopUpPack value)  $default,){
final _that = this;
switch (_that) {
case _TopUpPack():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopUpPack value)?  $default,){
final _that = this;
switch (_that) {
case _TopUpPack() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  int credits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopUpPack() when $default != null:
return $default(_that.productId,_that.credits);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  int credits)  $default,) {final _that = this;
switch (_that) {
case _TopUpPack():
return $default(_that.productId,_that.credits);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  int credits)?  $default,) {final _that = this;
switch (_that) {
case _TopUpPack() when $default != null:
return $default(_that.productId,_that.credits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TopUpPack implements TopUpPack {
  const _TopUpPack({required this.productId, required this.credits});
  factory _TopUpPack.fromJson(Map<String, dynamic> json) => _$TopUpPackFromJson(json);

@override final  String productId;
@override final  int credits;

/// Create a copy of TopUpPack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopUpPackCopyWith<_TopUpPack> get copyWith => __$TopUpPackCopyWithImpl<_TopUpPack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TopUpPackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopUpPack&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.credits, credits) || other.credits == credits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,credits);

@override
String toString() {
  return 'TopUpPack(productId: $productId, credits: $credits)';
}


}

/// @nodoc
abstract mixin class _$TopUpPackCopyWith<$Res> implements $TopUpPackCopyWith<$Res> {
  factory _$TopUpPackCopyWith(_TopUpPack value, $Res Function(_TopUpPack) _then) = __$TopUpPackCopyWithImpl;
@override @useResult
$Res call({
 String productId, int credits
});




}
/// @nodoc
class __$TopUpPackCopyWithImpl<$Res>
    implements _$TopUpPackCopyWith<$Res> {
  __$TopUpPackCopyWithImpl(this._self, this._then);

  final _TopUpPack _self;
  final $Res Function(_TopUpPack) _then;

/// Create a copy of TopUpPack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? credits = null,}) {
  return _then(_TopUpPack(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,credits: null == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
