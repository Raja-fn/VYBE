// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PreferencesController)
const preferencesControllerProvider = PreferencesControllerProvider._();

final class PreferencesControllerProvider extends $NotifierProvider<PreferencesController, PreferencesDraft> {
  const PreferencesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesControllerHash();

  @$internal
  @override
  PreferencesController create() => PreferencesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferencesDraft value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<PreferencesDraft>(value));
  }
}

String _$preferencesControllerHash() => r'd1f2749fee7ff6826d2932da7831590a0c559593';

abstract class _$PreferencesController extends $Notifier<PreferencesDraft> {
  PreferencesDraft build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PreferencesDraft, PreferencesDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PreferencesDraft, PreferencesDraft>,
              PreferencesDraft,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
