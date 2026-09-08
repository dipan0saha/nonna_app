import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:nonna_app/core/constants/onboarding_integration_keys.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_integration_helpers.dart';

import 'test_helper.dart';

/// Shared helpers for onboarding integration tests (#54).
class OnboardingIntegrationHelpers {
  static const ownerCarouselHeadline =
      "Your baby's story, in one private place";
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding integration — owner cold start', () {
    testWidgets('lands on owner carousel with primary CTA', (tester) async {
      await startApp(tester);

      expect(
        find.text(OnboardingIntegrationHelpers.ownerCarouselHeadline),
        findsOneWidget,
      );
      expect(
        find.byKey(OnboardingIntegrationKeys.ownerCarouselPrimary),
        findsOneWidget,
      );
    });
  });

  group('Onboarding integration — deep link', () {
    test('invite URL normalizes to invite-accept route', () {
      const token = 'preview-token-123';
      final route = onboardingInviteAcceptRouteForToken(token);
      expect(route, '${AppRoutes.inviteAccept}?token=$token');
    });
  });
}
