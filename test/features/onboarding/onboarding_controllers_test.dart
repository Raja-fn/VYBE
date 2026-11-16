import 'package:findx/app.dart';
import 'package:findx/core/services/identity_verification/identity_verification_service.dart';
import 'package:findx/core/services/image_capture/image_capture_service.dart';
import 'package:findx/core/utils/app_failure.dart';
import 'package:findx/core/utils/clock.dart';
import 'package:findx/features/onboarding/domain/account.dart';
import 'package:findx/features/onboarding/domain/session_stage.dart';
import 'package:findx/features/onboarding/presentation/rules_controller.dart';
import 'package:findx/features/onboarding/presentation/session_providers.dart';
import 'package:findx/features/preferences/domain/preferences.dart';
import 'package:findx/features/preferences/presentation/preferences_controller.dart';
import 'package:findx/features/verification/presentation/verification_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

final _now = DateTime.utc(2026, 11, 10, 10);

ProviderContainer _container(TestBackend backend) {
  final container = ProviderContainer(
    retry: noAutomaticRetry,
    overrides: [
      ...baseOverrides(backend: backend),
      clockProvider.overrideWithValue(FixedClock(_now)),
    ],
  );
  addTearDown(container.dispose);
  container
    ..listen(sessionStageProvider, (_, _) {})
    ..listen(verificationControllerProvider, (_, _) {})
    ..listen(preferencesControllerProvider, (_, _) {})
    ..listen(rulesControllerProvider, (_, _) {});
  return container;
}

Future<void> _flush() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('RulesController', () {
    test('before sign-in it only remembers consent', () async {
      final backend = TestBackend();
      final container = _container(backend);
      await _flush();
      await container.read(rulesControllerProvider.notifier).accept();
      expect(container.read(consentGivenProvider), isTrue);
      expect(backend.accounts.acceptedVersions, isEmpty);
    });

    test('after sign-in it creates the account with the current rules version', () async {
      final backend = TestBackend(
        auth: FakeAuthRepository(signedIn: const AuthUser(uid: testUid)),
      );
      final container = _container(backend);
      await _flush();
      expect(container.read(sessionStageProvider).value, isA<NeedsAccount>());
      await container.read(rulesControllerProvider.notifier).accept();
      expect(backend.accounts.acceptedVersions, [1]);
    });

    test('surfaces a server failure', () async {
      final backend = TestBackend(
        auth: FakeAuthRepository(signedIn: const AuthUser(uid: testUid)),
      )..accounts.acceptFailure = const AppFailure(FailureKind.network);
      final container = _container(backend);
      await _flush();
      await container.read(rulesControllerProvider.notifier).accept();
      expect(container.read(rulesControllerProvider).error, const AppFailure(FailureKind.network));
    });
  });

  group('VerificationController', () {
    test('rejects an invalid number without calling the server', () async {
      final backend = TestBackend();
      final container = _container(backend);
      await container.read(verificationControllerProvider.notifier).sendCode('12345');
      expect(container.read(verificationControllerProvider).phoneInvalid, isTrue);
      expect(backend.auth.otpRequests, isEmpty);
    });

    test('sends a code to the normalised number and starts the resend timer', () async {
      final backend = TestBackend();
      final container = _container(backend);
      await container.read(verificationControllerProvider.notifier).sendCode('98765 43210');
      final state = container.read(verificationControllerProvider);
      expect(backend.auth.otpRequests, ['+919876543210']);
      expect(state.codeSent, isTrue);
      expect(state.codeSentAt, _now);
      expect(state.resendToken, 7);
    });

    test('resend reuses the number', () async {
      final backend = TestBackend();
      final container = _container(backend);
      final controller = container.read(verificationControllerProvider.notifier);
      await controller.sendCode('9876543210');
      await controller.resendCode();
      expect(backend.auth.otpRequests, ['+919876543210', '+919876543210']);
    });

    test('a wrong code shows a failure; the right one signs in and creates the account', () async {
      final backend = TestBackend();
      final container = _container(backend);
      final controller = container.read(verificationControllerProvider.notifier);
      await controller.sendCode('9876543210');

      await controller.confirmCode('12');
      expect(container.read(verificationControllerProvider).codeInvalid, isTrue);

      await controller.confirmCode('0000');
      expect(container.read(verificationControllerProvider).failure?.kind, FailureKind.wrongCode);

      await controller.confirmCode(validOtp);
      await _flush();
      expect(backend.accounts.acceptedVersions, [1]);
      expect(container.read(sessionStageProvider).value, isA<NeedsVerification>());
    });

    test('a failed code request is shown', () async {
      final backend = TestBackend()..auth.requestOtpFailure = const AppFailure(FailureKind.rateLimited);
      final container = _container(backend);
      await container.read(verificationControllerProvider.notifier).sendCode('9876543210');
      expect(container.read(verificationControllerProvider).failure?.kind, FailureKind.rateLimited);
      expect(container.read(verificationControllerProvider).busy, isFalse);
    });

    test('selfie then ID approves the account and refreshes claims', () async {
      final backend = TestBackend(
        auth: FakeAuthRepository(signedIn: const AuthUser(uid: testUid)),
        accounts: FakeAccountRepository(initial: testAccount()),
      );
      final container = _container(backend);
      await _flush();
      final controller = container.read(verificationControllerProvider.notifier);

      await controller.captureAndSubmit();
      await _flush();
      expect(backend.capture.captures, [CaptureKind.selfie]);
      expect(backend.accounts.account.value!.verificationSteps.selfie, StepStatus.approved);

      // The ID step needs a document type first.
      await controller.captureAndSubmit();
      expect(backend.capture.captures, hasLength(1));

      controller.chooseDocument(IdDocumentType.passport);
      await controller.captureAndSubmit();
      await _flush();
      expect(backend.capture.captures, [CaptureKind.selfie, CaptureKind.document]);
      expect(backend.identity.started.last, (IdvStep.governmentId, IdDocumentType.passport));
      expect(backend.accounts.account.value!.isVerified, isTrue);
      expect(backend.auth.refreshClaimsCalls, 1);
      expect(container.read(sessionStageProvider).value, isA<NeedsPreferences>());
    });

    test('closing the camera does nothing', () async {
      final backend = TestBackend(
        auth: FakeAuthRepository(signedIn: const AuthUser(uid: testUid)),
        accounts: FakeAccountRepository(initial: testAccount()),
      )..capture.next = null;
      final container = _container(backend);
      await _flush();
      await container.read(verificationControllerProvider.notifier).captureAndSubmit();
      expect(backend.identity.started, isEmpty);
      expect(container.read(verificationControllerProvider).failure, isNull);
      expect(container.read(verificationControllerProvider).busy, isFalse);
    });

    test('a rejected selfie can be retried', () async {
      final backend = TestBackend(
        auth: FakeAuthRepository(signedIn: const AuthUser(uid: testUid)),
        accounts: FakeAccountRepository(initial: testAccount()),
      )..identity.nextStatus = IdvStatus.rejected;
      final container = _container(backend);
      await _flush();
      final controller = container.read(verificationControllerProvider.notifier);
      await controller.captureAndSubmit();
      await _flush();
      expect(backend.accounts.account.value!.verificationSteps.selfie, StepStatus.rejected);

      backend.identity.nextStatus = IdvStatus.approved;
      await controller.captureAndSubmit();
      await _flush();
      expect(backend.identity.started.map((s) => s.$1), [IdvStep.selfie, IdvStep.selfie]);
      expect(backend.accounts.account.value!.verificationSteps.selfie, StepStatus.approved);
    });

    test('an upload failure is shown and nothing changes', () async {
      final backend = TestBackend(
        auth: FakeAuthRepository(signedIn: const AuthUser(uid: testUid)),
        accounts: FakeAccountRepository(initial: testAccount()),
      )..identity.failure = const AppFailure(FailureKind.network);
      final container = _container(backend);
      await _flush();
      await container.read(verificationControllerProvider.notifier).captureAndSubmit();
      expect(container.read(verificationControllerProvider).failure?.kind, FailureKind.network);
      expect(backend.accounts.account.value!.verificationSteps.selfie, StepStatus.notStarted);
    });

    test('sign out clears consent and local state', () async {
      final backend = TestBackend(
        auth: FakeAuthRepository(signedIn: const AuthUser(uid: testUid)),
      );
      final container = _container(backend);
      container.read(consentGivenProvider.notifier).give();
      await container.read(verificationControllerProvider.notifier).signOut();
      await _flush();
      expect(container.read(consentGivenProvider), isFalse);
      expect(container.read(sessionStageProvider).value, isA<SignedOut>());
    });
  });

  group('PreferencesController', () {
    TestBackend verifiedBackend() => TestBackend(
      auth: FakeAuthRepository(signedIn: const AuthUser(uid: testUid)),
      accounts: FakeAccountRepository(initial: verifiedAccount),
    );

    test('starts from the AppConfig default age range', () {
      final container = _container(verifiedBackend());
      final draft = container.read(preferencesControllerProvider);
      expect((draft.ageMin, draft.ageMax), (21, 35));
      expect(draft.showMe, ShowMe.everyone);
      expect(draft.showGender, isFalse);
      expect(draft.canSave, isFalse);
    });

    test('keeps the age range inside the allowed limits', () {
      final container = _container(verifiedBackend());
      final controller = container.read(preferencesControllerProvider.notifier)..setAgeRange(10, 99);
      expect(container.read(preferencesControllerProvider).ageMin, 18);
      expect(container.read(preferencesControllerProvider).ageMax, 60);
      controller.setAgeRange(40, 30);
      expect(container.read(preferencesControllerProvider).ageMax, 40);
    });

    test('saves with "Who can request you" defaulting to everyone', () async {
      final backend = verifiedBackend();
      final container = _container(backend);
      await _flush();
      container.read(preferencesControllerProvider.notifier)
        ..setGender(Gender.undisclosed)
        ..setShowMe(ShowMe.women)
        ..setShowGender(true);
      await container.read(preferencesControllerProvider.notifier).save();
      await _flush();
      expect(
        backend.preferences.saved.single,
        const Preferences(
          gender: Gender.undisclosed,
          showMe: ShowMe.women,
          ageMin: 21,
          ageMax: 35,
          showGender: true,
          whoCanRequest: WhoCanRequest.everyone,
        ),
      );
      expect(container.read(sessionStageProvider).value, isA<Ready>());
    });

    test('a save failure is shown', () async {
      final backend = verifiedBackend()..preferences.saveFailure = const AppFailure(FailureKind.permissionDenied);
      final container = _container(backend);
      await _flush();
      container.read(preferencesControllerProvider.notifier).setGender(Gender.woman);
      await container.read(preferencesControllerProvider.notifier).save();
      expect(container.read(preferencesControllerProvider).failure?.kind, FailureKind.permissionDenied);
      expect(container.read(preferencesControllerProvider).saving, isFalse);
    });
  });
}
