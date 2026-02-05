import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'database_service.dart';

/// Service for managing force update mechanism
///
/// Checks app version against minimum required version from Supabase
/// and determines if the user needs to update the app
class ForceUpdateService {
  final DatabaseService _databaseService;

  ForceUpdateService({
    DatabaseService? databaseService,
  }) : _databaseService = databaseService ?? DatabaseService() {
    if (databaseService == null) {
      debugPrint(
          '⚠️  ForceUpdateService: Creating new DatabaseService instance. Consider using dependency injection.');
    }
  }

  // ==========================================
  // Version Checking
  // ==========================================

  /// Check if app needs to be updated
  ///
  /// Returns true if the current app version is below the minimum required version
  Future<bool> needsUpdate() async {
    try {
      final currentVersion = await _getCurrentAppVersion();
      final minVersion = await _getMinimumRequiredVersion();

      if (minVersion == null) {
        // No minimum version set, no update required
        return false;
      }

      return _isVersionLessThan(currentVersion, minVersion);
    } catch (e) {
      debugPrint('❌ Error checking for updates: $e');
      // Don't force update if there's an error checking
      return false;
    }
  }

  /// Get current app version from package info
  Future<String> _getCurrentAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Get minimum required version from Supabase
  Future<String?> _getMinimumRequiredVersion() async {
    try {
      final platform = _getPlatform();
      if (platform == null) {
        // Unsupported platform, skip version check
        return null;
      }

      final response = await _databaseService
          .select('app_versions', columns: 'minimum_version, platform')
          .eq('platform', platform)
          .single();

      return response['minimum_version'] as String?;
    } catch (e) {
      debugPrint('❌ Error fetching minimum version: $e');
      return null;
    }
  }

  /// Get the current platform string
  String? _getPlatform() {
    // Handle web platform explicitly
    if (kIsWeb) {
      return 'web';
    }

    // Handle native platforms
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 'macos';
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      return 'windows';
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      return 'linux';
    }

    // Return null for unsupported platforms to skip version check
    return null;
  }

  // ==========================================
  // Version Comparison
  // ==========================================

  /// Compare two semantic version strings
  ///
  /// Returns true if [current] is less than [minimum]
  bool _isVersionLessThan(String current, String minimum) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final minimumParts = minimum.split('.').map(int.parse).toList();

      // Ensure both versions have at least 3 parts (major.minor.patch)
      while (currentParts.length < 3) {
        currentParts.add(0);
      }
      while (minimumParts.length < 3) {
        minimumParts.add(0);
      }

      // Compare major, minor, and patch versions
      for (var i = 0; i < 3; i++) {
        if (currentParts[i] < minimumParts[i]) {
          return true;
        } else if (currentParts[i] > minimumParts[i]) {
          return false;
        }
      }

      // Versions are equal
      return false;
    } catch (e) {
      debugPrint('❌ Error comparing versions: $e');
      // If there's an error parsing versions, assume no update needed
      return false;
    }
  }

  // ==========================================
  // Store Links
  // ==========================================

  /// Get the app store URL for the current platform
  Future<String?> getStoreUrl() async {
    try {
      final platform = _getPlatform();
      if (platform == null) {
        return null;
      }

      final response = await _databaseService
          .select('app_versions', columns: 'store_url, platform')
          .eq('platform', platform)
          .single();

      return response['store_url'] as String?;
    } catch (e) {
      debugPrint('❌ Error fetching store URL: $e');
      return null;
    }
  }

  // ==========================================
  // Development Bypass
  // ==========================================

  /// Check if force update should be bypassed for development
  ///
  /// Returns true in debug mode to allow testing without updates
  bool shouldBypassForDevelopment() {
    return kDebugMode;
  }

  // ==========================================
  // Update Check with Bypass
  // ==========================================

  /// Check if update is required, respecting development bypass
  Future<bool> shouldShowUpdatePrompt() async {
    if (shouldBypassForDevelopment()) {
      return false;
    }

    return await needsUpdate();
  }

  // ==========================================
  // Update Info
  // ==========================================

  /// Get full update information
  Future<UpdateInfo?> getUpdateInfo() async {
    try {
      final platform = _getPlatform();
      if (platform == null) {
        final currentVersion = await _getCurrentAppVersion();
        return UpdateInfo(
          currentVersion: currentVersion,
          minimumVersion: null,
          needsUpdate: false,
          storeUrl: null,
        );
      }

      final currentVersion = await _getCurrentAppVersion();

      // Fetch app_versions row once
      final response = await _databaseService
          .select('app_versions',
              columns: 'minimum_version, store_url, platform')
          .eq('platform', platform)
          .single();

      final minVersion = response['minimum_version'] as String?;
      final storeUrl = response['store_url'] as String?;

      // Calculate needsUpdate from the fetched data
      final needsUpdateFlag = minVersion != null
          ? _isVersionLessThan(currentVersion, minVersion)
          : false;

      return UpdateInfo(
        currentVersion: currentVersion,
        minimumVersion: minVersion,
        needsUpdate: needsUpdateFlag,
        storeUrl: storeUrl,
      );
    } catch (e) {
      debugPrint('❌ Error getting update info: $e');
      return null;
    }
  }
}

/// Model for update information
class UpdateInfo {
  final String currentVersion;
  final String? minimumVersion;
  final bool needsUpdate;
  final String? storeUrl;

  UpdateInfo({
    required this.currentVersion,
    required this.minimumVersion,
    required this.needsUpdate,
    required this.storeUrl,
  });

  @override
  String toString() {
    return 'UpdateInfo(currentVersion: $currentVersion, minimumVersion: $minimumVersion, needsUpdate: $needsUpdate, storeUrl: $storeUrl)';
  }
}
