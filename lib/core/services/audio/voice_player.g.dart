// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_player.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(voicePlayer)
const voicePlayerProvider = VoicePlayerProvider._();

final class VoicePlayerProvider
    extends $FunctionalProvider<VoicePlayer, VoicePlayer, VoicePlayer>
    with $Provider<VoicePlayer> {
  const VoicePlayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voicePlayerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voicePlayerHash();

  @$internal
  @override
  $ProviderElement<VoicePlayer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VoicePlayer create(Ref ref) {
    return voicePlayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoicePlayer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoicePlayer>(value),
    );
  }
}

String _$voicePlayerHash() => r'73dd58c38e3666170355c84216e3df16be265b8a';
