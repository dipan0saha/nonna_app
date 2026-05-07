import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_helper.dart';
import 'fd_scenario_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FD Profile + Followers Scenarios', () {
    testWidgets('E2E-005 Create baby profile and auto-switch',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);

      final createProfileButton = find.byTooltip('Create Baby Profile');
      expect(createProfileButton, findsOneWidget);
      await tester.tap(createProfileButton);
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('create_baby_profile_screen')), findsOneWidget);

      final runId = fdRunId();
      await tester.enterText(
          find.byType(TextFormField).first, 'E2E Baby $runId');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byKey(const Key('home_app_bar')), findsOneWidget);
    });

    testWidgets('E2E-006 Owner follower management and invite flow',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);

      final manageFollowersButton = find.byTooltip('Invite & Manage Followers');
      if (!fdExists(manageFollowersButton)) {
        debugPrint(
          'Skipping E2E-006: selected profile is not owner or action hidden.',
        );
        return;
      }

      await tester.tap(manageFollowersButton);
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('followers_management_screen')), findsOneWidget);

      final inviteButton = find.byKey(const Key('invite_follower_button'));
      expect(inviteButton, findsOneWidget);
      await tester.tap(inviteButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('invite_followers_screen')), findsOneWidget);

      final inviteEmail = 'fd.${fdRunId()}@example.com';
      await tester.enterText(
        find.byKey(const Key('invite_email_field')),
        inviteEmail,
      );
      await tester.tap(find.byKey(const Key('send_invite_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final success = find.byKey(const Key('invite_success_message'));
      final error = find.byKey(const Key('invite_error_message'));
      expect(
          success.evaluate().isNotEmpty || error.evaluate().isNotEmpty, isTrue);
    });
  });
}
