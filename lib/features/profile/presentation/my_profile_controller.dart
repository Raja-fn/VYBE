import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_providers.dart';
import '../../../core/config/app_config.dart';
import '../../../core/push/push_notifications.dart';
import '../../../core/utils/app_failure.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../data/profile_repository.dart';

part 'my_profile_controller.freezed.dart';
part 'my_profile_controller.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    SupabaseProfileRepository(ref.watch(tablesProvider), ref.watch(fileUploaderProvider));

@freezed
abstract class MyProfileState with _$MyProfileState {
  const factory MyProfileState({
    @Default(false) bool saving,
    @Default(false) bool saved,
    @Default(false) bool nameInvalid,
    AppFailure? failure,
  }) = _MyProfileState;
}

/// Trims and checks a first name. Null when it is not acceptable.
String? cleanDisplayName(String raw, {required int maxLength}) {
  final name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (name.isEmpty || name.length > maxLength) return null;
  return name;
}

@riverpod
class MyProfileController extends _$MyProfileController {
  @override
  MyProfileState build() {
    // Keep the signed-in user subscribed for saveName().
    ref.listen(authUserProvider, (_, _) {});
    return const MyProfileState();
  }

  Future<void> saveName(String raw) async {
    final name = cleanDisplayName(raw, maxLength: ref.read(appConfigProvider).displayNameMaxLength);
    if (name == null) {
      state = const MyProfileState(nameInvalid: true);
      return;
    }
    final me = await ref.read(authUserProvider.future);
    if (me == null) return;
    state = const MyProfileState(saving: true);
    final result = await ref.read(profileRepositoryProvider).updateDisplayName(me.uid, name);
    if (!ref.mounted) return;
    state = MyProfileState(saved: result.isOk, failure: result.failureOrNull);
  }

  Future<void> signOut() async {
    await ref.read(pushRegistrationProvider.notifier).unregister();
    await ref.read(authRepositoryProvider).signOut();
    ref.read(consentGivenProvider.notifier).reset();
  }

  /// Deletes the account for good. On success the app returns to the start.
  Future<void> deleteAccount() async {
    final consent = ref.read(consentGivenProvider.notifier);
    state = const MyProfileState(saving: true);
    final result = await ref.read(authRepositoryProvider).deleteAccount();
    if (result.isOk) consent.reset();
    if (!ref.mounted) return;
    state = MyProfileState(failure: result.failureOrNull);
  }
}
