import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/features/registry/presentation/providers/registry_screen_provider.dart';
import 'package:nonna_app/features/registry/presentation/widgets/registry_filter_bar.dart';

/// Registry screen showing baby registry items with filtering and sorting.
///
/// **Functional Requirements**: Section 3.6.2 - Main App Screens Part II
class RegistryScreen extends ConsumerStatefulWidget {
  const RegistryScreen({
    super.key,
    this.babyProfileId,
    this.userRole,
    this.onItemTap,
  });

  /// ID of the baby profile whose registry to display
  final String? babyProfileId;

  /// Current user's role (owner sees add item FAB)
  final UserRole? userRole;

  /// Called when a registry item is tapped
  final Function(RegistryItem)? onItemTap;

  @override
  ConsumerState<RegistryScreen> createState() => _RegistryScreenState();
}

class _RegistryScreenState extends ConsumerState<RegistryScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.babyProfileId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(registryScreenProvider.notifier).loadItems(
              babyProfileId: widget.babyProfileId!,
            );
      });
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(registryScreenProvider.notifier).refresh();
  }

  void _onAddItemTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add registry item – coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registryScreenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registry'),
      ),
      floatingActionButton: widget.userRole == UserRole.owner
          ? FloatingActionButton(
              key: const Key('add_registry_item_fab'),
              onPressed: _onAddItemTap,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          RegistryFilterBar(
            currentFilter: state.currentFilter,
            currentSort: state.currentSort,
            onFilterChanged: (filter) =>
                ref.read(registryScreenProvider.notifier).applyFilter(filter),
            onSortChanged: (sort) =>
                ref.read(registryScreenProvider.notifier).applySort(sort),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _buildBody(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(RegistryScreenState state) {
    if (state.isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => const ShimmerListTile(),
      );
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(registryScreenProvider.notifier).refresh(),
      );
    }

    final items = state.sortedItems;

    if (items.isEmpty) {
      return const EmptyState(
        message: 'No registry items yet',
        icon: Icons.card_giftcard_outlined,
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final itemWithStatus = items[index];
        return ListTile(
          key: Key('registry_item_$index'),
          title: Text(itemWithStatus.item.name),
          subtitle: Text('Priority: ${itemWithStatus.item.priority}'),
          trailing: itemWithStatus.isPurchased
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.radio_button_unchecked),
          onTap: () => widget.onItemTap?.call(itemWithStatus.item),
        );
      },
    );
  }
}
