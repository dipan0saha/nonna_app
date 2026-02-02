/// Event model representing a calendar event in the Nonna app
///
/// Maps to the `events` table in Supabase.
/// Events are tied to a baby profile and can have RSVPs, comments, and other details.
class Event {
  /// Unique event identifier
  final String id;

  /// Baby profile this event is associated with
  final String babyProfileId;

  /// User who created this event
  final String createdByUserId;

  /// Event title
  final String title;

  /// Event start date and time
  final DateTime startsAt;

  /// Event end date and time
  final DateTime? endsAt;

  /// Event description
  final String? description;

  /// Event location
  final String? location;

  /// URL to video call link (e.g., Zoom, Google Meet)
  final String? videoLink;

  /// URL to event cover photo
  final String? coverPhotoUrl;

  /// Timestamp when the event was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Timestamp when the event was soft deleted (null if not deleted)
  final DateTime? deletedAt;

  /// Creates a new Event instance
  const Event({
    required this.id,
    required this.babyProfileId,
    required this.createdByUserId,
    required this.title,
    required this.startsAt,
    this.endsAt,
    this.description,
    this.location,
    this.videoLink,
    this.coverPhotoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Creates an Event from a JSON map
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      babyProfileId: json['baby_profile_id'] as String,
      createdByUserId: json['created_by_user_id'] as String,
      title: json['title'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: json['ends_at'] != null
          ? DateTime.parse(json['ends_at'] as String)
          : null,
      description: json['description'] as String?,
      location: json['location'] as String?,
      videoLink: json['video_link'] as String?,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  /// Converts this Event to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baby_profile_id': babyProfileId,
      'created_by_user_id': createdByUserId,
      'title': title,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'description': description,
      'location': location,
      'video_link': videoLink,
      'cover_photo_url': coverPhotoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Validates the event data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (title.trim().isEmpty) {
      return 'Event title is required';
    }
    if (title.length > 200) {
      return 'Event title must be 200 characters or less';
    }
    if (endsAt != null && endsAt!.isBefore(startsAt)) {
      return 'Event end time must be after start time';
    }
    if (startsAt.isBefore(DateTime.now().subtract(const Duration(days: 365)))) {
      return 'Event start time cannot be more than a year in the past';
    }
    if (description != null && description!.length > 2000) {
      return 'Event description must be 2000 characters or less';
    }
    if (location != null && location!.length > 500) {
      return 'Event location must be 500 characters or less';
    }
    return null;
  }

  /// Checks if the event is soft deleted
  bool get isDeleted => deletedAt != null;

  /// Checks if the event has ended
  bool get hasEnded {
    final endTime = endsAt ?? startsAt;
    return endTime.isBefore(DateTime.now());
  }

  /// Checks if the event is ongoing
  bool get isOngoing {
    final now = DateTime.now();
    final endTime = endsAt ?? startsAt;
    return startsAt.isBefore(now) && endTime.isAfter(now);
  }

  /// Checks if the event is upcoming
  bool get isUpcoming => startsAt.isAfter(DateTime.now());

  /// Duration of the event
  Duration? get duration {
    if (endsAt == null) return null;
    return endsAt!.difference(startsAt);
  }

  /// Creates a copy of this Event with the specified fields replaced
  Event copyWith({
    String? id,
    String? babyProfileId,
    String? createdByUserId,
    String? title,
    DateTime? startsAt,
    DateTime? endsAt,
    String? description,
    String? location,
    String? videoLink,
    String? coverPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Event(
      id: id ?? this.id,
      babyProfileId: babyProfileId ?? this.babyProfileId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      title: title ?? this.title,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      description: description ?? this.description,
      location: location ?? this.location,
      videoLink: videoLink ?? this.videoLink,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Event &&
        other.id == id &&
        other.babyProfileId == babyProfileId &&
        other.createdByUserId == createdByUserId &&
        other.title == title &&
        other.startsAt == startsAt &&
        other.endsAt == endsAt &&
        other.description == description &&
        other.location == location &&
        other.videoLink == videoLink &&
        other.coverPhotoUrl == coverPhotoUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        babyProfileId.hashCode ^
        createdByUserId.hashCode ^
        title.hashCode ^
        startsAt.hashCode ^
        endsAt.hashCode ^
        description.hashCode ^
        location.hashCode ^
        videoLink.hashCode ^
        coverPhotoUrl.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, startsAt: $startsAt, endsAt: $endsAt)';
  }
}
