import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Large photo card: radius 28 with a soft shadow.
class PhotoCard extends StatelessWidget {
  const PhotoCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: AppRadii.photoCardBorder,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSizes.shadowBlur,
            offset: Offset(0, AppSizes.shadowOffsetY),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.photoCardBorder,
        child: ColoredBox(color: AppColors.card, child: child),
      ),
    );
  }
}

/// Shown when a profile has no photo yet, or while it loads:
/// soft blobs with the person's initial.
class PhotoPlaceholderArt extends StatelessWidget {
  const PhotoPlaceholderArt({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = initialOf(name);
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final big = size.shortestSide * AppRatios.placeholderBlob;
          return ColoredBox(
            color: AppColors.photoBase,
            child: Stack(
              children: [
                Positioned(
                  left: -big * AppRatios.placeholderBlobOffsetX,
                  top: -big * AppRatios.placeholderBlobOffsetY,
                  child: _Blob(diameter: big, color: AppColors.photoBlobDeep),
                ),
                Positioned(
                  right: -big * AppRatios.placeholderBlobOffsetX,
                  bottom: -big * AppRatios.placeholderBlobOffsetY,
                  child: _Blob(diameter: big * AppRatios.placeholderBlobSecondary, color: AppColors.photoBlobLight),
                ),
                Center(
                  child: Text(
                    initial,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: size.shortestSide * AppRatios.placeholderInitial,
                      color: AppColors.photoInitial,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: diameter,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

/// First letter of a display name, upper-cased.
String initialOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '';
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}
