import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/app_failure.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_pill_button.dart';
import '../../domain/booking_models.dart';
import '../booking_providers.dart';

/// What the person can do with a booking right now: accept or decline a
/// request, "I'm here" at the venue, "How did it go?" afterwards, cancel.
class BookingActions extends ConsumerWidget {
  const BookingActions({
    required this.booking,
    required this.myUid,
    this.showCancel = true,
    this.onDark = false,
    super.key,
  });

  final Booking booking;
  final String? myUid;
  final bool showCancel;

  /// On a dark card (the chat booking card).
  final bool onDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final config = ref.watch(appConfigProvider);
    final busy = ref.watch(meetupActionsProvider).isLoading || ref.watch(cancelBookingProvider).isLoading;
    final b = booking;
    final now = DateTime.now();
    final secondary = onDark ? AppPillTone.raised : AppPillTone.soft;

    final actions = <Widget>[
      if (b.canRespond(myUid, now)) ...[
        AppPillButton(
          label: l10n.bookingAccept,
          tone: AppPillTone.accent,
          onPressed: busy ? null : () => _respond(context, ref, accept: true),
        ),
        AppPillButton(
          label: l10n.bookingDecline,
          tone: secondary,
          onPressed: busy ? null : () => _respond(context, ref, accept: false),
        ),
      ],
      if (b.canCheckIn(
        myUid,
        now,
        before: Duration(minutes: config.checkInWindowMinutesBefore),
        after: Duration(minutes: config.checkInWindowMinutesAfter),
      ))
        AppPillButton(
          label: l10n.bookingCheckIn,
          tone: AppPillTone.accent,
          onPressed: busy ? null : () => _checkIn(context, ref),
        ),
      if (b.canGiveFeedback(myUid, now))
        AppPillButton(
          label: l10n.bookingFeedback,
          tone: AppPillTone.accent,
          onPressed: busy ? null : () => showMeetFeedbackSheet(context, b, myUid),
        ),
      if (showCancel && b.canCancel(now))
        AppPillButton(
          label: l10n.bookingsCancel,
          tone: onDark ? AppPillTone.raised : AppPillTone.accentText,
          onPressed: busy ? null : () => _cancel(context, ref),
        ),
    ];
    if (actions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Wrap(spacing: AppSpacing.xs, runSpacing: AppSpacing.xs, children: actions),
    );
  }

  static void _tell(BuildContext context, String text, {SnackBarAction? action}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), action: action));

  Future<void> _respond(BuildContext context, WidgetRef ref, {required bool accept}) async {
    final l10n = context.l10n;
    final failure = await ref.read(meetupActionsProvider.notifier).respond(booking.id, accept: accept);
    if (!context.mounted) return;
    _tell(
      context,
      failure != null
          ? failureMessage(l10n, failure)
          : accept
          ? l10n.bookingAcceptedNote
          : l10n.bookingDeclinedNote,
    );
  }

  Future<void> _checkIn(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final failure = await ref.read(meetupActionsProvider.notifier).checkIn(booking.id);
    if (!context.mounted) return;
    if (failure != null) return _tell(context, failureMessage(l10n, failure));
    _tell(
      context,
      l10n.bookingCheckedInNote,
      action: SnackBarAction(label: l10n.safetyTitle, onPressed: () => context.push(AppRoutes.safety)),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.bookingsCancelTitle),
        content: Text(l10n.bookingsCancelBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.bookingsKeep)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.bookingsCancelConfirm)),
        ],
      ),
    );
    if (confirmed != true) return;
    final failure = await ref.read(cancelBookingProvider.notifier).cancel(booking.id);
    if (!context.mounted) return;
    _tell(context, failure == null ? l10n.bookingsCancelled : failureMessage(l10n, failure));
  }
}

/// The other person's name, from where [myUid] sits in the booking.
String otherNameIn(Booking b, String? myUid) => b.seekerUid == myUid ? b.companionName : b.seekerName;

/// Private "How did it go?" after a meetup.
Future<void> showMeetFeedbackSheet(BuildContext context, Booking booking, String? myUid) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _MeetFeedbackForm(booking: booking, otherName: otherNameIn(booking, myUid)),
);

class _MeetFeedbackForm extends ConsumerStatefulWidget {
  const _MeetFeedbackForm({required this.booking, required this.otherName});

  final Booking booking;
  final String otherName;

  @override
  ConsumerState<_MeetFeedbackForm> createState() => _MeetFeedbackFormState();
}

class _MeetFeedbackFormState extends ConsumerState<_MeetFeedbackForm> {
  final _note = TextEditingController();
  MeetFeeling? _felt;
  AppFailure? _failure;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final felt = _felt;
    if (felt == null) return;
    final l10n = context.l10n;
    final note = _note.text.trim();
    final failure = await ref
        .read(meetupActionsProvider.notifier)
        .feedback(widget.booking.id, felt: felt, note: note.isEmpty ? null : note);
    if (!mounted) return;
    if (failure != null) return setState(() => _failure = failure);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(felt == MeetFeeling.unsafe ? l10n.reportSent : l10n.feedbackThanks)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final sending = ref.watch(meetupActionsProvider).isLoading;
    final config = ref.watch(appConfigProvider);
    final failure = _failure;
    final choices = {
      MeetFeeling.good: l10n.feedbackGood,
      MeetFeeling.okay: l10n.feedbackOkay,
      MeetFeeling.unsafe: l10n.feedbackUnsafe,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        0,
        AppSpacing.screenGutter,
        AppSpacing.screenGutter + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.feedbackTitle(widget.otherName), style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(l10n.feedbackPrivate(widget.otherName), style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
            const SizedBox(height: AppSpacing.md),
            RadioGroup<MeetFeeling>(
              groupValue: _felt,
              onChanged: (value) {
                if (!sending) setState(() => _felt = value);
              },
              child: Column(
                children: [
                  for (final MapEntry(key: felt, value: label) in choices.entries)
                    RadioListTile<MeetFeeling>(value: felt, title: Text(label), contentPadding: EdgeInsets.zero),
                ],
              ),
            ),
            TextField(
              controller: _note,
              enabled: !sending,
              maxLength: config.reportDetailsMaxLength,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: l10n.feedbackNoteHint),
            ),
            if (failure != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  failureMessage(l10n, failure),
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.dangerText),
                ),
              ),
            AppButton(label: l10n.feedbackSend, isLoading: sending, onPressed: _felt == null || sending ? null : _send),
          ],
        ),
      ),
    );
  }
}
