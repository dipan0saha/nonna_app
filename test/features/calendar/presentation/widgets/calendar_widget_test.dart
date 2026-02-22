import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/calendar/presentation/widgets/calendar_widget.dart';

Widget _buildCalendar({
  DateTime? focusedMonth,
  DateTime? selectedDate,
  Set<DateTime> datesWithEvents = const {},
  ValueChanged<DateTime>? onDateSelected,
  ValueChanged<DateTime>? onMonthChanged,
}) {
  final now = DateTime(2024, 6, 15);
  return MaterialApp(
    home: Scaffold(
      body: CalendarWidget(
        focusedMonth: focusedMonth ?? now,
        selectedDate: selectedDate ?? now,
        datesWithEvents: datesWithEvents,
        onDateSelected: onDateSelected,
        onMonthChanged: onMonthChanged,
      ),
    ),
  );
}

void main() {
  group('CalendarWidget', () {
    testWidgets('renders with key calendar_widget', (tester) async {
      await tester.pumpWidget(_buildCalendar());
      expect(find.byKey(const Key('calendar_widget')), findsOneWidget);
    });

    testWidgets('shows month/year header', (tester) async {
      await tester.pumpWidget(
        _buildCalendar(focusedMonth: DateTime(2024, 6)),
      );
      expect(find.text('June 2024'), findsOneWidget);
    });

    testWidgets('renders prev month button', (tester) async {
      await tester.pumpWidget(_buildCalendar());
      expect(
        find.byKey(const Key('calendar_prev_month_button')),
        findsOneWidget,
      );
    });

    testWidgets('renders next month button', (tester) async {
      await tester.pumpWidget(_buildCalendar());
      expect(
        find.byKey(const Key('calendar_next_month_button')),
        findsOneWidget,
      );
    });

    testWidgets('calls onMonthChanged with earlier month on prev tap',
        (tester) async {
      DateTime? changed;
      await tester.pumpWidget(
        _buildCalendar(
          focusedMonth: DateTime(2024, 6),
          onMonthChanged: (d) => changed = d,
        ),
      );
      await tester.tap(find.byKey(const Key('calendar_prev_month_button')));
      expect(changed, isNotNull);
      expect(changed!.month, equals(5));
    });

    testWidgets('calls onMonthChanged with later month on next tap',
        (tester) async {
      DateTime? changed;
      await tester.pumpWidget(
        _buildCalendar(
          focusedMonth: DateTime(2024, 6),
          onMonthChanged: (d) => changed = d,
        ),
      );
      await tester.tap(find.byKey(const Key('calendar_next_month_button')));
      expect(changed, isNotNull);
      expect(changed!.month, equals(7));
    });

    testWidgets('renders day numbers in the grid', (tester) async {
      await tester.pumpWidget(
        _buildCalendar(focusedMonth: DateTime(2024, 6)),
      );
      // June has 30 days
      expect(find.text('1'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('calls onDateSelected when a day is tapped', (tester) async {
      DateTime? selected;
      await tester.pumpWidget(
        _buildCalendar(
          focusedMonth: DateTime(2024, 6),
          selectedDate: DateTime(2024, 6, 1),
          onDateSelected: (d) => selected = d,
        ),
      );
      // Tap the "15" day cell
      await tester.tap(find.text('15'));
      expect(selected, isNotNull);
      expect(selected!.day, equals(15));
    });

    testWidgets('shows weekday header row', (tester) async {
      await tester.pumpWidget(_buildCalendar());
      expect(find.text('Su'), findsOneWidget);
      expect(find.text('Sa'), findsOneWidget);
    });
  });
}
