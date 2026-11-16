import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Round dark button with a left chevron, top-left on pushed screens.
class AppBackButton extends StatelessWidget {
  const AppBackButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      AppRoundIconButton(icon: Icons.chevron_left, label: context.l10n.commonBack, onPressed: onPressed);
}

/// Round dark icon button: back, map, filters, report, save.
class AppRoundIconButton extends StatelessWidget {
  const AppRoundIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color = AppColors.ink,
    super.key,
  });

  final IconData icon;

  /// Tooltip and screen-reader name.
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: AppColors.inkRaised,
          shape: const CircleBorder(side: BorderSide(color: AppColors.track)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox.square(
              dimension: AppSizes.roundButton,
              child: Icon(icon, color: color, size: AppSizes.iconLarge),
            ),
          ),
        ),
      ),
    );
  }
}
