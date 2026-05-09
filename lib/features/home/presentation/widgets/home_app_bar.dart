import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/user_baby_profiles_provider.dart';
import 'package:nonna_app/features/home/presentation/widgets/home_app_bar_search_dialog.dart';

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
    final userId = ref.watch(authProvider).user?.id ?? '';
    final avatarUrl = userModel?.avatarUrl;
    final displayName = userModel?.displayName ?? '';
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';
    final profilesAsync = ref.watch(userBabyProfilesProvider);
    final profiles =
        profilesAsync.asData?.value ?? const <BabyProfileSummary>[];
    final selectedId = ref.watch(selectedBabyProfileProvider);
    final selectedProfile = profiles.isEmpty
        ? null
        : profiles.firstWhere(
            (p) => p.id == selectedId,
            orElse: () => profiles.first,
          );
    final selectedRole = selectedProfile == null
        ? null
        : ref
            .watch(currentUserRoleForBabyProfileProvider(selectedProfile.id))
            .asData
            ?.value;

    return AppBar(
      key: const Key('home_app_bar'),
      centerTitle: true,
      // Leading — search
      leading: IconButton(
        key: const Key('search_icon_button'),
        icon: const Icon(Icons.search),
        onPressed: () {
          showSearch(
            context: context,
            delegate: GlobalSearchDelegate(),
          );
        },
      ),
      // Title — brand name or baby profile switcher
      title: profilesAsync.when(
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
            child: SizedBox(
              width: double.infinity,
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedProfile.id,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.primary),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                selectedItemBuilder: (context) {
                  return profiles
                      .map(
                        (profile) => Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            profile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList();
                },
                onChanged: (String? newValue) async {
                  if (newValue != null) {
                    ref
                        .read(selectedBabyProfileProvider.notifier)
                        .select(newValue);
                    final resolvedRole = await ref.read(
                      currentUserRoleForBabyProfileProvider(newValue).future,
                    );
                    // Load tiles for the newly selected profile
                    ref.read(homeScreenProvider.notifier).switchBabyProfile(
                          babyProfileId: newValue,
                          role: resolvedRole,
                        );
                  }
                },
                items: profiles.map<DropdownMenuItem<String>>((profile) {
                  return DropdownMenuItem<String>(
                    value: profile.id,
                    child: Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
        loading: () => _buildTitle(context, 'Nonna'),
        error: (_, __) => _buildTitle(context, 'Nonna'),
      ),
      // Actions — avatar + chevron → profile
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: userId.isEmpty
              ? null
              : () {
                  context.push(
                    AppRoutes.babyProfileCreate,
                    extra: {'userId': userId},
                  );
                },
        ),
        if (selectedProfile != null)
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Baby Profile Info',
            onPressed: userId.isEmpty
                ? null
                : () {
                    context.push(
                      AppRoutes.babyProfile,
                      extra: {
                        'babyProfileId': selectedProfile.id,
                        'currentUserId': userId,
                      },
                    );
                  },
          ),
        if (selectedProfile != null && selectedRole == UserRole.owner)
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            onPressed: userId.isEmpty
                ? null
                : () {
                    context.push(
                      AppRoutes.babyProfileFollowers,
                      extra: {
                        'babyProfileId': selectedProfile.id,
                        'currentUserId': userId,
                      },
                    );
                  },
          ),
        GestureDetector(
          key: const Key('profile_avatar_button'),
          onTap: onBabyProfileTap ??
              () {
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
