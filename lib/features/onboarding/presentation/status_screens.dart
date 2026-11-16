import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/content_rows.dart';
import 'session_providers.dart';

/// Shown when the account is suspended or banned.
class SuspendedScreen extends ConsumerWidget {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return _StatusScaffold(
      icon: Icons.block_outlined,
      iconColor: AppColors.danger,
      title: l10n.suspendedTitle,
      body: l10n.suspendedBody,
      onSignOut: () => _signOut(ref),
    );
  }
}

Future<void> _signOut(WidgetRef ref) async {
  await ref.read(authRepositoryProvider).signOut();
  ref.read(consentGivenProvider.notifier).reset();
}

class _StatusScaffold extends StatelessWidget {
  const _StatusScaffold({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.onSignOut,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: AppSizes.captureIcon, color: iconColor),
                      const SizedBox(height: AppSpacing.md),
                      Semantics(
                        header: true,
                        child: Text(title, style: textTheme.headlineMedium, textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        body,
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            BottomActionBar(
              child: AppButton(label: context.l10n.signOut, onPressed: onSignOut, variant: AppButtonVariant.outline),
            ),
          ],
        ),
      ),
    );
  }
}
