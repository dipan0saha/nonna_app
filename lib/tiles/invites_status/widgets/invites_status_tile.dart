import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/enums/invitation_status.dart';
import 'package:nonna_app/core/models/invitation.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/core/tile_icons.dart';
import 'package:nonna_app/tiles/core/widgets/tile_header.dart';

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
    final actions = <Widget>[];
    if (onViewAll != null) {
      actions.add(
        TextButton(
          key: const Key('invites_status_view_all'),
          onPressed: onViewAll,
          child: const Text('View all'),
        ),
      );
    }

    final pendingBadge = pendingCount > 0
        ? Container(
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
          )
        : null;

    return TileHeader(
      icon: TileIcons.invitesStatus,
      title: 'Invite Status',
      titleSuffix: pendingBadge,
      actions: actions,
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
      children: [
        _StatusDonutChart(invitations: invitations),
        AppSpacing.verticalGapS,
        ...displayInvitations
            .map(
              (inv) => _InvitationRow(
                invitation: inv,
                onResend: onResend,
                onRevoke: onRevoke,
              ),
            )
            .toList(),
      ],
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

// ---------------------------------------------------------------------------
// Donut chart summarising invitation status breakdown
// ---------------------------------------------------------------------------

class _StatusDonutChart extends StatefulWidget {
  const _StatusDonutChart({required this.invitations});

  final List<Invitation> invitations;

  @override
  State<_StatusDonutChart> createState() => _StatusDonutChartState();
}

class _StatusDonutChartState extends State<_StatusDonutChart> {
  int _touchedIndex = -1;

  static const _labelStyle = TextStyle(fontSize: 11, color: Colors.black54);

  @override
  Widget build(BuildContext context) {
    final counts = <InvitationStatus, int>{};
    for (final inv in widget.invitations) {
      counts[inv.status] = (counts[inv.status] ?? 0) + 1;
    }

    final total = widget.invitations.length;
    final sections = _buildSections(counts, total);

    if (sections.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Column(
        children: [
          // Centred donut with total count in the hole
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex =
                              response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    sections: sections,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'invited',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          // Horizontally centred legend
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.m,
            runSpacing: 4,
            children: InvitationStatus.values.map((status) {
              final count = counts[status] ?? 0;
              if (count == 0) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${status.displayName} ($count)',
                    style: _labelStyle,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
    Map<InvitationStatus, int> counts,
    int total,
  ) {
    if (total == 0) return [];
    final entries = counts.entries.toList();
    return List.generate(entries.length, (i) {
      final status = entries[i].key;
      final count = entries[i].value;
      final isTouched = i == _touchedIndex;
      final pct = count / total * 100;
      return PieChartSectionData(
        color: _statusColor(status),
        value: count.toDouble(),
        title: isTouched ? '${pct.toStringAsFixed(0)}%' : '',
        radius: isTouched ? 32 : 26,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
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
