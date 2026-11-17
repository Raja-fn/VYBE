import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_pill_button.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/storage_photo.dart';
import '../../chat/domain/chat_models.dart';
import '../../chat/presentation/chat_actions_ui.dart';
import '../data/reels_repository.dart';
import '../domain/reel.dart';
import 'reels_providers.dart';
import 'widgets/reel_video.dart';

/// The Reels tab: short videos people post, one per page. Swipe up for the
/// next; tap to pause. The + button records or picks a video to post.
class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final _pages = PageController();
  int _current = 0;
  bool _muted = false;

  /// Another screen is open on top: pause.
  bool _away = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// Opens a screen on top, pausing the video until it closes.
  Future<void> _whileAway(Future<void> Function() open) async {
    setState(() => _away = true);
    try {
      await open();
    } finally {
      if (mounted) setState(() => _away = false);
    }
  }

  Future<void> _create() async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<VideoSource>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.photoCard)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: Text(l10n.reelsRecord),
              onTap: () => Navigator.of(context).pop(VideoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: Text(l10n.reelsPickGallery),
              onTap: () => Navigator.of(context).pop(VideoSource.gallery),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final result = await ref.read(videoPickerProvider).pick(source);
    if (!mounted) return;
    final failure = result.failureOrNull;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failureMessage(l10n, failure))));
      return;
    }
    final video = result.valueOrNull;
    if (video == null) return;
    if (video.bytes > reelMaxBytes) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.reelTooBig)));
      return;
    }
    await _whileAway(() => context.push(AppRoutes.newReel, extra: video.path));
    if (mounted && _pages.hasClients) _pages.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final feed = ref.watch(reelFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(header: true, child: Text(l10n.navReels, style: textTheme.headlineMedium)),
                  ),
                  AppRoundIconButton(
                    label: _muted ? l10n.reelUnmute : l10n.reelMute,
                    icon: _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    onPressed: () => setState(() => _muted = !_muted),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AppRoundIconButton(label: l10n.reelsPost, icon: Icons.add_rounded, onPressed: _create),
                ],
              ),
            ),
            Expanded(
              child: AsyncStateView<List<Reel>>(
                value: feed,
                onRetry: () => ref.invalidate(reelFeedProvider),
                builder: (context, reels) {
                  if (reels.isEmpty) return _Empty(onPost: _create);
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(reelFeedProvider.future),
                    child: PageView.builder(
                      controller: _pages,
                      scrollDirection: Axis.vertical,
                      itemCount: reels.length,
                      onPageChanged: (i) {
                        setState(() => _current = i);
                        if (i >= reels.length - 3) ref.read(reelFeedProvider.notifier).loadMore();
                      },
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.xs, 0, AppSpacing.xs, AppSpacing.sm),
                        child: ClipRRect(
                          borderRadius: AppRadii.cardBorder,
                          child: _ReelPage(
                            key: ValueKey(reels[i].reelId),
                            reel: reels[i],
                            active: i == _current && !_away,
                            muted: _muted,
                            onAway: _whileAway,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One reel: the video, who posted it, the caption and the actions.
class _ReelPage extends ConsumerWidget {
  const _ReelPage({required this.reel, required this.active, required this.muted, required this.onAway, super.key});

  final Reel reel;
  final bool active;
  final bool muted;
  final Future<void> Function(Future<void> Function() open) onAway;

  Future<void> _more(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    if (!reel.isMine) {
      await showReportOrBlock(
        context,
        uid: reel.authorUid,
        name: reel.authorName,
        reportContext: ReportContext.reel,
        refId: reel.reelId,
        onBlocked: () => ref.read(reelFeedProvider.notifier).hideAuthor(reel.authorUid),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reelDeleteTitle),
        content: Text(l10n.reelDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.reelDelete)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref.read(reelFeedProvider.notifier).delete(reel);
    final failure = result.failureOrNull;
    messenger.showSnackBar(SnackBar(content: Text(failure == null ? l10n.reelDeleted : failureMessage(l10n, failure))));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final shadow = [Shadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 6)];

    return Stack(
      fit: StackFit.expand,
      children: [
        ReelVideo.storage(reel.videoPath, active: active, muted: muted),
        // Bottom scrim so the text reads on any video.
        IgnorePointer(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.4,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.md,
          right: 72,
          bottom: AppSpacing.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.onInk, width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: StoragePhoto(
                      paths: [?reel.authorPhotoPath],
                      name: reel.authorName,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      reel.isMine ? l10n.reelYou : reel.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(color: AppColors.onInk, shadows: shadow),
                    ),
                  ),
                ],
              ),
              if (reel.caption.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  reel.caption,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.onInk, shadows: shadow),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          right: AppSpacing.xs,
          bottom: AppSpacing.lg,
          child: SizedBox(
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (reel.authorBookable) ...[
                  _Action(
                    label: l10n.discoverMessage,
                    icon: Icons.chat_bubble_rounded,
                    onTap: () => onAway(
                      () => openChatWith(context, ref, companionUid: reel.authorUid, name: reel.authorName),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _Action(
                    label: l10n.reelBook,
                    semanticLabel: l10n.reelBookWith(reel.authorName),
                    icon: Icons.event_available_rounded,
                    highlight: true,
                    onTap: () => onAway(() => context.push(AppRoutes.book(companionUid: reel.authorUid))),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                _Action(
                  label: reel.isMine ? l10n.reelDelete : l10n.reelMore,
                  semanticLabel: reel.isMine ? l10n.reelDelete : l10n.reelReport,
                  icon: reel.isMine ? Icons.delete_outline_rounded : Icons.more_horiz_rounded,
                  onTap: () => _more(context, ref),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.icon, required this.onTap, this.semanticLabel, this.highlight = false});

  final String label;
  final String? semanticLabel;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.onInk,
      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 4)],
    );
    return Semantics(
      container: true,
      button: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: highlight ? AppColors.accent : Colors.black.withValues(alpha: 0.3),
                ),
                child: Icon(icon, color: AppColors.onInk, size: 26),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onPost});

  final VoidCallback onPost;

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
            const Icon(Icons.movie_creation_outlined, color: AppColors.muted, size: 40),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.reelsEmptyTitle, style: textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l10n.reelsEmptyBody,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.md),
            AppPillButton(label: l10n.reelsPost, tone: AppPillTone.accent, onPressed: onPost),
          ],
        ),
      ),
    );
  }
}
