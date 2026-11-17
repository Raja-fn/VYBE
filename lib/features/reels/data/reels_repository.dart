import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../../core/backend/callable_client.dart';
import '../../../core/backend/file_storage.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/run_guarded.dart';
import '../domain/reel.dart';

/// The Reels feed, posting and deleting. Behind an interface for tests.
abstract interface class ReelsRepository {
  /// Newest first; [before] is the last reel of the previous page.
  Future<Result<ReelPage>> feed({String? before});

  /// Uploads the video file to [uid]'s folder, then adds the reel.
  Future<Result<void>> post({
    required String uid,
    required String reelId,
    required String localFile,
    required String caption,
  });

  Future<Result<void>> delete(Reel reel);
}

class SupabaseReelsRepository implements ReelsRepository {
  SupabaseReelsRepository({required CallableClient functions, required FileUploader files})
    : _functions = functions,
      _files = files;

  final CallableClient _functions;
  final FileUploader _files;

  @override
  Future<Result<ReelPage>> feed({String? before}) => runGuarded(() async {
    final data = await _functions.call('reelFeed', {'before': before});
    final list = (data['reels'] as List<Object?>? ?? const [])
        .map((e) => Reel.fromJson((e! as Map).cast<String, Object?>()))
        .toList();
    return (reels: list, hasMore: data['hasMore'] as bool? ?? false);
  });

  @override
  Future<Result<void>> post({
    required String uid,
    required String reelId,
    required String localFile,
    required String caption,
  }) => runGuarded(() async {
    // The server looks for the video at exactly this path.
    await _files.uploadVideo(reelVideoPath(uid, reelId), localFile);
    await _functions.call('postReel', {'reelId': reelId, 'caption': caption});
  });

  @override
  Future<Result<void>> delete(Reel reel) => runGuarded(() async {
    await _functions.call('deleteReel', {'reelId': reel.reelId});
    try {
      await _files.delete(reel.videoPath);
    } on Object {
      // The reel is gone from the feed; a leftover file is private to its folder.
    }
  });
}

/// A video picked to post, on the device.
typedef PickedVideo = ({String path, int bytes});

enum VideoSource { camera, gallery }

/// Records or picks a video. Behind an interface for tests.
abstract interface class VideoPickerService {
  /// The picked video, or null when the person backed out.
  Future<Result<PickedVideo?>> pick(VideoSource source);
}

class ImagePickerVideoService implements VideoPickerService {
  ImagePickerVideoService(this._picker);

  final ImagePicker _picker;

  @override
  Future<Result<PickedVideo?>> pick(VideoSource source) => runGuarded(() async {
    final file = await _picker.pickVideo(
      source: source == VideoSource.camera ? ImageSource.camera : ImageSource.gallery,
      maxDuration: reelMaxDuration,
    );
    if (file == null) return null;
    return (path: file.path, bytes: await File(file.path).length());
  });
}
