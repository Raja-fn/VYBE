import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/content_rows.dart';
import '../../../core/widgets/storage_photo.dart';
import '../../chat/domain/chat_models.dart';
import '../../chat/presentation/chat_actions_ui.dart';
import '../../profile/domain/profile_details.dart';
import '../../profile/presentation/profile_option_labels.dart';
import '../domain/companion_summary.dart';
import 'discover_providers.dart';
import 'widgets/discovery_state_view.dart';
import 'widgets/labels.dart';
import 'widgets/voice_intro_button.dart';

/// Screen 8: a companion's full profile.
class CompanionProfileScreen extends ConsumerWidget {
  const CompanionProfileScreen({required this.uid, super.key});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(companionProfileProvider(uid));

    void back() => context.canPop() ? context.pop() : context.go(AppRoutes.discover);

    return Scaffold(
      body: profile.hasValue
          ? _Profile(companion: profile.requireValue, onBack: back)
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: AppBackButton(onPressed: back),
                  ),
                  Expanded(
                    child: DiscoveryStateView<CompanionSummary>(
                      value: profile,
                      onRetry: () => ref.invalidate(companionProfileProvider(uid)),
                      builder: (context, _) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Profile extends ConsumerWidget {
  const _Profile({required this.companion, required this.onBack});

  final CompanionSummary companion;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final km = ref.watch(appConfigProvider).discoveryRadiusKm;
    final c = companion;
    final rating = c.ratingAvg;
    final tags = c.activityTags.map((t) => activityTagLabel(l10n, t)).whereType<String>().toList();
    final voice = c.voiceIntro;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: AppSizes.profilePhotoHeight,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadii.photoCard)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        StoragePhoto(paths: c.photoPaths, name: c.displayName),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppBackButton(onPressed: onBack),
                                const Spacer(),
                                AppRoundIconButton(
                                  icon: Icons.outlined_flag,
                                  label: l10n.reportOrBlock,
                                  onPressed: () => showReportOrBlock(
                                    context,
                                    uid: c.uid,
                                    name: c.displayName,
                                    reportContext: ReportContext.profile,
                                    onBlocked: () => context.go(AppRoutes.discover),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenGutter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Semantics(header: true, child: Text(c.displayName, style: textTheme.headlineLarge)),
                          ),
                          const VerifiedBadge(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              value: rating == null ? l10n.profileNewRating : rating.toStringAsFixed(1),
                              label: l10n.statRating,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: StatTile(value: '${c.meetupCount}', label: l10n.statMeetups),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: StatTile(value: '${c.ageYears}', label: l10n.statAge),
                          ),
                        ],
                      ),
                      if (c.about.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(c.about, style: textTheme.bodyLarge?.copyWith(color: AppColors.muted)),
                      ],
                      if (voice != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: VoiceIntroButton(intro: voice),
                        ),
                      ],
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [for (final tag in tags) AppTag(tag)],
                        ),
                      ],
                      _DetailsBlock(details: c.details),
                      const SizedBox(height: AppSpacing.lg),
                      SafetyNote(text: l10n.safetyNotePublicSpots(km)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        BottomActionBar(
          child: Row(
            children: [
              AppRoundIconButton(
                icon: Icons.chat_bubble_outline,
                label: l10n.profileChat,
                onPressed: () => openChatWith(context, ref, companionUid: c.uid, name: c.displayName),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: l10n.profileBookSpot,
                  onPressed: () => context.push(AppRoutes.book(companionUid: c.uid)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// City, work, languages, interests and lifestyle from "Edit profile".
class _DetailsBlock extends StatelessWidget {
  const _DetailsBlock({required this.details});

  final ProfileDetails details;

  @override
  Widget build(BuildContext context) {
    if (details.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final facts = <(IconData, String)>[
      if (details.city != null) (Icons.place_outlined, details.city!),
      if (details.profession != null) (Icons.work_outline, details.profession!),
      if (details.education != null) (Icons.school_outlined, ProfileOptionLabels.education(l10n, details.education!)),
      if (details.socialEnergy != null)
        (Icons.groups_outlined, ProfileOptionLabels.socialEnergy(l10n, details.socialEnergy!)),
    ];
    final lifestyle = <(IconData, String, String)>[
      if (details.drinking != null)
        (Icons.local_bar_outlined, l10n.editProfileDrinking, ProfileOptionLabels.habit(l10n, details.drinking!)),
      if (details.smoking != null)
        (Icons.smoke_free_outlined, l10n.editProfileSmoking, ProfileOptionLabels.habit(l10n, details.smoking!)),
      if (details.fitness != null)
        (Icons.fitness_center_outlined, l10n.editProfileFitness, ProfileOptionLabels.fitness(l10n, details.fitness!)),
    ];

    Widget group(String title, List<String> tags) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(title),
          const SizedBox(height: AppSpacing.xs),
          Wrap(spacing: AppSpacing.xs, runSpacing: AppSpacing.xs, children: [for (final t in tags) AppTag(t)]),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (facts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                for (final (icon, text) in facts)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: AppSizes.iconSmall, color: AppColors.muted),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(text, style: textTheme.bodyMedium),
                    ],
                  ),
              ],
            ),
          ),
        if (details.personality.isNotEmpty)
          group(l10n.editProfileHowIAm, [
            for (final v in details.personality) ProfileOptionLabels.personality(l10n, v),
          ]),
        if (details.interests.isNotEmpty)
          group(l10n.profileInterestsTitle, [for (final v in details.interests) ProfileOptionLabels.interest(l10n, v)]),
        if (details.languages.isNotEmpty)
          group(l10n.profileLanguagesTitle, [for (final v in details.languages) ProfileOptionLabels.language(l10n, v)]),
        if (lifestyle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(l10n.profileLifestyleTitle),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [for (final (_, label, value) in lifestyle) AppTag('$label: $value')],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
