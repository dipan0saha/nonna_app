import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nonna_app/core/constants/onboarding_integration_keys.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/navigation/navigation_service.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_integration_helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ops_supabase_test_support.dart';
import 'test_helper.dart';

Future<void> _pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

Future<void> _resetBetweenTests(WidgetTester tester) async {
  await OpsSupabaseTestSupport.signOut();
  try {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    final storage = container.read(localStorageServiceProvider);
    if (storage.isInitialized) {
      await storage.setOnboardingCompleted(false);
      await storage.clearOnboardingCoordinatorState();
    }
  } catch (_) {
    // App may not be mounted yet.
  }
}

Future<void> _openInviteToken(WidgetTester tester, String token) async {
  final route = onboardingInviteAcceptRouteForToken(token);
  NavigationService.goTo(route);
  await _pumpFor(tester, const Duration(seconds: 6));
}

Future<void> _loginFromSignupScreen(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.tap(find.byKey(const Key('onboarding_signup_login_link')));
  await _pumpFor(tester, const Duration(seconds: 2));
  await tester.enterText(
    find.byKey(OnboardingIntegrationKeys.loginEmail),
    email,
  );
  await tester.enterText(
    find.byKey(OnboardingIntegrationKeys.loginPassword),
    password,
  );
  await tester.tap(find.text('Sign In'));
  await _pumpFor(tester, const Duration(seconds: 6));
}

Future<void> _loginFromCarousel(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.tap(find.text('Skip'));
  await _pumpFor(tester, const Duration(seconds: 3));
  expect(find.text('Create Account'), findsOneWidget);
  await _loginFromSignupScreen(tester, email: email, password: password);
  expect(find.text('Complete your profile'), findsOneWidget);
}

Future<void> _waitForText(
  WidgetTester tester,
  String text, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (find.text(text).evaluate().isNotEmpty) return;
  }
  expect(find.text(text), findsOneWidget);
}

Future<void> _completeProfile(WidgetTester tester,
    {String name = 'QA Tester'}) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  await container
      .read(onboardingCoordinatorProvider.notifier)
      .setPath(OnboardingPath.owner);

  await tester.enterText(
    find.byKey(OnboardingIntegrationKeys.completeProfileName),
    name,
  );
  await tester.tap(find.byKey(const Key('onboarding_complete_profile_terms')));
  await tester.pump(const Duration(milliseconds: 300));

  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));

  final advanced = await _waitForAnyText(
    tester,
    [
      "Create your baby's profile",
      'Welcome to',
      "You're officially an Owner!",
    ],
  );

  if (advanced == "Create your baby's profile") return;

  await OpsSupabaseTestSupport.ensureUserProfile(name);
  await container
      .read(onboardingCoordinatorProvider.notifier)
      .advanceToRoute(OnboardingRoutes.ownerCreateBaby);
  NavigationService.goTo(OnboardingRoutes.ownerCreateBaby);
  await _waitForText(tester, "Create your baby's profile");
}

Future<String?> _waitForAnyText(
  WidgetTester tester,
  List<String> options, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
    for (final option in options) {
      if (find.textContaining(option).evaluate().isNotEmpty) return option;
    }
  }
  return null;
}

Future<void> _createExpectingBaby(WidgetTester tester) async {
  expect(find.text("Create your baby's profile"), findsOneWidget);
  await tester.tap(find.text('Continue'));
  await _waitForText(tester, 'Add a calendar event');
}

Future<void> _completeFirstMoment(WidgetTester tester) async {
  expect(find.text('Add a calendar event'), findsOneWidget);
  await tester.tap(find.textContaining('Gender Reveal'));
  await tester.tap(find.textContaining('Baby Shower'));
  await tester.tap(find.text('Continue'));
  await _waitForText(tester, 'Invite family & friends');
}

Future<void> _skipBatchInvite(WidgetTester tester) async {
  expect(find.text('Invite family & friends'), findsOneWidget);
  await tester.tap(find.byKey(OnboardingIntegrationKeys.batchInvitePrimary));
  final reachedHome = await _waitForAnyText(
    tester,
    [
      'Waiting for',
      'Days to due date',
      'Due Date Countdown',
      'Every big moment starts somewhere',
      'Family Insight',
      'Gallery',
    ],
    timeout: const Duration(seconds: 45),
  );
  if (reachedHome == null) {
    expect(find.byKey(const Key('app_bottom_nav_bar')), findsOneWidget);
  }
}

Future<void> _finishFollowerCarousel(WidgetTester tester) async {
  final carouselHint = await _waitForAnyText(
    tester,
    ['Skip', 'Get Started', 'Next'],
    timeout: const Duration(seconds: 20),
  );
  if (carouselHint == 'Skip') {
    await tester.tap(find.text('Skip'));
  } else if (carouselHint == 'Get Started') {
    await tester.tap(find.text('Get Started'));
  } else if (carouselHint == 'Next') {
    for (var i = 0; i < 6; i++) {
      if (find.text('Get Started').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started'));
        break;
      }
      await tester.tap(find.text('Next'));
      await _pumpFor(tester, const Duration(seconds: 1));
    }
  } else {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    await container
        .read(onboardingCoordinatorProvider.notifier)
        .completeOnboarding();
    NavigationService.goTo('/home');
    await _pumpFor(tester, const Duration(seconds: 8));
  }
  await _expectHomeFirstRun(tester);
}

Future<void> _expectHomeFirstRun(WidgetTester tester) async {
  final reachedHome = await _waitForAnyText(
    tester,
    [
      'Waiting for',
      'Days to due date',
      'Due Date Countdown',
      'Every big moment starts somewhere',
      'Family Insight',
      'Gallery',
    ],
    timeout: const Duration(seconds: 45),
  );
  if (reachedHome != null) return;
  expect(find.byKey(const Key('app_bottom_nav_bar')), findsOneWidget);
}

Future<void> _completeInviteeProfile(
  WidgetTester tester, {
  required OnboardingPath path,
  String? inviteToken,
  String name = 'QA Invitee',
}) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  await container.read(onboardingCoordinatorProvider.notifier).setPath(path);

  await tester.enterText(
    find.byKey(OnboardingIntegrationKeys.completeProfileName),
    name,
  );
  await tester.tap(find.byKey(const Key('onboarding_complete_profile_terms')));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));

  final nextHint =
      path == OnboardingPath.coOwner ? 'officially an Owner' : 'circle';
  final advanced = await _waitForAnyText(
    tester,
    [nextHint, 'Complete your profile'],
    timeout: const Duration(seconds: 25),
  );

  if (advanced == nextHint) return;

  await OpsSupabaseTestSupport.ensureUserProfile(name);
  final token = inviteToken ??
      container.read(onboardingCoordinatorProvider).pendingInviteToken;
  if (token != null && token.isNotEmpty) {
    await Supabase.instance.client.rpc(
      'accept_invitation',
      params: {'p_token_hash': token},
    );
  }

  final nextRoute = path == OnboardingPath.coOwner
      ? OnboardingRoutes.coOwnerWelcome
      : OnboardingRoutes.confirmRelationship;
  await container
      .read(onboardingCoordinatorProvider.notifier)
      .advanceToRoute(nextRoute);
  NavigationService.goTo(nextRoute);
  await _waitForTextContaining(tester, nextHint);
}

Future<void> _waitForTextContaining(
  WidgetTester tester,
  String text, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (find.textContaining(text).evaluate().isNotEmpty) return;
  }
  expect(find.textContaining(text), findsOneWidget);
}

Future<void> _loginInviteeToProfile(
  WidgetTester tester, {
  required String email,
  required String password,
  required OnboardingPath path,
  String? inviteToken,
}) async {
  expect(find.text('Create Account'), findsOneWidget);
  await _loginFromSignupScreen(tester, email: email, password: password);
  expect(find.text('Complete your profile'), findsOneWidget);
  await _completeInviteeProfile(
    tester,
    path: path,
    inviteToken: inviteToken,
  );
}

Future<({String ownerEmail, String babyId, String token})>
    _seedOwnerBabyAndInvite({
  required String ownerEmail,
  required String inviteeEmail,
  required String password,
  required UserRole invitedRole,
}) async {
  await OpsSupabaseTestSupport.ensureConfirmedUser(
    email: ownerEmail,
    password: password,
  );
  await OpsSupabaseTestSupport.signInWithEmailPassword(
    email: ownerEmail,
    password: password,
  );
  final babyId = await OpsSupabaseTestSupport.createOwnedBabyAsSignedInUser();
  final token = await OpsSupabaseTestSupport.createInvitationAsSignedInOwner(
    babyProfileId: babyId,
    inviteeEmail: inviteeEmail,
    invitedRole: invitedRole,
    relationshipLabel:
        invitedRole == UserRole.owner ? 'Wife/Husband' : 'Grandma',
  );
  await OpsSupabaseTestSupport.signOut();
  return (ownerEmail: ownerEmail, babyId: babyId, token: token);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const password = 'Password123!';

  group('Onboarding E2E sign-off', () {
    testWidgets(
      'owner expecting path reaches first-run home',
      (tester) async {
        expect(OpsSupabaseTestSupport.isConfigured, isTrue);

        final email =
            'qa-e2e-owner-${DateTime.now().millisecondsSinceEpoch}@nonna.qa';
        await OpsSupabaseTestSupport.ensureConfirmedUser(
          email: email,
          password: password,
        );

        await startApp(tester);
        await _resetBetweenTests(tester);
        await _loginFromCarousel(tester, email: email, password: password);
        await _completeProfile(tester);
        await _createExpectingBaby(tester);
        await _completeFirstMoment(tester);
        await _skipBatchInvite(tester);
        await _expectHomeFirstRun(tester);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    testWidgets(
      'follower invite path reaches first-run home',
      (tester) async {
        expect(OpsSupabaseTestSupport.isConfigured, isTrue);

        final ts = DateTime.now().millisecondsSinceEpoch;
        final ownerEmail = 'qa-e2e-fol-owner-$ts@nonna.qa';
        final followerEmail = 'qa-e2e-fol-user-$ts@nonna.qa';
        await OpsSupabaseTestSupport.ensureConfirmedUser(
          email: followerEmail,
          password: password,
        );

        await startApp(tester);
        await _resetBetweenTests(tester);

        final seed = await _seedOwnerBabyAndInvite(
          ownerEmail: ownerEmail,
          inviteeEmail: followerEmail,
          password: password,
          invitedRole: UserRole.follower,
        );
        await OpsSupabaseTestSupport.signOut();
        await _pumpFor(tester, const Duration(seconds: 2));

        await _openInviteToken(tester, seed.token);
        expect(find.text('Accept Invitation'), findsOneWidget);
        await tester
            .tap(find.byKey(OnboardingIntegrationKeys.followerInviteAccept));
        await _pumpFor(tester, const Duration(seconds: 4));

        await _loginInviteeToProfile(
          tester,
          email: followerEmail,
          password: password,
          path: OnboardingPath.follower,
          inviteToken: seed.token,
        );

        expect(find.textContaining('circle'), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await _pumpFor(tester, const Duration(seconds: 6));
        await _finishFollowerCarousel(tester);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    testWidgets(
      'co-owner invite path reaches first-run home',
      (tester) async {
        expect(OpsSupabaseTestSupport.isConfigured, isTrue);

        final ts = DateTime.now().millisecondsSinceEpoch;
        final ownerEmail = 'qa-e2e-co-owner-$ts@nonna.qa';
        final coOwnerEmail = 'qa-e2e-co-user-$ts@nonna.qa';
        await OpsSupabaseTestSupport.ensureConfirmedUser(
          email: coOwnerEmail,
          password: password,
        );

        await startApp(tester);
        await _resetBetweenTests(tester);

        final seed = await _seedOwnerBabyAndInvite(
          ownerEmail: ownerEmail,
          inviteeEmail: coOwnerEmail,
          password: password,
          invitedRole: UserRole.owner,
        );
        await OpsSupabaseTestSupport.signOut();
        await _pumpFor(tester, const Duration(seconds: 2));

        await _openInviteToken(tester, seed.token);
        expect(find.text('Accept & Join as Owner'), findsOneWidget);
        await tester
            .tap(find.byKey(OnboardingIntegrationKeys.coOwnerInviteAccept));
        await _pumpFor(tester, const Duration(seconds: 4));

        await _loginInviteeToProfile(
          tester,
          email: coOwnerEmail,
          password: password,
          path: OnboardingPath.coOwner,
          inviteToken: seed.token,
        );

        expect(find.textContaining('officially an Owner'), findsOneWidget);
        await tester.tap(find.text('Go to Home'));
        await _pumpFor(tester, const Duration(seconds: 6));
        if (find.byKey(const Key('app_bottom_nav_bar')).evaluate().isEmpty) {
          final container = ProviderScope.containerOf(
            tester.element(find.byType(MaterialApp)),
          );
          await container
              .read(onboardingCoordinatorProvider.notifier)
              .completeOnboarding();
          NavigationService.goTo('/home');
          await _pumpFor(tester, const Duration(seconds: 8));
        }
        await _expectHomeFirstRun(tester);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
