import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/constants/onboarding_integration_keys.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/core/services/deep_link_service.dart';
import 'package:nonna_app/core/utils/invitation_link_helpers.dart';

import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_integration_helpers.dart';

/// Follower invite deep-link path helpers (#21, #54).
void main() {
  test('follower invite deep link includes token query param', () {
    const token = 'qa-follower-token';
    final route = onboardingInviteAcceptRouteForToken(token);
    expect(route, contains('token=$token'));
    expect(route, startsWith(AppRoutes.inviteAccept));
  });

  test('co-owner invite URL uses owner invited role', () {
    const token = 'qa-coowner-token';
    final url = InvitationLinkHelpers.buildInviteAcceptUrl(
      token,
      invitedRole: UserRole.owner,
    );
    final route = DeepLinkService.normalizeToRoute(Uri.parse(url));
    expect(route, '${AppRoutes.inviteAccept}?token=$token&role=owner');
  });

  test('wrong-email screen key is stable for integration harness', () {
    expect(
      OnboardingIntegrationKeys.wrongEmailScreen,
      const Key('onboarding_wrong_email_screen'),
    );
  });
}
