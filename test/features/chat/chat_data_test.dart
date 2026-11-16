import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/app.dart';
import 'package:vybe/core/backend/callable_client.dart';
import 'package:vybe/core/utils/app_failure.dart';
import 'package:vybe/features/chat/data/chat_repository.dart';
import 'package:vybe/features/chat/domain/chat_models.dart';
import 'package:vybe/features/chat/presentation/chat_providers.dart';

import '../../helpers/fake_tables.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

void main() {
  group('SupabaseChatRepository', () {
    late FakeTables tables;
    late FakeCallableClient functions;
    late SupabaseChatRepository repository;

    setUp(() {
      tables = FakeTables();
      functions = FakeCallableClient();
      repository = SupabaseChatRepository(tables: tables, functions: functions);
    });

    test('lists my chats newest first, from my side', () async {
      // Row-level security returns only my chats (tested on the server).
      Map<String, Object?> chat(String id, String other, DateTime at, String text) => {
        'id': id,
        'participants': ['me', other],
        'participant_info': {
          'me': {'displayName': 'Aarav'},
          other: {'displayName': other.toUpperCase()},
        },
        'seeker_uid': 'me',
        'companion_uid': other,
        'status': 'open',
        'last_message': {'type': 'text', 'text': text, 'senderUid': other},
        'last_message_at': at.toUtc().toIso8601String(),
        'unread': {'me': 2, other: 0},
      };
      tables.seed('chats', [
        chat('a', 'neha', DateTime(2026, 11, 10, 9), 'Hi'),
        chat('b', 'sam', DateTime(2026, 11, 10, 11), 'Hello'),
      ]);

      final chats = await repository.watchChats('me').first;
      expect(chats.map((c) => c.otherName), ['SAM', 'NEHA']);
      expect(
        chats.first,
        isA<ChatThread>().having((c) => c.unread, 'unread', 2).having((c) => c.lastText, 'text', 'Hello'),
      );
    });

    test('reads text, system and booking-card messages', () async {
      tables.seed('messages', [
        {
          'chat_id': 'a',
          'id': '1',
          'type': 'system',
          'system_kind': 'chat_started',
          'credits': 1,
          'created_at': DateTime(2026, 11, 10, 9).toUtc().toIso8601String(),
        },
        {
          'chat_id': 'a',
          'id': '2',
          'type': 'booking_card',
          'sender_uid': 'me',
          'booking_id': 'b1',
          'plan_type': 'coffee',
          'venue_name': 'Cafe',
          'start_at': DateTime(2026, 11, 14, 16).toUtc().toIso8601String(),
          'created_at': DateTime(2026, 11, 10, 10).toUtc().toIso8601String(),
        },
        {'chat_id': 'other', 'id': '9', 'type': 'text', 'text': 'elsewhere', 'created_at': '2026-11-10T11:00:00Z'},
      ]);
      final messages = await repository.watchMessages('a', limit: 50).first;
      expect(messages.map((m) => m.type), [MessageType.bookingCard, MessageType.system]);
      expect(messages.first.startAt, DateTime(2026, 11, 14, 16));
      expect(messages.last.credits, 1);
    });

    test('start, send and read go through the functions', () async {
      functions.responses['startChat'] = {'chatId': 'me_neha', 'charged': true, 'balance': 19};
      final started = (await repository.startChat('neha')).valueOrNull!;
      expect(started, (chatId: 'me_neha', charged: true));
      await repository.sendMessage(chatId: 'me_neha', text: 'Hi', clientId: 'abcdefgh12');
      await repository.markRead('me_neha');
      expect(functions.calls.map((c) => c.$1), ['startChat', 'sendMessage', 'markChatRead']);
      expect(functions.calls[1].$2, {'chatId': 'me_neha', 'text': 'Hi', 'clientId': 'abcdefgh12'});
    });

    test('a blocked message becomes a moderation failure', () async {
      functions.error = const ServerException(
        'invalid-argument',
        code: 'moderation_blocked',
        message: 'This message was not sent.',
      );
      final result = await repository.sendMessage(chatId: 'c', text: '98765 43210', clientId: 'abcdefgh12');
      expect(result.failureOrNull?.kind, FailureKind.moderationBlocked);
    });

    test('report and block send the right payloads', () async {
      await repository.report(
        reportedUid: 'neha',
        context: ReportContext.chat,
        reason: ReportReason.askedForContact,
        refId: 'me_neha',
        details: '  asked for my number  ',
      );
      await repository.block('neha');
      expect(functions.calls.first.$2, {
        'reportedUid': 'neha',
        'contextType': 'chat',
        'refId': 'me_neha',
        'reason': 'asked_for_contact',
        'details': 'asked for my number',
      });
      expect(functions.calls.last.$2, {'blockedUid': 'neha'});
    });
  });

  group('ChatComposer', () {
    ProviderContainer container0(TestBackend backend) {
      final container = ProviderContainer(
        retry: noAutomaticRetry,
        overrides: baseOverrides(backend: backend),
      );
      addTearDown(container.dispose);
      container.listen(chatComposerProvider('c1'), (_, _) {});
      return container;
    }

    test('ignores blank messages', () async {
      final backend = readyBackend();
      final container = container0(backend);
      expect(await container.read(chatComposerProvider('c1').notifier).send('   '), isFalse);
      expect(backend.chat.sent, isEmpty);
    });

    test('sends trimmed text', () async {
      final backend = readyBackend();
      final container = container0(backend);
      expect(await container.read(chatComposerProvider('c1').notifier).send('  Hi there '), isTrue);
      expect(backend.chat.sent.single, ('c1', 'Hi there'));
    });

    test('a blocked message is reported and not cleared', () async {
      final backend = readyBackend()..chat.sendFailure = const AppFailure(FailureKind.moderationBlocked);
      final container = container0(backend);
      expect(await container.read(chatComposerProvider('c1').notifier).send('insta?'), isFalse);
      expect(container.read(chatComposerProvider('c1')).failure?.kind, FailureKind.moderationBlocked);
      container.read(chatComposerProvider('c1').notifier).clearFailure();
      expect(container.read(chatComposerProvider('c1')).failure, isNull);
    });
  });
}
