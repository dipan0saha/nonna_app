import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/features/calendar/presentation/screens/event_detail_screen.dart';

Event _makeEvent({
  String title = 'Baby Shower',
  String? description,
  String? location,
  String? videoLink,
  DateTime? endsAt,
}) {
  final now = DateTime(2024, 6, 15, 14, 0);
  return Event(
    id: 'event-1',
    babyProfileId: 'baby-1',
    createdByUserId: 'user-1',
    title: title,
    startsAt: now,
    endsAt: endsAt,
    description: description,
    location: location,
    videoLink: videoLink,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _buildScreen(Event event, {UserRole? userRole}) {
  return MaterialApp(
    home: EventDetailScreen(event: event, userRole: userRole),
  );
}

void main() {
  group('EventDetailScreen', () {
    testWidgets("renders Scaffold with key 'event_detail_screen'",
        (tester) async {
      await tester.pumpWidget(_buildScreen(_makeEvent()));
      expect(find.byKey(const Key('event_detail_screen')), findsOneWidget);
    });

    testWidgets('shows event title', (tester) async {
      await tester.pumpWidget(_buildScreen(_makeEvent(title: 'Baby Shower')));
      expect(find.byKey(const Key('event_title_text')), findsOneWidget);
      expect(find.text('Baby Shower'), findsWidgets);
    });

    testWidgets('shows description when provided', (tester) async {
      await tester
          .pumpWidget(_buildScreen(_makeEvent(description: 'Bring gifts!')));
      expect(find.byKey(const Key('event_description_text')), findsOneWidget);
    });

    testWidgets('shows location row when location is set', (tester) async {
      await tester
          .pumpWidget(_buildScreen(_makeEvent(location: 'Central Park')));
      expect(find.byKey(const Key('event_location_row')), findsOneWidget);
    });

    testWidgets('hides location row when location is null', (tester) async {
      await tester.pumpWidget(_buildScreen(_makeEvent()));
      expect(find.byKey(const Key('event_location_row')), findsNothing);
    });

    testWidgets('shows edit and delete buttons for owner', (tester) async {
      await tester
          .pumpWidget(_buildScreen(_makeEvent(), userRole: UserRole.owner));
      expect(find.byKey(const Key('edit_event_button')), findsOneWidget);
      expect(find.byKey(const Key('delete_event_button')), findsOneWidget);
    });

    testWidgets('hides edit and delete buttons for non-owner', (tester) async {
      await tester
          .pumpWidget(_buildScreen(_makeEvent(), userRole: UserRole.follower));
      expect(find.byKey(const Key('edit_event_button')), findsNothing);
      expect(find.byKey(const Key('delete_event_button')), findsNothing);
    });
  });
}
