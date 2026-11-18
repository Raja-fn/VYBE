import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_pill_button.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../booking/domain/booking_models.dart';
import '../../booking/presentation/booking_cost.dart';
import '../../booking/presentation/booking_providers.dart';
import '../../booking/presentation/bookings_screen.dart' show bookingStatusOf;
import '../../booking/presentation/widgets/booking_actions.dart';
import '../../discover/presentation/widgets/labels.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../domain/chat_models.dart';
import 'chat_actions_ui.dart';
import 'chat_providers.dart';

/// Screen 9: one conversation.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.chatId, super.key});

  final String chatId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _back() => context.canPop() ? context.pop() : context.go(AppRoutes.chats);

  Future<void> _send() async {
    final sent = await ref.read(chatComposerProvider(widget.chatId).notifier).send(_input.text);
    if (sent) _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final me = ref.watch(authUserProvider).value?.uid;
    final thread = ref.watch(myChatsProvider).value?.where((c) => c.id == widget.chatId).firstOrNull;
    final messages = ref.watch(chatMessagesProvider(widget.chatId));

    // Keep the unread badge honest while the chat is open.
    ref.listen(myChatsProvider, (_, next) {
      final current = next.value?.where((c) => c.id == widget.chatId).firstOrNull;
      if (current != null && current.unread > 0) ref.read(chatRepositoryProvider).markRead(widget.chatId);
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(thread: thread, onBack: _back),
            Expanded(
              child: AsyncStateView<List<ChatMessage>>(
                value: messages,
                onRetry: () => ref.invalidate(chatMessagesProvider(widget.chatId)),
                builder: (context, list) => _Conversation(thread: thread, messages: list, myUid: me),
              ),
            ),
            if (thread == null || thread.status == ChatStatus.open)
              _Composer(chatId: widget.chatId, controller: _input, onSend: _send)
            else
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(l10n.chatClosed, textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.thread, required this.onBack});

  final ChatThread? thread;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = thread;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back), tooltip: l10n.commonBack, onPressed: onBack),
            const SizedBox(width: AppSpacing.xs),
            if (t != null) ...[
              InitialsAvatar(name: t.otherName, size: AppSizes.avatarSmall),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    t.otherName,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              AppPillButton(
                label: l10n.chatReport,
                tone: AppPillTone.accentText,
                onPressed: () => showReportOrBlock(
                  context,
                  uid: t.otherUid,
                  name: t.otherName,
                  reportContext: ReportContext.chat,
                  refId: t.id,
                  onBlocked: () => context.go(AppRoutes.chats),
                ),
              ),
            ] else
              const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _Conversation extends ConsumerWidget {
  const _Conversation({required this.thread, required this.messages, required this.myUid});

  final ChatThread? thread;

  /// Newest first.
  final List<ChatMessage> messages;
  final String? myUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = thread;
    final bookings = ref.watch(myBookingsProvider).value ?? const <Booking>[];
    final now = DateTime.now();
    final iAmSeeker = t != null && t.seekerUid == myUid;
    final hasActiveBooking = bookings.any(
      (b) =>
          b.companionUid == t?.companionUid &&
          (b.status == BookingStatus.requested || b.status == BookingStatus.accepted) &&
          b.startAt.isAfter(now),
    );

    // The list is reversed so it opens at the newest message; the notice and
    // booking prompt sit at the start of the conversation.
    final items = <Widget>[
      for (final m in messages) _messageWidget(context, m, bookings),
      if (iAmSeeker && !hasActiveBooking) _BookPrompt(thread: t),
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            l10n.chatNotice,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ),
      ),
    ];

    return ListView.separated(
      reverse: true,
      padding: const EdgeInsets.all(AppSpacing.screenGutter),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) => items[i],
    );
  }

  Widget _messageWidget(BuildContext context, ChatMessage m, List<Booking> bookings) {
    final l10n = context.l10n;
    return switch (m.type) {
      MessageType.text => _Bubble(text: m.text ?? '', mine: m.senderUid == myUid),
      MessageType.system => Center(
        child: DecoratedBox(
          decoration: const ShapeDecoration(
            color: AppColors.card,
            shape: StadiumBorder(side: BorderSide(color: AppColors.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: Text(
              m.systemKind == 'chat_started' ? l10n.chatStartedCredits(m.credits ?? 0) : l10n.chatPreviewStarted,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ),
        ),
      ),
      MessageType.bookingCard => _BookingCard(
        message: m,
        booking: bookings.where((b) => b.id == m.bookingId).firstOrNull,
        myUid: myUid,
      ),
    };
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.mine});

  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(AppRadii.card);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * AppRatios.bubbleMaxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: mine ? AppColors.accent : AppColors.card,
            border: mine ? null : Border.all(color: AppColors.border),
            borderRadius: BorderRadius.only(
              topLeft: radius,
              topRight: radius,
              bottomLeft: mine ? radius : Radius.zero,
              bottomRight: mine ? Radius.zero : radius,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: mine ? AppColors.onAccent : AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.message, required this.booking, required this.myUid});

  final ChatMessage message;
  final Booking? booking;
  final String? myUid;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final start = message.startAt;
    final plan = planLabelFromWire(l10n, message.planType ?? '') ?? '';
    final when = start == null
        ? ''
        : '${DateFormat.E(Localizations.localeOf(context).toLanguageTag()).format(start.toLocal())} · ${clockTime(context, start)}';
    final b = booking;
    final status = b == null ? null : bookingStatusOf(l10n, b, myUid, DateTime.now()).$1;
    return AppCard(
      tone: AppCardTone.dark,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.chatBookingCardTitle(plan), style: textTheme.titleMedium?.copyWith(color: AppColors.onInk)),
          Text(
            l10n.chatBookingCardLine(when, message.venueName ?? ''),
            style: textTheme.bodyMedium?.copyWith(color: AppColors.onInkMuted),
          ),
          if (status != null) Text(status, style: textTheme.titleSmall?.copyWith(color: AppColors.gold)),
          if (b != null) BookingActions(booking: b, myUid: myUid, showCancel: false, onDark: true),
        ],
      ),
    );
  }
}

/// Seeker-only card: book a spot with this companion straight from the chat.
class _BookPrompt extends ConsumerWidget {
  const _BookPrompt({required this.thread});

  final ChatThread? thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final t = thread;
    if (t == null) return const SizedBox.shrink();
    final cost = ref.watch(appConfigProvider).creditCostBookSpot;
    return AppCard(
      tone: AppCardTone.dark,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.chatBookTitle(t.otherName), style: textTheme.titleMedium?.copyWith(color: AppColors.onInk)),
              Text(bookingCostLabel(l10n, cost), style: textTheme.bodyMedium?.copyWith(color: AppColors.onInkMuted)),
            ],
          ),
          AppButton(
            label: l10n.chatBook,
            variant: AppButtonVariant.gold,
            expand: false,
            onPressed: () => context.push(AppRoutes.book(companionUid: t.companionUid)),
          ),
        ],
      ),
    );
  }
}

class _Composer extends ConsumerWidget {
  const _Composer({required this.chatId, required this.controller, required this.onSend});

  final String chatId;
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(chatComposerProvider(chatId));
    final failure = state.failure;
    final maxLength = ref.watch(appConfigProvider).chatMessageMaxLength;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (failure != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    failureMessage(l10n, failure),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.danger),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLength: maxLength,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) {
                      if (failure != null) ref.read(chatComposerProvider(chatId).notifier).clearFailure();
                    },
                    decoration: InputDecoration(hintText: l10n.chatInputHint, counterText: ''),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Semantics(
                  button: true,
                  label: l10n.chatSend,
                  excludeSemantics: true,
                  child: Material(
                    color: AppColors.accent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: state.sending ? null : onSend,
                      child: SizedBox.square(
                        dimension: AppSizes.actionButton,
                        child: state.sending
                            ? const Padding(
                                padding: EdgeInsets.all(AppSpacing.lg),
                                child: CircularProgressIndicator(
                                  strokeWidth: AppSizes.progressStroke,
                                  color: AppColors.onAccent,
                                ),
                              )
                            : const Icon(Icons.arrow_forward, color: AppColors.onAccent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
