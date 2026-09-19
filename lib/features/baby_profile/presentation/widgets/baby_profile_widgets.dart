import 'package:flutter/material.dart';

import 'package:nonna_app/core/themes/nonna_theme_extension.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/baby_membership.dart';
import 'package:nonna_app/core/models/baby_profile.dart';

/// Card displaying a baby profile summary (name, gender icon, birth status).
class BabyProfileCard extends StatelessWidget {
  const BabyProfileCard({
    super.key,
    required this.profile,
  });

  final BabyProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('baby_profile_card'),
      elevation: 2,
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: profile.gender.color.withValues(alpha: 0.2),
              child: Icon(
                profile.gender.icon,
                color: profile.gender.color,
              ),
            ),
            AppSpacing.horizontalGapM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  AppSpacing.verticalGapXS,
                  Text(
                    profile.isBorn
                        ? 'Born ${_formatDate(profile.actualBirthDate!)}'
                        : profile.expectedBirthDate != null
                            ? 'Due ${_formatDate(profile.expectedBirthDate!)}'
                            : 'Birth date unknown',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Row widget representing a single membership with optional remove action.
class FollowerListItem extends StatelessWidget {
  const FollowerListItem({
    super.key,
    required this.membership,
    this.onRemove,
  });

  final BabyMembership membership;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('follower_list_item_${membership.userId}'),
      leading: CircleAvatar(
        backgroundColor: context.nonnaTheme.sageTint,
        child: Icon(Icons.person, color: context.nonnaTheme.sageDark),
      ),
      title: Text(membership.displayName ?? membership.userId),
      subtitle: membership.relationshipLabel != null
          ? Text(membership.relationshipLabel!)
          : null,
      trailing: onRemove != null
          ? IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: 'Remove follower',
              onPressed: onRemove,
            )
          : null,
    );
  }
}

/// Dialog for confirming baby profile deletion.
class DeleteProfileDialog {
  const DeleteProfileDialog._();

  /// Shows the delete confirmation dialog.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Profile'),
        content: const Text(
          'Are you sure you want to delete this baby profile? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
