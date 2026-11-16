import 'dart:async';

import 'package:findx/core/router/app_router.dart';
import 'package:findx/core/utils/app_failure.dart';
import 'package:findx/features/discover/presentation/companion_profile_screen.dart';
import 'package:findx/features/discover/presentation/discover_screen.dart';
import 'package:findx/features/discover/presentation/free_now_screen.dart';
import 'package:findx/features/discover/presentation/saved_screen.dart';
import 'package:findx/features/profile/presentation/my_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump();
  await tester.tap(finder.first);
  await settle(tester);
}

void main() {
  group('Discover', () {
    testWidgets('shows the first companion card with the screenshot details', (tester) async {
      await pumpFullApp(tester, backend: _withCompanions());
      expect(find.byType(DiscoverScreen), findsOneWidget);
      expect(find.text('What is the plan?'), findsOneWidget);
      expect(find.text('Showing: Everyone'), findsOneWidget);
      expect(find.text('Neha, 24'), findsOneWidget);
      expect(find.text('3 spots nearby'), findsOneWidget);
      expect(find.textContaining('About 2 km away · free until'), findsOneWidget);
      expect(find.text('Free now'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('MY IDEAL SUNDAY'), findsOneWidget);
      expect(find.text('20'), findsOneWidget); // credits pill
    });

    testWidgets('sends the device location before searching', (tester) async {
      final backend = _withCompanions();
      await pumpFullApp(tester, backend: backend);
      expect(backend.discover.locations, hasLength(1));
    });

    testWidgets('Skip moves to the next card; the end offers start over', (tester) async {
      await pumpFullApp(tester, backend: _withCompanions());
      await _tap(tester, find.bySemanticsLabel('Skip'));
      expect(find.text('Sam, 26'), findsOneWidget);
      await _tap(tester, find.bySemanticsLabel('Skip'));
      expect(find.text('You have seen everyone for now'), findsOneWidget);
      await _tap(tester, find.text('Start over'));
      expect(find.text('Neha, 24'), findsOneWidget);
    });

    testWidgets('plan chips filter the deck', (tester) async {
      await pumpFullApp(tester, backend: _withCompanions());
      await _tap(tester, find.text('Movie'));
      expect(find.text('Arjun, 27'), findsOneWidget);
    });

    testWidgets('Save toggles and is announced', (tester) async {
      final backend = _withCompanions();
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.bySemanticsLabel('Save'));
      expect(backend.discover.savedIds.value, {'neha'});
      expect(find.bySemanticsLabel('Remove from saved'), findsOneWidget);
    });

    testWidgets('empty plan shows the empty state', (tester) async {
      final backend = readyBackend();
      await pumpFullApp(tester, backend: backend);
      expect(find.text('No one nearby for this plan yet'), findsOneWidget);
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

    testWidgets('tapping the card opens the full profile', (tester) async {
      await pumpFullApp(tester, backend: _withCompanions());
      await _tap(tester, find.text('Neha, 24'));
      expect(find.byType(CompanionProfileScreen), findsOneWidget);
    });
  });

  group('Free right now', () {
    Future<void> open(WidgetTester tester, TestBackend backend) async {
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.text('See who is free right now'));
    }

    testWidgets('lists companions free in the next 2 hours', (tester) async {
      await open(tester, _withCompanions());
      expect(find.byType(FreeNowScreen), findsOneWidget);
      expect(find.text('Verified companions within 5 km.'), findsOneWidget);
      expect(find.text('Neha, 24'), findsOneWidget);
      expect(find.textContaining('Free until'), findsOneWidget);
      expect(find.text('About 2 km'), findsOneWidget);
      expect(find.text('Costs 5 credits'), findsOneWidget);
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
