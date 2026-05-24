/// Tile type enumeration for the dynamic tile system
///
/// **Functional Requirements**: Section 3.3.9 - Enums & Type Definitions
/// Reference: docs/Core_development_component_identification.md
///
/// Defines all tile types available in the Nonna app's dynamic tile system.
/// Each tile type corresponds to a specific tile implementation and matches
/// the cases handled by TileFactory.
///
/// Tile categories:
/// - Event tiles (upcomingEvents, rsvpTasks)
/// - Photo tiles (recentPhotos, galleryFavorites)
/// - Registry tiles (registryHighlights, recentPurchases)
/// - Notification tiles (notifications, systemAnnouncements)
/// - Status tiles (invitesStatus, countdown, storageUsage)
/// - Engagement tiles (activityList, newFollowers)
/// - Utility tiles (checklist)
///
/// Dependencies: None
enum TileType {
  /// Upcoming events tile - shows calendar events
  upcomingEvents,

  /// Recent photos tile - displays latest gallery photos
  recentPhotos,

  /// Registry highlights tile - featured registry items
  registryHighlights,

  /// Notifications tile - app notifications
  notifications,

  /// Registry list tile - full list of registry items
  registryList,

  /// Invites status tile - invitation management
  invitesStatus,

  /// RSVP tasks tile - events requiring RSVP
  rsvpTasks,

  /// Due date countdown tile - countdown to baby's due date
  countdown,

  /// Recent purchases tile - recently purchased registry items
  recentPurchases,

  /// Engagement recap tile - activity summary
  activityList,

  /// Gallery favorites tile - favorited photos
  galleryFavorites,

  /// Checklist tile - task checklist
  checklist,

  /// Storage usage tile - storage space usage
  storageUsage,

  /// System announcements tile - important app announcements
  systemAnnouncements,

  /// New followers tile - recent follower activity
  newFollowers,

  /// Name suggestions tile - baby name suggestions
  nameSuggestions,

  /// Prediction votes tile - votes for baby gender/birthdate
  predictionVotes,

  /// New baby welcome tile - welcome announcement card
  newBabyWelcome;

  /// Convert the enum to a string representation
  String toJson() => name;

  /// Create a TileType from a string
  static TileType fromJson(String value) {
    return TileType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => TileType.upcomingEvents,
    );
  }

  /// Get a display-friendly name for the tile type
  String get displayName {
    switch (this) {
      case TileType.upcomingEvents:
        return 'Upcoming Events';
      case TileType.recentPhotos:
        return 'Recent Photos';
      case TileType.registryHighlights:
        return 'Registry Highlights';
      case TileType.notifications:
        return 'Notifications';
      case TileType.registryList:
        return 'Registry List';
      case TileType.invitesStatus:
        return 'Invites Status';
      case TileType.rsvpTasks:
        return 'RSVP Tasks';
      case TileType.countdown:
        return 'Due Date Countdown';
      case TileType.recentPurchases:
        return 'Recent Purchases';
      case TileType.activityList:
        return 'Engagement Recap';
      case TileType.galleryFavorites:
        return 'Gallery Favorites';
      case TileType.checklist:
        return 'Checklist';
      case TileType.storageUsage:
        return 'Storage Usage';
      case TileType.systemAnnouncements:
        return 'System Announcements';
      case TileType.newFollowers:
        return 'New Followers';
      case TileType.nameSuggestions:
        return 'Name Suggestions';
      case TileType.predictionVotes:
        return 'Prediction Votes';
      case TileType.newBabyWelcome:
        return 'New Baby Welcome';
    }
  }

  /// Get a description for the tile type
  String get description {
    switch (this) {
      case TileType.upcomingEvents:
        return 'View upcoming calendar events';
      case TileType.recentPhotos:
        return 'Browse recent photos from the gallery';
      case TileType.registryHighlights:
        return 'Featured items from your registry';
      case TileType.notifications:
        return 'App notifications and updates';
      case TileType.registryList:
        return 'Complete list of items in the registry';
      case TileType.invitesStatus:
        return 'Manage invitations';
      case TileType.rsvpTasks:
        return 'Events requiring RSVP';
      case TileType.countdown:
        return 'Countdown to baby\'s due date';
      case TileType.recentPurchases:
        return 'Recently purchased registry items';
      case TileType.activityList:
        return 'Summary of recent activity';
      case TileType.galleryFavorites:
        return 'Your favorite photos';
      case TileType.checklist:
        return 'Task checklist and reminders';
      case TileType.storageUsage:
        return 'Storage space usage information';
      case TileType.systemAnnouncements:
        return 'Important app announcements';
      case TileType.newFollowers:
        return 'Recent follower activity';
      case TileType.nameSuggestions:
        return 'Baby name suggestions';
      case TileType.predictionVotes:
        return 'Predictions for gender or birthdate';
      case TileType.newBabyWelcome:
        return 'Welcome card shown to the owner for 7 days after the baby\'s birth.';
    }
  }
}
