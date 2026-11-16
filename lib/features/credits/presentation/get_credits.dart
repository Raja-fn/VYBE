import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/app_failure.dart';

/// A snack bar for [failure]. "Not enough credits" gets a Get credits button
/// that opens the Credits screen (owner decision, Phase 6).
SnackBar failureSnackBar(BuildContext context, AppFailure failure) {
  final l10n = context.l10n;
  final router = GoRouter.of(context);
  return SnackBar(
    content: Text(failureMessage(l10n, failure)),
    action: failure.kind == FailureKind.insufficientCredits
        ? SnackBarAction(label: l10n.getCredits, onPressed: () => router.push(AppRoutes.credits))
        : null,
  );
}

/// Shown under an inline "not enough credits" message.
class GetCreditsButton extends StatelessWidget {
  const GetCreditsButton({super.key});

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: TextButton(onPressed: () => context.push(AppRoutes.credits), child: Text(context.l10n.getCredits)),
  );
}
