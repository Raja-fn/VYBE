import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';

export '../../../core/config/app_config.dart' show PlanTier;

PlanTier planTierFromWire(String? value) =>
    PlanTier.values.firstWhere((t) => t.name == value, orElse: () => PlanTier.free);

/// The person's plan, as the server keeps it in `subscriptions/{uid}`.
@immutable
class SubscriptionInfo {
  const SubscriptionInfo({required this.tier, this.renewsAt, this.pendingTier});

  static const free = SubscriptionInfo(tier: PlanTier.free);

  final PlanTier tier;

  /// End of the paid period, when the next month's credits arrive.
  final DateTime? renewsAt;

  /// A lower plan that starts at [renewsAt].
  final PlanTier? pendingTier;

  @override
  bool operator ==(Object other) =>
      other is SubscriptionInfo && other.tier == tier && other.renewsAt == renewsAt && other.pendingTier == pendingTier;

  @override
  int get hashCode => Object.hash(tier, renewsAt, pendingTier);
}

enum StorePlatform { android, ios }

enum StorePurchaseStatus { pending, purchased, canceled, error }

/// One update from Google Play / the App Store (or the test store).
@immutable
class StorePurchase {
  const StorePurchase({
    required this.productId,
    required this.status,
    required this.platform,
    this.purchaseToken = '',
    this.handle,
  });

  final String productId;
  final StorePurchaseStatus status;
  final StorePlatform platform;

  /// What the server sends to the store to confirm the payment.
  final String purchaseToken;

  /// The store's own object, needed to finish the purchase.
  final Object? handle;
}

/// What the server did with a confirmed purchase.
enum VerifyStatus { granted, alreadyGranted, pending, atRenewal }

@immutable
class VerifyOutcome {
  const VerifyOutcome({required this.status, required this.creditsAdded, required this.balance, required this.tier});

  final VerifyStatus status;
  final int creditsAdded;
  final int balance;
  final PlanTier tier;
}
