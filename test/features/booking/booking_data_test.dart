import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/app.dart';
import 'package:vybe/core/backend/callable_client.dart';
import 'package:vybe/core/utils/app_failure.dart';
import 'package:vybe/core/utils/ids.dart';
import 'package:vybe/features/booking/data/booking_repository.dart';
import 'package:vybe/features/booking/domain/booking_models.dart';
import 'package:vybe/features/booking/presentation/booking_providers.dart';
import 'package:vybe/features/discover/domain/companion_summary.dart';

import '../../helpers/fake_tables.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

void main() {
  group('FunctionsBookingRepository', () {
    late FakeCallableClient functions;
    late FakeTables tables;
    late SupabaseBookingRepository repository;

    setUp(() {
      functions = FakeCallableClient();
      tables = FakeTables();
      repository = SupabaseBookingRepository(functions: functions, tables: tables);
    });

    test('parses venues with exact public distances and popularity', () async {
      functions.responses['nearbyVenues'] = {
        'venues': [
          {
            'venueId': 'v1',
            'name': 'Harbour Bean Cafe',
            'category': 'cafe',
            'addressLine': 'Hill Road',
            'lat': 19.05,
            'lng': 72.83,
            'distanceKm': 1.2,
            'planTypes': ['coffee'],
            'perk': null,
            'popularityScore': 0.9,
            'popularityLabel': 'hot',
            'rank': 1,
          },
        ],
      };
      final venues = (await repository.nearbyVenues(plan: PlanType.coffee, companionUid: 'neha')).valueOrNull!;
      expect(functions.calls.single.$2, {'planType': 'coffee', 'companionUid': 'neha'});
      expect(venues.single, isA<Venue>().having((v) => v.popularityLabel, 'label', PopularityLabel.hot));
      expect(venues.single.distanceKm, 1.2);
    });

    test('parses slot states, including companion_unavailable', () async {
      functions.responses['venueSlots'] = {
        'slots': [
          {
            'slotId': 's1',
            'startAt': '2026-11-10T11:30:00.000Z',
            'endAt': '2026-11-10T12:30:00.000Z',
            'state': 'available',
          },
          {
            'slotId': 's2',
            'startAt': '2026-11-10T12:30:00.000Z',
            'endAt': '2026-11-10T13:30:00.000Z',
            'state': 'companion_unavailable',
          },
        ],
      };
      final slots = (await repository.venueSlots(
        venueId: 'v1',
        dayKey: '2026-11-10',
        companionUid: 'neha',
      )).valueOrNull!;
      expect(slots.map((s) => s.state), [SlotState.available, SlotState.companionUnavailable]);
      expect(slots.first.isBookable, isTrue);
      expect(slots.last.isBookable, isFalse);
    });

    test('sends the booking request and returns the new balance', () async {
      functions.responses['requestBooking'] = {'bookingId': 'me_abc', 'balance': 15};
      final balance = await repository.requestBooking(
        requestId: 'abcdefghij',
        companionUid: 'neha',
        venueId: 'v1',
        slotId: 's1',
        plan: PlanType.coffee,
        kind: BookingKind.instant,
      );
      expect(balance.valueOrNull, 15);
      expect(functions.calls.single.$2, {
        'requestId': 'abcdefghij',
        'companionUid': 'neha',
        'venueId': 'v1',
        'slotId': 's1',
        'planType': 'coffee',
        'kind': 'instant',
      });
    });

    test('maps server booking errors to typed failures', () async {
      for (final (code, kind) in [
        ('slot_full', FailureKind.slotFull),
        ('insufficient_credits', FailureKind.insufficientCredits),
        ('companion_unavailable', FailureKind.companionUnavailable),
      ]) {
        functions.error = ServerException('failed-precondition', code: code, message: code);
        final result = await repository.cancel('x');
        expect(result.failureOrNull?.kind, kind, reason: code);
      }
    });

    test("lists the person's bookings, newest first", () async {
      // Row-level security returns only bookings the person is part of (tested on the server).
      Map<String, Object?> row(String id, String start, String status) => {
        'id': id,
        'seeker_uid': 'me',
        'companion_uid': 'neha',
        'companion_name': 'Neha',
        'seeker_name': 'Aarav',
        'venue_name': 'Cafe',
        'venue_category': 'cafe',
        'plan_type': 'coffee',
        'start_at': start,
        'end_at': DateTime.parse(start).add(const Duration(hours: 1)).toIso8601String(),
        'status': status,
        'kind': 'scheduled',
        'credit_cost': 5,
        'participants': ['me', 'neha'],
      };
      tables.seed('bookings', [
        row('a', '2026-11-10T11:30:00Z', 'requested'),
        row('b', '2026-11-12T11:30:00Z', 'checked_in'),
      ]);
      final list = await repository.watchMyBookings('me').first;
      expect(list.map((b) => b.id), ['b', 'a']);
      expect(list.first.status, BookingStatus.checkedIn);
      expect(list.first.startAt, DateTime.utc(2026, 11, 12, 11, 30).toLocal());
      expect(list.first.creditCost, 5);
    });
  });

  group('Booking rules', () {
    final now = DateTime(2026, 11, 10, 15, 30);

    test('the seeker can cancel only before it starts, while requested or accepted', () {
      final later = now.add(const Duration(hours: 1));
      expect(testBooking('a', startAt: later).canCancel(now), isTrue);
      expect(testBooking('a', startAt: later, status: BookingStatus.accepted).canCancel(now), isTrue);
      expect(testBooking('a', startAt: now.subtract(const Duration(minutes: 1))).canCancel(now), isFalse);
      expect(testBooking('a', startAt: later, status: BookingStatus.declined).canCancel(now), isFalse);
    });

    test('an unanswered request whose time has passed is shown as such', () {
      expect(testBooking('a', startAt: now.subtract(const Duration(hours: 1))).timePassed(now), isTrue);
      expect(testBooking('a', startAt: now.add(const Duration(hours: 1))).timePassed(now), isFalse);
      expect(
        testBooking(
          'a',
          startAt: now.subtract(const Duration(hours: 1)),
          status: BookingStatus.accepted,
        ).timePassed(now),
        isFalse,
      );
    });

    test('day keys match the server format', () {
      expect(dayKeyOf(DateTime(2026, 3, 7)), '2026-03-07');
    });

    test('request ids are 20 safe characters and different each time', () {
      final a = randomRequestId(Random(1));
      final b = randomRequestId(Random(2));
      expect(a, matches(RegExp(r'^[A-Za-z0-9]{20}$')));
      expect(a, isNot(b));
    });
  });

  group('BookSpotController', () {
    ProviderContainer container0(TestBackend backend) {
      final container = ProviderContainer(
        retry: noAutomaticRetry,
        overrides: baseOverrides(backend: backend),
      );
      addTearDown(container.dispose);
      container.listen(bookSpotControllerProvider('neha'), (_, _) {});
      return container;
    }

    test('needs a slot before confirming', () async {
      final backend = readyBackend();
      final container = container0(backend);
      await container
          .read(bookSpotControllerProvider('neha').notifier)
          .confirm(venueId: 'v1', plan: PlanType.coffee, kind: BookingKind.scheduled);
      expect(backend.booking.requests, isEmpty);
    });

    test('sends the request and marks it sent', () async {
      final backend = readyBackend();
      final container = container0(backend);
      final controller = container.read(bookSpotControllerProvider('neha').notifier)..selectSlot('s1');
      await controller.confirm(venueId: 'v1', plan: PlanType.coffee, kind: BookingKind.instant);
      expect(container.read(bookSpotControllerProvider('neha')).sent, isTrue);
      expect(backend.booking.requests.single, containsPair('kind', BookingKind.instant));
    });

    test('keeps the request id after a network error so a retry cannot charge twice', () async {
      final backend = readyBackend()..booking.requestFailure = const AppFailure(FailureKind.network);
      final container = container0(backend);
      final controller = container.read(bookSpotControllerProvider('neha').notifier)..selectSlot('s1');
      final before = container.read(bookSpotControllerProvider('neha')).requestId;
      await controller.confirm(venueId: 'v1', plan: PlanType.coffee, kind: BookingKind.scheduled);
      expect(container.read(bookSpotControllerProvider('neha')).requestId, before);
      expect(container.read(bookSpotControllerProvider('neha')).slotId, 's1');
    });

    test('a full slot clears the choice and uses a fresh id next time', () async {
      final backend = readyBackend()..booking.requestFailure = const AppFailure(FailureKind.slotFull);
      final container = container0(backend);
      final controller = container.read(bookSpotControllerProvider('neha').notifier)..selectSlot('s1');
      final before = container.read(bookSpotControllerProvider('neha')).requestId;
      await controller.confirm(venueId: 'v1', plan: PlanType.coffee, kind: BookingKind.scheduled);
      final after = container.read(bookSpotControllerProvider('neha'));
      expect(after.slotId, isNull);
      expect(after.requestId, isNot(before));
      expect(after.failure?.kind, FailureKind.slotFull);
    });

    test('changing venue or day clears the chosen time', () {
      final container = container0(readyBackend());
      final controller = container.read(bookSpotControllerProvider('neha').notifier)
        ..selectSlot('s1')
        ..selectVenue('v2');
      expect(container.read(bookSpotControllerProvider('neha')).slotId, isNull);
      controller
        ..selectSlot('s2')
        ..selectDay(DateTime(2026, 11, 12, 9));
      final state = container.read(bookSpotControllerProvider('neha'));
      expect(state.slotId, isNull);
      expect(state.day, DateTime(2026, 11, 12));
    });
  });
}
