import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/onboarding/presentation/session_providers.dart';
import '../../connectivity/connectivity_service.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/run_guarded.dart';
import '../../widgets/async_state_view.dart';

/// Shown for a moment right after the splash, while the session is worked
/// out; the router moves on from here. Plain on purpose, so the splash flows
/// straight into the app. If loading the session fails, it shows the error
/// with a retry.
class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                child: error != null
                    ? ErrorStateView(failure: mapError(error), onRetry: () => ref.invalidate(authUserProvider))
                    : Center(
                        child: Semantics(
                          label: context.l10n.startLoading,
                          child: const SizedBox.square(
                            dimension: AppSizes.iconLarge,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accent),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
