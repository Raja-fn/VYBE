// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(discoverRepository)
const discoverRepositoryProvider = DiscoverRepositoryProvider._();

final class DiscoverRepositoryProvider
    extends
        $FunctionalProvider<
          DiscoverRepository,
          DiscoverRepository,
          DiscoverRepository
        >
    with $Provider<DiscoverRepository> {
  const DiscoverRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverRepositoryHash();

  @$internal
  @override
  $ProviderElement<DiscoverRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DiscoverRepository create(Ref ref) {
    return discoverRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoverRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoverRepository>(value),
    );
  }
}

String _$discoverRepositoryHash() =>
    r'd7d12df7ad077219cc4318611762b0c9bbb5461a';

/// Reads the device position and sends it to the server. Every discovery
/// list waits for this, so results are always around the current position.

@ProviderFor(locationSync)
const locationSyncProvider = LocationSyncProvider._();

/// Reads the device position and sends it to the server. Every discovery
/// list waits for this, so results are always around the current position.

final class LocationSyncProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Reads the device position and sends it to the server. Every discovery
  /// list waits for this, so results are always around the current position.
  const LocationSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationSyncHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return locationSync(ref);
  }
}

String _$locationSyncHash() => r'd3dbbb708fc30dcbc68114772cf4964a21ca3648';

@ProviderFor(discoverResults)
const discoverResultsProvider = DiscoverResultsProvider._();

final class DiscoverResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CompanionSummary>>,
          List<CompanionSummary>,
          FutureOr<List<CompanionSummary>>
        >
    with
        $FutureModifier<List<CompanionSummary>>,
        $FutureProvider<List<CompanionSummary>> {
  const DiscoverResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverResultsHash();

  @$internal
  @override
  $FutureProviderElement<List<CompanionSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CompanionSummary>> create(Ref ref) {
    return discoverResults(ref);
  }
}

String _$discoverResultsHash() => r'56f9f289d7bc332c80f1750c799189a36743563e';

@ProviderFor(freeNowResults)
const freeNowResultsProvider = FreeNowResultsFamily._();

final class FreeNowResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CompanionSummary>>,
          List<CompanionSummary>,
          FutureOr<List<CompanionSummary>>
        >
    with
        $FutureModifier<List<CompanionSummary>>,
        $FutureProvider<List<CompanionSummary>> {
  const FreeNowResultsProvider._({
    required FreeNowResultsFamily super.from,
    required FreeWindow super.argument,
  }) : super(
         retry: null,
         name: r'freeNowResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$freeNowResultsHash();

  @override
  String toString() {
    return r'freeNowResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CompanionSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CompanionSummary>> create(Ref ref) {
    final argument = this.argument as FreeWindow;
    return freeNowResults(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FreeNowResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$freeNowResultsHash() => r'f8a188ccf4c5cb496edef24ddf7fe482ef30b9c0';

final class FreeNowResultsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<CompanionSummary>>,
          FreeWindow
        > {
  const FreeNowResultsFamily._()
    : super(
        retry: null,
        name: r'freeNowResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FreeNowResultsProvider call(FreeWindow window) =>
      FreeNowResultsProvider._(argument: window, from: this);

  @override
  String toString() => r'freeNowResultsProvider';
}

@ProviderFor(companionProfile)
const companionProfileProvider = CompanionProfileFamily._();

final class CompanionProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<CompanionSummary>,
          CompanionSummary,
          FutureOr<CompanionSummary>
        >
    with $FutureModifier<CompanionSummary>, $FutureProvider<CompanionSummary> {
  const CompanionProfileProvider._({
    required CompanionProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'companionProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$companionProfileHash();

  @override
  String toString() {
    return r'companionProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CompanionSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CompanionSummary> create(Ref ref) {
    final argument = this.argument as String;
    return companionProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CompanionProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$companionProfileHash() => r'b137740150e0b1740ccfed8dd9b4794a1e519d3a';

final class CompanionProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CompanionSummary>, String> {
  const CompanionProfileFamily._()
    : super(
        retry: null,
        name: r'companionProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CompanionProfileProvider call(String uid) =>
      CompanionProfileProvider._(argument: uid, from: this);

  @override
  String toString() => r'companionProfileProvider';
}

@ProviderFor(savedCompanions)
const savedCompanionsProvider = SavedCompanionsProvider._();

final class SavedCompanionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CompanionSummary>>,
          List<CompanionSummary>,
          FutureOr<List<CompanionSummary>>
        >
    with
        $FutureModifier<List<CompanionSummary>>,
        $FutureProvider<List<CompanionSummary>> {
  const SavedCompanionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedCompanionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedCompanionsHash();

  @$internal
  @override
  $FutureProviderElement<List<CompanionSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CompanionSummary>> create(Ref ref) {
    return savedCompanions(ref);
  }
}

String _$savedCompanionsHash() => r'd80844ed9082de579f6d99bfa8fa55c3a99e0c70';

@ProviderFor(savedIds)
const savedIdsProvider = SavedIdsProvider._();

final class SavedIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  const SavedIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedIdsHash();

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    return savedIds(ref);
  }
}

String _$savedIdsHash() => r'29077711917c1d19cbde4475de137cf0257a4bd5';

@ProviderFor(creditsRepository)
const creditsRepositoryProvider = CreditsRepositoryProvider._();

final class CreditsRepositoryProvider
    extends
        $FunctionalProvider<
          CreditsRepository,
          CreditsRepository,
          CreditsRepository
        >
    with $Provider<CreditsRepository> {
  const CreditsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CreditsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreditsRepository create(Ref ref) {
    return creditsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreditsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreditsRepository>(value),
    );
  }
}

String _$creditsRepositoryHash() => r'47bb8ae0284033e92781ceaadbbbca73c433e528';

/// The person's own credit balance (read-only; only the server changes it).

@ProviderFor(creditBalance)
const creditBalanceProvider = CreditBalanceProvider._();

/// The person's own credit balance (read-only; only the server changes it).

final class CreditBalanceProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// The person's own credit balance (read-only; only the server changes it).
  const CreditBalanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditBalanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditBalanceHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return creditBalance(ref);
  }
}

String _$creditBalanceHash() => r'2c6423ad91f29d6b8154a3c4027b1d3db4b216c9';
