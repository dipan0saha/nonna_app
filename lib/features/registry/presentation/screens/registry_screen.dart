import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/features/registry/presentation/providers/registry_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/widgets/tile_list_view.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/core/di/providers.dart';

class RegistryScreen extends ConsumerStatefulWidget {
  const RegistryScreen({
    super.key,
    this.babyProfileId,
    this.userRole,
  });

  /// ID of the baby profile whose registry to display
  final String? babyProfileId;

  /// Current user's role (owner sees add item FAB)
  final UserRole? userRole;

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

  @override
  void didUpdateWidget(RegistryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.babyProfileId != oldWidget.babyProfileId) {
      _loadRegistryIfReady();
    }
  }

  void _loadRegistryIfReady() {
    final babyId =
        widget.babyProfileId ?? ref.read(selectedBabyProfileProvider);
    if (babyId != null) {
      final role = widget.userRole ??
          ref.read(homeScreenProvider).selectedRole ??
          UserRole.follower;

      ref.read(registryScreenProvider.notifier).loadItems(
            babyProfileId: babyId,
            role: role,
          );
    }
  }

  Future<void> _onRefresh() async {
    final babyId =
        widget.babyProfileId ?? ref.read(selectedBabyProfileProvider);
    if (babyId != null) {
      final role = widget.userRole ??
          ref.read(homeScreenProvider).selectedRole ??
          UserRole.follower;

      await ref.read(registryScreenProvider.notifier).loadItems(
            babyProfileId: babyId,
            role: role,
            forceRefresh: true,
          );
    }
  }

  Future<void> _onAddItemTap() async {
    final babyId =
        widget.babyProfileId ?? ref.read(selectedBabyProfileProvider);
    final userId = ref.read(currentUserProvider)?.id;
    if (babyId == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open item creation.')),
      );
      return;
    }

    final created = await context.push<bool>(
      AppRoutes.registryItemCreate,
      extra: {
        'babyProfileId': babyId,
        'createdByUserId': userId,
      },
    );

    if (created == true && mounted) {
      final role = widget.userRole ??
          ref.read(homeScreenProvider).selectedRole ??
          UserRole.follower;
      await ref.read(registryScreenProvider.notifier).loadItems(
            babyProfileId: babyId,
            role: role,
            forceRefresh: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registryScreenProvider);
    final role = widget.userRole ??
        ref.watch(homeScreenProvider).selectedRole ??
        UserRole.follower;
    final isOwner = role == UserRole.owner;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registry'),
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              key: const Key('add_registry_item_fab'),
              onPressed: _onAddItemTap,
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildBody(state),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(RegistryScreenState state) {
    if (state.isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const ShimmerListTile(),
          childCount: 5,
        ),
      );
    }

    if (state.error != null) {
      return SliverFillRemaining(
        child: ErrorView(
          message: state.error!,
          onRetry: _onRefresh,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TileListView(
          tiles: state.tiles,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }
}
