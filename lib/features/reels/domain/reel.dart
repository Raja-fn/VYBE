import 'dart:math';

/// One posted video in the Reels tab.
class Reel {
  const Reel({
    required this.reelId,
    required this.authorUid,
    required this.authorName,
    required this.authorPhotoPath,
    required this.authorBookable,
    required this.videoPath,
    required this.caption,
    required this.createdAt,
    required this.isMine,
  });

  factory Reel.fromJson(Map<String, Object?> json) => Reel(
    reelId: json['reelId']! as String,
    authorUid: json['authorUid']! as String,
    authorName: json['authorName']! as String,
    authorPhotoPath: json['authorPhotoPath'] as String?,
    authorBookable: json['authorBookable'] as bool? ?? false,
    videoPath: json['videoPath']! as String,
    caption: json['caption'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt']! as String),
    isMine: json['isMine'] as bool? ?? false,
  );

  final String reelId;
  final String authorUid;
  final String authorName;
  final String? authorPhotoPath;

  /// The author offers meetups: Message and Book show on the reel.
  final bool authorBookable;

  /// Storage path: `reels/<uid>/<reelId>.mp4`.
  final String videoPath;
  final String caption;
  final DateTime createdAt;
  final bool isMine;
}

/// Where a reel's video is stored (the server checks this exact path).
String reelVideoPath(String uid, String reelId) => 'reels/$uid/$reelId.mp4';

/// One page of the feed.
typedef ReelPage = ({List<Reel> reels, bool hasMore});

/// Longest caption, in characters (the server allows the same).
const reelCaptionMax = 150;

/// Longest video someone can record or pick.
const reelMaxDuration = Duration(seconds: 60);

/// Largest video file (the storage bucket allows the same).
const reelMaxBytes = 50 * 1024 * 1024;

/// A random UUID (version 4), used as a new reel's id.
String newReelId([Random? random]) {
  final r = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => r.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}
