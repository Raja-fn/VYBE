import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';
import 'outlined_range_thumb_shape.dart';

/// The only theme: the dark FindX design language.
abstract final class AppTheme {
  static const _colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    secondary: AppColors.violet,
    onSecondary: AppColors.onAccent,
    tertiary: AppColors.gold,
    onTertiary: AppColors.onGold,
    error: AppColors.danger,
    onError: AppColors.onAccent,
    surface: AppColors.background,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
    surfaceContainerLowest: AppColors.card,
    surfaceContainerLow: AppColors.card,
    surfaceContainer: AppColors.card,
    surfaceContainerHigh: AppColors.softFill,
    surfaceContainerHighest: AppColors.softFill,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
    shadow: AppColors.shadow,
    inverseSurface: AppColors.softFill,
    onInverseSurface: AppColors.ink,
  );

  static ThemeData light() {
    final textTheme = AppTypography.coloredTextTheme();
    const pillShape = StadiumBorder();
    const buttonMinSize = Size(AppSizes.minTouchTarget, AppSizes.primaryButtonHeight);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorScheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      iconTheme: const IconThemeData(color: AppColors.ink, size: AppSizes.icon),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: AppSizes.borderWidth,
        space: AppSizes.borderWidth,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardBorder,
          side: BorderSide(color: AppColors.border),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.track,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: AppColors.softFill,
          disabledForegroundColor: AppColors.muted,
          minimumSize: buttonMinSize,
          shape: pillShape,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.softFill,
          minimumSize: buttonMinSize,
          shape: pillShape,
          side: const BorderSide(color: AppColors.border),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          minimumSize: const Size(AppSizes.minTouchTarget, AppSizes.minTouchTarget),
          shape: pillShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(AppSizes.minTouchTarget, AppSizes.minTouchTarget),
          foregroundColor: AppColors.ink,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(AppColors.knob),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.success : AppColors.track,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbIcon: const WidgetStatePropertyAll(null),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.accent : AppColors.softFill,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.onAccent),
        side: const BorderSide(color: AppColors.border, width: AppSizes.outlineButtonBorderWidth),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSpacing.xs))),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.track,
        thumbColor: AppColors.knob,
        overlayColor: AppColors.accentOverlay,
        trackHeight: AppSizes.sliderTrackHeight,
        rangeThumbShape: OutlinedRangeThumbShape(),
        showValueIndicator: ShowValueIndicator.never,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.pillBorder,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.pillBorder,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.pillBorder,
          borderSide: BorderSide(color: AppColors.accent, width: AppSizes.outlineButtonBorderWidth),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.pillBorder,
          borderSide: BorderSide(color: AppColors.danger),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        height: AppSizes.navBarHeight,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.bodyMedium?.copyWith(
            color: states.contains(WidgetState.selected) ? AppColors.accent : AppColors.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: AppSizes.icon,
            color: states.contains(WidgetState.selected) ? AppColors.accent : AppColors.muted,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.softFill,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.ink),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.track,
      ),
    );
  }
}
