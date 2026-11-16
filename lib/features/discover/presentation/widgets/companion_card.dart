import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/photo_card.dart';
import '../../../../core/widgets/storage_photo.dart';
import '../../domain/companion_summary.dart';
import 'labels.dart';
import 'voice_intro_button.dart';

/// The big Discover card: photo with badges and a name strip, then the prompt
/// answer and voice intro. Tapping it opens the full profile.
class CompanionCard extends StatelessWidget {
  const CompanionCard({required this.companion, required this.onOpen, super.key});

  final CompanionSummary companion;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final c = companion;
    final freeUntil = c.freeNowUntil;
    final prompt = c.prompt;
    final promptTitle = prompt == null ? null : promptLabel(l10n, prompt.promptId);
    final voice = c.voiceIntro;

    final subtitle = [
      l10n.cardAboutKmAway(c.distanceKm),
      if (freeUntil != null) l10n.cardFreeUntil(clockTime(context, freeUntil)),
    ].join(' · ');

    return PhotoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label:
                  '${l10n.cardNameAge(c.displayName, c.ageYears)}. $subtitle. ${l10n.cardSpotsNearby(c.spotsNearby)}',
              excludeSemantics: true,
              child: InkWell(
                onTap: onOpen,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    StoragePhoto(paths: c.photoPaths, name: c.displayName),
                    Positioned(
                      top: AppSpacing.md,
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      // Each badge keeps its natural width; with very large text they stack.
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: AppSpacing.xs,
                        children: [
                          if (freeUntil != null) const FreeNowBadge() else const SizedBox.shrink(),
                          const VerifiedBadge(),
                        ],
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: AppColors.photoOverlay,
                          borderRadius: AppRadii.cardBorder,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: AppSpacing.sm,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    l10n.cardNameAge(c.displayName, c.ageYears),
                                    style: textTheme.headlineMedium?.copyWith(color: AppColors.onInk),
                                  ),
                                  Text(
                                    l10n.cardSpotsNearby(c.spotsNearby),
                                    style: textTheme.titleMedium?.copyWith(color: AppColors.gold),
                                  ),
                                ],
                              ),
                              Text(subtitle, style: textTheme.bodyMedium?.copyWith(color: AppColors.onInkMuted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (prompt != null || voice != null)
            Padding(
              // Extra room at the bottom: the round actions overlap the card's edge.
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl + AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (promptTitle != null)
                          Text(
                            promptTitle.toUpperCase(),
                            style: textTheme.labelMedium?.copyWith(color: AppColors.violet),
                          ),
                        if (prompt != null)
                          Text(prompt.answer, style: textTheme.bodyLarge, maxLines: 3, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (voice != null) ...[const SizedBox(width: AppSpacing.sm), VoiceIntroButton(intro: voice)],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
