import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nonna_app/main.dart' as app;
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test login with newly created user', (WidgetTester tester) async {
    // Override the environment variable temporarily if needed, 
    // or just type into the text fields.
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Wait for the app to initialize completely
    await tester.pump(const Duration(seconds: 3));
    
    // Find email and password fields. 
    // Need to verify what the keys or semantics are.
    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;
    
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    
    await tester.enterText(emailField, 'testuser_nonna@example.com');
    await tester.pump(const Duration(milliseconds: 500));
    
    await tester.enterText(passwordField, 'Password123!');
    await tester.pump(const Duration(milliseconds: 500));
    
    // Find the login button - might be a text "Sign In" or "Login"
    final loginButton = find.byType(ElevatedButton).first;
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    
    // Check if we are on the Home screen
    // Home screen usually has a bottom navigation bar or a specific title
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
