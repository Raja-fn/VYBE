// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(connectivityService)
const connectivityServiceProvider = ConnectivityServiceProvider._();

final class ConnectivityServiceProvider
    extends $FunctionalProvider<ConnectivityService, ConnectivityService, ConnectivityService>
    with $Provider<ConnectivityService> {
  const ConnectivityServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityServiceHash();

  @$internal
  @override
  $ProviderElement<ConnectivityService> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ConnectivityService create(Ref ref) {
    return connectivityService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityService value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<ConnectivityService>(value));
  }
}

String _$connectivityServiceHash() => r'12f773725e4f6c6233a7468249e0e40ebc6ab619';

@ProviderFor(isOnline)
const isOnlineProvider = IsOnlineProvider._();

final class IsOnlineProvider extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  const IsOnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOnlineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOnlineHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return isOnline(ref);
  }
}

String _$isOnlineHash() => r'fb151ec6cde5743d7aec1adbc4dfe07635798e1e';

/// Synchronous view of [isOnline]: assumes online until told otherwise.

@ProviderFor(isOnlineValue)
const isOnlineValueProvider = IsOnlineValueProvider._();

/// Synchronous view of [isOnline]: assumes online until told otherwise.

final class IsOnlineValueProvider extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Synchronous view of [isOnline]: assumes online until told otherwise.
  const IsOnlineValueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOnlineValueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOnlineValueHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOnlineValue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<bool>(value));
  }
}

String _$isOnlineValueHash() => r'0bb15f977861ce7ad23ef5a4b1621c758a8564e9';
