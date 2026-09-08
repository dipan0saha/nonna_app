import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nonna_app/core/themes/onboarding_theme.dart';

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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [OnboardingColors.sageTint, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waiting for $babyName',
            style: GoogleFonts.baloo2(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: OnboardingColors.text,
            ),
          ),
          const SizedBox(height: 8),
          if (daysToDue != null) ...[
            Text(
              '$daysToDue',
              style: GoogleFonts.baloo2(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: OnboardingColors.sageDark,
              ),
            ),
            Text(
              'Days to due date',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: OnboardingColors.muted,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: OnboardingColors.sage,
                  foregroundColor: OnboardingColors.primaryButtonText,
                ),
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OnboardingColors.peachTint.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: OnboardingColors.peachDark.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Baby $babyName is here!',
              style: GoogleFonts.baloo2(
                fontSize: 18,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: OnboardingColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: OnboardingColors.muted,
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
