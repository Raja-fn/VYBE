import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/run_guarded.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_rows.dart';
import '../../../core/widgets/legal_links.dart';
import '../data/account_repository.dart';
import 'rules_controller.dart';
import 'widgets/map_hero.dart';
import 'widgets/onboarding_scaffold.dart';

/// Screen 1: what the app is and is not for, plus 18+ consent.
class RulesScreen extends ConsumerStatefulWidget {
  const RulesScreen({super.key});

  @override
  ConsumerState<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends ConsumerState<RulesScreen> {
  bool _agreed = false;
  DateTime? _birthDate;

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      initialEntryMode: DatePickerEntryMode.input,
      helpText: context.l10n.rulesBirthDate,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final status = ref.watch(rulesControllerProvider);
    final error = status.error;
    final config = ref.watch(appConfigProvider);
    final birthDate = _birthDate;
    final tooYoung = birthDate != null && ageOnDay(birthDate, DateTime.now()) < config.ageMinimum;
    final canContinue = _agreed && birthDate != null && !tooYoung;

    return OnboardingScaffold(
      eyebrow: l10n.appName,
      title: l10n.startTagline,
      accentTitleEnd: true,
      bottom: AppButton(
        label: l10n.rulesContinue,
        isLoading: status.isLoading,
        onPressed: canContinue ? () => ref.read(rulesControllerProvider.notifier).accept(dateOfBirth: birthDate) : null,
      ),
      children: [
        const MapHero(),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RulesSection(
                title: l10n.rulesForTitle,
                allowed: true,
                items: [l10n.rulesFor1, l10n.rulesFor2, l10n.rulesFor3],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(),
              ),
              _RulesSection(
                title: l10n.rulesNotForTitle,
                allowed: false,
                items: [l10n.rulesNotFor1, l10n.rulesNotFor2, l10n.rulesNotFor3],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          onTap: _pickBirthDate,
          child: Row(
            children: [
              const Icon(Icons.cake_outlined, color: AppColors.accent),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.rulesBirthDate, style: textTheme.titleMedium),
                    Text(
                      birthDate == null
                          ? l10n.rulesBirthDateHint
                          : MaterialLocalizations.of(context).formatMediumDate(birthDate),
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
        if (tooYoung)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Semantics(
              liveRegion: true,
              child: Text(
                l10n.rulesTooYoung(config.ageMinimum),
                style: textTheme.bodyMedium?.copyWith(color: AppColors.dangerText),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        MergeSemantics(
          child: InkWell(
            onTap: () => setState(() => _agreed = !_agreed),
            borderRadius: AppRadii.cardBorder,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(value: _agreed, onChanged: (value) => setState(() => _agreed = value ?? false)),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(l10n.rulesConsent, style: textTheme.bodyLarge),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const LegalLinks(),
        if (error != null) InlineFailure(failureMessage(l10n, mapError(error))),
      ],
    );
  }
}

class _RulesSection extends StatelessWidget {
  const _RulesSection({required this.title, required this.allowed, required this.items});

  final String title;
  final bool allowed;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: allowed ? AppColors.successText : AppColors.dangerText),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final item in items) RuleListItem(text: item, allowed: allowed),
      ],
    );
  }
}
