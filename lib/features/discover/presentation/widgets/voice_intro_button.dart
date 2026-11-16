import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/backend/backend_providers.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/services/audio/voice_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../domain/companion_summary.dart';
import 'labels.dart';

/// "▷ 0:15" pill that plays or stops a companion's voice intro.
class VoiceIntroButton extends ConsumerStatefulWidget {
  const VoiceIntroButton({required this.intro, super.key});

  final VoiceIntro intro;

  @override
  ConsumerState<VoiceIntroButton> createState() => _VoiceIntroButtonState();
}

class _VoiceIntroButtonState extends ConsumerState<VoiceIntroButton> {
  String? _url;

  Future<void> _toggle(bool isPlaying) async {
    final player = ref.read(voicePlayerProvider);
    if (isPlaying) {
      await player.stop();
      return;
    }
    final url = _url ??= await ref.read(storageUrlResolverProvider).urlFor(widget.intro.path);
    await player.play(url);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final player = ref.watch(voicePlayerProvider);
    return StreamBuilder<String?>(
      stream: player.playing,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data != null && snapshot.data == _url;
        return Semantics(
          button: true,
          label: isPlaying ? l10n.voiceIntroStop : l10n.voiceIntroPlay(widget.intro.durationSec),
          excludeSemantics: true,
          child: Material(
            color: AppColors.softFill,
            shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _toggle(isPlaying),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isPlaying ? Icons.stop_outlined : Icons.play_arrow_outlined, size: AppSizes.icon),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        voiceDurationLabel(l10n, widget.intro.durationSec),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
