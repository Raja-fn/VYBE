import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/app_failure.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_choice_chip.dart';
import '../widgets/app_pill_button.dart';
import '../widgets/async_state_view.dart';
import '../widgets/badges.dart';
import '../widgets/content_rows.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/photo_card.dart';

/// Test-build-only screen showing every shared widget, for visual checks of
/// the design system. Not reachable in production builds.
class ComponentGalleryScreen extends ConsumerStatefulWidget {
  const ComponentGalleryScreen({super.key});

  @override
  ConsumerState<ComponentGalleryScreen> createState() => _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState extends ConsumerState<ComponentGalleryScreen> {
  int _selectedPlan = 0;
  bool _switchOn = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final config = ref.watch(appConfigProvider);
    final textTheme = Theme.of(context).textTheme;
    final plans = [l10n.planCoffee, l10n.planMovie, l10n.planEvent, l10n.planWalk, l10n.planDinner];
    void noop() {}

    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(title),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );

    const gap = SizedBox(height: AppSpacing.sm);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.devGalleryTitle),
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Center(child: AppBackButton(onPressed: () => Navigator.of(context).maybePop())),
        ),
        leadingWidth: AppSizes.appBarPillLeadingWidth,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        children: [
          section(l10n.devGallerySectionButtons, [
            AppButton(label: l10n.devGalleryPrimary, onPressed: noop),
            gap,
            AppButton(label: l10n.devGalleryOutline, onPressed: noop, variant: AppButtonVariant.outline),
            gap,
            AppButton(label: l10n.devGalleryGold, onPressed: noop, variant: AppButtonVariant.gold),
            gap,
            AppButton(label: l10n.devGallerySuccess, onPressed: noop, variant: AppButtonVariant.successOutline),
            gap,
            AppButton(label: l10n.devGalleryDisabled, onPressed: null),
            gap,
            AppButton(label: l10n.devGalleryPrimary, onPressed: noop, isLoading: true),
            gap,
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                AppBackButton(onPressed: noop),
                AppPillButton(label: l10n.commonRetry, onPressed: noop, tone: AppPillTone.soft),
                AppPillButton(label: l10n.commonRetry, onPressed: noop, tone: AppPillTone.accentText),
                AppPillButton(label: l10n.commonRetry, onPressed: noop, tone: AppPillTone.accent),
              ],
            ),
          ]),
          section(l10n.devGallerySectionChips, [
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (var i = 0; i < plans.length; i++)
                  AppChoiceChip(
                    label: plans[i],
                    selected: i == _selectedPlan,
                    enabled: i != plans.length - 1,
                    onSelected: () => setState(() => _selectedPlan = i),
                  ),
              ],
            ),
            gap,
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [AppTag(l10n.planCoffee), AppTag(l10n.planWalk)],
            ),
          ]),
          section(l10n.devGallerySectionCards, [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.devGalleryCardTitle, style: textTheme.titleLarge),
                  Text(l10n.devGalleryCardBody, style: textTheme.bodyMedium),
                ],
              ),
            ),
            gap,
            AppCard(
              tone: AppCardTone.dark,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.devGalleryDarkCardBody,
                      style: textTheme.titleMedium?.copyWith(color: AppColors.onInk),
                    ),
                  ),
                  AppPillButton(label: l10n.commonRetry, onPressed: noop, tone: AppPillTone.raised),
                ],
              ),
            ),
            gap,
            AppCard(
              child: AppSwitchTile(
                title: l10n.devGallerySwitchTitle,
                subtitle: l10n.devGallerySwitchSubtitle,
                value: _switchOn,
                onChanged: (value) => setState(() => _switchOn = value),
              ),
            ),
            gap,
            SafetyNote(text: l10n.safetyNotePublicSpots(config.discoveryRadiusKm)),
            gap,
            SizedBox(
              height: AppSizes.avatar * 3,
              child: PhotoCard(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PhotoPlaceholderArt(name: l10n.devGallerySampleName),
                    const Positioned(top: AppSpacing.md, left: AppSpacing.md, child: FreeNowBadge()),
                    const Positioned(top: AppSpacing.md, right: AppSpacing.md, child: VerifiedBadge()),
                  ],
                ),
              ),
            ),
          ]),
          section(l10n.devGallerySectionBadges, [
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                InitialsAvatar(name: l10n.devGallerySampleName),
                CreditsPill(credits: config.signupBonusCredits, onPressed: noop),
              ],
            ),
            gap,
            Row(
              children: [
                Expanded(
                  child: StatTile(value: l10n.devGallerySampleRating, label: l10n.statRating),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatTile(value: l10n.devGallerySampleCount, label: l10n.statMeetups, dark: true),
                ),
              ],
            ),
          ]),
          section(l10n.devGallerySectionSteps, [
            AppCard(
              child: Column(
                children: [
                  StepRow(
                    number: 1,
                    title: l10n.devGalleryCardTitle,
                    subtitle: l10n.devGalleryCardBody,
                    state: AppStepState.done,
                  ),
                  StepRow(
                    number: 2,
                    title: l10n.devGalleryCardTitle,
                    subtitle: l10n.devGalleryCardBody,
                    state: AppStepState.current,
                  ),
                  StepRow(
                    number: 3,
                    title: l10n.devGalleryCardTitle,
                    subtitle: l10n.devGalleryCardBody,
                    state: AppStepState.upcoming,
                  ),
                ],
              ),
            ),
          ]),
          section(l10n.devGallerySectionStates, [
            const OfflineBanner(),
            gap,
            AppCard(
              child: ErrorStateView(failure: const AppFailure(FailureKind.network), onRetry: noop),
            ),
            gap,
            AppCard(child: EmptyStateView(title: l10n.stateEmptyTitle)),
          ]),
        ],
      ),
    );
  }
}
