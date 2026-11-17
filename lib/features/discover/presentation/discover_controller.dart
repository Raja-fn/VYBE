import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../onboarding/presentation/session_providers.dart';
import 'discover_providers.dart';

part 'discover_controller.g.dart';

/// Discover actions (saving people). Discover shows everyone nearby, for any
/// plan; the plan is picked when booking.
@riverpod
class DiscoverController extends _$DiscoverController {
  @override
  void build() {
    // Keep the signed-in user subscribed for toggleSave().
    ref.listen(authUserProvider, (_, _) {});
  }

  Future<Result<void>> toggleSave(String companionUid, {required bool saved}) async {
    final me = await ref.read(authUserProvider.future);
    if (me == null) return const Err(AppFailure(FailureKind.unauthenticated));
    return ref.read(discoverRepositoryProvider).setSaved(myUid: me.uid, companionUid: companionUid, saved: saved);
  }
}
