// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_verification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Always the server client. Which provider (fake or real) decides
/// is chosen on the server, so the test project exercises the real app flow.

@ProviderFor(identityVerificationService)
const identityVerificationServiceProvider = IdentityVerificationServiceProvider._();

/// Always the server client. Which provider (fake or real) decides
/// is chosen on the server, so the test project exercises the real app flow.

final class IdentityVerificationServiceProvider
    extends $FunctionalProvider<IdentityVerificationService, IdentityVerificationService, IdentityVerificationService>
    with $Provider<IdentityVerificationService> {
  /// Always the server client. Which provider (fake or real) decides
  /// is chosen on the server, so the test project exercises the real app flow.
  const IdentityVerificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identityVerificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identityVerificationServiceHash();

  @$internal
  @override
  $ProviderElement<IdentityVerificationService> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  IdentityVerificationService create(Ref ref) {
    return identityVerificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentityVerificationService value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<IdentityVerificationService>(value));
  }
}

String _$identityVerificationServiceHash() => r'09bc6751ef7d69dea4ac0a827429a64e5373343c';
