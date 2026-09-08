import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Shown when an invite token is invalid, revoked, or expired (Gap #43).
class OnboardingInviteExpiredScreen extends ConsumerWidget {
  const OnboardingInviteExpiredScreen({
    super.key,
    this.message =
        'This invitation is no longer valid. It may have expired or already been used.',
  });

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardingScaffold(
      showBack: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),
          Icon(
            Icons.link_off_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 24),
          Text(
            'Invitation unavailable',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          OnboardingPrimaryButton(
            label: 'Get started',
            onPressed: () => context.go(OnboardingRoutes.ownerCarousel),
          ),
        ],
      ),
    );
  }
}
