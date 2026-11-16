import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_choice_chip.dart';
import '../../../core/widgets/content_rows.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import '../domain/preferences.dart';
import 'preferences_controller.dart';

/// Screen 3: who the person is, who they want to see, and age range.
class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final config = ref.watch(appConfigProvider);
    final draft = ref.watch(preferencesControllerProvider);
    final controller = ref.read(preferencesControllerProvider.notifier);
    final failure = draft.failure;

    final genders = {
      Gender.woman: l10n.genderWoman,
      Gender.man: l10n.genderMan,
      Gender.nonBinary: l10n.genderNonBinary,
      Gender.undisclosed: l10n.genderUndisclosed,
    };
    final showMe = {ShowMe.women: l10n.showMeWomen, ShowMe.men: l10n.showMeMen, ShowMe.everyone: l10n.showMeEveryone};

    return OnboardingScaffold(
      step: 3,
      title: l10n.prefsTitle,
      subtitle: l10n.prefsSubtitle,
      bottom: AppButton(
        label: l10n.prefsStart,
        isLoading: draft.saving,
        onPressed: draft.canSave ? controller.save : null,
      ),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(l10n.prefsIAm),
              const SizedBox(height: AppSpacing.sm),
              _ChipGroup<Gender>(options: genders, selected: draft.gender, onSelected: controller.setGender),
              const SizedBox(height: AppSpacing.lg),
              SectionLabel(l10n.prefsShowMe),
              const SizedBox(height: AppSpacing.sm),
              _ChipGroup<ShowMe>(options: showMe, selected: draft.showMe, onSelected: controller.setShowMe),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(l10n.prefsAgeRange, style: textTheme.titleLarge)),
                  Text(
                    l10n.prefsAgeRangeValue(draft.ageMin, draft.ageMax),
                    style: textTheme.titleLarge?.copyWith(color: AppColors.accentText),
                  ),
                ],
              ),
              RangeSlider(
                values: RangeValues(draft.ageMin.toDouble(), draft.ageMax.toDouble()),
                min: config.ageMinimum.toDouble(),
                max: config.ageMaximum.toDouble(),
                divisions: config.ageMaximum - config.ageMinimum,
                labels: RangeLabels(l10n.prefsAgeMin(draft.ageMin), l10n.prefsAgeMax(draft.ageMax)),
                semanticFormatterCallback: (value) => '${value.round()}',
                onChanged: (values) => controller.setAgeRange(values.start.round(), values.end.round()),
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(child: Text(l10n.prefsDistance, style: textTheme.bodyLarge)),
                  Text(l10n.prefsDistanceValue(config.discoveryRadiusKm), style: textTheme.titleMedium),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: AppSwitchTile(
            title: l10n.prefsShowGender,
            subtitle: l10n.prefsShowGenderSubtitle,
            value: draft.showGender,
            onChanged: controller.setShowGender,
          ),
        ),
        if (failure != null) InlineFailure(failureMessage(l10n, failure)),
      ],
    );
  }
}

class _ChipGroup<T> extends StatelessWidget {
  const _ChipGroup({required this.options, required this.selected, required this.onSelected});

  final Map<T, String> options;
  final T? selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final entry in options.entries)
          AppChoiceChip(label: entry.value, selected: entry.key == selected, onSelected: () => onSelected(entry.key)),
      ],
    );
  }
}
