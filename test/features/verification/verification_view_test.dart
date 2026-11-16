import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/services/identity_verification/identity_verification_service.dart';
import 'package:vybe/core/widgets/content_rows.dart';
import 'package:vybe/features/onboarding/domain/account.dart';
import 'package:vybe/features/onboarding/domain/session_stage.dart';
import 'package:vybe/features/verification/domain/verification_view.dart';

import '../../helpers/fakes.dart';

const _user = AuthUser(uid: testUid);

VerificationView _view(Account account) => verificationViewFor(NeedsVerification(account), codeSent: false);

void main() {
  test('phone, then code, then finishing the account', () {
    expect(verificationViewFor(const SignedOut(), codeSent: false), VerificationView.signIn);
    expect(verificationViewFor(const SignedOut(), codeSent: true), VerificationView.enterCode);
    expect(verificationViewFor(const NeedsAccount(_user), codeSent: true), VerificationView.finishAccount);
  });

  test('selfie first, then ID', () {
    expect(_view(testAccount()), VerificationView.selfie);
    expect(_view(testAccount(selfie: StepStatus.approved)), VerificationView.document);
  });

  test('in review and rejected apply to whichever step is due', () {
    expect(_view(testAccount(selfie: StepStatus.inReview)), VerificationView.inReview);
    expect(_view(testAccount(selfie: StepStatus.rejected)), VerificationView.rejected);
    expect(_view(testAccount(selfie: StepStatus.approved, id: StepStatus.inReview)), VerificationView.inReview);
    expect(_view(testAccount(selfie: StepStatus.approved, id: StepStatus.rejected)), VerificationView.rejected);
  });

  test('under 18 is final', () {
    final account = testAccount(
      selfie: StepStatus.approved,
      id: StepStatus.rejected,
      status: VerificationStatus.rejected,
      reason: underageReason,
    );
    expect(_view(account), VerificationView.underage);
  });

  test('the next capture step follows the selfie result', () {
    expect(currentCaptureStep(testAccount()), IdvStep.selfie);
    expect(currentCaptureStep(testAccount(selfie: StepStatus.rejected)), IdvStep.selfie);
    expect(currentCaptureStep(testAccount(selfie: StepStatus.approved)), IdvStep.governmentId);
  });

  test('steps card states', () {
    expect(stepStates(const SignedOut()), (
      phone: AppStepState.current,
      selfie: AppStepState.upcoming,
      id: AppStepState.upcoming,
    ));
    expect(stepStates(const NeedsAccount(_user)).phone, AppStepState.done);
    expect(stepStates(NeedsVerification(testAccount())), (
      phone: AppStepState.done,
      selfie: AppStepState.current,
      id: AppStepState.upcoming,
    ));
    expect(stepStates(NeedsVerification(testAccount(selfie: StepStatus.approved))), (
      phone: AppStepState.done,
      selfie: AppStepState.done,
      id: AppStepState.current,
    ));
  });
}
