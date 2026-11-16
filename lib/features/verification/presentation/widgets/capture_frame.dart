import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/dashed_border.dart';

/// Dashed frame that shows where the face or ID should go.
///
/// Keeps its shape (square, or ID-card) as a minimum, and grows taller if
/// large text needs the room.
class CaptureFrame extends StatelessWidget {
  const CaptureFrame.selfie({required this.label, super.key}) : icon = Icons.person_outline, aspectRatio = 1;

  const CaptureFrame.document({required this.label, super.key})
    : icon = Icons.badge_outlined,
      aspectRatio = AppRatios.idCard;

  final String label;
  final IconData icon;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    if (aspectRatio == 1) return _SelfieFrame(label: label);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          width: width,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: width / aspectRatio),
            child: DashedBorder(
              color: AppColors.accent,
              strokeWidth: AppSizes.dashStroke,
              borderRadius: AppRadii.cardBorder,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: AppColors.card, borderRadius: AppRadii.cardBorder),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: AppSizes.captureIcon, color: AppColors.accent),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Circle with a dashed coral ring and a face silhouette.
class _SelfieFrame extends StatelessWidget {
  const _SelfieFrame({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    const outer = AppSizes.captureFrame;
    const ring = outer - AppSpacing.xl;
    const face = ring - AppSpacing.xl * 1.5;
    return Semantics(
      label: label,
      image: true,
      child: SizedBox.square(
        dimension: outer,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
              ),
              child: SizedBox.square(dimension: outer),
            ),
            const DashedBorder(
              color: AppColors.accent,
              strokeWidth: AppSizes.dashStroke,
              borderRadius: BorderRadius.all(Radius.circular(ring / 2)),
              child: SizedBox.square(dimension: ring),
            ),
            ClipOval(
              child: Container(
                width: face,
                height: face,
                color: AppColors.softFill,
                alignment: Alignment.bottomCenter,
                child: const Icon(Icons.person, size: face * 0.95, color: AppColors.track),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
