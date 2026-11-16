import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// One dark bar split into equal choices; the chosen one is a coral pill
/// ("Next 2 hrs | Tonight | Tomorrow", "Everyone | Women | Men").
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    super.key,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: const ShapeDecoration(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardBorder,
          side: BorderSide(color: AppColors.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxs + 2),
        child: Row(
          children: [
            for (final value in values)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: value == selected,
                  inMutuallyExclusiveGroup: true,
                  label: labelOf(value),
                  excludeSemantics: true,
                  child: Material(
                    color: value == selected ? AppColors.accent : Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(AppRadii.avatar)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onSelected(value),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs, vertical: AppSpacing.xs),
                            child: Text(
                              labelOf(value),
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: value == selected ? AppColors.onAccent : AppColors.muted,
                                fontWeight: value == selected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
