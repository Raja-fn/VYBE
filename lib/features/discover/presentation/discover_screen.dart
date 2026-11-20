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
import 'widgets/reel_view.dart';

/// Screen 4: Discover as reels. A top bar (title, Free now, Map, credits)
/// sits above the reels; each person is one rounded card filling the rest.
/// Everyone nearby shows, for any plan: the plan is picked when booking. Swipe up for the next person; tap the sides of a photo to
/// see their other photos.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _pages = PageController();

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final results = ref.watch(discoverResultsProvider);
    final online = ref.watch(isOnlineValueProvider);
    final credits = ref.watch(creditBalanceProvider).value ?? 0;
    final stage = ref.watch(sessionStageProvider).value;
    final account = stage is Ready ? stage.account : null;
    final showMe = account == null ? null : ref.watch(preferencesProvider(account.uid)).value?.showMe;
    final needsName = account != null && (account.displayName?.trim().isEmpty ?? true);
    final people = results.value;

    Future<void> startAgain() async {
      if (_pages.hasClients) {
        await _pages.animateToPage(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
      }
      ref.invalidate(discoverResultsProvider);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!online) const OfflineBanner(),
            // Top bar: title and the three round actions.
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, AppSpacing.sm, AppSpacing.md, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(header: true, child: Text(l10n.navDiscover, style: textTheme.headlineMedium)),
                        if (showMe != null)
                          Text(
                            l10n.discoverShowing(_showMeLabel(l10n, showMe)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
                          ),
                      ],
                    ),
                  ),
                  AppRoundIconButton(
                    label: l10n.discoverFreeNowLink,
                    icon: Icons.bolt_rounded,
                    onPressed: () => context.go(AppRoutes.freeNow),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AppRoundIconButton(
                    label: l10n.discoverMap,
                    icon: Icons.place_outlined,
                    onPressed: () => context.go(AppRoutes.discoverMap()),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  CreditsPill(credits: credits, onPressed: () => context.push(AppRoutes.credits)),
                ],
              ),
            ),
            if (needsName)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, AppSpacing.sm, AppSpacing.screenGutter, 0),
                child: _NameBanner(onAdd: () => context.go(AppRoutes.profile)),
              ),
            const SizedBox(height: AppSpacing.sm),
            // The reels: one rounded card per person, below the controls.
            Expanded(
              child: people != null && people.isNotEmpty
                  ? PageView.builder(
                      controller: _pages,
                      scrollDirection: Axis.vertical,
                      itemCount: people.length + 1,
                      itemBuilder: (context, i) => Padding(
                        // A small gap between cards shows while swiping.
                        padding: const EdgeInsets.fromLTRB(AppSpacing.xs, 0, AppSpacing.xs, AppSpacing.sm),
                        child: i < people.length
                            ? ClipRRect(
                                borderRadius: AppRadii.cardBorder,
                                child: _Post(companion: people[i]),
                              )
                            : _EndOfReels(onStartAgain: startAgain),
                      ),
                    )
                  : DiscoveryStateView<List<CompanionSummary>>(
                      value: results,
                      onRetry: () => ref.invalidate(discoverResultsProvider),
                      isEmpty: (all) => all.isEmpty,
                      emptyTitle: l10n.discoverEmptyTitle,
                      emptyMessage: l10n.discoverEmptyBody,
                      builder: (context, _) => const SizedBox.shrink(),
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

/// One reel with its actions wired up.
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

    return ReelView(
      companion: c,
      saved: saved,
      onOpen: () => context.push(AppRoutes.companion(c.uid)),
      onMessage: () => openChatWith(context, ref, companionUid: c.uid, name: c.displayName),
      onBook: () => context.push(AppRoutes.book(companionUid: c.uid)),
      onToggleSave: toggleSave,
    );
  }
}

/// The last page, after everyone.
class _EndOfReels extends StatelessWidget {
  const _EndOfReels({required this.onStartAgain});

  final VoidCallback onStartAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.done_all_rounded, color: AppColors.muted, size: AppSizes.iconLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.discoverAllSeenTitle, style: textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l10n.feedEndBody,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.md),
            AppPillButton(label: l10n.reelStartAgain, tone: AppPillTone.accent, onPressed: onStartAgain),
          ],
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
