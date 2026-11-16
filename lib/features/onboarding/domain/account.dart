import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

enum StepStatus {
  @JsonValue('not_started')
  notStarted,
  @JsonValue('in_review')
  inReview,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
}

enum VerificationStatus { pending, approved, rejected }

enum AccountStatus { active, suspended, banned }

enum AccountType {
  member,
  @JsonValue('venue_partner')
  venuePartner,
}

/// Server reason code: the ID shows the person is under 18. Never retryable.
const underageReason = 'underage';

@freezed
abstract class VerificationSteps with _$VerificationSteps {
  const factory VerificationSteps({
    @JsonKey(unknownEnumValue: StepStatus.notStarted) required StepStatus phone,
    @JsonKey(unknownEnumValue: StepStatus.notStarted) required StepStatus selfie,
    @JsonKey(unknownEnumValue: StepStatus.notStarted) required StepStatus id,
  }) = _VerificationSteps;

  factory VerificationSteps.fromJson(Map<String, Object?> json) => _$VerificationStepsFromJson(json);
}

/// The signed-in person's own `users/{uid}` document.
@freezed
abstract class Account with _$Account {
  const factory Account({
    required String uid,
    @JsonKey(unknownEnumValue: AccountType.member) required AccountType accountType,
    @JsonKey(unknownEnumValue: VerificationStatus.pending) required VerificationStatus verificationStatus,
    required VerificationSteps verificationSteps,
    @JsonKey(unknownEnumValue: AccountStatus.active) required AccountStatus accountStatus,
    String? verificationReason,
    String? displayName,
    int? ageYears,

    /// Profile photos as storage paths (`photos/<uid>/<id>.jpg`), main first.
    @Default([]) List<String> photoPaths,
  }) = _Account;

  const Account._();

  factory Account.fromJson(Map<String, Object?> json) => _$AccountFromJson(json);

  bool get isVerified => verificationStatus == VerificationStatus.approved;
  bool get isSuspended => accountStatus != AccountStatus.active;
  bool get isUnderage => verificationReason == underageReason;
}
