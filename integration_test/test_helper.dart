import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/main.dart' as app;
import 'package:nonna_app/core/services/app_initialization_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String kIntegrationTestEmail = 'testuser_nonna@example.com';
const String kIntegrationTestPassword = 'Password123!';

/// Helper to start the app for integration tests.
Future<void> startApp(WidgetTester tester) async {
  debugPrint('Starting AppInitializationService.initialize()...');
  final result = await AppInitializationService.initialize();

  await tester.pumpWidget(const ProviderScope(child: app.MyApp()));
  await tester.pumpAndSettle();

  if (!result.success) {
    debugPrint('Initialization failed: ${result.criticalError}');
  }
}

/// Helper to sign in only when the login form is present.
Future<void> signInIfNeeded(WidgetTester tester) async {
  final signInBtn = find.byKey(const Key('sign_in_button'));
  if (signInBtn.evaluate().isNotEmpty) {
    debugPrint('Not logged in, signing in first...');
    await tester.enterText(
      find.byKey(const Key('auth_email_field')),
      kIntegrationTestEmail,
    );
    await tester.enterText(
      find.byKey(const Key('auth_password_field')),
      kIntegrationTestPassword,
    );
    await tester.tap(signInBtn);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }
}

/// Helper to start the app and ensure user is logged in for integration tests.
Future<void> startAppAndLogin(WidgetTester tester) async {
  await startApp(tester);
  await signInIfNeeded(tester);
}
