import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRegistryIfReady();
    });
  }

  void _loadRegistryIfReady() {
    final babyProfileId =
        widget.babyProfileId ?? ref.read(selectedBabyProfileProvider);
    if (babyProfileId != null) {
      ref.read(registryScreenProvider.notifier).loadItems(
            babyProfileId: babyProfileId,
          );
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(registryScreenProvider.notifier).refresh();
  }

  void _onAddItemTap() {
    final state = ref.read(registryScreenProvider);
    final currentUser = ref.read(currentUserProvider);

    if (state.selectedBabyProfileId != null && currentUser != null) {
      context.push(
        AppRoutes.registryItemCreate,
        extra: {
          'babyProfileId': state.selectedBabyProfileId,
          'createdByUserId': currentUser.id,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Cannot create item: missing profile or user context.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for baby profile changes to reload registry items
    ref.listen<String?>(selectedBabyProfileProvider, (previous, next) {
      if (next != null && next != previous && widget.babyProfileId == null) {
        _loadRegistryIfReady();
      }
    });

    final currentBabyProfileId =
        widget.babyProfileId ?? ref.watch(selectedBabyProfileProvider);

    if (currentBabyProfileId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Registry')),
        body: const Center(
          child: EmptyState(
            message: 'Select a baby profile to view registry',
            icon: Icons.child_care,
          ),
        ),
      );
    }

    final state = ref.watch(registryScreenProvider);
    // Use widget role or fall back to home provider role, defaulting to follower
    final role = widget.userRole ??
        ref.watch(homeScreenProvider).selectedRole ??
        UserRole.follower;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registry'),
      ),
      floatingActionButton: role == UserRole.owner
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
            if (widget.onItemTap != null) {
              widget.onItemTap!.call(itemWithStatus.item);
            } else {
              context.push(AppRoutes.registryItem, extra: itemWithStatus.item);
            }
          },
        );
      },
    );
  }
}
