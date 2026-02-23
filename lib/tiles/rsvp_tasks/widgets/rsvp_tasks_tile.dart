import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/rsvp_tasks/providers/rsvp_tasks_provider.dart';

/// Tile widget that displays events requiring an RSVP response.
class RsvpTasksTile extends StatelessWidget {
  const RsvpTasksTile({
    super.key,
    required this.events,
    this.isLoading = false,
    this.error,
    this.onEventTap,
    this.onRefresh,
    this.onViewAll,
  });

  /// Events to display with their RSVP state.
  final List<EventWithRSVP> events;
  final bool isLoading;
  final String? error;
  final void Function(EventWithRSVP)? onEventTap;
  final VoidCallback? onRefresh;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('rsvp_tasks_tile'),
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
    final pendingCount = events.where((e) => e.needsResponse).length;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text('RSVP Tasks', style: context.textTheme.titleMedium),
              if (pendingCount > 0 && !isLoading) ...[
                AppSpacing.horizontalGapXS,
                Container(
                  key: const Key('pending_rsvp_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.l),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onViewAll != null)
          TextButton(
            key: const Key('rsvp_tasks_view_all'),
            onPressed: onViewAll,
            child: const Text('View all'),
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
          ShimmerListTile(),
        ],
      );
    }

    if (error != null) {
      return InlineErrorView(message: error!, onRetry: onRefresh);
    }

    if (events.isEmpty) {
      return const CompactEmptyState(
        message: 'No RSVP tasks',
        icon: Icons.check_circle_outline,
      );
    }

    final displayEvents = events.take(3).toList();
    return Column(
      children: displayEvents
          .map((item) => _RsvpTaskRow(item: item, onTap: onEventTap))
          .toList(),
    );
  }
}

class _RsvpTaskRow extends StatelessWidget {
  const _RsvpTaskRow({required this.item, this.onTap});

  final EventWithRSVP item;
  final void Function(EventWithRSVP)? onTap;

  @override
  Widget build(BuildContext context) {
    final event = item.event;
    final dateStr = DateFormat('MMM d, yyyy').format(event.startsAt);

    return InkWell(
      key: Key('rsvp_task_${event.id}'),
      onTap: onTap != null ? () => onTap!(item) : null,
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              item.needsResponse
                  ? Icons.pending_actions
                  : Icons.check_circle,
              color: item.needsResponse
                  ? AppColors.primary
                  : Colors.green,
              size: 20,
            ),
            AppSpacing.horizontalGapS,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: context.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalGapXS,
                  Text(
                    dateStr,
                    style: context.textTheme.bodySmall?.copyWith(
                      color:
                          AppColors.onSurfaceSecondary(context.colorScheme),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              key: Key('rsvp_status_${event.id}'),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: item.needsResponse
                    ? Colors.orange.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Text(
                item.needsResponse ? 'Pending' : 'Responded',
                style: context.textTheme.labelSmall?.copyWith(
                  color: item.needsResponse
                      ? Colors.orange.shade800
                      : Colors.green.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
