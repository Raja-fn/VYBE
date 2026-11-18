import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/router/app_router.dart';
import 'package:vybe/core/utils/app_failure.dart';
import 'package:vybe/core/widgets/app_pill_button.dart';
import 'package:vybe/features/booking/domain/booking_models.dart';
import 'package:vybe/features/booking/presentation/book_spot_screen.dart';
import 'package:vybe/features/booking/presentation/bookings_screen.dart';
import 'package:vybe/features/credits/presentation/credits_screen.dart';
import 'package:vybe/features/map/presentation/map_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

DateTime _todayAt(int hour) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour);
}

/// A ready seeker with Neha nearby, three venues and three time slots today.
TestBackend _world() {
  final backend = readyBackend();
  backend.discover.companions = [
    testCompanion('neha', name: 'Neha', freeNowUntil: DateTime.now().add(const Duration(hours: 2))),
  ];
  backend.booking
    ..venues = [
      testVenue('cafe'),
      testVenue('mall', rank: 2, km: 3.1, label: PopularityLabel.busy),
      testVenue('park', rank: 3, km: 2.4, label: PopularityLabel.quiet, plans: ['walk']),
    ]
    ..slots = [
      testSlot('s16', _todayAt(23).add(const Duration(minutes: 1))),
      testSlot('s17', _todayAt(23).add(const Duration(minutes: 2)), state: SlotState.full),
      testSlot('s18', _todayAt(23).add(const Duration(minutes: 3)), state: SlotState.companionUnavailable),
    ];
  return backend;
}

/// The "Pick" button for one venue.
Finder _pick(String venue) => find.byWidgetPredicate((w) => w is AppPillButton && w.semanticLabel == 'Pick $venue');

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump();
  await tester.tap(finder.first);
  await settle(tester);
}

Future<void> _go(WidgetTester tester, String location) async {
  final container = ProviderScope.containerOf(tester.element(find.byType(Navigator).first));
  container.read(appRouterProvider).go(location);
  await settle(tester);
}

void main() {
  group('Map (screen 5)', () {
    testWidgets('lists the best spots with rank and line', (tester) async {
      await pumpFullApp(tester, backend: _world());
      await _go(tester, '/discover/map');
      expect(find.byType(MapScreen), findsOneWidget);
      expect(find.text('Within 5 km'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text('Best spots to meet'), findsOneWidget);
      expect(find.text('Venue cafe'), findsOneWidget);
      expect(find.text('Cafe · 1.2 km · Hot now'), findsOneWidget);
      expect(find.text('Cafe · 3.1 km · Busy'), findsOneWidget);
    });

    testWidgets('tapping a pin shows that spot on the map; tapping the map clears it', (tester) async {
      await pumpFullApp(tester, backend: _world());
      await _go(tester, '/discover/map');
      expect(find.text('Venue cafe'), findsOneWidget);
      await tester.tapAt(tester.getCenter(find.bySemanticsLabel('1. Venue cafe')));
      await settle(tester);
      // Once in the selected card on the map, once in the list.
      expect(find.text('Venue cafe'), findsNWidgets(2));
      expect(find.bySemanticsLabel('Back to my location'), findsNothing);
    });

    testWidgets('tapping a spot in the list selects it and moves the map there', (tester) async {
      await pumpFullApp(tester, backend: _world());
      await _go(tester, '/discover/map');
      await tester.tap(find.bySemanticsLabel('Back to my location'));
      await settle(tester);
      await tester.tap(find.text('Venue mall'));
      await settle(tester);
      expect(find.text('Venue mall'), findsNWidgets(2));
      // The card on the map is only as tall as its content.
      expect(tester.getSize(find.byType(VenueRow).first).height, lessThan(200));
      final camera = MapCamera.of(tester.element(find.byType(MarkerLayer)));
      expect(camera.center.latitude, closeTo(19.0596 + 2 * 0.004, 0.0001));
      expect(camera.zoom, greaterThanOrEqualTo(14));
    });

    testWidgets('without a companion there is nothing to pick', (tester) async {
      await pumpFullApp(tester, backend: _world());
      await _go(tester, '/discover/map');
      expect(find.text('Pick'), findsNothing);
    });

    testWidgets('the Discover Map button shows the spots near me, for looking only', (tester) async {
      final backend = _world();
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.byTooltip('Map'));
      expect(find.byType(MapScreen), findsOneWidget);
      expect(backend.booking.venueQueries.last.companionUid, isNull);
      expect(find.text('Venue cafe'), findsOneWidget);
      expect(_pick('Venue cafe'), findsNothing);
    });

    testWidgets('no spots shows the empty state', (tester) async {
      final backend = _world()..booking.venues = [];
      await pumpFullApp(tester, backend: backend);
      await _go(tester, '/discover/map');
      expect(find.text('No verified spots nearby yet'), findsOneWidget);
    });
  });

  group('Book your spot (screen 6)', () {
    Future<void> open(WidgetTester tester, TestBackend backend, {String extra = ''}) async {
      await pumpFullApp(tester, backend: backend);
      await _go(tester, '/book?companion=neha$extra');
    }

    testWidgets('shows the companion, the best venue, days, times and the cost', (tester) async {
      await open(tester, _world());
      expect(find.text('Book your spot'), findsOneWidget);
      expect(find.text('Neha, 24'), findsOneWidget);
      expect(find.textContaining('Coffee · free until'), findsOneWidget);
      expect(find.text('Venue cafe'), findsOneWidget);
      expect(find.text('1.2 km · Verified public venue'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Pick a day'), findsOneWidget);
      expect(find.text('Spot booking'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('Credits are not refunded if the request is declined or cancelled.'), findsNothing);
    });

    testWidgets('full and unavailable times cannot be chosen; Confirm waits for a time', (tester) async {
      final backend = _world();
      await open(tester, backend);
      FilledButton confirm() => tester.widget<FilledButton>(find.byType(FilledButton).last);
      expect(confirm().onPressed, isNull);

      await _tap(tester, find.bySemanticsLabel(RegExp(r'not available')).first);
      expect(confirm().onPressed, isNull);

      await _tap(tester, find.text('11:01 PM'));
      expect(confirm().onPressed, isNotNull);
    });

    testWidgets('confirming sends the request and lands on Bookings', (tester) async {
      final backend = _world();
      await open(tester, backend);
      await _tap(tester, find.text('11:01 PM'));
      await _tap(tester, find.text('Confirm spot'));
      expect(backend.booking.requests.single, containsPair('venueId', 'cafe'));
      expect(backend.booking.requests.single, containsPair('kind', BookingKind.scheduled));
      expect(find.byType(BookingsScreen), findsOneWidget);
      expect(find.text('Request sent to Neha.'), findsOneWidget);
    });

    testWidgets('instant requests say so', (tester) async {
      final backend = _world();
      await open(tester, backend, extra: '&kind=instant');
      expect(find.text('Instant request'), findsOneWidget);
      await _tap(tester, find.text('11:01 PM'));
      await _tap(tester, find.text('Confirm spot'));
      expect(backend.booking.requests.single, containsPair('kind', BookingKind.instant));
    });

    testWidgets('not enough credits is explained, with Get credits', (tester) async {
      final backend = _world()..booking.requestFailure = const AppFailure(FailureKind.insufficientCredits);
      await open(tester, backend);
      await _tap(tester, find.text('11:01 PM'));
      await _tap(tester, find.text('Confirm spot'));
      expect(find.text('You do not have enough credits for this.'), findsOneWidget);
      await _tap(tester, find.text('Get credits'));
      expect(find.byType(CreditsScreen), findsOneWidget);
    });

    testWidgets('Change opens the map in pick mode and switches the venue', (tester) async {
      await open(tester, _world());
      await _tap(tester, find.text('Change'));
      expect(find.byType(MapScreen), findsOneWidget);
      await _tap(tester, _pick('Venue mall'));
      expect(find.byType(BookSpotScreen), findsOneWidget);
      expect(find.text('Venue mall'), findsOneWidget);
    });

    testWidgets('the profile button opens booking for that companion', (tester) async {
      await pumpFullApp(tester, backend: _world());
      final container = ProviderScope.containerOf(tester.element(find.byType(Navigator).first));
      unawaited(container.read(appRouterProvider).push('/companion/neha'));
      await settle(tester);
      await _tap(tester, find.text('Book your spot'));
      expect(find.byType(BookSpotScreen), findsOneWidget);
    });
  });

  group('Free right now: instant request', () {
    testWidgets('choose a person, then Pick spot opens an instant booking', (tester) async {
      await pumpFullApp(tester, backend: _world());
      await _go(tester, '/discover/free-now');
      expect(find.text('Tap someone to choose them, then pick a spot.'), findsOneWidget);
      FilledButton pick() => tester.widget<FilledButton>(find.byType(FilledButton).last);
      expect(pick().onPressed, isNull);

      await _tap(tester, find.text('Neha, 24'));
      expect(find.text('View profile'), findsOneWidget);
      expect(pick().onPressed, isNotNull);

      await _tap(tester, find.text('Pick spot'));
      expect(find.byType(BookSpotScreen), findsOneWidget);
      expect(find.text('Instant request'), findsOneWidget);
    });
  });

  group('Bookings tab', () {
    testWidgets('lists bookings with their status', (tester) async {
      final backend = _world();
      backend.booking.bookings.value = [
        testBooking('b1'),
        testBooking('b2', status: BookingStatus.accepted),
        testBooking('b3', startAt: DateTime.now().subtract(const Duration(hours: 2))),
      ];
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.byTooltip('Bookings'));
      expect(find.text('Coffee with Neha'), findsNWidgets(3));
      expect(find.text('Waiting for reply'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Time passed'), findsOneWidget);
      expect(find.text('Cancel'), findsNWidgets(2));
    });

    testWidgets('cancelling asks first', (tester) async {
      final backend = _world();
      backend.booking.bookings.value = [testBooking('b1')];
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.byTooltip('Bookings'));
      await _tap(tester, find.text('Cancel'));
      expect(find.text('The table is released and they will see it is cancelled.'), findsOneWidget);

      await _tap(tester, find.text('Keep it'));
      expect(backend.booking.cancelled, isEmpty);

      await _tap(tester, find.text('Cancel'));
      await _tap(tester, find.text('Cancel booking'));
      expect(backend.booking.cancelled, ['b1']);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Booking cancelled.'), findsOneWidget);
    });
  });

  group('text scale 1.3 on a small phone', () {
    for (final location in ['/discover/map?companion=neha', '/book?companion=neha', '/bookings']) {
      testWidgets(location, (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final backend = _world();
        backend.booking.bookings.value = [testBooking('b1')];
        await pumpFullApp(tester, backend: backend, size: smallPhoneSize);
        await _go(tester, location);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
