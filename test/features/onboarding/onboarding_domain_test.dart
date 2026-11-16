import 'package:findx/core/router/routes.dart';
import 'package:findx/core/utils/app_failure.dart';
import 'package:findx/features/onboarding/domain/account.dart';
import 'package:findx/features/onboarding/domain/onboarding_redirect.dart';
import 'package:findx/features/onboarding/domain/phone_number.dart';
import 'package:findx/features/onboarding/domain/session_stage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

const _user = AuthUser(uid: testUid, phoneNumber: testPhone);
const _failure = AppFailure(FailureKind.network);

AsyncValue<SessionStage> _derive({
  AsyncValue<AuthUser?> user = const AsyncData(_user),
  AsyncValue<Account?>? account,
  AsyncValue<bool> prefs = const AsyncData(false),
}) => deriveSessionStage(user: user, account: (_) => account ?? AsyncData(testAccount()), hasPreferences: (_) => prefs);

void main() {
  group('deriveSessionStage', () {
    test('loading until the auth state is known', () {
      expect(_derive(user: const AsyncLoading()), isA<AsyncLoading<SessionStage>>());
    });

    test('signed out', () {
      expect(_derive(user: const AsyncData(null)).value, isA<SignedOut>());
    });

    test('signed in without an account needs the account created', () {
      expect(_derive(account: const AsyncData(null)).value, isA<NeedsAccount>());
    });

    test('waits for the account doc', () {
      expect(_derive(account: const AsyncLoading()), isA<AsyncLoading<SessionStage>>());
    });

    test('unverified accounts go to verification', () {
      expect(_derive().value, isA<NeedsVerification>());
    });

    test('suspended and banned accounts are stopped before anything else', () {
      for (final status in [AccountStatus.suspended, AccountStatus.banned]) {
        final stage = _derive(account: AsyncData(testAccount(accountStatus: status))).value;
        expect(stage, isA<Suspended>());
      }
    });

    test('verified without preferences, then ready', () {
      expect(_derive(account: AsyncData(verifiedAccount)).value, isA<NeedsPreferences>());
      expect(_derive(account: AsyncData(verifiedAccount), prefs: const AsyncData(true)).value, isA<Ready>());
    });

    test('passes errors through', () {
      expect(_derive(user: const AsyncError(_failure, StackTrace.empty)).hasError, isTrue);
      expect(_derive(account: const AsyncError(_failure, StackTrace.empty)).hasError, isTrue);
      expect(
        _derive(account: AsyncData(verifiedAccount), prefs: const AsyncError(_failure, StackTrace.empty)).hasError,
        isTrue,
      );
    });
  });

  group('onboardingRedirect', () {
    String? redirect(SessionStage stage, String location, {bool consent = false}) =>
        onboardingRedirect(stage: AsyncData(stage), consentGiven: consent, location: location);

    test('signed out without consent goes to the rules', () {
      expect(redirect(const SignedOut(), AppRoutes.start), AppRoutes.rules);
      expect(redirect(const SignedOut(), AppRoutes.verify), AppRoutes.rules);
      expect(redirect(const SignedOut(), AppRoutes.rules), isNull);
    });

    test('signed out with consent goes to verification', () {
      expect(redirect(const SignedOut(), AppRoutes.rules, consent: true), AppRoutes.verify);
      expect(redirect(const SignedOut(), AppRoutes.verify, consent: true), isNull);
    });

    test('no account yet: rules first unless consent was given on this device', () {
      expect(redirect(const NeedsAccount(_user), AppRoutes.verify), AppRoutes.rules);
      expect(redirect(const NeedsAccount(_user), AppRoutes.rules, consent: true), AppRoutes.verify);
    });

    test('verification, suspension and preferences each own one screen', () {
      expect(redirect(NeedsVerification(testAccount()), AppRoutes.home), AppRoutes.verify);
      expect(redirect(Suspended(testAccount()), AppRoutes.verify), AppRoutes.suspended);
      expect(redirect(NeedsPreferences(verifiedAccount), AppRoutes.verify), AppRoutes.preferences);
    });

    test('ready leaves onboarding for home but allows other screens', () {
      for (final location in [AppRoutes.start, AppRoutes.rules, AppRoutes.verify, AppRoutes.preferences]) {
        expect(redirect(Ready(verifiedAccount), location), AppRoutes.home);
      }
      expect(redirect(Ready(verifiedAccount), AppRoutes.home), isNull);
    });

    test('while loading, nobody is moved', () {
      expect(onboardingRedirect(stage: const AsyncLoading(), consentGiven: false, location: AppRoutes.rules), isNull);
    });

    test('a session error goes back to the start screen, which shows it', () {
      const stage = AsyncError<SessionStage>(_failure, StackTrace.empty);
      expect(onboardingRedirect(stage: stage, consentGiven: false, location: AppRoutes.verify), AppRoutes.start);
      expect(onboardingRedirect(stage: stage, consentGiven: false, location: AppRoutes.start), isNull);
    });

    test('the developer gallery is never redirected', () {
      expect(redirect(const SignedOut(), AppRoutes.devComponents), isNull);
    });
  });

  group('phone numbers', () {
    String? normalize(String raw) => normalizePhoneNumber(raw, countryCode: '+91', nationalLength: 10);

    test('accepts common ways of typing an Indian mobile number', () {
      for (final raw in ['9876543210', '98765 43210', '098765-43210', '+91 98765 43210', '919876543210']) {
        expect(normalize(raw), '+919876543210', reason: raw);
      }
    });

    test('rejects wrong lengths, letters and leading zeros', () {
      for (final raw in ['', '12345', '98765432101', 'abcdefghij', '0000000000', '+1 9876543210']) {
        expect(normalize(raw), isNull, reason: raw);
      }
    });

    test('formats for display', () {
      expect(formatPhoneNumber('+919876543210', countryCode: '+91'), '+91 98765 43210');
    });

    test('one-time codes have exactly the configured number of digits', () {
      expect(isValidOtp('1234', length: 4), isTrue);
      expect(isValidOtp(' 1234 ', length: 4), isTrue);
      expect(isValidOtp('123', length: 4), isFalse);
      expect(isValidOtp('12345', length: 4), isFalse);
      expect(isValidOtp('12a4', length: 4), isFalse);
    });
  });
}
