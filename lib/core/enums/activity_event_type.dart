/// Activity event type enumeration
///
/// **Functional Requirements**: Section 3.3.9 - Enums & Type Definitions
/// Reference: docs/Core_development_component_identification.md
///
/// Defines different types of activity events in the Nonna app.
/// Activity events track user actions within a baby profile for the
/// activity feed and engagement metrics.
///
/// Activity types:
/// - photoUploaded: Photo uploaded
/// - commentAdded: Comment added
/// - rsvpYes/rsvpNo/rsvpMaybe: RSVP responses
/// - itemPurchased: Registry item purchased
/// - eventCreated/eventUpdated: Event management
/// - photoSquished: Photo liked
/// - nameSuggested: Name suggestion added
/// - voteCast: Prediction vote cast
/// - followerAdded: New follower joined
///
/// Dependencies: None
enum ActivityEventType {
  /// Photo uploaded
  photoUploaded,

  /// Comment added
  commentAdded,

  /// RSVP yes response
  rsvpYes,

  /// RSVP no response
  rsvpNo,

  /// RSVP maybe response
  rsvpMaybe,

  /// Registry item purchased
  itemPurchased,

  /// Event created
  eventCreated,

  /// Event updated
  eventUpdated,

  /// Photo squished (liked)
  photoSquished,

  /// Name suggested
  nameSuggested,

  /// Vote cast
  voteCast,

  /// Member invited
  memberInvited,

  /// Member joined
  memberJoined,

  /// Profile updated
  profileUpdated,

  /// Photo tagged
  photoTagged;

  /// Convert the enum to a string representation
  String toJson() => name;

  /// Create an ActivityEventType from a string
  static ActivityEventType fromJson(String value) {
    return ActivityEventType.values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ActivityEventType.commentAdded,
    );
  }

  /// Get a display-friendly name for the activity event type
  String get displayName {
    switch (this) {
      case ActivityEventType.photoUploaded:
        return 'Photo Uploaded';
      case ActivityEventType.commentAdded:
        return 'Comment Added';
      case ActivityEventType.rsvpYes:
        return 'RSVP Yes';
      case ActivityEventType.rsvpNo:
        return 'RSVP No';
      case ActivityEventType.rsvpMaybe:
        return 'RSVP Maybe';
      case ActivityEventType.itemPurchased:
        return 'Item Purchased';
      case ActivityEventType.eventCreated:
        return 'Event Created';
      case ActivityEventType.eventUpdated:
        return 'Event Updated';
      case ActivityEventType.photoSquished:
        return 'Photo Liked';
      case ActivityEventType.nameSuggested:
        return 'Name Suggested';
      case ActivityEventType.voteCast:
        return 'Vote Cast';
      case ActivityEventType.memberInvited:
        return 'Member Invited';
      case ActivityEventType.memberJoined:
        return 'Member Joined';
      case ActivityEventType.profileUpdated:
        return 'Profile Updated';
      case ActivityEventType.photoTagged:
        return 'Photo Tagged';
    }
  }

  /// Get a description for the activity event type
  String get description {
    switch (this) {
      case ActivityEventType.photoUploaded:
        return 'A new photo was uploaded to the gallery';
      case ActivityEventType.commentAdded:
        return 'A comment was added';
      case ActivityEventType.rsvpYes:
        return 'Someone responded yes to an event';
      case ActivityEventType.rsvpNo:
        return 'Someone responded no to an event';
      case ActivityEventType.rsvpMaybe:
        return 'Someone responded maybe to an event';
      case ActivityEventType.itemPurchased:
        return 'A registry item was purchased';
      case ActivityEventType.eventCreated:
        return 'A new event was created';
      case ActivityEventType.eventUpdated:
        return 'An event was updated';
      case ActivityEventType.photoSquished:
        return 'Someone liked a photo';
      case ActivityEventType.nameSuggested:
        return 'A name was suggested';
      case ActivityEventType.voteCast:
        return 'A prediction vote was cast';
      case ActivityEventType.memberInvited:
        return 'A new member was invited';
      case ActivityEventType.memberJoined:
        return 'A new member joined';
      case ActivityEventType.profileUpdated:
        return 'The baby profile was updated';
      case ActivityEventType.photoTagged:
        return 'A photo was tagged';
    }
  }
}
