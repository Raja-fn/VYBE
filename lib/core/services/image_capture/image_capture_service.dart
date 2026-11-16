import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/app_config.dart';
import '../../utils/result.dart';
import '../../utils/run_guarded.dart';

part 'image_capture_service.g.dart';

enum CaptureKind {
  /// Front camera.
  selfie,

  /// Rear camera, for an ID document.
  document,
}

/// Takes a photo with the camera.
abstract interface class ImageCaptureService {
  /// `Ok(null)` means the person closed the camera without taking a photo.
  Future<Result<Uint8List?>> capture(CaptureKind kind);
}

class ImagePickerCaptureService implements ImageCaptureService {
  ImagePickerCaptureService({required ImagePicker picker, required int maxDimension, required int jpegQuality})
    : _picker = picker,
      _maxDimension = maxDimension.toDouble(),
      _jpegQuality = jpegQuality;

  final ImagePicker _picker;
  final double _maxDimension;
  final int _jpegQuality;

  @override
  Future<Result<Uint8List?>> capture(CaptureKind kind) => runGuarded(() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: kind == CaptureKind.selfie ? CameraDevice.front : CameraDevice.rear,
      maxWidth: _maxDimension,
      maxHeight: _maxDimension,
      imageQuality: _jpegQuality,
      requestFullMetadata: false,
    );
    return file?.readAsBytes();
  });
}

@Riverpod(keepAlive: true)
ImageCaptureService imageCaptureService(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return ImagePickerCaptureService(
    picker: ImagePicker(),
    maxDimension: config.captureMaxDimension,
    jpegQuality: config.captureJpegQuality,
  );
}
