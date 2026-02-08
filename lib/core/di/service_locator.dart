import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../services/database_service.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../services/observability_service.dart';
import '../services/realtime_service.dart';
import '../services/storage_service.dart';
import 'providers.dart';

/// Service locator for manual dependency injection and testing
///
/// **Functional Requirements**: Section 3.5.1 - Core Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Provides:
/// - Manual service registration and retrieval
/// - Provider overrides for testing
/// - Lazy initialization
/// - Service lifecycle management
///
/// Usage:
/// ```dart
/// // Initialize the service locator
/// await ServiceLocator.initialize();
///
/// // Get a service
/// final authService = ServiceLocator.get<AuthService>();
///
/// // In tests, override providers
/// final container = ProviderContainer(
///   overrides: ServiceLocator.getTestOverrides(),
/// );
/// ```
///
/// Dependencies: All core services, providers.dart
class ServiceLocator {
  // Private constructor to prevent instantiation
  ServiceLocator._();

  // Service registry
  static final Map<Type, dynamic> _services = {};
  static bool _isInitialized = false;

  /// Check if the service locator has been initialized
  static bool get isInitialized => _isInitialized;

  // ==========================================
  // Initialization
  // ==========================================

  /// Initialize the service locator
  ///
  /// Registers all core services for manual dependency injection.
  /// Must be called before using [get] method.
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️  ServiceLocator already initialized');
      return;
    }

    try {
      debugPrint('🔧 Initializing ServiceLocator...');

      // Register services in dependency order
      _registerCoreServices();
      _registerDataServices();
      _registerRealtimeServices();
      _registerMonitoringServices();

      // Initialize services that require async initialization
      await _initializeAsyncServices();

      _isInitialized = true;
      debugPrint('✅ ServiceLocator initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing ServiceLocator: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Register core services
  static void _registerCoreServices() {
    register<AuthService>(AuthService());
  }

  /// Register data services
  static void _registerDataServices() {
    register<DatabaseService>(DatabaseService());
    register<CacheService>(CacheService());
    register<LocalStorageService>(LocalStorageService());
    register<StorageService>(StorageService());
  }

  /// Register realtime and notification services
  static void _registerRealtimeServices() {
    register<RealtimeService>(RealtimeService());
    register<NotificationService>(NotificationService.instance);
  }

  /// Register monitoring and analytics services
  static void _registerMonitoringServices() {
    register<AnalyticsService>(AnalyticsService.instance);
    register<ObservabilityService>(ObservabilityService());
  }

  /// Initialize services that require async initialization
  static Future<void> _initializeAsyncServices() async {
    // Initialize cache service
    final cacheService = get<CacheService>();
    if (!cacheService.isInitialized) {
      await cacheService.initialize();
    }

    // Initialize local storage service
    final localStorageService = get<LocalStorageService>();
    if (!localStorageService.isInitialized) {
      await localStorageService.initialize();
    }
  }

  // ==========================================
  // Service Registration
  // ==========================================

  /// Register a service instance
  ///
  /// [service] The service instance to register
  ///
  /// Example:
  /// ```dart
  /// ServiceLocator.register<MyService>(MyService());
  /// ```
  static void register<T>(T service) {
    _services[T] = service;
    debugPrint('✅ Registered service: $T');
  }

  /// Register a lazy service factory
  ///
  /// The service will be created only when first accessed.
  ///
  /// [factory] Function that creates the service instance
  ///
  /// Example:
  /// ```dart
  /// ServiceLocator.registerLazy<MyService>(() => MyService());
  /// ```
  static void registerLazy<T>(T Function() factory) {
    _services[T] = factory;
    debugPrint('✅ Registered lazy service: $T');
  }

  /// Unregister a service
  ///
  /// Removes the service from the registry.
  /// Useful for cleanup or testing.
  static void unregister<T>() {
    _services.remove(T);
    debugPrint('✅ Unregistered service: $T');
  }

  // ==========================================
  // Service Retrieval
  // ==========================================

  /// Get a registered service instance
  ///
  /// Returns the service instance or throws if not registered.
  ///
  /// Example:
  /// ```dart
  /// final authService = ServiceLocator.get<AuthService>();
  /// ```
  static T get<T>() {
    final service = _services[T];

    if (service == null) {
      throw Exception(
        'Service of type $T is not registered. '
        'Did you forget to call ServiceLocator.initialize()?',
      );
    }

    // If it's a factory function, call it and cache the result
    if (service is T Function()) {
      final instance = service();
      _services[T] = instance;
      return instance;
    }

    return service as T;
  }

  /// Try to get a registered service instance
  ///
  /// Returns the service instance or null if not registered.
  ///
  /// Example:
  /// ```dart
  /// final authService = ServiceLocator.tryGet<AuthService>();
  /// if (authService != null) {
  ///   // Use the service
  /// }
  /// ```
  static T? tryGet<T>() {
    try {
      return get<T>();
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // Testing Support
  // ==========================================

  /// Get provider overrides for testing
  ///
  /// Returns a list of provider overrides that can be used
  /// to replace real services with mocks in tests.
  ///
  /// Example:
  /// ```dart
  /// final container = ProviderContainer(
  ///   overrides: ServiceLocator.getTestOverrides(
  ///     mockAuth: mockAuthService,
  ///     mockDatabase: mockDatabaseService,
  ///   ),
  /// );
  /// ```
  static List<Override> getTestOverrides({
    AuthService? mockAuth,
    DatabaseService? mockDatabase,
    CacheService? mockCache,
    StorageService? mockStorage,
    RealtimeService? mockRealtime,
    NotificationService? mockNotification,
    AnalyticsService? mockAnalytics,
    ObservabilityService? mockObservability,
    LocalStorageService? mockLocalStorage,
  }) {
    final overrides = <Override>[];

    if (mockAuth != null) {
      overrides.add(authServiceProvider.overrideWithValue(mockAuth));
    }

    if (mockDatabase != null) {
      overrides.add(databaseServiceProvider.overrideWithValue(mockDatabase));
    }

    if (mockCache != null) {
      overrides.add(cacheServiceProvider.overrideWithValue(mockCache));
    }

    if (mockStorage != null) {
      overrides.add(storageServiceProvider.overrideWithValue(mockStorage));
    }

    if (mockRealtime != null) {
      overrides.add(realtimeServiceProvider.overrideWithValue(mockRealtime));
    }

    if (mockNotification != null) {
      overrides
          .add(notificationServiceProvider.overrideWithValue(mockNotification));
    }

    if (mockAnalytics != null) {
      overrides.add(analyticsServiceProvider.overrideWithValue(mockAnalytics));
    }

    if (mockObservability != null) {
      overrides.add(
        observabilityServiceProvider.overrideWithValue(mockObservability),
      );
    }

    if (mockLocalStorage != null) {
      overrides.add(
        localStorageServiceProvider.overrideWithValue(mockLocalStorage),
      );
    }

    return overrides;
  }

  /// Reset the service locator
  ///
  /// Clears all registered services and resets initialization state.
  /// Useful for testing to ensure a clean state between tests.
  static void reset() {
    _services.clear();
    _isInitialized = false;
    debugPrint('✅ ServiceLocator reset');
  }

  /// Dispose all services
  ///
  /// Calls dispose on services that support it (CacheService, etc.).
  /// Should be called when the app is closing.
  static Future<void> dispose() async {
    try {
      // Dispose cache service
      final cacheService = tryGet<CacheService>();
      if (cacheService != null && cacheService.isInitialized) {
        await cacheService.dispose();
      }

      // Local storage service doesn't have dispose method
      // It uses SharedPreferences which doesn't need explicit disposal

      debugPrint('✅ ServiceLocator disposed');
    } catch (e) {
      debugPrint('❌ Error disposing ServiceLocator: $e');
    }
  }
}
