import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/location/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_pill_button.dart';
import '../../../core/widgets/content_rows.dart';
import '../data/safety_services.dart';
import 'safety_providers.dart';

/// SOS, a trusted contact who can be sent your location, and safety tips.
class SafetyHubScreen extends ConsumerWidget {
  const SafetyHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          children: [
            Row(
              children: [
                AppBackButton(onPressed: () => context.pop()),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Semantics(header: true, child: Text(l10n.safetyTitle, style: textTheme.headlineMedium)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.safetySubtitle, style: textTheme.bodyLarge?.copyWith(color: AppColors.muted)),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: SosButton(
                number: config.emergencyNumber,
                hold: Duration(seconds: config.sosHoldSeconds),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.safetySosHint(config.sosHoldSeconds, config.emergencyNumber),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _TrustedContactCard(),
            const SizedBox(height: AppSpacing.md),
            const _TipsCard(),
          ],
        ),
      ),
    );
  }
}

/// Press and hold for [hold] to call [number]. A quick tap does nothing, so
/// it is hard to set off by accident.
class SosButton extends ConsumerStatefulWidget {
  const SosButton({required this.number, required this.hold, super.key});

  final String number;
  final Duration hold;

  @override
  ConsumerState<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends ConsumerState<SosButton> with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(vsync: this, duration: widget.hold)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _progress.value = 0;
        _call();
      }
    });

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Future<void> _call() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final opened = await ref.read(safetyLauncherProvider).call(widget.number);
    if (!opened) messenger.showSnackBar(SnackBar(content: Text(l10n.safetyCallFailed(widget.number))));
  }

  /// Screen readers cannot hold, so a double tap asks first instead.
  Future<void> _confirmCall() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.safetySosConfirmTitle(widget.number)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerText),
            child: Text(l10n.safetySosCall),
          ),
        ],
      ),
    );
    if (confirmed == true) await _call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const size = 160.0;
    return Semantics(
      button: true,
      label: l10n.safetySosSemantics(widget.number),
      onTap: _confirmCall,
      excludeSemantics: true,
      child: Listener(
        onPointerDown: (_) => _progress.forward(from: 0),
        onPointerUp: (_) => _progress.reverse(),
        onPointerCancel: (_) => _progress.reverse(),
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.danger.withValues(alpha: 0.15)),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: DecoratedBox(
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.danger),
                  child: Center(
                    child: Text(
                      l10n.safetySos,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.onAccent),
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _progress,
                builder: (context, _) => CircularProgressIndicator(
                  value: _progress.value,
                  strokeWidth: 6,
                  color: AppColors.danger,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustedContactCard extends ConsumerWidget {
  const _TrustedContactCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final contact = ref.watch(myTrustedContactProvider);
    final current = contact.value;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: SectionLabel(l10n.safetyContactTitle)),
              if (!contact.isLoading)
                AppPillButton(
                  label: current == null ? l10n.safetyContactAdd : l10n.safetyContactEdit,
                  tone: AppPillTone.soft,
                  onPressed: () => showTrustedContactSheet(context, current),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (contact.isLoading)
            const LinearProgressIndicator()
          else if (current == null)
            Text(l10n.safetyContactEmpty, style: textTheme.bodyMedium?.copyWith(color: AppColors.muted))
          else
            Text('${current.name} · ${current.phoneE164}', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.safetySendLocation,
            variant: AppButtonVariant.outline,
            onPressed: contact.isLoading ? null : () => sendMyLocation(context, ref, current),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            current == null ? l10n.safetySendLocationAnyone : l10n.safetySendLocationTo(current.name),
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/// Gets the current position and sends a map link to [contact] by text
/// message, or through the share sheet when there is no contact.
Future<void> sendMyLocation(BuildContext context, WidgetRef ref, TrustedContact? contact) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final position = await ref.read(locationServiceProvider).current();
  final failure = position.failureOrNull;
  if (failure != null) {
    messenger.showSnackBar(SnackBar(content: Text(failureMessage(l10n, failure))));
    return;
  }
  final here = position.valueOrThrow;
  final body = l10n.safetyLocationMessage(mapLink(here.lat, here.lng));
  final launcher = ref.read(safetyLauncherProvider);
  final opened = contact == null ? await launcher.share(body) : await launcher.text(contact.phoneE164, body);
  if (!opened) messenger.showSnackBar(SnackBar(content: Text(l10n.safetyShareFailed)));
}

/// Add, change or remove the trusted contact.
Future<void> showTrustedContactSheet(BuildContext context, TrustedContact? current) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _TrustedContactForm(current: current),
);

class _TrustedContactForm extends ConsumerStatefulWidget {
  const _TrustedContactForm({required this.current});

  final TrustedContact? current;

  @override
  ConsumerState<_TrustedContactForm> createState() => _TrustedContactFormState();
}

class _TrustedContactFormState extends ConsumerState<_TrustedContactForm> {
  late final _name = TextEditingController(text: widget.current?.name);
  late final _phone = TextEditingController(text: widget.current?.phoneE164);
  bool _saving = false;
  String? _nameError;
  String? _phoneError;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save(TrustedContact? contact) async {
    final l10n = context.l10n;
    setState(() => _saving = true);
    final failure = await ref.read(myTrustedContactProvider.notifier).save(contact);
    if (!mounted) return;
    setState(() => _saving = false);
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failureMessage(l10n, failure))));
      return;
    }
    Navigator.of(context).pop();
  }

  void _submit() {
    final l10n = context.l10n;
    final config = ref.read(appConfigProvider);
    final name = _name.text.trim();
    final phone = trustedPhoneE164(
      _phone.text,
      countryCode: config.phoneCountryCode,
      nationalLength: config.phoneNationalNumberLength,
    );
    setState(() {
      _nameError = name.isEmpty || name.length > 60 ? l10n.safetyContactNameInvalid : null;
      _phoneError = phone == null ? l10n.safetyContactPhoneInvalid : null;
    });
    if (_nameError != null || phone == null) return;
    _save(TrustedContact(name: name, phoneE164: phone));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        0,
        AppSpacing.screenGutter,
        AppSpacing.screenGutter + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.safetyContactTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _name,
            enabled: !_saving,
            textCapitalization: TextCapitalization.words,
            maxLength: 60,
            decoration: InputDecoration(labelText: l10n.safetyContactName, errorText: _nameError, counterText: ''),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _phone,
            enabled: !_saving,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            decoration: InputDecoration(labelText: l10n.safetyContactPhone, errorText: _phoneError),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: l10n.safetyContactSave, isLoading: _saving, onPressed: _saving ? null : _submit),
          if (widget.current != null)
            TextButton(
              onPressed: _saving ? null : () => _save(null),
              style: TextButton.styleFrom(foregroundColor: AppColors.dangerText),
              child: Text(l10n.safetyContactRemove),
            ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final tips = [
      l10n.safetyTipPublic,
      l10n.safetyTipTell,
      l10n.safetyTipTravel,
      l10n.safetyTipMoney,
      l10n.safetyTipLeave,
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(l10n.safetyTipsTitle),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: AppSizes.iconSmall, color: AppColors.successText),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(tip, style: textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
