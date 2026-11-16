import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'photo_card.dart';

/// Rounded-square avatar showing a person's initial.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    required this.name,
    this.size = AppSizes.avatar,
    this.radius = AppRadii.avatarLarge,
    super.key,
  });

  final String name;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.avatarFill,
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
          child: Center(
            child: Text(
              initialOf(name),
              textScaler: TextScaler.noScaling,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: size * AppRatios.avatarInitial,
                color: AppColors.avatarInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
