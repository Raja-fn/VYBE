// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerificationSteps _$VerificationStepsFromJson(Map<String, dynamic> json) =>
    _VerificationSteps(
      phone: $enumDecode(
        _$StepStatusEnumMap,
        json['phone'],
        unknownValue: StepStatus.notStarted,
      ),
      selfie: $enumDecode(
        _$StepStatusEnumMap,
        json['selfie'],
        unknownValue: StepStatus.notStarted,
      ),
      id: $enumDecode(
        _$StepStatusEnumMap,
        json['id'],
        unknownValue: StepStatus.notStarted,
      ),
    );

Map<String, dynamic> _$VerificationStepsToJson(_VerificationSteps instance) =>
    <String, dynamic>{
      'phone': _$StepStatusEnumMap[instance.phone]!,
      'selfie': _$StepStatusEnumMap[instance.selfie]!,
      'id': _$StepStatusEnumMap[instance.id]!,
    };

const _$StepStatusEnumMap = {
  StepStatus.notStarted: 'not_started',
  StepStatus.inReview: 'in_review',
  StepStatus.approved: 'approved',
  StepStatus.rejected: 'rejected',
};

_Account _$AccountFromJson(Map<String, dynamic> json) => _Account(
  uid: json['uid'] as String,
  accountType: $enumDecode(
    _$AccountTypeEnumMap,
    json['accountType'],
    unknownValue: AccountType.member,
  ),
  verificationStatus: $enumDecode(
    _$VerificationStatusEnumMap,
    json['verificationStatus'],
    unknownValue: VerificationStatus.pending,
  ),
  verificationSteps: VerificationSteps.fromJson(
    json['verificationSteps'] as Map<String, dynamic>,
  ),
  accountStatus: $enumDecode(
    _$AccountStatusEnumMap,
    json['accountStatus'],
    unknownValue: AccountStatus.active,
  ),
  verificationReason: json['verificationReason'] as String?,
  displayName: json['displayName'] as String?,
  ageYears: (json['ageYears'] as num?)?.toInt(),
  photoPaths:
      (json['photoPaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$AccountToJson(_Account instance) => <String, dynamic>{
  'uid': instance.uid,
  'accountType': _$AccountTypeEnumMap[instance.accountType]!,
  'verificationStatus':
      _$VerificationStatusEnumMap[instance.verificationStatus]!,
  'verificationSteps': instance.verificationSteps,
  'accountStatus': _$AccountStatusEnumMap[instance.accountStatus]!,
  'verificationReason': instance.verificationReason,
  'displayName': instance.displayName,
  'ageYears': instance.ageYears,
  'photoPaths': instance.photoPaths,
};

const _$AccountTypeEnumMap = {
  AccountType.member: 'member',
  AccountType.venuePartner: 'venue_partner',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.approved: 'approved',
  VerificationStatus.rejected: 'rejected',
};

const _$AccountStatusEnumMap = {
  AccountStatus.active: 'active',
  AccountStatus.suspended: 'suspended',
  AccountStatus.banned: 'banned',
};
