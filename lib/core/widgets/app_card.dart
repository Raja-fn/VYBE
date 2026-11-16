import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

enum AppCardTone {
  /// White card, 1px border.
  light,

  /// Ink card for one highlighted action ("Request instantly", selected venue).
  dark,

  /// White card with an accent border (highlighted plan).
  highlighted,
}

/// Standard card: radius 22 with a 1px border.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.tone = AppCardTone.light,
    this.padding = AppSpacing.cardPadding,
    this.onTap,
    super.key,
  });

  final Widget child;
  final AppCardTone tone;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (fill, border, width) = switch (tone) {
      AppCardTone.light => (AppColors.card, AppColors.border, AppSizes.borderWidth),
      AppCardTone.dark => (AppColors.violetCard, AppColors.violetCard, AppSizes.borderWidth),
      AppCardTone.highlighted => (AppColors.accentCard, AppColors.accent, AppSizes.borderWidth),
    };
    final content = Padding(padding: padding, child: child);
    final textColor = tone == AppCardTone.dark ? AppColors.onInk : AppColors.ink;

    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.cardBorder,
        side: BorderSide(color: border, width: width),
      ),
      clipBehavior: Clip.antiAlias,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: textColor),
        child: IconTheme.merge(
          data: IconThemeData(color: textColor),
          child: onTap == null ? content : InkWell(onTap: onTap, child: content),
        ),
      ),
    );
  }
}
