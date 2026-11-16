import 'package:flutter/widgets.dart';

/// Spacing scale and screen padding.
abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 18.0;
  static const xl = 22.0;
  static const xxl = 28.0;

  static const tagVertical = 6.0;

  static const screenGutter = 20.0;
  static const screenPadding = EdgeInsets.symmetric(horizontal: screenGutter);
  static const cardPadding = EdgeInsets.all(lg);
}

/// Corner radii.
abstract final class AppRadii {
  static const card = 20.0;
  static const photoCard = 24.0;
  static const avatar = 16.0;
  static const avatarLarge = 24.0;
  static const pill = 999.0;
  static const captureFrame = 56.0;

  static const cardBorder = BorderRadius.all(Radius.circular(card));
  static const photoCardBorder = BorderRadius.all(Radius.circular(photoCard));
  static const pillBorder = BorderRadius.all(Radius.circular(pill));
}

/// Fixed component sizes.
abstract final class AppSizes {
  static const primaryButtonHeight = 48.0;
  static const minTouchTarget = 44.0;
  static const borderWidth = 1.0;
  static const outlineButtonBorderWidth = 1.5;
  static const iconSmall = 16.0;
  static const icon = 20.0;
  static const iconLarge = 24.0;
  static const avatarSmall = 44.0;
  static const avatar = 54.0;
  static const statusDot = 10.0;
  static const creditsDot = 14.0;
  static const stepCircle = 34.0;
  static const progressStroke = 2.0;
  static const dashLength = 6.0;
  static const dashGap = 4.0;
  static const dashStroke = 2.0;
  static const shadowBlur = 24.0;
  static const shadowOffsetY = 8.0;
  static const navBarHeight = 72.0;
  static const navPillHeight = 46.0;
  static const roundButton = 44.0;
  static const appBarPillLeadingWidth = 112.0;
  static const sliderThumbRadius = 12.0;
  static const sliderThumbStroke = 3.0;
  static const sliderTrackHeight = 6.0;
  static const captureFrame = 200.0;
  static const captureIcon = 44.0;
  static const otpFieldWidth = 220.0;
  static const actionButton = 56.0;
  static const feedAvatar = 36.0;
  static const feedDot = 6.0;
  static const stateViewHeight = 320.0;
  static const mapHeight = 300.0;
  static const mapPin = 34.0;
  static const userDot = 20.0;
  static const mapRoadWidth = 18.0;
  static const mapZoom = 12.5;
  static const heatRadiusPx = 40;
  static const rankCircle = 40.0;
  static const actionElevation = 4.0;
  static const profilePhotoHeight = 240.0;
  static const mapHeroHeight = 168.0;
  static const stepBarHeight = 5.0;
  static const iconWell = 44.0;
}

/// Animation timings.
abstract final class AppDurations {
  static const short = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
}

/// Proportions used by drawn placeholders (fractions of the available size).
abstract final class AppRatios {
  static const placeholderBlob = 0.75;
  static const placeholderBlobSecondary = 0.8;
  static const placeholderBlobOffsetX = 0.35;
  static const placeholderBlobOffsetY = 0.3;
  static const placeholderInitial = 0.28;
  static const avatarInitial = 0.45;

  /// ID-1 card (Aadhaar, licence) width / height.
  static const idCard = 1.586;

  /// Opacity of actions that are shown but not available yet.
  static const disabledOpacity = 0.4;

  /// Share of the Discover page height given to the card deck.
  /// Feed photos are 4:5, like a post.
  static const feedPhoto = 4 / 5;

  /// Share of the drawn map's half-size used by the 5 km ring.
  static const mapRingShare = 0.85;

  /// Heat blob radius as a share of the ring radius, and its peak opacity.
  static const heatBlobShare = 0.35;
  static const heatAlpha = 0.55;

  /// Minimum heat weight so quiet venues still show faintly.
  static const heatFloor = 0.1;

  /// Widest a chat bubble may be, as a share of the screen width.
  static const bubbleMaxWidth = 0.75;

  /// Decorative roads on the drawn map, as (x1, y1, x2, y2) fractions of its size.
  static const mapRoads = [
    (0.0, 0.28, 1.0, 0.2),
    (0.0, 0.68, 1.0, 0.58),
    (0.3, 0.0, 0.34, 1.0),
    (0.68, 0.0, 0.62, 1.0),
  ];
}
