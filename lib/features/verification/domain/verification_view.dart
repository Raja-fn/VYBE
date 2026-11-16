import '../../../core/services/identity_verification/identity_verification_service.dart';
import '../../../core/widgets/content_rows.dart';
import '../../onboarding/domain/account.dart';
import '../../onboarding/domain/session_stage.dart';

/// What the verification screen shows below the steps card.
enum VerificationView {
  /// Signed out: Continue with Google (and the phone form when phone login is on).
  signIn,
  enterCode,

  /// Phone verified; the account still has to be created.
  finishAccount,
  selfie,
  document,
  inReview,
  rejected,
  underage,
}

/// Picks the view from the session stage and whether a code was sent.
/// Pure, so every combination is unit-tested.
VerificationView verificationViewFor(SessionStage stage, {required bool codeSent}) {
  return switch (stage) {
    SignedOut() => codeSent ? VerificationView.enterCode : VerificationView.signIn,
    NeedsAccount() => VerificationView.finishAccount,
    NeedsVerification(:final account) => _viewForAccount(account),
    // Other stages are redirected away; show the review state meanwhile.
    _ => VerificationView.inReview,
  };
}

VerificationView _viewForAccount(Account account) {
  if (account.isUnderage) return VerificationView.underage;
  final steps = account.verificationSteps;
  final step = steps.selfie == StepStatus.approved ? steps.id : steps.selfie;
  final isSelfie = steps.selfie != StepStatus.approved;
  return switch (step) {
    StepStatus.inReview => VerificationView.inReview,
    StepStatus.rejected => VerificationView.rejected,
    StepStatus.notStarted || StepStatus.approved => isSelfie ? VerificationView.selfie : VerificationView.document,
  };
}

/// The capture step that is due next (for "Take photo" and "Try again").
IdvStep currentCaptureStep(Account account) =>
    account.verificationSteps.selfie == StepStatus.approved ? IdvStep.governmentId : IdvStep.selfie;

/// State of the phone, selfie and ID rows in the steps card.
({AppStepState phone, AppStepState selfie, AppStepState id}) stepStates(SessionStage stage) {
  return switch (stage) {
    SignedOut() => (phone: AppStepState.current, selfie: AppStepState.upcoming, id: AppStepState.upcoming),
    NeedsAccount() => (phone: AppStepState.done, selfie: AppStepState.upcoming, id: AppStepState.upcoming),
    NeedsVerification(:final account) => _accountStepStates(account.verificationSteps),
    _ => (phone: AppStepState.done, selfie: AppStepState.done, id: AppStepState.done),
  };
}

({AppStepState phone, AppStepState selfie, AppStepState id}) _accountStepStates(VerificationSteps steps) {
  final selfieDone = steps.selfie == StepStatus.approved;
  return (
    phone: AppStepState.done,
    selfie: selfieDone ? AppStepState.done : AppStepState.current,
    id: steps.id == StepStatus.approved
        ? AppStepState.done
        : selfieDone
        ? AppStepState.current
        : AppStepState.upcoming,
  );
}
