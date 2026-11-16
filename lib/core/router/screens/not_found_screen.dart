import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../theme/app_dimens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/async_state_view.dart';
import '../routes.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              Expanded(
                child: EmptyStateView(title: l10n.notFoundTitle, icon: Icons.explore_off_outlined),
              ),
              AppButton(label: l10n.notFoundAction, onPressed: () => context.go(AppRoutes.start)),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
