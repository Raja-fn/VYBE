// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  const AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AuthRepository>(value));
  }
}

String _$authRepositoryHash() => r'5a298a673d7a14f3b182d98675efeb2dfdc824b0';

@ProviderFor(accountRepository)
const accountRepositoryProvider = AccountRepositoryProvider._();

final class AccountRepositoryProvider
    extends $FunctionalProvider<AccountRepository, AccountRepository, AccountRepository>
    with $Provider<AccountRepository> {
  const AccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccountRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  AccountRepository create(Ref ref) {
    return accountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AccountRepository>(value));
  }
}

String _$accountRepositoryHash() => r'3e0d996f24b482978f452c2501ca7a99b1d7b608';

@ProviderFor(authUser)
const authUserProvider = AuthUserProvider._();

final class AuthUserProvider extends $FunctionalProvider<AsyncValue<AuthUser?>, AuthUser?, Stream<AuthUser?>>
    with $FutureModifier<AuthUser?>, $StreamProvider<AuthUser?> {
  const AuthUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authUserHash();

  @$internal
  @override
  $StreamProviderElement<AuthUser?> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<AuthUser?> create(Ref ref) {
    return authUser(ref);
  }
}

String _$authUserHash() => r'eb5861fccca8a24b7df59fc0415964608897267f';

@ProviderFor(account)
const accountProvider = AccountFamily._();

final class AccountProvider extends $FunctionalProvider<AsyncValue<Account?>, Account?, Stream<Account?>>
    with $FutureModifier<Account?>, $StreamProvider<Account?> {
  const AccountProvider._({required AccountFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'accountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountHash();

  @override
  String toString() {
    return r'accountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Account?> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<Account?> create(Ref ref) {
    final argument = this.argument as String;
    return account(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountHash() => r'47a77f5b4823dcae0b78325977ada0419965a080';

final class AccountFamily extends $Family with $FunctionalFamilyOverride<Stream<Account?>, String> {
  const AccountFamily._()
    : super(
        retry: null,
        name: r'accountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  AccountProvider call(String uid) => AccountProvider._(argument: uid, from: this);

  @override
  String toString() => r'accountProvider';
}

/// Where the person is in getting set up. The router redirects on this.

@ProviderFor(sessionStage)
const sessionStageProvider = SessionStageProvider._();

/// Where the person is in getting set up. The router redirects on this.

final class SessionStageProvider
    extends $FunctionalProvider<AsyncValue<SessionStage>, AsyncValue<SessionStage>, AsyncValue<SessionStage>>
    with $Provider<AsyncValue<SessionStage>> {
  /// Where the person is in getting set up. The router redirects on this.
  const SessionStageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionStageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionStageHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<SessionStage>> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  AsyncValue<SessionStage> create(Ref ref) {
    return sessionStage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<SessionStage> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AsyncValue<SessionStage>>(value));
  }
}

String _$sessionStageHash() => r'9993686b96e1fc990304b6f8c28a3a5cdc2491c0';

/// Whether the rules were accepted on this device in this session.
///
/// Consent is recorded on the server (with the rules version) as soon as the
/// phone is verified; this only carries it from the rules screen to sign-in.

@ProviderFor(ConsentGiven)
const consentGivenProvider = ConsentGivenProvider._();

/// Whether the rules were accepted on this device in this session.
///
/// Consent is recorded on the server (with the rules version) as soon as the
/// phone is verified; this only carries it from the rules screen to sign-in.
final class ConsentGivenProvider extends $NotifierProvider<ConsentGiven, bool> {
  /// Whether the rules were accepted on this device in this session.
  ///
  /// Consent is recorded on the server (with the rules version) as soon as the
  /// phone is verified; this only carries it from the rules screen to sign-in.
  const ConsentGivenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'consentGivenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$consentGivenHash();

  @$internal
  @override
  ConsentGiven create() => ConsentGiven();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<bool>(value));
  }
}

String _$consentGivenHash() => r'ef8f883210c6e4f670b389d3ef6d8b45d630449e';

/// Whether the rules were accepted on this device in this session.
///
/// Consent is recorded on the server (with the rules version) as soon as the
/// phone is verified; this only carries it from the rules screen to sign-in.

abstract class _$ConsentGiven extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

/// The date of birth typed on the rules screen, sent when the account is created.

@ProviderFor(SignupBirthDate)
const signupBirthDateProvider = SignupBirthDateProvider._();

/// The date of birth typed on the rules screen, sent when the account is created.
final class SignupBirthDateProvider extends $NotifierProvider<SignupBirthDate, DateTime?> {
  /// The date of birth typed on the rules screen, sent when the account is created.
  const SignupBirthDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signupBirthDateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signupBirthDateHash();

  @$internal
  @override
  SignupBirthDate create() => SignupBirthDate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<DateTime?>(value));
  }
}

String _$signupBirthDateHash() => r'32673bb15d35509ed45513a4514fd77d5ddb6ae3';

/// The date of birth typed on the rules screen, sent when the account is created.

abstract class _$SignupBirthDate extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<DateTime?, DateTime?>, DateTime?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
