import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nonna_app/core/themes/onboarding_theme.dart';

/// Relationship options for batch invite rows (Phase 1e).
const kOnboardingRelationshipOptions = [
  'Wife',
  'Husband',
  'Grandma',
  'Grandpa',
  'Aunt',
  'Uncle',
  'Godmother',
  'Godfather',
  'Family Friend',
];

class OnboardingInviteRow extends StatelessWidget {
  const OnboardingInviteRow({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.relationship,
    required this.onRelationshipChanged,
    this.showOwnerBadge = false,
    this.onRemove,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final String relationship;
  final ValueChanged<String> onRelationshipChanged;
  final bool showOwnerBadge;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: showOwnerBadge
              ? OnboardingColors.peachDark
              : OnboardingColors.border,
        ),
        color: showOwnerBadge
            ? OnboardingColors.peachTint.withValues(alpha: 0.35)
            : OnboardingColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Invitee',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: OnboardingColors.text,
                  ),
                ),
              ),
              if (showOwnerBadge)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: OnboardingColors.peachTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Co-owner',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: OnboardingColors.peachDark,
                    ),
                  ),
                ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: 18),
                  color: OnboardingColors.muted,
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Email'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: relationship,
            decoration: const InputDecoration(hintText: 'Relationship'),
            items: kOnboardingRelationshipOptions
                .map(
                  (r) => DropdownMenuItem(value: r, child: Text(r)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onRelationshipChanged(value);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            readOnly: true,
            enabled: false,
            decoration: InputDecoration(
              hintText: 'Phone (coming soon)',
              hintStyle: GoogleFonts.inter(color: OnboardingColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
