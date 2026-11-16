import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
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

/// Screen 5: the 5 km heatmap and "Best spots to meet".
///
/// - [pickMode]: "Pick" returns the venue id to the screen that opened it.
/// - [companionUid] without [pickMode]: "Pick" opens Book your spot with
///   that companion and venue.
/// - Neither: the list is for looking only.
class MapScreen extends ConsumerWidget {
  const MapScreen({this.companionUid, this.plan, this.pickMode = false, super.key});

  final String? companionUid;
  final PlanType? plan;
  final bool pickMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final radiusKm = ref.watch(appConfigProvider).discoveryRadiusKm;
    final venues = ref.watch(nearbyVenuesProvider(plan: plan, companionUid: companionUid));
    final position = ref.watch(myPositionProvider);
    final uid = companionUid;

    void back() => context.canPop() ? context.pop() : context.go(AppRoutes.discover);

    VoidCallback? pickFor(Venue venue) {
      if (pickMode) return () => context.pop(venue.venueId);
      if (uid == null) return null;
      return () => context.push(AppRoutes.book(companionUid: uid, plan: plan, venueId: venue.venueId));
    }

    final list = venues.value;
    final center = position.value;
    final ready = list != null && center != null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppSizes.mapHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (ready)
                    VenueMap(center: center, venues: list, radiusKm: radiusKm)
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
                          const Align(alignment: Alignment.bottomLeft, child: _Legend()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, 0, AppSpacing.screenGutter, AppSpacing.xl),
              sliver: SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) => VenueRow(venue: list[i], onPick: pickFor(list[i])),
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
    );
  }
}

/// One "Best spots to meet" row: rank, name, "Cafe · 1.2 km · Hot now", Pick.
class VenueRow extends StatelessWidget {
  const VenueRow({required this.venue, required this.onPick, super.key});

  final Venue venue;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final pick = onPick;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          RankCircle(rank: venue.rank),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
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

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    Widget row(Color color, String label) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: AppSizes.creditsDot,
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(child: Text(label, style: textTheme.titleSmall)),
        ],
      ),
    );
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.card, borderRadius: AppRadii.cardBorder),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row(AppColors.accent, l10n.mapLegendHot),
            row(AppColors.gold, l10n.mapLegendBusy),
            row(AppColors.border, l10n.mapLegendQuiet),
          ],
        ),
      ),
    );
  }
}
