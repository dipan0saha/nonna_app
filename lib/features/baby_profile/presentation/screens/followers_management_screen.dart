import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';
import 'package:nonna_app/features/baby_profile/presentation/widgets/baby_profile_widgets.dart';

/// Screen for managing followers of a baby profile (owner-only).
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class FollowersManagementScreen extends ConsumerStatefulWidget {
  const FollowersManagementScreen({
    super.key,
    required this.babyProfileId,
    required this.currentUserId,
    this.onInviteTap,
  });

  final String babyProfileId;
  final String currentUserId;
  final VoidCallback? onInviteTap;

  @override
  ConsumerState<FollowersManagementScreen> createState() =>
      _FollowersManagementScreenState();
}

class _FollowersManagementScreenState
    extends ConsumerState<FollowersManagementScreen> {
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

  Future<void> _removeFollower(String membershipId) async {
    await ref.read(babyProfileProvider.notifier).removeFollower(
          babyProfileId: widget.babyProfileId,
          membershipId: membershipId,
        );
  }

  Future<void> _revokeInvitation(String invitationId) async {
    final success =
        await ref.read(babyProfileProvider.notifier).revokeInvitation(
              invitationId: invitationId,
              babyProfileId: widget.babyProfileId,
              currentUserId: widget.currentUserId,
            );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation revoked')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(babyProfileProvider);

    return Scaffold(
      key: const Key('followers_management_screen'),
      appBar: AppBar(
        title: const Text('Manage Followers'),
        actions: [
          if (state.isOwner)
            IconButton(
              key: const Key('invite_follower_button'),
              icon: const Icon(Icons.person_add),
              tooltip: 'Invite Follower',
              onPressed: widget.onInviteTap,
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

    if (!state.isOwner) {
      return const Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Text(
            'Only profile owners can manage followers and invitations.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final pendingInvitations = state.pendingInvitations;
    final followers = state.followers;

    if (followers.isEmpty && pendingInvitations.isEmpty) {
      return EmptyState(
        key: const Key('no_followers_empty_state'),
        icon: Icons.people_outline,
        message: 'No followers yet',
        actionLabel: 'Invite Someone',
        onAction: widget.onInviteTap,
      );
    }

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        if (pendingInvitations.isNotEmpty) ...[
          Text(
            'Pending Invitations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSpacing.verticalGapS,
          ...pendingInvitations.map(
            (invitation) => ListTile(
              key: Key('pending_invitation_${invitation.id}'),
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                child: Icon(Icons.mail_outline),
              ),
              title: Text(invitation.inviteeEmail),
              subtitle: Text(
                'Sent ${invitation.createdAt.toLocal().toString().split('.').first}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                tooltip: 'Revoke invitation',
                onPressed: () => _revokeInvitation(invitation.id),
              ),
            ),
          ),
          const Divider(height: 24),
        ],
        if (followers.isNotEmpty) ...[
          Text(
            'Followers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSpacing.verticalGapS,
          ...followers.asMap().entries.map((entry) {
            final index = entry.key;
            final membership = entry.value;
            return FollowerListItem(
              key: Key('follower_item_$index'),
              membership: membership,
              onRemove: () {
                if (membership.id == null) {
                  debugPrint(
                      '⚠️  BabyMembership.id is null for userId=${membership.userId}; falling back to userId as membershipId');
                }
                _removeFollower(membership.id ?? membership.userId);
              },
            );
          }),
        ],
      ],
    );
  }
}
