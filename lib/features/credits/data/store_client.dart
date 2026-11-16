import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart' show ReplacementMode;
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../../core/utils/ids.dart';
import '../domain/credit_models.dart';

/// Google Play / App Store billing, behind an interface so the test store
/// and tests can stand in for it.
abstract interface class StoreClient {
  /// True for the built-in test store: no real money is charged.
  bool get isTestStore;

  Future<bool> isAvailable();

  /// Local price text per product id, as the store shows it (e.g. "₹99.00").
  Future<Map<String, String>> prices(Set<String> productIds);

  /// Every purchase update, including ones left unfinished last time.
  Stream<StorePurchase> get purchases;

  /// Starts the store's payment sheet. [replacingProductId] is the plan
  /// being changed; [changeNow] is true for an upgrade, false for a
  /// downgrade that starts at the renewal.
  Future<void> buy(String productId, {required bool consumable, String? replacingProductId, bool changeNow = true});

  /// Tells the store the purchase was handled (after the server confirmed it).
  Future<void> complete(StorePurchase purchase);
}

/// The real stores, through `in_app_purchase`.
class InAppPurchaseStoreClient implements StoreClient {
  InAppPurchaseStoreClient(this._iap);

  final InAppPurchase _iap;
  final Map<String, ProductDetails> _products = {};

  static StorePlatform get _platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? StorePlatform.ios : StorePlatform.android;

  @override
  bool get isTestStore => false;

  @override
  Future<bool> isAvailable() => _iap.isAvailable();

  @override
  Future<Map<String, String>> prices(Set<String> productIds) async {
    final response = await _iap.queryProductDetails(productIds);
    for (final product in response.productDetails) {
      _products[product.id] = product;
    }
    return {for (final product in response.productDetails) product.id: product.price};
  }

  @override
  Stream<StorePurchase> get purchases => _iap.purchaseStream.expand(
    (updates) => updates.map(
      (p) => StorePurchase(
        productId: p.productID,
        platform: _platform,
        purchaseToken: p.verificationData.serverVerificationData,
        handle: p,
        status: switch (p.status) {
          PurchaseStatus.pending => StorePurchaseStatus.pending,
          PurchaseStatus.purchased || PurchaseStatus.restored => StorePurchaseStatus.purchased,
          PurchaseStatus.canceled => StorePurchaseStatus.canceled,
          PurchaseStatus.error => StorePurchaseStatus.error,
        },
      ),
    ),
  );

  @override
  Future<void> buy(
    String productId, {
    required bool consumable,
    String? replacingProductId,
    bool changeNow = true,
  }) async {
    final product = _products[productId] ?? (await _iap.queryProductDetails({productId})).productDetails.firstOrNull;
    if (product == null) throw StateError('Product $productId is not available in the store.');
    if (consumable) {
      await _iap.buyConsumable(purchaseParam: PurchaseParam(productDetails: product));
      return;
    }
    // iOS changes plans inside the subscription group by itself; Play needs
    // the plan being replaced.
    final change = _platform == StorePlatform.android && replacingProductId != null
        ? await _androidChange(replacingProductId, changeNow: changeNow)
        : null;
    final param = change == null
        ? PurchaseParam(productDetails: product)
        : GooglePlayPurchaseParam(productDetails: product, changeSubscriptionParam: change);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<ChangeSubscriptionParam?> _androidChange(String oldProductId, {required bool changeNow}) async {
    final android = _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final past = await android.queryPastPurchases();
    final old = past.pastPurchases.where((p) => p.productID == oldProductId).firstOrNull;
    if (old == null) return null;
    return ChangeSubscriptionParam(
      oldPurchaseDetails: old,
      replacementMode: changeNow ? ReplacementMode.chargeProratedPrice : ReplacementMode.deferred,
    );
  }

  @override
  Future<void> complete(StorePurchase purchase) async {
    final details = purchase.handle;
    if (details is PurchaseDetails && details.pendingCompletePurchase) await _iap.completePurchase(details);
  }
}

/// Built-in test store for test builds. Every purchase
/// succeeds at once with a `fake-` receipt, which only the fake purchase
/// service on the server accepts. No money is charged.
class TestStoreClient implements StoreClient {
  TestStoreClient({DateTime Function()? now, StorePlatform? platform})
    : _now = now ?? DateTime.now,
      _platform = platform ?? (defaultTargetPlatform == TargetPlatform.iOS ? StorePlatform.ios : StorePlatform.android);

  final DateTime Function() _now;
  final StorePlatform _platform;
  final _updates = StreamController<StorePurchase>.broadcast();

  @override
  bool get isTestStore => true;

  @override
  Future<bool> isAvailable() async => true;

  /// The test store has no prices; the screen says "Test purchase".
  @override
  Future<Map<String, String>> prices(Set<String> productIds) async => const {};

  @override
  Stream<StorePurchase> get purchases => _updates.stream;

  @override
  Future<void> buy(
    String productId, {
    required bool consumable,
    String? replacingProductId,
    bool changeNow = true,
  }) async {
    _updates.add(
      StorePurchase(
        productId: productId,
        platform: _platform,
        status: StorePurchaseStatus.purchased,
        purchaseToken: 'fake-t${_now().millisecondsSinceEpoch}-${randomRequestId()}',
      ),
    );
  }

  @override
  Future<void> complete(StorePurchase purchase) async {}
}
