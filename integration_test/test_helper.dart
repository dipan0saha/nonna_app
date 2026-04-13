import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/main.dart' as app;
import 'package:nonna_app/core/services/app_initialization_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper to start the app and ensure user is logged in for integration tests.
Future<void> startAppAndLogin(WidgetTester tester) async {
  debugPrint('🚀 Starting AppInitializationService.initialize()...');
  final result = await AppInitializationService.initialize();
  
  await tester.pumpWidget(const ProviderScope(child: app.MyApp()));
  await tester.pumpAndSettle();

  // Handle initialization error
  if (!result.success) {
    debugPrint('❌ Initialization failed: ${result.criticalError}');
  }

  // Ensure we are logged in
  final signInBtn = find.byKey(const Key('sign_in_button'));
  if (signInBtn.evaluate().isNotEmpty) {
    debugPrint('🔑 Not logged in, signing in first...');
    // In a real scenario, we might pull these from env variables 
    // or a secure config, but for integration tests we use the known seed user.
    await tester.enterText(find.byKey(const Key('auth_email_field')), 'seed+10000000@example.local');
    await tester.enterText(find.byKey(const Key('auth_password_field')), 'password123');
    await tester.tap(signInBtn);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }
}
