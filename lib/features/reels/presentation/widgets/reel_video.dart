import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/backend/backend_providers.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../reels_providers.dart';

/// Plays one reel, filling its box, on a loop.
///
/// It plays only while [active], its tab is showing and the app is in the
/// foreground. Tapping pauses and resumes.
class ReelVideo extends ConsumerStatefulWidget {
  /// A posted reel, from storage.
  const ReelVideo.storage(String path, {required this.active, required this.muted, super.key})
    : storagePath = path,
      filePath = null;

  /// A video on this device (the preview before posting).
  const ReelVideo.file(String path, {required this.active, required this.muted, super.key})
    : storagePath = null,
      filePath = path;

  final String? storagePath;
  final String? filePath;
  final bool active;
  final bool muted;

  @override
  ConsumerState<ReelVideo> createState() => _ReelVideoState();
}

class _ReelVideoState extends ConsumerState<ReelVideo> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _failed = false;
  bool _pausedByUser = false;
  bool _foreground = true;
  bool _visible = true;

  bool get _enabled => ref.read(videoPlaybackProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_enabled) _open();
  }

  Future<void> _open() async {
    try {
      final file = widget.filePath;
      final controller = file != null
          ? VideoPlayerController.file(File(file))
          : VideoPlayerController.networkUrl(
              Uri.parse(await ref.read(storageUrlResolverProvider).urlFor(widget.storagePath!)),
            );
      if (!mounted) return;
      _controller = controller;
      await controller.initialize();
      await controller.setLooping(true);
      if (!mounted) return;
      setState(() {});
      _sync();
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tabs that are not showing have their tickers turned off.
    _visible = TickerMode.of(context);
    _sync();
  }

  @override
  void didUpdateWidget(ReelVideo old) {
    super.didUpdateWidget(old);
    if (old.active && !widget.active) _pausedByUser = false;
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _sync();
  }

  void _sync() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    controller.setVolume(widget.muted ? 0 : 1);
    final play = widget.active && _visible && _foreground && !_pausedByUser;
    if (play && !controller.value.isPlaying) {
      controller.play();
    } else if (!play && controller.value.isPlaying) {
      controller.pause();
    }
  }

  void _toggle() {
    setState(() => _pausedByUser = !_pausedByUser);
    _sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;

    return Semantics(
      container: true,
      label: l10n.reelVideo,
      button: true,
      onTapHint: _pausedByUser ? l10n.reelPlay : l10n.reelPause,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: ready ? _toggle : null,
        child: ColoredBox(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (ready)
                FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                )
              else if (_failed)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off_outlined, color: AppColors.onInkMuted, size: AppSizes.iconLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(l10n.reelCouldNotPlay, style: const TextStyle(color: AppColors.onInkMuted)),
                    ],
                  ),
                )
              else if (_enabled)
                const Center(child: CircularProgressIndicator(color: AppColors.onInk, strokeWidth: 2)),
              if (ready && _pausedByUser)
                const Center(
                  child: Icon(Icons.play_arrow_rounded, color: AppColors.onInk, size: 72),
                ),
              if (ready)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: false,
                    padding: EdgeInsets.zero,
                    colors: VideoProgressColors(
                      playedColor: AppColors.accent,
                      bufferedColor: AppColors.onInk.withValues(alpha: 0.3),
                      backgroundColor: AppColors.onInk.withValues(alpha: 0.12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
