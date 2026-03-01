import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';

/// Role selection screen shown to first-time users after sign-up.
///
/// **Functional Requirements**: Section 3.6.1 - Authentication Screens
/// Reference: docs/Core_development_component_identification.md
///
/// Users choose whether to:
///   - Create a new baby profile (owner / primary caregiver)
///   - Follow / join an existing baby profile (family / friend)
///
/// Navigation is handled via callbacks so the screen remains testable
/// without a router.
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({
    super.key,
    this.onCreateProfile,
    this.onJoinProfile,
    this.onSkip,
  });

  /// Called when the user chooses to create a new baby profile.
  final VoidCallback? onCreateProfile;

  /// Called when the user chooses to join an existing profile.
  final VoidCallback? onJoinProfile;

  /// Called when the user wants to skip onboarding for now.
  final VoidCallback? onSkip;

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  _Role? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Getting Started'),
        automaticallyImplyLeading: false,
        actions: [
          if (widget.onSkip != null)
            TextButton(
              key: const Key('skip_button'),
              onPressed: widget.onSkip,
              child: const Text('Skip'),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.child_friendly,
                size: 72,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'How will you use nonna?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your role to personalise your experience',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 40),

              // Role cards
              _RoleCard(
                cardKey: const Key('create_profile_card'),
                role: _Role.create,
                selectedRole: _selectedRole,
                icon: Icons.add_circle_outline,
                title: 'Create a Baby Profile',
                description:
                    'I\'m a parent or primary caregiver and want to create '
                    'a new profile to track milestones.',
                onTap: () => setState(() => _selectedRole = _Role.create),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                cardKey: const Key('join_profile_card'),
                role: _Role.join,
                selectedRole: _selectedRole,
                icon: Icons.group_outlined,
                title: 'Follow an Existing Profile',
                description:
                    'I\'m a family member or friend and want to follow '
                    'an existing baby\'s milestones.',
                onTap: () => setState(() => _selectedRole = _Role.join),
              ),

              const SizedBox(height: 24),

              // Continue button
              ElevatedButton(
                key: const Key('continue_button'),
                onPressed: _selectedRole == null ? null : _handleContinue,
                child: const Text('Continue'),
              ),

              const SizedBox(height: 12),

              // Sign out link
              Center(
                child: TextButton(
                  key: const Key('sign_out_button'),
                  onPressed: () => ref.read(authProvider.notifier).signOut(),
                  child: const Text('Sign out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    switch (_selectedRole) {
      case _Role.create:
        widget.onCreateProfile?.call();
      case _Role.join:
        widget.onJoinProfile?.call();
      case null:
        break;
    }
  }
}

// ============================================================
// Internal helpers
// ============================================================

enum _Role { create, join }

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.cardKey,
    required this.role,
    required this.selectedRole,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final Key cardKey;
  final _Role role;
  final _Role? selectedRole;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  bool get _isSelected => selectedRole == role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        key: cardKey,
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isSelected ? AppColors.primaryPale : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isSelected ? AppColors.primary : AppColors.border,
            width: _isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: _isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: _isSelected ? AppColors.primary : AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
