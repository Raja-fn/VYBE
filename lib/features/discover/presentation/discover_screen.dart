import 'dart:math' as math;

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
import 'widgets/companion_card.dart';
import 'widgets/discovery_state_view.dart';
import 'widgets/labels.dart';

/// Screen 4: plan chips and a deck of companion cards (Skip / Message / Save).
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
    final currentUid = controller.remaining(results.value ?? const []).firstOrNull?.uid;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!online) const OfflineBanner(),
            Expanded(
              // The page scrolls on small phones; the card keeps a usable height.
              child: LayoutBuilder(
                builder: (context, box) => SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenGutter,
                          AppSpacing.md,
                          AppSpacing.screenGutter,
                          0,
                        ),
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
                                  // With a card on screen, "Pick" on the map books that companion.
                                  onPressed: () =>
                                      context.go(AppRoutes.discoverMap(companionUid: currentUid, plan: state.plan)),
                                ),
                                CreditsPill(credits: credits, onPressed: () => context.push(AppRoutes.credits)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (needsName)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenGutter,
                            AppSpacing.md,
                            AppSpacing.screenGutter,
                            0,
                          ),
                          child: _NameBanner(onAdd: () => context.go(AppRoutes.profile)),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenGutter,
                          AppSpacing.md,
                          AppSpacing.screenGutter,
                          0,
                        ),
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
                      const SizedBox(height: AppSpacing.xs),
                      SizedBox(
                        height: AppSizes.minTouchTarget + AppSpacing.xs,
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
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: math.max(AppSizes.deckMinHeight, box.maxHeight * AppRatios.deckShare),
                        child: DiscoveryStateView<List<CompanionSummary>>(
                          value: results,
                          onRetry: () => ref.invalidate(discoverResultsProvider(state.plan)),
                          isEmpty: (all) => all.isEmpty,
                          emptyTitle: l10n.discoverEmptyTitle,
                          emptyMessage: l10n.discoverEmptyBody,
                          builder: (context, all) => _Deck(remaining: controller.remaining(all)),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go(AppRoutes.freeNow),
                          child: Text(l10n.discoverFreeNowLink),
                        ),
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

  static String _showMeLabel(AppLocalizations l10n, ShowMe showMe) => switch (showMe) {
    ShowMe.women => l10n.showMeWomen,
    ShowMe.men => l10n.showMeMen,
    ShowMe.everyone => l10n.showMeEveryone,
  };
}

class _Deck extends ConsumerWidget {
  const _Deck({required this.remaining});

  final List<CompanionSummary> remaining;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(discoverControllerProvider.notifier);

    if (remaining.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmptyStateView(title: l10n.discoverAllSeenTitle, icon: Icons.done_all_outlined),
          AppPillButton(label: l10n.discoverStartOver, onPressed: controller.startOver),
        ],
      );
    }

    final current = remaining.first;
    final saved = ref.watch(savedIdsProvider).value?.contains(current.uid) ?? false;

    Future<void> toggleSave() async {
      final result = await controller.toggleSave(current.uid, saved: !saved);
      final failure = result.failureOrNull;
      if (failure != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failureMessage(l10n, failure))));
      }
    }

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Stack(
        children: [
          Positioned.fill(
            bottom: AppSizes.actionButton / 2,
            child: Dismissible(
              key: ValueKey(current.uid),
              onDismissed: (_) => controller.skip(current.uid),
              child: CompanionCard(companion: current, onOpen: () => context.push(AppRoutes.companion(current.uid))),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundAction(
                  icon: Icons.close,
                  label: l10n.discoverSkip,
                  tone: _RoundTone.light,
                  onPressed: () => controller.skip(current.uid),
                ),
                const SizedBox(width: AppSpacing.xl),
                _RoundAction(
                  icon: Icons.chat_bubble_outline,
                  label: l10n.discoverMessage,
                  tone: _RoundTone.dark,
                  onPressed: () => openChatWith(context, ref, companionUid: current.uid, name: current.displayName),
                ),
                const SizedBox(width: AppSpacing.xl),
                _RoundAction(
                  icon: saved ? Icons.bookmark : Icons.bookmark_border,
                  label: saved ? l10n.discoverUnsave : l10n.discoverSave,
                  tone: _RoundTone.accent,
                  onPressed: toggleSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _RoundTone { light, dark, accent }

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.label, required this.tone, required this.onPressed});

  final IconData icon;
  final String label;
  final _RoundTone tone;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final (fill, foreground) = switch (tone) {
      _RoundTone.light => (AppColors.inkRaised, AppColors.ink),
      _RoundTone.dark => (AppColors.inkRaised, AppColors.ink),
      _RoundTone.accent => (AppColors.accent, AppColors.onAccent),
    };
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : AppRatios.disabledOpacity,
        child: Material(
          color: fill,
          shape: const CircleBorder(),
          elevation: AppSizes.actionElevation,
          shadowColor: AppColors.shadow,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox.square(
              dimension: AppSizes.actionButton,
              child: Icon(icon, color: foreground, size: AppSizes.iconLarge),
            ),
          ),
        ),
      ),
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
