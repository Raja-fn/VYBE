import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/content_rows.dart';
import '../../../../core/widgets/storage_photo.dart';
import '../../../profile/presentation/profile_option_labels.dart';
import '../../domain/companion_summary.dart';
import 'labels.dart';
import 'voice_intro_button.dart';

/// One person in the Discover feed, like a post: header, a swipeable photo
/// carousel, Message / Save, then their prompt, bio and interests.
///
/// The carousel is a list of media items so a short intro video can later be
/// added as its first item.
class FeedPost extends StatelessWidget {
  const FeedPost({
    required this.companion,
    required this.saved,
    required this.onOpen,
    required this.onMessage,
    required this.onToggleSave,
    super.key,
  });

  final CompanionSummary companion;
  final bool saved;
  final VoidCallback onOpen;
  final VoidCallback onMessage;
  final VoidCallback onToggleSave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final c = companion;
    final freeUntil = c.freeNowUntil;
    final prompt = c.prompt;
    final voice = c.voiceIntro;
    final interests = [for (final v in c.details.interests.take(4)) ProfileOptionLabels.interest(l10n, v)];
    final subtitle = [
      l10n.cardAboutKmAway(c.distanceKm),
      if (c.details.city != null) c.details.city!,
      if (freeUntil != null) l10n.cardFreeUntil(clockTime(context, freeUntil)),
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: who this is. Tapping it opens the full profile.
        Semantics(
          button: true,
          label: '${l10n.cardNameAge(c.displayName, c.ageYears)}. $subtitle',
          excludeSemantics: true,
          child: InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox.square(
                      dimension: AppSizes.feedAvatar,
                      child: StoragePhoto(paths: c.photoPaths, name: c.displayName),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppSpacing.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(l10n.cardNameAge(c.displayName, c.ageYears), style: textTheme.titleLarge),
                            const Icon(Icons.verified, size: AppSizes.iconSmall, color: AppColors.success),
                          ],
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _Carousel(companion: c, onOpen: onOpen, freeNow: freeUntil != null),
        // Actions.
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, AppSpacing.sm, AppSpacing.xs, 0),
          child: Row(
            children: [
              FilledButton.icon(
                onPressed: onMessage,
                icon: const Icon(Icons.chat_bubble_outline, size: AppSizes.iconSmall),
                label: Text(l10n.discoverMessage),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, AppSizes.minTouchTarget),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  shape: const StadiumBorder(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.cardSpotsNearby(c.spotsNearby),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(color: AppColors.gold),
                ),
              ),
              IconButton(
                onPressed: onToggleSave,
                tooltip: saved ? l10n.discoverUnsave : l10n.discoverSave,
                icon: Icon(
                  saved ? Icons.bookmark : Icons.bookmark_border,
                  color: saved ? AppColors.accent : AppColors.ink,
                  size: AppSizes.iconLarge,
                ),
              ),
            ],
          ),
        ),
        // Details.
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, AppSpacing.xs, AppSpacing.screenGutter, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (prompt != null) ...[
                Text(
                  (promptLabel(l10n, prompt.promptId) ?? '').toUpperCase(),
                  style: textTheme.labelMedium?.copyWith(color: AppColors.violet),
                ),
                Row(
                  children: [
                    Expanded(child: Text(prompt.answer, style: textTheme.bodyLarge)),
                    if (voice != null) ...[const SizedBox(width: AppSpacing.sm), VoiceIntroButton(intro: voice)],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
              ] else if (voice != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: VoiceIntroButton(intro: voice),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              if (c.about.isNotEmpty)
                Text(
                  c.about,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              if (interests.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [for (final i in interests) AppTag(i)],
                ),
              ],
              TextButton(
                onPressed: onOpen,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(l10n.feedViewProfile),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Swipe sideways through the photos (4:5, like a post), with a counter.
class _Carousel extends StatefulWidget {
  const _Carousel({required this.companion, required this.onOpen, required this.freeNow});

  final CompanionSummary companion;
  final VoidCallback onOpen;
  final bool freeNow;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = widget.companion;
    // No photos yet: one placeholder slide.
    final photos = c.photoPaths.isEmpty ? const <String?>[null] : <String?>[...c.photoPaths];
    return AspectRatio(
      aspectRatio: AppRatios.feedPhoto,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: photos.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, i) {
              final path = photos[i];
              return Semantics(
                image: true,
                label: l10n.feedPhotoOf(c.displayName, i + 1, photos.length),
                child: GestureDetector(
                  onTap: widget.onOpen,
                  child: StoragePhoto(paths: path == null ? const [] : [path], name: c.displayName),
                ),
              );
            },
          ),
          if (widget.freeNow) const Positioned(top: AppSpacing.md, left: AppSpacing.md, child: FreeNowBadge()),
          if (photos.length > 1) ...[
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: ExcludeSemantics(
                child: DecoratedBox(
                  decoration: const ShapeDecoration(color: AppColors.photoOverlay, shape: StadiumBorder()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                    child: Text(
                      '${_page + 1} / ${photos.length}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onInk),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.sm,
              child: ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < photos.length; i++)
                      Container(
                        width: AppSizes.feedDot,
                        height: AppSizes.feedDot,
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _page ? AppColors.onInk : AppColors.onInkMuted.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
