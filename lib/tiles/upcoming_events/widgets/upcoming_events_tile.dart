import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/enums/rsvp_status.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/upcoming_events/models/event_with_rsvp.dart';

export 'package:nonna_app/tiles/upcoming_events/models/event_with_rsvp.dart';

/// Tile widget that displays upcoming events with optional RSVP status.
class UpcomingEventsTile extends StatelessWidget {
  const UpcomingEventsTile({
    super.key,
    required this.events,
    this.isLoading = false,
    this.error,
    this.onEventTap,
    this.onRefresh,
    this.onViewAll,
  });

  /// Events to display. Use [EventWithRsvp] to include the current user's RSVP
  /// status alongside each event; the RSVP indicator will be shown when present.
  final List<EventWithRsvp> events;
  final bool isLoading;
  final String? error;
  final void Function(Event)? onEventTap;
  final VoidCallback? onRefresh;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('upcoming_events_tile'),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TileHeader(
              title: 'Upcoming Events',
              onViewAll: onViewAll,
              viewAllKey: const Key('upcoming_events_view_all'),
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
          ShimmerListTile(),
        ],
      );
    }

    if (error != null) {
      return InlineErrorView(message: error!, onRetry: onRefresh);
    }

    if (events.isEmpty) {
      return const CompactEmptyState(
        message: 'No upcoming events',
        icon: Icons.event_outlined,
      );
    }

    final displayEvents = events.take(3).toList();
    return Column(
      children: displayEvents
          .map((item) => _EventCard(item: item, onTap: onEventTap))
          .toList(),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.item, this.onTap});

  final EventWithRsvp item;
  final void Function(Event)? onTap;

  @override
  Widget build(BuildContext context) {
    final event = item.event;
    final dateStr = DateFormat('MMM d, yyyy').format(event.startsAt);

    return InkWell(
      key: Key('event_card_${event.id}'),
      onTap: onTap != null ? () => onTap!(event) : null,
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 20,
            ),
            AppSpacing.horizontalGapS,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: context.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalGapXS,
                  Text(
                    dateStr,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceSecondary(context.colorScheme),
                    ),
                  ),
                  if (event.location != null) ...[
                    AppSpacing.verticalGapXS,
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.onSurfaceHint(context.colorScheme),
                        ),
                        AppSpacing.horizontalGapXS,
                        Expanded(
                          child: Text(
                            event.location!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color:
                                  AppColors.onSurfaceHint(context.colorScheme),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (item.hasRsvp) ...[
              AppSpacing.horizontalGapS,
              _RsvpBadge(
                key: Key('rsvp_badge_${event.id}'),
                status: item.rsvpStatus!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small icon chip showing the user's RSVP response.
class _RsvpBadge extends StatelessWidget {
  const _RsvpBadge({super.key, required this.status});

  final RsvpStatus status;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: status.displayName,
      child: Icon(
        status.icon,
        size: 18,
        color: status.color,
      ),
    );
  }
}

class _TileHeader extends StatelessWidget {
  const _TileHeader({
    required this.title,
    this.onViewAll,
    this.viewAllKey,
    this.trailing,
  });

  final String title;
  final VoidCallback? onViewAll;
  final Key? viewAllKey;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: context.textTheme.titleMedium),
        ),
        if (trailing != null) trailing!,
        if (onViewAll != null)
          TextButton(
            key: viewAllKey,
            onPressed: onViewAll,
            child: const Text('View all'),
          ),
      ],
    );
  }
}
