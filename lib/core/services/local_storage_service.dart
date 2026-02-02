import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service for managing user preferences and app settings
/// 
/// Uses SharedPreferences for general data and FlutterSecureStorage for sensitive data
class LocalStorageService {
  SharedPreferences? _prefs;
  late FlutterSecureStorage _secureStorage;
  bool _isInitialized = false;

  /// Check if the service has been initialized
  bool get isInitialized => _isInitialized;

  // Storage keys
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyAnalyticsEnabled = 'analytics_enabled';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyLastSyncTimestamp = 'last_sync_timestamp';
  static const String _keySelectedBabyProfileId = 'selected_baby_profile_id';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyBiometricEnabled = 'biometric_enabled';

  // ==========================================
  // Initialization
  // ==========================================

  /// Initialize the local storage service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️  LocalStorageService already initialized');
      return;
    }

    try {
      _prefs = await SharedPreferences.getInstance();
      _secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );
      
      _isInitialized = true;
      
      debugPrint('✅ LocalStorageService initialized');
    } catch (e) {
      debugPrint('❌ Error initializing LocalStorageService: $e');
      rethrow;
    }
  }

  /// Ensure the service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'LocalStorageService not initialized. Call initialize() first.',
      );
    }
  }

  // ==========================================
  // Onboarding
  // ==========================================

  /// Check if onboarding is completed
  bool get isOnboardingCompleted {
    _ensureInitialized();
    return _prefs!.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted(bool completed) async {
    _ensureInitialized();
    await _prefs!.setBool(_keyOnboardingCompleted, completed);
  }

  // ==========================================
  // Theme
  // ==========================================

  /// Get the saved theme mode
  /// 
  /// Returns 'light', 'dark', or 'system'
  String get themeMode {
    _ensureInitialized();
    return _prefs!.getString(_keyThemeMode) ?? 'system';
  }

  /// Set the theme mode
  Future<void> setThemeMode(String mode) async {
    _ensureInitialized();
    await _prefs!.setString(_keyThemeMode, mode);
  }

  // ==========================================
  // Language
  // ==========================================

  /// Get the saved language code
  String? get languageCode {
    _ensureInitialized();
    return _prefs!.getString(_keyLanguageCode);
  }

  /// Set the language code
  Future<void> setLanguageCode(String code) async {
    _ensureInitialized();
    await _prefs!.setString(_keyLanguageCode, code);
  }

  // ==========================================
  // Analytics
  // ==========================================

  /// Check if analytics is enabled
  bool get isAnalyticsEnabled {
    _ensureInitialized();
    return _prefs!.getBool(_keyAnalyticsEnabled) ?? true;
  }

  /// Set analytics enabled status
  Future<void> setAnalyticsEnabled(bool enabled) async {
    _ensureInitialized();
    await _prefs!.setBool(_keyAnalyticsEnabled, enabled);
  }

  // ==========================================
  // Notifications
  // ==========================================

  /// Check if notifications are enabled
  bool get isNotificationsEnabled {
    _ensureInitialized();
    return _prefs!.getBool(_keyNotificationsEnabled) ?? true;
  }

  /// Set notifications enabled status
  Future<void> setNotificationsEnabled(bool enabled) async {
    _ensureInitialized();
    await _prefs!.setBool(_keyNotificationsEnabled, enabled);
  }

  // ==========================================
  // Sync
  // ==========================================

  /// Get last sync timestamp
  DateTime? get lastSyncTimestamp {
    _ensureInitialized();
    final timestamp = _prefs!.getInt(_keyLastSyncTimestamp);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Set last sync timestamp
  Future<void> setLastSyncTimestamp(DateTime timestamp) async {
    _ensureInitialized();
    await _prefs!.setInt(
      _keyLastSyncTimestamp,
      timestamp.millisecondsSinceEpoch,
    );
  }

  // ==========================================
  // Baby Profile Selection
  // ==========================================

  /// Get selected baby profile ID
  String? get selectedBabyProfileId {
    _ensureInitialized();
    return _prefs!.getString(_keySelectedBabyProfileId);
  }

  /// Set selected baby profile ID
  Future<void> setSelectedBabyProfileId(String? babyProfileId) async {
    _ensureInitialized();
    if (babyProfileId == null) {
      await _prefs!.remove(_keySelectedBabyProfileId);
    } else {
      await _prefs!.setString(_keySelectedBabyProfileId, babyProfileId);
    }
  }

  // ==========================================
  // Biometric Authentication
  // ==========================================

  /// Check if biometric authentication is enabled
  bool get isBiometricEnabled {
    _ensureInitialized();
    return _prefs!.getBool(_keyBiometricEnabled) ?? false;
  }

  /// Set biometric authentication enabled status
  Future<void> setBiometricEnabled(bool enabled) async {
    _ensureInitialized();
    await _prefs!.setBool(_keyBiometricEnabled, enabled);
  }

  // ==========================================
  // Secure Storage (for sensitive data)
  // ==========================================

  /// Save auth token securely
  Future<void> saveAuthToken(String token) async {
    _ensureInitialized();
    await _secureStorage.write(key: _keyAuthToken, value: token);
  }

  /// Get auth token
  Future<String?> getAuthToken() async {
    _ensureInitialized();
    return await _secureStorage.read(key: _keyAuthToken);
  }

  /// Delete auth token
  Future<void> deleteAuthToken() async {
    _ensureInitialized();
    await _secureStorage.delete(key: _keyAuthToken);
  }

  /// Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    _ensureInitialized();
    await _secureStorage.write(key: _keyRefreshToken, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    _ensureInitialized();
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    _ensureInitialized();
    await _secureStorage.delete(key: _keyRefreshToken);
  }

  /// Save secure value
  Future<void> saveSecure(String key, String value) async {
    _ensureInitialized();
    await _secureStorage.write(key: key, value: value);
  }

  /// Get secure value
  Future<String?> getSecure(String key) async {
    _ensureInitialized();
    return await _secureStorage.read(key: key);
  }

  /// Delete secure value
  Future<void> deleteSecure(String key) async {
    _ensureInitialized();
    await _secureStorage.delete(key: key);
  }

  // ==========================================
  // Generic Storage Methods
  // ==========================================

  /// Save string value
  Future<void> setString(String key, String value) async {
    _ensureInitialized();
    await _prefs!.setString(key, value);
  }

  /// Get string value
  String? getString(String key) {
    _ensureInitialized();
    return _prefs!.getString(key);
  }

  /// Save int value
  Future<void> setInt(String key, int value) async {
    _ensureInitialized();
    await _prefs!.setInt(key, value);
  }

  /// Get int value
  int? getInt(String key) {
    _ensureInitialized();
    return _prefs!.getInt(key);
  }

  /// Save bool value
  Future<void> setBool(String key, bool value) async {
    _ensureInitialized();
    await _prefs!.setBool(key, value);
  }

  /// Get bool value
  bool? getBool(String key) {
    _ensureInitialized();
    return _prefs!.getBool(key);
  }

  /// Save double value
  Future<void> setDouble(String key, double value) async {
    _ensureInitialized();
    await _prefs!.setDouble(key, value);
  }

  /// Get double value
  double? getDouble(String key) {
    _ensureInitialized();
    return _prefs!.getDouble(key);
  }

  /// Save string list
  Future<void> setStringList(String key, List<String> value) async {
    _ensureInitialized();
    await _prefs!.setStringList(key, value);
  }

  /// Get string list
  List<String>? getStringList(String key) {
    _ensureInitialized();
    return _prefs!.getStringList(key);
  }

  /// Remove a key
  Future<void> remove(String key) async {
    _ensureInitialized();
    await _prefs!.remove(key);
  }

  /// Check if a key exists
  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  /// Clear all preferences (except secure storage)
  Future<void> clearPreferences() async {
    _ensureInitialized();
    await _prefs!.clear();
  }

  /// Clear all secure storage
  Future<void> clearSecureStorage() async {
    _ensureInitialized();
    await _secureStorage.deleteAll();
  }

  /// Clear all data (preferences and secure storage)
  Future<void> clearAll() async {
    _ensureInitialized();
    await clearPreferences();
    await clearSecureStorage();
    debugPrint('✅ Cleared all local storage');
  }
}
