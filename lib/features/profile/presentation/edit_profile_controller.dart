import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/image_capture/photo_picker_service.dart';
import '../../../core/utils/app_failure.dart';
import '../../../core/utils/ids.dart';
import '../../onboarding/domain/account.dart';
import '../../onboarding/domain/session_stage.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../domain/profile_details.dart';
import 'my_profile_controller.dart';

part 'edit_profile_controller.freezed.dart';
part 'edit_profile_controller.g.dart';

/// The signed-in person's profile details, live.
@riverpod
Stream<ProfileDetails> myProfileDetails(Ref ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) return Stream.value(ProfileDetails.empty);
  return ref.watch(profileRepositoryProvider).watchDetails(user.uid);
}

@freezed
abstract class EditProfileState with _$EditProfileState {
  const factory EditProfileState({@Default(false) bool uploading, @Default(false) bool saving, AppFailure? failure}) =
      _EditProfileState;
}

@riverpod
class EditProfileController extends _$EditProfileController {
  @override
  EditProfileState build() {
    ref.listen(authUserProvider, (_, _) {});
    return const EditProfileState();
  }

  /// The signed-in account (name, age, photos), when there is one.
  Account? get _account {
    final stage = ref.read(sessionStageProvider).value;
    return switch (stage) {
      Ready(:final account) => account,
      NeedsPreferences(:final account) => account,
      NeedsVerification(:final account) => account,
      _ => null,
    };
  }

  /// Saves the details; the screen shows them again through [myProfileDetailsProvider].
  Future<void> saveDetails(ProfileDetails details) async {
    final uid = ref.read(authUserProvider).value?.uid;
    if (uid == null) return;
    state = state.copyWith(saving: true, failure: null);
    final result = await ref.read(profileRepositoryProvider).saveDetails(uid, details);
    if (!ref.mounted) return;
    state = state.copyWith(saving: false, failure: result.failureOrNull);
  }

  Future<void> saveName(String raw) async {
    final account = _account;
    final name = cleanDisplayName(raw, maxLength: ref.read(appConfigProvider).displayNameMaxLength);
    if (account == null || name == null) return;
    state = state.copyWith(saving: true, failure: null);
    final result = await ref.read(profileRepositoryProvider).updateDisplayName(account.uid, name);
    if (!ref.mounted) return;
    state = state.copyWith(saving: false, failure: result.failureOrNull);
  }

  /// Picks a photo and adds it to the end of the profile photos.
  Future<void> addPhoto(PhotoSource source) async {
    final account = _account;
    if (account == null || state.uploading) return;
    if (account.photoPaths.length >= ref.read(appConfigProvider).maxProfilePhotos) return;
    final picked = await ref.read(photoPickerServiceProvider).pick(source);
    if (!ref.mounted) return;
    final bytes = picked.valueOrNull;
    if (bytes == null) {
      state = state.copyWith(failure: picked.failureOrNull);
      return;
    }
    state = state.copyWith(uploading: true, failure: null);
    final result = await ref
        .read(profileRepositoryProvider)
        .addPhoto(account.uid, bytes, current: account.photoPaths, photoId: randomRequestId());
    if (!ref.mounted) return;
    state = state.copyWith(uploading: false, failure: result.failureOrNull);
  }

  /// Moves a photo to the front: it becomes the one people see first.
  Future<void> makeMain(String path) async {
    final account = _account;
    if (account == null || !account.photoPaths.contains(path)) return;
    await _setPhotos(account.uid, [path, ...account.photoPaths.where((p) => p != path)]);
  }

  Future<void> removePhoto(String path) async {
    final account = _account;
    if (account == null) return;
    await _setPhotos(account.uid, account.photoPaths.where((p) => p != path).toList(), removed: [path]);
  }

  Future<void> _setPhotos(String uid, List<String> photos, {List<String> removed = const []}) async {
    state = state.copyWith(saving: true, failure: null);
    final result = await ref.read(profileRepositoryProvider).setPhotos(uid, photos, removed: removed);
    if (!ref.mounted) return;
    state = state.copyWith(saving: false, failure: result.failureOrNull);
  }

  void clearFailure() => state = state.copyWith(failure: null);
}
