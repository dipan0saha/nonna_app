import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/features/registry/presentation/providers/registry_screen_provider.dart';
import 'package:nonna_app/features/registry/presentation/widgets/registry_filter_bar.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';

class RegistryListSmartTile extends ConsumerWidget {
  const RegistryListSmartTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registryScreenProvider);

    if (state.isLoading) {
      return Card(
        child: Column(
          children: List.generate(5, (_) => const ShimmerListTile()),
        ),
      );
    }

    final items = state.sortedItems;

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
            onFilterChanged: (filter) =>
                ref.read(registryScreenProvider.notifier).applyFilter(filter),
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final itemWithStatus = items[index];
                return ListTile(
                  key: Key('registry_item_$index'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(itemWithStatus.item.name),
                  subtitle: Text('Priority: ${itemWithStatus.item.priority}'),
                  trailing: IconButton(
                    icon: itemWithStatus.isPurchased
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.radio_button_unchecked),
                    onPressed: () {
                      ref
                          .read(registryScreenProvider.notifier)
                          .togglePurchase(itemWithStatus);
                    },
                  ),
                  onTap: () {
                    context.push(AppRoutes.registryItem,
                        extra: itemWithStatus.item);
                  },
                );
              },
            ),
          AppSpacing.verticalGapS,
        ],
      ),
    );
  }
}
