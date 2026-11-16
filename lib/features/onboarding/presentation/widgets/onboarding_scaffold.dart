import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/async_state_view.dart';
import '../../../../core/widgets/content_rows.dart';

/// Shared layout for the onboarding screens: optional "Step N of 3" label,
/// a big title, scrolling content and a pinned bottom action.
class OnboardingScaffold extends ConsumerWidget {
  const OnboardingScaffold({
    required this.title,
    required this.children,
    required this.bottom,
    this.step,
    this.eyebrow,
    this.subtitle,
    this.accentTitleEnd = false,
    super.key,
  });

  /// Shows the title's last word in coral with a full stop ("Meet new people, *safely.*").
  final bool accentTitleEnd;

  /// 1-based onboarding step, shown as "Step N of 3".
  final int? step;

  /// Accent label above the title (for example the app name).
  final String? eyebrow;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget bottom;

  static const totalSteps = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final online = ref.watch(isOnlineValueProvider);
    final stepNumber = step;
    final top = eyebrow;
    final sub = subtitle;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (!online) const OfflineBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenGutter,
                  AppSpacing.xl,
                  AppSpacing.screenGutter,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (stepNumber != null) ...[
                      _StepBars(step: stepNumber, total: totalSteps),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.onboardingStep(stepNumber, totalSteps).toUpperCase(),
                        style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
                      ),
                    ],
                    if (top != null)
                      Text(top.toUpperCase(), style: textTheme.labelMedium?.copyWith(color: AppColors.accent)),
                    const SizedBox(height: AppSpacing.xs),
                    Semantics(
                      header: true,
                      child: accentTitleEnd ? _AccentEndTitle(title) : Text(title, style: textTheme.displaySmall),
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(sub, style: textTheme.bodyLarge?.copyWith(color: AppColors.muted)),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    ...children,
                  ],
                ),
              ),
            ),
            BottomActionBar(child: bottom),
          ],
        ),
      ),
    );
  }
}

/// Thin progress bars above the step label: done steps coral, the rest dark.
class _StepBars extends StatelessWidget {
  const _StepBars({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 1; i <= total; i++) ...[
            if (i > 1) const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Container(
                height: AppSizes.stepBarHeight,
                decoration: BoxDecoration(
                  color: i <= step ? AppColors.accent : AppColors.track,
                  borderRadius: AppRadii.pillBorder,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "Meet new people, safely" with the last word in coral and a full stop.
class _AccentEndTitle extends StatelessWidget {
  const _AccentEndTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.displaySmall;
    final split = title.lastIndexOf(' ');
    final head = split < 0 ? '' : title.substring(0, split + 1);
    final tail = split < 0 ? title : title.substring(split + 1);
    return Text.rich(
      TextSpan(
        text: head,
        children: [
          TextSpan(
            text: '$tail.',
            style: style?.copyWith(color: AppColors.accent),
          ),
        ],
      ),
      style: style,
      semanticsLabel: title,
    );
  }
}

/// Red message under a form when an action fails.
class InlineFailure extends StatelessWidget {
  const InlineFailure(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, size: AppSizes.iconSmall, color: AppColors.danger),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.danger)),
            ),
          ],
        ),
      ),
    );
  }
}
