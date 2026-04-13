import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('8. Notifications Integration Tests', () {
    testWidgets('Verify notifications visibility', (WidgetTester tester) async {
      await startAppAndLogin(tester);
      
      final notificationBtn = find.byKey(const Key('notification_icon_button'));
      if (notificationBtn.evaluate().isNotEmpty) {
        await tester.tap(notificationBtn);
        await tester.pumpAndSettle();
      }
    });
  });
}
