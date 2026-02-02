import 'dart:convert';
import '../enums/activity_event_type.dart';

/// Activity event model representing an activity log entry
///
/// Maps to the `activity_events` table in Supabase.
/// Activity events track user actions and are auto-created via triggers.
/// Supports realtime updates.
class ActivityEvent {
  /// Unique activity event identifier
  final String id;

  /// Baby profile this activity is associated with
  final String babyProfileId;

  /// User who performed this activity
  final String actorUserId;

  /// Type of activity event
  final ActivityEventType type;

  /// Additional payload data in JSON format
  final Map<String, dynamic>? payload;

  /// Timestamp when the activity was created
  final DateTime createdAt;

  /// Creates a new ActivityEvent instance
  const ActivityEvent({
    required this.id,
    required this.babyProfileId,
    required this.actorUserId,
    required this.type,
    this.payload,
    required this.createdAt,
  });

  /// Creates an ActivityEvent from a JSON map
  factory ActivityEvent.fromJson(Map<String, dynamic> json) {
    return ActivityEvent(
      id: json['id'] as String,
      babyProfileId: json['baby_profile_id'] as String,
      actorUserId: json['actor_user_id'] as String,
      type: ActivityEventType.fromJson(json['type'] as String),
      payload: json['payload'] != null
          ? (json['payload'] is String
              ? jsonDecode(json['payload'] as String) as Map<String, dynamic>
              : json['payload'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this ActivityEvent to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baby_profile_id': babyProfileId,
      'actor_user_id': actorUserId,
      'type': type.toJson(),
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Validates the activity event data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (babyProfileId.trim().isEmpty) {
      return 'Baby profile ID is required';
    }
    if (actorUserId.trim().isEmpty) {
      return 'Actor user ID is required';
    }
    return null;
  }

  /// Checks if the activity event has a payload
  bool get hasPayload => payload != null && payload!.isNotEmpty;

  /// Gets a display message for the activity event
  String get displayMessage {
    return type.description;
  }

  /// Creates a copy of this ActivityEvent with the specified fields replaced
  ActivityEvent copyWith({
    String? id,
    String? babyProfileId,
    String? actorUserId,
    ActivityEventType? type,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
  }) {
    return ActivityEvent(
      id: id ?? this.id,
      babyProfileId: babyProfileId ?? this.babyProfileId,
      actorUserId: actorUserId ?? this.actorUserId,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ActivityEvent &&
        other.id == id &&
        other.babyProfileId == babyProfileId &&
        other.actorUserId == actorUserId &&
        other.type == type &&
        _mapEquals(other.payload, payload) &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        babyProfileId.hashCode ^
        actorUserId.hashCode ^
        type.hashCode ^
        (payload != null ? Object.hashAll(payload!.entries) : 0) ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'ActivityEvent(id: $id, babyProfileId: $babyProfileId, actorUserId: $actorUserId, type: $type)';
  }

  /// Helper method to compare two maps for equality
  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
