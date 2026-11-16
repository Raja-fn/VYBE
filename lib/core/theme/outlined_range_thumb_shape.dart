import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

/// Range slider thumb from the design: white circle with an accent ring.
class OutlinedRangeThumbShape extends RangeSliderThumbShape {
  const OutlinedRangeThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size.fromRadius(AppSizes.sliderThumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final canvas = context.canvas;
    canvas
      ..drawCircle(center, AppSizes.sliderThumbRadius, Paint()..color = AppColors.knob)
      ..drawCircle(
        center,
        AppSizes.sliderThumbRadius - AppSizes.sliderThumbStroke / 2,
        Paint()
          ..color = isEnabled ? AppColors.knob : AppColors.muted
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppSizes.sliderThumbStroke,
      );
  }
}
