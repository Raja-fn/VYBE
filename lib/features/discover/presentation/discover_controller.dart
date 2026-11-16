import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../domain/companion_summary.dart' show PlanType;
import 'discover_providers.dart';

part 'discover_controller.freezed.dart';
part 'discover_controller.g.dart';

@freezed
abstract class DiscoverState with _$DiscoverState {
  const factory DiscoverState({@Default(PlanType.coffee) PlanType plan}) = _DiscoverState;
}

@riverpod
class DiscoverController extends _$DiscoverController {
  @override
  DiscoverState build() {
    // Keep the signed-in user subscribed for toggleSave().
    ref.listen(authUserProvider, (_, _) {});
    return const DiscoverState();
  }

  void selectPlan(PlanType plan) {
    if (plan == state.plan) return;
    state = DiscoverState(plan: plan);
  }

  Future<Result<void>> toggleSave(String companionUid, {required bool saved}) async {
    final me = await ref.read(authUserProvider.future);
    if (me == null) return const Err(AppFailure(FailureKind.unauthenticated));
    return ref.read(discoverRepositoryProvider).setSaved(myUid: me.uid, companionUid: companionUid, saved: saved);
  }
}
