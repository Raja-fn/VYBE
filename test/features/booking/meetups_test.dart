import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/utils/app_failure.dart';
import 'package:vybe/features/booking/domain/booking_models.dart';
import 'package:vybe/features/chat/domain/chat_models.dart';
import 'package:vybe/features/safety/presentation/safety_hub_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump();
  await tester.tap(finder.first);
  await settle(tester);
}

/// Neha asked me (the signed-in person) to meet.
Booking _invite(String id, {BookingStatus status = BookingStatus.requested, DateTime? startAt}) => testBooking(
  id,
  status: status,
  startAt: startAt,
  seekerUid: 'neha',
  seekerName: 'Neha',
  companionUid: testUid,
  companionName: 'Aarav',
);

Future<TestBackend> _openBookings(WidgetTester tester, List<Booking> bookings) async {
  final backend = readyBackend();
  backend.booking.bookings.value = bookings;
  await pumpFullApp(tester, backend: backend);
  await _tap(tester, find.byTooltip('Bookings'));
  return backend;
}

void main() {
  group('Answering a request', () {
    testWidgets('the invited person sees Accept and Decline; Accept confirms', (tester) async {
      final backend = await _openBookings(tester, [_invite('b1')]);
      expect(find.text('Waiting for your reply'), findsOneWidget);
      await _tap(tester, find.text('Accept'));
      expect(backend.booking.responses, [('b1', true)]);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Confirmed. See you there!'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
    });

    testWidgets('Decline turns the request down', (tester) async {
      final backend = await _openBookings(tester, [_invite('b1')]);
      await _tap(tester, find.text('Decline'));
      expect(backend.booking.responses, [('b1', false)]);
      expect(find.text('Declined'), findsOneWidget);
    });

    testWidgets('the person who asked only waits (and can cancel)', (tester) async {
      await _openBookings(tester, [testBooking('b1')]);
      expect(find.text('Waiting for reply'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('a failed answer is explained', (tester) async {
      final backend = readyBackend();
      backend.booking
        ..bookings.value = [_invite('b1')]
        ..actionFailure = const AppFailure(FailureKind.invalidInput);
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.byTooltip('Bookings'));
      await _tap(tester, find.text('Accept'));
      expect(find.text('Waiting for your reply'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('requests can be answered from the chat booking card too', (tester) async {
      final backend = readyBackend();
      final start = DateTime.now().add(const Duration(hours: 3));
      backend.booking.bookings.value = [_invite('b1', startAt: start)];
      final thread = testThread('neha').copyWith(seekerUid: 'neha', companionUid: testUid);
      backend.chat.chats.value = [thread];
      backend.chat.messagesOf(thread.id).value = [
        ChatMessage(
          id: 'booking_b1',
          senderUid: 'neha',
          type: MessageType.bookingCard,
          createdAt: DateTime.now(),
          bookingId: 'b1',
          planType: 'coffee',
          startAt: start,
          venueName: 'Harbour Bean Cafe',
        ),
      ];
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.byTooltip('Chats'));
      await _tap(tester, find.text('Neha'));
      await _tap(tester, find.text('Accept'));
      expect(backend.booking.responses, [('b1', true)]);
    });
  });

  group("I'm here", () {
    testWidgets('shows around the start of a confirmed meetup and checks in', (tester) async {
      final backend = await _openBookings(tester, [
        testBooking('b1', status: BookingStatus.accepted, startAt: DateTime.now().add(const Duration(minutes: 10))),
      ]);
      await _tap(tester, find.text("I'm here"));
      expect(backend.booking.checkIns, ['b1']);
      expect(find.text('Checked in'), findsOneWidget);
      expect(find.text("I'm here"), findsNothing);
      // The snack bar offers the Safety Hub.
      await _tap(tester, find.widgetWithText(SnackBarAction, 'Safety'));
      expect(find.byType(SafetyHubScreen), findsOneWidget);
    });

    testWidgets('is not offered hours ahead or for unconfirmed requests', (tester) async {
      await _openBookings(tester, [
        testBooking('b1', status: BookingStatus.accepted),
        testBooking('b2', startAt: DateTime.now().add(const Duration(minutes: 5))),
      ]);
      expect(find.text("I'm here"), findsNothing);
    });
  });

  group('How did it go?', () {
    final started = DateTime.now().subtract(const Duration(hours: 2));

    testWidgets('after a meetup, the answer is private and sent once', (tester) async {
      final backend = await _openBookings(tester, [
        testBooking('b1', status: BookingStatus.checkedIn, startAt: started),
      ]);
      await _tap(tester, find.text('How did it go?'));
      expect(find.text('How did it go with Neha?'), findsOneWidget);
      expect(find.text("Only our safety team sees this. Neha won't."), findsOneWidget);
      await _tap(tester, find.text('Good, I felt comfortable'));
      await tester.enterText(find.byType(TextField), ' Lovely chat ');
      await _tap(tester, find.text('Send'));
      expect(backend.booking.feedbacks.single, (bookingId: 'b1', felt: MeetFeeling.good, note: 'Lovely chat'));
      expect(find.text('Thanks for telling us.'), findsOneWidget);
      expect(find.text('How did it go?'), findsNothing);
    });

    testWidgets('"I felt unsafe" tells them the safety team will look', (tester) async {
      final backend = await _openBookings(tester, [
        testBooking('b1', status: BookingStatus.accepted, startAt: started),
      ]);
      await _tap(tester, find.text('How did it go?'));
      await _tap(tester, find.text('I felt unsafe'));
      await _tap(tester, find.text('Send'));
      expect(backend.booking.feedbacks.single.felt, MeetFeeling.unsafe);
      expect(find.text('Thanks. Our safety team will review this.'), findsOneWidget);
    });

    testWidgets('is not asked before the start or for declined requests', (tester) async {
      await _openBookings(tester, [
        testBooking('b1', status: BookingStatus.accepted),
        testBooking('b2', status: BookingStatus.declined, startAt: started),
        testBooking('b3', status: BookingStatus.accepted, startAt: started, feedbackUids: [testUid]),
      ]);
      expect(find.text('How did it go?'), findsNothing);
    });
  });

  group('Booking rules', () {
    final now = DateTime(2026, 11, 20, 18);
    Booking at(DateTime start, {BookingStatus status = BookingStatus.accepted}) =>
        testBooking('b', status: status, startAt: start);
    const before = Duration(minutes: 15);
    const after = Duration(minutes: 30);

    test('check-in opens 15 minutes before and closes 30 after the start', () {
      expect(at(now.add(const Duration(minutes: 16))).canCheckIn(testUid, now, before: before, after: after), isFalse);
      expect(at(now.add(const Duration(minutes: 15))).canCheckIn(testUid, now, before: before, after: after), isTrue);
      expect(
        at(now.subtract(const Duration(minutes: 30))).canCheckIn(testUid, now, before: before, after: after),
        isTrue,
      );
      expect(
        at(now.subtract(const Duration(minutes: 31))).canCheckIn(testUid, now, before: before, after: after),
        isFalse,
      );
      expect(at(now, status: BookingStatus.requested).canCheckIn(testUid, now, before: before, after: after), isFalse);
    });

    test('only the invited person answers, before the start', () {
      final b = _invite('b', startAt: now.add(const Duration(hours: 1)));
      expect(b.canRespond(testUid, now), isTrue);
      expect(b.canRespond('neha', now), isFalse);
      expect(b.canRespond(testUid, now.add(const Duration(hours: 2))), isFalse);
    });

    test('feedback is open for two weeks after the end', () {
      final b = at(now.subtract(const Duration(hours: 2)));
      expect(b.canGiveFeedback(testUid, now), isTrue);
      expect(b.canGiveFeedback(testUid, now.add(const Duration(days: 15))), isFalse);
    });
  });
}
