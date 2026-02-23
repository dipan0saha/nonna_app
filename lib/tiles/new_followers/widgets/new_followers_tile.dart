import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/baby_membership.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';

/// Tile widget that shows recent followers (baby profile members added in the
/// last 30 days).
class NewFollowersTile extends StatelessWidget {
  const NewFollowersTile({
    super.key,
    required this.followers,
    this.activeCount = 0,
    this.isLoading = false,
    this.error,
    this.onFollowerTap,
    this.onRefresh,
    this.onViewAll,
  });

  /// Recent followers to display.
  final List<BabyMembership> followers;

  /// Count of currently active (non-removed) followers.
  final int activeCount;
  final bool isLoading;
  final String? error;
  final void Function(BabyMembership)? onFollowerTap;
  final VoidCallback? onRefresh;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('new_followers_tile'),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TileHeader(
              title: 'New Followers',
              activeCount: activeCount,
              onViewAll: onViewAll,
              viewAllKey: const Key('new_followers_view_all'),
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

    if (followers.isEmpty) {
      return const CompactEmptyState(
        message: 'No new followers recently',
        icon: Icons.people_outline,
      );
    }

    final display = followers.take(5).toList();
    return Column(
      children: display
          .map(
            (f) => _FollowerRow(
              follower: f,
              onTap: onFollowerTap,
            ),
          )
          .toList(),
    );
  }
}

class _FollowerRow extends StatelessWidget {
  const _FollowerRow({required this.follower, this.onTap});

  final BabyMembership follower;
  final void Function(BabyMembership)? onTap;

  @override
  Widget build(BuildContext context) {
    final joinedDate = DateFormat('MMM d, yyyy').format(follower.createdAt);

    return InkWell(
      key: Key('follower_${follower.userId}'),
      onTap: onTap != null ? () => onTap!(follower) : null,
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              Icons.person_outline,
              color: AppColors.primary,
              size: 20,
            ),
            AppSpacing.horizontalGapS,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    follower.relationshipLabel ?? follower.userId,
                    style: context.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Joined $joinedDate',
                    style: context.textTheme.bodySmall?.copyWith(
                      color:
                          AppColors.onSurfaceSecondary(context.colorScheme),
                    ),
                  ),
                ],
              ),
            ),
            if (!follower.isActive)
              _StatusBadge(
                key: Key('removed_badge_${follower.userId}'),
                label: 'Removed',
                color: Colors.red,
              )
            else
              _StatusBadge(
                key: Key('active_badge_${follower.userId}'),
                label: 'Active',
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _TileHeader extends StatelessWidget {
  const _TileHeader({
    required this.title,
    required this.activeCount,
    this.onViewAll,
    this.viewAllKey,
  });

  final String title;
  final int activeCount;
  final VoidCallback? onViewAll;
  final Key? viewAllKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: context.textTheme.titleMedium),
        ),
        if (activeCount > 0)
          Container(
            key: const Key('new_followers_count_badge'),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$activeCount',
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
