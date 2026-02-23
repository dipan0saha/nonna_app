import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/registry_purchase.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';

/// Tile widget that displays recent registry purchases.
class RecentPurchasesTile extends StatelessWidget {
  const RecentPurchasesTile({
    super.key,
    required this.purchases,
    this.isLoading = false,
    this.error,
    this.onPurchaseTap,
    this.onRefresh,
    this.onViewAll,
  });

  final List<RegistryPurchase> purchases;
  final bool isLoading;
  final String? error;
  final void Function(RegistryPurchase)? onPurchaseTap;
  final VoidCallback? onRefresh;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('recent_purchases_tile'),
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
            'Recent Purchases',
            style: context.textTheme.titleMedium,
          ),
        ),
        if (onViewAll != null)
          TextButton(
            key: const Key('recent_purchases_view_all'),
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

    if (purchases.isEmpty) {
      return const CompactEmptyState(
        message: 'No recent purchases',
        icon: Icons.shopping_bag_outlined,
      );
    }

    final displayPurchases = purchases.take(5).toList();
    return Column(
      children: displayPurchases
          .map(
            (purchase) =>
                _PurchaseRow(purchase: purchase, onTap: onPurchaseTap),
          )
          .toList(),
    );
  }
}

class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({required this.purchase, this.onTap});

  final RegistryPurchase purchase;
  final void Function(RegistryPurchase)? onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d').format(purchase.purchasedAt);

    return InkWell(
      key: Key('purchase_row_${purchase.id}'),
      onTap: onTap != null ? () => onTap!(purchase) : null,
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            const Icon(Icons.card_giftcard, size: 20, color: AppColors.primary),
            AppSpacing.horizontalGapS,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item #${purchase.registryItemId.substring(0, 8)}',
                    style: context.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (purchase.note != null) ...[
                    AppSpacing.verticalGapXS,
                    Text(
                      purchase.note!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceSecondary(
                            context.colorScheme),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              dateStr,
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
