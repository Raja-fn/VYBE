import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/location/location_service.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_pill_button.dart';
import '../../booking/domain/booking_models.dart';
import '../../booking/presentation/booking_providers.dart';
import '../../booking/presentation/widgets/venue_labels.dart';
import '../../discover/domain/companion_summary.dart';
import '../../discover/presentation/widgets/discovery_state_view.dart';
import 'widgets/venue_map.dart';

/// Screen 5: an interactive map of nearby spots and "Best spots to meet".
///
/// - [pickMode]: "Pick" returns the venue id to the screen that opened it.
/// - [companionUid] without [pickMode]: "Pick" opens Book your spot with
///   that companion and venue.
/// - Neither: the list is for looking only.
///
/// Tapping a pin selects the spot and shows it in a card on the map; tapping a
/// row in the list flies the map to that spot.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({this.companionUid, this.plan, this.pickMode = false, super.key});

  final String? companionUid;
  final PlanType? plan;
  final bool pickMode;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _map = MapController();
  String? _selectedId;

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  void _select(Venue? venue, {bool fly = false}) {
    setState(() => _selectedId = venue?.venueId);
    if (venue != null && fly) _map.move(LatLng(venue.lat, venue.lng), math.max(_map.camera.zoom, 14));
  }

  void _recenter(DevicePosition me) {
    setState(() => _selectedId = null);
    _map.move(LatLng(me.lat, me.lng), VenueMap.initialZoom);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final plan = widget.plan;
    final companionUid = widget.companionUid;
    final radiusKm = ref.watch(appConfigProvider).discoveryRadiusKm;
    final venues = ref.watch(nearbyVenuesProvider(plan: plan, companionUid: companionUid));
    final position = ref.watch(myPositionProvider);

    void back() => context.canPop() ? context.pop() : context.go(AppRoutes.discover);

    VoidCallback? pickFor(Venue venue) {
      if (widget.pickMode) return () => context.pop(venue.venueId);
      if (companionUid == null) return null;
      return () => context.push(AppRoutes.book(companionUid: companionUid, plan: plan, venueId: venue.venueId));
    }

    final list = venues.value;
    final center = position.value;
    final ready = list != null && center != null;
    final selected = list?.where((v) => v.venueId == _selectedId).firstOrNull;
    final mapHeight = MediaQuery.sizeOf(context).height * AppRatios.mapShare;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: mapHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (ready)
                  VenueMap(
                    center: center,
                    venues: list,
                    radiusKm: radiusKm,
                    controller: _map,
                    selectedId: _selectedId,
                    onSelect: _select,
                  )
                else
                  const ColoredBox(color: AppColors.mapLand),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: AppBackButton(onPressed: back),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: _MapChip(text: l10n.mapWithinKm(radiusKm)),
                        ),
                        if (selected != null)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              // Leaves room for the map credit in the corner.
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: VenueRow(venue: selected, onPick: pickFor(selected), selected: true),
                            ),
                          )
                        else if (center != null)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                              child: AppRoundIconButton(
                                label: l10n.mapRecenter,
                                icon: Icons.my_location,
                                onPressed: () => _recenter(center),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenGutter,
                    AppSpacing.lg,
                    AppSpacing.screenGutter,
                    AppSpacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Semantics(header: true, child: Text(l10n.mapBestSpots, style: textTheme.headlineSmall)),
                        Text(l10n.mapToday, style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
                if (list != null && list.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenGutter,
                      0,
                      AppSpacing.screenGutter,
                      AppSpacing.xl,
                    ),
                    sliver: SliverList.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) => VenueRow(
                        venue: list[i],
                        onPick: pickFor(list[i]),
                        selected: list[i].venueId == _selectedId,
                        onTap: () => _select(list[i], fly: true),
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: AppSizes.stateViewHeight,
                      child: DiscoveryStateView<List<Venue>>(
                        value: venues,
                        onRetry: () {
                          ref
                            ..invalidate(nearbyVenuesProvider(plan: plan, companionUid: companionUid))
                            ..invalidate(myPositionProvider);
                        },
                        isEmpty: (items) => items.isEmpty,
                        emptyTitle: l10n.mapNoVenuesTitle,
                        emptyMessage: l10n.mapNoVenuesBody,
                        builder: (context, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One "Best spots to meet" row: rank, name, "Cafe · 1.2 km · Hot now", Pick.
class VenueRow extends StatelessWidget {
  const VenueRow({required this.venue, required this.onPick, this.selected = false, this.onTap, super.key});

  final Venue venue;
  final VoidCallback? onPick;
  final bool selected;

  /// Shows the spot on the map.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final pick = onPick;
    return AppCard(
      tone: selected ? AppCardTone.highlighted : AppCardTone.light,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          RankCircle(rank: venue.rank),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name, style: textTheme.titleLarge),
                Text(venueLine(l10n, venue), style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          if (pick != null) ...[
            const SizedBox(width: AppSpacing.xs),
            AppPillButton(
              label: l10n.mapPick,
              semanticLabel: l10n.mapPickSemantics(venue.name),
              tone: AppPillTone.accent,
              onPressed: pick,
            ),
          ],
        ],
      ),
    );
  }
}

/// Numbered circle; the top spot is accent, the rest ink.
class RankCircle extends StatelessWidget {
  const RankCircle({required this.rank, super.key});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.rankCircle,
      height: AppSizes.rankCircle,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: rank == 1 ? AppColors.accent : AppColors.softFill,
        shape: BoxShape.circle,
        border: Border.all(color: rank == 1 ? AppColors.accent : AppColors.track),
      ),
      child: Text(
        '$rank',
        textScaler: TextScaler.noScaling,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: rank == 1 ? AppColors.onAccent : AppColors.ink),
      ),
    );
  }
}

class _MapChip extends StatelessWidget {
  const _MapChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const ShapeDecoration(color: AppColors.card, shape: StadiumBorder()),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    ),
  );
}
