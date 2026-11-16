import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/onboarding/presentation/session_providers.dart';
import '../../config/app_env.dart';
import '../../connectivity/connectivity_service.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/run_guarded.dart';
import '../../widgets/app_button.dart';
import '../../widgets/async_state_view.dart';
import '../../widgets/content_rows.dart';
import '../routes.dart';

/// First screen while the session is worked out; the router moves on from
/// here. If loading the session fails, it shows the error with a retry.
/// Test builds also link to the component gallery.
class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final env = ref.watch(appEnvProvider);
    final online = ref.watch(isOnlineValueProvider);
    final error = ref.watch(sessionStageProvider).error;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!online) const OfflineBanner(),
            Expanded(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    Semantics(
                      header: true,
                      child: Text(l10n.appName, style: textTheme.headlineLarge?.copyWith(color: AppColors.accent)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(l10n.startTagline, style: textTheme.displaySmall),
                    Expanded(
                      child: error != null
                          ? ErrorStateView(failure: mapError(error), onRetry: () => ref.invalidate(authUserProvider))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const LoadingStateView(),
                                const SizedBox(height: AppSpacing.sm),
                                Text(l10n.startLoading, style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            if (env.isDev)
              BottomActionBar(
                child: AppButton(
                  label: l10n.devGalleryOpen,
                  variant: AppButtonVariant.outline,
                  onPressed: () => context.push(AppRoutes.devComponents),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
