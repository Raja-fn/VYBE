import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_choice_chip.dart';
import '../../../core/widgets/content_rows.dart';
import '../../credits/presentation/get_credits.dart';
import '../domain/chat_models.dart';
import 'chat_providers.dart';

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// Opens the chat with a companion. The first time it asks before spending
/// the start-chat credit; after that it goes straight in.
Future<void> openChatWith(
  BuildContext context,
  WidgetRef ref, {
  required String companionUid,
  required String name,
}) async {
  final l10n = context.l10n;
  // The chat list may not be loaded yet (e.g. the Chats tab was never
  // opened), so wait for it. If it fails, fall back to asking; the server
  // never charges twice for the same pair.
  final keepAlive = ref.listenManual(myChatsProvider, (_, _) {});
  List<ChatThread>? chats;
  try {
    chats = await ref.read(myChatsProvider.future);
  } on Object {
    chats = null;
  } finally {
    keepAlive.close();
  }
  if (!context.mounted) return;
  final existing = chats?.where((c) => c.otherUid == companionUid).firstOrNull;
  if (existing != null) {
    await context.push(AppRoutes.chat(existing.id));
    return;
  }

  final cost = ref.read(appConfigProvider).creditCostStartChat;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.chatStartTitle(name)),
      content: Text(l10n.chatStartBody(l10n.creditsCount(cost))),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.chatStartConfirm)),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final result = await ref.read(chatActionsProvider.notifier).start(companionUid);
  if (!context.mounted) return;
  final failure = result.failureOrNull;
  if (failure != null) {
    ScaffoldMessenger.of(context).showSnackBar(failureSnackBar(context, failure));
    return;
  }
  await context.push(AppRoutes.chat(result.valueOrNull!.chatId));
}

/// "Report or block" sheet, available on every profile and chat.
/// [onBlocked] runs after a successful block (e.g. to leave the screen).
Future<void> showReportOrBlock(
  BuildContext context, {
  required String uid,
  required String name,
  required ReportContext reportContext,
  required VoidCallback onBlocked,
  String? refId,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: AppColors.background,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.photoCard))),
  builder: (_) => _ReportSheet(uid: uid, name: name, reportContext: reportContext, refId: refId, onBlocked: onBlocked),
);

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({
    required this.uid,
    required this.name,
    required this.reportContext,
    required this.refId,
    required this.onBlocked,
  });

  final String uid;
  final String name;
  final ReportContext reportContext;
  final String? refId;
  final VoidCallback onBlocked;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  ReportReason? _reason;
  final _details = TextEditingController();

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  String _label(AppLocalizations l10n, ReportReason reason) => switch (reason) {
    ReportReason.inappropriateMessages => l10n.reportReasonInappropriate,
    ReportReason.askedForContact => l10n.reportReasonContact,
    ReportReason.harassment => l10n.reportReasonHarassment,
    ReportReason.fakeProfile => l10n.reportReasonFake,
    ReportReason.safetyConcern => l10n.reportReasonSafety,
    ReportReason.other => l10n.reportReasonOther,
  };

  Future<void> _submit() async {
    final l10n = context.l10n;
    final reason = _reason;
    if (reason == null) return;
    final result = await ref
        .read(chatActionsProvider.notifier)
        .report(
          reportedUid: widget.uid,
          context: widget.reportContext,
          reason: reason,
          refId: widget.refId,
          details: _details.text,
        );
    if (!mounted) return;
    final failure = result.failureOrNull;
    Navigator.of(context).pop();
    _snack(context, failure == null ? l10n.reportSent : failureMessage(l10n, failure));
  }

  Future<void> _block() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.blockTitle(widget.name)),
        content: Text(l10n.blockBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.blockConfirm)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await ref.read(chatActionsProvider.notifier).block(widget.uid);
    if (!mounted) return;
    final failure = result.failureOrNull;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text(failure == null ? l10n.blockDone(widget.name) : failureMessage(l10n, failure))),
    );
    if (failure == null) widget.onBlocked();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final busy = ref.watch(chatActionsProvider).isLoading;
    final maxDetails = ref.watch(appConfigProvider).reportDetailsMaxLength;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(header: true, child: Text(l10n.reportTitle(widget.name), style: textTheme.headlineSmall)),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final reason in ReportReason.values)
                    AppChoiceChip(
                      label: _label(l10n, reason),
                      selected: reason == _reason,
                      onSelected: () => setState(() => _reason = reason),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _details,
                maxLength: maxDetails,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.reportDetailsHint,
                  border: const OutlineInputBorder(borderRadius: AppRadii.cardBorder),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: AppRadii.cardBorder,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(label: l10n.reportSubmit, isLoading: busy, onPressed: _reason == null ? null : _submit),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              SectionLabel(l10n.blockConfirm),
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                label: l10n.blockAction(widget.name),
                variant: AppButtonVariant.outline,
                onPressed: busy ? null : _block,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
