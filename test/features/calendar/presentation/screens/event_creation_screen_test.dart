import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/calendar/presentation/screens/event_creation_screen.dart';

Widget _buildScreen({VoidCallback? onCreated, VoidCallback? onCancelled}) {
  return ProviderScope(
    child: MaterialApp(
      home: EventCreationScreen(
        babyProfileId: 'baby-1',
        createdByUserId: 'user-1',
        onCreated: onCreated,
        onCancelled: onCancelled,
      ),
    ),
  );
}

void main() {
  group('EventCreationScreen', () {
    testWidgets("renders Scaffold with key 'event_creation_screen'",
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(find.byKey(const Key('event_creation_screen')), findsOneWidget);
    });

    testWidgets('shows app bar title "New Event"', (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(find.text('New Event'), findsOneWidget);
    });

    testWidgets('renders title, description, and location fields',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(find.byKey(const Key('event_title_field')), findsOneWidget);
      expect(find.byKey(const Key('event_description_field')), findsOneWidget);
      expect(find.byKey(const Key('event_location_field')), findsOneWidget);
    });

    testWidgets('renders start and end date tiles', (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(find.byKey(const Key('event_start_date_tile')), findsOneWidget);
      expect(find.byKey(const Key('event_end_date_tile')), findsOneWidget);
    });

    testWidgets('shows validation error when title is empty', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.tap(find.byKey(const Key('save_event_button')));
      await tester.pump();
      expect(find.text('Title is required'), findsOneWidget);
    });

    testWidgets('calls onCreated after saving valid event', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildScreen(onCreated: () => called = true));
      await tester.enterText(
          find.byKey(const Key('event_title_field')), 'Birthday Party');
      await tester.tap(find.byKey(const Key('save_event_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(called, isTrue);
    });

    testWidgets('renders save event button', (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(find.byKey(const Key('save_event_button')), findsOneWidget);
    });
  });
}
