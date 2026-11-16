import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connectivity/connectivity_service.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/app_failure.dart';
import '../utils/run_guarded.dart';
import 'app_button.dart';

/// Renders the loading, empty, error and offline states for an [AsyncValue].
///
/// Data stays on screen while it refreshes. When offline, cached data is
/// shown under a banner, and an error becomes the offline state.
/// Must be given bounded height (for example as a Scaffold body).
class AsyncStateView<T> extends ConsumerWidget {
  const AsyncStateView({
    required this.value,
    required this.builder,
    this.isEmpty,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.onRetry,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final bool Function(T data)? isEmpty;
  final String? emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineValueProvider);

    if (value.hasValue) {
      final data = value.requireValue;
      final empty = isEmpty?.call(data) ?? false;
      final content = empty
          ? EmptyStateView(title: emptyTitle ?? context.l10n.stateEmptyTitle, message: emptyMessage, icon: emptyIcon)
          : builder(context, data);
      return Column(
        children: [
          if (!online) const OfflineBanner(),
          Expanded(child: content),
        ],
      );
    }

    final error = value.error;
    if (error != null) {
      if (!online) return OfflineStateView(onRetry: onRetry);
      return ErrorStateView(failure: mapError(error), onRetry: onRetry);
    }

    return const LoadingStateView();
  }
}

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(label: context.l10n.commonLoading, child: const CircularProgressIndicator()),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({required this.title, this.message, this.icon = Icons.inbox_outlined, super.key});

  final String title;
  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _MessageView(icon: icon, title: title, message: message);
  }
}

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({required this.failure, this.onRetry, super.key});

  final AppFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _MessageView(
      icon: Icons.error_outline,
      iconColor: AppColors.danger,
      title: l10n.stateErrorTitle,
      message: failureMessage(l10n, failure),
      onRetry: onRetry,
    );
  }
}

class OfflineStateView extends StatelessWidget {
  const OfflineStateView({this.onRetry, super.key});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _MessageView(
      icon: Icons.wifi_off_outlined,
      title: l10n.stateOfflineTitle,
      message: l10n.stateOfflineMessage,
      onRetry: onRetry,
    );
  }
}

/// Thin raised strip shown above content while offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: ColoredBox(
        color: AppColors.softFill,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter, vertical: AppSpacing.xs),
          child: Row(
            children: [
              const Icon(Icons.wifi_off_outlined, size: AppSizes.iconSmall, color: AppColors.onInk),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  context.l10n.offlineBanner,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onInk),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    this.message,
    this.iconColor = AppColors.muted,
    this.onRetry,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final body = message;
    final retry = onRetry;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconLarge, color: iconColor),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                body,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ],
            if (retry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: context.l10n.commonRetry,
                onPressed: retry,
                variant: AppButtonVariant.outline,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
