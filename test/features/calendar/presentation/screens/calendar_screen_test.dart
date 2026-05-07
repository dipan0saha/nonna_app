import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
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
    UserRole role = UserRole.owner,
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
        babyProfileId: babyProfileId ?? 'baby-1',
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
          userRole: UserRole.owner,
        ),
      );
      await tester.pump();
      expect(find.byType(ShimmerCard), findsNWidgets(3));
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          CalendarScreenState(error: 'Load failed'),
          userRole: UserRole.owner,
        ),
      );
      await tester.pump();
      expect(find.text('Load failed'), findsOneWidget);
    });

    testWidgets('hides selected-date label when no events for selected date',
        (tester) async {
      final selectedDate = DateTime(2024, 6, 15);
      final formattedDate = DateFormat('EEEE, MMMM d').format(selectedDate);

      await tester.pumpWidget(
        _buildScreen(
          CalendarScreenState(selectedDate: selectedDate),
          userRole: UserRole.owner,
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('selected_date_label')), findsNothing);
      expect(find.text(formattedDate), findsNothing);
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

    testWidgets('does not show FAB for follower role', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          CalendarScreenState(),
          userRole: UserRole.follower,
        ),
      );
      expect(find.byKey(const Key('add_event_fab')), findsNothing);
    });

    testWidgets('does not show FAB when userRole is null', (tester) async {
      await tester.pumpWidget(
        _buildScreen(CalendarScreenState()),
      );
      expect(find.byKey(const Key('add_event_fab')), findsNothing);
    });

    testWidgets('renders event cards for selected date', (tester) async {
      final selectedDate = DateTime(2024, 6, 15);
      final formattedDate = DateFormat('EEEE, MMMM d').format(selectedDate);
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
        _buildScreen(
          state,
          userRole: UserRole.owner,
        ),
      );
      await tester.pump();
      expect(find.text('Birthday Party'), findsOneWidget);
      expect(find.byKey(const Key('selected_date_label')), findsOneWidget);
      expect(find.text(formattedDate), findsOneWidget);
    });

    testWidgets('does not render snackbar guard path for follower',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          CalendarScreenState(),
          userRole: UserRole.follower,
        ),
      );
      await tester.pump();
      expect(find.text('Only owners can add events.'), findsNothing);
    });
  });
}
