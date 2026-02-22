import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/event.dart';

/// Screen displaying the details of a calendar event.
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class EventDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy – h:mm a');
    final bool isOwner = userRole == UserRole.owner;

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
              onPressed: onEditTap,
            ),
            IconButton(
              key: const Key('delete_event_button'),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Event',
              onPressed: onDeleteTap,
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
              event.title,
              key: const Key('event_title_text'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalGapM,
            _DetailRow(
              icon: Icons.schedule,
              label: 'Starts',
              value: dateFormat.format(event.startsAt),
            ),
            if (event.endsAt != null)
              _DetailRow(
                key: const Key('event_ends_at_row'),
                icon: Icons.schedule_outlined,
                label: 'Ends',
                value: dateFormat.format(event.endsAt!),
              ),
            if (event.location != null)
              _DetailRow(
                key: const Key('event_location_row'),
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: event.location!,
              ),
            if (event.videoLink != null)
              _DetailRow(
                key: const Key('event_video_link_row'),
                icon: Icons.video_camera_front_outlined,
                label: 'Video Link',
                value: event.videoLink!,
              ),
            if (event.description != null && event.description!.isNotEmpty) ...[
              AppSpacing.verticalGapL,
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSpacing.verticalGapXS,
              Text(
                event.description!,
                key: const Key('event_description_text'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
