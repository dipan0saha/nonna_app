import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/system_announcement.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';

/// Tile widget that displays global system announcements with per-user dismissal.
class SystemAnnouncementsTile extends StatelessWidget {
  const SystemAnnouncementsTile({
    super.key,
    required this.announcements,
    this.dismissedIds = const {},
    this.isLoading = false,
    this.error,
    this.onDismiss,
    this.onRefresh,
  });

  /// All active announcements.
  final List<SystemAnnouncement> announcements;

  /// IDs of announcements the current user has dismissed.
  final Set<String> dismissedIds;
  final bool isLoading;
  final String? error;

  /// Called with the announcement ID when the user taps the dismiss button.
  final void Function(String announcementId)? onDismiss;
  final VoidCallback? onRefresh;

  /// Visible (non-dismissed) announcements.
  List<SystemAnnouncement> get _visible =>
      announcements.where((a) => !dismissedIds.contains(a.id)).toList();

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('system_announcements_tile'),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Announcements', style: context.textTheme.titleMedium),
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

    final visible = _visible;
    if (visible.isEmpty) {
      return const CompactEmptyState(
        message: 'No announcements',
        icon: Icons.campaign_outlined,
      );
    }

    return Column(
      children: visible
          .take(3)
          .map(
            (a) => _AnnouncementCard(
              announcement: a,
              onDismiss: onDismiss,
            ),
          )
          .toList(),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    this.onDismiss,
  });

  final SystemAnnouncement announcement;
  final void Function(String)? onDismiss;

  Color _priorityColor(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.critical:
        return Colors.red;
      case AnnouncementPriority.high:
        return Colors.orange;
      case AnnouncementPriority.medium:
        return AppColors.primary;
      case AnnouncementPriority.low:
        return Colors.grey;
    }
  }

  IconData _priorityIcon(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.critical:
        return Icons.error_outline;
      case AnnouncementPriority.high:
        return Icons.warning_amber_outlined;
      case AnnouncementPriority.medium:
        return Icons.info_outline;
      case AnnouncementPriority.low:
        return Icons.campaign_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(announcement.priority);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        key: Key('announcement_${announcement.id}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _priorityIcon(announcement.priority),
            size: 20,
            color: color,
          ),
          AppSpacing.horizontalGapS,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: context.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.verticalGapXS,
                Text(
                  announcement.body,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceSecondary(context.colorScheme),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              key: Key('dismiss_${announcement.id}'),
              icon: const Icon(Icons.close, size: 16),
              onPressed: () => onDismiss!(announcement.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Dismiss',
            ),
        ],
      ),
    );
  }
}
