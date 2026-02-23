import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';
import 'package:nonna_app/features/baby_profile/presentation/widgets/baby_profile_widgets.dart';

/// Screen for viewing a baby profile, follower list, and edit access.
///
/// **Functional Requirements**: Section 3.6.3 - Profile Management Screens
class BabyProfileScreen extends ConsumerStatefulWidget {
  const BabyProfileScreen({
    super.key,
    required this.babyProfileId,
    required this.currentUserId,
    this.onEditTap,
    this.onCreateTap,
  });

  final String babyProfileId;
  final String currentUserId;
  final VoidCallback? onEditTap;
  final VoidCallback? onCreateTap;

  @override
  ConsumerState<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends ConsumerState<BabyProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(babyProfileProvider.notifier).loadProfile(
            babyProfileId: widget.babyProfileId,
            currentUserId: widget.currentUserId,
          );
    });
  }

  Future<void> _removeFollower(
      String babyProfileId, String membershipId) async {
    await ref.read(babyProfileProvider.notifier).removeFollower(
          babyProfileId: babyProfileId,
          membershipId: membershipId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(babyProfileProvider);

    return Scaffold(
      key: const Key('baby_profile_screen'),
      appBar: AppBar(
        title: Text(state.profile?.name ?? 'Baby Profile'),
        actions: [
          if (state.isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
              onPressed: widget.onEditTap,
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(BabyProfileState state) {
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
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalGapM,
              ElevatedButton(
                onPressed: () =>
                    ref.read(babyProfileProvider.notifier).loadProfile(
                          babyProfileId: widget.babyProfileId,
                          currentUserId: widget.currentUserId,
                        ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = state.profile;
    if (profile == null) {
      return EmptyState(
        icon: Icons.child_care,
        message: 'No baby profile found',
        actionLabel: 'Create Profile',
        onAction: widget.onCreateTap,
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BabyProfileCard(profile: profile),
          if (state.isOwner && state.followers.isNotEmpty) ...[
            AppSpacing.verticalGapL,
            Text(
              'Followers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalGapS,
            ...state.followers.map(
              (m) => FollowerListItem(
                membership: m,
                onRemove: () {
                  if (m.id == null) {
                    debugPrint(
                        '⚠️  BabyMembership.id is null for userId=${m.userId}; falling back to userId as membershipId');
                  }
                  _removeFollower(widget.babyProfileId, m.id ?? m.userId);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
