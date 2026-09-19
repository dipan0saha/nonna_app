import 'package:flutter/material.dart';

import 'package:nonna_app/core/themes/nonna_theme_extension.dart';

/// Expecting-home hero card with countdown (#40).
class FirstRunHeroCard extends StatelessWidget {
  const FirstRunHeroCard({
    super.key,
    required this.babyName,
    required this.daysToDue,
    this.onAnnounceArrival,
    this.onInviteTap,
  });

  final String babyName;
  final int? daysToDue;
  final VoidCallback? onAnnounceArrival;
  final VoidCallback? onInviteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nonna = context.nonnaTheme;
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [nonna.sageTint, cs.surface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waiting for $babyName',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (daysToDue != null) ...[
            Text(
              '$daysToDue',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 36,
                color: nonna.sageDark,
              ),
            ),
            Text(
              'Days to due date',
              style: theme.textTheme.bodySmall?.copyWith(
                color: nonna.muted,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (onAnnounceArrival != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onAnnounceArrival,
                child: const Text('Announce Arrival'),
              ),
            ),
          if (onInviteTap != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onInviteTap,
                child: const Text('Invite family'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Born-home welcome banner (#48).
class FirstRunWelcomeBanner extends StatelessWidget {
  const FirstRunWelcomeBanner({super.key, required this.babyName});

  final String babyName;

  @override
  Widget build(BuildContext context) {
    final nonna = context.nonnaTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: nonna.peachTint.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: nonna.peachDark.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Baby $babyName is here!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick action row for follower first-run home (#40, #49).
class FollowerFirstRunQuickActions extends StatelessWidget {
  const FollowerFirstRunQuickActions({
    super.key,
    required this.isBorn,
    this.onVoteTap,
    this.onGalleryTap,
  });

  final bool isBorn;
  final VoidCallback? onVoteTap;
  final VoidCallback? onGalleryTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isBorn ? onGalleryTap : onVoteTap,
              child: Text(isBorn ? 'View Gallery' : 'Vote in Fun'),
            ),
          ),
          if (!isBorn) ...[
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: onGalleryTap,
                child: const Text('View Gallery'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Family insight / recent activity empty state for first-run home.
class FirstRunEmptyInsightCard extends StatelessWidget {
  const FirstRunEmptyInsightCard({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nonna = context.nonnaTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: nonna.muted,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
