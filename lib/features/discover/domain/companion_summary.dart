import 'package:freezed_annotation/freezed_annotation.dart';

import '../../profile/domain/profile_details.dart';

part 'companion_summary.freezed.dart';
part 'companion_summary.g.dart';

/// Everyday plans a meetup can be for.
enum PlanType { coffee, movie, event, walk, dinner }

/// "Free right now" filter chips.
enum FreeWindow {
  @JsonValue('next_2h')
  next2h,
  tonight,
  tomorrow,
}

extension FreeWindowWire on FreeWindow {
  String get wire => switch (this) {
    FreeWindow.next2h => 'next_2h',
    FreeWindow.tonight => 'tonight',
    FreeWindow.tomorrow => 'tomorrow',
  };
}

@freezed
abstract class PromptAnswer with _$PromptAnswer {
  const factory PromptAnswer({required String promptId, required String answer}) = _PromptAnswer;

  factory PromptAnswer.fromJson(Map<String, Object?> json) => _$PromptAnswerFromJson(json);
}

@freezed
abstract class VoiceIntro with _$VoiceIntro {
  const factory VoiceIntro({required String path, required int durationSec}) = _VoiceIntro;

  factory VoiceIntro.fromJson(Map<String, Object?> json) => _$VoiceIntroFromJson(json);
}

/// A companion as the server shows them to this seeker.
///
/// Holds a rounded distance only. Exact locations never reach the app.
@freezed
abstract class CompanionSummary with _$CompanionSummary {
  const factory CompanionSummary({
    required String uid,
    required String displayName,
    required int ageYears,
    required List<String> photoPaths,
    required String about,
    required List<String> activityTags,
    required List<String> planTypes,
    required int ratingCount,
    required int meetupCount,
    required int distanceKm,
    required int spotsNearby,

    /// Only when the companion chose to show it.
    String? gender,
    PromptAnswer? prompt,
    VoiceIntro? voiceIntro,
    double? ratingAvg,
    DateTime? freeNowUntil,

    /// The free window for "Tonight" / "Tomorrow" in Free right now.
    DateTime? freeFrom,
    DateTime? freeUntil,

    /// City, languages, interests, lifestyle and personality, when filled in.
    @Default(ProfileDetails.empty) ProfileDetails details,
  }) = _CompanionSummary;

  factory CompanionSummary.fromJson(Map<String, Object?> json) => _$CompanionSummaryFromJson(json);
}
