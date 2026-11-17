import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../booking/domain/booking_models.dart';

/// The spots map: drag, pinch to zoom, tap a numbered pin to select it.
/// Shows a 5 km ring around the person and their own position. Venue
/// positions are public; the only personal position shown is the viewer's.
///
/// Tiles come from OpenStreetMap (no key needed), darkened to match the app.
class VenueMap extends StatelessWidget {
  const VenueMap({
    required this.center,
    required this.venues,
    required this.radiusKm,
    required this.controller,
    required this.selectedId,
    required this.onSelect,
    super.key,
  });

  final DevicePosition center;
  final List<Venue> venues;
  final int radiusKm;
  final MapController controller;
  final String? selectedId;

  /// A pin was tapped (or the empty map, with null).
  final ValueChanged<Venue?> onSelect;

  /// Public OSM tiles: fine for light use. For heavy traffic, point this at a
  /// hosted tile provider (see README, "Map").
  static const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Zoom that fits the 5 km ring on a phone.
  static const initialZoom = 12.4;

  @override
  Widget build(BuildContext context) {
    final me = LatLng(center.lat, center.lng);
    // Selected pin drawn last, so it sits on top.
    final ordered = [...venues]..sort((a, b) => (a.venueId == selectedId ? 1 : 0) - (b.venueId == selectedId ? 1 : 0));
    return Semantics(
      label: context.l10n.mapSemantics(radiusKm),
      child: FlutterMap(
        mapController: controller,
        options: MapOptions(
          initialCenter: me,
          initialZoom: initialZoom,
          minZoom: 9,
          maxZoom: 18,
          backgroundColor: AppColors.mapLand,
          interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
          // Taps are resolved here rather than on each pin: the nearest pin
          // within finger reach is selected, anything else clears the selection.
          onTap: (tap, _) => onSelect(_pinAt(tap.relative)),
        ),
        children: [
          TileLayer(urlTemplate: _tileUrl, userAgentPackageName: 'com.vybe.app', tileBuilder: darkModeTileBuilder),
          CircleLayer(
            circles: [
              CircleMarker(
                point: me,
                radius: radiusKm * 1000.0,
                useRadiusInMeter: true,
                color: AppColors.accent.withValues(alpha: 0.06),
                borderColor: AppColors.accent,
                borderStrokeWidth: 1.5,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(point: me, width: AppSizes.userDot, height: AppSizes.userDot, child: const _UserDot()),
              for (final v in ordered)
                Marker(
                  point: LatLng(v.lat, v.lng),
                  width: AppSizes.minTouchTarget,
                  height: AppSizes.minTouchTarget,
                  child: _Pin(venue: v, selected: v.venueId == selectedId, onTap: () => onSelect(v)),
                ),
            ],
          ),
          // Credit required by OpenStreetMap's tile licence.
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              color: AppColors.card.withValues(alpha: 0.85),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
              child: Text(
                '© OpenStreetMap',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: TextScaler.noScaling,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Venue? _pinAt(Offset? at) {
    if (at == null) return null;
    final camera = controller.camera;
    Venue? nearest;
    var best = AppSizes.minTouchTarget / 2 + 8;
    for (final v in venues) {
      final d = (camera.latLngToScreenOffset(LatLng(v.lat, v.lng)) - at).distance;
      if (d < best) {
        best = d;
        nearest = v;
      }
    }
    return nearest;
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.venue, required this.selected, required this.onTap});

  final Venue venue;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = selected ? AppSizes.mapPin * 1.25 : AppSizes.mapPin;
    return Semantics(
      button: true,
      selected: selected,
      label: '${venue.rank}. ${venue.name}',
      excludeSemantics: true,
      onTap: onTap,
      child: IgnorePointer(
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected || venue.rank == 1 ? AppColors.accent : AppColors.knob,
              shape: BoxShape.circle,
              border: Border.all(color: selected ? AppColors.onInk : AppColors.background, width: 2),
            ),
            child: Text(
              '${venue.rank}',
              textScaler: TextScaler.noScaling,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.onAccent),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.mapUserDot,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.onInk, width: 2),
    ),
  );
}
