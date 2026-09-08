import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nonna_app/core/constants/onboarding_integration_keys.dart';
import 'package:nonna_app/core/themes/onboarding_theme.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/invite_accept_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/shared/onboarding_invite_expired_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_invite_helpers.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_coowner_helpers.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Co-owner invite landing — prototype copy + owner privileges reassurance.
class OnboardingCoOwnerInviteScreen extends ConsumerStatefulWidget {
  const OnboardingCoOwnerInviteScreen({super.key});

  @override
  ConsumerState<OnboardingCoOwnerInviteScreen> createState() =>
      _OnboardingCoOwnerInviteScreenState();
}

class _OnboardingCoOwnerInviteScreenState
    extends ConsumerState<OnboardingCoOwnerInviteScreen> {
  @override
  void initState() {
    super.initState();
    scheduleInvitePreviewLoad(
      WidgetsBinding.instance,
      () => ensureInvitePreviewLoaded(
        ref,
        fallbackPath: OnboardingPath.coOwner,
      ),
    );
  }

  Future<void> _dismissInvite(BuildContext context) async {
    await ref
        .read(onboardingCoordinatorProvider.notifier)
        .dismissPendingInvite();
    if (context.mounted) context.go(OnboardingRoutes.ownerCarousel);
  }

  @override
  Widget build(BuildContext context) {
    final inviteState = ref.watch(inviteAcceptProvider);

    if (inviteState.status == InviteAcceptStatus.loading ||
        inviteState.status == InviteAcceptStatus.idle) {
      return const OnboardingScaffold(
        showBack: false,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (inviteState.status == InviteAcceptStatus.expired) {
      return const OnboardingInviteExpiredScreen();
    }

    if (inviteState.status == InviteAcceptStatus.notFound ||
        inviteState.status == InviteAcceptStatus.error) {
      return OnboardingInviteExpiredScreen(
        message: inviteState.error ??
            'We could not find this invitation. Check the link and try again.',
      );
    }

    final babyName = inviteState.babyName ?? 'Baby';
    final inviterName = inviteState.inviterName ?? 'A family member';

    return OnboardingScaffold(
      showBack: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 22),
          Text(
            '$inviterName invited you to co-own',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: OnboardingColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: OnboardingColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: OnboardingColors.peachDark.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                const Text('👶', style: TextStyle(fontSize: 42)),
                const SizedBox(height: 10),
                Text(
                  babyName,
                  style: GoogleFonts.baloo2(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: OnboardingColors.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: OnboardingColors.sageDark,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'As a co-owner, you\'ll have full access to edit, invite, and manage, just like $inviterName.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: OnboardingColors.muted,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OnboardingPrimaryButton(
            buttonKey: OnboardingIntegrationKeys.coOwnerInviteAccept,
            label: 'Accept & Join as Owner',
            onPressed: () => navigateFromCoOwnerInviteAccept(
              ref: ref,
              context: context,
            ),
          ),
          OnboardingBottomLink(
            prefix: '',
            actionLabel: 'Not who this was meant for?',
            onTap: () => _dismissInvite(context),
          ),
        ],
      ),
    );
  }
}
