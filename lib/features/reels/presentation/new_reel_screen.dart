import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/content_rows.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart' show InlineFailure;
import '../domain/reel.dart';
import 'reels_providers.dart';
import 'widgets/reel_video.dart';

/// Preview a recorded or picked video, add a caption and post it.
class NewReelScreen extends ConsumerStatefulWidget {
  const NewReelScreen({required this.file, super.key});

  /// The video on this device.
  final String file;

  @override
  ConsumerState<NewReelScreen> createState() => _NewReelScreenState();
}

class _NewReelScreenState extends ConsumerState<NewReelScreen> {
  final _caption = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final l10n = context.l10n;
    setState(() => _error = null);
    final result = await ref.read(postReelProvider.notifier).post(localFile: widget.file, caption: _caption.text);
    if (!mounted) return;
    final failure = result.failureOrNull;
    if (failure != null) {
      setState(() => _error = failureMessage(l10n, failure));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.newReelPosted)));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final posting = ref.watch(postReelProvider).isLoading;
    final error = _error;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenGutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        AppBackButton(
                          onPressed: () {
                            if (!posting) context.pop();
                          },
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Semantics(header: true, child: Text(l10n.newReelTitle, style: textTheme.headlineMedium)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // The preview, portrait, at most half the screen tall.
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.5),
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: ClipRRect(
                            borderRadius: AppRadii.cardBorder,
                            child: ReelVideo.file(widget.file, active: !posting, muted: false),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: _caption,
                      enabled: !posting,
                      maxLength: reelCaptionMax,
                      maxLines: 3,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(labelText: l10n.newReelCaption, hintText: l10n.newReelCaptionHint),
                    ),
                    Text(l10n.newReelRules, style: textTheme.bodySmall?.copyWith(color: AppColors.muted)),
                    if (error != null) InlineFailure(error),
                  ],
                ),
              ),
            ),
            BottomActionBar(
              child: AppButton(label: l10n.newReelPost, isLoading: posting, onPressed: posting ? null : _post),
            ),
          ],
        ),
      ),
    );
  }
}
