// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRepository)
const profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends $FunctionalProvider<ProfileRepository, ProfileRepository, ProfileRepository>
    with $Provider<ProfileRepository> {
  const ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<ProfileRepository>(value));
  }
}

String _$profileRepositoryHash() => r'20b1d30432b532a99ae0dd6e5f0329fa47d58f67';

@ProviderFor(MyProfileController)
const myProfileControllerProvider = MyProfileControllerProvider._();

final class MyProfileControllerProvider extends $NotifierProvider<MyProfileController, MyProfileState> {
  const MyProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myProfileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myProfileControllerHash();

  @$internal
  @override
  MyProfileController create() => MyProfileController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MyProfileState value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<MyProfileState>(value));
  }
}

String _$myProfileControllerHash() => r'f50e554bc01ac1dc8ff9b6f93a906af56c56eb6d';

abstract class _$MyProfileController extends $Notifier<MyProfileState> {
  MyProfileState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MyProfileState, MyProfileState>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<MyProfileState, MyProfileState>, MyProfileState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
