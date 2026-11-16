import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

enum AppPillTone {
  /// Dark raised pill: "Map", "Within 5 km".
  light,

  /// White pill with dark text: "Pick spot" on a highlighted card.
  bright,

  /// Soft fill: "Edit", chat "Back".
  soft,

  /// On dark cards: "Change".
  raised,

  /// Accent-colored text: "Report".
  accentText,

  /// Accent fill: "Pick".
  accent,
}

/// Compact pill button (at least 44 tall) for secondary actions.
class AppPillButton extends StatelessWidget {
  const AppPillButton({
    required this.label,
    required this.onPressed,
    this.tone = AppPillTone.light,
    this.icon,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppPillTone tone;
  final IconData? icon;

  /// Extra context for screen readers, e.g. "Pick Cafe Name".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = switch (tone) {
      AppPillTone.light => (AppColors.inkRaised, AppColors.ink, AppColors.track),
      AppPillTone.bright => (AppColors.knob, AppColors.onAccent, AppColors.knob),
      AppPillTone.soft => (AppColors.softFill, AppColors.ink, AppColors.track),
      AppPillTone.raised => (AppColors.inkRaised, AppColors.onInk, AppColors.track),
      AppPillTone.accentText => (AppColors.softFill, AppColors.accent, AppColors.track),
      AppPillTone.accent => (AppColors.accent, AppColors.onAccent, AppColors.accent),
    };
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(color: foreground);
    final leading = icon;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: Material(
        color: background,
        shape: StadiumBorder(side: BorderSide(color: border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget, minWidth: AppSizes.minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    Icon(leading, size: AppSizes.icon, color: foreground),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(child: Text(label, style: textStyle)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
