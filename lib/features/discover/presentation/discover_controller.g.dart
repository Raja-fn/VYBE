// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Discover actions (saving people). Discover shows everyone nearby, for any
/// plan; the plan is picked when booking.

@ProviderFor(DiscoverController)
const discoverControllerProvider = DiscoverControllerProvider._();

/// Discover actions (saving people). Discover shows everyone nearby, for any
/// plan; the plan is picked when booking.
final class DiscoverControllerProvider
    extends $NotifierProvider<DiscoverController, void> {
  /// Discover actions (saving people). Discover shows everyone nearby, for any
  /// plan; the plan is picked when booking.
  const DiscoverControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverControllerHash();

  @$internal
  @override
  DiscoverController create() => DiscoverController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$discoverControllerHash() =>
    r'bd4624546a9afae0733ea73f1d1f822e44c51474';

/// Discover actions (saving people). Discover shows everyone nearby, for any
/// plan; the plan is picked when booking.

abstract class _$DiscoverController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
