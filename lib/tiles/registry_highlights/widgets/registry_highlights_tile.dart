import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/registry_highlights/models/registry_item_with_status.dart';
import 'package:nonna_app/tiles/core/tile_icons.dart';
import 'package:nonna_app/tiles/core/widgets/tile_header.dart';

/// Tile widget that displays registry highlights with priority and purchase status.
class RegistryHighlightsTile extends StatelessWidget {
  const RegistryHighlightsTile({
    super.key,
    required this.items,
    this.isLoading = false,
    this.error,
    this.onItemTap,
    this.onRefresh,
    this.onViewAll,
  });

  final List<RegistryItemWithStatus> items;
  final bool isLoading;
  final String? error;
  final void Function(RegistryItemWithStatus)? onItemTap;
  final VoidCallback? onRefresh;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('registry_highlights_tile'),
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
    if (onViewAll != null) {
      actions.add(
        TextButton(
          key: const Key('registry_highlights_view_all'),
          onPressed: onViewAll,
          child: const Text('View all'),
        ),
      );
    }

    return TileHeader(
      icon: TileIcons.registryHighlights,
      title: 'Registry Highlights',
      actions: actions,
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

    if (items.isEmpty) {
      return const CompactEmptyState(
        message: 'No registry items',
        icon: Icons.card_giftcard_outlined,
      );
    }

    final displayItems = items.take(5).toList();
    return Column(
      children: displayItems
          .map((item) => _RegistryItemRow(item: item, onTap: onItemTap))
          .toList(),
    );
  }
}

class _RegistryItemRow extends StatelessWidget {
  const _RegistryItemRow({required this.item, this.onTap});

  final RegistryItemWithStatus item;
  final void Function(RegistryItemWithStatus)? onTap;

  Color _priorityColor(BuildContext context, int priority) {
    final scheme = Theme.of(context).colorScheme;
    if (priority >= 4) return scheme.error;
    if (priority == 3) return AppColors.secondary;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('registry_item_${item.item.id}'),
      onTap: onTap != null ? () => onTap!(item) : null,
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.item.name,
                style: context.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _PriorityBadge(
              priority: item.item.priority,
              color: _priorityColor(context, item.item.priority),
              id: item.item.id,
            ),
            AppSpacing.horizontalGapS,
            Icon(
              key: Key('purchase_status_${item.item.id}'),
              item.isPurchased
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: item.isPurchased
                  ? AppColors.primary
                  : AppColors.onSurfaceHint(context.colorScheme),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({
    required this.priority,
    required this.color,
    required this.id,
  });

  final int priority;
  final Color color;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('priority_badge_$id'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        'P$priority',
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
