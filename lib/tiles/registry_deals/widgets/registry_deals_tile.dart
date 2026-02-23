import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';

/// Tile widget that displays recommended registry items (deals).
class RegistryDealsTile extends StatelessWidget {
  const RegistryDealsTile({
    super.key,
    required this.deals,
    this.isLoading = false,
    this.error,
    this.onDealTap,
    this.onRefresh,
    this.onViewAll,
  });

  final List<RegistryItem> deals;
  final bool isLoading;
  final String? error;
  final void Function(RegistryItem)? onDealTap;
  final VoidCallback? onRefresh;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('registry_deals_tile'),
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
            'Registry Deals',
            style: context.textTheme.titleMedium,
          ),
        ),
        if (onViewAll != null)
          TextButton(
            key: const Key('registry_deals_view_all'),
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

    if (deals.isEmpty) {
      return const CompactEmptyState(
        message: 'No recommended items',
        icon: Icons.local_offer_outlined,
      );
    }

    final displayDeals = deals.take(5).toList();
    return Column(
      children: displayDeals
          .map((deal) => _DealRow(deal: deal, onTap: onDealTap))
          .toList(),
    );
  }
}

class _DealRow extends StatelessWidget {
  const _DealRow({required this.deal, this.onTap});

  final RegistryItem deal;
  final void Function(RegistryItem)? onTap;

  Color _priorityColor(int priority) {
    if (priority >= 5) return Colors.red;
    if (priority == 4) return Colors.orange;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(deal.priority);
    return InkWell(
      key: Key('deal_row_${deal.id}'),
      onTap: onTap != null ? () => onTap!(deal) : null,
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(Icons.local_offer, size: 20, color: color),
            AppSpacing.horizontalGapS,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.name,
                    style: context.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (deal.description != null) ...[
                    AppSpacing.verticalGapXS,
                    Text(
                      deal.description!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color:
                            AppColors.onSurfaceSecondary(context.colorScheme),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  key: Key('deal_priority_badge_${deal.id}'),
                  label: Text(
                    'P${deal.priority}',
                    style: context.textTheme.labelSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  backgroundColor: color,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
                if (deal.linkUrl != null) ...[
                  AppSpacing.horizontalGapXS,
                  Icon(
                    key: Key('deal_link_${deal.id}'),
                    Icons.open_in_new,
                    size: 16,
                    color: AppColors.onSurfaceHint(context.colorScheme),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
