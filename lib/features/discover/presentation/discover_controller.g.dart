// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DiscoverController)
const discoverControllerProvider = DiscoverControllerProvider._();

final class DiscoverControllerProvider extends $NotifierProvider<DiscoverController, DiscoverState> {
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
  Override overrideWithValue(DiscoverState value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<DiscoverState>(value));
  }
}

String _$discoverControllerHash() => r'56dde03cdea863637d0a6c7a0246ad4bfc3a7c5d';

abstract class _$DiscoverController extends $Notifier<DiscoverState> {
  DiscoverState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DiscoverState, DiscoverState>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<DiscoverState, DiscoverState>, DiscoverState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
