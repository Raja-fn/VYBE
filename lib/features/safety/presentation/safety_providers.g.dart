// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trustedContactRepository)
const trustedContactRepositoryProvider = TrustedContactRepositoryProvider._();

final class TrustedContactRepositoryProvider
    extends
        $FunctionalProvider<
          TrustedContactRepository,
          TrustedContactRepository,
          TrustedContactRepository
        >
    with $Provider<TrustedContactRepository> {
  const TrustedContactRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trustedContactRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trustedContactRepositoryHash();

  @$internal
  @override
  $ProviderElement<TrustedContactRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrustedContactRepository create(Ref ref) {
    return trustedContactRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrustedContactRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrustedContactRepository>(value),
    );
  }
}

String _$trustedContactRepositoryHash() =>
    r'8bfff29807bf08dc307af452e2343cd1747475a2';

@ProviderFor(safetyLauncher)
const safetyLauncherProvider = SafetyLauncherProvider._();

final class SafetyLauncherProvider
    extends $FunctionalProvider<SafetyLauncher, SafetyLauncher, SafetyLauncher>
    with $Provider<SafetyLauncher> {
  const SafetyLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'safetyLauncherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$safetyLauncherHash();

  @$internal
  @override
  $ProviderElement<SafetyLauncher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SafetyLauncher create(Ref ref) {
    return safetyLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyLauncher>(value),
    );
  }
}

String _$safetyLauncherHash() => r'1d570ac75d9c289ffb5febce08ea9d803a28418b';

/// The signed-in person's trusted contact (null when none is set).

@ProviderFor(MyTrustedContact)
const myTrustedContactProvider = MyTrustedContactProvider._();

/// The signed-in person's trusted contact (null when none is set).
final class MyTrustedContactProvider
    extends $AsyncNotifierProvider<MyTrustedContact, TrustedContact?> {
  /// The signed-in person's trusted contact (null when none is set).
  const MyTrustedContactProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myTrustedContactProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myTrustedContactHash();

  @$internal
  @override
  MyTrustedContact create() => MyTrustedContact();
}

String _$myTrustedContactHash() => r'601a1b863b6276252bd5f42c2f8d75833c9f1b86';

/// The signed-in person's trusted contact (null when none is set).

abstract class _$MyTrustedContact extends $AsyncNotifier<TrustedContact?> {
  FutureOr<TrustedContact?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<TrustedContact?>, TrustedContact?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TrustedContact?>, TrustedContact?>,
              AsyncValue<TrustedContact?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
