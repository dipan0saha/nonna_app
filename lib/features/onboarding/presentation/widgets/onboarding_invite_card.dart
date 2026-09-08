import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nonna_app/core/themes/onboarding_theme.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';

class OnboardingInviteCard extends StatelessWidget {
  const OnboardingInviteCard({
    super.key,
    required this.babyName,
    required this.inviterName,
    required this.isCoOwner,
    required this.onAccept,
    this.onDismiss,
  });

  final String babyName;
  final String inviterName;
  final bool isCoOwner;
  final VoidCallback onAccept;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCoOwner
                  ? [OnboardingColors.peachTint, OnboardingColors.surface]
                  : [OnboardingColors.sageTint, OnboardingColors.surface],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isCoOwner
                  ? OnboardingColors.peachDark
                  : OnboardingColors.sageTint,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCoOwner ? 'Co-own with $inviterName' : 'Join $babyName',
                style: GoogleFonts.baloo2(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: OnboardingColors.text,
                ),
              ),
              const SizedBox(height: 8),
              OnboardingSupportText(
                isCoOwner
                    ? '$inviterName invited you to co-own $babyName\'s private family space.'
                    : '$inviterName invited you to follow $babyName\'s journey privately.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OnboardingPrimaryButton(
          label: 'Accept Invitation',
          onPressed: onAccept,
        ),
        if (onDismiss != null) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: onDismiss,
              child: Text(
                'Not who this was meant for?',
                style: GoogleFonts.inter(
                  color: OnboardingColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
