import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_helper.dart';
import 'fd_scenario_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FD Settings + Logout Scenarios', () {
    testWidgets('E2E-014 Open settings and change preferences',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);
      await fdOpenProfileFromHome(tester);

      expect(find.byKey(const Key('profile_screen')), findsOneWidget);

      final settingsItem = find.descendant(
        of: find.byKey(const Key('profile_screen')),
        matching: find.text('Settings'),
      );
      expect(settingsItem, findsOneWidget);
      await tester.tap(settingsItem);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings_screen')), findsOneWidget);

      final notifications = find.byKey(const Key('notifications_toggle'));
      expect(notifications, findsOneWidget);
      await tester.tap(notifications);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings_screen')), findsOneWidget);
    });

    testWidgets('E2E-012 Logout redirects to sign in',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);
      await fdOpenProfileFromHome(tester);

      expect(find.byKey(const Key('profile_screen')), findsOneWidget);

      final logoutItem = find.descendant(
        of: find.byKey(const Key('profile_screen')),
        matching: find.text('Logout'),
      );
      expect(logoutItem, findsOneWidget);
      await tester.tap(logoutItem);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byKey(const Key('sign_in_button')), findsOneWidget);
    });
  });
}
