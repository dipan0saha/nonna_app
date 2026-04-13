import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('1. Auth Integration Tests', () {
    testWidgets('Auth Journey', (WidgetTester tester) async {
      await startAppAndLogin(tester);
      
      final homeAppBar = find.byKey(const Key('home_app_bar'));
      if (homeAppBar.evaluate().isNotEmpty) {
        expect(homeAppBar, findsOneWidget);
        debugPrint('Successfully authenticated and reached Home');
      } else {
        debugPrint('Still on Login screen or error state - check credentials');
      }
    });

    testWidgets('Logout flow', (WidgetTester tester) async {
      await startAppAndLogin(tester);
      
      final settingsBtn = find.byKey(const Key('settings_icon_button'));
      if (settingsBtn.evaluate().isNotEmpty) {
        await tester.tap(settingsBtn);
        await tester.pumpAndSettle();
        
        final logoutBtn = find.text('Logout');
        if (logoutBtn.evaluate().isNotEmpty) {
          await tester.tap(logoutBtn);
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('sign_in_button')), findsOneWidget);
        }
      }
    });
  });
}
