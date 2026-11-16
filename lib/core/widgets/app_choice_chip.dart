import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'dashed_border.dart';

/// Selectable pill chip.
///
/// Selected: ink fill, white text. Unselected: white fill with border.
/// Disabled (for example a full time slot): dashed border, struck-through text.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final bool enabled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isOn = selected && enabled;
    final foreground = !enabled
        ? AppColors.muted
        : isOn
        ? AppColors.onAccent
        : AppColors.ink;

    final text = Text(
      label,
      style: textTheme.bodyLarge?.copyWith(
        color: foreground,
        fontWeight: isOn ? FontWeight.w600 : FontWeight.w400,
        decoration: enabled ? null : TextDecoration.lineThrough,
        decorationColor: AppColors.muted,
      ),
    );

    final padded = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget, minWidth: AppSizes.minTouchTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        child: Center(widthFactor: 1, child: text),
      ),
    );

    final Widget chip;
    if (!enabled) {
      chip = DashedBorder(borderRadius: AppRadii.pillBorder, color: AppColors.border, child: padded);
    } else {
      chip = AnimatedContainer(
        duration: AppDurations.short,
        decoration: ShapeDecoration(
          color: isOn ? AppColors.accent : AppColors.softFill,
          shape: StadiumBorder(side: BorderSide(color: isOn ? AppColors.accent : AppColors.track)),
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: onSelected, child: padded),
        ),
      );
    }

    return Semantics(
      button: true,
      selected: isOn,
      enabled: enabled,
      inMutuallyExclusiveGroup: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: chip,
    );
  }
}
