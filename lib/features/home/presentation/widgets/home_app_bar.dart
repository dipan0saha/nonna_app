import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/user_baby_profiles_provider.dart';

/// Home screen app bar — prototype design.
///
/// Layout:
/// - Leading : search icon → opens search
/// - Title   : "Nonna" in [AppColors.primary] (centered)
/// - Actions : circular user avatar + dropdown chevron → opens profile
///
/// **Functional Requirements**: Section 3.6.2 - Main App Screens Part I
class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    // Legacy params kept for backward-compatibility with existing tests.
    // The prototype design no longer uses these; the app bar derives its
    // data from [authProvider] instead.
    this.babyProfileName,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onSettingsTap,
    this.onBabyProfileTap,
  });

  final String? babyProfileName;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onBabyProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModel = ref.watch(authProvider).userModel;
    final avatarUrl = userModel?.avatarUrl;
    final displayName = userModel?.displayName ?? '';
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';

    return AppBar(
      key: const Key('home_app_bar'),
      centerTitle: true,
      // Leading — search
      leading: IconButton(
        key: const Key('search_icon_button'),
        icon: const Icon(Icons.search),
        tooltip: 'Search',
        onPressed: () {
          // TODO(search): open search screen/delegate when implemented.
        },
      ),
      // Title — brand name or baby profile switcher
      title: ref.watch(userBabyProfilesProvider).when(
        data: (profiles) {
          if (profiles.isEmpty) return _buildTitle(context, 'Nonna');
          
          final selectedId = ref.watch(selectedBabyProfileProvider);
          final selectedProfile = profiles.firstWhere(
            (p) => p.id == selectedId,
            orElse: () => profiles.first,
          );

          if (profiles.length == 1) {
            return _buildTitle(context, selectedProfile.name);
          }

          return DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedProfile.id,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref.read(selectedBabyProfileProvider.notifier).select(newValue);
                  // Load tiles for the newly selected profile
                  ref.read(homeScreenProvider.notifier).switchBabyProfile(
                    babyProfileId: newValue,
                    role: ref.read(homeScreenProvider).selectedRole ?? UserRole.follower,
                  );
                }
              },
              items: profiles.map<DropdownMenuItem<String>>((profile) {
                return DropdownMenuItem<String>(
                  value: profile.id,
                  child: Text(profile.name),
                );
              }).toList(),
            ),
          );
        },
        loading: () => _buildTitle(context, 'Nonna'),
        error: (_, __) => _buildTitle(context, 'Nonna'),
      ),
      // Actions — avatar + chevron → profile
      actions: [
        GestureDetector(
          key: const Key('profile_avatar_button'),
          onTap: onBabyProfileTap ??
              () {
                final userId = ref.read(authProvider).user?.id ?? '';
                context.push(AppRoutes.profile, extra: {'userId': userId});
              },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  foregroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
