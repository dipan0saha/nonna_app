import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_helper.dart';
import 'fd_scenario_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FD Auth + Navigation Scenarios', () {
    testWidgets('E2E-002 Login with latest credentials',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);

      expect(find.byKey(const Key('home_app_bar')), findsOneWidget);
    });

    testWidgets('E2E-003 Navigate all shell tabs', (WidgetTester tester) async {
      await startAppAndLogin(tester);

      final hasBottomNav =
          find.byKey(const Key('app_bottom_nav_bar')).evaluate().isNotEmpty;
      final hasNavRail =
          find.byKey(const Key('app_navigation_rail')).evaluate().isNotEmpty;
      expect(hasBottomNav || hasNavRail, isTrue);

      await fdGoToTab(tester, 'Gallery');
      expect(find.text('Gallery'), findsWidgets);

      await fdGoToTab(tester, 'Calendar');
      expect(find.text('Calendar'), findsWidgets);

      await fdGoToTab(tester, 'Registry');
      expect(find.text('Registry'), findsWidgets);

      await fdGoToTab(tester, 'Fun');
      expect(find.byKey(const Key('gamification_screen')), findsOneWidget);

      await fdGoToTab(tester, 'Home');
      expect(find.byKey(const Key('home_app_bar')), findsOneWidget);
    });
  });
}
