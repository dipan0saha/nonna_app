/// Tile type enumeration for the dynamic tile system
///
/// Defines all tile types available in the Nonna app.
/// Each tile type corresponds to a specific tile implementation.
enum TileType {
  /// Upcoming events tile - shows calendar events
  upcomingEvents,

  /// Recent photos tile - displays latest gallery photos
  recentPhotos,

  /// Registry highlights tile - featured registry items
  registryHighlights,

  /// Notifications tile - app notifications
  notifications,

  /// Invites status tile - invitation management
  invitesStatus,

  /// RSVP tasks tile - events requiring RSVP
  rsvpTasks,

  /// Due date countdown tile - countdown to baby's due date
  dueDateCountdown,

  /// Recent purchases tile - recently purchased registry items
  recentPurchases,

  /// Registry deals tile - special offers on registry items
  registryDeals,

  /// Engagement recap tile - activity summary
  engagementRecap,

  /// Gallery favorites tile - favorited photos
  galleryFavorites,

  /// Checklist tile - task checklist
  checklist,

  /// Storage usage tile - storage space usage
  storageUsage,

  /// System announcements tile - important app announcements
  systemAnnouncements,

  /// New followers tile - recent follower activity
  newFollowers;

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
      case TileType.invitesStatus:
        return 'Invites Status';
      case TileType.rsvpTasks:
        return 'RSVP Tasks';
      case TileType.dueDateCountdown:
        return 'Due Date Countdown';
      case TileType.recentPurchases:
        return 'Recent Purchases';
      case TileType.registryDeals:
        return 'Registry Deals';
      case TileType.engagementRecap:
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
      case TileType.invitesStatus:
        return 'Manage invitations';
      case TileType.rsvpTasks:
        return 'Events requiring RSVP';
      case TileType.dueDateCountdown:
        return 'Countdown to baby\'s due date';
      case TileType.recentPurchases:
        return 'Recently purchased registry items';
      case TileType.registryDeals:
        return 'Special offers on registry items';
      case TileType.engagementRecap:
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
    }
  }
}
