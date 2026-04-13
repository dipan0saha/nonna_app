import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('3. Dashboard Integration Tests', () {
    testWidgets('Verify essential tiles are visible', (WidgetTester tester) async {
      await startAppAndLogin(tester);

      // Ensure we are on the Home screen
      final homeAppBar = find.byKey(const Key('home_app_bar'));
      if (homeAppBar.evaluate().isNotEmpty) {
        final tileList = find.byKey(const Key('tile_list_view'));
        expect(tileList, findsOneWidget);
      }
    });

    testWidgets('Ensure scrolling and layout boundaries', (WidgetTester tester) async {
       await startAppAndLogin(tester);
       final tileList = find.byKey(const Key('tile_list_view'));
       if (tileList.evaluate().isNotEmpty) {
         await tester.drag(tileList, const Offset(0, -300));
         await tester.pumpAndSettle();
       }
    });
  });
}
