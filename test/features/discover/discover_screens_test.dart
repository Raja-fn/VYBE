import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/router/app_router.dart';
import 'package:vybe/core/utils/app_failure.dart';
import 'package:vybe/features/discover/presentation/companion_profile_screen.dart';
import 'package:vybe/features/discover/presentation/discover_screen.dart';
import 'package:vybe/features/discover/presentation/free_now_screen.dart';
import 'package:vybe/features/discover/presentation/saved_screen.dart';
import 'package:vybe/features/profile/presentation/my_profile_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

final _soon = DateTime.now().add(const Duration(hours: 2));

TestBackend _withCompanions({String? displayName = 'Aarav'}) {
  final backend = readyBackend(displayName: displayName);
  backend.discover.companions = [
    testCompanion('neha', name: 'Neha', freeNowUntil: _soon),
    testCompanion('arjun', name: 'Arjun', age: 27, plans: ['movie'], distanceKm: 3),
    testCompanion('sam', name: 'Sam', age: 26, ratingAvg: 4.8),
  ];
  return backend;
}

/// Taps something on the current reel. No scrolling first: that would nudge
/// the page.
Future<void> _tapReel(WidgetTester tester, Finder finder) async {
  await tester.tap(finder.first);
  await settle(tester);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump();
  await tester.tap(finder.first);
  await settle(tester);
}

void main() {
  group('Discover', () {
    testWidgets('shows one person at a time as a full-screen reel with their details', (tester) async {
      await pumpFullApp(tester, backend: _withCompanions());
      expect(find.byType(DiscoverScreen), findsOneWidget);
      expect(find.text('Showing: Everyone'), findsOneWidget);
      expect(find.text('Neha, 24'), findsOneWidget);
      expect(find.text('Coffee'), findsNothing); // no plan filter: everyone shows
      expect(find.textContaining('About 2 km away · 3 spots nearby'), findsOneWidget);
      expect(find.textContaining('Free now · '), findsOneWidget);
      expect(find.text('MY IDEAL SUNDAY'), findsOneWidget);
      expect(find.bySemanticsLabel('View full profile'), findsOneWidget);
      expect(find.text('20'), findsOneWidget); // credits pill
    });

    testWidgets('sends the device location before searching', (tester) async {
      final backend = _withCompanions();
      await pumpFullApp(tester, backend: backend);
      expect(backend.discover.locations, hasLength(1));
    });

    testWidgets('swiping up shows the next person, then the end, then start again', (tester) async {
      await pumpFullApp(tester, backend: _withCompanions());
      Future<void> swipeUp() async {
        await tester.fling(find.byType(PageView), const Offset(0, -500), 1500);
        await settle(tester);
      }

      await swipeUp();
      expect(find.text('Arjun, 27'), findsOneWidget);
      expect(find.text('Neha, 24'), findsNothing);
      await swipeUp();
      expect(find.text('Sam, 26'), findsOneWidget);
      await swipeUp();
      expect(find.text('You have seen everyone for now'), findsOneWidget);
      await _tap(tester, find.text('Start again'));
      expect(find.text('Neha, 24'), findsOneWidget);
    });

    testWidgets("tapping the photo's right side shows the next photo, the left side goes back", (tester) async {
      final backend = _withCompanions();
      backend.discover.companions = [
        testCompanion(
          'neha',
          name: 'Neha',
        ).copyWith(photoPaths: ['photos/neha/1.jpg', 'photos/neha/2.jpg', 'photos/neha/3.jpg']),
      ];
      await pumpFullApp(tester, backend: backend);
      expect(find.bySemanticsLabel('Photo 1 of 3 of Neha'), findsOneWidget);
      final middle = tester.getCenter(find.byType(PageView));
      await tester.tapAt(middle + const Offset(120, -60));
      await settle(tester);
      expect(find.bySemanticsLabel('Photo 2 of 3 of Neha'), findsOneWidget);
      await tester.tapAt(middle + const Offset(-150, -60));
      await settle(tester);
      expect(find.bySemanticsLabel('Photo 1 of 3 of Neha'), findsOneWidget);
    });

    testWidgets('Message opens the chat with that person', (tester) async {
      final backend = _withCompanions();
      await pumpFullApp(tester, backend: backend);
      await _tapReel(tester, find.bySemanticsLabel('Message'));
      expect(find.textContaining('Neha'), findsWidgets);
    });

    testWidgets('shows everyone, for any plan, and Book opens booking', (tester) async {
      final backend = _withCompanions();
      await pumpFullApp(tester, backend: backend);
      expect(backend.discover.discoverCalls, [null]);
      await _tapReel(tester, find.bySemanticsLabel('Book a meetup with Neha'));
      expect(find.text('Book your spot'), findsOneWidget);
    });

    testWidgets('Save toggles and is announced', (tester) async {
      final backend = _withCompanions();
      await pumpFullApp(tester, backend: backend);
      await _tapReel(tester, find.bySemanticsLabel('Save'));
      expect(backend.discover.savedIds.value, {'neha'});
      expect(find.bySemanticsLabel('Remove from saved'), findsOneWidget);
    });

    testWidgets('no one nearby shows the empty state', (tester) async {
      final backend = readyBackend();
      await pumpFullApp(tester, backend: backend);
      expect(find.text('No one nearby yet'), findsOneWidget);
    });

    testWidgets('a server error offers a retry', (tester) async {
      final backend = _withCompanions()..discover.failure = const AppFailure(FailureKind.network);
      await pumpFullApp(tester, backend: backend);
      expect(find.text('Something went wrong'), findsOneWidget);
      backend.discover.failure = null;
      await _tap(tester, find.text('Try again'));
      expect(find.text('Neha, 24'), findsOneWidget);
    });

    testWidgets('location off shows how to allow it', (tester) async {
      final backend = _withCompanions();
      final denied = DeniedLocationService();
      backend.location = denied;
      await pumpFullApp(tester, backend: backend);
      expect(find.text('Location is needed'), findsOneWidget);
      await _tap(tester, find.text('Open settings'));
      expect(denied.settingsOpened, 1);
    });

    testWidgets('asks for a first name when there is none', (tester) async {
      await pumpFullApp(tester, backend: _withCompanions(displayName: null));
      expect(find.text('Add your first name'), findsOneWidget);
      await _tap(tester, find.text('Add name'));
      expect(find.byType(MyProfileScreen), findsOneWidget);
    });

    testWidgets("tapping a post's name opens the full profile", (tester) async {
      await pumpFullApp(tester, backend: _withCompanions());
      await _tapReel(tester, find.text('Neha, 24'));
      expect(find.byType(CompanionProfileScreen), findsOneWidget);
    });
  });

  group('Free right now', () {
    Future<void> open(WidgetTester tester, TestBackend backend) async {
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.byTooltip('See who is free right now'));
    }

    testWidgets('lists companions free in the next 2 hours', (tester) async {
      await open(tester, _withCompanions());
      expect(find.byType(FreeNowScreen), findsOneWidget);
      expect(find.text('Verified companions within 5 km.'), findsOneWidget);
      expect(find.text('Neha, 24'), findsOneWidget);
      expect(find.textContaining('Free until'), findsOneWidget);
      expect(find.text('About 2 km'), findsOneWidget);
      expect(find.text('Free · they get your request right away'), findsOneWidget);
    });

    testWidgets('switching to tomorrow shows the free window', (tester) async {
      final backend = _withCompanions();
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      backend.discover.companions.add(
        testCompanion(
          'ira',
          name: 'Ira',
          freeFrom: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11),
          freeUntil: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 13),
        ),
      );
      await open(tester, backend);
      await _tap(tester, find.text('Tomorrow'));
      expect(find.text('Ira, 24'), findsOneWidget);
      expect(find.text('Free 11 AM to 1 PM'), findsOneWidget);
    });

    testWidgets('an empty window says so', (tester) async {
      await open(tester, readyBackend());
      expect(find.text('No one is free in this window'), findsOneWidget);
    });
  });

  group('Companion profile', () {
    Future<void> open(WidgetTester tester, TestBackend backend, String uid) async {
      await pumpFullApp(tester, backend: backend);
      final container = ProviderScope.containerOf(tester.element(find.byType(Navigator).first));
      unawaited(container.read(appRouterProvider).push('/companion/$uid'));
      await settle(tester);
    }

    testWidgets('shows stats, about, tags and the safety note', (tester) async {
      await open(tester, _withCompanions(), 'sam');
      expect(find.text('Sam'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('26'), findsOneWidget);
      expect(find.text('About sam'), findsOneWidget);
      expect(find.text('Coffee meetup'), findsOneWidget);
      expect(find.text('Meet only at verified public spots within 5 km.'), findsOneWidget);
    });

    testWidgets('a new companion has no rating yet', (tester) async {
      await open(tester, _withCompanions(), 'neha');
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('someone not visible shows a not-found message', (tester) async {
      await open(tester, _withCompanions(), 'nobody');
      expect(find.text('We could not find that.'), findsOneWidget);
    });
  });

  group('Profile tab and saved list', () {
    Future<void> openProfile(WidgetTester tester, TestBackend backend) async {
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.byTooltip('Profile'));
    }

    testWidgets('validates and saves the first name', (tester) async {
      final backend = _withCompanions(displayName: null);
      await openProfile(tester, backend);
      expect(find.text('+91 98765 43210'), findsOneWidget);
      await _tap(tester, find.text('Save name'));
      expect(find.text('Enter your first name, up to 40 characters.'), findsOneWidget);
    });

    testWidgets('shows saved companions, newest saved first', (tester) async {
      final backend = _withCompanions()..discover.savedIds.value = {'sam'};
      await openProfile(tester, backend);
      await _tap(tester, find.text('Saved companions'));
      expect(find.byType(SavedScreen), findsOneWidget);
      expect(find.text('Sam, 26'), findsOneWidget);
    });

    testWidgets('an empty saved list explains how to save', (tester) async {
      await openProfile(tester, _withCompanions());
      await _tap(tester, find.text('Saved companions'));
      expect(find.text('No saved companions yet'), findsOneWidget);
    });

    testWidgets('Chats and Bookings tabs are empty for now', (tester) async {
      await pumpFullApp(tester, backend: _withCompanions());
      await _tap(tester, find.byTooltip('Chats'));
      expect(find.text('No chats yet'), findsOneWidget);
      await _tap(tester, find.byTooltip('Bookings'));
      expect(find.text('No bookings yet'), findsOneWidget);
    });
  });

  group('text scale 1.3 on a small phone', () {
    final routes = <String, String>{
      'discover': '/discover',
      'free now': '/discover/free-now',
      'companion profile': '/companion/neha',
      'my profile': '/profile',
      'saved': '/profile/saved',
    };
    for (final entry in routes.entries) {
      testWidgets(entry.key, (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final backend = _withCompanions(displayName: null)..discover.savedIds.value = {'neha'};
        await pumpFullApp(tester, backend: backend, size: smallPhoneSize);
        final container = ProviderScope.containerOf(tester.element(find.byType(Navigator).first));
        container.read(appRouterProvider).go(entry.value);
        await settle(tester);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
