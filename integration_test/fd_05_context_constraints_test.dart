import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'fd_scenario_utils.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FD Context + Constraint Scenarios', () {
    testWidgets('E2E-004 Profile context reload + E2E-021 pull-to-refresh',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);
      await fdGoToTab(tester, 'Home');

      final tileList = find.byKey(const Key('tile_list_view'));
      expect(tileList, findsOneWidget);

      // Pull-to-refresh coverage.
      await tester.drag(tileList, const Offset(0, 400));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_app_bar')), findsOneWidget);

      // Profile-switch coverage when multiple profiles exist.
      final dropdown = find.byType(DropdownButton<String>);
      if (fdExists(dropdown)) {
        await tester.tap(dropdown.first);
        await tester.pumpAndSettle();

        final menuItems = find.byType(DropdownMenuItem<String>);
        if (menuItems.evaluate().length > 1) {
          await tester.tap(menuItems.at(1));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('tile_list_view')), findsOneWidget);
        } else {
          debugPrint('Skipping profile switch: only one profile available.');
          await tester.tapAt(const Offset(5, 5));
          await tester.pumpAndSettle();
        }
      } else {
        debugPrint('Skipping profile switch: profile dropdown not visible.');
      }
    });

    testWidgets('E2E-022 Follower-owner action constraints (conditional)',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);
      await fdGoToTab(tester, 'Home');

      final ownerAction = find.byTooltip('Invite & Manage Followers');
      final inFollowerContext = !fdExists(ownerAction);

      if (!inFollowerContext) {
        debugPrint(
          'Skipping strict follower assertions: current context appears owner.',
        );
        return;
      }

      await fdGoToTab(tester, 'Gallery');
      expect(find.byKey(const Key('upload_photo_fab')), findsNothing);

      await fdGoToTab(tester, 'Calendar');
      expect(find.byKey(const Key('add_event_fab')), findsNothing);

      await fdGoToTab(tester, 'Registry');
      expect(find.byKey(const Key('add_registry_item_fab')), findsNothing);
    });
  });
}
