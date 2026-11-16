import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

enum AppButtonVariant {
  /// Accent fill: "I agree, continue", "Confirm spot".
  primary,

  /// Dark raised pill: "Chat", "Decline", "Report".
  outline,

  /// Second coral call to action inside cards: "Book", "Withdraw".
  gold,

  /// White pill with dark text on a tinted card: "Pick spot".
  bright,

  /// Green fill with dark text: "I am safe, check in".
  successOutline,
}

/// Full-height (52) pill button used for every main action.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.expand = true,
    this.icon,
    super.key,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final callback = enabled ? onPressed : null;
    final child = _ButtonContent(label: label, icon: icon, isLoading: isLoading, spinnerColor: _foreground);

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(onPressed: callback, child: child),
      AppButtonVariant.gold => FilledButton(onPressed: callback, child: child),
      AppButtonVariant.bright => FilledButton(
        onPressed: callback,
        style: FilledButton.styleFrom(backgroundColor: AppColors.knob, foregroundColor: AppColors.onAccent),
        child: child,
      ),
      AppButtonVariant.outline => OutlinedButton(onPressed: callback, child: child),
      AppButtonVariant.successOutline => FilledButton(
        onPressed: callback,
        style: FilledButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: AppColors.onSuccess),
        child: child,
      ),
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: isLoading ? '$label, ${context.l10n.commonLoading}' : null,
      excludeSemantics: isLoading,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }

  Color get _foreground => switch (variant) {
    AppButtonVariant.primary => AppColors.onAccent,
    AppButtonVariant.gold => AppColors.onAccent,
    AppButtonVariant.bright => AppColors.onAccent,
    AppButtonVariant.outline => AppColors.ink,
    AppButtonVariant.successOutline => AppColors.onSuccess,
  };
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, required this.icon, required this.isLoading, required this.spinnerColor});

  final String label;
  final IconData? icon;
  final bool isLoading;
  final Color spinnerColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: AppSizes.iconSmall,
        child: CircularProgressIndicator(strokeWidth: AppSizes.progressStroke, color: spinnerColor),
      );
    }
    final text = Text(label, textAlign: TextAlign.center);
    final leading = icon;
    if (leading == null) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(leading, size: AppSizes.iconSmall),
        const SizedBox(width: AppSpacing.xs),
        Flexible(child: text),
      ],
    );
  }
}
