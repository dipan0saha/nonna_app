import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nonna_app/core/navigation/navigation_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nonna_app/core/constants/onboarding_integration_keys.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';

import 'ops_supabase_test_support.dart';
import 'test_helper.dart';

Future<void> _pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

Future<void> _goToRoute(WidgetTester tester, String route) async {
  await _pumpFor(tester, const Duration(seconds: 2));
  NavigationService.goTo(route);
  await _pumpFor(tester, const Duration(seconds: 2));
}

Future<void> _openBatchInviteForBaby(
  WidgetTester tester,
  String babyProfileId,
) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  final coordinator = container.read(onboardingCoordinatorProvider.notifier);
  await coordinator.setPath(OnboardingPath.owner);
  await coordinator.setBabyStatus(BabyStatus.expecting);
  await coordinator.setCreatedBabyProfileId(babyProfileId);
  await coordinator.goToStep(OnboardingStep.batchInvite);
  NavigationService.goTo(OnboardingRoutes.ownerInvite);
  await _pumpFor(tester, const Duration(seconds: 4));
}

Future<void> _confirmEmailWithOtp(String email) async {
  final otp = await OpsSupabaseTestSupport.signupEmailOtp(email);
  await Supabase.instance.client.auth.verifyOTP(
    type: OtpType.signup,
    email: email,
    token: otp,
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const password = 'Password123!';

  group('OPS emulator sign-off', () {
    testWidgets('OPS-010 email confirm deep link advances past verify screen',
        (tester) async {
      expect(
        OpsSupabaseTestSupport.isConfigured,
        isTrue,
        reason:
            'Pass SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY via --dart-define',
      );

      final ownerEmail =
          'qa-ops-010-${DateTime.now().millisecondsSinceEpoch}@nonna.qa';

      await OpsSupabaseTestSupport.ensureUnconfirmedUser(
        email: ownerEmail,
        password: password,
      );

      await startApp(tester);

      await _goToRoute(tester, OnboardingRoutes.emailVerify);

      expect(find.text('Check your email'), findsOneWidget);

      await OpsSupabaseTestSupport.signupEmailOtp(ownerEmail);
      await _confirmEmailWithOtp(ownerEmail);
      await _pumpFor(tester, const Duration(seconds: 5));

      expect(find.text('Complete your profile'), findsOneWidget);
    });

    testWidgets('OPS-P1-012 batch invite skips existing member email', (
      tester,
    ) async {
      expect(OpsSupabaseTestSupport.isConfigured, isTrue);

      final ts = DateTime.now().millisecondsSinceEpoch;
      final ownerEmail = 'qa-ops-012-owner-$ts@nonna.qa';
      final followerEmail = 'qa-ops-012-follower-$ts@nonna.qa';

      await OpsSupabaseTestSupport.ensureConfirmedUser(
        email: ownerEmail,
        password: password,
      );
      await OpsSupabaseTestSupport.ensureConfirmedUser(
        email: followerEmail,
        password: password,
      );

      await startApp(tester);

      await tester.tap(find.text('Skip'));
      await _pumpFor(tester, const Duration(seconds: 3));
      expect(find.text('Create Account'), findsOneWidget);
      await tester.tap(find.byKey(const Key('onboarding_signup_login_link')));
      await _pumpFor(tester, const Duration(seconds: 2));
      await tester.enterText(
        find.byKey(const Key('onboarding_login_email')),
        ownerEmail,
      );
      await tester.enterText(
        find.byKey(const Key('onboarding_login_password')),
        password,
      );
      await tester.tap(find.text('Sign In'));
      await _pumpFor(tester, const Duration(seconds: 6));

      final babyId =
          await OpsSupabaseTestSupport.createOwnedBabyAsSignedInUser();
      await _openBatchInviteForBaby(tester, babyId);

      expect(find.text('Invite family & friends'), findsOneWidget);

      final followerId =
          await OpsSupabaseTestSupport.userIdForEmail(followerEmail);
      await OpsSupabaseTestSupport.insertFollowerMembership(
        babyProfileId: babyId,
        followerUserId: followerId,
      );

      final emailFields = find.byType(TextField);
      expect(emailFields, findsWidgets);
      await tester.enterText(emailFields.at(1), followerEmail);
      await tester
          .tap(find.byKey(OnboardingIntegrationKeys.batchInvitePrimary));
      await _pumpFor(tester, const Duration(seconds: 6));

      expect(find.text('Already a member'), findsOneWidget);
    });
  });
}
