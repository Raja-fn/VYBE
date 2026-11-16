// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(_supabaseChat)
const _supabaseChatProvider = _SupabaseChatProvider._();

final class _SupabaseChatProvider
    extends $FunctionalProvider<SupabaseChatRepository, SupabaseChatRepository, SupabaseChatRepository>
    with $Provider<SupabaseChatRepository> {
  const _SupabaseChatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_supabaseChatProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_supabaseChatHash();

  @$internal
  @override
  $ProviderElement<SupabaseChatRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  SupabaseChatRepository create(Ref ref) {
    return _supabaseChat(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseChatRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<SupabaseChatRepository>(value));
  }
}

String _$_supabaseChatHash() => r'28557be89c8b0a99cc91d9cd4ebaac08c945331a';

@ProviderFor(chatRepository)
const chatRepositoryProvider = ChatRepositoryProvider._();

final class ChatRepositoryProvider extends $FunctionalProvider<ChatRepository, ChatRepository, ChatRepository>
    with $Provider<ChatRepository> {
  const ChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChatRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ChatRepository create(Ref ref) {
    return chatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<ChatRepository>(value));
  }
}

String _$chatRepositoryHash() => r'5f72699e22b2089c8c073183da822eda308107f9';

@ProviderFor(safetyRepository)
const safetyRepositoryProvider = SafetyRepositoryProvider._();

final class SafetyRepositoryProvider extends $FunctionalProvider<SafetyRepository, SafetyRepository, SafetyRepository>
    with $Provider<SafetyRepository> {
  const SafetyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'safetyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$safetyRepositoryHash();

  @$internal
  @override
  $ProviderElement<SafetyRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  SafetyRepository create(Ref ref) {
    return safetyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<SafetyRepository>(value));
  }
}

String _$safetyRepositoryHash() => r'4e241bf71ec29c8aa4dd64336bb6cfd4c3046d86';

/// Open chats only: a blocked chat disappears for both people.

@ProviderFor(myChats)
const myChatsProvider = MyChatsProvider._();

/// Open chats only: a blocked chat disappears for both people.

final class MyChatsProvider
    extends $FunctionalProvider<AsyncValue<List<ChatThread>>, List<ChatThread>, Stream<List<ChatThread>>>
    with $FutureModifier<List<ChatThread>>, $StreamProvider<List<ChatThread>> {
  /// Open chats only: a blocked chat disappears for both people.
  const MyChatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myChatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myChatsHash();

  @$internal
  @override
  $StreamProviderElement<List<ChatThread>> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<List<ChatThread>> create(Ref ref) {
    return myChats(ref);
  }
}

String _$myChatsHash() => r'367559acf363276f6c702b0c533e857bd93cbac6';

/// Newest first.

@ProviderFor(chatMessages)
const chatMessagesProvider = ChatMessagesFamily._();

/// Newest first.

final class ChatMessagesProvider
    extends $FunctionalProvider<AsyncValue<List<ChatMessage>>, List<ChatMessage>, Stream<List<ChatMessage>>>
    with $FutureModifier<List<ChatMessage>>, $StreamProvider<List<ChatMessage>> {
  /// Newest first.
  const ChatMessagesProvider._({required ChatMessagesFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'chatMessagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatMessagesHash();

  @override
  String toString() {
    return r'chatMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ChatMessage>> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<List<ChatMessage>> create(Ref ref) {
    final argument = this.argument as String;
    return chatMessages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatMessagesHash() => r'c1f9d33072bd00e32288c7bec95701b8879ad833';

/// Newest first.

final class ChatMessagesFamily extends $Family with $FunctionalFamilyOverride<Stream<List<ChatMessage>>, String> {
  const ChatMessagesFamily._()
    : super(
        retry: null,
        name: r'chatMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Newest first.

  ChatMessagesProvider call(String chatId) => ChatMessagesProvider._(argument: chatId, from: this);

  @override
  String toString() => r'chatMessagesProvider';
}

@ProviderFor(ChatComposer)
const chatComposerProvider = ChatComposerFamily._();

final class ChatComposerProvider extends $NotifierProvider<ChatComposer, ChatComposerState> {
  const ChatComposerProvider._({required ChatComposerFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'chatComposerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatComposerHash();

  @override
  String toString() {
    return r'chatComposerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatComposer create() => ChatComposer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatComposerState value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<ChatComposerState>(value));
  }

  @override
  bool operator ==(Object other) {
    return other is ChatComposerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatComposerHash() => r'9211065b114f9b22c411ba0442509b6bab6c26d9';

final class ChatComposerFamily extends $Family
    with $ClassFamilyOverride<ChatComposer, ChatComposerState, ChatComposerState, ChatComposerState, String> {
  const ChatComposerFamily._()
    : super(
        retry: null,
        name: r'chatComposerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatComposerProvider call(String chatId) => ChatComposerProvider._(argument: chatId, from: this);

  @override
  String toString() => r'chatComposerProvider';
}

abstract class _$ChatComposer extends $Notifier<ChatComposerState> {
  late final _$args = ref.$arg as String;
  String get chatId => _$args;

  ChatComposerState build(String chatId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<ChatComposerState, ChatComposerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatComposerState, ChatComposerState>,
              ChatComposerState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Opening a chat, report and block: the actions available on profiles and chats.

@ProviderFor(ChatActions)
const chatActionsProvider = ChatActionsProvider._();

/// Opening a chat, report and block: the actions available on profiles and chats.
final class ChatActionsProvider extends $AsyncNotifierProvider<ChatActions, void> {
  /// Opening a chat, report and block: the actions available on profiles and chats.
  const ChatActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatActionsHash();

  @$internal
  @override
  ChatActions create() => ChatActions();
}

String _$chatActionsHash() => r'19b9b86c13d86614c800109db32ab9fc061232b8';

/// Opening a chat, report and block: the actions available on profiles and chats.

abstract class _$ChatActions extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<AsyncValue<void>, void>, AsyncValue<void>, Object?, Object?>;
    element.handleValue(ref, null);
  }
}
