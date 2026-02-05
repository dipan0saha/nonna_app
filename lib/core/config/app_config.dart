/// Application configuration
///
/// **Functional Requirements**: Section 3.3 - Configuration Management for Utils & Helpers
/// Reference: docs/Core_development_component_identification.md
///
/// Provides environment-specific configuration:
/// - Base URL for deep links
/// - Environment detection (dev, staging, prod)
/// - Feature flags
/// - API endpoints
///
/// No external dependencies
class AppConfig {
  // Prevent instantiation
  AppConfig._();

  // ============================================================
  // Environment Detection
  // ============================================================

  /// Current app environment
  static AppEnvironment get environment {
    // This can be configured via build flavors or environment variables
    // For now, default to production
    const String env = String.fromEnvironment('ENV', defaultValue: 'prod');

    switch (env.toLowerCase()) {
      case 'dev':
      case 'development':
        return AppEnvironment.development;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'prod':
      case 'production':
      default:
        return AppEnvironment.production;
    }
  }

  // ============================================================
  // Base URLs
  // ============================================================

  /// Base URL for the app (used in deep links and sharing)
  static String get baseUrl {
    switch (environment) {
      case AppEnvironment.development:
        return 'https://dev.nonna.app';
      case AppEnvironment.staging:
        return 'https://staging.nonna.app';
      case AppEnvironment.production:
        return 'https://nonna.app';
    }
  }

  /// API base URL (if different from web app)
  static String get apiBaseUrl {
    switch (environment) {
      case AppEnvironment.development:
        return 'https://api-dev.nonna.app';
      case AppEnvironment.staging:
        return 'https://api-staging.nonna.app';
      case AppEnvironment.production:
        return 'https://api.nonna.app';
    }
  }

  /// Web app URL (for browser redirects)
  static String get webAppUrl {
    switch (environment) {
      case AppEnvironment.development:
        return 'https://dev.nonna.app';
      case AppEnvironment.staging:
        return 'https://staging.nonna.app';
      case AppEnvironment.production:
        return 'https://nonna.app';
    }
  }

  // ============================================================
  // Feature Flags
  // ============================================================

  /// Enable debug logging
  static bool get debugLogging {
    return environment == AppEnvironment.development;
  }

  /// Enable analytics
  static bool get analyticsEnabled {
    return environment != AppEnvironment.development;
  }

  /// Enable crash reporting
  static bool get crashReportingEnabled {
    return environment == AppEnvironment.production;
  }

  /// Enable beta features
  static bool get betaFeaturesEnabled {
    return environment == AppEnvironment.development ||
        environment == AppEnvironment.staging;
  }

  // ============================================================
  // App Information
  // ============================================================

  /// App name
  static const String appName = 'Nonna';

  /// App tagline
  static const String appTagline = 'Share your baby\'s journey';

  /// Support email
  static const String supportEmail = 'support@nonna.app';

  /// Privacy policy URL
  static String get privacyPolicyUrl => '$webAppUrl/privacy';

  /// Terms of service URL
  static String get termsOfServiceUrl => '$webAppUrl/terms';

  // ============================================================
  // Deep Link Configuration
  // ============================================================

  /// Deep link scheme
  static const String deepLinkScheme = 'nonna';

  /// Deep link host
  static const String deepLinkHost = 'app';

  /// Universal link domains
  static List<String> get universalLinkDomains {
    switch (environment) {
      case AppEnvironment.development:
        return ['dev.nonna.app'];
      case AppEnvironment.staging:
        return ['staging.nonna.app'];
      case AppEnvironment.production:
        return ['nonna.app', 'www.nonna.app'];
    }
  }

  // ============================================================
  // Share Configuration
  // ============================================================

  /// Default share message
  static const String defaultShareMessage = 'Check this out on Nonna! 👶';

  /// App Store URL (iOS)
  static const String appStoreUrl =
      'https://apps.apple.com/app/nonna/id123456789';

  /// Play Store URL (Android)
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.nonna.app';

  /// Share referral tracking enabled
  static bool get shareReferralTracking {
    return environment == AppEnvironment.production;
  }

  // ============================================================
  // Cache Configuration
  // ============================================================

  /// Maximum cache size in MB
  static int get maxCacheSizeMB {
    switch (environment) {
      case AppEnvironment.development:
        return 50; // Smaller cache in dev
      case AppEnvironment.staging:
        return 100;
      case AppEnvironment.production:
        return 200;
    }
  }

  // ============================================================
  // Debugging & Testing
  // ============================================================

  /// Is development environment
  static bool get isDevelopment => environment == AppEnvironment.development;

  /// Is staging environment
  static bool get isStaging => environment == AppEnvironment.staging;

  /// Is production environment
  static bool get isProduction => environment == AppEnvironment.production;

  /// Environment name
  static String get environmentName => environment.name;

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Get full URL for a path
  static String getFullUrl(String path) {
    // Ensure path starts with /
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$cleanPath';
  }

  /// Get deep link URL for a path
  static String getDeepLinkUrl(String path) {
    // Ensure path starts with /
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$deepLinkScheme://$deepLinkHost$cleanPath';
  }
}

/// App environment enumeration
enum AppEnvironment {
  /// Development environment (local testing)
  development,

  /// Staging environment (pre-production testing)
  staging,

  /// Production environment (live app)
  production;

  /// Get display name
  String get displayName {
    switch (this) {
      case AppEnvironment.development:
        return 'Development';
      case AppEnvironment.staging:
        return 'Staging';
      case AppEnvironment.production:
        return 'Production';
    }
  }

  /// Get short name
  String get shortName {
    switch (this) {
      case AppEnvironment.development:
        return 'dev';
      case AppEnvironment.staging:
        return 'stage';
      case AppEnvironment.production:
        return 'prod';
    }
  }
}
