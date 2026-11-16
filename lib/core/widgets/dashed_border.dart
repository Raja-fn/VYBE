import 'package:flutter/widgets.dart';

import '../theme/app_dimens.dart';

/// Draws a dashed rounded-rectangle border around [child].
///
/// Used for disabled time slots and the selfie frame.
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    required this.child,
    required this.color,
    required this.borderRadius,
    this.strokeWidth = AppSizes.borderWidth,
    super.key,
  });

  final Widget child;
  final Color color;
  final BorderRadius borderRadius;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color: color, borderRadius: borderRadius, strokeWidth: strokeWidth),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.borderRadius, required this.strokeWidth});

  final Color color;
  final BorderRadius borderRadius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(inset, inset, size.width - strokeWidth, size.height - strokeWidth);
    // scaleRadii() shrinks oversized (pill) radii so they fit the rect.
    final rrect = borderRadius.resolve(TextDirection.ltr).toRRect(rect).scaleRadii();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + AppSizes.dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + AppSizes.dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.borderRadius != borderRadius || oldDelegate.strokeWidth != strokeWidth;
}
