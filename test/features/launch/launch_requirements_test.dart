import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/features/booking/presentation/bookings_screen.dart';
import 'package:vybe/features/profile/presentation/my_profile_screen.dart';

import '../../helpers/test_app.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump();
  await tester.tap(finder.first);
  await settle(tester);
}

void main() {
  group('Notifications', () {
    testWidgets('a signed-in member registers this phone once', (tester) async {
      final backend = readyBackend();
      await pumpFullApp(tester, backend: backend);
      final registrations = backend.functions.calls.where((c) => c.$1 == 'registerPushToken').toList();
      expect(registrations, hasLength(1));
      expect(registrations.single.$2, {'token': 'test-push-token'});
      expect(backend.push.permissionRequests, 1);
    });

    testWidgets('a new token is registered too', (tester) async {
      final backend = readyBackend();
      await pumpFullApp(tester, backend: backend);
      backend.push.refreshes.add('new-push-token');
      await settle(tester);
      expect(backend.functions.calls.last.$1, 'registerPushToken');
      expect(backend.functions.calls.last.$2, {'token': 'new-push-token'});
    });

    testWidgets('notifications not allowed: nothing is registered', (tester) async {
      final backend = readyBackend()..push.allowed = false;
      await pumpFullApp(tester, backend: backend);
      expect(backend.functions.calls.where((c) => c.$1 == 'registerPushToken'), isEmpty);
    });

    testWidgets('tapping a notification opens its screen', (tester) async {
      final backend = readyBackend();
      await pumpFullApp(tester, backend: backend);
      backend.push.opened.add('/bookings');
      await settle(tester);
      expect(find.byType(BookingsScreen), findsOneWidget);
    });

    testWidgets('signing out stops notifications on this phone', (tester) async {
      final backend = readyBackend();
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.byTooltip('Profile'));
      await tester.scrollUntilVisible(
        find.text('Sign out'),
        300,
        scrollable: find.descendant(of: find.byType(MyProfileScreen), matching: find.byType(Scrollable)).first,
      );
      await _tap(tester, find.text('Sign out'));
      expect(backend.functions.calls.last.$1, 'unregisterPushToken');
      expect(backend.functions.calls.last.$2, {'token': 'test-push-token'});
    });
  });

  group('About and legal', () {
    testWidgets('privacy policy, terms, support and the Grievance Officer are in Profile', (tester) async {
      final backend = readyBackend();
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.byTooltip('Profile'));
      await _tap(tester, find.text('Privacy policy'));
      await _tap(tester, find.text('Terms'));
      await _tap(tester, find.text('Grievance Officer'));
      expect(backend.links.opened.map((u) => u.toString()), [
        'https://findx-dev-b5f6b.web.app/privacy',
        'https://findx-dev-b5f6b.web.app/terms',
        'mailto:rk7033688851@gmail.com?subject=Grievance',
      ]);
    });

    testWidgets('a link that cannot open is explained', (tester) async {
      final backend = readyBackend()..links.opens = false;
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.byTooltip('Profile'));
      await _tap(tester, find.text('Privacy policy'));
      expect(find.textContaining("Couldn't open"), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
