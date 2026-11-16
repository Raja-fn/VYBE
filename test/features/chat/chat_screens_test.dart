import 'dart:async';

import 'package:findx/core/router/app_router.dart';
import 'package:findx/core/utils/app_failure.dart';
import 'package:findx/features/booking/domain/booking_models.dart';
import 'package:findx/features/booking/presentation/book_spot_screen.dart';
import 'package:findx/features/chat/domain/chat_models.dart';
import 'package:findx/features/chat/presentation/chat_screen.dart';
import 'package:findx/features/chat/presentation/chats_screen.dart';
import 'package:findx/features/discover/presentation/discover_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

final _chatId = FakeChatRepository.idFor('neha');

TestBackend _world({bool withChat = false}) {
  final backend = readyBackend();
  backend.discover.companions = [testCompanion('neha', name: 'Neha')];
  if (withChat) {
    backend.chat.chats.value = [testThread('neha', unread: 2, lastText: 'Afternoon works for me.')];
    backend.chat.messagesOf(_chatId).value = [
      ChatMessage(
        id: 'card',
        type: MessageType.bookingCard,
        createdAt: DateTime(2026, 11, 10, 12),
        senderUid: testUid,
        bookingId: 'b1',
        planType: 'coffee',
        startAt: DateTime(2026, 11, 14, 16),
        venueName: 'Harbour Bean Cafe',
      ),
      ChatMessage(
        id: 'm3',
        type: MessageType.text,
        createdAt: DateTime(2026, 11, 10, 11),
        senderUid: 'neha',
        text: 'Afternoon works for me.',
      ),
      ChatMessage(
        id: 'm2',
        type: MessageType.text,
        createdAt: DateTime(2026, 11, 10, 10),
        senderUid: testUid,
        text: 'Yes! Free this Saturday?',
      ),
      ChatMessage(
        id: 'start',
        type: MessageType.system,
        createdAt: DateTime(2026, 11, 10, 9),
        systemKind: 'chat_started',
        credits: 1,
      ),
    ];
  }
  return backend;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump();
  await tester.tap(finder.first);
  await settle(tester);
}

Future<void> _go(WidgetTester tester, String location, {bool push = false}) async {
  final router = ProviderScope.containerOf(tester.element(find.byType(Navigator).first)).read(appRouterProvider);
  if (push) {
    unawaited(router.push(location));
  } else {
    router.go(location);
  }
  await settle(tester);
}

void main() {
  group('Starting a chat', () {
    testWidgets('Message on Discover asks before spending a credit, then opens the chat', (tester) async {
      final backend = _world();
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.bySemanticsLabel('Message'));
      expect(find.text('Start a chat with Neha?'), findsOneWidget);
      expect(find.text('This uses 1 credit. Credits are not refunded.'), findsOneWidget);

      await _tap(tester, find.text('Cancel'));
      expect(backend.chat.started, isEmpty);

      await _tap(tester, find.bySemanticsLabel('Message'));
      await _tap(tester, find.text('Start chat'));
      expect(backend.chat.started, ['neha']);
      expect(find.byType(ChatScreen), findsOneWidget);
      expect(find.text('1 credit used to start this chat'), findsOneWidget);
    });

    testWidgets('an existing chat opens straight away without a charge', (tester) async {
      final backend = _world(withChat: true);
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.bySemanticsLabel('Message'));
      expect(find.text('Start a chat with Neha?'), findsNothing);
      expect(find.byType(ChatScreen), findsOneWidget);
      expect(backend.chat.started, isEmpty);
    });

    testWidgets('not enough credits is explained', (tester) async {
      final backend = _world()..chat.startFailure = const AppFailure(FailureKind.insufficientCredits);
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.bySemanticsLabel('Message'));
      await _tap(tester, find.text('Start chat'));
      expect(find.text('You do not have enough credits for this.'), findsOneWidget);
      expect(find.byType(DiscoverScreen), findsOneWidget);
    });

    testWidgets('the profile Chat button opens the chat too', (tester) async {
      await pumpFullApp(tester, backend: _world(withChat: true));
      await _go(tester, '/companion/neha', push: true);
      await _tap(tester, find.byTooltip('Chat'));
      expect(find.byType(ChatScreen), findsOneWidget);
    });
  });

  group('Chats tab', () {
    testWidgets('lists chats with preview and unread count', (tester) async {
      await pumpFullApp(tester, backend: _world(withChat: true));
      await _tap(tester, find.byTooltip('Chats'));
      expect(find.byType(ChatsScreen), findsOneWidget);
      expect(find.text('Neha'), findsOneWidget);
      expect(find.text('Afternoon works for me.'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('empty when there are no chats', (tester) async {
      await pumpFullApp(tester, backend: _world());
      await _tap(tester, find.byTooltip('Chats'));
      expect(find.text('No chats yet'), findsOneWidget);
    });
  });

  group('Chat (screen 9)', () {
    Future<TestBackend> open(WidgetTester tester) async {
      final backend = _world(withChat: true);
      backend.booking.bookings.value = [testBooking('b1', startAt: DateTime.now().add(const Duration(days: 2)))];
      await pumpFullApp(tester, backend: backend);
      await _go(tester, '/chat/$_chatId', push: true);
      return backend;
    }

    testWidgets('shows the notice, messages, the credit note and the booking card', (tester) async {
      await open(tester);
      expect(
        find.text('Chat is for planning your meetup. Phone numbers and off-app contact are blocked.'),
        findsOneWidget,
      );
      expect(find.text('Yes! Free this Saturday?'), findsOneWidget);
      expect(find.text('Afternoon works for me.'), findsWidgets);
      expect(find.text('1 credit used to start this chat'), findsOneWidget);
      expect(find.text('Coffee meetup'), findsOneWidget);
      expect(find.textContaining('Harbour Bean Cafe'), findsOneWidget);
      expect(find.text('Waiting for reply'), findsOneWidget);
    });

    testWidgets('opening it marks the chat read', (tester) async {
      final backend = await open(tester);
      expect(backend.chat.markedRead, contains(_chatId));
    });

    testWidgets('sends a message and clears the box', (tester) async {
      final backend = await open(tester);
      await tester.enterText(find.byType(TextField), 'See you there!');
      await _tap(tester, find.bySemanticsLabel('Send message'));
      expect(backend.chat.sent.single, (_chatId, 'See you there!'));
      expect(find.text('See you there!'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
    });

    testWidgets('a blocked message explains why and keeps the text', (tester) async {
      final backend = await open(tester);
      backend.chat.sendFailure = const AppFailure(FailureKind.moderationBlocked);
      await tester.enterText(find.byType(TextField), 'my insta is neha');
      await _tap(tester, find.bySemanticsLabel('Send message'));
      expect(find.text('Phone numbers, emails, social handles and links cannot be shared in chat.'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'my insta is neha');
    });

    testWidgets('with no booking yet, the seeker can book from the chat', (tester) async {
      final backend = _world(withChat: true);
      await pumpFullApp(tester, backend: backend);
      await _go(tester, '/chat/$_chatId', push: true);
      expect(find.text('Book your spot with Neha'), findsOneWidget);
      await _tap(tester, find.text('Book'));
      expect(find.byType(BookSpotScreen), findsOneWidget);
    });

    testWidgets('Report files a report with the chosen reason', (tester) async {
      final backend = await open(tester);
      await _tap(tester, find.text('Report'));
      expect(find.text('Report Neha'), findsOneWidget);
      FilledButton send() => tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Send report'));
      expect(send().onPressed, isNull);
      await _tap(tester, find.text('Asked for my number or other contact'));
      await _tap(tester, find.text('Send report'));
      expect(backend.chat.reports.single, containsPair('reason', ReportReason.askedForContact));
      expect(backend.chat.reports.single, containsPair('context', ReportContext.chat));
      expect(find.text('Thanks. Our safety team will review this.'), findsOneWidget);
    });

    testWidgets('Block asks first, then closes the chat for both', (tester) async {
      final backend = await open(tester);
      await _tap(tester, find.text('Report'));
      await _tap(tester, find.text('Block Neha'));
      expect(find.text('Block Neha?'), findsOneWidget);
      expect(find.textContaining('Credits are not refunded.'), findsOneWidget);
      await _tap(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text('Block')));
      expect(backend.chat.blocked, ['neha']);
      expect(find.byType(ChatsScreen), findsOneWidget);
      expect(find.text('No chats yet'), findsOneWidget);
    });
  });

  testWidgets('profiles have Report or block too', (tester) async {
    final backend = _world();
    await pumpFullApp(tester, backend: backend);
    await _go(tester, '/companion/neha', push: true);
    await _tap(tester, find.byTooltip('Report or block'));
    await _tap(tester, find.text('Fake profile'));
    await _tap(tester, find.text('Send report'));
    expect(backend.chat.reports.single, containsPair('context', ReportContext.profile));
  });

  group('text scale 1.3 on a small phone', () {
    for (final location in ['/chats', '/chat/${FakeChatRepository.idFor('neha')}']) {
      testWidgets(location, (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final backend = _world(withChat: true)..booking.bookings.value = [testBooking('b1')];
        await pumpFullApp(tester, backend: backend, size: smallPhoneSize);
        await _go(tester, location);
        expect(tester.takeException(), isNull);
      });
    }
  });

  test('booking status is shared with the booking model', () {
    expect(BookingStatus.values, contains(BookingStatus.requested));
  });
}
