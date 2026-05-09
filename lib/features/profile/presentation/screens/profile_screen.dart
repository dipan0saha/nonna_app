import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/user_stats.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:nonna_app/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nonna_app/core/router/app_router.dart';

/// Profile screen showing user avatar, stats, and settings actions.
///
/// **Functional Requirements**: Section 3.6.3 - Profile Management Screens
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({
    super.key,
    required this.userId,
    this.onEditTap,
    this.onSettingsTap,
    this.onLogoutTap,
  });

  final String userId;
  final VoidCallback? onEditTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile(userId: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      key: const Key('profile_screen'),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Profile'),
            backgroundColor: theme.scaffoldBackgroundColor,
            scrolledUnderElevation: 0,
          ),
          SliverToBoxAdapter(
            child: _buildBody(state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.error!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalGapM,
              ElevatedButton(
                onPressed: () => ref
                    .read(profileProvider.notifier)
                    .loadProfile(userId: widget.userId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = state.profile;
    if (profile == null) {
      return const Center(child: Text('No profile found'));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.m,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ProfileAvatar(
                  avatarUrl: profile.avatarUrl,
                  displayName: profile.displayName,
                  radius: 32,
                ),
                AppSpacing.horizontalGapM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.verticalGapXS,
                      Text(
                        '@${profile.userId.substring(0, 8)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalGapM,

          // Stats Section
          if (state.stats != null) ...[
            Padding(
              padding: const EdgeInsets.only(
                  left: AppSpacing.m, bottom: AppSpacing.xs),
              child: Text(
                'Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            _StatsSection(stats: state.stats!),
            AppSpacing.verticalGapM,
          ],

          // Actions Section
          Padding(
            padding: const EdgeInsets.only(
                left: AppSpacing.m, bottom: AppSpacing.xs),
            child: Text(
              'Account',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    _EnhancedListTile(
                      icon: Icons.edit_rounded,
                      iconColor: Colors.blue.shade600,
                      backgroundColor: Colors.blue.shade100,
                      title: 'Edit Profile',
                      onTap: widget.onEditTap ??
                          () {
                            context.push('${AppRoutes.profile}/edit',
                                extra: {'userId': widget.userId});
                          },
                    ),
                    const _Divider(),
                    _EnhancedListTile(
                      icon: Icons.settings_rounded,
                      iconColor: Colors.teal.shade600,
                      backgroundColor: Colors.teal.shade100,
                      title: 'Settings',
                      onTap: widget.onSettingsTap ??
                          () {
                            context.push(AppRoutes.settings);
                          },
                    ),
                    const _Divider(),
                    _EnhancedListTile(
                      icon: Icons.logout_rounded,
                      iconColor: colorScheme.error,
                      backgroundColor: colorScheme.errorContainer,
                      title: 'Logout',
                      titleColor: colorScheme.error,
                      showTrailing: false,
                      onTap: widget.onLogoutTap ??
                          () async {
                            final router = GoRouter.of(context);
                            await ref.read(authProvider.notifier).signOut();
                            router.go(AppRoutes.login);
                          },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Extra padding for scrolling
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64.0),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
      ),
    );
  }
}

class _EnhancedListTile extends StatelessWidget {
  const _EnhancedListTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.onTap,
    this.showTrailing = true,
    this.titleColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool showTrailing;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: titleColor),
      ),
      trailing: showTrailing
          ? const Icon(Icons.chevron_right_rounded, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.stats});

  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.s,
      mainAxisSpacing: AppSpacing.s,
      childAspectRatio: 1.8,
      children: [
        ProfileStatCard(
          label: 'Events Attended',
          value: '${stats.eventsAttendedCount}',
        ),
        ProfileStatCard(
          label: 'Items Purchased',
          value: '${stats.itemsPurchasedCount}',
        ),
        ProfileStatCard(
          label: 'Photos Squished',
          value: '${stats.photosSquishedCount}',
        ),
        ProfileStatCard(
          label: 'Comments',
          value: '${stats.commentsAddedCount}',
        ),
      ],
    );
  }
}
