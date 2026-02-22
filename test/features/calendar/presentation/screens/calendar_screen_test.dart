import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/features/calendar/presentation/providers/calendar_screen_provider.dart';
import 'package:nonna_app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:nonna_app/features/calendar/presentation/widgets/calendar_widget.dart';

// ---------------------------------------------------------------------------
// Fake CalendarScreenNotifier
// ---------------------------------------------------------------------------

class _FakeCalendarNotifier extends CalendarScreenNotifier {
  _FakeCalendarNotifier(this._initial);

  final CalendarScreenState _initial;

  @override
  CalendarScreenState build() => _initial;

  @override
  Future<void> loadEvents({
    required String babyProfileId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> retry() async {}

  @override
  void selectDate(DateTime date) {}

  @override
  void nextMonth() {}

  @override
  void previousMonth() {}
}

// ---------------------------------------------------------------------------
// Helper factory for Event
// ---------------------------------------------------------------------------

Event _makeEvent(String id, String title, DateTime date) {
  return Event(
    id: id,
    babyProfileId: 'p1',
    createdByUserId: 'u1',
    title: title,
    startsAt: date,
    createdAt: date,
    updatedAt: date,
  );
}

// ---------------------------------------------------------------------------
// Helper: build wrapped screen
// ---------------------------------------------------------------------------

Widget _buildScreen(
  CalendarScreenState state, {
  String? babyProfileId,
  UserRole? userRole,
}) {
  return ProviderScope(
    overrides: [
      calendarScreenProvider.overrideWith(() => _FakeCalendarNotifier(state)),
    ],
    child: MaterialApp(
      home: CalendarScreen(
        babyProfileId: babyProfileId,
        userRole: userRole,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CalendarScreen', () {
    testWidgets('renders app bar with title Calendar', (tester) async {
      await tester.pumpWidget(
        _buildScreen(CalendarScreenState()),
      );
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('renders CalendarWidget', (tester) async {
      await tester.pumpWidget(
        _buildScreen(CalendarScreenState()),
      );
      expect(find.byType(CalendarWidget), findsOneWidget);
    });

    testWidgets('shows shimmer cards when loading', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          CalendarScreenState(isLoading: true),
          babyProfileId: 'p1',
        ),
      );
      expect(find.byType(ShimmerCard), findsNWidgets(3));
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          CalendarScreenState(error: 'Load failed'),
          babyProfileId: 'p1',
        ),
      );
      expect(find.text('Load failed'), findsOneWidget);
    });

    testWidgets('shows empty state when no events for selected date',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          CalendarScreenState(),
          babyProfileId: 'p1',
        ),
      );
      await tester.pump();
      expect(find.text('No events for this day'), findsOneWidget);
    });

    testWidgets('shows FAB for owner role', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          CalendarScreenState(),
          userRole: UserRole.owner,
        ),
      );
      expect(find.byKey(const Key('add_event_fab')), findsOneWidget);
    });

    testWidgets('shows FAB for follower role', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          CalendarScreenState(),
          userRole: UserRole.follower,
        ),
      );
      // FAB is shown for all non-null roles; snackbar restricts action
      expect(find.byKey(const Key('add_event_fab')), findsOneWidget);
    });

    testWidgets('does not show FAB when userRole is null', (tester) async {
      await tester.pumpWidget(
        _buildScreen(CalendarScreenState()),
      );
      expect(find.byKey(const Key('add_event_fab')), findsNothing);
    });

    testWidgets('renders event cards for selected date', (tester) async {
      final selectedDate = DateTime(2024, 6, 15);
      final event = _makeEvent('e1', 'Birthday Party', selectedDate);
      final dateKey = '2024-06-15';
      final state = CalendarScreenState(
        selectedDate: selectedDate,
        events: [event],
        eventsByDate: {
          dateKey: [event],
        },
      );
      await tester.pumpWidget(
        _buildScreen(state, babyProfileId: 'p1'),
      );
      expect(find.text('Birthday Party'), findsOneWidget);
    });

    testWidgets('snackbar shown when follower taps add event FAB',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          CalendarScreenState(),
          userRole: UserRole.follower,
        ),
      );
      await tester.tap(find.byKey(const Key('add_event_fab')));
      await tester.pump();
      expect(find.text('Only owners can add events.'), findsOneWidget);
    });
  });
}
