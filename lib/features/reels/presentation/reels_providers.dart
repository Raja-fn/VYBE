import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_providers.dart';
import '../../../core/utils/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../data/reels_repository.dart';
import '../domain/reel.dart';

part 'reels_providers.g.dart';

@Riverpod(keepAlive: true)
ReelsRepository reelsRepository(Ref ref) =>
    SupabaseReelsRepository(functions: ref.watch(callableClientProvider), files: ref.watch(fileUploaderProvider));

@Riverpod(keepAlive: true)
VideoPickerService videoPicker(Ref ref) => ImagePickerVideoService(ImagePicker());

/// Whether reels really play. Widget tests turn it off (no video engine there).
@Riverpod(keepAlive: true)
bool videoPlayback(Ref ref) => true;

/// The Reels feed: the reels loaded so far, newest first.
@riverpod
class ReelFeed extends _$ReelFeed {
  bool _hasMore = false;
  bool _loadingMore = false;

  /// More reels can be loaded at the end.
  bool get hasMore => _hasMore;

  @override
  Future<List<Reel>> build() async {
    final page = (await ref.watch(reelsRepositoryProvider).feed()).valueOrThrow;
    _hasMore = page.hasMore;
    return page.reels;
  }

  /// Loads the next page; quietly does nothing when already loading or at the end.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isEmpty || !_hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final result = await ref.read(reelsRepositoryProvider).feed(before: current.last.reelId);
      final page = result.valueOrNull;
      if (page == null) return;
      _hasMore = page.hasMore;
      state = AsyncData([...current, ...page.reels]);
    } finally {
      _loadingMore = false;
    }
  }

  /// Deletes the caller's own reel and takes it off the feed.
  Future<Result<void>> delete(Reel reel) async {
    final result = await ref.read(reelsRepositoryProvider).delete(reel);
    if (result.isOk) {
      state = AsyncData([...?state.value?.where((r) => r.reelId != reel.reelId)]);
    }
    return result;
  }

  /// Takes someone's reels off the feed (after blocking them).
  void hideAuthor(String uid) {
    state = AsyncData([...?state.value?.where((r) => r.authorUid != uid)]);
  }
}

/// Posts a new reel.
@riverpod
class PostReel extends _$PostReel {
  @override
  FutureOr<void> build() {}

  Future<Result<void>> post({required String localFile, required String caption}) async {
    final me = await ref.read(authUserProvider.future);
    if (me == null) return const Err(AppFailure(FailureKind.unauthenticated));
    state = const AsyncLoading();
    final result = await ref
        .read(reelsRepositoryProvider)
        .post(uid: me.uid, reelId: newReelId(), localFile: localFile, caption: caption.trim());
    state = const AsyncData(null);
    if (result.isOk) ref.invalidate(reelFeedProvider);
    return result;
  }
}
