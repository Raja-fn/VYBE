import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/app.dart';
import 'package:vybe/core/backend/backend_providers.dart';
import 'package:vybe/core/config/app_config.dart';
import 'package:vybe/core/config/app_env.dart';
import 'package:vybe/core/connectivity/connectivity_service.dart';
import 'package:vybe/core/l10n/l10n.dart';
import 'package:vybe/core/location/location_service.dart';
import 'package:vybe/core/services/identity_verification/identity_verification_providers.dart';
import 'package:vybe/core/services/image_capture/image_capture_service.dart';
import 'package:vybe/core/services/image_capture/photo_picker_service.dart';
import 'package:vybe/core/theme/app_theme.dart';
import 'package:vybe/features/booking/presentation/booking_providers.dart';
import 'package:vybe/features/chat/presentation/chat_providers.dart';
import 'package:vybe/features/credits/data/store_client.dart';
import 'package:vybe/features/credits/domain/credit_models.dart';
import 'package:vybe/features/credits/presentation/credits_providers.dart';
import 'package:vybe/features/discover/presentation/discover_providers.dart';
import 'package:vybe/features/onboarding/domain/session_stage.dart';
import 'package:vybe/features/onboarding/presentation/session_providers.dart';
import 'package:vybe/features/preferences/domain/preferences.dart';
import 'package:vybe/features/preferences/presentation/preferences_providers.dart';
import 'package:vybe/features/profile/presentation/my_profile_controller.dart';
import 'package:vybe/features/reels/presentation/reels_providers.dart';

import 'fakes.dart';

/// The real bundled defaults, read straight from disk.
AppConfig loadTestConfig() {
  final raw = File('config/app_config_defaults.json').readAsStringSync();
  return AppConfig.fromJson((jsonDecode(raw) as Map).cast<String, Object?>());
}

/// A typical phone, and the smallest phone we support.
const phoneSize = Size(390, 844);
const smallPhoneSize = Size(320, 640);

/// All fakes used by one test, so the test can drive and inspect them.
class TestBackend {
  TestBackend({FakeAuthRepository? auth, FakeAccountRepository? accounts, FakePreferencesRepository? preferences})
    : auth = auth ?? FakeAuthRepository(),
      accounts = accounts ?? FakeAccountRepository(),
      preferences = preferences ?? FakePreferencesRepository() {
    identity = ScriptedIdentityVerification(this.accounts);
  }

  final FakeAuthRepository auth;
  final FakeAccountRepository accounts;
  final FakePreferencesRepository preferences;
  final FakeImageCapture capture = FakeImageCapture();
  late final ScriptedIdentityVerification identity;
  final FakeDiscoverRepository discover = FakeDiscoverRepository();
  final FakeCreditsRepository credits = FakeCreditsRepository();
  final FakeBookingRepository booking = FakeBookingRepository();
  final FakeChatRepository chat = FakeChatRepository();
  late final FakePurchaseRepository purchases = FakePurchaseRepository(credits);
  StoreClient store = TestStoreClient(platform: StorePlatform.android);
  late final FakeProfileRepository profile = FakeProfileRepository(accounts);
  final FakePhotoPicker photos = FakePhotoPicker();
  final FakeStorageUrlResolver storage = FakeStorageUrlResolver();
  final FakeReelsRepository reels = FakeReelsRepository();
  final FakeVideoPicker videos = FakeVideoPicker();
  LocationService location = const FixedLocationService(DevicePosition(lat: 19.0596, lng: 72.8295, accuracyM: 5));

  List<Override> get overrides => [
    authRepositoryProvider.overrideWithValue(auth),
    accountRepositoryProvider.overrideWithValue(accounts),
    preferencesRepositoryProvider.overrideWithValue(preferences),
    imageCaptureServiceProvider.overrideWithValue(capture),
    identityVerificationServiceProvider.overrideWithValue(identity),
    discoverRepositoryProvider.overrideWithValue(discover),
    creditsRepositoryProvider.overrideWithValue(credits),
    bookingRepositoryProvider.overrideWithValue(booking),
    chatRepositoryProvider.overrideWithValue(chat),
    safetyRepositoryProvider.overrideWithValue(chat),
    purchaseRepositoryProvider.overrideWithValue(purchases),
    storeClientProvider.overrideWithValue(store),
    locationServiceProvider.overrideWithValue(location),
    profileRepositoryProvider.overrideWithValue(profile),
    photoPickerServiceProvider.overrideWithValue(photos),
    storageUrlResolverProvider.overrideWithValue(storage),
    reelsRepositoryProvider.overrideWithValue(reels),
    videoPickerProvider.overrideWithValue(videos),
    // No video engine in widget tests.
    videoPlaybackProvider.overrideWithValue(false),
  ];
}

/// A signed-in, verified person who has finished onboarding.
TestBackend readyBackend({String? displayName = 'Aarav'}) => TestBackend(
  auth: FakeAuthRepository(
    signedIn: const AuthUser(uid: testUid, phoneNumber: testPhone),
  ),
  accounts: FakeAccountRepository(initial: verifiedAccount.copyWith(displayName: displayName)),
  preferences: FakePreferencesRepository(
    initial: const Preferences(
      gender: Gender.woman,
      showMe: ShowMe.everyone,
      ageMin: 21,
      ageMax: 35,
      showGender: false,
      whoCanRequest: WhoCanRequest.everyone,
    ),
  ),
);

List<Override> baseOverrides({AppEnv env = AppEnv.dev, bool online = true, TestBackend? backend, AppConfig? config}) =>
    [
      appEnvProvider.overrideWithValue(env),
      appConfigProvider.overrideWithValue(config ?? loadTestConfig()),
      connectivityServiceProvider.overrideWithValue(FakeConnectivityService(online: online)),
      ...(backend ?? TestBackend()).overrides,
    ];

void _setSurface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _withTextScale(BuildContext context, Widget? child, double textScale) => MediaQuery(
  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
  child: child ?? const SizedBox.shrink(),
);

/// Pumps [child] inside the app theme, localizations and a ProviderScope.
Future<void> pumpInApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  AppEnv env = AppEnv.dev,
  bool online = true,
  double textScale = 1,
  Size size = phoneSize,
  bool wrapInScaffold = true,
  TestBackend? backend,
  AppConfig? config,
}) async {
  _setSurface(tester, size);
  await tester.pumpWidget(
    ProviderScope(
      retry: noAutomaticRetry,
      overrides: [
        ...baseOverrides(env: env, online: online, backend: backend, config: config),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, inner) => _withTextScale(context, inner, textScale),
        home: wrapInScaffold ? Scaffold(body: child) : child,
      ),
    ),
  );
  await tester.pump();
}

/// Pumps the full app (router included) with test overrides.
Future<void> pumpFullApp(
  WidgetTester tester, {
  AppEnv env = AppEnv.dev,
  bool online = true,
  Size size = phoneSize,
  TestBackend? backend,
}) async {
  _setSurface(tester, size);
  await tester.pumpWidget(
    ProviderScope(
      retry: noAutomaticRetry,
      overrides: baseOverrides(env: env, online: online, backend: backend),
      child: const VybeApp(),
    ),
  );
  await settle(tester);
}

/// Pumps past stream events and route transitions. Avoids pumpAndSettle,
/// which never finishes while a loading spinner is on screen.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}
