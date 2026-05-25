import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/features/registry/presentation/providers/registry_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/widgets/tile_list_view.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/user_baby_profiles_provider.dart';
import 'package:nonna_app/core/di/providers.dart';

final registryEffectiveRoleProvider =
    FutureProvider.autoDispose.family<UserRole, String>(
  (ref, babyProfileId) async {
    final selectedRole =
        ref.watch(homeScreenProvider.select((s) => s.selectedRole));

    try {
      return await ref.watch(
        currentUserRoleForBabyProfileProvider(babyProfileId).future,
      );
    } catch (_) {
      return selectedRole ?? UserRole.follower;
    }
  },
);

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

  Future<UserRole> _resolveEffectiveRole(String babyId) async {
    if (widget.userRole != null) return widget.userRole!;
    return ref.read(registryEffectiveRoleProvider(babyId).future);
  }

  Future<void> _loadRegistryIfReady() async {
    final babyId =
        widget.babyProfileId ?? ref.read(selectedBabyProfileProvider);
    if (babyId != null) {
      final role = await _resolveEffectiveRole(babyId);

      // Always force-refresh on the initial load so the list reflects the
      // current DB state rather than a potentially stale cache entry. The
      // cache-first path is kept for subsequent manual refreshes only.
      ref.read(registryScreenProvider.notifier).loadItems(
            babyProfileId: babyId,
            role: role,
            forceRefresh: true,
          );
    }
  }

  Future<void> _onRefresh() async {
    final babyId =
        widget.babyProfileId ?? ref.read(selectedBabyProfileProvider);
    if (babyId != null) {
      final role = await _resolveEffectiveRole(babyId);

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
      final role = await _resolveEffectiveRole(babyId);
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
    final selectedBabyId =
        widget.babyProfileId ?? ref.watch(selectedBabyProfileProvider);

    AsyncValue<UserRole> resolvedRole = const AsyncData(UserRole.follower);
    if (widget.userRole == null && selectedBabyId != null) {
      resolvedRole = ref.watch(registryEffectiveRoleProvider(selectedBabyId));
    }

    final role = widget.userRole ??
        resolvedRole.asData?.value ??
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
              heroTag: null,
              onPressed: _onAddItemTap,
              child: const Icon(Icons.add),
            )
          : null,
      body: TileListView(
        tiles: state.tiles,
        isLoading: state.isLoading,
        error: state.error,
        onRefresh: _onRefresh,
        onRetry: _loadRegistryIfReady,
        emptyWidget: const EmptyState(
          icon: Icons.card_giftcard_outlined,
          title: 'Your registry is empty',
          message: 'Add your first item!',
          description: 'Tap the + button below to get started.',
        ),
      ),
    );
  }
}
