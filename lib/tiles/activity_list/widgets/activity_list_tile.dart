import 'package:flutter/material.dart';
import 'package:nonna_app/flutter_gen/gen_l10n/app_localizations.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/activity_list/providers/activity_list_provider.dart';
import 'package:nonna_app/tiles/core/tile_icons.dart';
import 'package:nonna_app/tiles/core/widgets/tile_header.dart';

/// Tile widget that shows an engagement recap (squishes, comments, RSVPs).
class ActivityListTile extends StatelessWidget {
  const ActivityListTile({
    super.key,
    this.metrics,
    this.isLoading = false,
    this.error,
    this.onRefresh,
    this.onPeriodChanged,
    this.selectedDays = 30,
  });

  final EngagementMetrics? metrics;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;

  /// Callback invoked when the user selects a different time period.
  final void Function(int days)? onPeriodChanged;

  /// Currently selected look-back period in days (7, 30, or 90).
  final int selectedDays;

  static const List<int> _periodOptions = [7, 30, 90];

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('activity_list_tile'),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            AppSpacing.verticalGapS,
            _buildBody(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final actions = <Widget>[];
    if (onPeriodChanged != null) {
      actions.add(
        _PeriodSelector(
          selectedDays: selectedDays,
          options: _periodOptions,
          onChanged: onPeriodChanged!,
        ),
      );
    }

    return TileHeader(
      icon: TileIcons.activityList,
      title: AppLocalizations.of(context).tile_activity_title,
      actions: actions,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Column(
        children: [
          ShimmerListTile(),
          ShimmerListTile(),
        ],
      );
    }

    if (error != null) {
      return InlineErrorView(message: error!, onRetry: onRefresh);
    }

    if (metrics == null) {
      return const _EmptyEngagement();
    }

    return _MetricsSummary(metrics: metrics!);
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selectedDays,
    required this.options,
    required this.onChanged,
  });

  final int selectedDays;
  final List<int> options;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      key: const Key('period_selector'),
      segments: options
          .map(
            (d) => ButtonSegment<int>(
              value: d,
              label: Text(AppLocalizations.of(context).tile_activity_period(d)),
            ),
          )
          .toList(),
      selected: {selectedDays},
      onSelectionChanged: (selection) => onChanged(selection.first),
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _MetricsSummary extends StatelessWidget {
  const _MetricsSummary({required this.metrics});

  final EngagementMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _MetricChip(
          key: const Key('squishes_metric'),
          icon: Icons.favorite,
          label: l10n.tile_activity_squishes,
          value: metrics.photoSquishes,
          color: Colors.pink,
        ),
        _MetricChip(
          key: const Key('comments_metric'),
          icon: Icons.chat_bubble_outline,
          label: l10n.tile_activity_comments,
          value: metrics.photoComments,
          color: Colors.blue,
        ),
        _MetricChip(
          key: const Key('rsvps_metric'),
          icon: Icons.event_available,
          label: l10n.tile_activity_rsvps,
          value: metrics.eventRSVPs,
          color: Colors.green,
        ),
        _MetricChip(
          key: const Key('total_metric'),
          icon: Icons.bar_chart,
          label: l10n.tile_activity_total,
          value: metrics.totalEngagement,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        AppSpacing.verticalGapXS,
        Text(
          '$value',
          style: context.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceSecondary(context.colorScheme),
          ),
        ),
      ],
    );
  }
}

class _EmptyEngagement extends StatelessWidget {
  const _EmptyEngagement();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 32,
              color: AppColors.onSurfaceHint(context.colorScheme),
            ),
            AppSpacing.verticalGapXS,
            Text(
              AppLocalizations.of(context).tile_activity_empty,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceHint(context.colorScheme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
