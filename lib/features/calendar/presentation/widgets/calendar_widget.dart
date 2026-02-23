import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';

/// Custom calendar widget
///
/// **Functional Requirements**: Section 3.6.2 - Main App Screens Part I
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Month/year header with prev/next navigation
/// - 7-column day grid (Sun–Sat)
/// - Selected date highlighted with primary color circle
/// - Today highlighted with outline
/// - Dot indicator below days that have events
/// - Callbacks: onDateSelected, onMonthChanged
class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    this.datesWithEvents = const {},
    this.onDateSelected,
    this.onMonthChanged,
  });

  /// The month currently shown in the calendar
  final DateTime focusedMonth;

  /// Currently selected date
  final DateTime selectedDate;

  /// Dates that have events (dot indicator displayed)
  final Set<DateTime> datesWithEvents;

  /// Called when a day is tapped
  final ValueChanged<DateTime>? onDateSelected;

  /// Called when the month changes via prev/next buttons
  final ValueChanged<DateTime>? onMonthChanged;

  static const List<String> _weekdayLabels = [
    'Su',
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('calendar_widget'),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MonthHeader(
            focusedMonth: focusedMonth,
            onPreviousMonth: onMonthChanged == null
                ? null
                : () => onMonthChanged!(
                      DateTime(focusedMonth.year, focusedMonth.month - 1),
                    ),
            onNextMonth: onMonthChanged == null
                ? null
                : () => onMonthChanged!(
                      DateTime(focusedMonth.year, focusedMonth.month + 1),
                    ),
          ),
          // Weekday label row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              children: _weekdayLabels
                  .map(
                    (label) => Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xs / 2),
          // Day grid
          _DayGrid(
            focusedMonth: focusedMonth,
            selectedDate: selectedDate,
            datesWithEvents: datesWithEvents,
            onDateSelected: onDateSelected,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

/// Month/year header with navigation arrows
class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.focusedMonth,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  final DateTime focusedMonth;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('MMMM yyyy').format(focusedMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs / 2,
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('calendar_prev_month_button'),
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousMonth,
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton(
            key: const Key('calendar_next_month_button'),
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}

/// The grid of day cells for the current month
class _DayGrid extends StatelessWidget {
  const _DayGrid({
    required this.focusedMonth,
    required this.selectedDate,
    required this.datesWithEvents,
    this.onDateSelected,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Set<DateTime> datesWithEvents;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    // weekday: Monday=1 … Sunday=7. We want Sunday=0 offset.
    final startOffset = firstDay.weekday % 7;
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;

    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    final cells = <Widget>[];

    // Leading empty cells
    for (var i = 0; i < startOffset; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, day);
      final isSelected = date ==
          DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          );
      final isToday = date == todayNorm;
      final hasEvent = datesWithEvents.contains(date);

      cells.add(
        _DayCell(
          date: date,
          isSelected: isSelected,
          isToday: isToday,
          hasEvent: hasEvent,
          onTap: onDateSelected == null ? null : () => onDateSelected!(date),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: cells,
      ),
    );
  }
}

/// A single day cell in the calendar grid
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.hasEvent,
    this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool hasEvent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color? bgColor;
    Color textColor = colorScheme.onSurface;
    BoxBorder? border;

    if (isSelected) {
      bgColor = AppColors.primaryDark;
      textColor = Colors.white;
    } else if (isToday) {
      border = Border.all(color: AppColors.primaryDark, width: 1.5);
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: border,
              ),
              alignment: Alignment.center,
              child: Text(
                date.day.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor,
                      fontWeight:
                          isSelected || isToday ? FontWeight.bold : null,
                    ),
              ),
            ),
            if (hasEvent)
              Container(
                key: Key('calendar_event_indicator_${date.toIso8601String()}'),
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }
}
