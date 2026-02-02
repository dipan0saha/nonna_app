import '../enums/rsvp_status.dart';

/// Event RSVP model representing a user's response to an event invitation
///
/// Maps to the `event_rsvps` table in Supabase.
/// Each user can have only one RSVP per event.
class EventRsvp {
  /// Unique RSVP identifier
  final String id;

  /// Event this RSVP is associated with
  final String eventId;

  /// User who created this RSVP
  final String userId;

  /// RSVP status (yes, no, maybe)
  final RsvpStatus status;

  /// Timestamp when the RSVP was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Creates a new EventRsvp instance
  const EventRsvp({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an EventRsvp from a JSON map
  factory EventRsvp.fromJson(Map<String, dynamic> json) {
    return EventRsvp(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      status: RsvpStatus.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this EventRsvp to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'status': status.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Validates the RSVP data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    // No specific validation needed beyond type checks
    return null;
  }

  /// Creates a copy of this EventRsvp with the specified fields replaced
  EventRsvp copyWith({
    String? id,
    String? eventId,
    String? userId,
    RsvpStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventRsvp(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventRsvp &&
        other.id == id &&
        other.eventId == eventId &&
        other.userId == userId &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        eventId.hashCode ^
        userId.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'EventRsvp(id: $id, eventId: $eventId, userId: $userId, status: ${status.displayName})';
  }
}
