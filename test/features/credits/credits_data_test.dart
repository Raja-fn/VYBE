import 'dart:async';

import 'package:findx/app.dart';
import 'package:findx/core/backend/callable_client.dart';
import 'package:findx/core/utils/app_failure.dart';
import 'package:findx/features/credits/data/credits_repository.dart';
import 'package:findx/features/credits/data/store_client.dart';
import 'package:findx/features/credits/domain/credit_models.dart';
import 'package:findx/features/credits/presentation/credits_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_tables.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

/// A store whose updates the test pushes by hand.
class ScriptedStore implements StoreClient {
  final updates = StreamController<StorePurchase>.broadcast();
  final List<(String, bool, String?, bool)> bought = [];
  final List<StorePurchase> completed = [];
  bool available = true;
  Object? buyError;

  @override
  bool get isTestStore => false;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<Map<String, String>> prices(Set<String> productIds) async => {for (final id in productIds) id: '₹99'};

  @override
  Stream<StorePurchase> get purchases => updates.stream;

  @override
  Future<void> buy(
    String productId, {
    required bool consumable,
    String? replacingProductId,
    bool changeNow = true,
  }) async {
    final error = buyError;
    if (error != null) throw error;
    bought.add((productId, consumable, replacingProductId, changeNow));
  }

  @override
  Future<void> complete(StorePurchase purchase) async => completed.add(purchase);
}

StorePurchase _paid(String productId, {String token = 'fake-t1-abc'}) => StorePurchase(
  productId: productId,
  status: StorePurchaseStatus.purchased,
  platform: StorePlatform.android,
  purchaseToken: token,
);

void main() {
  group('SupabasePurchaseRepository', () {
    late FakeTables tables;
    late FakeCallableClient functions;
    late SupabasePurchaseRepository repository;

    setUp(() {
      tables = FakeTables();
      functions = FakeCallableClient();
      repository = SupabasePurchaseRepository(tables: tables, functions: functions);
    });

    test('reads the plan, its renewal date and a waiting downgrade', () async {
      tables.seed('subscriptions', [
        {
          'uid': 'me',
          'tier': 'premium',
          'status': 'active',
          'current_period_end': DateTime(2026, 12, 12).toUtc().toIso8601String(),
          'pending_tier': 'plus',
        },
      ]);
      final sub = await repository.watchSubscription('me').first;
      expect(
        sub,
        SubscriptionInfo(tier: PlanTier.premium, renewsAt: DateTime(2026, 12, 12), pendingTier: PlanTier.plus),
      );
    });

    test('an ended, refunded or missing plan is Free', () async {
      expect(await repository.watchSubscription('nobody').first, SubscriptionInfo.free);
      tables.seed('subscriptions', [
        {'uid': 'me', 'tier': 'plus', 'status': 'expired'},
        {'uid': 'you', 'tier': 'plus', 'status': 'refunded'},
      ]);
      expect(await repository.watchSubscription('me').first, SubscriptionInfo.free);
      expect(await repository.watchSubscription('you').first, SubscriptionInfo.free);
    });

    test('sends the receipt to verifyPurchase and reads the result', () async {
      functions.responses['verifyPurchase'] = {
        'status': 'granted',
        'creditsAdded': 100,
        'balance': 120,
        'tier': 'plus',
      };
      final outcome = (await repository.verify(_paid('findx_plus_monthly'))).valueOrNull!;
      expect(functions.calls.single.$1, 'verifyPurchase');
      expect(functions.calls.single.$2, {
        'platform': 'android',
        'productId': 'findx_plus_monthly',
        'purchaseToken': 'fake-t1-abc',
      });
      expect(outcome.status, VerifyStatus.granted);
      expect(outcome.creditsAdded, 100);
      expect(outcome.balance, 120);
      expect(outcome.tier, PlanTier.plus);
    });

    test('a receipt the store rejects becomes a purchase failure', () async {
      functions.error = const ServerException('failed-precondition', code: 'purchase_invalid', message: 'no');
      expect((await repository.verify(_paid('findx_credits_10'))).failureOrNull?.kind, FailureKind.purchaseInvalid);
    });
  });

  test('the test store pays at once with a fake receipt and has no prices', () async {
    final store = TestStoreClient(now: () => DateTime.fromMillisecondsSinceEpoch(1700000000000));
    final next = store.purchases.first;
    await store.buy('findx_credits_10', consumable: true);
    final purchase = await next;
    expect(purchase.status, StorePurchaseStatus.purchased);
    expect(purchase.purchaseToken, startsWith('fake-t1700000000000-'));
    expect(await store.prices({'findx_credits_10'}), isEmpty);
    expect(store.isTestStore, isTrue);
  });

  group('PurchaseFlow', () {
    late TestBackend backend;
    late ScriptedStore store;
    late ProviderContainer container;

    setUp(() {
      backend = readyBackend();
      store = ScriptedStore();
      backend.store = store;
      container = ProviderContainer(
        retry: noAutomaticRetry,
        overrides: baseOverrides(backend: backend),
      );
      addTearDown(container.dispose);
      container.listen(purchaseFlowProvider, (_, _) {});
    });

    PurchaseFlow flow() => container.read(purchaseFlowProvider.notifier);
    PurchaseFlowState state() => container.read(purchaseFlowProvider);
    Future<void> push(StorePurchase purchase) async {
      store.updates.add(purchase);
      await pumpEventQueue();
    }

    test('a pack: store, then server, then the store is told it is done', () async {
      await flow().buy('findx_credits_30', consumable: true);
      expect(store.bought.single, ('findx_credits_30', true, null, true));
      expect(state().busyProductId, 'findx_credits_30');

      await push(_paid('findx_credits_30'));
      expect(backend.credits.balance.value, 50);
      expect(store.completed, hasLength(1));
      expect(state().notice, const PurchaseNotice.creditsAdded(30));
      expect(state().busyProductId, isNull);
    });

    test('a plan becomes active', () async {
      await push(_paid('findx_plus_monthly'));
      expect(state().notice, const PurchaseNotice.planActive(PlanTier.plus, 100));
      expect(backend.purchases.subscription.value.tier, PlanTier.plus);
    });

    test('a downgrade is announced for the renewal', () async {
      backend.purchases.subscription.value = SubscriptionInfo(tier: PlanTier.premium, renewsAt: DateTime(2026, 12, 12));
      await flow().buy(
        'findx_plus_monthly',
        consumable: false,
        replacingProductId: 'findx_premium_monthly',
        changeNow: false,
      );
      expect(store.bought.single, ('findx_plus_monthly', false, 'findx_premium_monthly', false));
      await push(_paid('findx_plus_monthly'));
      expect(state().notice, const PurchaseNotice.planAtRenewal(PlanTier.plus));
    });

    test('a payment that has not cleared stays open in the store', () async {
      backend.purchases.pending = true;
      await push(_paid('findx_credits_10'));
      expect(state().notice, const PurchaseNotice.pending());
      expect(store.completed, isEmpty);
    });

    test('a store "pending" update says so', () async {
      await push(
        const StorePurchase(
          productId: 'findx_credits_10',
          status: StorePurchaseStatus.pending,
          platform: StorePlatform.android,
        ),
      );
      expect(state().notice, const PurchaseNotice.pending());
    });

    test('cancelling clears the busy state', () async {
      await flow().buy('findx_credits_10', consumable: true);
      await push(
        const StorePurchase(
          productId: 'findx_credits_10',
          status: StorePurchaseStatus.canceled,
          platform: StorePlatform.android,
        ),
      );
      expect(state(), const PurchaseFlowState());
    });

    test('offline: the paid purchase is kept and Try again confirms it', () async {
      backend.purchases.failure = const AppFailure(FailureKind.network);
      await push(_paid('findx_credits_10'));
      expect(state().failure?.kind, FailureKind.network);
      expect(state().unconfirmed, isNotNull);
      expect(store.completed, isEmpty);

      backend.purchases.failure = null;
      flow().dismiss();
      expect(state().unconfirmed, isNotNull);
      await flow().retry();
      expect(state().notice, const PurchaseNotice.creditsAdded(10));
      expect(state().unconfirmed, isNull);
      expect(store.completed, hasLength(1));
    });

    test('a rejected receipt is not retried or finished', () async {
      backend.purchases.failure = const AppFailure(FailureKind.purchaseInvalid);
      await push(_paid('findx_credits_10'));
      expect(state().failure?.kind, FailureKind.purchaseInvalid);
      expect(state().unconfirmed, isNull);
      expect(store.completed, isEmpty);
    });

    test('a store that cannot open its payment sheet is reported', () async {
      store.buyError = StateError('billing unavailable');
      await flow().buy('findx_credits_10', consumable: true);
      expect(state().failure?.kind, FailureKind.storeUnavailable);
      expect(state().busyProductId, isNull);
    });

    test('store prices, or a clear failure when the store is unavailable', () async {
      expect(await container.read(storePricesProvider.future), containsPair('findx_plus_monthly', '₹99'));
      store.available = false;
      container.invalidate(storePricesProvider);
      await expectLater(
        container.read(storePricesProvider.future),
        throwsA(isA<AppFailure>().having((f) => f.kind, 'kind', FailureKind.storeUnavailable)),
      );
    });
  });
}
