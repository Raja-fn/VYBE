import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../utils/result.dart';
import '../../utils/run_guarded.dart';

part 'voice_player.g.dart';

/// Plays one short voice intro at a time.
abstract interface class VoicePlayer {
  /// The URL currently playing, or null when stopped.
  Stream<String?> get playing;

  Future<Result<void>> play(String url);

  Future<void> stop();
}

class JustAudioVoicePlayer implements VoicePlayer {
  JustAudioVoicePlayer() {
    _subscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) unawaited(stop());
    });
  }

  final _player = AudioPlayer();
  final _playing = StreamController<String?>.broadcast();
  late final StreamSubscription<PlayerState> _subscription;

  @override
  Stream<String?> get playing => _playing.stream;

  @override
  Future<Result<void>> play(String url) => runGuarded(() async {
    await _player.stop();
    await _player.setUrl(url);
    _playing.add(url);
    unawaited(_player.play());
  });

  @override
  Future<void> stop() async {
    await _player.stop();
    _playing.add(null);
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _player.dispose();
    await _playing.close();
  }
}

@Riverpod(keepAlive: true)
VoicePlayer voicePlayer(Ref ref) {
  final player = JustAudioVoicePlayer();
  ref.onDispose(player.dispose);
  return player;
}
