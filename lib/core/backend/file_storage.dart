import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Storage paths are "bucket/object", for example
/// `verification/<uid>/<session>.jpg` or `photos/<uid>/1.jpg`.
({String bucket, String name}) splitStoragePath(String path) {
  final slash = path.indexOf('/');
  if (slash <= 0) throw ArgumentError.value(path, 'path', 'Expected "<bucket>/<object>".');
  return (bucket: path.substring(0, slash), name: path.substring(slash + 1));
}

/// Uploads bytes to file storage. Behind an interface for tests.
abstract interface class FileUploader {
  /// Throws on failure; callers wrap calls in `runGuarded`.
  Future<void> uploadJpeg(String path, Uint8List bytes);

  Future<void> delete(String path);
}

class SupabaseStorageUploader implements FileUploader {
  SupabaseStorageUploader(this._storage);

  final SupabaseStorageClient _storage;

  @override
  Future<void> uploadJpeg(String path, Uint8List bytes) async {
    final target = splitStoragePath(path);
    await _storage
        .from(target.bucket)
        .uploadBinary(target.name, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
  }

  @override
  Future<void> delete(String path) async {
    final target = splitStoragePath(path);
    await _storage.from(target.bucket).remove([target.name]);
  }
}

/// Turns a storage path into a URL the app can load. Behind an interface for tests.
abstract interface class StorageUrlResolver {
  Future<String> urlFor(String path);
}

/// Files are private; verified people get short-lived signed links.
class SupabaseStorageUrlResolver implements StorageUrlResolver {
  SupabaseStorageUrlResolver(this._storage, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  static const _lifetime = Duration(hours: 1);

  final SupabaseStorageClient _storage;
  final DateTime Function() _now;
  final _cache = <String, ({String url, DateTime expiresAt})>{};

  @override
  Future<String> urlFor(String path) async {
    final cached = _cache[path];
    // Reuse a link until it is close to expiring.
    if (cached != null && cached.expiresAt.isAfter(_now().add(const Duration(minutes: 5)))) return cached.url;
    final target = splitStoragePath(path);
    final url = await _storage.from(target.bucket).createSignedUrl(target.name, _lifetime.inSeconds);
    _cache[path] = (url: url, expiresAt: _now().add(_lifetime));
    return url;
  }
}
