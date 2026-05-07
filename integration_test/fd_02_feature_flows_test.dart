import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_helper.dart';
import 'fd_scenario_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FD Calendar + Registry + Gamification Scenarios', () {
    testWidgets('E2E-009 Create calendar event (owner conditional)',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);
      await fdGoToTab(tester, 'Calendar');

      final addEventFab = find.byKey(const Key('add_event_fab'));
      if (!fdExists(addEventFab)) {
        debugPrint('Skipping E2E-009: add event action not available.');
        return;
      }

      await tester.tap(addEventFab);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('event_creation_screen')), findsOneWidget);

      final title = 'E2E Event ${fdRunId()}';
      await tester.enterText(find.byKey(const Key('event_title_field')), title);
      await tester.tap(find.byKey(const Key('save_event_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byKey(const Key('event_creation_screen')), findsNothing);
      expect(find.textContaining('Calendar'), findsWidgets);
    });

    testWidgets('E2E-010 Create registry item and open detail',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);
      await fdGoToTab(tester, 'Registry');

      final addRegistryFab = find.byKey(const Key('add_registry_item_fab'));
      if (!fdExists(addRegistryFab)) {
        debugPrint('Skipping E2E-010: add registry item action not available.');
        return;
      }

      await tester.tap(addRegistryFab);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('registry_item_creation_screen')),
        findsOneWidget,
      );

      final itemName = 'E2E Item ${fdRunId()}';
      await tester.enterText(
          find.byKey(const Key('item_name_field')), itemName);
      await tester.tap(find.byKey(const Key('save_item_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(
          find.byKey(const Key('registry_item_creation_screen')), findsNothing);
      expect(find.textContaining('Registry'), findsWidgets);

      final createdItem = find.text(itemName);
      if (fdExists(createdItem)) {
        await tester.tap(createdItem.first);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('purchase_status_row')), findsOneWidget);
      }
    });

    testWidgets('E2E-011 Gamification name suggestion and vote',
        (WidgetTester tester) async {
      await startAppAndLogin(tester);
      await fdGoToTab(tester, 'Fun');

      expect(find.byKey(const Key('gamification_screen')), findsOneWidget);

      final addSuggestionButton =
          find.byKey(const Key('add_name_suggestion_button'));
      if (fdExists(addSuggestionButton)) {
        await tester.tap(addSuggestionButton);
        await tester.pumpAndSettle();

        final suggestion = 'Name ${fdRunId()}';
        await tester.enterText(
          find.byKey(const Key('name_suggestion_text_field')),
          suggestion,
        );
        await tester
            .tap(find.byKey(const Key('submit_name_suggestion_button')));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      final boyVote = find.text('Boy');
      if (fdExists(boyVote)) {
        await tester.tap(boyVote.first);
        await tester.pumpAndSettle();
      }

      final voteBirthDateButton =
          find.byKey(const Key('vote_birthdate_button'));
      if (fdExists(voteBirthDateButton)) {
        await tester.tap(voteBirthDateButton);
        await tester.pumpAndSettle();

        final okButton = find.text('OK');
        if (fdExists(okButton)) {
          await tester.tap(okButton.first);
          await tester.pumpAndSettle();
        }
      }

      expect(find.byKey(const Key('prediction_votes_tile')), findsOneWidget);
    });
  });
}
