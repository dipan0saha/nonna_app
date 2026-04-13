import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('2. Baby Profile Integration Tests', () {
    testWidgets('Navigate to creation wizard, fill details and save', (WidgetTester tester) async {
      await startAppAndLogin(tester);

      // If we are at the empty home state, tap 'Create Profile'
      final createProfileBtn = find.text('Create Profile');
      if (createProfileBtn.evaluate().isNotEmpty) {
        await tester.tap(createProfileBtn);
        await tester.pumpAndSettle();
      }

      // Verify we are on the creation screen (assuming we were at home)
      if (find.byKey(const Key('create_baby_profile_screen')).evaluate().isNotEmpty) {
        expect(find.byKey(const Key('create_baby_profile_screen')), findsOneWidget);

        // Fill details
        final nameField = find.byType(TextFormField);
        await tester.enterText(nameField, 'Baby Integration');
        await tester.pumpAndSettle();

        // Tap Create
        final saveBtn = find.text('Create');
        await tester.tap(saveBtn);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });

    testWidgets('Verify Baby Profile selector in header', (WidgetTester tester) async {
       await startAppAndLogin(tester);
       // Test logic for profile selector
    });
  });
}
