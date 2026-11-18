import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_providers.dart';
import '../../../core/utils/app_failure.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../data/safety_services.dart';

part 'safety_providers.g.dart';

@Riverpod(keepAlive: true)
TrustedContactRepository trustedContactRepository(Ref ref) =>
    SupabaseTrustedContactRepository(ref.watch(tablesProvider));

@Riverpod(keepAlive: true)
SafetyLauncher safetyLauncher(Ref ref) => const DeviceSafetyLauncher();

/// The signed-in person's trusted contact (null when none is set).
@riverpod
class MyTrustedContact extends _$MyTrustedContact {
  @override
  Future<TrustedContact?> build() async {
    final uid = ref.watch(authUserProvider).value?.uid;
    if (uid == null) return null;
    return (await ref.watch(trustedContactRepositoryProvider).load(uid)).valueOrThrow;
  }

  /// Saves (or with null, removes) the contact. Returns the failure, if any.
  Future<AppFailure?> save(TrustedContact? contact) async {
    final uid = ref.read(authUserProvider).value?.uid;
    if (uid == null) return const AppFailure(FailureKind.unauthenticated);
    final result = await ref.read(trustedContactRepositoryProvider).save(uid, contact);
    final failure = result.failureOrNull;
    if (failure == null) state = AsyncData(contact);
    return failure;
  }
}
