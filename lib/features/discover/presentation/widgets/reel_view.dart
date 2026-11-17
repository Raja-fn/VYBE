import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/storage_photo.dart';
import '../../../profile/presentation/profile_option_labels.dart';
import '../../domain/companion_summary.dart';
import 'labels.dart';
import 'voice_intro_button.dart';

/// One person in the Discover reels: full-height photos (tap the left or
/// right side to change photo), their details over the bottom of the photo,
/// and Profile / Message / Save down the right edge.
///
/// The photos are a list of media items, so a short intro video can later be
/// added as the first item.
class ReelView extends StatefulWidget {
  const ReelView({
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
  State<ReelView> createState() => _ReelViewState();
}

class _ReelViewState extends State<ReelView> {
  int _photo = 0;

  List<String?> get _photos {
    final paths = widget.companion.photoPaths;
    return paths.isEmpty ? const [null] : paths;
  }

  void _step(int delta) {
    final next = (_photo + delta).clamp(0, _photos.length - 1);
    if (next != _photo) setState(() => _photo = next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = widget.companion;
    final photos = _photos;
    final path = photos[_photo];

    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The photo, with a quick cross-fade between photos.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: SizedBox.expand(
              key: ValueKey(_photo),
              child: Semantics(
                container: true,
                image: true,
                excludeSemantics: true,
                label: l10n.feedPhotoOf(c.displayName, _photo + 1, photos.length),
                child: StoragePhoto(paths: path == null ? const [] : [path], name: c.displayName),
              ),
            ),
          ),
          // Scrims keep the white text readable on any photo.
          const _Scrim(top: true),
          const _Scrim(top: false),
          // Tap the left third for the previous photo, the rest for the next.
          Row(
            children: [
              Expanded(
                child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => _step(-1)),
              ),
              Expanded(
                flex: 2,
                child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => _step(1)),
              ),
            ],
          ),
          if (photos.length > 1)
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: _PhotoBars(count: photos.length, current: _photo),
            ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md + _Actions.width + AppSpacing.sm,
            bottom: AppSpacing.lg,
            child: _Details(companion: c, onOpen: widget.onOpen),
          ),
          Positioned(
            right: AppSpacing.sm,
            bottom: AppSpacing.lg,
            child: _Actions(
              companion: c,
              saved: widget.saved,
              onOpen: widget.onOpen,
              onMessage: widget.onMessage,
              onToggleSave: widget.onToggleSave,
            ),
          ),
        ],
      ),
    );
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim({required this.top});

  final bool top;

  @override
  Widget build(BuildContext context) => Positioned(
    left: 0,
    right: 0,
    top: top ? 0 : null,
    bottom: top ? null : 0,
    height: MediaQuery.sizeOf(context).height * (top ? 0.14 : 0.5),
    child: IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: top ? Alignment.topCenter : Alignment.bottomCenter,
            end: top ? Alignment.bottomCenter : Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: top ? 0.35 : 0.82),
              Colors.black.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Story-style bars: one per photo, the current one filled.
class _PhotoBars extends StatelessWidget {
  const _PhotoBars({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.xxs),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              decoration: BoxDecoration(
                color: i <= current ? AppColors.onInk : AppColors.onInk.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class _Details extends StatelessWidget {
  const _Details({required this.companion, required this.onOpen});

  final CompanionSummary companion;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final c = companion;
    final freeUntil = c.freeNowUntil;
    final prompt = c.prompt;
    final voice = c.voiceIntro;
    final interests = [for (final v in c.details.interests.take(3)) ProfileOptionLabels.interest(l10n, v)];
    const onPhoto = AppColors.onInk;
    const shadow = [Shadow(blurRadius: 8, color: Colors.black54)];
    final place = [
      l10n.cardAboutKmAway(c.distanceKm),
      if (c.details.city != null) c.details.city!,
      l10n.cardSpotsNearby(c.spotsNearby),
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (freeUntil != null) ...[
          _FreeNowTag(label: clockTime(context, freeUntil)),
          const SizedBox(height: AppSpacing.xs),
        ],
        Semantics(
          button: true,
          label: '${l10n.cardNameAge(c.displayName, c.ageYears)}. $place',
          excludeSemantics: true,
          child: GestureDetector(
            onTap: onOpen,
            child: Wrap(
              spacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.cardNameAge(c.displayName, c.ageYears),
                  style: textTheme.headlineMedium?.copyWith(color: onPhoto, shadows: shadow),
                ),
                if (c.isSample)
                  const _SampleTag()
                else
                  const Icon(Icons.verified, size: AppSizes.iconSmall, color: AppColors.success),
              ],
            ),
          ),
        ),
        Text(
          place,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.onInkMuted, shadows: shadow),
        ),
        if (prompt != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            (promptLabel(l10n, prompt.promptId) ?? '').toUpperCase(),
            style: textTheme.labelMedium?.copyWith(color: AppColors.gold, shadows: shadow),
          ),
          Text(
            prompt.answer,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyLarge?.copyWith(color: onPhoto, shadows: shadow),
          ),
        ],
        if (voice != null) ...[const SizedBox(height: AppSpacing.xs), VoiceIntroButton(intro: voice)],
        if (interests.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [for (final i in interests) _GlassChip(label: i)],
          ),
        ],
      ],
    );
  }
}

/// Profile, Message and Save down the right edge, each with a small label.
class _Actions extends StatelessWidget {
  const _Actions({
    required this.companion,
    required this.saved,
    required this.onOpen,
    required this.onMessage,
    required this.onToggleSave,
  });

  static const width = 64.0;

  final CompanionSummary companion;
  final bool saved;
  final VoidCallback onOpen;
  final VoidCallback onMessage;
  final VoidCallback onToggleSave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            label: l10n.reelProfile,
            semanticLabel: l10n.feedViewProfile,
            onTap: onOpen,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.onInk, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: StoragePhoto(paths: companion.photoPaths, name: companion.displayName),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionButton(
            label: l10n.discoverMessage,
            onTap: onMessage,
            child: const Icon(Icons.chat_bubble_rounded, color: AppColors.onInk, size: 32),
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionButton(
            label: saved ? l10n.reelSaved : l10n.discoverSave,
            semanticLabel: saved ? l10n.discoverUnsave : l10n.discoverSave,
            onTap: onToggleSave,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Icon(
                saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                key: ValueKey(saved),
                color: saved ? AppColors.accent : AppColors.onInk,
                size: 34,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap, required this.child, this.semanticLabel});

  final String label;
  final String? semanticLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel ?? label,
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: TextScaler.noScaling,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onInk,
                shadows: const [Shadow(blurRadius: 6, color: Colors.black54)],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(
      color: Colors.black.withValues(alpha: 0.35),
      shape: StadiumBorder(side: BorderSide(color: AppColors.onInk.withValues(alpha: 0.35))),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onInk)),
    ),
  );
}

class _FreeNowTag extends StatelessWidget {
  const _FreeNowTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(color: Colors.black.withValues(alpha: 0.45), shape: const StadiumBorder()),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(
            dimension: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              '${context.l10n.badgeFreeNow} · $label',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onInk),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Marks a made-up sample profile.
class _SampleTag extends StatelessWidget {
  const _SampleTag();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(
      color: Colors.black.withValues(alpha: 0.35),
      shape: StadiumBorder(side: BorderSide(color: AppColors.onInk.withValues(alpha: 0.6))),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 1),
      child: Text(
        context.l10n.sampleProfileTag,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onInk),
      ),
    ),
  );
}
