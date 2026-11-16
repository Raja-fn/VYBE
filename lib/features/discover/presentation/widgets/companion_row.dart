import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/content_rows.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../domain/companion_summary.dart';
import 'labels.dart';

/// A companion in a list (Free right now, Saved): avatar, name, free time,
/// plans and rounded distance.
class CompanionRow extends StatelessWidget {
  const CompanionRow({
    required this.companion,
    required this.onOpen,
    this.selected = false,
    this.onViewProfile,
    super.key,
  });

  final CompanionSummary companion;
  final VoidCallback onOpen;

  /// Highlighted as the chosen companion (Free right now).
  final bool selected;

  /// When set and [selected], shows a "View profile" link.
  final VoidCallback? onViewProfile;

  String? _freeLabel(BuildContext context, AppLocalizations l10n) {
    final c = companion;
    final from = c.freeFrom;
    final until = c.freeUntil ?? c.freeNowUntil;
    if (until == null) return null;
    if (from != null && from.isAfter(DateTime.now())) {
      return l10n.freeBetween(clockTime(context, from), clockTime(context, until));
    }
    return l10n.freeUntil(clockTime(context, until));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final c = companion;
    final free = _freeLabel(context, l10n);
    final plans = c.planTypes.map((p) => planLabelFromWire(l10n, p)).whereType<String>().toList();

    final viewProfile = onViewProfile;
    return Semantics(
      button: true,
      selected: selected,
      label: [l10n.cardNameAge(c.displayName, c.ageYears), ?free, l10n.aboutKm(c.distanceKm)].join('. '),
      child: AppCard(
        tone: selected ? AppCardTone.highlighted : AppCardTone.light,
        onTap: onOpen,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InitialsAvatar(name: c.displayName),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distance sits beside the name, or below it when there is no room.
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: AppSpacing.xs,
                    children: [
                      Text(l10n.cardNameAge(c.displayName, c.ageYears), style: textTheme.titleLarge),
                      Text(l10n.aboutKm(c.distanceKm), style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
                    ],
                  ),
                  if (free != null) Text(free, style: textTheme.titleSmall?.copyWith(color: AppColors.successText)),
                  if (plans.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [for (final plan in plans) AppTag(plan)],
                    ),
                  ],
                  if (selected && viewProfile != null)
                    TextButton(onPressed: viewProfile, child: Text(l10n.freeNowViewProfile)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
