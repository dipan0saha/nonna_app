import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/core/themes/colors.dart';

/// Shared tile header that keeps icon and title alignment consistent.
class TileHeader extends StatelessWidget {
  const TileHeader({
    super.key,
    required this.icon,
    required this.title,
    this.titleSuffix,
    this.actions = const [],
    this.bottom,
    this.iconColor,
    this.iconSize = 20,
    this.titleStyle,
  });

  final IconData icon;
  final String title;
  final Widget? titleSuffix;
  final List<Widget> actions;
  final Widget? bottom;
  final Color? iconColor;
  final double iconSize;
  final TextStyle? titleStyle;

  List<Widget> _withSpacing(List<Widget> items) {
    if (items.length <= 1) return items;
    final spaced = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      spaced.add(items[i]);
      if (i < items.length - 1) {
        spaced.add(AppSpacing.horizontalGapXS);
      }
    }
    return spaced;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTitleStyle = titleStyle ?? context.textTheme.titleMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.primary,
            ),
            AppSpacing.horizontalGapS,
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: resolvedTitleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (titleSuffix != null) ...[
                    AppSpacing.horizontalGapXS,
                    titleSuffix!,
                  ],
                ],
              ),
            ),
            if (actions.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: _withSpacing(actions),
              ),
          ],
        ),
        if (bottom != null) ...[
          AppSpacing.verticalGapXS,
          bottom!,
        ],
      ],
    );
  }
}
