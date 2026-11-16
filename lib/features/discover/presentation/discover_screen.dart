import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/connectivity/connectivity_service.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_choice_chip.dart';
import '../../../core/widgets/app_pill_button.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/badges.dart';
import '../../chat/presentation/chat_actions_ui.dart';
import '../../onboarding/domain/session_stage.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../../preferences/domain/preferences.dart';
import '../../preferences/presentation/preferences_providers.dart';
import '../domain/companion_summary.dart';
import 'discover_controller.dart';
import 'discover_providers.dart';
import 'widgets/discovery_state_view.dart';
import 'widgets/feed_post.dart';
import 'widgets/labels.dart';

/// Screen 4: plan chips, then a scrolling feed of people (photos, details,
/// Message / Save). Scrolling past someone is the skip.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(discoverControllerProvider);
    final controller = ref.read(discoverControllerProvider.notifier);
    final results = ref.watch(discoverResultsProvider(state.plan));
    final online = ref.watch(isOnlineValueProvider);
    final credits = ref.watch(creditBalanceProvider).value ?? 0;
    final stage = ref.watch(sessionStageProvider).value;
    final account = stage is Ready ? stage.account : null;
    final showMe = account == null ? null : ref.watch(preferencesProvider(account.uid)).value?.showMe;
    final needsName = account != null && (account.displayName?.trim().isEmpty ?? true);
    final people = results.value;

    const gutter = EdgeInsets.fromLTRB(AppSpacing.screenGutter, AppSpacing.md, AppSpacing.screenGutter, 0);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!online) const OfflineBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(discoverResultsProvider(state.plan).future),
                child: CustomScrollView(
                  // Photos of the next few people load before they scroll into view.
                  cacheExtent: MediaQuery.sizeOf(context).height * 1.5,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: gutter,
                        // Wraps onto two lines on narrow phones with large text.
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.appName.toUpperCase(),
                                  style: textTheme.labelMedium?.copyWith(color: AppColors.accent),
                                ),
                                Semantics(header: true, child: Text(l10n.navDiscover, style: textTheme.headlineLarge)),
                              ],
                            ),
                            Wrap(
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xs,
                              children: [
                                AppRoundIconButton(
                                  label: l10n.discoverMap,
                                  icon: Icons.place_outlined,
                                  onPressed: () => context.go(AppRoutes.discoverMap(plan: state.plan)),
                                ),
                                CreditsPill(credits: credits, onPressed: () => context.push(AppRoutes.credits)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (needsName)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: gutter,
                          child: _NameBanner(onAdd: () => context.go(AppRoutes.profile)),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: gutter,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: AppSpacing.xxs,
                          children: [
                            Text(
                              l10n.discoverPlanQuestion,
                              style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
                            ),
                            if (showMe != null)
                              Text(
                                l10n.discoverShowing(_showMeLabel(l10n, showMe)),
                                style: textTheme.labelMedium?.copyWith(color: AppColors.accentText),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: AppSizes.minTouchTarget + AppSpacing.md,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: AppSpacing.screenPadding,
                          itemCount: PlanType.values.length,
                          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
                          itemBuilder: (context, i) {
                            final plan = PlanType.values[i];
                            return Center(
                              child: AppChoiceChip(
                                label: planLabel(l10n, plan),
                                selected: plan == state.plan,
                                onSelected: () => controller.selectPlan(plan),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                          child: TextButton.icon(
                            onPressed: () => context.go(AppRoutes.freeNow),
                            icon: const Icon(Icons.bolt, size: AppSizes.iconSmall),
                            label: Text(l10n.discoverFreeNowLink),
                          ),
                        ),
                      ),
                    ),
                    if (people != null && people.isNotEmpty) ...[
                      SliverList.separated(
                        itemCount: people.length,
                        separatorBuilder: (_, _) => const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: Divider(height: 1),
                        ),
                        itemBuilder: (context, i) => _Post(companion: people[i]),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenGutter,
                            AppSpacing.xl,
                            AppSpacing.screenGutter,
                            AppSpacing.xxl,
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.done_all_outlined, color: AppColors.muted, size: AppSizes.iconLarge),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                l10n.discoverAllSeenTitle,
                                style: textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                l10n.feedEndBody,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: AppSizes.stateViewHeight),
                          child: DiscoveryStateView<List<CompanionSummary>>(
                            value: results,
                            onRetry: () => ref.invalidate(discoverResultsProvider(state.plan)),
                            isEmpty: (all) => all.isEmpty,
                            emptyTitle: l10n.discoverEmptyTitle,
                            emptyMessage: l10n.discoverEmptyBody,
                            builder: (context, _) => const SizedBox.shrink(),
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
    );
  }

  static String _showMeLabel(AppLocalizations l10n, ShowMe showMe) => switch (showMe) {
    ShowMe.women => l10n.showMeWomen,
    ShowMe.men => l10n.showMeMen,
    ShowMe.everyone => l10n.showMeEveryone,
  };
}

/// One feed post with its actions wired up.
class _Post extends ConsumerWidget {
  const _Post({required this.companion});

  final CompanionSummary companion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = companion;
    final saved = ref.watch(savedIdsProvider).value?.contains(c.uid) ?? false;

    Future<void> toggleSave() async {
      final result = await ref.read(discoverControllerProvider.notifier).toggleSave(c.uid, saved: !saved);
      final failure = result.failureOrNull;
      if (failure != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failureMessage(l10n, failure))));
      }
    }

    return FeedPost(
      companion: c,
      saved: saved,
      onOpen: () => context.push(AppRoutes.companion(c.uid)),
      onMessage: () => openChatWith(context, ref, companionUid: c.uid, name: c.displayName),
      onToggleSave: toggleSave,
    );
  }
}

class _NameBanner extends StatelessWidget {
  const _NameBanner({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      // Text first, button underneath: never squeezes the text on small phones.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.nameBannerTitle, style: textTheme.titleMedium),
          Text(l10n.nameBannerBody, style: textTheme.bodySmall?.copyWith(color: AppColors.muted)),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: AppPillButton(label: l10n.nameBannerAction, tone: AppPillTone.accent, onPressed: onAdd),
          ),
        ],
      ),
    );
  }
}
