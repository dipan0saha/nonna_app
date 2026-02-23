import 'package:nonna_app/core/enums/rsvp_status.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/models/event_rsvp.dart';

/// An [Event] paired with the current user's optional RSVP.
///
/// Used by [UpcomingEventsTile] so the widget can display RSVP status
/// without coupling to any provider.
class EventWithRsvp {
  final Event event;

  /// The current user's RSVP, or `null` if they haven't responded yet.
  final EventRsvp? rsvp;

  const EventWithRsvp({required this.event, this.rsvp});

  /// Convenience getter – the user's RSVP status, if available.
  RsvpStatus? get rsvpStatus => rsvp?.status;

  /// Whether the user has responded to this event.
  bool get hasRsvp => rsvp != null;
}
