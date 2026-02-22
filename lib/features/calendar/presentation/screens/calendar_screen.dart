import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/features/calendar/presentation/providers/calendar_screen_provider.dart';
import 'package:nonna_app/features/calendar/presentation/widgets/calendar_widget.dart';

/// Calendar screen
///
/// **Functional Requirements**: Section 3.6.2 - Main App Screens Part I
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Calendar widget at the top showing the focused month
/// - Event list for the selected date below the calendar
/// - FAB to add events (owner only)
/// - Pull-to-refresh
/// - Loading, error, and empty states
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({
    super.key,
    this.babyProfileId,
    this.userRole,
  });

  /// The ID of the baby profile whose events to load
  final String? babyProfileId;

  /// Current user role (owner sees the add-event FAB)
  final UserRole? userRole;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    _loadEventsIfReady();
  }

  @override
  void didUpdateWidget(CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.babyProfileId != oldWidget.babyProfileId) {
      _loadEventsIfReady();
    }
  }

  void _loadEventsIfReady() {
    if (widget.babyProfileId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(calendarScreenProvider.notifier).loadEvents(
              babyProfileId: widget.babyProfileId!,
            );
      });
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(calendarScreenProvider.notifier).refresh();
  }

  void _onAddEventTap() {
    if (widget.userRole != UserRole.owner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only owners can add events.'),
        ),
      );
      return;
    }
    // TODO: navigate to add-event screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add event – coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarScreenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      floatingActionButton: widget.userRole != null
          ? FloatingActionButton(
              key: const Key('add_event_fab'),
              onPressed: _onAddEventTap,
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // Calendar widget pinned at top
            SliverToBoxAdapter(
              child: CalendarWidget(
                focusedMonth: state.focusedMonth,
                selectedDate: state.selectedDate,
                datesWithEvents: state.datesWithEvents,
                onDateSelected: (date) {
                  ref
                      .read(calendarScreenProvider.notifier)
                      .selectDate(date);
                },
                onMonthChanged: (month) {
                  if (month.isAfter(state.focusedMonth)) {
                    ref
                        .read(calendarScreenProvider.notifier)
                        .nextMonth();
                  } else {
                    ref
                        .read(calendarScreenProvider.notifier)
                        .previousMonth();
                  }
                },
              ),
            ),
            const SliverToBoxAdapter(child: Divider()),
            // Selected-date label
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  DateFormat('EEEE, MMMM d').format(state.selectedDate),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            // Event list area
            _buildEventSliver(state),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSliver(CalendarScreenState state) {
    if (state.isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.xs / 2,
            ),
            child: ShimmerCard(height: 80, hasImage: false),
          ),
          childCount: 3,
        ),
      );
    }

    if (state.error != null) {
      return SliverFillRemaining(
        child: ErrorView(
          message: state.error!,
          onRetry: () =>
              ref.read(calendarScreenProvider.notifier).retry(),
        ),
      );
    }

    final events = state.eventsForSelectedDate;

    if (events.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyState(
          message: 'No events for this day',
          icon: Icons.event_available_outlined,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _EventCard(event: events[index]),
          childCount: events.length,
        ),
      ),
    );
  }
}

/// Card for a single calendar event
class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(event.title),
        subtitle: Text(
          DateFormat('h:mm a').format(event.startsAt),
        ),
        trailing: event.location != null
            ? const Icon(Icons.location_on_outlined, size: 16)
            : null,
      ),
    );
  }
}
