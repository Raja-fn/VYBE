import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/result.dart';
import 'session_providers.dart';

part 'rules_controller.g.dart';

/// Accepting the rules. Before sign-in this only remembers consent; if the
/// phone is already verified it also records consent on the server.
@riverpod
class RulesController extends _$RulesController {
  @override
  FutureOr<void> build() {
    // Keep the signed-in user subscribed: Riverpod pauses providers nobody
    // listens to, and accept() waits on it.
    ref.listen(authUserProvider, (_, _) {});
  }

  Future<void> accept() async {
    ref.read(consentGivenProvider.notifier).give();
    // Signed out: consent is recorded right after the phone is verified.
    final user = await ref.read(authUserProvider.future);
    if (user == null) return;

    // Signed in: record it now. Safe if the account already exists.
    state = const AsyncLoading();
    final result = await ref
        .read(accountRepositoryProvider)
        .acceptRules(rulesVersion: ref.read(appConfigProvider).rulesVersion);
    // Accepting moves the app on, which can close this screen first.
    if (!ref.mounted) return;
    state = switch (result) {
      Ok() => const AsyncData(null),
      Err(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}
