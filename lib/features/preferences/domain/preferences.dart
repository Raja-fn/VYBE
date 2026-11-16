import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferences.freezed.dart';
part 'preferences.g.dart';

enum Gender {
  woman,
  man,
  @JsonValue('non_binary')
  nonBinary,

  /// "Prefer not to say".
  undisclosed,
}

enum ShowMe { women, men, everyone }

enum WhoCanRequest { everyone, women, men }

/// `preferences/{uid}`. Distance is not stored: it is always AppConfig's radius.
@freezed
abstract class Preferences with _$Preferences {
  const factory Preferences({
    required Gender gender,
    required ShowMe showMe,
    required int ageMin,
    required int ageMax,
    required bool showGender,
    required WhoCanRequest whoCanRequest,
  }) = _Preferences;

  factory Preferences.fromJson(Map<String, Object?> json) => _$PreferencesFromJson(json);
}
