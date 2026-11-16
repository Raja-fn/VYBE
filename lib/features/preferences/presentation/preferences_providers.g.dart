// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(preferencesRepository)
const preferencesRepositoryProvider = PreferencesRepositoryProvider._();

final class PreferencesRepositoryProvider
    extends $FunctionalProvider<PreferencesRepository, PreferencesRepository, PreferencesRepository>
    with $Provider<PreferencesRepository> {
  const PreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<PreferencesRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  PreferencesRepository create(Ref ref) {
    return preferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferencesRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<PreferencesRepository>(value));
  }
}

String _$preferencesRepositoryHash() => r'914348a4a3052e1807cb4c1c08b0d5cc4fb51255';

@ProviderFor(preferences)
const preferencesProvider = PreferencesFamily._();

final class PreferencesProvider
    extends $FunctionalProvider<AsyncValue<Preferences?>, Preferences?, Stream<Preferences?>>
    with $FutureModifier<Preferences?>, $StreamProvider<Preferences?> {
  const PreferencesProvider._({required PreferencesFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'preferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesHash();

  @override
  String toString() {
    return r'preferencesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Preferences?> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<Preferences?> create(Ref ref) {
    final argument = this.argument as String;
    return preferences(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PreferencesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$preferencesHash() => r'e9d0da16e9e8b3bf8f2a08af527ae47e962392fe';

final class PreferencesFamily extends $Family with $FunctionalFamilyOverride<Stream<Preferences?>, String> {
  const PreferencesFamily._()
    : super(
        retry: null,
        name: r'preferencesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  PreferencesProvider call(String uid) => PreferencesProvider._(argument: uid, from: this);

  @override
  String toString() => r'preferencesProvider';
}
