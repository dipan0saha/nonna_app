import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/invite_accept_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_invite_helpers.dart';

void main() {
  group('onboardingPathForInvitedRole', () {
    test('maps owner to co-owner path', () {
      expect(
        onboardingPathForInvitedRole(UserRole.owner),
        OnboardingPath.coOwner,
      );
    });

    test('maps follower to follower path', () {
      expect(
        onboardingPathForInvitedRole(UserRole.follower),
        OnboardingPath.follower,
      );
    });
  });

  group('resolveInvitePath', () {
    test('uses fallback when preview not found', () {
      const state = InviteAcceptState(status: InviteAcceptStatus.loading);
      expect(
        resolveInvitePath(
          inviteState: state,
          fallbackPath: OnboardingPath.follower,
        ),
        OnboardingPath.follower,
      );
    });
  });
}
