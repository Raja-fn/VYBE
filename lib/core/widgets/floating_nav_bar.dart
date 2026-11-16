import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// One tab of [FloatingNavBar].
class FloatingNavItem {
  const FloatingNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Rounded bar floating above the bottom edge. The current tab is a coral pill
/// with its icon and name; the others show their icon only (name in a tooltip
/// and for screen readers).
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({required this.items, required this.currentIndex, required this.onSelected, super.key});

  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenGutter,
          AppSpacing.xs,
          AppSpacing.screenGutter,
          AppSpacing.md,
        ),
        child: DecoratedBox(
          decoration: const ShapeDecoration(
            color: AppColors.card,
            shape: StadiumBorder(side: BorderSide(color: AppColors.border)),
            shadows: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: AppSizes.shadowBlur,
                offset: Offset(0, AppSizes.shadowOffsetY),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  i == currentIndex
                      ? _ActiveTab(item: items[i])
                      : Expanded(
                          child: _Tab(item: items[i], onTap: () => onSelected(i)),
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveTab extends StatelessWidget {
  const _ActiveTab({required this.item});

  final FloatingNavItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: true,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppDurations.medium,
        height: AppSizes.navPillHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: const ShapeDecoration(color: AppColors.accent, shape: StadiumBorder()),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: AppColors.onAccent, size: AppSizes.icon),
            const SizedBox(width: AppSpacing.xs),
            Text(
              item.label,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.onTap});

  final FloatingNavItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.label,
      child: Semantics(
        button: true,
        label: item.label,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: AppSizes.navPillHeight / 2,
          child: SizedBox(
            height: AppSizes.navPillHeight,
            child: Icon(item.icon, color: AppColors.muted, size: AppSizes.icon),
          ),
        ),
      ),
    );
  }
}
