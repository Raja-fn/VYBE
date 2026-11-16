import 'dart:typed_data';

import '../../../core/backend/file_storage.dart';
import '../../../core/backend/tables.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/run_guarded.dart';
import '../domain/profile_details.dart';

/// The person's own editable profile: name, photos and details.
abstract interface class ProfileRepository {
  Future<Result<void>> updateDisplayName(String uid, String name);

  /// Emits [ProfileDetails.empty] until something is saved.
  Stream<ProfileDetails> watchDetails(String uid);

  Future<Result<void>> saveDetails(String uid, ProfileDetails details);

  /// Uploads a photo and adds it after [current]. Returns the new list.
  Future<Result<List<String>>> addPhoto(
    String uid,
    Uint8List jpeg, {
    required List<String> current,
    required String photoId,
  });

  /// Saves a new order or a smaller list. Photos no longer listed are deleted.
  Future<Result<void>> setPhotos(String uid, List<String> photos, {List<String> removed = const []});
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._tables, this._files);

  final Tables _tables;
  final FileUploader _files;

  static String _now() => DateTime.now().toUtc().toIso8601String();

  @override
  Future<Result<void>> updateDisplayName(String uid, String name) => runGuarded(() async {
    await _tables.update('users', {'display_name': name, 'updated_at': _now()}, where: [(column: 'id', value: uid)]);
  });

  @override
  Stream<ProfileDetails> watchDetails(String uid) => _tables
      .watch('profile_details', primaryKey: const ['uid'], where: (column: 'uid', value: uid))
      .map((rows) => rows.isEmpty ? ProfileDetails.empty : ProfileDetails.fromRow(rows.first));

  @override
  Future<Result<void>> saveDetails(String uid, ProfileDetails details) => runGuarded(() async {
    await _tables.upsert('profile_details', {'uid': uid, ...details.toRow(), 'updated_at': _now()});
  });

  @override
  Future<Result<List<String>>> addPhoto(
    String uid,
    Uint8List jpeg, {
    required List<String> current,
    required String photoId,
  }) => runGuarded(() async {
    final path = 'photos/$uid/$photoId.jpg';
    await _files.uploadJpeg(path, jpeg);
    final photos = [...current, path];
    await _tables.update('users', {'photo_paths': photos, 'updated_at': _now()}, where: [(column: 'id', value: uid)]);
    return photos;
  });

  @override
  Future<Result<void>> setPhotos(String uid, List<String> photos, {List<String> removed = const []}) => runGuarded(
    () async {
      await _tables.update('users', {'photo_paths': photos, 'updated_at': _now()}, where: [(column: 'id', value: uid)]);
      for (final path in removed) {
        try {
          await _files.delete(path);
        } on Object {
          // Already off the profile; a leftover file is harmless and private to its folder.
        }
      }
    },
  );
}
