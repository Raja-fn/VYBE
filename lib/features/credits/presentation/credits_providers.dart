import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_providers.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/app_env.dart';
import '../../../core/utils/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../data/credits_repository.dart';
import '../data/store_client.dart';
import '../domain/credit_models.dart';

part 'credits_providers.freezed.dart';
part 'credits_providers.g.dart';

/// Real stores in production; the built-in test store everywhere else.
@Riverpod(keepAlive: true)
StoreClient storeClient(Ref ref) =>
    ref.watch(appEnvProvider).usesTestStore ? TestStoreClient() : InAppPurchaseStoreClient(InAppPurchase.instance);

@Riverpod(keepAlive: true)
PurchaseRepository purchaseRepository(Ref ref) =>
    SupabasePurchaseRepository(tables: ref.watch(tablesProvider), functions: ref.watch(callableClientProvider));

@riverpod
Stream<SubscriptionInfo> mySubscription(Ref ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) return Stream.value(SubscriptionInfo.free);
  return ref.watch(purchaseRepositoryProvider).watchSubscription(user.uid);
}

/// Store prices for every plan and pack. Empty for the test store.
@riverpod
Future<Map<String, String>> storePrices(Ref ref) async {
  final store = ref.watch(storeClientProvider);
  final config = ref.watch(appConfigProvider);
  if (!await store.isAvailable()) throw const AppFailure(FailureKind.storeUnavailable);
  return store.prices({
    for (final plan in config.plans) ?plan.productId,
    for (final pack in config.topUpPacks) pack.productId,
  });
}

/// What to tell the person after a purchase.
@freezed
sealed class PurchaseNotice with _$PurchaseNotice {
  const factory PurchaseNotice.creditsAdded(int credits) = CreditsAddedNotice;
  const factory PurchaseNotice.planActive(PlanTier tier, int credits) = PlanActiveNotice;
  const factory PurchaseNotice.planAtRenewal(PlanTier tier) = PlanAtRenewalNotice;
  const factory PurchaseNotice.alreadyAdded() = AlreadyAddedNotice;
  const factory PurchaseNotice.pending() = PendingNotice;
}

@freezed
abstract class PurchaseFlowState with _$PurchaseFlowState {
  const factory PurchaseFlowState({
    /// The product waiting on the store or the server.
    String? busyProductId,
    PurchaseNotice? notice,
    AppFailure? failure,

    /// A paid purchase the server could not confirm yet (e.g. offline).
    StorePurchase? unconfirmed,
  }) = _PurchaseFlowState;
}

/// Runs a purchase: store payment sheet → server check → credits added →
/// store told it is done. Listens from sign-in so a purchase left unfinished
/// last time is picked up again.
@Riverpod(keepAlive: true)
class PurchaseFlow extends _$PurchaseFlow {
  StreamSubscription<StorePurchase>? _updates;

  @override
  PurchaseFlowState build() {
    final store = ref.watch(storeClientProvider);
    _updates = store.purchases.listen((purchase) => unawaited(_onUpdate(purchase)));
    ref.onDispose(() => _updates?.cancel());
    return const PurchaseFlowState();
  }

  StoreClient get _store => ref.read(storeClientProvider);

  Future<void> buy(
    String productId, {
    required bool consumable,
    String? replacingProductId,
    bool changeNow = true,
  }) async {
    if (state.busyProductId != null) return;
    state = PurchaseFlowState(busyProductId: productId);
    try {
      await _store.buy(productId, consumable: consumable, replacingProductId: replacingProductId, changeNow: changeNow);
    } on Object catch (error) {
      state = PurchaseFlowState(failure: AppFailure(FailureKind.storeUnavailable, debugMessage: '$error'));
    }
  }

  /// Sends a paid purchase to the server again (after a network failure).
  Future<void> retry() async {
    final purchase = state.unconfirmed;
    if (purchase != null) await _confirm(purchase);
  }

  /// The notice or failure has been shown.
  void dismiss() => state = state.copyWith(notice: null, failure: null);

  Future<void> _onUpdate(StorePurchase purchase) async {
    switch (purchase.status) {
      case StorePurchaseStatus.canceled:
        state = const PurchaseFlowState();
      case StorePurchaseStatus.error:
        await _store.complete(purchase);
        state = const PurchaseFlowState(failure: AppFailure(FailureKind.unknown, debugMessage: 'Store error'));
      case StorePurchaseStatus.pending:
        state = const PurchaseFlowState(notice: PurchaseNotice.pending());
      case StorePurchaseStatus.purchased:
        await _confirm(purchase);
    }
  }

  Future<void> _confirm(StorePurchase purchase) async {
    state = PurchaseFlowState(busyProductId: purchase.productId);
    final result = await ref.read(purchaseRepositoryProvider).verify(purchase);
    switch (result) {
      case Ok(:final value):
        // A payment that has not cleared stays open in the store.
        if (value.status != VerifyStatus.pending) await _store.complete(purchase);
        state = PurchaseFlowState(notice: _noticeFor(value, purchase.productId));
      case Err(:final failure):
        // A receipt the store rejects is left unfinished: Play refunds
        // unacknowledged purchases by itself.
        final retryable = failure.kind != FailureKind.purchaseInvalid && failure.kind != FailureKind.invalidInput;
        state = PurchaseFlowState(failure: failure, unconfirmed: retryable ? purchase : null);
    }
  }

  PurchaseNotice _noticeFor(VerifyOutcome outcome, String productId) {
    final plan = ref.read(appConfigProvider).plans.where((p) => p.productId == productId).firstOrNull;
    return switch (outcome.status) {
      VerifyStatus.pending => const PurchaseNotice.pending(),
      VerifyStatus.alreadyGranted => const PurchaseNotice.alreadyAdded(),
      VerifyStatus.atRenewal => PurchaseNotice.planAtRenewal(plan?.tier ?? outcome.tier),
      VerifyStatus.granted when plan != null => PurchaseNotice.planActive(plan.tier, outcome.creditsAdded),
      VerifyStatus.granted => PurchaseNotice.creditsAdded(outcome.creditsAdded),
    };
  }
}
