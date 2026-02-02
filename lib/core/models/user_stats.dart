/// User statistics model for gamification counters
///
/// Maps to the `user_stats` view in Supabase.
/// Contains read-only aggregated statistics about user activity.
class UserStats {
  /// Number of events the user has attended (RSVPed yes)
  final int eventsAttendedCount;

  /// Number of registry items the user has purchased
  final int itemsPurchasedCount;

  /// Number of photos the user has squished (liked)
  final int photosSquishedCount;

  /// Number of comments the user has added
  final int commentsAddedCount;

  /// Creates a new UserStats instance
  const UserStats({
    this.eventsAttendedCount = 0,
    this.itemsPurchasedCount = 0,
    this.photosSquishedCount = 0,
    this.commentsAddedCount = 0,
  });

  /// Creates a UserStats from a JSON map
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      eventsAttendedCount: json['events_attended_count'] as int? ?? 0,
      itemsPurchasedCount: json['items_purchased_count'] as int? ?? 0,
      photosSquishedCount: json['photos_squished_count'] as int? ?? 0,
      commentsAddedCount: json['comments_added_count'] as int? ?? 0,
    );
  }

  /// Converts this UserStats to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'events_attended_count': eventsAttendedCount,
      'items_purchased_count': itemsPurchasedCount,
      'photos_squished_count': photosSquishedCount,
      'comments_added_count': commentsAddedCount,
    };
  }

  /// Calculates the total activity count
  int get totalActivityCount =>
      eventsAttendedCount +
      itemsPurchasedCount +
      photosSquishedCount +
      commentsAddedCount;

  /// Checks if the user has any activity
  bool get hasActivity => totalActivityCount > 0;

  /// Validates the user stats data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (eventsAttendedCount < 0) {
      return 'Events attended count cannot be negative';
    }
    if (itemsPurchasedCount < 0) {
      return 'Items purchased count cannot be negative';
    }
    if (photosSquishedCount < 0) {
      return 'Photos squished count cannot be negative';
    }
    if (commentsAddedCount < 0) {
      return 'Comments added count cannot be negative';
    }
    return null;
  }

  /// Creates a copy of this UserStats with the specified fields replaced
  UserStats copyWith({
    int? eventsAttendedCount,
    int? itemsPurchasedCount,
    int? photosSquishedCount,
    int? commentsAddedCount,
  }) {
    return UserStats(
      eventsAttendedCount: eventsAttendedCount ?? this.eventsAttendedCount,
      itemsPurchasedCount: itemsPurchasedCount ?? this.itemsPurchasedCount,
      photosSquishedCount: photosSquishedCount ?? this.photosSquishedCount,
      commentsAddedCount: commentsAddedCount ?? this.commentsAddedCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserStats &&
        other.eventsAttendedCount == eventsAttendedCount &&
        other.itemsPurchasedCount == itemsPurchasedCount &&
        other.photosSquishedCount == photosSquishedCount &&
        other.commentsAddedCount == commentsAddedCount;
  }

  @override
  int get hashCode {
    return eventsAttendedCount.hashCode ^
        itemsPurchasedCount.hashCode ^
        photosSquishedCount.hashCode ^
        commentsAddedCount.hashCode;
  }

  @override
  String toString() {
    return 'UserStats(eventsAttendedCount: $eventsAttendedCount, itemsPurchasedCount: $itemsPurchasedCount, photosSquishedCount: $photosSquishedCount, commentsAddedCount: $commentsAddedCount)';
  }
}
