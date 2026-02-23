import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/engagement_recap/providers/engagement_recap_provider.dart';

/// Tile widget that shows an engagement recap (squishes, comments, RSVPs).
class EngagementRecapTile extends StatelessWidget {
  const EngagementRecapTile({
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
      key: const Key('engagement_recap_tile'),
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
    return Row(
      children: [
        Expanded(
          child: Text(
            'Engagement Recap',
            style: context.textTheme.titleMedium,
          ),
        ),
        if (onPeriodChanged != null)
          _PeriodSelector(
            selectedDays: selectedDays,
            options: _periodOptions,
            onChanged: onPeriodChanged!,
          ),
      ],
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
              label: Text('${d}d'),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _MetricChip(
          key: const Key('squishes_metric'),
          icon: Icons.favorite,
          label: 'Squishes',
          value: metrics.photoSquishes,
          color: Colors.pink,
        ),
        _MetricChip(
          key: const Key('comments_metric'),
          icon: Icons.chat_bubble_outline,
          label: 'Comments',
          value: metrics.photoComments,
          color: Colors.blue,
        ),
        _MetricChip(
          key: const Key('rsvps_metric'),
          icon: Icons.event_available,
          label: 'RSVPs',
          value: metrics.eventRSVPs,
          color: Colors.green,
        ),
        _MetricChip(
          key: const Key('total_metric'),
          icon: Icons.bar_chart,
          label: 'Total',
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
              'No engagement data yet',
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
