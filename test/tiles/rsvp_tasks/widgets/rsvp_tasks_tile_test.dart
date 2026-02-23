import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/models/event_rsvp.dart';
import 'package:nonna_app/core/enums/rsvp_status.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/rsvp_tasks/providers/rsvp_tasks_provider.dart';
import 'package:nonna_app/tiles/rsvp_tasks/widgets/rsvp_tasks_tile.dart';

EventWithRSVP _makeTask({
  String id = 'ev1',
  String title = 'Baby Shower',
  bool needsResponse = true,
}) {
  final now = DateTime.now();
  final event = Event(
    id: id,
    babyProfileId: 'bp1',
    createdByUserId: 'u1',
    title: title,
    startsAt: now.add(const Duration(days: 5)),
    createdAt: now,
    updatedAt: now,
  );
  EventRsvp? rsvp;
  if (!needsResponse) {
    rsvp = EventRsvp(
      id: 'rsvp_$id',
      eventId: id,
      userId: 'u1',
      status: RsvpStatus.yes,
      createdAt: now,
      updatedAt: now,
    );
  }
  return EventWithRSVP(event: event, rsvp: rsvp, needsResponse: needsResponse);
}

Widget _buildWidget({
  List<EventWithRSVP> events = const [],
  bool isLoading = false,
  String? error,
  void Function(EventWithRSVP)? onEventTap,
  VoidCallback? onRefresh,
  VoidCallback? onViewAll,
}) {
  return MaterialApp(
    home: Scaffold(
      body: RsvpTasksTile(
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
  group('RsvpTasksTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('rsvp_tasks_tile')), findsOneWidget);
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
      expect(find.text('No RSVP tasks'), findsOneWidget);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('RSVP Tasks'), findsOneWidget);
    });

    testWidgets('shows events when provided', (tester) async {
      final tasks = [
        _makeTask(id: 'ev1', title: 'Shower'),
        _makeTask(id: 'ev2', title: 'Reveal'),
      ];
      await tester.pumpWidget(_buildWidget(events: tasks));
      expect(find.byKey(const Key('rsvp_task_ev1')), findsOneWidget);
      expect(find.byKey(const Key('rsvp_task_ev2')), findsOneWidget);
    });

    testWidgets('shows at most 3 tasks', (tester) async {
      final tasks = List.generate(5, (i) => _makeTask(id: 'ev$i'));
      await tester.pumpWidget(_buildWidget(events: tasks));
      for (int i = 0; i < 3; i++) {
        expect(find.byKey(Key('rsvp_task_ev$i')), findsOneWidget);
      }
      expect(find.byKey(const Key('rsvp_task_ev3')), findsNothing);
    });

    testWidgets('shows pending badge when there are pending tasks',
        (tester) async {
      final tasks = [_makeTask(needsResponse: true)];
      await tester.pumpWidget(_buildWidget(events: tasks));
      expect(find.byKey(const Key('pending_rsvp_badge')), findsOneWidget);
    });

    testWidgets('hides pending badge when no pending tasks', (tester) async {
      final tasks = [_makeTask(needsResponse: false)];
      await tester.pumpWidget(_buildWidget(events: tasks));
      expect(find.byKey(const Key('pending_rsvp_badge')), findsNothing);
    });

    testWidgets('shows rsvp status badge for each task', (tester) async {
      final task = _makeTask(id: 'ev1');
      await tester.pumpWidget(_buildWidget(events: [task]));
      expect(find.byKey(const Key('rsvp_status_ev1')), findsOneWidget);
    });

    testWidgets('calls onEventTap when task is tapped', (tester) async {
      EventWithRSVP? tapped;
      final task = _makeTask(id: 'ev1');
      await tester.pumpWidget(
        _buildWidget(events: [task], onEventTap: (e) => tapped = e),
      );
      await tester.tap(find.byKey(const Key('rsvp_task_ev1')));
      expect(tapped, equals(task));
    });

    testWidgets('shows view all button when onViewAll is provided',
        (tester) async {
      await tester.pumpWidget(_buildWidget(onViewAll: () {}));
      expect(find.byKey(const Key('rsvp_tasks_view_all')), findsOneWidget);
    });

    testWidgets('hides view all button when onViewAll is null', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('rsvp_tasks_view_all')), findsNothing);
    });

    testWidgets('view all button calls onViewAll callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildWidget(onViewAll: () => called = true));
      await tester.tap(find.byKey(const Key('rsvp_tasks_view_all')));
      expect(called, isTrue);
    });

    testWidgets('error retry calls onRefresh', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _buildWidget(error: 'Oops', onRefresh: () => called = true),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      expect(called, isTrue);
    });
  });
}
