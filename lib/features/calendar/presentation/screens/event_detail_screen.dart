import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/rsvp_status.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/models/event_rsvp.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';

/// Screen displaying the details of a calendar event.
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.event,
    this.userRole,
    this.onEditTap,
    this.onDeleteTap,
  });

  final Event event;
  final UserRole? userRole;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  late Event _event;
  List<_RsvpEntry> _rsvps = [];
  bool _loadingRsvps = true;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRsvps());
  }

  Future<void> _deleteEvent(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
          'Are you sure you want to delete "${_event.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final databaseService = ref.read(databaseServiceProvider);
      await databaseService.update(SupabaseTables.events, {
        'deleted_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq(SupabaseTables.id, _event.id);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: $e')),
      );
    }
  }

  Future<void> _loadRsvps() async {
    try {
      final databaseService = ref.read(databaseServiceProvider);

      final response = await databaseService
          .select(SupabaseTables.eventRsvps)
          .eq('event_id', _event.id);

      final rawList = response as List;
      if (rawList.isEmpty) {
        if (mounted) setState(() => _loadingRsvps = false);
        return;
      }

      final userIds =
          rawList.map((r) => (r as Map)['user_id'] as String).toList();
      final profilesResponse = await databaseService
          .select(
            SupabaseTables.userProfiles,
            columns: '${SupabaseTables.userId}, ${SupabaseTables.displayName}',
          )
          .inFilter(SupabaseTables.userId, userIds);

      final profileMap = <String, String>{};
      for (final p in profilesResponse as List<dynamic>) {
        final row = p as Map;
        final uid = row[SupabaseTables.userId] as String;
        final name = row[SupabaseTables.displayName];
        profileMap[uid] = name is String ? name : 'Guest';
      }

      final entries = rawList.map((json) {
        final rsvp = EventRsvp.fromJson(json as Map<String, dynamic>);
        final name = profileMap[rsvp.userId] ?? rsvp.userId.substring(0, 8);
        return _RsvpEntry(rsvp: rsvp, displayName: name);
      }).toList();

      if (mounted) {
        setState(() {
          _rsvps = entries;
          _loadingRsvps = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️  Failed to load event RSVPs: $e');
      if (mounted) setState(() => _loadingRsvps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy – h:mm a');
    final currentUserId = ref.watch(authProvider).user?.id;
    final bool isOwner =
        currentUserId != null && currentUserId == _event.createdByUserId;

    return Scaffold(
      key: const Key('event_detail_screen'),
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (isOwner) ...[
            IconButton(
              key: const Key('edit_event_button'),
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Event',
              onPressed: widget.onEditTap ??
                  () async {
                    final result = await context.push<Event>(
                      AppRoutes.calendarEventEdit,
                      extra: _event,
                    );
                    if (result is Event && mounted) {
                      setState(() => _event = result);
                    }
                  },
            ),
            IconButton(
              key: const Key('delete_event_button'),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Event',
              onPressed: widget.onDeleteTap ?? () => _deleteEvent(context),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _event.title,
              key: const Key('event_title_text'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalGapM,
            _DetailRow(
              icon: Icons.schedule,
              label: 'Starts',
              value: dateFormat.format(_event.startsAt),
            ),
            if (_event.endsAt != null)
              _DetailRow(
                key: const Key('event_ends_at_row'),
                icon: Icons.schedule_outlined,
                label: 'Ends',
                value: dateFormat.format(_event.endsAt!),
              ),
            if (_event.location != null)
              _DetailRow(
                key: const Key('event_location_row'),
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: _event.location!,
              ),
            if (_event.videoLink != null)
              _DetailRow(
                key: const Key('event_video_link_row'),
                icon: Icons.video_camera_front_outlined,
                label: 'Video Link',
                value: _event.videoLink!,
              ),
            if (_event.description != null &&
                _event.description!.isNotEmpty) ...[
              AppSpacing.verticalGapL,
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalGapXS,
              Text(
                _event.description!,
                key: const Key('event_description_text'),
              ),
            ],
            // Guests / RSVP section
            if (!_loadingRsvps && _rsvps.isNotEmpty) ...[
              AppSpacing.verticalGapL,
              const Divider(),
              AppSpacing.verticalGapS,
              Text(
                'Guests (${_rsvps.length})',
                key: const Key('event_guests_header'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalGapXS,
              ..._rsvps.map((entry) => _GuestRow(entry: entry)),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data class holding an RSVP + resolved display name
// ---------------------------------------------------------------------------

class _RsvpEntry {
  const _RsvpEntry({required this.rsvp, required this.displayName});

  final EventRsvp rsvp;
  final String displayName;
}

// ---------------------------------------------------------------------------
// Row showing a guest's name and their RSVP chip
// ---------------------------------------------------------------------------

class _GuestRow extends StatelessWidget {
  const _GuestRow({required this.entry});

  final _RsvpEntry entry;

  @override
  Widget build(BuildContext context) {
    final Color chipColor;
    final String chipLabel;
    switch (entry.rsvp.status) {
      case RsvpStatus.yes:
        chipColor = Colors.green;
        chipLabel = 'Going';
      case RsvpStatus.no:
        chipColor = Colors.red;
        chipLabel = 'Declined';
      case RsvpStatus.maybe:
        chipColor = Colors.orange;
        chipLabel = 'Awaiting';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 18),
          AppSpacing.horizontalGapS,
          Expanded(child: Text(entry.displayName)),
          Chip(
            key: Key('rsvp_chip_${entry.rsvp.userId}'),
            label: Text(
              chipLabel,
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
            backgroundColor: chipColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Row showing an event detail field (icon + label + value)
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          AppSpacing.horizontalGapS,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
