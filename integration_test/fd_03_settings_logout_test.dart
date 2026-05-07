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

      final settingsItem =
          find.byKey(const Key('profile_settings_item_Settings'));
      expect(settingsItem, findsOneWidget);
      await tester.tap(settingsItem);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings_screen')), findsOneWidget);

      final darkMode = find.byKey(const Key('dark_mode_toggle'));
      expect(darkMode, findsOneWidget);
      await tester.tap(darkMode);
      await tester.pumpAndSettle();

      final languageTile = find.byKey(const Key('language_tile'));
      expect(languageTile, findsOneWidget);
      await tester.tap(languageTile);
      await tester.pumpAndSettle();

      final languageOptionEs = find.byKey(const Key('language_option_es'));
      if (fdExists(languageOptionEs)) {
        await tester.tap(languageOptionEs);
      } else {
        final languageOptionEn = find.byKey(const Key('language_option_en'));
        if (fdExists(languageOptionEn)) {
          await tester.tap(languageOptionEn);
        }
      }
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings_screen')), findsOneWidget);
    });

    testWidgets('E2E-012 Logout redirects to sign in',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);
      await fdOpenProfileFromHome(tester);

      expect(find.byKey(const Key('profile_screen')), findsOneWidget);

      final logoutItem = find.byKey(const Key('profile_settings_item_Logout'));
      expect(logoutItem, findsOneWidget);
      await tester.tap(logoutItem);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byKey(const Key('sign_in_button')), findsOneWidget);
    });
  });
}
