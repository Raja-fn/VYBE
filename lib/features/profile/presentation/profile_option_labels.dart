import '../../../core/l10n/l10n.dart';

/// Display text for the fixed profile choices (generated with the strings; keep in sync).
abstract final class ProfileOptionLabels {
  static String language(AppLocalizations l10n, String value) => switch (value) {
    'english' => l10n.optLanguageEnglish,
    'hindi' => l10n.optLanguageHindi,
    'marathi' => l10n.optLanguageMarathi,
    'gujarati' => l10n.optLanguageGujarati,
    'tamil' => l10n.optLanguageTamil,
    'telugu' => l10n.optLanguageTelugu,
    'kannada' => l10n.optLanguageKannada,
    'malayalam' => l10n.optLanguageMalayalam,
    'bengali' => l10n.optLanguageBengali,
    'punjabi' => l10n.optLanguagePunjabi,
    'urdu' => l10n.optLanguageUrdu,
    'odia' => l10n.optLanguageOdia,
    _ => value,
  };

  static String education(AppLocalizations l10n, String value) => switch (value) {
    'high_school' => l10n.optEducationHighSchool,
    'diploma' => l10n.optEducationDiploma,
    'bachelors' => l10n.optEducationBachelors,
    'masters' => l10n.optEducationMasters,
    'doctorate' => l10n.optEducationDoctorate,
    'other' => l10n.optEducationOther,
    _ => value,
  };

  static String interest(AppLocalizations l10n, String value) => switch (value) {
    'music' => l10n.optInterestMusic,
    'movies' => l10n.optInterestMovies,
    'travel' => l10n.optInterestTravel,
    'food' => l10n.optInterestFood,
    'coffee' => l10n.optInterestCoffee,
    'books' => l10n.optInterestBooks,
    'fitness' => l10n.optInterestFitness,
    'art' => l10n.optInterestArt,
    'photography' => l10n.optInterestPhotography,
    'gaming' => l10n.optInterestGaming,
    'cricket' => l10n.optInterestCricket,
    'football' => l10n.optInterestFootball,
    'dance' => l10n.optInterestDance,
    'theatre' => l10n.optInterestTheatre,
    'tech' => l10n.optInterestTech,
    'nature' => l10n.optInterestNature,
    'cooking' => l10n.optInterestCooking,
    'fashion' => l10n.optInterestFashion,
    _ => value,
  };

  static String personality(AppLocalizations l10n, String value) => switch (value) {
    'calm' => l10n.optPersonalityCalm,
    'cheerful' => l10n.optPersonalityCheerful,
    'curious' => l10n.optPersonalityCurious,
    'adventurous' => l10n.optPersonalityAdventurous,
    'thoughtful' => l10n.optPersonalityThoughtful,
    'witty' => l10n.optPersonalityWitty,
    'easygoing' => l10n.optPersonalityEasygoing,
    'ambitious' => l10n.optPersonalityAmbitious,
    _ => value,
  };

  static String socialEnergy(AppLocalizations l10n, String value) => switch (value) {
    'introvert' => l10n.optSocialEnergyIntrovert,
    'ambivert' => l10n.optSocialEnergyAmbivert,
    'extrovert' => l10n.optSocialEnergyExtrovert,
    _ => value,
  };

  static String habit(AppLocalizations l10n, String value) => switch (value) {
    'never' => l10n.optHabitNever,
    'socially' => l10n.optHabitSocially,
    'regularly' => l10n.optHabitRegularly,
    _ => value,
  };

  static String fitness(AppLocalizations l10n, String value) => switch (value) {
    'rarely' => l10n.optFitnessRarely,
    'sometimes' => l10n.optFitnessSometimes,
    'active' => l10n.optFitnessActive,
    'very_active' => l10n.optFitnessVeryActive,
    _ => value,
  };
}
