import 'package:flutter/painting.dart';

/// Every color in the app. Widgets never use a raw [Color] literal.
///
/// Dark design language: near-black page, slightly lighter cards, a coral
/// accent with dark text on it, green for "safe / done", purple for people
/// and "you", gold for credits.
abstract final class AppColors {
  // Brand tokens.
  static const background = Color(0xFF0E0E12);
  static const card = Color(0xFF19191F);

  /// Text and icons on the page and on cards.
  static const ink = Color(0xFFF4F3F6);
  static const accent = Color(0xFFFF6B4A);
  static const muted = Color(0xFF9C9AA8);
  static const border = Color(0xFF2A2A33);
  static const gold = Color(0xFFF5B83D);
  static const success = Color(0xFF45D896);
  static const danger = Color(0xFFFF5A5A);

  /// People, the "you are here" dot and companion accents.
  static const violet = Color(0xFF8B7CF6);

  // Text and icons drawn on brand fills.
  static const onAccent = Color(0xFF17100E);
  static const onInk = Color(0xFFF4F3F6);
  static const onInkMuted = Color(0xFFB8B6C3);
  static const onGold = Color(0xFF17100E);
  static const onSuccess = Color(0xFF0E2A1D);

  /// Green text and labels ("Done", "This app is for", "Free now").
  static const successText = success;

  /// Coral text on the dark page (large and small text both pass contrast).
  static const accentText = accent;

  /// Red-coral labels such as "Not for".
  static const dangerText = Color(0xFFFF6B6B);

  // Supporting tokens.
  /// Raised fills inside cards: chips, secondary buttons, icon wells.
  static const softFill = Color(0xFF24242C);
  static const track = Color(0xFF2E2E37);

  /// Dark surfaces that stand out from cards (round action buttons, chips).
  static const inkRaised = Color(0xFF2A2A33);

  /// Switch and slider knobs.
  static const knob = Color(0xFFFFFFFF);

  /// Tinted wells behind icons: safety (green), place (coral), people (violet).
  static const successWell = Color(0xFF1C3A2E);
  static const violetWell = Color(0xFF2A2640);

  static const accentCard = Color(0xFF2C1B18);
  static const violetCard = Color(0xFF221F38);

  static const photoOverlay = Color(0xFF221D3B);
  static const avatarFill = Color(0xFFC4BBFA);
  static const avatarInk = Color(0xFF221D4F);
  static const photoBase = Color(0xFF8B7CF6);
  static const photoBlobDeep = Color(0xFF221D4F);
  static const photoBlobLight = Color(0xFFC4BBFA);
  static const photoInitial = Color(0xFF221D4F);
  static const mapUserDot = violet;
  static const mapLand = Color(0xFF15151B);
  static const mapRoad = Color(0xFF2A2A33);
  static const shadow = Color(0x66000000);
  static const accentOverlay = Color(0x1FFF6B4A);
}
