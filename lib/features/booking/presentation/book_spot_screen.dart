import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/app_failure.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_choice_chip.dart';
import '../../../core/widgets/app_pill_button.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/content_rows.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../credits/presentation/get_credits.dart';
import '../../discover/domain/companion_summary.dart';
import '../../discover/presentation/discover_providers.dart';
import '../../discover/presentation/widgets/discovery_state_view.dart';
import '../../discover/presentation/widgets/labels.dart';
import '../../map/presentation/map_screen.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import '../domain/booking_models.dart';
import 'booking_providers.dart';
import 'widgets/venue_labels.dart';

/// Screen 6: the chosen companion and venue, a day and a time, then Confirm.
class BookSpotScreen extends ConsumerWidget {
  const BookSpotScreen({
    required this.companionUid,
    this.plan,
    this.initialVenueId,
    this.kind = BookingKind.scheduled,
    super.key,
  });

  final String companionUid;
  final PlanType? plan;
  final String? initialVenueId;
  final BookingKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companion = ref.watch(companionProfileProvider(companionUid));

    void back() => context.canPop() ? context.pop() : context.go(AppRoutes.discover);

    return Scaffold(
      body: SafeArea(
        child: companion.hasValue
            ? _BookSpot(
                companion: companion.requireValue,
                plan: plan ?? _firstPlan(companion.requireValue),
                initialVenueId: initialVenueId,
                kind: kind,
                onBack: back,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: AppBackButton(onPressed: back),
                  ),
                  Expanded(
                    child: DiscoveryStateView<CompanionSummary>(
                      value: companion,
                      onRetry: () => ref.invalidate(companionProfileProvider(companionUid)),
                      builder: (context, _) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  static PlanType _firstPlan(CompanionSummary c) =>
      PlanType.values.firstWhere((p) => c.planTypes.contains(p.name), orElse: () => PlanType.coffee);
}

class _BookSpot extends ConsumerWidget {
  const _BookSpot({
    required this.companion,
    required this.plan,
    required this.initialVenueId,
    required this.kind,
    required this.onBack,
  });

  final CompanionSummary companion;
  final PlanType plan;
  final String? initialVenueId;
  final BookingKind kind;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final config = ref.watch(appConfigProvider);
    final provider = bookSpotControllerProvider(companion.uid);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final venues = ref.watch(nearbyVenuesProvider(plan: plan, companionUid: companion.uid));
    final venueList = venues.value ?? const <Venue>[];
    final venueId = state.venueId ?? initialVenueId ?? venueList.firstOrNull?.venueId;
    final venue = venueList.where((v) => v.venueId == venueId).firstOrNull;
    final cost = kind == BookingKind.instant ? config.creditCostInstantRequest : config.creditCostBookSpot;
    final failure = state.failure;

    ref.listen(provider.select((s) => s.sent), (_, sent) {
      if (!sent) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bookSent(companion.displayName))));
      context.go(AppRoutes.bookings);
    });

    Future<void> changeVenue() async {
      final picked = await context.push<String>(AppRoutes.pickSpot(companionUid: companion.uid, plan: plan));
      if (picked != null) controller.selectVenue(picked);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppBackButton(onPressed: onBack),
                    Semantics(header: true, child: Text(l10n.bookTitle, style: textTheme.headlineMedium)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _CompanionCard(companion: companion, plan: plan),
                const SizedBox(height: AppSpacing.md),
                if (venue != null)
                  _VenueCard(venue: venue, onChange: changeVenue)
                else
                  SizedBox(
                    height: AppSizes.avatar * 2,
                    child: DiscoveryStateView<List<Venue>>(
                      value: venues,
                      onRetry: () => ref.invalidate(nearbyVenuesProvider(plan: plan, companionUid: companion.uid)),
                      isEmpty: (list) => list.isEmpty,
                      emptyTitle: l10n.bookNoVenue,
                      builder: (context, _) => const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                SectionLabel(l10n.bookDay),
                const SizedBox(height: AppSpacing.sm),
                _DayChips(selected: state.day, daysAhead: config.bookingDaysAhead, onSelected: controller.selectDay),
                if (venue != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  SectionLabel(l10n.bookTimeSlot),
                  const SizedBox(height: AppSpacing.sm),
                  _SlotChips(
                    venueId: venue.venueId,
                    dayKey: dayKeyOf(state.day),
                    companionUid: companion.uid,
                    selected: state.slotId,
                    onSelected: controller.selectSlot,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                SafetyNote(text: l10n.bookSafety),
                if (failure != null) InlineFailure(failureMessage(l10n, failure)),
                if (failure?.kind == FailureKind.insufficientCredits) const GetCreditsButton(),
              ],
            ),
          ),
        ),
        BottomActionBar(
          caption: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      kind == BookingKind.instant ? l10n.bookInstantCostLabel : l10n.bookCostLabel,
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                    ),
                  ),
                  Text(l10n.creditsCount(cost), style: textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(l10n.bookNoRefund, style: textTheme.bodySmall?.copyWith(color: AppColors.muted)),
            ],
          ),
          child: AppButton(
            label: l10n.bookConfirm,
            isLoading: state.submitting,
            onPressed: venueId == null || state.slotId == null
                ? null
                : () => controller.confirm(venueId: venueId, plan: plan, kind: kind),
          ),
        ),
      ],
    );
  }
}

class _CompanionCard extends StatelessWidget {
  const _CompanionCard({required this.companion, required this.plan});

  final CompanionSummary companion;
  final PlanType plan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final freeUntil = companion.freeNowUntil;
    final line = [
      planLabel(l10n, plan),
      if (freeUntil != null) l10n.cardFreeUntil(clockTime(context, freeUntil)),
    ].join(' · ');
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          InitialsAvatar(name: companion.displayName, radius: AppRadii.avatar),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.cardNameAge(companion.displayName, companion.ageYears), style: textTheme.titleLarge),
                Text(line, style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          const Flexible(child: VerifiedBadge()),
        ],
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({required this.venue, required this.onChange});

  final Venue venue;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      tone: AppCardTone.dark,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          RankCircle(rank: venue.rank),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name, style: textTheme.titleLarge?.copyWith(color: AppColors.onInk)),
                Text(
                  l10n.bookVenueLine(kmText(venue.distanceKm)),
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.onInkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          AppPillButton(label: l10n.bookChange, tone: AppPillTone.raised, onPressed: onChange),
        ],
      ),
    );
  }
}

class _DayChips extends StatelessWidget {
  const _DayChips({required this.selected, required this.daysAhead, required this.onSelected});

  final DateTime selected;
  final int daysAhead;
  final ValueChanged<DateTime> onSelected;

  /// Today plus the next two days as chips, then "Pick a day".
  static const _quickDays = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final quick = [for (var i = 0; i < _quickDays && i < daysAhead; i++) today.add(Duration(days: i))];
    final pickedOther = !quick.contains(selected);

    Future<void> pickDay() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selected,
        firstDate: today,
        lastDate: today.add(Duration(days: daysAhead - 1)),
      );
      if (picked != null) onSelected(picked);
    }

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final day in quick)
          AppChoiceChip(
            label: day == today ? l10n.bookToday : DateFormat.E(locale).format(day),
            selected: day == selected,
            onSelected: () => onSelected(day),
          ),
        AppChoiceChip(
          label: pickedOther ? DateFormat.MMMEd(locale).format(selected) : l10n.bookPickDay,
          selected: pickedOther,
          onSelected: pickDay,
        ),
      ],
    );
  }
}

class _SlotChips extends ConsumerWidget {
  const _SlotChips({
    required this.venueId,
    required this.dayKey,
    required this.companionUid,
    required this.selected,
    required this.onSelected,
  });

  final String venueId;
  final String dayKey;
  final String companionUid;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final slots = ref.watch(venueSlotsProvider(venueId: venueId, dayKey: dayKey, companionUid: companionUid));
    final list = slots.value?.where((s) => s.state != SlotState.past).toList();
    if (list == null) {
      return SizedBox(
        height: AppSizes.avatar * 2,
        child: DiscoveryStateView<List<VenueSlot>>(
          value: slots,
          onRetry: () =>
              ref.invalidate(venueSlotsProvider(venueId: venueId, dayKey: dayKey, companionUid: companionUid)),
          builder: (context, _) => const SizedBox.shrink(),
        ),
      );
    }
    if (list.isEmpty) {
      return Text(l10n.bookNoSlots, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted));
    }
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final slot in list)
          AppChoiceChip(
            label: clockTime(context, slot.startAt),
            selected: slot.slotId == selected,
            enabled: slot.isBookable,
            semanticLabel: slot.isBookable ? null : l10n.bookSlotUnavailableSemantics(clockTime(context, slot.startAt)),
            onSelected: () => onSelected(slot.slotId),
          ),
      ],
    );
  }
}
