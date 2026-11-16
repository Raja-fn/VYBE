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
import '../domain/chat_models.dart';
import 'chat_providers.dart';

/// Chats tab: open conversations, most recent first.
class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final chats = ref.watch(myChatsProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, AppSpacing.md, AppSpacing.screenGutter, 0),
              child: Semantics(
                header: true,
                child: Text(l10n.chatsTitle, style: Theme.of(context).textTheme.headlineLarge),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AsyncStateView<List<ChatThread>>(
                value: chats,
                onRetry: () => ref.invalidate(myChatsProvider),
                isEmpty: (list) => list.isEmpty,
                emptyTitle: l10n.chatsEmptyTitle,
                emptyMessage: l10n.chatsEmptyBody,
                emptyIcon: Icons.chat_bubble_outline,
                builder: (context, list) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenGutter,
                    0,
                    AppSpacing.screenGutter,
                    AppSpacing.md,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => _ChatRow(thread: list[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.thread});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final t = thread;
    final preview = switch (t.lastType) {
      MessageType.text => t.lastText,
      MessageType.bookingCard => l10n.chatPreviewBooking,
      MessageType.system => l10n.chatPreviewStarted,
    };
    final now = DateTime.now();
    final local = t.lastAt.toLocal();
    final sameDay = local.year == now.year && local.month == now.month && local.day == now.day;
    final when = sameDay
        ? clockTime(context, t.lastAt)
        : DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag()).format(local);

    return Semantics(
      button: true,
      label: [t.otherName, preview, if (t.unread > 0) l10n.chatsUnread(t.unread)].join('. '),
      excludeSemantics: true,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: () => context.push(AppRoutes.chat(t.id)),
        child: Row(
          children: [
            InitialsAvatar(name: t.otherName, size: AppSizes.avatarSmall, radius: AppRadii.avatar),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.otherName, style: textTheme.titleMedium),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(when, style: textTheme.bodySmall?.copyWith(color: AppColors.muted)),
                if (t.unread > 0)
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.xxs),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs / 2),
                    decoration: const ShapeDecoration(color: AppColors.accent, shape: StadiumBorder()),
                    child: Text('${t.unread}', style: textTheme.labelSmall?.copyWith(color: AppColors.onAccent)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
