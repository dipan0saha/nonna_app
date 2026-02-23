import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/themes/colors.dart';

/// Registry item detail screen showing full info, purchase status, and actions.
///
/// **Functional Requirements**: Section 3.6.2 - Main App Screens Part II
class RegistryItemDetailScreen extends StatelessWidget {
  const RegistryItemDetailScreen({
    super.key,
    required this.item,
    this.isPurchased = false,
    this.purchaseCount = 0,
    this.isOwner = false,
    this.onPurchase,
    this.onEdit,
    this.onLinkTap,
  });

  /// The registry item to display
  final RegistryItem item;

  /// Whether this item has been purchased
  final bool isPurchased;

  /// Number of people who purchased this item
  final int purchaseCount;

  /// Whether the current user is the owner
  final bool isOwner;

  /// Called when the purchase button is tapped
  final VoidCallback? onPurchase;

  /// Called when the edit button is tapped
  final VoidCallback? onEdit;

  /// Called when the item link is tapped
  final VoidCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          if (isOwner)
            IconButton(
              key: const Key('edit_item_button'),
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority stars
            Row(
              key: const Key('priority_stars'),
              children: [
                Text(
                  'Priority:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                AppSpacing.horizontalGapXS,
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < item.priority ? Icons.star : Icons.star_border,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalGapM,
            // Description
            if (item.description != null) ...[
              Text(
                'Description:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              AppSpacing.verticalGapXS,
              Text(item.description!),
              AppSpacing.verticalGapM,
            ],
            // Link
            if (item.linkUrl != null) ...[
              Text(
                'Item Link:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              AppSpacing.verticalGapXS,
              InkWell(
                onTap: onLinkTap,
                child: Text(
                  item.linkUrl!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              AppSpacing.verticalGapM,
            ],
            // Purchase status
            Row(
              key: const Key('purchase_status_row'),
              children: [
                if (isPurchased) ...[
                  const Icon(Icons.check_circle, color: Colors.green),
                  AppSpacing.horizontalGapXS,
                  const Text('Purchased'),
                ] else ...[
                  const Icon(Icons.radio_button_unchecked),
                  AppSpacing.horizontalGapXS,
                  const Text('Not yet purchased'),
                ],
              ],
            ),
            AppSpacing.verticalGapM,
            // Purchase button (non-owner, not yet purchased)
            if (!isOwner && !isPurchased)
              ElevatedButton(
                key: const Key('purchase_button'),
                onPressed: onPurchase,
                child: const Text('Mark as Purchased'),
              ),
            // Purchase count
            if (purchaseCount > 0) ...[
              AppSpacing.verticalGapS,
              Text(
                'Purchased by $purchaseCount ${purchaseCount == 1 ? 'person' : 'people'}',
              ),
            ],
            AppSpacing.verticalGapM,
            // Created date
            Text(
              'Added: ${DateFormat('MMM d, yyyy').format(item.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
