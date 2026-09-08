import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_integration_helpers.dart';

void main() {
  test('onboardingInviteAcceptRouteForToken normalizes to invite-accept route',
      () {
    const token = 'preview-token-123';
    expect(
      onboardingInviteAcceptRouteForToken(token),
      '${AppRoutes.inviteAccept}?token=$token',
    );
  });
}
