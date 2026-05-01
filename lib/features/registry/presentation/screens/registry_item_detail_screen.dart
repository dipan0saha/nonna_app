import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/features/registry/presentation/providers/registry_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:url_launcher/url_launcher.dart';

/// Registry item detail screen showing full info, purchase status, and actions.
///
/// **Functional Requirements**: Section 3.6.2 - Main App Screens Part II
class RegistryItemDetailScreen extends ConsumerWidget {
  const RegistryItemDetailScreen({
    super.key,
    required this.item,
  });

  /// The registry item to display
  final RegistryItem item;

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registryScreenProvider);
    final itemWithStatus =
        state.items.cast<RegistryItemWithStatus?>().firstWhere(
              (element) => element?.item.id == item.id,
              orElse: () => null,
            );

    final isPurchased = itemWithStatus?.isPurchased ?? false;
    final purchaseCount = itemWithStatus?.purchaseCount ?? 0;

    final role =
        ref.watch(homeScreenProvider).selectedRole ?? UserRole.follower;
    final isOwner = role == UserRole.owner;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          if (isOwner)
            IconButton(
              key: const Key('edit_item_button'),
              icon: const Icon(Icons.edit),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Edit registry item – coming soon!')),
                );
              },
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
                onTap: () => _launchUrl(item.linkUrl),
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
                  const Text('Purchased',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ] else ...[
                  const Icon(Icons.radio_button_unchecked),
                  AppSpacing.horizontalGapXS,
                  const Text('Not yet purchased'),
                ],
              ],
            ),
            AppSpacing.verticalGapM,

            // Show purchasers list if it's purchased
            if (isPurchased &&
                itemWithStatus != null &&
                itemWithStatus.purchasers.isNotEmpty) ...[
              Text(
                'Purchased by:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              AppSpacing.verticalGapS,
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: itemWithStatus.purchasers.map((user) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundImage:
                          user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                      child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                          ? Text(user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : '?')
                          : null,
                    ),
                    label: Text(user.displayName),
                  );
                }).toList(),
              ),
              AppSpacing.verticalGapM,
            ],

            // Purchase button (non-owner, wait: if it's already purchased, but NOT by the current user, maybe they want to buy another one? Or buy it too?)
            // If they haven't purchased it, but someone else has? The current logic is simple: Mark as purchased / Unmark. If they haven't purchased it:
            if (!isOwner &&
                (itemWithStatus == null ||
                    !itemWithStatus.isPurchasedByCurrentUser))
              ElevatedButton(
                key: const Key('purchase_button'),
                onPressed: () {
                  if (itemWithStatus != null) {
                    ref
                        .read(registryScreenProvider.notifier)
                        .togglePurchase(itemWithStatus);
                  }
                },
                child: const Text('Mark as Purchased'),
              ),

            // Un-Purchase button (non-owner, previously purchased by currentUser)
            if (!isOwner && (itemWithStatus?.isPurchasedByCurrentUser ?? false))
              OutlinedButton(
                onPressed: () {
                  if (itemWithStatus != null) {
                    ref
                        .read(registryScreenProvider.notifier)
                        .togglePurchase(itemWithStatus);
                  }
                },
                child: const Text('Unmark as Purchased'),
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
