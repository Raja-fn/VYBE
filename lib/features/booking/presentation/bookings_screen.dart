import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../discover/presentation/widgets/labels.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../domain/booking_models.dart';
import 'booking_providers.dart';
import 'widgets/booking_actions.dart';

/// Bookings tab: the person's requests and meetups, newest first.
class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final bookings = ref.watch(myBookingsProvider);
    final me = ref.watch(authUserProvider).value?.uid;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, AppSpacing.md, AppSpacing.screenGutter, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(l10n.bookingsTitle, style: Theme.of(context).textTheme.headlineLarge),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.safetyTitle,
                    onPressed: () => context.push(AppRoutes.safety),
                    icon: const Icon(Icons.shield_outlined, color: AppColors.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AsyncStateView<List<Booking>>(
                value: bookings,
                onRetry: () => ref.invalidate(myBookingsProvider),
                isEmpty: (list) => list.isEmpty,
                emptyTitle: l10n.bookingsEmptyTitle,
                emptyMessage: l10n.bookingsEmptyBody,
                emptyIcon: Icons.calendar_today_outlined,
                builder: (context, list) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenGutter,
                    0,
                    AppSpacing.screenGutter,
                    AppSpacing.md,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => BookingCard(booking: list[i], myUid: me),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingCard extends ConsumerWidget {
  const BookingCard({required this.booking, required this.myUid, super.key});

  final Booking booking;
  final String? myUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final b = booking;
    final otherName = otherNameIn(b, myUid);
    final plan = planLabelFromWire(l10n, b.planType) ?? b.planType;
    final when = '${DateFormat.MMMEd(locale).format(b.startAt.toLocal())}, ${clockTime(context, b.startAt)}';
    final (statusText, statusColor) = bookingStatusOf(l10n, b, myUid, now);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialsAvatar(name: otherName, size: AppSizes.avatarSmall, radius: AppRadii.avatar),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.bookingsWith(plan, otherName), style: textTheme.titleMedium),
                Text(when, style: textTheme.bodyMedium),
                Text(b.venueName, style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
                const SizedBox(height: AppSpacing.xxs),
                Text(statusText, style: textTheme.titleSmall?.copyWith(color: statusColor)),
                BookingActions(booking: b, myUid: myUid),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The status line for a booking, from [myUid]'s side.
(String, Color) bookingStatusOf(AppLocalizations l10n, Booking b, String? myUid, DateTime now) {
  if (b.timePassed(now)) return (l10n.bookingsStatusTimePassed, AppColors.muted);
  return switch (b.status) {
    BookingStatus.requested when b.companionUid == myUid => (l10n.bookingsStatusYourReply, AppColors.accentText),
    BookingStatus.requested => (l10n.bookingsStatusRequested, AppColors.accentText),
    BookingStatus.accepted => (l10n.bookingsStatusAccepted, AppColors.successText),
    BookingStatus.declined => (l10n.bookingsStatusDeclined, AppColors.muted),
    BookingStatus.cancelled => (l10n.bookingsStatusCancelled, AppColors.muted),
    BookingStatus.checkedIn => (l10n.bookingsStatusCheckedIn, AppColors.successText),
    BookingStatus.completed => (l10n.bookingsStatusCompleted, AppColors.successText),
    BookingStatus.disputed => (l10n.bookingsStatusDisputed, AppColors.danger),
  };
}
