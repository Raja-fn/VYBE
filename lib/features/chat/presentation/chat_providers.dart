import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_providers.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/app_failure.dart';
import '../../../core/utils/ids.dart';
import '../../../core/utils/result.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../data/chat_repository.dart';
import '../domain/chat_models.dart';

part 'chat_providers.freezed.dart';
part 'chat_providers.g.dart';

@Riverpod(keepAlive: true)
SupabaseChatRepository _supabaseChat(Ref ref) =>
    SupabaseChatRepository(tables: ref.watch(tablesProvider), functions: ref.watch(callableClientProvider));

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) => ref.watch(_supabaseChatProvider);

@Riverpod(keepAlive: true)
SafetyRepository safetyRepository(Ref ref) => ref.watch(_supabaseChatProvider);

/// Open chats only: a blocked chat disappears for both people.
@riverpod
Stream<List<ChatThread>> myChats(Ref ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) return Stream.value(const []);
  return ref
      .watch(chatRepositoryProvider)
      .watchChats(user.uid)
      .map((chats) => chats.where((c) => c.status == ChatStatus.open).toList());
}

/// Newest first.
@riverpod
Stream<List<ChatMessage>> chatMessages(Ref ref, String chatId) =>
    ref.watch(chatRepositoryProvider).watchMessages(chatId, limit: ref.watch(appConfigProvider).chatMessagesPageSize);

@freezed
abstract class ChatComposerState with _$ChatComposerState {
  const factory ChatComposerState({@Default(false) bool sending, AppFailure? failure}) = _ChatComposerState;
}

@riverpod
class ChatComposer extends _$ChatComposer {
  @override
  ChatComposerState build(String chatId) => const ChatComposerState();

  /// Returns true when the message was accepted (the field can be cleared).
  Future<bool> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return false;
    state = const ChatComposerState(sending: true);
    final result = await ref
        .read(chatRepositoryProvider)
        .sendMessage(chatId: chatId, text: trimmed, clientId: randomRequestId());
    state = ChatComposerState(failure: result.failureOrNull);
    return result.isOk;
  }

  void clearFailure() => state = state.copyWith(failure: null);
}

/// Opening a chat, report and block: the actions available on profiles and chats.
@riverpod
class ChatActions extends _$ChatActions {
  @override
  FutureOr<void> build() {}

  Future<Result<({String chatId, bool charged})>> start(String companionUid) async {
    state = const AsyncLoading();
    final result = await ref.read(chatRepositoryProvider).startChat(companionUid);
    state = const AsyncData(null);
    return result;
  }

  Future<Result<void>> report({
    required String reportedUid,
    required ReportContext context,
    required ReportReason reason,
    String? refId,
    String? details,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(safetyRepositoryProvider)
        .report(reportedUid: reportedUid, context: context, reason: reason, refId: refId, details: details);
    state = const AsyncData(null);
    return result;
  }

  Future<Result<void>> block(String uid) async {
    state = const AsyncLoading();
    final result = await ref.read(safetyRepositoryProvider).block(uid);
    state = const AsyncData(null);
    return result;
  }
}
