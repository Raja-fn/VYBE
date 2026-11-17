// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VerificationController)
const verificationControllerProvider = VerificationControllerProvider._();

final class VerificationControllerProvider
    extends $NotifierProvider<VerificationController, VerificationFlowState> {
  const VerificationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verificationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verificationControllerHash();

  @$internal
  @override
  VerificationController create() => VerificationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerificationFlowState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerificationFlowState>(value),
    );
  }
}

String _$verificationControllerHash() =>
    r'17d7450d969dc3197cf508b35faaf250a348d78f';

abstract class _$VerificationController
    extends $Notifier<VerificationFlowState> {
  VerificationFlowState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<VerificationFlowState, VerificationFlowState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VerificationFlowState, VerificationFlowState>,
              VerificationFlowState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
