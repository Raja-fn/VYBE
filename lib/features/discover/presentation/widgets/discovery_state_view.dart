import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/app_failure.dart';
import '../../../../core/utils/run_guarded.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/async_state_view.dart';
import '../discover_providers.dart';

/// [AsyncStateView] for discovery lists, plus a dedicated "Location is
/// needed" state when location is off or not allowed.
class DiscoveryStateView<T> extends ConsumerWidget {
  const DiscoveryStateView({
    required this.value,
    required this.builder,
    required this.onRetry,
    this.isEmpty,
    this.emptyTitle,
    this.emptyMessage,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback onRetry;
  final bool Function(T data)? isEmpty;
  final String? emptyTitle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = value.error;
    if (!value.hasValue && error != null) {
      final kind = mapError(error).kind;
      if (kind == FailureKind.locationDenied || kind == FailureKind.locationRequired) {
        return _LocationNeeded(
          onAllow: () {
            ref.invalidate(locationSyncProvider);
            onRetry();
          },
        );
      }
    }
    return AsyncStateView<T>(
      value: value,
      builder: builder,
      isEmpty: isEmpty,
      emptyTitle: emptyTitle,
      emptyMessage: emptyMessage,
      emptyIcon: Icons.travel_explore_outlined,
      // The failure may have been in sending the location, so redo that too.
      onRetry: () {
        ref.invalidate(locationSyncProvider);
        onRetry();
      },
    );
  }
}

class _LocationNeeded extends ConsumerWidget {
  const _LocationNeeded({required this.onAllow});

  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final km = ref.watch(appConfigProvider).discoveryRadiusKm;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_outlined, size: AppSizes.captureIcon, color: AppColors.accent),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.locationNeededTitle, style: textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.locationNeededBody(km),
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: l10n.locationAllow, onPressed: onAllow, expand: false),
            TextButton(
              onPressed: () => ref.read(locationServiceProvider).openSettings(),
              child: Text(l10n.locationOpenSettings),
            ),
          ],
        ),
      ),
    );
  }
}
