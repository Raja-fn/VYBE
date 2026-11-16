import '../../../core/backend/callable_client.dart';
import '../../../core/backend/tables.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/run_guarded.dart';
import '../domain/chat_models.dart';

/// Chats are read straight from the database (participants only, by
/// row-level security); every write goes through the server, which moderates first.
abstract interface class ChatRepository {
  Stream<List<ChatThread>> watchChats(String myUid);

  Stream<List<ChatMessage>> watchMessages(String chatId, {required int limit});

  /// Opens (or reopens) the chat with a companion. `charged` is true only
  /// the first time, when the start-chat credit is spent.
  Future<Result<({String chatId, bool charged})>> startChat(String companionUid);

  Future<Result<void>> sendMessage({required String chatId, required String text, required String clientId});

  Future<Result<void>> markRead(String chatId);
}

/// Report and block, available on every profile and chat.
abstract interface class SafetyRepository {
  Future<Result<void>> report({
    required String reportedUid,
    required ReportContext context,
    required ReportReason reason,
    String? refId,
    String? details,
  });

  Future<Result<void>> block(String uid);
}

class SupabaseChatRepository implements ChatRepository, SafetyRepository {
  SupabaseChatRepository({required Tables tables, required CallableClient functions})
    : _tables = tables,
      _functions = functions;

  final Tables _tables;
  final CallableClient _functions;

  /// Row-level security returns only the chats this person is in.
  @override
  Stream<List<ChatThread>> watchChats(String myUid) => _tables
      .watch('chats', primaryKey: const ['id'], orderBy: 'last_message_at', descending: true)
      .map((rows) => [for (final row in rows) chatThreadFromRow(row, myUid)]);

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId, {required int limit}) => _tables
      .watch(
        'messages',
        primaryKey: const ['chat_id', 'id'],
        where: (column: 'chat_id', value: chatId),
        orderBy: 'created_at',
        descending: true,
        limit: limit,
      )
      .map((rows) => [for (final row in rows) chatMessageFromRow(row)]);

  @override
  Future<Result<({String chatId, bool charged})>> startChat(String companionUid) => runGuarded(() async {
    final data = await _functions.call('startChat', {'companionUid': companionUid});
    return (chatId: data['chatId']! as String, charged: data['charged'] == true);
  });

  @override
  Future<Result<void>> sendMessage({required String chatId, required String text, required String clientId}) =>
      runGuarded(() async {
        await _functions.call('sendMessage', {'chatId': chatId, 'text': text, 'clientId': clientId});
      });

  @override
  Future<Result<void>> markRead(String chatId) => runGuarded(() async {
    await _functions.call('markChatRead', {'chatId': chatId});
  });

  @override
  Future<Result<void>> report({
    required String reportedUid,
    required ReportContext context,
    required ReportReason reason,
    String? refId,
    String? details,
  }) => runGuarded(() async {
    await _functions.call('submitReport', {
      'reportedUid': reportedUid,
      'contextType': context.name,
      'refId': refId,
      'reason': reason.wire,
      if (details != null && details.trim().isNotEmpty) 'details': details.trim(),
    });
  });

  @override
  Future<Result<void>> block(String uid) => runGuarded(() async {
    await _functions.call('blockUser', {'blockedUid': uid});
  });
}

DateTime _time(Object? value) => parseTime(value) ?? DateTime.fromMillisecondsSinceEpoch(0);

MessageType _type(Object? value) => switch (value) {
  'system' => MessageType.system,
  'booking_card' => MessageType.bookingCard,
  _ => MessageType.text,
};

ChatThread chatThreadFromRow(Map<String, Object?> row, String myUid) {
  final participants = ((row['participants'] as List?) ?? const []).cast<String>();
  final other = participants.firstWhere((p) => p != myUid, orElse: () => '');
  final info = ((row['participant_info'] as Map?) ?? const {}).cast<String, Object?>();
  final otherInfo = ((info[other] as Map?) ?? const {}).cast<String, Object?>();
  final last = ((row['last_message'] as Map?) ?? const {}).cast<String, Object?>();
  final unread = ((row['unread'] as Map?) ?? const {}).cast<String, Object?>();
  return ChatThread(
    id: row['id']! as String,
    otherUid: other,
    otherName: (otherInfo['displayName'] as String?) ?? '',
    seekerUid: (row['seeker_uid'] as String?) ?? '',
    companionUid: (row['companion_uid'] as String?) ?? '',
    status: row['status'] == 'open' ? ChatStatus.open : ChatStatus.closed,
    lastType: _type(last['type']),
    lastText: (last['text'] as String?) ?? '',
    lastAt: _time(row['last_message_at']),
    unread: (unread[myUid] as num?)?.toInt() ?? 0,
  );
}

ChatMessage chatMessageFromRow(Map<String, Object?> row) => ChatMessage(
  id: row['id']! as String,
  type: _type(row['type']),
  createdAt: _time(row['created_at']),
  senderUid: row['sender_uid'] as String?,
  text: row['text'] as String?,
  systemKind: row['system_kind'] as String?,
  credits: (row['credits'] as num?)?.toInt(),
  bookingId: row['booking_id'] as String?,
  planType: row['plan_type'] as String?,
  startAt: parseTime(row['start_at']),
  venueName: row['venue_name'] as String?,
);
