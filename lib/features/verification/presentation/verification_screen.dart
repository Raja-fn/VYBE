import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/services/identity_verification/identity_verification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/run_guarded.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_choice_chip.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/content_rows.dart';
import '../../onboarding/domain/phone_number.dart';
import '../../onboarding/domain/session_stage.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import '../domain/verification_view.dart';
import 'verification_controller.dart';
import 'widgets/capture_frame.dart';
import 'widgets/resend_code_button.dart';

/// Screen 2: sign in (Google; phone OTP when switched on), selfie check and ID check.
class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stageValue = ref.watch(sessionStageProvider);
    final stage = stageValue.value;
    if (stage == null) {
      return Scaffold(
        body: stageValue.hasError
            ? ErrorStateView(failure: mapError(stageValue.error!), onRetry: () => ref.invalidate(authUserProvider))
            : const LoadingStateView(),
      );
    }

    final l10n = context.l10n;
    final flow = ref.watch(verificationControllerProvider);
    final controller = ref.read(verificationControllerProvider.notifier);
    final config = ref.watch(appConfigProvider);
    final view = verificationViewFor(stage, codeSent: flow.codeSent);
    final steps = stepStates(stage);
    final failure = flow.failure;

    final (String label, VoidCallback? onPressed, AppButtonVariant variant) = switch (view) {
      VerificationView.signIn => (l10n.verifyContinueWithGoogle, controller.signInWithGoogle, AppButtonVariant.primary),
      VerificationView.enterCode => (
        l10n.verifyConfirmCode,
        () => controller.confirmCode(_code.text),
        AppButtonVariant.primary,
      ),
      VerificationView.finishAccount => (l10n.verifyContinue, controller.createAccount, AppButtonVariant.primary),
      VerificationView.selfie => (l10n.verifyTakeSelfie, controller.captureAndSubmit, AppButtonVariant.primary),
      VerificationView.document => (
        l10n.verifyTakeIdPhoto,
        flow.documentType == null ? null : controller.captureAndSubmit,
        AppButtonVariant.primary,
      ),
      VerificationView.rejected => (l10n.verifyTryAgain, controller.captureAndSubmit, AppButtonVariant.primary),
      VerificationView.inReview ||
      VerificationView.underage => (l10n.signOut, controller.signOut, AppButtonVariant.outline),
    };

    return OnboardingScaffold(
      step: 2,
      title: l10n.verifyTitle,
      bottom: AppButton(label: label, onPressed: onPressed, variant: variant, isLoading: flow.busy),
      children: [
        AppCard(
          child: Column(
            children: [
              StepRow(
                number: 1,
                title: l10n.verifySignInTitle,
                subtitle: steps.phone == AppStepState.done
                    ? l10n.verifySignInDone
                    : (config.phoneLoginEnabled ? l10n.verifySignInSubtitleWithPhone : l10n.verifySignInSubtitle),
                state: steps.phone,
              ),
              StepRow(
                number: 2,
                title: l10n.verifySelfieTitle,
                subtitle: l10n.verifySelfieSubtitle,
                state: steps.selfie,
              ),
              StepRow(number: 3, title: l10n.verifyIdTitle, subtitle: l10n.verifyIdSubtitle, state: steps.id),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        switch (view) {
          VerificationView.signIn => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.verifySignInBody, style: Theme.of(context).textTheme.bodyLarge),
              if (config.phoneLoginEnabled) ...[
                const SizedBox(height: AppSpacing.lg),
                SectionLabel(l10n.verifyOrPhone),
                const SizedBox(height: AppSpacing.xs),
                _PhoneForm(
                  controller: _phone,
                  countryCode: config.phoneCountryCode,
                  invalidMessage: flow.phoneInvalid ? l10n.verifyPhoneInvalid(config.phoneNationalNumberLength) : null,
                  onSubmitted: () => controller.sendCode(_phone.text),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.verifySendCode,
                  variant: AppButtonVariant.outline,
                  onPressed: flow.busy ? null : () => controller.sendCode(_phone.text),
                ),
              ],
            ],
          ),
          VerificationView.enterCode => _CodeForm(
            controller: _code,
            codeLength: config.otpLength,
            phone: formatPhoneNumber(flow.phoneE164 ?? '', countryCode: config.phoneCountryCode),
            invalid: flow.codeInvalid,
            codeSentAt: flow.codeSentAt,
            busy: flow.busy,
            onResend: controller.resendCode,
            onChangeNumber: () {
              _code.clear();
              controller.changeNumber();
            },
            onSubmitted: () => controller.confirmCode(_code.text),
          ),
          VerificationView.finishAccount => _Message(title: l10n.verifyFinishTitle, body: l10n.verifyFinishBody),
          VerificationView.selfie => _CaptureSection(frame: CaptureFrame.selfie(label: l10n.verifySelfieFrame)),
          VerificationView.document => _CaptureSection(
            header: _DocumentChoice(selected: flow.documentType, onSelected: controller.chooseDocument),
            frame: CaptureFrame.document(label: l10n.verifyIdFrame),
          ),
          VerificationView.inReview => _Message(
            title: l10n.verifyReviewTitle,
            body: l10n.verifyReviewBody,
            icon: Icons.hourglass_top_outlined,
          ),
          VerificationView.rejected => _Message(
            title: l10n.verifyRejectedTitle,
            body: l10n.verifyRejectedBody,
            icon: Icons.error_outline,
            iconColor: AppColors.danger,
          ),
          VerificationView.underage => _Message(
            title: l10n.verifyUnderageTitle,
            body: l10n.verifyUnderageBody,
            icon: Icons.block_outlined,
            iconColor: AppColors.danger,
          ),
        },
        if (failure != null) InlineFailure(failureMessage(l10n, failure)),
        if (stage is! SignedOut && view != VerificationView.inReview && view != VerificationView.underage) ...[
          const SizedBox(height: AppSpacing.md),
          Center(
            child: TextButton(
              onPressed: flow.busy ? null : controller.signOut,
              child: Text(l10n.verifyUseDifferentNumber),
            ),
          ),
        ],
      ],
    );
  }
}

class _PhoneForm extends StatelessWidget {
  const _PhoneForm({
    required this.controller,
    required this.countryCode,
    required this.invalidMessage,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String countryCode;
  final String? invalidMessage;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(l10n.verifyPhoneLabel),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumberNational],
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-]'))],
          onSubmitted: (_) => onSubmitted(),
          decoration: InputDecoration(
            prefixText: '$countryCode ',
            hintText: l10n.verifyPhoneHint,
            errorText: invalidMessage,
          ),
        ),
      ],
    );
  }
}

class _CodeForm extends StatelessWidget {
  const _CodeForm({
    required this.controller,
    required this.codeLength,
    required this.phone,
    required this.invalid,
    required this.codeSentAt,
    required this.busy,
    required this.onResend,
    required this.onChangeNumber,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String phone;
  final bool invalid;
  final DateTime? codeSentAt;
  final bool busy;
  final VoidCallback onResend;
  final VoidCallback onChangeNumber;
  final VoidCallback onSubmitted;
  final int codeLength;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sentAt = codeSentAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.verifyOtpSentTo(phone), style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.md),
        SectionLabel(l10n.verifyOtpLabel(codeLength)),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          textInputAction: TextInputAction.done,
          maxLength: codeLength,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (_) => onSubmitted(),
          decoration: InputDecoration(counterText: '', errorText: invalid ? l10n.verifyOtpInvalid(codeLength) : null),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          children: [
            if (sentAt != null) ResendCodeButton(sentAt: sentAt, enabled: !busy, onResend: onResend),
            TextButton(onPressed: busy ? null : onChangeNumber, child: Text(l10n.verifyChangeNumber)),
          ],
        ),
      ],
    );
  }
}

class _DocumentChoice extends StatelessWidget {
  const _DocumentChoice({required this.selected, required this.onSelected});

  final IdDocumentType? selected;
  final ValueChanged<IdDocumentType> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = {
      IdDocumentType.aadhaar: l10n.idAadhaar,
      IdDocumentType.passport: l10n.idPassport,
      IdDocumentType.drivingLicence: l10n.idDrivingLicence,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(l10n.verifyChooseId),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final entry in labels.entries)
              AppChoiceChip(
                label: entry.value,
                selected: selected == entry.key,
                onSelected: () => onSelected(entry.key),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _CaptureSection extends StatelessWidget {
  const _CaptureSection({required this.frame, this.header});

  final Widget frame;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?header,
        Center(child: frame),
        const SizedBox(height: AppSpacing.xl),
        SafetyNote(text: context.l10n.verifyIdPrivacy),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.title,
    required this.body,
    this.icon = Icons.verified_user_outlined,
    this.iconColor = AppColors.accent,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSizes.iconLarge, color: iconColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(body, style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
