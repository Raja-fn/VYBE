import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/config/maps_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../booking/domain/booking_models.dart';

/// The spots map: a 5 km ring around the person, a popularity heat layer
/// and numbered venue pins. Venue positions are public; the only personal
/// position shown is the viewer's own.
class VenueMap extends StatelessWidget {
  const VenueMap({required this.center, required this.venues, required this.radiusKm, super.key});

  final DevicePosition center;
  final List<Venue> venues;
  final int radiusKm;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.mapSemantics(radiusKm),
      // The list below the map carries the same information for screen readers.
      child: ExcludeSemantics(
        child: MapsConfig.enabled
            ? _GoogleVenueMap(center: center, venues: venues, radiusKm: radiusKm)
            : _DrawnVenueMap(center: center, venues: venues, radiusKm: radiusKm),
      ),
    );
  }
}

Color _heatColor(PopularityLabel label) => switch (label) {
  PopularityLabel.hot => AppColors.accent,
  PopularityLabel.busy => AppColors.gold,
  PopularityLabel.quiet => AppColors.border,
};

class _GoogleVenueMap extends StatelessWidget {
  const _GoogleVenueMap({required this.center, required this.venues, required this.radiusKm});

  final DevicePosition center;
  final List<Venue> venues;
  final int radiusKm;

  @override
  Widget build(BuildContext context) {
    final me = LatLng(center.lat, center.lng);
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: me, zoom: AppSizes.mapZoom),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      circles: {
        Circle(
          circleId: const CircleId('radius'),
          center: me,
          radius: radiusKm * 1000.0,
          strokeColor: AppColors.accent,
          strokeWidth: AppSizes.dashStroke.toInt(),
        ),
      },
      heatmaps: {
        if (venues.isNotEmpty)
          Heatmap(
            heatmapId: const HeatmapId('popularity'),
            data: [
              for (final v in venues)
                WeightedLatLng(LatLng(v.lat, v.lng), weight: v.popularityScore + AppRatios.heatFloor),
            ],
            radius: const HeatmapRadius.fromPixels(AppSizes.heatRadiusPx),
          ),
      },
      markers: {
        for (final v in venues)
          Marker(
            markerId: MarkerId(v.venueId),
            position: LatLng(v.lat, v.lng),
            infoWindow: InfoWindow(title: '${v.rank}. ${v.name}'),
          ),
      },
    );
  }
}

/// Drawn map used when no Google Maps key is configured.
class _DrawnVenueMap extends StatelessWidget {
  const _DrawnVenueMap({required this.center, required this.venues, required this.radiusKm});

  final DevicePosition center;
  final List<Venue> venues;
  final int radiusKm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        final pxPerKm = size.shortestSide / 2 * AppRatios.mapRingShare / radiusKm;
        Offset project(double lat, double lng) {
          final dxKm = (lng - center.lng) * _kmPerDegree * math.cos(center.lat * math.pi / 180);
          final dyKm = (lat - center.lat) * _kmPerDegree;
          return size.center(Offset.zero) + Offset(dxKm * pxPerKm, -dyKm * pxPerKm);
        }

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MapPainter(
                  center: size.center(Offset.zero),
                  ringRadius: radiusKm * pxPerKm,
                  heat: [for (final v in venues) (project(v.lat, v.lng), _heatColor(v.popularityLabel))],
                ),
              ),
            ),
            for (final v in venues) _pin(project(v.lat, v.lng), v.rank, textTheme),
            Positioned(
              left: size.width / 2 - AppSizes.userDot / 2,
              top: size.height / 2 - AppSizes.userDot / 2,
              child: const _UserDot(),
            ),
          ],
        );
      },
    );
  }

  Widget _pin(Offset at, int rank, TextTheme textTheme) => Positioned(
    left: at.dx - AppSizes.mapPin / 2,
    top: at.dy - AppSizes.mapPin / 2,
    child: Container(
      width: AppSizes.mapPin,
      height: AppSizes.mapPin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: rank == 1 ? AppColors.accent : AppColors.knob,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: AppSizes.outlineButtonBorderWidth * 2),
      ),
      child: Text(
        '$rank',
        textScaler: TextScaler.noScaling,
        style: textTheme.titleSmall?.copyWith(color: AppColors.onAccent),
      ),
    ),
  );

  static const _kmPerDegree = 111.32;
}

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) => Container(
    width: AppSizes.userDot,
    height: AppSizes.userDot,
    decoration: BoxDecoration(
      color: AppColors.mapUserDot,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.card, width: AppSizes.outlineButtonBorderWidth * 2),
    ),
  );
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.center, required this.ringRadius, required this.heat});

  final Offset center;
  final double ringRadius;
  final List<(Offset, Color)> heat;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.mapLand);

    // A few soft "roads" so the drawing reads as a map.
    final road = Paint()
      ..color = AppColors.mapRoad
      ..strokeWidth = AppSizes.mapRoadWidth;
    for (final (x1, y1, x2, y2) in AppRatios.mapRoads) {
      canvas.drawLine(Offset(size.width * x1, size.height * y1), Offset(size.width * x2, size.height * y2), road);
    }

    final blob = ringRadius * AppRatios.heatBlobShare;
    for (final (at, color) in heat) {
      canvas.drawCircle(
        at,
        blob,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: AppRatios.heatAlpha),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: at, radius: blob)),
      );
    }

    final ring = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSizes.dashStroke;
    final path = Path()..addOval(Rect.fromCircle(center: center, radius: ringRadius));
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + AppSizes.dashLength * 2), ring);
        d += AppSizes.dashLength * 2 + AppSizes.dashGap * 2;
      }
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.center != center || old.ringRadius != ringRadius || old.heat != heat;
}
