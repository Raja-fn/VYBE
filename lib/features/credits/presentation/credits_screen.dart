import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/badges.dart';
import '../../discover/presentation/discover_providers.dart';
import '../domain/credit_models.dart';
import 'credits_providers.dart';

String planName(AppLocalizations l10n, PlanTier tier) => switch (tier) {
  PlanTier.free => l10n.planFree,
  PlanTier.plus => l10n.planPlus,
  PlanTier.premium => l10n.planPremium,
};

/// The message shown after a purchase.
String purchaseNoticeText(AppLocalizations l10n, PurchaseNotice notice) => switch (notice) {
  CreditsAddedNotice(:final credits) => l10n.creditsAdded(credits),
  PlanActiveNotice(:final tier, :final credits) => l10n.creditsPlanActive(planName(l10n, tier), credits),
  PlanAtRenewalNotice(:final tier) => l10n.creditsPlanAtRenewal(planName(l10n, tier)),
  AlreadyAddedNotice() => l10n.creditsAlreadyAdded,
  PendingNotice() => l10n.creditsPending,
};

/// Screen 11: Credits and plans. Free, Plus, Premium and three top-up packs.
class CreditsScreen extends ConsumerStatefulWidget {
  const CreditsScreen({super.key});

  @override
  ConsumerState<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends ConsumerState<CreditsScreen> {
  String? _selected;

  /// Plus by default (as in the design); the next useful choice when Plus
  /// is already the plan.
  String _defaultSelection(AppConfig config, SubscriptionInfo sub) {
    final paidPlans = config.plans.where((p) => p.productId != null).toList();
    final suggested =
        paidPlans.where((p) => p.tier == PlanTier.plus && p.tier != sub.tier).firstOrNull ??
        paidPlans.where((p) => p.tier.index > sub.tier.index).firstOrNull;
    return suggested?.productId ?? config.topUpPacks.first.productId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final config = ref.watch(appConfigProvider);
    final store = ref.watch(storeClientProvider);
    final balance = ref.watch(creditBalanceProvider).value ?? 0;
    final sub = ref.watch(mySubscriptionProvider).value ?? SubscriptionInfo.free;
    final pricesAsync = ref.watch(storePricesProvider);
    final prices = pricesAsync.value ?? const <String, String>{};
    final flow = ref.watch(purchaseFlowProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();
    String date(DateTime d) => DateFormat.MMMd(locale).format(d.toLocal());

    ref.listen(purchaseFlowProvider, (previous, next) {
      final notice = next.notice;
      final failure = next.failure;
      if (notice == null && failure == null) return;
      final text = notice != null ? purchaseNoticeText(l10n, notice) : failureMessage(l10n, failure!);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));
      ref.read(purchaseFlowProvider.notifier).dismiss();
    });

    final storeFailure = pricesAsync.error;
    final available = storeFailure == null && !pricesAsync.isLoading;
    String? priceOf(String productId) => store.isTestStore ? l10n.creditsTestPrice : prices[productId];
    bool canBuy(String productId) => available && priceOf(productId) != null;

    final selected = _selected ?? _defaultSelection(config, sub);
    final selectedPlan = config.plans.where((p) => p.productId == selected).firstOrNull;
    final selectedPack = config.topUpPacks.where((p) => p.productId == selected).firstOrNull;

    final String buttonLabel;
    VoidCallback? onBuy;
    if (selectedPlan != null) {
      final name = planName(l10n, selectedPlan.tier);
      final isCurrent = selectedPlan.tier == sub.tier || selectedPlan.tier == sub.pendingTier;
      final isDowngrade = selectedPlan.tier.index < sub.tier.index;
      buttonLabel = isCurrent
          ? l10n.creditsCurrentPlan
          : (isDowngrade ? l10n.creditsSwitchAtRenewal(name) : l10n.creditsContinueWith(name));
      final currentProduct = config.plans.where((p) => p.tier == sub.tier).firstOrNull?.productId;
      if (!isCurrent && canBuy(selected)) {
        onBuy = () => ref
            .read(purchaseFlowProvider.notifier)
            .buy(selected, consumable: false, replacingProductId: currentProduct, changeNow: !isDowngrade);
      }
    } else {
      buttonLabel = l10n.creditsBuyPack(selectedPack?.credits ?? 0);
      if (canBuy(selected)) onBuy = () => ref.read(purchaseFlowProvider.notifier).buy(selected, consumable: true);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenGutter,
                  AppSpacing.xs,
                  AppSpacing.screenGutter,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          tooltip: l10n.commonBack,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const Spacer(),
                        CreditsPill(credits: balance, onPressed: null),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Semantics(header: true, child: Text(l10n.creditsTitle, style: textTheme.headlineLarge)),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(l10n.creditsSubtitle, style: textTheme.bodyLarge?.copyWith(color: AppColors.muted)),
                    const SizedBox(height: AppSpacing.lg),
                    for (final plan in config.plans) ...[
                      _PlanCard(
                        name: planName(l10n, plan.tier),
                        price: plan.productId == null
                            ? l10n.creditsFreePrice
                            : (priceOf(plan.productId!) == null
                                  ? l10n.creditsPriceMissing
                                  : (store.isTestStore
                                        ? l10n.creditsTestPrice
                                        : l10n.creditsPerMonth(priceOf(plan.productId!)!))),
                        detail: [
                          if (plan.productId == null)
                            l10n.creditsFreeDetail(config.signupBonusCredits)
                          else
                            l10n.creditsPlanDetail(plan.monthlyCredits),
                          if (plan.tier == sub.tier && sub.renewsAt != null)
                            sub.pendingTier == null
                                ? l10n.creditsRenews(date(sub.renewsAt!))
                                : l10n.creditsMovesTo(planName(l10n, sub.pendingTier!), date(sub.renewsAt!)),
                        ].join(' · '),
                        popular: plan.tier == PlanTier.plus,
                        current: plan.tier == sub.tier,
                        selected: plan.productId != null && plan.productId == selected,
                        onTap: plan.productId == null ? null : () => setState(() => _selected = plan.productId),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Text(l10n.creditsTopUpTitle, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final (i, pack) in config.topUpPacks.indexed) ...[
                          if (i > 0) const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _PackTile(
                              credits: pack.credits,
                              price: priceOf(pack.productId) ?? l10n.creditsPriceMissing,
                              selected: pack.productId == selected,
                              onTap: () => setState(() => _selected = pack.productId),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (store.isTestStore) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(l10n.creditsTestStoreNote, style: textTheme.bodySmall?.copyWith(color: AppColors.muted)),
                    ],
                    if (storeFailure != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.failureStoreUnavailable,
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.danger),
                      ),
                    ],
                    if (flow.unconfirmed != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: l10n.creditsRetry,
                        variant: AppButtonVariant.outline,
                        isLoading: flow.busyProductId != null,
                        onPressed: () => ref.read(purchaseFlowProvider.notifier).retry(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: AppSizes.borderWidth),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenGutter),
              child: AppButton(label: buttonLabel, isLoading: flow.busyProductId != null, onPressed: onBuy),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.detail,
    required this.popular,
    required this.current,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String price;
  final String detail;
  final bool popular;
  final bool current;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: l10n.creditsPlanSemantics(name, price),
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardBorder,
          side: BorderSide(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? AppSizes.outlineButtonBorderWidth : AppSizes.borderWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xxs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ExcludeSemantics(child: Text(name, style: textTheme.titleLarge)),
                          if (popular) _Tag(label: l10n.creditsPopular, filled: true),
                          if (current) _Tag(label: l10n.creditsYourPlan, filled: false),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: ExcludeSemantics(
                        child: Text(price, style: textTheme.titleMedium, textAlign: TextAlign.end),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(detail, style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? AppColors.accent : AppColors.softFill,
        borderRadius: AppRadii.pillBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.tagVertical),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: filled ? AppColors.onAccent : AppColors.ink),
        ),
      ),
    );
  }
}

class _PackTile extends StatelessWidget {
  const _PackTile({required this.credits, required this.price, required this.selected, required this.onTap});

  final int credits;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      label: context.l10n.creditsPackSemantics(credits, price),
      excludeSemantics: true,
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.photoCardBorder,
          side: BorderSide(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? AppSizes.outlineButtonBorderWidth : AppSizes.borderWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.xs),
            child: Column(
              children: [
                Text('$credits', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  price,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
