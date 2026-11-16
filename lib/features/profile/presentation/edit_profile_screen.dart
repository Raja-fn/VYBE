import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/services/image_capture/photo_picker_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_choice_chip.dart';
import '../../../core/widgets/dashed_border.dart';
import '../../../core/widgets/storage_photo.dart';
import '../../onboarding/domain/account.dart';
import '../../onboarding/domain/session_stage.dart';
import '../../onboarding/presentation/session_providers.dart';
import '../../preferences/domain/preferences.dart';
import '../../preferences/presentation/preferences_providers.dart';
import '../domain/profile_details.dart';
import 'edit_profile_controller.dart';
import 'profile_option_labels.dart';

/// "Edit profile": photos (main first), basics, about me, work, story,
/// personality, lifestyle and interests. Every row opens a small picker and
/// saves straight away.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final stage = ref.watch(sessionStageProvider).value;
    final account = switch (stage) {
      Ready(:final account) || NeedsPreferences(:final account) || NeedsVerification(:final account) => account,
      _ => null,
    };
    final details = ref.watch(myProfileDetailsProvider).value ?? ProfileDetails.empty;
    final prefs = account == null ? null : ref.watch(preferencesProvider(account.uid)).value;
    final state = ref.watch(editProfileControllerProvider);
    final controller = ref.read(editProfileControllerProvider.notifier);
    final failure = state.failure;

    ref.listen(editProfileControllerProvider.select((s) => s.failure), (_, next) {
      if (next == null) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failureMessage(l10n, next))));
      controller.clearFailure();
    });

    void save(ProfileDetails next) => controller.saveDetails(next);

    return Scaffold(
      body: SafeArea(
        child: account == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenGutter,
                  AppSpacing.md,
                  AppSpacing.screenGutter,
                  AppSpacing.xxl,
                ),
                children: [
                  Row(
                    children: [
                      AppBackButton(onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.profile)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Semantics(header: true, child: Text(l10n.editProfile, style: textTheme.headlineLarge)),
                      ),
                      if (state.saving)
                        const SizedBox.square(
                          dimension: AppSizes.iconSmall,
                          child: CircularProgressIndicator(strokeWidth: AppSizes.progressStroke),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PhotoGrid(account: account, uploading: state.uploading),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.editProfilePhotosHint(ref.watch(appConfigProvider).maxProfilePhotos),
                    style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  if (failure != null) const SizedBox.shrink(),
                  _Section(
                    title: l10n.editProfileBasics,
                    rows: [
                      _Row(
                        icon: Icons.badge_outlined,
                        label: l10n.editProfileName,
                        value: account.displayName,
                        onTap: () async {
                          final name = await _askText(
                            context,
                            title: l10n.editProfileName,
                            initial: account.displayName,
                            maxLength: ref.read(appConfigProvider).displayNameMaxLength,
                          );
                          if (name != null) await controller.saveName(name);
                        },
                      ),
                      _Row(
                        icon: Icons.cake_outlined,
                        label: l10n.editProfileAge,
                        value: account.ageYears?.toString(),
                        hint: l10n.editProfileAgeFromId,
                      ),
                      _Row(
                        icon: Icons.person_outline,
                        label: l10n.editProfileGender,
                        value: prefs == null ? null : _genderLabel(context, prefs.gender),
                      ),
                    ],
                  ),
                  _Section(
                    title: l10n.editProfileAboutMe,
                    rows: [
                      _Row(
                        icon: Icons.place_outlined,
                        label: l10n.editProfileCity,
                        value: details.city,
                        onTap: () async {
                          final city = await _askText(
                            context,
                            title: l10n.editProfileCity,
                            initial: details.city,
                            maxLength: ProfileOptions.cityMaxLength,
                          );
                          if (city != null) save(details.copyWith(city: city));
                        },
                      ),
                      _Row(
                        icon: Icons.translate,
                        label: l10n.editProfileLanguages,
                        value: _summary(context, details.languages, ProfileOptionLabels.language),
                        onTap: () async {
                          final picked = await _askMany(
                            context,
                            title: l10n.editProfileLanguages,
                            options: ProfileOptions.languages,
                            labelOf: (v) => ProfileOptionLabels.language(l10n, v),
                            selected: details.languages,
                            max: ProfileOptions.maxLanguages,
                          );
                          if (picked != null) save(details.copyWith(languages: picked));
                        },
                      ),
                    ],
                  ),
                  _Section(
                    title: l10n.editProfileWork,
                    rows: [
                      _Row(
                        icon: Icons.school_outlined,
                        label: l10n.editProfileEducation,
                        value: details.education == null
                            ? null
                            : ProfileOptionLabels.education(l10n, details.education!),
                        onTap: () async {
                          final picked = await _askOne(
                            context,
                            title: l10n.editProfileEducation,
                            options: ProfileOptions.education,
                            labelOf: (v) => ProfileOptionLabels.education(l10n, v),
                            selected: details.education,
                          );
                          if (picked != null) save(details.copyWith(education: picked.value));
                        },
                      ),
                      _Row(
                        icon: Icons.work_outline,
                        label: l10n.editProfileProfession,
                        value: details.profession,
                        onTap: () async {
                          final text = await _askText(
                            context,
                            title: l10n.editProfileProfession,
                            initial: details.profession,
                            maxLength: ProfileOptions.professionMaxLength,
                          );
                          if (text != null) save(details.copyWith(profession: text));
                        },
                      ),
                    ],
                  ),
                  _Section(
                    title: l10n.editProfileStory,
                    rows: [
                      _Row(
                        icon: Icons.notes,
                        label: details.about?.trim().isNotEmpty ?? false ? details.about! : l10n.editProfileBioHint,
                        multiline: true,
                        muted: details.about?.trim().isEmpty ?? true,
                        onTap: () async {
                          final text = await _askText(
                            context,
                            title: l10n.editProfileStory,
                            initial: details.about,
                            hint: l10n.editProfileBioHint,
                            maxLength: ProfileOptions.aboutMaxLength,
                            lines: 5,
                          );
                          if (text != null) save(details.copyWith(about: text));
                        },
                      ),
                    ],
                  ),
                  _Section(
                    title: l10n.editProfilePersonality,
                    rows: [
                      _Row(
                        icon: Icons.celebration_outlined,
                        label: l10n.editProfileHowIAm,
                        value: _summary(context, details.personality, ProfileOptionLabels.personality),
                        onTap: () async {
                          final picked = await _askMany(
                            context,
                            title: l10n.editProfileHowIAm,
                            options: ProfileOptions.personality,
                            labelOf: (v) => ProfileOptionLabels.personality(l10n, v),
                            selected: details.personality,
                            max: ProfileOptions.maxPersonality,
                          );
                          if (picked != null) save(details.copyWith(personality: picked));
                        },
                      ),
                      _Row(
                        icon: Icons.groups_outlined,
                        label: l10n.editProfileSocialEnergy,
                        value: details.socialEnergy == null
                            ? null
                            : ProfileOptionLabels.socialEnergy(l10n, details.socialEnergy!),
                        onTap: () async {
                          final picked = await _askOne(
                            context,
                            title: l10n.editProfileSocialEnergy,
                            options: ProfileOptions.socialEnergy,
                            labelOf: (v) => ProfileOptionLabels.socialEnergy(l10n, v),
                            selected: details.socialEnergy,
                          );
                          if (picked != null) save(details.copyWith(socialEnergy: picked.value));
                        },
                      ),
                    ],
                  ),
                  _Section(
                    title: l10n.editProfileLifestyle,
                    rows: [
                      for (final (icon, label, value, apply) in [
                        (
                          Icons.local_bar_outlined,
                          l10n.editProfileDrinking,
                          details.drinking,
                          (String? v) => details.copyWith(drinking: v),
                        ),
                        (
                          Icons.smoke_free_outlined,
                          l10n.editProfileSmoking,
                          details.smoking,
                          (String? v) => details.copyWith(smoking: v),
                        ),
                      ])
                        _Row(
                          icon: icon,
                          label: label,
                          value: value == null ? null : ProfileOptionLabels.habit(l10n, value),
                          onTap: () async {
                            final picked = await _askOne(
                              context,
                              title: label,
                              options: ProfileOptions.habit,
                              labelOf: (v) => ProfileOptionLabels.habit(l10n, v),
                              selected: value,
                            );
                            if (picked != null) save(apply(picked.value));
                          },
                        ),
                      _Row(
                        icon: Icons.fitness_center_outlined,
                        label: l10n.editProfileFitness,
                        value: details.fitness == null ? null : ProfileOptionLabels.fitness(l10n, details.fitness!),
                        onTap: () async {
                          final picked = await _askOne(
                            context,
                            title: l10n.editProfileFitness,
                            options: ProfileOptions.fitness,
                            labelOf: (v) => ProfileOptionLabels.fitness(l10n, v),
                            selected: details.fitness,
                          );
                          if (picked != null) save(details.copyWith(fitness: picked.value));
                        },
                      ),
                    ],
                  ),
                  _Section(
                    title: l10n.editProfileThingsILove,
                    rows: [
                      _Row(
                        icon: Icons.favorite_border,
                        label: details.interests.isEmpty
                            ? l10n.editProfilePickUpTo(ProfileOptions.maxInterests)
                            : [for (final v in details.interests) ProfileOptionLabels.interest(l10n, v)].join(', '),
                        muted: details.interests.isEmpty,
                        multiline: true,
                        onTap: () async {
                          final picked = await _askMany(
                            context,
                            title: l10n.editProfileThingsILove,
                            options: ProfileOptions.interests,
                            labelOf: (v) => ProfileOptionLabels.interest(l10n, v),
                            selected: details.interests,
                            max: ProfileOptions.maxInterests,
                          );
                          if (picked != null) save(details.copyWith(interests: picked));
                        },
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

String _genderLabel(BuildContext context, Gender gender) {
  final l10n = context.l10n;
  return switch (gender) {
    Gender.woman => l10n.genderWoman,
    Gender.man => l10n.genderMan,
    Gender.nonBinary => l10n.genderNonBinary,
    Gender.undisclosed => l10n.genderUndisclosed,
  };
}

/// "Music + 5 more", or the single choice, or null when nothing is picked.
String? _summary(
  BuildContext context,
  List<String> values,
  String Function(AppLocalizations l10n, String value) labelOf,
) {
  if (values.isEmpty) return null;
  final l10n = context.l10n;
  final first = labelOf(l10n, values.first);
  return values.length == 1 ? first : l10n.editProfileSelectedMore(first, values.length - 1);
}

// ---------------------------------------------------------------------------
// Photos
// ---------------------------------------------------------------------------

/// Main photo large on the left, five more around it; empty slots add a photo.
class _PhotoGrid extends ConsumerWidget {
  const _PhotoGrid({required this.account, required this.uploading});

  final Account account;
  final bool uploading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final max = ref.watch(appConfigProvider).maxProfilePhotos;
    final photos = account.photoPaths;
    final name = account.displayName ?? '';
    return LayoutBuilder(
      builder: (context, box) {
        const gap = AppSpacing.xs;
        final cell = (box.maxWidth - 2 * gap) / 3;
        final cellHeight = cell * 4 / 3;
        Rect slot(int i) => switch (i) {
          0 => Rect.fromLTWH(0, 0, 2 * cell + gap, 2 * cellHeight + gap),
          1 => Rect.fromLTWH(2 * (cell + gap), 0, cell, cellHeight),
          2 => Rect.fromLTWH(2 * (cell + gap), cellHeight + gap, cell, cellHeight),
          _ => Rect.fromLTWH((i - 3) * (cell + gap), 2 * (cellHeight + gap), cell, cellHeight),
        };
        return SizedBox(
          height: 3 * cellHeight + 2 * gap,
          child: Stack(
            children: [
              for (var i = 0; i < max && i < 6; i++)
                Positioned.fromRect(
                  rect: slot(i),
                  child: i < photos.length
                      ? _PhotoTile(path: photos[i], name: name, main: i == 0)
                      : _AddTile(enabled: i == photos.length && !uploading, busy: uploading && i == photos.length),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PhotoTile extends ConsumerWidget {
  const _PhotoTile({required this.path, required this.name, required this.main});

  final String path;
  final String name;
  final bool main;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(editProfileControllerProvider.notifier);
    return Semantics(
      button: true,
      image: true,
      label: main ? l10n.editProfileMainPhoto : l10n.editProfilePhotos,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: AppRadii.cardBorder,
        child: Stack(
          fit: StackFit.expand,
          children: [
            StoragePhoto(paths: [path], name: name),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (sheet) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!main)
                          ListTile(
                            leading: const Icon(Icons.star_outline),
                            title: Text(l10n.editProfileMakeMain),
                            onTap: () {
                              Navigator.of(sheet).pop();
                              controller.makeMain(path);
                            },
                          ),
                        ListTile(
                          leading: const Icon(Icons.delete_outline, color: AppColors.dangerText),
                          title: Text(l10n.editProfileRemovePhoto, style: const TextStyle(color: AppColors.dangerText)),
                          onTap: () {
                            Navigator.of(sheet).pop();
                            controller.removePhoto(path);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (main)
              Positioned(
                left: AppSpacing.xs,
                top: AppSpacing.xs,
                child: DecoratedBox(
                  decoration: const ShapeDecoration(color: AppColors.photoOverlay, shape: StadiumBorder()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                    child: Text(l10n.editProfileMainPhoto, style: Theme.of(context).textTheme.labelSmall),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends ConsumerWidget {
  const _AddTile({required this.enabled, required this.busy});

  /// Only the next free slot takes a photo, so the order stays tidy.
  final bool enabled;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(editProfileControllerProvider.notifier);
    return Semantics(
      button: true,
      enabled: enabled,
      label: busy ? l10n.editProfileUploading : l10n.editProfileAddPhoto,
      excludeSemantics: true,
      child: DashedBorder(
        borderRadius: AppRadii.cardBorder,
        color: enabled || busy ? AppColors.accent : AppColors.border,
        child: Material(
          color: AppColors.card,
          borderRadius: AppRadii.cardBorder,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: !enabled
                ? null
                : () async {
                    final source = await showModalBottomSheet<PhotoSource>(
                      context: context,
                      builder: (sheet) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library_outlined),
                              title: Text(l10n.editProfileFromGallery),
                              onTap: () => Navigator.of(sheet).pop(PhotoSource.gallery),
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_camera_outlined),
                              title: Text(l10n.editProfileTakePhoto),
                              onTap: () => Navigator.of(sheet).pop(PhotoSource.camera),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (source != null) await controller.addPhoto(source);
                  },
            child: Center(
              child: busy
                  ? const SizedBox.square(
                      dimension: AppSizes.icon,
                      child: CircularProgressIndicator(strokeWidth: AppSizes.progressStroke),
                    )
                  : Icon(Icons.add, color: enabled ? AppColors.accent : AppColors.track, size: AppSizes.iconLarge),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sections and rows
// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.headlineSmall)),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                  rows[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    this.value,
    this.hint,
    this.onTap,
    this.multiline = false,
    this.muted = false,
  });

  final IconData icon;
  final String label;

  /// Shown on the right; "Add" when the row can be edited but is empty.
  final String? value;

  /// Small grey line under the label (for example "From your ID check").
  final String? hint;
  final VoidCallback? onTap;
  final bool multiline;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Multi-line rows (bio, interests) show their content as the label instead.
    final shown = multiline ? null : value ?? (onTap == null ? null : context.l10n.editProfileNotSet);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget + AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Icon(icon, size: AppSizes.icon, color: AppColors.muted),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: multiline ? 6 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(color: muted ? AppColors.muted : null),
                    ),
                    if (hint != null) Text(hint!, style: textTheme.bodySmall?.copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
              if (shown != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: Text(
                    shown,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: textTheme.bodyMedium?.copyWith(color: value == null ? AppColors.accentText : AppColors.ink),
                  ),
                ),
              ],
              if (onTap != null) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.chevron_right, size: AppSizes.icon, color: AppColors.muted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pickers
// ---------------------------------------------------------------------------

/// A one-of-many choice; `(value: null)` clears it, null means "closed without choosing".
Future<({String? value})?> _askOne(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String Function(String) labelOf,
  required String? selected,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<({String? value})>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, 0, AppSpacing.screenGutter, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(sheet).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final option in options)
                  AppChoiceChip(
                    label: labelOf(option),
                    selected: option == selected,
                    onSelected: () => Navigator.of(sheet).pop((value: option)),
                  ),
              ],
            ),
            if (selected != null) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton(onPressed: () => Navigator.of(sheet).pop((value: null)), child: Text(l10n.editProfileClear)),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Several choices, up to [max]. Null means "closed without saving".
Future<List<String>?> _askMany(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String Function(String) labelOf,
  required List<String> selected,
  required int max,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) => _ManySheet(title: title, options: options, labelOf: labelOf, initial: selected, max: max),
  );
}

class _ManySheet extends StatefulWidget {
  const _ManySheet({
    required this.title,
    required this.options,
    required this.labelOf,
    required this.initial,
    required this.max,
  });

  final String title;
  final List<String> options;
  final String Function(String) labelOf;
  final List<String> initial;
  final int max;

  @override
  State<_ManySheet> createState() => _ManySheetState();
}

class _ManySheetState extends State<_ManySheet> {
  late final List<String> _picked = [...widget.initial];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final full = _picked.length >= widget.max;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, 0, AppSpacing.screenGutter, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: textTheme.headlineSmall),
            Text(l10n.editProfilePickUpTo(widget.max), style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final option in widget.options)
                      AppChoiceChip(
                        label: widget.labelOf(option),
                        selected: _picked.contains(option),
                        enabled: _picked.contains(option) || !full,
                        onSelected: () => setState(() {
                          if (!_picked.remove(option)) _picked.add(option);
                        }),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: l10n.editProfileSave, onPressed: () => Navigator.of(context).pop(_picked)),
          ],
        ),
      ),
    );
  }
}

/// Free text. Null means "closed without saving"; an empty string clears it.
Future<String?> _askText(
  BuildContext context, {
  required String title,
  required String? initial,
  required int maxLength,
  String? hint,
  int lines = 1,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) => _TextSheet(title: title, initial: initial, maxLength: maxLength, hint: hint, lines: lines),
  );
}

class _TextSheet extends StatefulWidget {
  const _TextSheet({
    required this.title,
    required this.initial,
    required this.maxLength,
    required this.hint,
    required this.lines,
  });

  final String title;
  final String? initial;
  final int maxLength;
  final String? hint;
  final int lines;

  @override
  State<_TextSheet> createState() => _TextSheetState();
}

class _TextSheetState extends State<_TextSheet> {
  late final _text = TextEditingController(text: widget.initial ?? '');

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenGutter, 0, AppSpacing.screenGutter, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _text,
                autofocus: true,
                maxLength: widget.maxLength,
                minLines: widget.lines,
                maxLines: widget.lines,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  border: widget.lines > 1 ? const OutlineInputBorder(borderRadius: AppRadii.cardBorder) : null,
                ),
                onSubmitted: widget.lines == 1 ? (value) => Navigator.of(context).pop(value) : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(label: l10n.editProfileSave, onPressed: () => Navigator.of(context).pop(_text.text)),
            ],
          ),
        ),
      ),
    );
  }
}
