import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/constants/onboarding_integration_keys.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/invite_accept_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Wrong-email UX when signed-in account ≠ invitee email (#30).
class OnboardingWrongEmailScreen extends ConsumerWidget {
  const OnboardingWrongEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inviteState = ref.watch(inviteAcceptProvider);
    final coordinator = ref.watch(onboardingCoordinatorProvider);
    final inviteeEmail = coordinator.inviteeEmail ??
        inviteState.inviteeEmail ??
        'the invited email';
    final signedInEmail =
        ref.watch(currentAuthUserProvider)?.email ?? 'your current account';

    return OnboardingScaffold(
      key: OnboardingIntegrationKeys.wrongEmailScreen,
      showBack: false,
      bottom: Column(
        children: [
          OnboardingPrimaryButton(
            label: 'Sign out & switch account',
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              await ref
                  .read(onboardingCoordinatorProvider.notifier)
                  .goToStep(OnboardingStep.signup);
              if (context.mounted) {
                context.go(OnboardingRoutes.signupPathFor(coordinator.path));
              }
            },
          ),
          OnboardingBottomLink(
            prefix: '',
            actionLabel: 'Back to invitation',
            onTap: () => context.go(OnboardingRoutes.followerInvite),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const OnboardingHeadline('Different email on this invite'),
          const SizedBox(height: 12),
          OnboardingSupportText(
            'This invitation was sent to $inviteeEmail, but you\'re signed in as $signedInEmail. Sign out and create an account or log in with the invited email to continue.',
          ),
        ],
      ),
    );
  }
}
