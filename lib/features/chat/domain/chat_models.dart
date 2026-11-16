import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_models.freezed.dart';

enum ChatStatus { open, closed }

enum MessageType { text, system, bookingCard }

/// One conversation, seen from the signed-in person's side.
@freezed
abstract class ChatThread with _$ChatThread {
  const factory ChatThread({
    required String id,
    required String otherUid,
    required String otherName,
    required String seekerUid,
    required String companionUid,
    required ChatStatus status,
    required MessageType lastType,
    required String lastText,
    required DateTime lastAt,
    required int unread,
  }) = _ChatThread;
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required MessageType type,
    required DateTime createdAt,
    String? senderUid,
    String? text,

    /// System messages: what happened (e.g. "chat_started") and its credit cost.
    String? systemKind,
    int? credits,

    /// Booking cards.
    String? bookingId,
    String? planType,
    DateTime? startAt,
    String? venueName,
  }) = _ChatMessage;
}

/// Reasons offered in the report sheet; values match the server.
enum ReportReason {
  inappropriateMessages('inappropriate_messages'),
  askedForContact('asked_for_contact'),
  harassment('harassment'),
  fakeProfile('fake_profile'),
  safetyConcern('safety_concern'),
  other('other');

  const ReportReason(this.wire);

  final String wire;
}

enum ReportContext { profile, chat, booking, meetup }
