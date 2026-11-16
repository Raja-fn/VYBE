// Renders every screen to a PNG for a visual check against the designs.
// Not part of the normal test run. Run with:
//
//   flutter test tool/screens/render_screens_test.dart --update-goldens
//
// Images land in tool/screens/out/ (git-ignored).
import 'dart:io';

import 'package:findx/core/router/routes.dart';
import 'package:findx/features/booking/domain/booking_models.dart';
import 'package:findx/features/chat/domain/chat_models.dart';
import 'package:findx/features/onboarding/domain/session_stage.dart';
import 'package:findx/features/profile/domain/profile_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../test/helpers/fakes.dart';
import '../../test/helpers/test_app.dart';

Future<void> _loadFonts() async {
  Future<ByteData> bytes(String path) async => ByteData.sublistView(await File(path).readAsBytes());
  final jakarta = FontLoader('PlusJakartaSans');
  for (final weight in ['Regular', 'SemiBold', 'ExtraBold']) {
    jakarta.addFont(bytes('assets/fonts/PlusJakartaSans-$weight.ttf'));
  }
  await jakarta.load();
  final flutterRoot = File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final icons = FontLoader('MaterialIcons')
    ..addFont(bytes('$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf'));
  await icons.load();
}

TestBackend _ready() {
  final backend = readyBackend();
  final now = DateTime.now();
  backend.discover.companions = [
    testCompanion('neha', name: 'Neha', freeNowUntil: now.add(const Duration(hours: 2)), ratingAvg: 4.8),
    testCompanion('sam', name: 'Sam', age: 26, plans: const ['movie', 'dinner'], distanceKm: 3),
    testCompanion('ira', name: 'Ira', age: 23, plans: const ['coffee', 'event'], distanceKm: 1),
  ];
  backend.booking.venues = [
    testVenue('cafe'),
    testVenue('mall', rank: 2, km: 3.1, label: PopularityLabel.busy),
    testVenue('park', rank: 3, km: 2.4, label: PopularityLabel.busy),
  ];
  final today = DateTime(now.year, now.month, now.day, 16);
  backend.booking.slots = [
    testSlot('s16', today),
    testSlot('s17', today.add(const Duration(hours: 1))),
    testSlot('s18', today.add(const Duration(hours: 2)), state: SlotState.full),
    testSlot('s19', today.add(const Duration(hours: 3))),
  ];
  backend.booking.bookings.value = [testBooking('b1'), testBooking('b2', status: BookingStatus.accepted)];
  backend.chat.chats.value = [
    testThread('neha', name: 'Neha', unread: 2, lastText: 'Afternoon works for me.'),
    testThread('sam', name: 'Sam', lastText: 'See you there!'),
  ];
  final chatId = FakeChatRepository.idFor('neha');
  backend.chat.messagesOf(chatId).value = [
    ChatMessage(id: 'm4', type: MessageType.text, createdAt: now, senderUid: 'neha', text: 'Afternoon works for me.'),
    ChatMessage(id: 'm3', type: MessageType.text, createdAt: now, senderUid: testUid, text: 'Yes! Free this Saturday?'),
    ChatMessage(
      id: 'm2',
      type: MessageType.text,
      createdAt: now,
      senderUid: 'neha',
      text: 'Hi! Saw you like filter coffee.',
    ),
    ChatMessage(id: 'm1', type: MessageType.system, createdAt: now, systemKind: 'chat_started', credits: 1),
  ];
  return backend;
}

Future<void> _shoot(WidgetTester tester, String name, TestBackend backend, {String? route}) async {
  await pumpFullApp(tester, backend: backend);
  if (route != null) {
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go(route);
    await settle(tester);
  }
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/$name.png'));
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('rules', (tester) async {
    await _shoot(tester, '01_rules', TestBackend(auth: FakeAuthRepository()));
  });

  testWidgets('verify sign-in', (tester) async {
    final backend = TestBackend();
    await pumpFullApp(tester, backend: backend);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('I agree, continue'));
    await settle(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/02_verify_signin.png'));
  });

  testWidgets('verify selfie', (tester) async {
    await _shoot(
      tester,
      '03_verify_selfie',
      TestBackend(
        auth: FakeAuthRepository(
          signedIn: const AuthUser(uid: testUid, email: 'test@example.com'),
        ),
        accounts: FakeAccountRepository(initial: testAccount()),
      ),
    );
  });

  testWidgets('preferences', (tester) async {
    await _shoot(
      tester,
      '04_preferences',
      TestBackend(
        auth: FakeAuthRepository(
          signedIn: const AuthUser(uid: testUid, email: 'test@example.com'),
        ),
        accounts: FakeAccountRepository(initial: verifiedAccount),
      ),
    );
  });

  testWidgets('discover', (tester) async => _shoot(tester, '05_discover', _ready()));
  testWidgets('map', (tester) async => _shoot(tester, '06_map', _ready(), route: AppRoutes.discoverMapPath));
  testWidgets('free now', (tester) async => _shoot(tester, '07_free_now', _ready(), route: AppRoutes.freeNow));
  testWidgets(
    'profile',
    (tester) async => _shoot(tester, '08_companion', _ready(), route: AppRoutes.companion('neha')),
  );
  testWidgets(
    'book',
    (tester) async =>
        _shoot(tester, '09_book', _ready(), route: '${AppRoutes.bookPath}?companion=neha&plan=coffee&venue=cafe'),
  );
  testWidgets('chats', (tester) async => _shoot(tester, '10_chats', _ready(), route: AppRoutes.chats));
  testWidgets('chat', (tester) async {
    final backend = _ready();
    await _shoot(tester, '11_chat', backend, route: AppRoutes.chat(FakeChatRepository.idFor('neha')));
  });
  testWidgets('bookings', (tester) async => _shoot(tester, '12_bookings', _ready(), route: AppRoutes.bookings));
  testWidgets('credits', (tester) async => _shoot(tester, '13_credits', _ready(), route: AppRoutes.credits));
  testWidgets('my profile', (tester) async => _shoot(tester, '14_my_profile', _ready(), route: AppRoutes.profile));
  testWidgets('edit profile', (tester) async {
    final backend = _ready();
    backend.accounts.account.value = backend.accounts.account.value!.copyWith(
      photoPaths: ['photos/$testUid/a.jpg', 'photos/$testUid/b.jpg', 'photos/$testUid/c.jpg'],
      ageYears: 26,
    );
    backend.profile.details.value = const ProfileDetails(
      city: 'Mumbai',
      languages: ['english', 'hindi', 'marathi'],
      education: 'bachelors',
      interests: ['music', 'coffee', 'books'],
      drinking: 'socially',
    );
    await _shoot(tester, '15_edit_profile', backend, route: AppRoutes.editProfile);
  });
}
