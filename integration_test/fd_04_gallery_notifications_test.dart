import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'fd_scenario_utils.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FD Gallery + Home Tile Scenarios', () {
    testWidgets('E2E-007/E2E-008 Gallery flow and photo detail interaction',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);
      await fdGoToTab(tester, 'Gallery');

      expect(find.textContaining('Gallery'), findsWidgets);

      // Owner-only upload action may be hidden for follower role.
      final uploadFab = find.byKey(const Key('upload_photo_fab'));
      debugPrint('upload_photo_fab visible: ${fdExists(uploadFab)}');

      final photoItems = fdByKeyPrefix('photo_item_');
      if (fdExists(photoItems)) {
        await tester.tap(photoItems.first);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('photo_detail_image')), findsOneWidget);

        final squishButton = find.byKey(const Key('squish_button'));
        if (fdExists(squishButton)) {
          await tester.tap(squishButton);
          await tester.pumpAndSettle();
        }
      } else {
        debugPrint('Skipping photo detail steps: no photos currently visible.');
      }
    });

    testWidgets('E2E-015/E2E-016 Home tile interactions',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);
      await fdGoToTab(tester, 'Home');

      expect(find.byKey(const Key('home_app_bar')), findsOneWidget);
      expect(find.byKey(const Key('tile_list_view')), findsOneWidget);

      await fdTapIfExists(
          tester, find.byKey(const Key('mark_all_read_button')));

      final dismissAnnouncementButtons = fdByKeyPrefix('dismiss_');
      if (fdExists(dismissAnnouncementButtons)) {
        await tester.tap(dismissAnnouncementButtons.first);
        await tester.pumpAndSettle();
      }

      final revokeInviteButtons = fdByKeyPrefix('revoke_button_');
      if (fdExists(revokeInviteButtons)) {
        await tester.tap(revokeInviteButtons.first);
        await tester.pumpAndSettle();
      }

      expect(find.byKey(const Key('home_app_bar')), findsOneWidget);
    });

    testWidgets('E2E-017/E2E-018 Tile view-all navigation checks',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);
      await fdGoToTab(tester, 'Home');

      final photosViewAll = find.byKey(const Key('recent_photos_view_all'));
      if (fdExists(photosViewAll)) {
        await tester.tap(photosViewAll);
        await tester.pumpAndSettle();
        expect(find.textContaining('Gallery'), findsWidgets);
        await fdGoToTab(tester, 'Home');
      }

      final eventsViewAll = find.byKey(const Key('upcoming_events_view_all'));
      if (fdExists(eventsViewAll)) {
        await tester.tap(eventsViewAll);
        await tester.pumpAndSettle();

        // Upcoming events route still belongs to calendar feature.
        expect(
          find.textContaining('Upcoming').evaluate().isNotEmpty ||
              find.textContaining('Calendar').evaluate().isNotEmpty,
          isTrue,
        );
      }
    });
  });
}
