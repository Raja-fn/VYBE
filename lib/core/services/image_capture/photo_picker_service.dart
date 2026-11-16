import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/app_config.dart';
import '../../utils/result.dart';
import '../../utils/run_guarded.dart';

part 'photo_picker_service.g.dart';

enum PhotoSource { gallery, camera }

/// Profile photos from the gallery or the camera, shrunk and compressed as
/// JPEG. Behind an interface for tests.
abstract interface class PhotoPickerService {
  /// The picked photo, or null when the person backed out.
  Future<Result<Uint8List?>> pick(PhotoSource source);
}

class ImagePickerPhotoService implements PhotoPickerService {
  ImagePickerPhotoService({required ImagePicker picker, required int maxDimension, required int jpegQuality})
    : _picker = picker,
      _maxDimension = maxDimension,
      _jpegQuality = jpegQuality;

  final ImagePicker _picker;
  final int _maxDimension;
  final int _jpegQuality;

  @override
  Future<Result<Uint8List?>> pick(PhotoSource source) => runGuarded(() async {
    final file = await _picker.pickImage(
      source: source == PhotoSource.gallery ? ImageSource.gallery : ImageSource.camera,
      maxWidth: _maxDimension.toDouble(),
      maxHeight: _maxDimension.toDouble(),
      imageQuality: _jpegQuality,
      requestFullMetadata: false,
    );
    return file == null ? null : await file.readAsBytes();
  });
}

@Riverpod(keepAlive: true)
PhotoPickerService photoPickerService(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return ImagePickerPhotoService(
    picker: ImagePicker(),
    maxDimension: config.captureMaxDimension,
    jpegQuality: config.captureJpegQuality,
  );
}
