import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/constants/onboarding_integration_keys.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/main.dart' as app;
import 'package:nonna_app/core/services/app_initialization_service.dart';

const String kIntegrationTestEmail = 'testuser_nonna@example.com';
const String kIntegrationTestPassword = 'Password123!';

/// Helper to start the app for integration tests.
Future<void> startApp(WidgetTester tester) async {
  debugPrint('Starting AppInitializationService.initialize()...');

  // Save the test runner's error handler
  final originalOnError = FlutterError.onError;

  final result = await AppInitializationService.initialize();

  // Restore the test runner's error handler so exceptions don't break the test framework
  FlutterError.onError = originalOnError;

  await tester.pumpWidget(const ProviderScope(child: app.MyApp()));
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }

  // Restore again after first frames — app init may reset the handler.
  FlutterError.onError = originalOnError;

  if (!result.success) {
    debugPrint('Initialization failed: ${result.criticalError}');
  }
}

Future<void> _submitOnboardingLogin(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(OnboardingIntegrationKeys.loginEmail),
    kIntegrationTestEmail,
  );
  await tester.enterText(
    find.byKey(OnboardingIntegrationKeys.loginPassword),
    kIntegrationTestPassword,
  );
  await tester.tap(find.text('Sign In'));
  await tester.pump(const Duration(seconds: 3));
  await _reachHomeAfterAuth(tester);
}

bool _completeProfileAttempted = false;

/// Resets per-test login side effects (call from setUp if needed).
void resetIntegrationLoginState() {
  _completeProfileAttempted = false;
}

ProviderContainer? integrationProviderContainer(WidgetTester tester) {
  final anchors = [
    find.byType(MaterialApp),
    find.byType(Scaffold),
    find.byType(ProviderScope),
  ];
  for (final anchor in anchors) {
    if (anchor.evaluate().isEmpty) continue;
    try {
      return ProviderScope.containerOf(tester.element(anchor.first));
    } catch (_) {
      continue;
    }
  }
  return null;
}

Future<void> _openOnboardingLogin(WidgetTester tester) async {
  appRouter.go(OnboardingRoutes.login);
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (find
        .byKey(OnboardingIntegrationKeys.loginEmail)
        .evaluate()
        .isNotEmpty) {
      return;
    }
  }
  throw TestFailure('Onboarding login form did not appear');
}

Future<void> _tapContinueIfPresent(WidgetTester tester) async {
  final btn = find.text('Continue');
  if (btn.evaluate().isEmpty) return;
  await tester.tap(btn);
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _advanceOwnerOnboardingTail(WidgetTester tester) async {
  final boyName = find.byKey(const Key('onboarding_create_baby_boy_name'));
  if (boyName.evaluate().isNotEmpty) {
    await tester.enterText(boyName, 'QA Integration');
    await tester.pump(const Duration(milliseconds: 300));
    await _tapContinueIfPresent(tester);
    return;
  }

  final girlName = find.byKey(const Key('onboarding_create_baby_girl_name'));
  if (girlName.evaluate().isNotEmpty) {
    await tester.enterText(girlName, 'QA Integration');
    await tester.pump(const Duration(milliseconds: 300));
    await _tapContinueIfPresent(tester);
    return;
  }

  if (find.text('Invite family & friends').evaluate().isNotEmpty) {
    final skipNow = find.text('Skip for now');
    if (skipNow.evaluate().isNotEmpty) {
      await tester.tap(skipNow);
      await tester.pump(const Duration(seconds: 3));
    }
    return;
  }

  if (find.textContaining('First moment').evaluate().isNotEmpty ||
      find
          .byKey(OnboardingIntegrationKeys.firstMomentNameInput)
          .evaluate()
          .isNotEmpty) {
    await _tapContinueIfPresent(tester);
  }
}

/// Returning users with baby memberships can skip the owner tail after profile.
Future<void> _forceHomeForReturningUser(WidgetTester tester) async {
  final container = integrationProviderContainer(tester);
  if (container == null) return;

  try {
    final storage = container.read(localStorageServiceProvider);
    if (!storage.isInitialized) return;

    final hasMemberships = container.read(userHasBabyMembershipsProvider);
    if (!hasMemberships) return;

    await storage.setOnboardingCompleted(true);
    await container
        .read(onboardingCoordinatorProvider.notifier)
        .completeOnboarding();
    appRouter.go('/home');

    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('home_app_bar')).evaluate().isNotEmpty) {
        return;
      }
    }
  } catch (e) {
    debugPrint('forceHomeForReturningUser: $e');
  }
}

Future<void> _reachHomeAfterAuth(WidgetTester tester) async {
  var forcedHome = false;

  for (var i = 0; i < 48; i++) {
    if (find.byKey(const Key('home_app_bar')).evaluate().isNotEmpty) {
      return;
    }

    final nameField = find.byKey(OnboardingIntegrationKeys.completeProfileName);
    if (nameField.evaluate().isNotEmpty) {
      if (_completeProfileAttempted) {
        await tester.pump(const Duration(milliseconds: 500));
        if (!forcedHome && i > 8) {
          forcedHome = true;
          await _forceHomeForReturningUser(tester);
        }
        continue;
      }
      _completeProfileAttempted = true;

      await tester.enterText(nameField, 'Integration Test User');
      await tester.pump(const Duration(milliseconds: 300));
      final agreeRow = find.textContaining('I agree to the');
      if (agreeRow.evaluate().isNotEmpty) {
        await tester.tap(agreeRow);
        await tester.pump(const Duration(milliseconds: 300));
      }
      final continueBtn = find.text('Continue');
      if (continueBtn.evaluate().isNotEmpty) {
        await tester.tap(continueBtn);
        await tester.pump(const Duration(seconds: 2));
      }
      continue;
    }

    await _advanceOwnerOnboardingTail(tester);

    if (!forcedHome && i >= 12) {
      forcedHome = true;
      await _forceHomeForReturningUser(tester);
    }

    await tester.pump(const Duration(milliseconds: 500));
  }

  debugPrint(
    'Login did not reach home — if stuck on complete profile, ensure '
    'testuser has a saved profile or fix Supabase upsert for integration tests.',
  );
}

/// Helper to sign in only when the login form is present.
Future<void> signInIfNeeded(WidgetTester tester) async {
  if (find.byKey(const Key('home_app_bar')).evaluate().isNotEmpty) {
    return;
  }

  final signInBtn = find.byKey(const Key('sign_in_button'));
  if (signInBtn.evaluate().isNotEmpty) {
    debugPrint('Not logged in, signing in via legacy /login...');
    await tester.enterText(
      find.byKey(const Key('auth_email_field')),
      kIntegrationTestEmail,
    );
    await tester.enterText(
      find.byKey(const Key('auth_password_field')),
      kIntegrationTestPassword,
    );
    await tester.tap(signInBtn);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    await _reachHomeAfterAuth(tester);
    return;
  }

  if (find.byKey(OnboardingIntegrationKeys.loginEmail).evaluate().isNotEmpty) {
    debugPrint('Not logged in, signing in via onboarding login...');
    await _submitOnboardingLogin(tester);
    return;
  }

  debugPrint('Not logged in, opening onboarding login route...');
  await _openOnboardingLogin(tester);
  await _submitOnboardingLogin(tester);
}

/// Helper to start the app and ensure user is logged in for integration tests.
Future<void> startAppAndLogin(WidgetTester tester) async {
  resetIntegrationLoginState();
  await startApp(tester);
  await signInIfNeeded(tester);

  for (var i = 0; i < 20; i++) {
    if (find.byKey(const Key('home_app_bar')).evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 500));
  }

  expect(
    find.byKey(const Key('home_app_bar')),
    findsOneWidget,
    reason: 'startAppAndLogin did not reach Home',
  );
}
