import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/due_date_countdown/providers/due_date_countdown_provider.dart';

/// Tile widget that displays due date countdowns for one or more baby profiles.
class DueDateCountdownTile extends StatelessWidget {
  const DueDateCountdownTile({
    super.key,
    required this.countdowns,
    this.isLoading = false,
    this.error,
    this.onRefresh,
  });

  final List<BabyCountdown> countdowns;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('due_date_countdown_tile'),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Due Date Countdown',
              style: context.textTheme.titleMedium,
            ),
            AppSpacing.verticalGapS,
            _buildBody(context),
          ],
        ),
      ),
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

    if (countdowns.isEmpty) {
      return const CompactEmptyState(
        message: 'No due dates to display',
        icon: Icons.child_care_outlined,
      );
    }

    return Column(
      children: countdowns
          .map((countdown) => _CountdownRow(countdown: countdown))
          .toList(),
    );
  }
}

class _CountdownRow extends StatelessWidget {
  const _CountdownRow({required this.countdown});

  final BabyCountdown countdown;

  Color _countdownColor(BabyCountdown countdown) {
    if (countdown.isPastDue) return Colors.red;
    if (countdown.daysUntilDueDate <= 7) return Colors.orange;
    if (countdown.daysUntilDueDate <= 30) return Colors.amber;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final color = _countdownColor(countdown);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        key: Key('countdown_row_${countdown.profile.id}'),
        children: [
          Icon(
            countdown.isPastDue
                ? Icons.child_friendly
                : Icons.pregnant_woman,
            color: color,
            size: 24,
          ),
          AppSpacing.horizontalGapS,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  countdown.profile.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.verticalGapXS,
                Text(
                  countdown.formattedCountdown,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceSecondary(context.colorScheme),
                  ),
                ),
              ],
            ),
          ),
          Container(
            key: Key('days_badge_${countdown.profile.id}'),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs / 2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Text(
              countdown.isPastDue
                  ? 'Born!'
                  : '${countdown.daysUntilDueDate}d',
              style: context.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
