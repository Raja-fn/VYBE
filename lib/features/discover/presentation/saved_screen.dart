import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_back_button.dart';
import '../domain/companion_summary.dart';
import 'discover_providers.dart';
import 'widgets/companion_row.dart';
import 'widgets/discovery_state_view.dart';

/// Companions the person saved from Discover. Anyone no longer visible to
/// them (moved away, changed settings, blocked) is left out by the server.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final saved = ref.watch(savedCompanionsProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, AppSpacing.md, AppSpacing.screenGutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBackButton(onPressed: () => context.go(AppRoutes.profile)),
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    header: true,
                    child: Text(l10n.savedTitle, style: Theme.of(context).textTheme.headlineLarge),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: DiscoveryStateView<List<CompanionSummary>>(
                value: saved,
                onRetry: () => ref.invalidate(savedCompanionsProvider),
                isEmpty: (list) => list.isEmpty,
                emptyTitle: l10n.savedEmptyTitle,
                emptyMessage: l10n.savedEmptyBody,
                builder: (context, list) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenGutter,
                    0,
                    AppSpacing.screenGutter,
                    AppSpacing.md,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) =>
                      CompanionRow(companion: list[i], onOpen: () => context.push(AppRoutes.companion(list[i].uid))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
