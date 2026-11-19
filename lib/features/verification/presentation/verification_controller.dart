import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/push/push_notifications.dart';
import '../../../core/services/identity_verification/identity_verification_providers.dart';
import '../../../core/services/identity_verification/identity_verification_service.dart';
import '../../../core/services/image_capture/image_capture_service.dart';
import '../../../core/utils/app_failure.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/result.dart';
import '../../onboarding/data/auth_repository.dart';
import '../../onboarding/domain/phone_number.dart';
import '../../onboarding/domain/session_stage.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../domain/verification_view.dart';

part 'verification_controller.freezed.dart';
part 'verification_controller.g.dart';

/// Local state of the verification screen. Step results themselves live on
/// the server (the account doc) and arrive through the session stage.
@freezed
abstract class VerificationFlowState with _$VerificationFlowState {
  const factory VerificationFlowState({
    String? phoneE164,
    String? verificationId,
    int? resendToken,
    DateTime? codeSentAt,
    IdDocumentType? documentType,
    @Default(false) bool busy,
    @Default(false) bool phoneInvalid,
    @Default(false) bool codeInvalid,
    AppFailure? failure,
  }) = _VerificationFlowState;

  const VerificationFlowState._();

  bool get codeSent => verificationId != null;
}

@riverpod
class VerificationController extends _$VerificationController {
  @override
  VerificationFlowState build() => const VerificationFlowState();

  AppConfig get _config => ref.read(appConfigProvider);

  /// "Continue with Google". Closing the picker is not an error.
  Future<void> signInWithGoogle() => _signIn(() => ref.read(authRepositoryProvider).signInWithGoogle());

  /// Test builds: sign in as a shared test account.
  Future<void> signInWithTestAccount(String email) =>
      _signIn(() => ref.read(authRepositoryProvider).signInWithTestGoogleAccount(email));

  Future<void> _signIn(Future<Result<void>> Function() signIn) async {
    if (state.busy) return;
    state = state.copyWith(busy: true, failure: null);
    final result = await signIn();
    // Signing in moves the app on; this screen (and its controller) may be gone.
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        await createAccount();
      case Err(:final failure):
        state = state.copyWith(busy: false, failure: failure.kind == FailureKind.signInCanceled ? null : failure);
    }
  }

  Future<void> sendCode(String rawPhone) async {
    final phone = normalizePhoneNumber(
      rawPhone,
      countryCode: _config.phoneCountryCode,
      nationalLength: _config.phoneNationalNumberLength,
    );
    if (phone == null) {
      state = state.copyWith(phoneInvalid: true, failure: null);
      return;
    }
    state = state.copyWith(phoneE164: phone, phoneInvalid: false);
    await _requestCode(phone, resendToken: null);
  }

  Future<void> resendCode() async {
    final phone = state.phoneE164;
    if (phone == null) return;
    await _requestCode(phone, resendToken: state.resendToken);
  }

  Future<void> _requestCode(String phone, {required int? resendToken}) async {
    state = state.copyWith(busy: true, failure: null);
    final result = await ref.read(authRepositoryProvider).requestOtp(phone, resendToken: resendToken);
    if (!ref.mounted) return;
    switch (result) {
      case Ok(value: OtpCodeSent(:final verificationId, resendToken: final token)):
        state = state.copyWith(
          busy: false,
          verificationId: verificationId,
          resendToken: token,
          codeSentAt: ref.read(clockProvider).now(),
        );
      case Err(:final failure):
        state = state.copyWith(busy: false, failure: failure);
    }
  }

  void changeNumber() {
    state = const VerificationFlowState();
  }

  Future<void> confirmCode(String code) async {
    final verificationId = state.verificationId;
    if (verificationId == null) return;
    if (!isValidOtp(code, length: _config.otpLength)) {
      state = state.copyWith(codeInvalid: true, failure: null);
      return;
    }
    state = state.copyWith(busy: true, codeInvalid: false, failure: null);
    final result = await ref.read(authRepositoryProvider).confirmOtp(verificationId: verificationId, code: code);
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        await createAccount();
      case Err(:final failure):
        state = state.copyWith(busy: false, failure: failure);
    }
  }

  /// Records consent and creates the account. Called right after sign-in,
  /// and from the "Continue" button if the app was closed in between.
  Future<void> createAccount() async {
    final dateOfBirth = ref.read(signupBirthDateProvider);
    if (dateOfBirth == null) {
      // The app restarted after the rules screen: ask again (the router shows the rules).
      ref.read(consentGivenProvider.notifier).reset();
      return;
    }
    state = state.copyWith(busy: true, failure: null);
    final result = await ref
        .read(accountRepositoryProvider)
        .acceptRules(rulesVersion: _config.rulesVersion, dateOfBirth: dateOfBirth);
    // A new account moves the app on to the next step, which closes this screen.
    if (!ref.mounted) return;
    state = state.copyWith(busy: false, failure: result.failureOrNull);
  }

  void chooseDocument(IdDocumentType type) {
    state = state.copyWith(documentType: type, failure: null);
  }

  /// Takes the photo for whichever step is due, uploads it and asks the
  /// server to decide. The new step status arrives through the account doc.
  Future<void> captureAndSubmit() async {
    final stage = ref.read(sessionStageProvider).value;
    if (stage is! NeedsVerification) return;
    final step = currentCaptureStep(stage.account);
    final documentType = state.documentType;
    if (step == IdvStep.governmentId && documentType == null) return;

    state = state.copyWith(busy: true, failure: null);
    final captured = await ref
        .read(imageCaptureServiceProvider)
        .capture(step == IdvStep.selfie ? CaptureKind.selfie : CaptureKind.document);
    if (!ref.mounted) return;
    final bytes = captured.valueOrNull;
    if (captured is Err || bytes == null) {
      state = state.copyWith(busy: false, failure: captured.failureOrNull);
      return;
    }

    final service = ref.read(identityVerificationServiceProvider);
    final session = await service.startSession(step, documentType: documentType);
    if (!ref.mounted) return;
    final sessionValue = session.valueOrNull;
    if (sessionValue == null) {
      state = state.copyWith(busy: false, failure: session.failureOrNull);
      return;
    }

    final outcome = await service.submitCapture(session: sessionValue, imageBytes: bytes);
    if (outcome.valueOrNull?.accountApproved ?? false) {
      // The server just set the `verified` claim; pick it up now.
      await ref.read(authRepositoryProvider).refreshClaims();
    }
    // An approved account moves the app on, which closes this screen.
    if (!ref.mounted) return;
    state = state.copyWith(busy: false, failure: outcome.failureOrNull);
  }

  void clearFailure() {
    state = state.copyWith(failure: null);
  }

  Future<void> signOut() async {
    state = state.copyWith(busy: true);
    final consent = ref.read(consentGivenProvider.notifier);
    await ref.read(pushRegistrationProvider.notifier).unregister();
    await ref.read(authRepositoryProvider).signOut();
    consent.reset();
    if (!ref.mounted) return;
    state = const VerificationFlowState();
  }
}
