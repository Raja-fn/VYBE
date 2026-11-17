// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reels_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reelsRepository)
const reelsRepositoryProvider = ReelsRepositoryProvider._();

final class ReelsRepositoryProvider
    extends
        $FunctionalProvider<ReelsRepository, ReelsRepository, ReelsRepository>
    with $Provider<ReelsRepository> {
  const ReelsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reelsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reelsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReelsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReelsRepository create(Ref ref) {
    return reelsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReelsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReelsRepository>(value),
    );
  }
}

String _$reelsRepositoryHash() => r'19a3c55576691c945dca673736c9059e28968b4d';

@ProviderFor(videoPicker)
const videoPickerProvider = VideoPickerProvider._();

final class VideoPickerProvider
    extends
        $FunctionalProvider<
          VideoPickerService,
          VideoPickerService,
          VideoPickerService
        >
    with $Provider<VideoPickerService> {
  const VideoPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videoPickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videoPickerHash();

  @$internal
  @override
  $ProviderElement<VideoPickerService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VideoPickerService create(Ref ref) {
    return videoPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideoPickerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideoPickerService>(value),
    );
  }
}

String _$videoPickerHash() => r'9378152eb29f13ba9b0cf0ffe0007c789ecc68ef';

/// Whether reels really play. Widget tests turn it off (no video engine there).

@ProviderFor(videoPlayback)
const videoPlaybackProvider = VideoPlaybackProvider._();

/// Whether reels really play. Widget tests turn it off (no video engine there).

final class VideoPlaybackProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether reels really play. Widget tests turn it off (no video engine there).
  const VideoPlaybackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videoPlaybackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videoPlaybackHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return videoPlayback(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$videoPlaybackHash() => r'9bed8b58f78a60504c889f2286211a4831aa4b58';

/// The Reels feed: the reels loaded so far, newest first.

@ProviderFor(ReelFeed)
const reelFeedProvider = ReelFeedProvider._();

/// The Reels feed: the reels loaded so far, newest first.
final class ReelFeedProvider
    extends $AsyncNotifierProvider<ReelFeed, List<Reel>> {
  /// The Reels feed: the reels loaded so far, newest first.
  const ReelFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reelFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reelFeedHash();

  @$internal
  @override
  ReelFeed create() => ReelFeed();
}

String _$reelFeedHash() => r'82ed85b87ea880cd751234bf1a64e92c4a5bc385';

/// The Reels feed: the reels loaded so far, newest first.

abstract class _$ReelFeed extends $AsyncNotifier<List<Reel>> {
  FutureOr<List<Reel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Reel>>, List<Reel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Reel>>, List<Reel>>,
              AsyncValue<List<Reel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Posts a new reel.

@ProviderFor(PostReel)
const postReelProvider = PostReelProvider._();

/// Posts a new reel.
final class PostReelProvider extends $AsyncNotifierProvider<PostReel, void> {
  /// Posts a new reel.
  const PostReelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postReelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postReelHash();

  @$internal
  @override
  PostReel create() => PostReel();
}

String _$postReelHash() => r'b5a173fcfcbacb8e58f8ff3c75b3ede3d63baf36';

/// Posts a new reel.

abstract class _$PostReel extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
