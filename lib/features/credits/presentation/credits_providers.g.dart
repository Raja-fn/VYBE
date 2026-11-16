// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credits_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Real stores in production; the built-in test store everywhere else.

@ProviderFor(storeClient)
const storeClientProvider = StoreClientProvider._();

/// Real stores in production; the built-in test store everywhere else.

final class StoreClientProvider extends $FunctionalProvider<StoreClient, StoreClient, StoreClient>
    with $Provider<StoreClient> {
  /// Real stores in production; the built-in test store everywhere else.
  const StoreClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeClientHash();

  @$internal
  @override
  $ProviderElement<StoreClient> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  StoreClient create(Ref ref) {
    return storeClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreClient value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<StoreClient>(value));
  }
}

String _$storeClientHash() => r'42f4f188cd3743cff5277fc7c98a63c64a6d05b1';

@ProviderFor(purchaseRepository)
const purchaseRepositoryProvider = PurchaseRepositoryProvider._();

final class PurchaseRepositoryProvider
    extends $FunctionalProvider<PurchaseRepository, PurchaseRepository, PurchaseRepository>
    with $Provider<PurchaseRepository> {
  const PurchaseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseRepositoryHash();

  @$internal
  @override
  $ProviderElement<PurchaseRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  PurchaseRepository create(Ref ref) {
    return purchaseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<PurchaseRepository>(value));
  }
}

String _$purchaseRepositoryHash() => r'befe5a09073d5913a7b4f2e4c7ae5f827d72f4cc';

@ProviderFor(mySubscription)
const mySubscriptionProvider = MySubscriptionProvider._();

final class MySubscriptionProvider
    extends $FunctionalProvider<AsyncValue<SubscriptionInfo>, SubscriptionInfo, Stream<SubscriptionInfo>>
    with $FutureModifier<SubscriptionInfo>, $StreamProvider<SubscriptionInfo> {
  const MySubscriptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mySubscriptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mySubscriptionHash();

  @$internal
  @override
  $StreamProviderElement<SubscriptionInfo> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<SubscriptionInfo> create(Ref ref) {
    return mySubscription(ref);
  }
}

String _$mySubscriptionHash() => r'9a9f38dfcf968edac00b90f168c972ae2be75146';

/// Store prices for every plan and pack. Empty for the test store.

@ProviderFor(storePrices)
const storePricesProvider = StorePricesProvider._();

/// Store prices for every plan and pack. Empty for the test store.

final class StorePricesProvider
    extends $FunctionalProvider<AsyncValue<Map<String, String>>, Map<String, String>, FutureOr<Map<String, String>>>
    with $FutureModifier<Map<String, String>>, $FutureProvider<Map<String, String>> {
  /// Store prices for every plan and pack. Empty for the test store.
  const StorePricesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storePricesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storePricesHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, String>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, String>> create(Ref ref) {
    return storePrices(ref);
  }
}

String _$storePricesHash() => r'4f56a402f4d39e0705685c5bb68a1e96a75a7352';

/// Runs a purchase: store payment sheet → server check → credits added →
/// store told it is done. Listens from sign-in so a purchase left unfinished
/// last time is picked up again.

@ProviderFor(PurchaseFlow)
const purchaseFlowProvider = PurchaseFlowProvider._();

/// Runs a purchase: store payment sheet → server check → credits added →
/// store told it is done. Listens from sign-in so a purchase left unfinished
/// last time is picked up again.
final class PurchaseFlowProvider extends $NotifierProvider<PurchaseFlow, PurchaseFlowState> {
  /// Runs a purchase: store payment sheet → server check → credits added →
  /// store told it is done. Listens from sign-in so a purchase left unfinished
  /// last time is picked up again.
  const PurchaseFlowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseFlowProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseFlowHash();

  @$internal
  @override
  PurchaseFlow create() => PurchaseFlow();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseFlowState value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<PurchaseFlowState>(value));
  }
}

String _$purchaseFlowHash() => r'026452080b9193b9493e3a518e7ba57eb81847bb';

/// Runs a purchase: store payment sheet → server check → credits added →
/// store told it is done. Listens from sign-in so a purchase left unfinished
/// last time is picked up again.

abstract class _$PurchaseFlow extends $Notifier<PurchaseFlowState> {
  PurchaseFlowState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PurchaseFlowState, PurchaseFlowState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PurchaseFlowState, PurchaseFlowState>,
              PurchaseFlowState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
