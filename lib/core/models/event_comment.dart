/// Event comment model representing a comment on an event
///
/// Maps to the `event_comments` table in Supabase.
/// Supports soft deletion with moderation tracking.
class EventComment {
  /// Unique comment identifier
  final String id;

  /// Event this comment is associated with
  final String eventId;

  /// User who created this comment
  final String userId;

  /// Comment body/text
  final String body;

  /// Timestamp when the comment was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Timestamp when the comment was soft deleted (null if not deleted)
  final DateTime? deletedAt;

  /// User who deleted this comment (null if not deleted)
  final String? deletedByUserId;

  /// Creates a new EventComment instance
  const EventComment({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deletedByUserId,
  });

  /// Creates an EventComment from a JSON map
  factory EventComment.fromJson(Map<String, dynamic> json) {
    return EventComment(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      deletedByUserId: json['deleted_by_user_id'] as String?,
    );
  }

  /// Converts this EventComment to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by_user_id': deletedByUserId,
    };
  }

  /// Validates the comment data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (body.trim().isEmpty) {
      return 'Comment body is required';
    }
    if (body.length > 1000) {
      return 'Comment body must be 1000 characters or less';
    }
    if (deletedAt != null && deletedByUserId == null) {
      return 'Deleted by user ID is required when comment is deleted';
    }
    return null;
  }

  /// Checks if the comment is soft deleted
  bool get isDeleted => deletedAt != null;

  /// Creates a copy of this EventComment with the specified fields replaced
  EventComment copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? deletedByUserId,
  }) {
    return EventComment(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedByUserId: deletedByUserId ?? this.deletedByUserId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventComment &&
        other.id == id &&
        other.eventId == eventId &&
        other.userId == userId &&
        other.body == body &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt &&
        other.deletedByUserId == deletedByUserId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        eventId.hashCode ^
        userId.hashCode ^
        body.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode ^
        deletedByUserId.hashCode;
  }

  @override
  String toString() {
    return 'EventComment(id: $id, eventId: $eventId, userId: $userId, isDeleted: $isDeleted)';
  }
}
