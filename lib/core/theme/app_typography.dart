import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Plus Jakarta Sans at 400, 600 and 800 only.
abstract final class AppTypography {
  static const fontFamily = 'PlusJakartaSans';

  static const regular = FontWeight.w400;
  static const semiBold = FontWeight.w600;
  static const extraBold = FontWeight.w800;

  static const textTheme = TextTheme(
    // Screen titles: "Meet new people, safely", "Verify it is you".
    displaySmall: TextStyle(fontSize: 28, height: 1.1, fontWeight: extraBold, letterSpacing: -1.0),
    headlineLarge: TextStyle(fontSize: 25, height: 1.12, fontWeight: extraBold, letterSpacing: -0.8),
    headlineMedium: TextStyle(fontSize: 20, height: 1.2, fontWeight: extraBold, letterSpacing: -0.5),
    // Section titles: "Best spots to meet", "New requests".
    headlineSmall: TextStyle(fontSize: 17, height: 1.25, fontWeight: extraBold, letterSpacing: -0.3),
    // Card titles: "This app is for", names on cards.
    titleLarge: TextStyle(fontSize: 16, height: 1.3, fontWeight: extraBold),
    titleMedium: TextStyle(fontSize: 14.5, height: 1.3, fontWeight: extraBold),
    titleSmall: TextStyle(fontSize: 13, height: 1.3, fontWeight: semiBold),
    bodyLarge: TextStyle(fontSize: 14.5, height: 1.45, fontWeight: regular),
    bodyMedium: TextStyle(fontSize: 13, height: 1.45, fontWeight: regular),
    bodySmall: TextStyle(fontSize: 11.5, height: 1.4, fontWeight: regular),
    // Buttons.
    labelLarge: TextStyle(fontSize: 15, height: 1.2, fontWeight: semiBold),
    // Section labels: "Show me", "Day", "Time slot".
    labelMedium: TextStyle(fontSize: 11.5, height: 1.3, fontWeight: semiBold, letterSpacing: 1.2),
    labelSmall: TextStyle(fontSize: 11, height: 1.3, fontWeight: semiBold),
  );

  static TextTheme coloredTextTheme() =>
      textTheme.apply(fontFamily: fontFamily, bodyColor: AppColors.ink, displayColor: AppColors.ink);
}
