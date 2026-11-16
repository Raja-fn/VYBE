import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/app_failure.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../domain/preferences.dart';
import 'preferences_providers.dart';

part 'preferences_controller.freezed.dart';
part 'preferences_controller.g.dart';

/// The preferences form before it is saved.
@freezed
abstract class PreferencesDraft with _$PreferencesDraft {
  const factory PreferencesDraft({
    required int ageMin,
    required int ageMax,
    Gender? gender,
    @Default(ShowMe.everyone) ShowMe showMe,
    @Default(false) bool showGender,
    @Default(false) bool saving,
    AppFailure? failure,
  }) = _PreferencesDraft;

  const PreferencesDraft._();

  bool get canSave => gender != null && !saving;
}

@riverpod
class PreferencesController extends _$PreferencesController {
  @override
  PreferencesDraft build() {
    // Keep the signed-in user subscribed: Riverpod pauses providers nobody
    // listens to, and save() waits on it.
    ref.listen(authUserProvider, (_, _) {});
    final config = ref.watch(appConfigProvider);
    return PreferencesDraft(ageMin: config.defaultAgeRangeMin, ageMax: config.defaultAgeRangeMax);
  }

  void setGender(Gender gender) => state = state.copyWith(gender: gender, failure: null);

  void setShowMe(ShowMe showMe) => state = state.copyWith(showMe: showMe, failure: null);

  void setShowGender(bool value) => state = state.copyWith(showGender: value);

  /// Keeps the range inside AppConfig's limits and in order.
  void setAgeRange(int min, int max) {
    final config = ref.read(appConfigProvider);
    final low = min.clamp(config.ageMinimum, config.ageMaximum);
    final high = max.clamp(low, config.ageMaximum);
    state = state.copyWith(ageMin: low, ageMax: high);
  }

  Future<void> save() async {
    final gender = state.gender;
    final uid = (await ref.read(authUserProvider.future))?.uid;
    if (gender == null || uid == null) return;

    state = state.copyWith(saving: true, failure: null);
    final result = await ref
        .read(preferencesRepositoryProvider)
        .save(
          uid,
          Preferences(
            gender: gender,
            showMe: state.showMe,
            ageMin: state.ageMin,
            ageMax: state.ageMax,
            showGender: state.showGender,
            whoCanRequest: WhoCanRequest.everyone,
          ),
        );
    // Saving moves the app on, which can close this screen first.
    if (!ref.mounted) return;
    state = state.copyWith(saving: false, failure: result.failureOrNull);
  }
}
