import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/features/registry/presentation/providers/registry_screen_provider.dart';
import 'package:nonna_app/features/registry/presentation/widgets/registry_filter_bar.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';

class RegistryListSmartTile extends ConsumerWidget {
  const RegistryListSmartTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registryScreenProvider);
    final role =
        ref.watch(homeScreenProvider).selectedRole ?? UserRole.follower;
    final isOwner = role == UserRole.owner;

    if (state.isLoading) {
      return Card(
        child: Column(
          children: List.generate(5, (_) => const ShimmerListTile()),
        ),
      );
    }

    final items = state.sortedItems;
    final availableItems = items.where((item) => !item.isPurchased).toList();
    final purchasedItems = items.where((item) => item.isPurchased).toList();

    return Card(
      key: const Key('registry_list_smart_tile'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Registry Items',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          RegistryFilterBar(
            currentFilter: state.currentFilter,
            currentSort: state.currentSort,
            onFilterChanged: (_) {},
            onSortChanged: (sort) =>
                ref.read(registryScreenProvider.notifier).applySort(sort),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: EmptyState(
                message: 'No registry items found',
                icon: Icons.card_giftcard_outlined,
              ),
            )
          else
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _SectionHeader(
                  title: 'Available Items',
                  count: availableItems.length,
                ),
                ...availableItems.map(
                  (itemWithStatus) => _RegistryItemRow(
                    itemWithStatus: itemWithStatus,
                    isOwner: isOwner,
                    onTap: () => context.push(AppRoutes.registryItem,
                        extra: itemWithStatus.item),
                    onTogglePurchase: () => ref
                        .read(registryScreenProvider.notifier)
                        .togglePurchase(itemWithStatus),
                  ),
                ),
                if (purchasedItems.isNotEmpty) ...[
                  const Divider(height: 20),
                  _SectionHeader(
                    title: 'Purchased Items',
                    count: purchasedItems.length,
                  ),
                  ...purchasedItems.map(
                    (itemWithStatus) => _RegistryItemRow(
                      itemWithStatus: itemWithStatus,
                      isOwner: isOwner,
                      onTap: () => context.push(AppRoutes.registryItem,
                          extra: itemWithStatus.item),
                      onTogglePurchase: () => ref
                          .read(registryScreenProvider.notifier)
                          .togglePurchase(itemWithStatus),
                    ),
                  ),
                ],
              ],
            ),
          AppSpacing.verticalGapS,
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

class _RegistryItemRow extends StatelessWidget {
  const _RegistryItemRow({
    required this.itemWithStatus,
    required this.isOwner,
    required this.onTap,
    required this.onTogglePurchase,
  });

  final RegistryItemWithStatus itemWithStatus;
  final bool isOwner;
  final VoidCallback onTap;
  final VoidCallback onTogglePurchase;

  @override
  Widget build(BuildContext context) {
    final item = itemWithStatus.item;
    final addedDate = DateFormat('MMM d, yyyy').format(item.createdAt);
    final purchaserNames =
        itemWithStatus.purchasers.map((p) => p.displayName).toSet().join(', ');

    final canUnpurchase = itemWithStatus.isPurchasedByCurrentUser;
    final canPurchase = !itemWithStatus.isPurchasedByCurrentUser;

    IconData icon;
    Color? iconColor;
    String tooltip;

    if (canUnpurchase) {
      icon = Icons.undo;
      iconColor = Colors.orange;
      tooltip = 'Mark as unpurchased';
    } else if (itemWithStatus.isPurchased) {
      icon = Icons.add_task;
      iconColor = Colors.green;
      tooltip = isOwner
          ? 'Also mark as purchased by you'
          : 'Mark as purchased by you';
    } else {
      icon = Icons.check_circle_outline;
      iconColor = Colors.green;
      tooltip = 'Mark as purchased';
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(item.name),
      subtitle: Text(
        itemWithStatus.isPurchased && purchaserNames.isNotEmpty
            ? 'Priority ${item.priority} • Added $addedDate\nPurchased by: $purchaserNames'
            : 'Priority ${item.priority} • Added $addedDate',
      ),
      isThreeLine: itemWithStatus.isPurchased && purchaserNames.isNotEmpty,
      trailing: IconButton(
        icon: Icon(icon, color: iconColor),
        tooltip: tooltip,
        onPressed: canPurchase || canUnpurchase ? onTogglePurchase : null,
      ),
      onTap: onTap,
    );
  }
}
