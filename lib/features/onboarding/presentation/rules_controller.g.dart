// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rules_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Accepting the rules. Before sign-in this only remembers consent; if the
/// phone is already verified it also records consent on the server.

@ProviderFor(RulesController)
const rulesControllerProvider = RulesControllerProvider._();

/// Accepting the rules. Before sign-in this only remembers consent; if the
/// phone is already verified it also records consent on the server.
final class RulesControllerProvider extends $AsyncNotifierProvider<RulesController, void> {
  /// Accepting the rules. Before sign-in this only remembers consent; if the
  /// phone is already verified it also records consent on the server.
  const RulesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rulesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rulesControllerHash();

  @$internal
  @override
  RulesController create() => RulesController();
}

String _$rulesControllerHash() => r'2154331513a2c2ef371d402a5a6b9ea988a0d335';

/// Accepting the rules. Before sign-in this only remembers consent; if the
/// phone is already verified it also records consent on the server.

abstract class _$RulesController extends $AsyncNotifier<void> {
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
