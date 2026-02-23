import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/notification.dart' as app_notification;
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';

/// Tile widget that displays recent notifications with read/unread state.
class NotificationsTile extends StatelessWidget {
  const NotificationsTile({
    super.key,
    required this.notifications,
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
    this.onNotificationTap,
    this.onMarkAllRead,
    this.onRefresh,
    this.onViewAll,
  });

  final List<app_notification.Notification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;
  final void Function(app_notification.Notification)? onNotificationTap;
  final VoidCallback? onMarkAllRead;
  final VoidCallback? onRefresh;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('notifications_tile'),
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
          child: Row(
            children: [
              Text('Notifications', style: context.textTheme.titleMedium),
              if (unreadCount > 0) ...[
                AppSpacing.horizontalGapXS,
                Container(
                  key: const Key('unread_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.l),
                  ),
                  child: Text(
                    '$unreadCount',
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
        if (onMarkAllRead != null && unreadCount > 0)
          TextButton(
            key: const Key('mark_all_read_button'),
            onPressed: onMarkAllRead,
            child: const Text('Mark all read'),
          ),
        if (onViewAll != null)
          TextButton(
            key: const Key('notifications_view_all'),
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

    if (notifications.isEmpty) {
      return const CompactEmptyState(
        message: 'No notifications',
        icon: Icons.notifications_none_outlined,
      );
    }

    final displayNotifications = notifications.take(5).toList();
    return Column(
      children: displayNotifications
          .map(
            (n) => _NotificationItem(
              notification: n,
              onTap: onNotificationTap,
            ),
          )
          .toList(),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.notification, this.onTap});

  final app_notification.Notification notification;
  final void Function(app_notification.Notification)? onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isUnread;

    return InkWell(
      key: Key('notification_item_${notification.id}'),
      onTap: onTap != null ? () => onTap!(notification) : null,
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              notification.type.icon,
              color: notification.type.color,
              size: 20,
            ),
            AppSpacing.horizontalGapS,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalGapXS,
                  Text(
                    notification.body,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceSecondary(context.colorScheme),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4, left: AppSpacing.xs),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
