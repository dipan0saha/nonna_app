import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/enums/invitation_status.dart';
import 'package:nonna_app/core/models/invitation.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';

/// Tile widget that displays invitation statuses with resend/revoke actions.
class InvitesStatusTile extends StatelessWidget {
  const InvitesStatusTile({
    super.key,
    required this.invitations,
    this.pendingCount = 0,
    this.isLoading = false,
    this.error,
    this.onResend,
    this.onRevoke,
    this.onRefresh,
    this.onViewAll,
  });

  final List<Invitation> invitations;
  final int pendingCount;
  final bool isLoading;
  final String? error;
  final void Function(Invitation)? onResend;
  final void Function(Invitation)? onRevoke;
  final VoidCallback? onRefresh;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('invites_status_tile'),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            AppSpacing.verticalGapS,
            _buildBody(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text('Invite Status', style: context.textTheme.titleMedium),
              if (pendingCount > 0) ...[
                AppSpacing.horizontalGapXS,
                Container(
                  key: const Key('pending_count_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppSpacing.l),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onViewAll != null)
          TextButton(
            key: const Key('invites_status_view_all'),
            onPressed: onViewAll,
            child: const Text('View all'),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Column(
        children: [
          ShimmerListTile(),
          ShimmerListTile(),
          ShimmerListTile(),
        ],
      );
    }

    if (error != null) {
      return InlineErrorView(message: error!, onRetry: onRefresh);
    }

    if (invitations.isEmpty) {
      return const CompactEmptyState(
        message: 'No invitations sent',
        icon: Icons.mail_outlined,
      );
    }

    final displayInvitations = invitations.take(5).toList();
    return Column(
      children: displayInvitations
          .map(
            (inv) => _InvitationRow(
              invitation: inv,
              onResend: onResend,
              onRevoke: onRevoke,
            ),
          )
          .toList(),
    );
  }
}

Color _statusColor(InvitationStatus status) {
  switch (status) {
    case InvitationStatus.pending:
      return Colors.orange;
    case InvitationStatus.accepted:
      return Colors.green;
    case InvitationStatus.revoked:
      return Colors.red;
    case InvitationStatus.expired:
      return Colors.grey;
  }
}

class _InvitationRow extends StatelessWidget {
  const _InvitationRow({
    required this.invitation,
    this.onResend,
    this.onRevoke,
  });

  final Invitation invitation;
  final void Function(Invitation)? onResend;
  final void Function(Invitation)? onRevoke;

  @override
  Widget build(BuildContext context) {
    final isPending = invitation.status == InvitationStatus.pending;

    return Padding(
      key: Key('invitation_item_${invitation.id}'),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  invitation.inviteeEmail,
                  style: context.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Chip(
                key: Key('status_chip_${invitation.id}'),
                label: Text(
                  invitation.status.displayName,
                  style: context.textTheme.labelSmall
                      ?.copyWith(color: Colors.white),
                ),
                backgroundColor: _statusColor(invitation.status),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          if (isPending) ...[
            Row(
              children: [
                if (onResend != null)
                  TextButton(
                    key: Key('resend_button_${invitation.id}'),
                    onPressed: () => onResend!(invitation),
                    child: const Text('Resend'),
                  ),
                if (onRevoke != null)
                  TextButton(
                    key: Key('revoke_button_${invitation.id}'),
                    onPressed: () => onRevoke!(invitation),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Revoke'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
