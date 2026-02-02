import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';

/// A shimmer loading placeholder with customizable shapes and sizes.
///
/// Provides skeleton loading screens with shimmer animation for
/// better user experience during data loading.
class ShimmerPlaceholder extends StatelessWidget {
  /// Creates a shimmer placeholder.
  ///
  /// The [width] and [height] define the size of the placeholder.
  /// The [shape] determines whether it's rectangular or circular.
  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
  });

  /// Width of the placeholder
  final double width;

  /// Height of the placeholder
  final double height;

  /// Shape of the placeholder (rectangle or circle)
  final BoxShape shape;

  /// Border radius for rectangular placeholders
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? (borderRadius ?? BorderRadius.circular(AppSpacing.xs / 2))
              : null,
        ),
      ),
    );
  }
}

/// A shimmer placeholder for list tiles.
class ShimmerListTile extends StatelessWidget {
  /// Creates a shimmer list tile placeholder.
  const ShimmerListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.hasSubtitle = true,
    this.padding,
  });

  /// Whether to show a leading placeholder
  final bool hasLeading;

  /// Whether to show a trailing placeholder
  final bool hasTrailing;

  /// Whether to show a subtitle placeholder
  final bool hasSubtitle;

  /// Optional padding
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          AppSpacing.horizontalPadding.add(AppSpacing.verticalPadding / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLeading) ...[
            const ShimmerPlaceholder(
              width: 48,
              height: 48,
              shape: BoxShape.circle,
            ),
            AppSpacing.horizontalGapM,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerPlaceholder(
                  width: double.infinity,
                  height: 16,
                  borderRadius:
                      BorderRadius.all(Radius.circular(AppSpacing.xs / 2)),
                ),
                if (hasSubtitle) ...[
                  AppSpacing.verticalGapXS,
                  ShimmerPlaceholder(
                    width: context.screenWidth * 0.6,
                    height: 14,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(AppSpacing.xs / 2)),
                  ),
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            AppSpacing.horizontalGapM,
            const ShimmerPlaceholder(
              width: 24,
              height: 24,
            ),
          ],
        ],
      ),
    );
  }
}

/// A shimmer placeholder for cards.
class ShimmerCard extends StatelessWidget {
  /// Creates a shimmer card placeholder.
  const ShimmerCard({
    super.key,
    this.width,
    this.height = 200,
    this.hasImage = true,
    this.hasTitle = true,
    this.hasSubtitle = true,
    this.margin,
  });

  /// Width of the card. Defaults to full width if null
  final double? width;

  /// Height of the card
  final double height;

  /// Whether to show an image placeholder
  final bool hasImage;

  /// Whether to show a title placeholder
  final bool hasTitle;

  /// Whether to show a subtitle placeholder
  final bool hasSubtitle;

  /// Optional margin
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            Expanded(
              child: ShimmerPlaceholder(
                width: width ?? double.infinity,
                height: double.infinity,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.xs),
                ),
              ),
            ),
          Padding(
            padding: AppSpacing.compactPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTitle)
                  ShimmerPlaceholder(
                    width: width != null ? width! * 0.7 : 200,
                    height: 16,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(AppSpacing.xs / 2)),
                  ),
                if (hasSubtitle) ...[
                  AppSpacing.verticalGapXS,
                  ShimmerPlaceholder(
                    width: width != null ? width! * 0.5 : 150,
                    height: 14,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(AppSpacing.xs / 2)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A shimmer placeholder for text lines.
class ShimmerText extends StatelessWidget {
  /// Creates a shimmer text placeholder.
  const ShimmerText({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.lines = 1,
    this.spacing = 8,
  });

  /// Width of each line
  final double width;

  /// Height of each line
  final double height;

  /// Number of lines to display
  final int lines;

  /// Spacing between lines
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        lines,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
          child: ShimmerPlaceholder(
            width: index == lines - 1 ? width * 0.7 : width,
            height: height,
            borderRadius:
                const BorderRadius.all(Radius.circular(AppSpacing.xs / 2)),
          ),
        ),
      ),
    );
  }
}
