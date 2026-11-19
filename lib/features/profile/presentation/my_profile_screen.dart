import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/content_rows.dart';
import '../../../core/widgets/legal_links.dart';
import '../../../core/widgets/storage_photo.dart';
import '../../onboarding/domain/phone_number.dart';
import '../../onboarding/domain/session_stage.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'my_profile_controller.dart';

/// Profile tab: first name, phone, saved companions and sign out.
class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  final _name = TextEditingController();
  bool _prefilled = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final config = ref.watch(appConfigProvider);
    final state = ref.watch(myProfileControllerProvider);
    final controller = ref.read(myProfileControllerProvider.notifier);
    final stage = ref.watch(sessionStageProvider).value;
    final account = stage is Ready ? stage.account : null;
    final user = ref.watch(authUserProvider).value;
    final phone = user?.phoneNumber;
    final email = user?.email;
    // Phone login shows the number; Google login shows the email.
    final signedInAs = phone != null
        ? (l10n.myProfilePhone, formatPhoneNumber(phone, countryCode: config.phoneCountryCode))
        : (email != null ? (l10n.myProfileEmail, email) : null);
    final failure = state.failure;

    final currentName = account?.displayName;
    if (!_prefilled && currentName != null) {
      _name.text = currentName;
      _prefilled = true;
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                Semantics(header: true, child: Text(l10n.myProfileTitle, style: textTheme.headlineLarge)),
                const VerifiedBadge(),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              onTap: () => context.push(AppRoutes.editProfile),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox.square(
                      dimension: AppSizes.avatar,
                      child: StoragePhoto(paths: account?.photoPaths ?? const [], name: account?.displayName ?? ''),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(account?.displayName ?? '', style: textTheme.titleLarge),
                        Text(l10n.editProfile, style: textTheme.bodyMedium?.copyWith(color: AppColors.accentText)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionLabel(l10n.myProfileName),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.givenName],
                    maxLength: config.displayNameMaxLength,
                    onSubmitted: controller.saveName,
                    decoration: InputDecoration(
                      hintText: l10n.myProfileNameHint,
                      counterText: '',
                      errorText: state.nameInvalid ? l10n.myProfileNameInvalid(config.displayNameMaxLength) : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: l10n.myProfileSaveName,
                    isLoading: state.saving,
                    onPressed: () => controller.saveName(_name.text),
                  ),
                  if (state.saved)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          l10n.myProfileNameSaved,
                          style: textTheme.bodyMedium?.copyWith(color: AppColors.successText),
                        ),
                      ),
                    ),
                  if (failure != null) InlineFailure(failureMessage(l10n, failure)),
                ],
              ),
            ),
            if (signedInAs case (final label, final value)) ...[
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: AppSpacing.sm,
                  children: [
                    Text(label, style: textTheme.bodyLarge),
                    Text(value, style: textTheme.titleMedium),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppCard(
              onTap: () => context.go(AppRoutes.saved),
              child: Row(
                children: [
                  const Icon(Icons.bookmark_border, color: AppColors.accent),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(l10n.myProfileSaved, style: textTheme.titleMedium)),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              onTap: () => context.push(AppRoutes.safety),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.accent),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(l10n.safetyTitle, style: textTheme.titleMedium)),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const _AboutCard(),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: l10n.signOut, onPressed: controller.signOut, variant: AppButtonVariant.outline),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () => _confirmDelete(context, controller),
                style: TextButton.styleFrom(foregroundColor: AppColors.dangerText),
                child: Text(l10n.deleteAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks once more, then deletes the account.
Future<void> _confirmDelete(BuildContext context, MyProfileController controller) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deleteAccountTitle),
      content: Text(l10n.deleteAccountBody),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.dangerText),
          child: Text(l10n.deleteAccountConfirm),
        ),
      ],
    ),
  );
  if (confirmed ?? false) await controller.deleteAccount();
}

/// Privacy policy, terms, support and the Grievance Officer (India IT Rules 2021).
class _AboutCard extends ConsumerWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final config = ref.watch(appConfigProvider);
    final grievanceName = config.grievanceOfficerName.trim();

    Widget row(IconData icon, String label, VoidCallback onTap, {String? detail}) => InkWell(
      onTap: onTap,
      borderRadius: AppRadii.cardBorder,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: textTheme.titleMedium),
                    if (detail != null) Text(detail, style: textTheme.bodySmall?.copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, size: AppSizes.iconSmall, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(l10n.aboutTitle),
          const SizedBox(height: AppSpacing.xs),
          row(
            Icons.privacy_tip_outlined,
            l10n.legalPrivacy,
            () => openLink(context, ref, Uri.parse(config.privacyPolicyUrl)),
          ),
          row(Icons.description_outlined, l10n.legalTerms, () => openLink(context, ref, Uri.parse(config.termsUrl))),
          row(
            Icons.mail_outline,
            l10n.aboutSupport,
            () => openLink(context, ref, mailTo(config.supportEmail, subject: 'VYBE support')),
            detail: config.supportEmail,
          ),
          row(
            Icons.gavel_outlined,
            l10n.aboutGrievance,
            () => openLink(context, ref, mailTo(config.grievanceOfficerEmail, subject: 'Grievance')),
            detail: grievanceName.isEmpty
                ? config.grievanceOfficerEmail
                : '$grievanceName · ${config.grievanceOfficerEmail}',
          ),
        ],
      ),
    );
  }
}
