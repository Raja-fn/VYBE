import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/config/app_config.dart';
import 'package:vybe/core/services/identity_verification/identity_verification_service.dart';
import 'package:vybe/core/utils/app_failure.dart';
import 'package:vybe/features/discover/presentation/discover_screen.dart';
import 'package:vybe/features/onboarding/domain/account.dart';
import 'package:vybe/features/onboarding/domain/session_stage.dart';
import 'package:vybe/features/onboarding/presentation/rules_screen.dart';
import 'package:vybe/features/onboarding/presentation/status_screens.dart';
import 'package:vybe/features/preferences/domain/preferences.dart';
import 'package:vybe/features/preferences/presentation/preferences_screen.dart';
import 'package:vybe/features/verification/presentation/verification_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

const _signedIn = AuthUser(uid: testUid, phoneNumber: testPhone);

TestBackend _verifying(Account account) => TestBackend(
  auth: FakeAuthRepository(signedIn: _signedIn),
  accounts: FakeAccountRepository(initial: account),
);

TestBackend _needsPreferences() => TestBackend(
  auth: FakeAuthRepository(signedIn: _signedIn),
  accounts: FakeAccountRepository(initial: verifiedAccount),
);

FilledButton _primary(WidgetTester tester) => tester.widget<FilledButton>(find.byType(FilledButton).last);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.last);
  await tester.pump();
  await tester.tap(finder.last);
  await settle(tester);
}

Future<void> _tapText(WidgetTester tester, String text) => _tap(tester, find.text(text));

/// Types a date of birth (MM/DD/YYYY in English) into the date picker.
Future<void> _enterBirthDate(WidgetTester tester, String date) async {
  await _tapText(tester, 'Your date of birth');
  await tester.enterText(find.byType(TextField).last, date);
  await _tapText(tester, 'OK');
}

/// Phone OTP login switched on (it is off by default for now).
AppConfig _phoneOn() => loadTestConfig().copyWith(phoneLoginEnabled: true);

void main() {
  group('Rules screen', () {
    testWidgets('shows both lists and needs a date of birth and consent before continuing', (tester) async {
      await pumpInApp(tester, const RulesScreen(), wrapInScaffold: false);
      expect(find.text('THIS APP IS FOR'), findsOneWidget);
      expect(find.text('NOT FOR'), findsOneWidget);
      expect(find.text('Sexual services or any kind of solicitation'), findsOneWidget);
      expect(find.text('Terms'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(_primary(tester).onPressed, isNull);

      await _tapText(tester, 'I am 18 or older and I agree to these rules. Breaking them means a permanent ban.');
      expect(_primary(tester).onPressed, isNull);
      await _enterBirthDate(tester, '01/15/2000');
      expect(_primary(tester).onPressed, isNotNull);
    });

    testWidgets('under 18 cannot continue', (tester) async {
      await pumpInApp(tester, const RulesScreen(), wrapInScaffold: false);
      final now = DateTime.now();
      final sixteen = '${now.month.toString().padLeft(2, '0')}/01/${now.year - 16}';
      await _enterBirthDate(tester, sixteen);
      await _tapText(tester, 'I am 18 or older and I agree to these rules. Breaking them means a permanent ban.');
      expect(find.text('VYBE is only for people aged 18 or older.'), findsOneWidget);
      expect(_primary(tester).onPressed, isNull);
    });

    testWidgets('shows a server failure when recording consent fails', (tester) async {
      final backend = TestBackend(auth: FakeAuthRepository(signedIn: _signedIn))
        ..accounts.acceptFailure = const AppFailure(FailureKind.network);
      await pumpInApp(tester, const RulesScreen(), wrapInScaffold: false, backend: backend);
      await settle(tester);
      await _enterBirthDate(tester, '01/15/2000');
      await _tap(tester, find.byType(Checkbox));
      await _tapText(tester, 'I agree, continue');
      expect(find.text('We could not reach VYBE. Check your connection and try again.'), findsOneWidget);
    });
  });

  group('Verification screen', () {
    testWidgets('signs in with Google, then moves on to the selfie', (tester) async {
      final backend = TestBackend();
      await pumpInApp(tester, const VerificationScreen(), wrapInScaffold: false, backend: backend);
      expect(find.text('STEP 2 OF 3'), findsOneWidget);
      expect(find.text('With your Google account'), findsOneWidget);
      expect(find.text('Send code'), findsNothing);
      await _tapText(tester, 'Continue with Google');
      expect(backend.accounts.acceptedVersions, [1]);
      expect(find.bySemanticsLabel('Fit your face in the frame'), findsOneWidget);
      expect(find.text('Signed in'), findsOneWidget);
    });

    testWidgets('closing the Google picker shows nothing', (tester) async {
      final backend = TestBackend()..auth.googleFailure = const AppFailure(FailureKind.signInCanceled);
      await pumpInApp(tester, const VerificationScreen(), wrapInScaffold: false, backend: backend);
      await _tapText(tester, 'Continue with Google');
      expect(find.text('Sign-in was cancelled.'), findsNothing);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('Google not set up on this build is explained', (tester) async {
      final backend = TestBackend()..auth.googleFailure = const AppFailure(FailureKind.googleSignInUnavailable);
      await pumpInApp(tester, const VerificationScreen(), wrapInScaffold: false, backend: backend);
      await _tapText(tester, 'Continue with Google');
      expect(find.textContaining('Google sign-in is not set up on this build yet.'), findsOneWidget);
    });

    testWidgets('phone login (when switched on) validates the number, then asks for the code', (tester) async {
      await pumpInApp(tester, const VerificationScreen(), wrapInScaffold: false, config: _phoneOn());
      expect(find.text('With Google or your phone number'), findsOneWidget);
      expect(find.text('STEP 2 OF 3'), findsOneWidget);
      expect(find.text('Verify it is you'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '12345');
      await _tapText(tester, 'Send code');
      expect(find.text('Enter a valid 10-digit mobile number.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '98765 43210');
      await _tapText(tester, 'Send code');
      expect(find.text('We sent a code to +91 98765 43210.'), findsOneWidget);
      expect(find.textContaining('Resend code in'), findsOneWidget);
    });

    testWidgets('phone login: a wrong code is explained, the right one moves on to the selfie', (tester) async {
      final backend = TestBackend();
      await pumpInApp(tester, const VerificationScreen(), wrapInScaffold: false, backend: backend, config: _phoneOn());
      await tester.enterText(find.byType(TextField), '9876543210');
      await _tapText(tester, 'Send code');

      await tester.enterText(find.byType(TextField), '0000');
      await _tapText(tester, 'Verify code');
      expect(find.text('That code is not right. Check the SMS and try again.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), validOtp);
      await _tapText(tester, 'Verify code');
      expect(find.bySemanticsLabel('Fit your face in the frame'), findsOneWidget);
      expect(find.text('Signed in'), findsOneWidget);
    });

    testWidgets('selfie, then the ID needs a document type', (tester) async {
      await pumpInApp(tester, const VerificationScreen(), wrapInScaffold: false, backend: _verifying(testAccount()));
      await settle(tester);
      expect(find.text('Your ID is encrypted and is never shown to other users.'), findsOneWidget);

      await _tapText(tester, 'Take selfie');
      expect(find.text('WHICH ID WILL YOU USE?'), findsOneWidget);
      expect(_primary(tester).onPressed, isNull);

      await _tapText(tester, 'Aadhaar');
      expect(_primary(tester).onPressed, isNotNull);
    });

    testWidgets('a rejected photo offers a retry', (tester) async {
      await pumpInApp(
        tester,
        const VerificationScreen(),
        wrapInScaffold: false,
        backend: _verifying(testAccount(selfie: StepStatus.rejected)),
      );
      await settle(tester);
      expect(find.text('We could not verify this photo'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('in review lets the person leave', (tester) async {
      await pumpInApp(
        tester,
        const VerificationScreen(),
        wrapInScaffold: false,
        backend: _verifying(testAccount(selfie: StepStatus.inReview)),
      );
      await settle(tester);
      expect(find.text('A person is checking your photos'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('under 18 is explained and final', (tester) async {
      await pumpInApp(
        tester,
        const VerificationScreen(),
        wrapInScaffold: false,
        backend: _verifying(
          testAccount(
            selfie: StepStatus.approved,
            id: StepStatus.rejected,
            status: VerificationStatus.rejected,
            reason: underageReason,
          ),
        ),
      );
      await settle(tester);
      expect(find.text('VYBE is for adults only'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('shows an upload failure', (tester) async {
      final backend = _verifying(testAccount())..identity.failure = const AppFailure(FailureKind.network);
      await pumpInApp(tester, const VerificationScreen(), wrapInScaffold: false, backend: backend);
      await settle(tester);
      await _tapText(tester, 'Take selfie');
      expect(find.text('We could not reach VYBE. Check your connection and try again.'), findsOneWidget);
    });

    testWidgets('finishing the account after a restart', (tester) async {
      final backend = TestBackend(auth: FakeAuthRepository(signedIn: _signedIn));
      await pumpInApp(tester, const VerificationScreen(), wrapInScaffold: false, backend: backend);
      await settle(tester);
      expect(find.text('Finish setting up your account'), findsOneWidget);
      await _tapText(tester, 'Continue');
      expect(backend.accounts.acceptedVersions, [1]);
      expect(find.bySemanticsLabel('Fit your face in the frame'), findsOneWidget);
    });
  });

  group('Preferences screen', () {
    testWidgets('shows the defaults and needs "I am" before saving', (tester) async {
      await pumpInApp(tester, const PreferencesScreen(), wrapInScaffold: false, backend: _needsPreferences());
      await settle(tester);
      expect(find.text('STEP 3 OF 3'), findsOneWidget);
      expect(find.text('21 to 35'), findsOneWidget);
      expect(find.text('Within 5 km'), findsOneWidget);
      expect(find.text('Off by default. Only used to decide who sees you.'), findsOneWidget);
      expect(_primary(tester).onPressed, isNull);
    });

    testWidgets('saves the chosen preferences', (tester) async {
      final backend = _needsPreferences();
      await pumpInApp(tester, const PreferencesScreen(), wrapInScaffold: false, backend: backend);
      await settle(tester);
      await _tapText(tester, 'Non-binary');
      await _tapText(tester, 'Men');
      await _tapText(tester, 'Start exploring');
      expect(backend.preferences.saved.single.gender, Gender.nonBinary);
      expect(backend.preferences.saved.single.showMe, ShowMe.men);
    });

    testWidgets('shows a save failure', (tester) async {
      final backend = _needsPreferences()..preferences.saveFailure = const AppFailure(FailureKind.network);
      await pumpInApp(tester, const PreferencesScreen(), wrapInScaffold: false, backend: backend);
      await settle(tester);
      await _tapText(tester, 'Woman');
      await _tapText(tester, 'Start exploring');
      expect(find.text('We could not reach VYBE. Check your connection and try again.'), findsOneWidget);
    });
  });

  group('Status screens', () {
    testWidgets('suspended accounts can only sign out', (tester) async {
      final backend = TestBackend(auth: FakeAuthRepository(signedIn: _signedIn));
      await pumpInApp(tester, const SuspendedScreen(), wrapInScaffold: false, backend: backend);
      expect(find.text('Your account is suspended'), findsOneWidget);
      await _tapText(tester, 'Sign out');
      expect(backend.auth.user.value, isNull);
    });
  });

  testWidgets('full onboarding: rules, Google, selfie, ID, preferences, done', (tester) async {
    final backend = TestBackend();
    await pumpFullApp(tester, backend: backend);
    expect(find.byType(RulesScreen), findsOneWidget);

    await _enterBirthDate(tester, '01/15/2000');
    await _tap(tester, find.byType(Checkbox));
    await _tapText(tester, 'I agree, continue');
    expect(find.byType(VerificationScreen), findsOneWidget);

    await _tapText(tester, 'Continue with Google');
    await _tapText(tester, 'Take selfie');
    await _tapText(tester, 'Passport');
    await _tapText(tester, 'Take ID photo');
    expect(backend.identity.started.last, (IdvStep.governmentId, IdDocumentType.passport));
    expect(find.byType(PreferencesScreen), findsOneWidget);

    await _tapText(tester, 'Woman');
    await _tapText(tester, 'Start exploring');
    expect(find.byType(DiscoverScreen), findsOneWidget);
    expect(backend.auth.refreshClaimsCalls, 1);
  });

  group('text scale 1.3 on a small phone', () {
    final cases = <String, (Widget, TestBackend Function())>{
      'rules': (const RulesScreen(), TestBackend.new),
      'verification (phone)': (const VerificationScreen(), TestBackend.new),
      'verification (ID)': (const VerificationScreen(), () => _verifying(testAccount(selfie: StepStatus.approved))),
      'verification (under 18)': (
        const VerificationScreen(),
        () => _verifying(testAccount(selfie: StepStatus.approved, id: StepStatus.rejected, reason: underageReason)),
      ),
      'preferences': (const PreferencesScreen(), _needsPreferences),
      'suspended': (const SuspendedScreen(), TestBackend.new),
    };

    for (final entry in cases.entries) {
      testWidgets(entry.key, (tester) async {
        final (screen, backend) = entry.value;
        await pumpInApp(
          tester,
          screen,
          wrapInScaffold: false,
          textScale: 1.3,
          size: smallPhoneSize,
          backend: backend(),
        );
        await settle(tester);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
