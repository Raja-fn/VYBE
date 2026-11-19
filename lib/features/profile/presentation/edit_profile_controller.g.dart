// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in person's profile details, live.

@ProviderFor(myProfileDetails)
const myProfileDetailsProvider = MyProfileDetailsProvider._();

/// The signed-in person's profile details, live.

final class MyProfileDetailsProvider
    extends $FunctionalProvider<AsyncValue<ProfileDetails>, ProfileDetails, Stream<ProfileDetails>>
    with $FutureModifier<ProfileDetails>, $StreamProvider<ProfileDetails> {
  /// The signed-in person's profile details, live.
  const MyProfileDetailsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myProfileDetailsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myProfileDetailsHash();

  @$internal
  @override
  $StreamProviderElement<ProfileDetails> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<ProfileDetails> create(Ref ref) {
    return myProfileDetails(ref);
  }
}

String _$myProfileDetailsHash() => r'9f644e86cb2ac655ff148d5fc4f89f0633721370';

@ProviderFor(EditProfileController)
const editProfileControllerProvider = EditProfileControllerProvider._();

final class EditProfileControllerProvider extends $NotifierProvider<EditProfileController, EditProfileState> {
  const EditProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editProfileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editProfileControllerHash();

  @$internal
  @override
  EditProfileController create() => EditProfileController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditProfileState value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<EditProfileState>(value));
  }
}

String _$editProfileControllerHash() => r'c307c698ccb1069ea4ea2bb9ac9e56d96b090fa4';

abstract class _$EditProfileController extends $Notifier<EditProfileState> {
  EditProfileState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<EditProfileState, EditProfileState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EditProfileState, EditProfileState>,
              EditProfileState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
