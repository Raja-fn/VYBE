// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_capture_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(imageCaptureService)
const imageCaptureServiceProvider = ImageCaptureServiceProvider._();

final class ImageCaptureServiceProvider
    extends $FunctionalProvider<ImageCaptureService, ImageCaptureService, ImageCaptureService>
    with $Provider<ImageCaptureService> {
  const ImageCaptureServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageCaptureServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageCaptureServiceHash();

  @$internal
  @override
  $ProviderElement<ImageCaptureService> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ImageCaptureService create(Ref ref) {
    return imageCaptureService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImageCaptureService value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<ImageCaptureService>(value));
  }
}

String _$imageCaptureServiceHash() => r'ebf5fe16067605b0102c53719bfe743c4781a4a7';
