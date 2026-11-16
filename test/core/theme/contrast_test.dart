import 'dart:math';

import 'package:findx/core/theme/app_colors.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  // Every text color / background pair the design uses.
  const textPairs = <String, (Color, Color)>{
    'ink on background': (AppColors.ink, AppColors.background),
    'ink on card': (AppColors.ink, AppColors.card),
    'ink on soft fill': (AppColors.ink, AppColors.softFill),
    'muted on background': (AppColors.muted, AppColors.background),
    'muted on card': (AppColors.muted, AppColors.card),
    'muted on soft fill': (AppColors.muted, AppColors.softFill),
    'accent text on background': (AppColors.accentText, AppColors.background),
    'accent text on card': (AppColors.accentText, AppColors.card),
    'accent on card': (AppColors.accent, AppColors.card),
    'dark text on accent': (AppColors.onAccent, AppColors.accent),
    'dark text on white pill': (AppColors.onAccent, AppColors.knob),
    'dark text on success': (AppColors.onSuccess, AppColors.success),
    'light text on raised fill': (AppColors.onInk, AppColors.inkRaised),
    'light text on violet card': (AppColors.onInk, AppColors.violetCard),
    'muted light text on violet card': (AppColors.onInkMuted, AppColors.violetCard),
    'light text on coral card': (AppColors.ink, AppColors.accentCard),
    'light text on photo overlay': (AppColors.onInk, AppColors.photoOverlay),
    'gold on photo overlay': (AppColors.gold, AppColors.photoOverlay),
    'gold on card': (AppColors.gold, AppColors.card),
    'violet on card': (AppColors.violet, AppColors.card),
    'dark text on gold': (AppColors.onGold, AppColors.gold),
    'success text on card': (AppColors.successText, AppColors.card),
    'success text on background': (AppColors.successText, AppColors.background),
    'danger text on card': (AppColors.dangerText, AppColors.card),
    'danger on card': (AppColors.danger, AppColors.card),
  };

  for (final entry in textPairs.entries) {
    test('${entry.key} meets 4.5:1', () {
      final (fg, bg) = entry.value;
      expect(contrastRatio(fg, bg), greaterThanOrEqualTo(4.5));
    });
  }

  test('raw accent on background passes for large text only (3:1)', () {
    expect(contrastRatio(AppColors.accent, AppColors.background), greaterThanOrEqualTo(3));
  });

  test('the green, coral and violet accents all work as small text on the dark page', () {
    for (final color in [AppColors.success, AppColors.accent, AppColors.violet]) {
      expect(contrastRatio(color, AppColors.background), greaterThanOrEqualTo(4.5));
    }
  });
}
