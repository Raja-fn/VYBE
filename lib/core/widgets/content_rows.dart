import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'app_card.dart';

/// Muted, spaced capitals above a group: "SHOW ME", "DAY", "TIME SLOT".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text.toUpperCase(), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.muted)),
    );
  }
}

/// Static tag on a soft fill: activity tags, plan types on cards.
class AppTag extends StatelessWidget {
  const AppTag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const ShapeDecoration(
        color: AppColors.softFill,
        shape: StadiumBorder(side: BorderSide(color: AppColors.track)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.tagVertical),
        child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

/// Check or cross followed by text: the rules lists and safety checklist.
class RuleListItem extends StatelessWidget {
  const RuleListItem({required this.text, required this.allowed, super.key});

  final String text;
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            allowed ? Icons.check : Icons.close,
            size: AppSizes.icon,
            color: allowed ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

/// Rounded square tint behind an icon: green for safety, coral for places.
class IconWell extends StatelessWidget {
  const IconWell({required this.icon, this.color = AppColors.success, this.fill = AppColors.successWell, super.key});

  final IconData icon;
  final Color color;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.iconWell,
      height: AppSizes.iconWell,
      decoration: BoxDecoration(color: fill, borderRadius: const BorderRadius.all(Radius.circular(AppRadii.avatar))),
      child: Icon(icon, size: AppSizes.iconLarge, color: color),
    );
  }
}

/// Card with a green shield and a short safety message.
class SafetyNote extends StatelessWidget {
  const SafetyNote({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const IconWell(icon: Icons.verified_user_outlined),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

/// Title, optional subtitle, and a switch: "I am free now", "Share live location".
class AppSwitchTile extends StatelessWidget {
  const AppSwitchTile({required this.title, required this.value, required this.onChanged, this.subtitle, super.key});

  final String title;
  final String? subtitle;
  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sub = subtitle;
    return MergeSemantics(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleLarge),
                if (sub != null) Text(sub, style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

enum AppStepState { done, current, upcoming }

/// Numbered circle with a title and subtitle: the verification steps.
class StepRow extends StatelessWidget {
  const StepRow({required this.number, required this.title, required this.subtitle, required this.state, super.key});

  final int number;
  final String title;
  final String subtitle;
  final AppStepState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final stateLabel = switch (state) {
      AppStepState.done => l10n.stepSemanticsDone(number),
      AppStepState.current => l10n.stepSemanticsCurrent(number),
      AppStepState.upcoming => l10n.stepSemanticsUpcoming(number),
    };

    return Semantics(
      label: '$stateLabel. $title. $subtitle',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            _StepCircle(number: number, state: state),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleMedium),
                  Text(subtitle, style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.number, required this.state});

  final int number;
  final AppStepState state;

  @override
  Widget build(BuildContext context) {
    final (fill, border) = switch (state) {
      AppStepState.done => (AppColors.success, AppColors.success),
      AppStepState.current => (AppColors.accent, AppColors.accent),
      AppStepState.upcoming => (AppColors.card, AppColors.border),
    };
    return SizedBox.square(
      dimension: AppSizes.stepCircle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: AppSizes.outlineButtonBorderWidth),
        ),
        child: Center(
          child: state == AppStepState.done
              ? const Icon(Icons.check, size: AppSizes.icon, color: AppColors.onAccent)
              : Text(
                  '$number',
                  textScaler: TextScaler.noScaling,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: state == AppStepState.current ? AppColors.onAccent : AppColors.muted,
                  ),
                ),
        ),
      ),
    );
  }
}

/// The bottom of a screen holding its main action, on the page background.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({required this.child, this.caption, super.key});

  final Widget child;

  /// Optional row above the action, e.g. "Spot booking · 5 credits".
  final Widget? caption;

  @override
  Widget build(BuildContext context) {
    final top = caption;
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            AppSpacing.md,
            AppSpacing.screenGutter,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (top != null) ...[top, const SizedBox(height: AppSpacing.sm)],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
