import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_details.freezed.dart';
part 'profile_details.g.dart';

/// What people fill in on "Edit profile". Every field is optional. Choices
/// use the fixed wire values below; the database refuses anything else.
@freezed
abstract class ProfileDetails with _$ProfileDetails {
  const factory ProfileDetails({
    String? about,
    String? city,
    @Default([]) List<String> languages,
    String? education,
    String? profession,
    @Default([]) List<String> interests,
    @Default([]) List<String> personality,
    String? socialEnergy,
    String? drinking,
    String? smoking,
    String? fitness,
  }) = _ProfileDetails;

  const ProfileDetails._();

  factory ProfileDetails.fromJson(Map<String, Object?> json) => _$ProfileDetailsFromJson(json);

  static const empty = ProfileDetails();

  /// Reads a `profile_details` row.
  factory ProfileDetails.fromRow(Map<String, Object?> row) => ProfileDetails(
    about: row['about'] as String?,
    city: row['city'] as String?,
    languages: _strings(row['languages']),
    education: row['education'] as String?,
    profession: row['profession'] as String?,
    interests: _strings(row['interests']),
    personality: _strings(row['personality']),
    socialEnergy: row['social_energy'] as String?,
    drinking: row['drinking'] as String?,
    smoking: row['smoking'] as String?,
    fitness: row['fitness'] as String?,
  );

  /// The `profile_details` columns. Blank text is stored as "not set".
  Map<String, Object?> toRow() => {
    'about': _blankToNull(about),
    'city': _blankToNull(city),
    'languages': languages,
    'education': education,
    'profession': _blankToNull(profession),
    'interests': interests,
    'personality': personality,
    'social_energy': socialEnergy,
    'drinking': drinking,
    'smoking': smoking,
    'fitness': fitness,
  };

  /// Nothing filled in yet.
  bool get isEmpty => this == empty;

  static List<String> _strings(Object? value) => value is List ? value.cast<String>() : const [];

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

/// The fixed choices, in display order. Keep in sync with the CHECK
/// constraints in supabase/migrations/20261114000200_profile_details.sql.
abstract final class ProfileOptions {
  static const languages = [
    'english',
    'hindi',
    'marathi',
    'gujarati',
    'tamil',
    'telugu',
    'kannada',
    'malayalam',
    'bengali',
    'punjabi',
    'urdu',
    'odia',
  ];
  static const education = ['high_school', 'diploma', 'bachelors', 'masters', 'doctorate', 'other'];
  static const interests = [
    'music',
    'movies',
    'travel',
    'food',
    'coffee',
    'books',
    'fitness',
    'art',
    'photography',
    'gaming',
    'cricket',
    'football',
    'dance',
    'theatre',
    'tech',
    'nature',
    'cooking',
    'fashion',
  ];
  static const personality = [
    'calm',
    'cheerful',
    'curious',
    'adventurous',
    'thoughtful',
    'witty',
    'easygoing',
    'ambitious',
  ];
  static const socialEnergy = ['introvert', 'ambivert', 'extrovert'];
  static const habit = ['never', 'socially', 'regularly'];
  static const fitness = ['rarely', 'sometimes', 'active', 'very_active'];

  static const maxLanguages = 8;
  static const maxInterests = 8;
  static const maxPersonality = 3;
  static const aboutMaxLength = 500;
  static const cityMaxLength = 40;
  static const professionMaxLength = 60;
}
