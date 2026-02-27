import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/enums/rsvp_status.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/models/event_rsvp.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/upcoming_events/widgets/upcoming_events_tile.dart';

Event _makeEvent({
  String id = 'e1',
  String title = 'Baby Shower',
  String? location,
}) {
  final now = DateTime.now();
  return Event(
    id: id,
    babyProfileId: 'bp1',
    createdByUserId: 'u1',
    title: title,
    startsAt: now.add(const Duration(days: 3)),
    createdAt: now,
    updatedAt: now,
    location: location,
  );
}

EventWithRsvp _makeEventWithRsvp({
  String id = 'e1',
  String title = 'Baby Shower',
  String? location,
  RsvpStatus? rsvpStatus,
}) {
  final event = _makeEvent(id: id, title: title, location: location);
  EventRsvp? rsvp;
  if (rsvpStatus != null) {
    final now = DateTime.now();
    rsvp = EventRsvp(
      id: 'rsvp_$id',
      eventId: id,
      userId: 'u1',
      status: rsvpStatus,
      createdAt: now,
      updatedAt: now,
    );
  }
  return EventWithRsvp(event: event, rsvp: rsvp);
}

Widget _buildWidget({
  List<EventWithRsvp> events = const [],
  bool isLoading = false,
  String? error,
  void Function(Event)? onEventTap,
  VoidCallback? onRefresh,
  VoidCallback? onViewAll,
}) {
  return MaterialApp(
    home: Scaffold(
      body: UpcomingEventsTile(
        events: events,
        isLoading: isLoading,
        error: error,
        onEventTap: onEventTap,
        onRefresh: onRefresh,
        onViewAll: onViewAll,
      ),
    ),
  );
}

void main() {
  group('UpcomingEventsTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('upcoming_events_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Something went wrong'));
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows empty state when events list is empty', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('No upcoming events'), findsOneWidget);
    });

    testWidgets('shows events when provided', (tester) async {
      final events = [
        _makeEventWithRsvp(id: 'e1', title: 'Shower'),
        _makeEventWithRsvp(id: 'e2', title: 'Party'),
      ];
      await tester.pumpWidget(_buildWidget(events: events));
      expect(find.byKey(const Key('event_card_e1')), findsOneWidget);
      expect(find.byKey(const Key('event_card_e2')), findsOneWidget);
    });

    testWidgets('shows at most 3 events', (tester) async {
      final events = List.generate(
        5,
        (i) => _makeEventWithRsvp(id: 'e$i', title: 'Event $i'),
      );
      await tester.pumpWidget(_buildWidget(events: events));
      expect(find.byType(InkWell), findsNWidgets(3));
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Upcoming Events'), findsOneWidget);
    });

    testWidgets('calls onEventTap when event card is tapped', (tester) async {
      Event? tappedEvent;
      final item = _makeEventWithRsvp();
      await tester.pumpWidget(
        _buildWidget(
          events: [item],
          onEventTap: (e) => tappedEvent = e,
        ),
      );
      await tester.tap(find.byKey(const Key('event_card_e1')));
      expect(tappedEvent, equals(item.event));
    });

    testWidgets('shows view all button when onViewAll is provided',
        (tester) async {
      await tester.pumpWidget(_buildWidget(onViewAll: () {}));
      expect(find.byKey(const Key('upcoming_events_view_all')), findsOneWidget);
    });

    testWidgets('view all button calls onViewAll callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildWidget(onViewAll: () => called = true));
      await tester.tap(find.byKey(const Key('upcoming_events_view_all')));
      expect(called, isTrue);
    });

    testWidgets('hides view all button when onViewAll is null', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('upcoming_events_view_all')), findsNothing);
    });

    testWidgets('shows location when event has one', (tester) async {
      final item = _makeEventWithRsvp(location: 'Central Park');
      await tester.pumpWidget(_buildWidget(events: [item]));
      expect(find.text('Central Park'), findsOneWidget);
    });

    testWidgets('error retry calls onRefresh', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _buildWidget(error: 'Oops', onRefresh: () => called = true),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      expect(called, isTrue);
    });

    testWidgets('shows RSVP badge when rsvp is provided', (tester) async {
      final item = _makeEventWithRsvp(rsvpStatus: RsvpStatus.yes);
      await tester.pumpWidget(_buildWidget(events: [item]));
      expect(find.byKey(const Key('rsvp_badge_e1')), findsOneWidget);
    });

    testWidgets('hides RSVP badge when no rsvp', (tester) async {
      final item = _makeEventWithRsvp(); // no rsvp
      await tester.pumpWidget(_buildWidget(events: [item]));
      expect(find.byKey(const Key('rsvp_badge_e1')), findsNothing);
    });
  });
}
