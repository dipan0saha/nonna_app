import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/registry_highlights/providers/registry_highlights_provider.dart';

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
    return Row(
      children: [
        Expanded(
          child: Text(
            'Registry Highlights',
            style: context.textTheme.titleMedium,
          ),
        ),
        if (onViewAll != null)
          TextButton(
            key: const Key('registry_highlights_view_all'),
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

  Color _priorityColor(int priority) {
    if (priority >= 4) return Colors.red;
    if (priority == 3) return Colors.orange;
    return Colors.blue;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.item.name,
                    style: context.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalGapXS,
                  Chip(
                    key: Key('priority_badge_${item.item.id}'),
                    label: Text(
                      'P${item.item.priority}',
                      style: context.textTheme.labelSmall
                          ?.copyWith(color: Colors.white),
                    ),
                    backgroundColor: _priorityColor(item.item.priority),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            Icon(
              key: Key('purchase_status_${item.item.id}'),
              item.isPurchased
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: item.isPurchased
                  ? Colors.green
                  : AppColors.onSurfaceHint(context.colorScheme),
            ),
          ],
        ),
      ),
    );
  }
}
