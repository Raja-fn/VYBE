import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Dark pill with a green shield: "Verified".
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return _BadgePill(
      leading: const Icon(Icons.verified_user_outlined, size: AppSizes.iconSmall, color: AppColors.success),
      label: context.l10n.badgeVerified,
    );
  }
}

/// Dark pill with a green dot: "Free now".
class FreeNowBadge extends StatelessWidget {
  const FreeNowBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return _BadgePill(
      leading: const SizedBox.square(
        dimension: AppSizes.statusDot,
        child: DecoratedBox(
          decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
        ),
      ),
      label: context.l10n.badgeFreeNow,
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.leading, required this.label});

  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: const ShapeDecoration(
          color: AppColors.photoOverlay,
          shape: StadiumBorder(side: BorderSide(color: AppColors.violetWell)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header pill showing the credit balance. Tapping opens credits and plans.
class CreditsPill extends StatelessWidget {
  const CreditsPill({required this.credits, required this.onPressed, super.key});

  final int credits;

  /// Null while the credits screen is not available.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: onPressed != null,
      label: onPressed != null ? l10n.creditsPillSemantics(credits) : l10n.creditsCount(credits),
      excludeSemantics: true,
      child: Material(
        color: AppColors.inkRaised,
        shape: const StadiumBorder(side: BorderSide(color: AppColors.track)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox.square(
                    dimension: AppSizes.creditsDot,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('$credits', style: textTheme.titleMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small white card with a big value and a label: "4.8 Rating".
class StatTile extends StatelessWidget {
  const StatTile({required this.value, required this.label, this.dark = false, super.key});

  final String value;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? AppColors.softFill : AppColors.card,
          borderRadius: AppRadii.cardBorder,
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: textTheme.headlineMedium?.copyWith(color: dark ? AppColors.onInk : AppColors.ink),
                textAlign: TextAlign.center,
              ),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(color: dark ? AppColors.onInkMuted : AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
