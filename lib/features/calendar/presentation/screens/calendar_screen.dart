import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/home/presentation/widgets/tile_list_view.dart'; // Ensure TileListView gets imported
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/features/calendar/presentation/providers/calendar_screen_provider.dart';
import 'package:nonna_app/features/calendar/presentation/widgets/calendar_widget.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/user_baby_profiles_provider.dart';

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
    final babyProfileId =
        widget.babyProfileId ?? ref.read(selectedBabyProfileProvider);
    final userRole = widget.userRole ??
        ref.read(homeScreenProvider).selectedRole ??
        UserRole.follower;
    if (babyProfileId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(calendarScreenProvider.notifier).loadEvents(
              babyProfileId: babyProfileId,
              role: userRole,
            );
      });
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(calendarScreenProvider.notifier).refresh();
  }

  Future<void> _onAddEventTap(
      UserRole effectiveRole, String babyProfileId) async {
    if (effectiveRole != UserRole.owner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only owners can add events.'),
        ),
      );
      return;
    }
    // navigate to add-event screen
    final userId = ref.read(authProvider).user?.id ?? '';
    final created = await context.push(
      '/calendar/event/create',
      extra: {
        'babyProfileId': babyProfileId,
        'createdByUserId': userId,
      },
    );

    if (created == true && mounted) {
      await ref.read(calendarScreenProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the globally selected baby profile
    ref.listen<String?>(selectedBabyProfileProvider, (previous, next) {
      if (next != previous && next != null) {
        ref.read(calendarScreenProvider.notifier).loadEvents(
              babyProfileId: next,
            );
      }
    });

    final currentBabyProfileId =
        widget.babyProfileId ?? ref.watch(selectedBabyProfileProvider);
    final resolvedRole = currentBabyProfileId != null
        ? ref
            .watch(currentUserRoleForBabyProfileProvider(currentBabyProfileId))
            .asData
            ?.value
        : null;
    final effectiveRole = widget.userRole ??
        ref.watch(homeScreenProvider).selectedRole ??
        resolvedRole ??
        UserRole.follower;

    if (currentBabyProfileId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Calendar')),
        body: const Center(
          child: EmptyState(
            message: 'Select a baby profile to view calendar',
            icon: Icons.child_care,
          ),
        ),
      );
    }

    final state = ref.watch(calendarScreenProvider);
    final hasSelectedDateEvents = state.eventsForSelectedDate.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      floatingActionButton: effectiveRole == UserRole.owner
          ? FloatingActionButton(
              key: const Key('add_event_fab'),
              heroTag: null,
              onPressed: () =>
                  _onAddEventTap(effectiveRole, currentBabyProfileId),
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Calendar widget
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: CalendarWidget(
                  focusedMonth: state.focusedMonth,
                  selectedDate: state.selectedDate,
                  datesWithEvents: state.datesWithEvents,
                  onDateSelected: (date) {
                    ref.read(calendarScreenProvider.notifier).selectDate(date);
                  },
                  onMonthChanged: (month) {
                    ref.read(calendarScreenProvider.notifier).goToMonth(month);
                  },
                ),
              ),
              const Divider(),
              // Selected-date label
              if (hasSelectedDateEvents)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    DateFormat('EEEE, MMMM d').format(state.selectedDate),
                    key: const Key('selected_date_label'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              // Event list area
              _buildEventList(state),
              // Separator and Tiles
              if (state.tiles.isNotEmpty == true) ...[
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  child: Text(
                    'Upcoming Activities',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                TileListView(
                  tiles: state.tiles,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventList(CalendarScreenState state) {
    if (state.isLoading) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.xs / 2,
          ),
          child: ShimmerCard(height: 80, hasImage: false),
        ),
      );
    }

    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: ErrorView(
          message: state.error!,
          onRetry: () => ref.read(calendarScreenProvider.notifier).retry(),
        ),
      );
    }

    final events = state.eventsForSelectedDate;

    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      children: [
        ...events.map((event) => _EventCard(event: event)),
      ],
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
        onTap: () {
          context.push('/calendar/event/detail', extra: event);
        },
      ),
    );
  }
}
