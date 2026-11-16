import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/connectivity/connectivity_service.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/segmented_choice.dart';
import '../../booking/domain/booking_models.dart';
import '../domain/companion_summary.dart';
import 'discover_providers.dart';
import 'widgets/companion_row.dart';
import 'widgets/discovery_state_view.dart';
import 'widgets/labels.dart';

/// Screen 7: companions free in the next 2 hours, tonight or tomorrow.
class FreeNowScreen extends ConsumerStatefulWidget {
  const FreeNowScreen({super.key});

  @override
  ConsumerState<FreeNowScreen> createState() => _FreeNowScreenState();
}

class _FreeNowScreenState extends ConsumerState<FreeNowScreen> {
  FreeWindow _window = FreeWindow.next2h;

  /// The companion chosen for an instant request.
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final config = ref.watch(appConfigProvider);
    final results = ref.watch(freeNowResultsProvider(_window));
    // Only keep a selection that is still in the current list.
    final selectedUid = (results.value ?? const []).any((c) => c.uid == _selected) ? _selected : null;

    final list = results.value;
    final hasRows = results.hasValue && list != null && list.isNotEmpty;
    const gutter = EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter);

    // One scrolling page (header, rows, then the instant-request card), so
    // nothing is squeezed on small phones with large text.
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            if (!ref.watch(isOnlineValueProvider)) const SliverToBoxAdapter(child: OfflineBanner()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, AppSpacing.md, AppSpacing.screenGutter, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBackButton(onPressed: () => context.go(AppRoutes.discover)),
                    const SizedBox(height: AppSpacing.md),
                    Semantics(header: true, child: Text(l10n.freeNowTitle, style: textTheme.headlineLarge)),
                    Text(
                      l10n.freeNowSubtitle(config.discoveryRadiusKm),
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SegmentedChoice<FreeWindow>(
                      values: FreeWindow.values,
                      selected: _window,
                      labelOf: (window) => freeWindowLabel(l10n, window),
                      onSelected: (window) => setState(() {
                        _window = window;
                        _selected = null;
                      }),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            if (hasRows)
              SliverPadding(
                padding: gutter,
                sliver: SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => CompanionRow(
                    companion: list[i],
                    selected: list[i].uid == _selected,
                    onOpen: () => setState(() => _selected = list[i].uid),
                    onViewProfile: () => context.push(AppRoutes.companion(list[i].uid)),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: SizedBox(
                  height: AppSizes.stateViewHeight,
                  child: DiscoveryStateView<List<CompanionSummary>>(
                    value: results,
                    onRetry: () => ref.invalidate(freeNowResultsProvider(_window)),
                    isEmpty: (rows) => rows.isEmpty,
                    emptyTitle: l10n.freeNowEmptyTitle,
                    emptyMessage: l10n.freeNowEmptyBody,
                    builder: (context, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.screenGutter),
              sliver: SliverToBoxAdapter(
                child: AppCard(
                  tone: AppCardTone.dark,
                  // Side by side when it fits; the button drops below on small phones.
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.instantTitle, style: textTheme.titleMedium?.copyWith(color: AppColors.onInk)),
                          Text(
                            l10n.instantBody(config.creditCostInstantRequest),
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.onInkMuted),
                          ),
                          if (selectedUid == null)
                            Text(
                              l10n.freeNowSelectHint,
                              style: textTheme.bodySmall?.copyWith(color: AppColors.onInkMuted),
                            ),
                        ],
                      ),
                      AppButton(
                        label: l10n.instantPickSpot,
                        onPressed: selectedUid == null
                            ? null
                            : () => context.push(
                                AppRoutes.book(companionUid: selectedUid, kind: BookingKind.instant.name),
                              ),
                        variant: AppButtonVariant.bright,
                        expand: false,
                      ),
                    ],
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
