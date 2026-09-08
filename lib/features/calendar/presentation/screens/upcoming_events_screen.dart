import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/tiles/upcoming_events/providers/upcoming_events_provider.dart';
import 'package:nonna_app/tiles/upcoming_events/widgets/upcoming_events_tile.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';

class UpcomingEventsScreen extends ConsumerStatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  ConsumerState<UpcomingEventsScreen> createState() =>
      _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends ConsumerState<UpcomingEventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  Future<void> _loadEvents({bool forceRefresh = false}) async {
    final babyProfileId = ref.read(selectedBabyProfileProvider);
    final role = ref.read(homeScreenProvider).selectedRole ?? UserRole.follower;
    if (babyProfileId == null) return;

    if (forceRefresh) {
      await ref
          .read(upcomingEventsProvider.notifier)
          .refresh(babyProfileId: babyProfileId, role: role);
    } else {
      await ref
          .read(upcomingEventsProvider.notifier)
          .fetchEvents(babyProfileId: babyProfileId, role: role);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        _loadEvents(forceRefresh: true);
      }
    });

    final babyProfileId = ref.watch(selectedBabyProfileProvider);
    final state = ref.watch(upcomingEventsProvider);

    if (babyProfileId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Upcoming Events')),
        body: const Center(
          child: EmptyState(
            message: 'Select a baby profile to view upcoming events',
            icon: Icons.child_care,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Events')),
      body: RefreshIndicator(
        onRefresh: () => _loadEvents(forceRefresh: true),
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.l),
                child: ErrorView(
                  message: state.error!,
                  onRetry: () => _loadEvents(forceRefresh: true),
                ),
              )
            else
              UpcomingEventsTile(
                events:
                    state.events.map((e) => EventWithRsvp(event: e)).toList(),
                isLoading: state.isLoading && state.events.isEmpty,
                fullView: true,
                onEventTap: (event) => context
                    .push(AppRoutes.calendarEventRoute(event.id), extra: event),
              ),
          ],
        ),
      ),
    );
  }
}
