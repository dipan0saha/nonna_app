import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/user_baby_profiles_provider.dart';
import 'package:nonna_app/features/home/presentation/widgets/home_app_bar.dart';
import 'package:nonna_app/features/home/presentation/widgets/tile_list_view.dart';
import 'package:nonna_app/core/widgets/offline_indicator.dart';

/// Home screen
///
/// **Functional Requirements**: Section 3.6.2 - Main App Screens Part I
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Tile list with pull-to-refresh
/// - Role toggle for dual-role users
/// - Baby profile selector
/// - Custom app bar with notifications/settings
/// - Shimmer loading, error, and empty states
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.babyProfileId,
    this.babyProfileName,
    this.userRole,
    this.isDualRole = false,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onSettingsTap,
    this.onBabyProfileTap,
  });

  /// The ID of the selected baby profile (triggers tile loading when set)
  final String? babyProfileId;

  /// Display name of the selected baby profile
  final String? babyProfileName;

  /// Current user role
  final UserRole? userRole;

  /// Whether the user has both owner and follower roles
  final bool isDualRole;

  /// Number of unread notifications
  final int notificationCount;

  /// Called when the notification icon is tapped
  final VoidCallback? onNotificationTap;

  /// Called when the settings icon is tapped
  final VoidCallback? onSettingsTap;

  /// Called when the baby profile name is tapped
  final VoidCallback? onBabyProfileTap;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadTilesIfReady();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.babyProfileId != oldWidget.babyProfileId ||
        widget.userRole != oldWidget.userRole) {
      _loadTilesIfReady();
    }
  }

  void _loadTilesIfReady() {
    // Prefer explicit constructor params, then fall back to global providers.
    final babyProfileId =
        widget.babyProfileId ?? ref.read(selectedBabyProfileProvider);
    final userRole =
        widget.userRole ?? ref.read(homeScreenProvider).selectedRole;

    if (babyProfileId != null && userRole != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(homeScreenProvider.notifier).loadTiles(
              babyProfileId: babyProfileId,
              role: userRole,
            );
      });
    } else if (babyProfileId != null && userRole == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final resolvedRole = await ref
            .read(currentUserRoleForBabyProfileProvider(babyProfileId).future);
        if (!mounted) return;

        ref.read(homeScreenProvider.notifier).loadTiles(
              babyProfileId: babyProfileId,
              role: resolvedRole,
            );
      });
    } else if (babyProfileId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userId = ref.read(authProvider).user?.id;
        if (userId != null) {
          ref.read(homeScreenProvider.notifier).autoSelectFirstProfile(userId);
        }
      });
    }
  }

  Future<void> _syncSelectedProfileIfNeeded(
    List<BabyProfileSummary> profiles,
  ) async {
    if (profiles.isEmpty) {
      final currentSelected = ref.read(selectedBabyProfileProvider);
      if (currentSelected != null) {
        ref.read(selectedBabyProfileProvider.notifier).select(null);
      }
      return;
    }

    final selectedId = ref.read(selectedBabyProfileProvider);
    final hasValidSelection = selectedId != null &&
        profiles.any((profile) => profile.id == selectedId);
    if (hasValidSelection) return;

    final fallbackProfileId = profiles.first.id;
    ref.read(selectedBabyProfileProvider.notifier).select(fallbackProfileId);

    final resolvedRole = await ref
        .read(currentUserRoleForBabyProfileProvider(fallbackProfileId).future);
    if (!mounted) return;

    await ref.read(homeScreenProvider.notifier).switchBabyProfile(
          babyProfileId: fallbackProfileId,
          role: resolvedRole,
        );
  }

  Future<void> _onRefresh() async {
    await ref.read(homeScreenProvider.notifier).onPullToRefresh();
  }

  void _onToggleRole(UserRole newRole) {
    ref.read(homeScreenProvider.notifier).toggleRole(newRole);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<BabyProfileSummary>>>(
      userBabyProfilesProvider,
      (previous, next) {
        next.whenData((profiles) {
          unawaited(_syncSelectedProfileIfNeeded(profiles));
        });
      },
    );

    final state = ref.watch(homeScreenProvider);
    // Resolve role and dual-role flag from provider state then constructor fallback.
    final userRole = state.selectedRole ?? widget.userRole;
    final isDualRole = widget.isDualRole;

    return Scaffold(
      appBar: HomeAppBar(
        babyProfileName: widget.babyProfileName,
        notificationCount: widget.notificationCount,
        onNotificationTap: widget.onNotificationTap,
        onSettingsTap: widget.onSettingsTap,
        onBabyProfileTap: widget.onBabyProfileTap,
      ),
      body: Column(
        children: [
          // Offline indicator — shown when device has no network connectivity.
          // isOnlineProvider is non-autoDispose so it survives navigation.
          OfflineIndicator(
            isOffline: !ref.watch(isOnlineProvider),
            onRetry: () => ref.read(homeScreenProvider.notifier).refresh(),
          ),
          // Role toggle for dual-role users
          if (isDualRole && userRole != null)
            _RoleToggle(
              selectedRole: state.selectedRole ?? userRole,
              onRoleChanged: _onToggleRole,
            ),
          // Main content
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(HomeScreenState state) {
    // Resolve the effective IDs using provider state first, then constructor params.
    final babyProfileId = state.selectedBabyProfileId ??
        widget.babyProfileId ??
        ref.read(selectedBabyProfileProvider);
    final resolvedRole = babyProfileId != null
        ? ref
            .watch(currentUserRoleForBabyProfileProvider(babyProfileId))
            .asData
            ?.value
        : null;
    final userRole = state.selectedRole ?? widget.userRole ?? resolvedRole;

    // No profile or role configured yet
    if (babyProfileId == null) {
      return EmptyState(
        message: 'Select a baby profile to get started',
        icon: Icons.child_care,
        actionLabel: 'Create Profile',
        onAction: () {
          final userId = ref.read(authProvider).user?.id ?? '';
          context.push(AppRoutes.babyProfileCreate, extra: {'userId': userId});
        },
      );
    }

    if (userRole == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return TileListView(
      tiles: state.tiles,
      isLoading: state.isLoading,
      error: state.error,
      onRefresh: _onRefresh,
      onRetry: () => ref.read(homeScreenProvider.notifier).retry(),
      emptyWidget: const EmptyState(
        icon: Icons.add_a_photo_outlined,
        title: 'Every big moment starts somewhere.',
        message: 'Add your first photo!',
        description: 'Tap the + button below to get started.',
      ),
    );
  }
}

/// Role toggle widget for dual-role users
class _RoleToggle extends StatelessWidget {
  const _RoleToggle({
    required this.selectedRole,
    required this.onRoleChanged,
  });

  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs / 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _RoleChip(
            label: UserRole.owner.displayName,
            icon: UserRole.owner.icon,
            isSelected: selectedRole == UserRole.owner,
            onTap: () => onRoleChanged(UserRole.owner),
          ),
          AppSpacing.horizontalGapM,
          _RoleChip(
            label: UserRole.follower.displayName,
            icon: UserRole.follower.icon,
            isSelected: selectedRole == UserRole.follower,
            onTap: () => onRoleChanged(UserRole.follower),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppColors.primaryDark,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryDark,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
      ),
    );
  }
}
