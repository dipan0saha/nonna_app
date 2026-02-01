/// Screen name enumeration for navigation and routing
///
/// Defines all main screens in the Nonna app.
/// Used for type-safe navigation and route mapping.
enum ScreenName {
  /// Home screen - dashboard with dynamic tiles
  home,

  /// Calendar screen - event calendar and management
  calendar,

  /// Gallery screen - photo gallery
  gallery,

  /// Registry screen - baby registry
  registry,

  /// Fun screen - gamification features (voting, name suggestions)
  fun,

  /// Profile screen - user profile
  profile,

  /// Baby profile screen - baby profile management
  babyProfile,

  /// Settings screen - app settings
  settings,

  /// Notifications screen - notification center
  notifications;

  /// Convert the enum to a string representation
  String toJson() => name;

  /// Create a ScreenName from a string
  static ScreenName fromJson(String value) {
    return ScreenName.values.firstWhere(
      (screen) => screen.name == value.toLowerCase(),
      orElse: () => ScreenName.home,
    );
  }

  /// Get the route path for this screen
  String get route {
    switch (this) {
      case ScreenName.home:
        return '/';
      case ScreenName.calendar:
        return '/calendar';
      case ScreenName.gallery:
        return '/gallery';
      case ScreenName.registry:
        return '/registry';
      case ScreenName.fun:
        return '/fun';
      case ScreenName.profile:
        return '/profile';
      case ScreenName.babyProfile:
        return '/baby-profile';
      case ScreenName.settings:
        return '/settings';
      case ScreenName.notifications:
        return '/notifications';
    }
  }

  /// Get a display-friendly name for the screen
  String get displayName {
    switch (this) {
      case ScreenName.home:
        return 'Home';
      case ScreenName.calendar:
        return 'Calendar';
      case ScreenName.gallery:
        return 'Gallery';
      case ScreenName.registry:
        return 'Registry';
      case ScreenName.fun:
        return 'Fun';
      case ScreenName.profile:
        return 'Profile';
      case ScreenName.babyProfile:
        return 'Baby Profile';
      case ScreenName.settings:
        return 'Settings';
      case ScreenName.notifications:
        return 'Notifications';
    }
  }
}
