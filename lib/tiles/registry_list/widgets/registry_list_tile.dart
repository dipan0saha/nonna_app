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
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/tiles/core/tile_icons.dart';
import 'package:nonna_app/tiles/core/widgets/tile_header.dart';

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
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TileHeader(
              icon: TileIcons.registryList,
              title: 'Registry Items',
            ),
            AppSpacing.verticalGapXS,
            RegistryFilterBar(
              currentFilter: state.currentFilter,
              currentSort: state.currentSort,
              onFilterChanged: (_) {},
              onSortChanged: (sort) =>
                  ref.read(registryScreenProvider.notifier).applySort(sort),
            ),
            if (items.isEmpty)
              const CompactEmptyState(
                message: 'No registry items found',
                icon: Icons.card_giftcard_outlined,
              )
            else
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _SectionHeader(
                    title: 'Available Items',
                    count: availableItems.length,
                    color: AppColors.primary,
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
                    const Divider(height: 16),
                    _SectionHeader(
                      title: 'Purchased Items',
                      count: purchasedItems.length,
                      color: AppColors.secondary,
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
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.horizontalGapXS,
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          AppSpacing.horizontalGapXS,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
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
    final addedDate = DateFormat('MMM d').format(item.createdAt);
    final purchaserNames = itemWithStatus.isPurchased
        ? itemWithStatus.purchasers.map((p) => p.displayName).toSet().join(', ')
        : '';

    final canUnpurchase = itemWithStatus.isPurchasedByCurrentUser;
    final canPurchase = !itemWithStatus.isPurchased;

    IconData icon;
    Color? iconColor;
    String tooltip;

    if (canUnpurchase) {
      icon = Icons.undo;
      iconColor = AppColors.warningDark;
      tooltip = 'Mark as unpurchased';
    } else if (itemWithStatus.isPurchased) {
      icon = Icons.lock;
      iconColor = AppColors.onSurfaceHint(Theme.of(context).colorScheme);
      tooltip =
          isOwner ? 'Already purchased by someone else' : 'Already purchased';
    } else {
      icon = Icons.check_circle_outline;
      iconColor = AppColors.success;
      tooltip = 'Mark as purchased';
    }

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      minVerticalPadding: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _PriorityBadge(priority: item.priority),
        ],
      ),
      subtitle: Text(
        itemWithStatus.isPurchased
            ? purchaserNames.isNotEmpty
                ? 'Added $addedDate • Purchased by $purchaserNames'
                : 'Added $addedDate • Purchased'
            : 'Added $addedDate',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color:
                  AppColors.onSurfaceSecondary(Theme.of(context).colorScheme),
            ),
      ),
      trailing: IconButton(
        icon: Icon(icon, color: iconColor),
        iconSize: 20,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        tooltip: tooltip,
        onPressed: canPurchase || canUnpurchase ? onTogglePurchase : null,
      ),
      onTap: onTap,
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final int priority;

  Color _priorityColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (priority >= 4) return scheme.error;
    if (priority == 3) return AppColors.secondary;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(context);
    return Container(
      margin: const EdgeInsets.only(left: AppSpacing.xs),
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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}
