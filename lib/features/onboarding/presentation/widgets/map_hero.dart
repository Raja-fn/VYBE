import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// Decorative map on the first screen: you, two glowing meetup spots inside
/// a dashed 5 km ring, and a "Verified public spots only" tag. A drawing, not
/// a live map, so it costs nothing to show.
class MapHero extends StatelessWidget {
  const MapHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: AppRadii.photoCardBorder,
        child: SizedBox(
          height: AppSizes.mapHeroHeight,
          child: Stack(
            children: [
              const Positioned.fill(child: CustomPaint(painter: _HeroPainter())),
              const Align(alignment: Alignment(-0.42, -0.55), child: _Pin(number: 1, accent: true)),
              const Align(alignment: Alignment(0.45, -0.05), child: _Pin(number: 2, accent: false)),
              const Align(child: _You()),
              Positioned(
                left: AppSpacing.md,
                bottom: AppSpacing.md,
                child: DecoratedBox(
                  decoration: const ShapeDecoration(
                    color: AppColors.background,
                    shape: StadiumBorder(side: BorderSide(color: AppColors.border)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_outlined, size: AppSizes.iconSmall, color: AppColors.success),
                        const SizedBox(width: AppSpacing.xs),
                        Text(context.l10n.mapHeroTag, style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _You extends StatelessWidget {
  const _You();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: AppColors.violetWell, shape: BoxShape.circle),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.knob,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(BorderSide(color: AppColors.violet, width: 5)),
          ),
          child: SizedBox.square(dimension: AppSizes.userDot),
        ),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.number, required this.accent});

  final int number;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final fill = accent ? AppColors.accent : AppColors.knob;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizes.mapPin,
          height: AppSizes.mapPin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.background, width: AppSizes.outlineButtonBorderWidth * 2),
          ),
          child: Text(
            '$number',
            textScaler: TextScaler.noScaling,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onAccent),
          ),
        ),
        CustomPaint(size: const Size(AppSpacing.md, AppSpacing.xs), painter: _PinTip(fill)),
      ],
    );
  }
}

class _PinTip extends CustomPainter {
  const _PinTip(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PinTip oldDelegate) => oldDelegate.color != color;
}

class _HeroPainter extends CustomPainter {
  const _HeroPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.mapLand);

    // Water in the corners.
    final water = Paint()..color = AppColors.violetWell;
    canvas
      ..drawCircle(Offset(size.width * 1.02, size.height * 0.05), size.height * 0.45, water)
      ..drawCircle(Offset(size.width * 0.98, size.height * 1.05), size.height * 0.35, water);

    // Streets.
    final road = Paint()
      ..color = AppColors.mapRoad
      ..strokeWidth = AppSizes.mapRoadWidth * 0.6;
    for (final (x1, y1, x2, y2) in const [
      (0.0, 0.48, 1.0, 0.12),
      (0.0, 0.88, 1.0, 0.7),
      (0.27, 0.0, 0.42, 1.0),
      (0.72, 0.0, 0.88, 1.0),
      (0.0, 0.2, 0.55, 0.0),
    ]) {
      canvas.drawLine(Offset(x1 * size.width, y1 * size.height), Offset(x2 * size.width, y2 * size.height), road);
    }

    // Warm glow where people meet.
    void glow(Offset at, double radius) {
      canvas.drawCircle(
        at,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.55),
              AppColors.violet.withValues(alpha: 0.18),
              AppColors.mapLand.withValues(alpha: 0),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(Rect.fromCircle(center: at, radius: radius)),
      );
    }

    glow(Offset(size.width * 0.3, size.height * 0.32), size.height * 0.5);
    glow(Offset(size.width * 0.72, size.height * 0.55), size.height * 0.45);

    // Dashed 5 km ring around you.
    final center = size.center(Offset.zero);
    final radius = size.height * 0.4;
    final dash = Paint()
      ..color = AppColors.muted
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSizes.dashStroke * 0.75;
    const segments = 40;
    for (var i = 0; i < segments; i += 2) {
      final start = i * 2 * math.pi / segments;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, 2 * math.pi / segments, false, dash);
    }
  }

  @override
  bool shouldRepaint(_HeroPainter oldDelegate) => false;
}
