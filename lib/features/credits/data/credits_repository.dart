import '../../../core/backend/callable_client.dart';
import '../../../core/backend/tables.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/run_guarded.dart';
import '../domain/credit_models.dart';

/// The person's own credit balance. Read-only: only the server changes it.
abstract interface class CreditsRepository {
  Stream<int> watchBalance(String uid);
}

class SupabaseCreditsRepository implements CreditsRepository {
  SupabaseCreditsRepository(this._tables);

  final Tables _tables;

  @override
  Stream<int> watchBalance(String uid) => _tables
      .watch('credit_accounts', primaryKey: const ['uid'], where: (column: 'uid', value: uid))
      .map((rows) => rows.isEmpty ? 0 : (rows.first['balance'] as num?)?.toInt() ?? 0);
}

/// Plans and purchases. Credits are only ever added by the server, after
/// the store confirms the payment.
abstract interface class PurchaseRepository {
  Stream<SubscriptionInfo> watchSubscription(String uid);

  Future<Result<VerifyOutcome>> verify(StorePurchase purchase);
}

/// Builds the plan from a `subscriptions` row (null: no row yet, so Free).
SubscriptionInfo subscriptionFromRow(Map<String, Object?>? row) {
  if (row == null) return SubscriptionInfo.free;
  final tier = planTierFromWire(row['tier'] as String?);
  final status = row['status'] as String?;
  if (tier == PlanTier.free || status != 'active') return SubscriptionInfo.free;
  final pending = row['pending_tier'] as String?;
  return SubscriptionInfo(
    tier: tier,
    renewsAt: parseTime(row['current_period_end']),
    pendingTier: pending == null ? null : planTierFromWire(pending),
  );
}

class SupabasePurchaseRepository implements PurchaseRepository {
  SupabasePurchaseRepository({required Tables tables, required CallableClient functions})
    : _tables = tables,
      _functions = functions;

  final Tables _tables;
  final CallableClient _functions;

  static const _statuses = {
    'granted': VerifyStatus.granted,
    'already_granted': VerifyStatus.alreadyGranted,
    'pending': VerifyStatus.pending,
    'at_renewal': VerifyStatus.atRenewal,
  };

  @override
  Stream<SubscriptionInfo> watchSubscription(String uid) => _tables
      .watch('subscriptions', primaryKey: const ['uid'], where: (column: 'uid', value: uid))
      .map((rows) => subscriptionFromRow(rows.firstOrNull));

  @override
  Future<Result<VerifyOutcome>> verify(StorePurchase purchase) => runGuarded(() async {
    final data = await _functions.call('verifyPurchase', {
      'platform': purchase.platform.name,
      'productId': purchase.productId,
      'purchaseToken': purchase.purchaseToken,
    });
    return VerifyOutcome(
      status: _statuses[data['status']] ?? VerifyStatus.alreadyGranted,
      creditsAdded: (data['creditsAdded'] as num?)?.toInt() ?? 0,
      balance: (data['balance'] as num?)?.toInt() ?? 0,
      tier: planTierFromWire(data['tier'] as String?),
    );
  });
}
