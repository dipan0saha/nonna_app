import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/user_stats.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:nonna_app/features/profile/presentation/widgets/profile_widgets.dart';

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
      ref
          .read(profileProvider.notifier)
          .loadProfile(userId: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      key: const Key('profile_screen'),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primaryLight,
      ),
      body: _buildBody(state),
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

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileAvatar(
            avatarUrl: profile.avatarUrl,
            displayName: profile.displayName,
            radius: 48,
          ),
          AppSpacing.verticalGapM,
          Text(
            profile.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSpacing.verticalGapL,
          if (state.stats != null) _StatsSection(stats: state.stats!),
          AppSpacing.verticalGapL,
          const Divider(),
          ProfileSettingsItem(
            icon: Icons.edit,
            label: 'Edit Profile',
            onTap: widget.onEditTap ?? () {},
          ),
          ProfileSettingsItem(
            icon: Icons.settings,
            label: 'Settings',
            onTap: widget.onSettingsTap ?? () {},
          ),
          ProfileSettingsItem(
            icon: Icons.logout,
            label: 'Logout',
            onTap: widget.onLogoutTap ?? () {},
            trailing: const Icon(Icons.logout, color: AppColors.error),
          ),
        ],
      ),
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
      childAspectRatio: 2.0,
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
