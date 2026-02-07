import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../services/database_service.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../services/observability_service.dart';
import '../services/realtime_service.dart';
import '../services/storage_service.dart';

/// Global providers for dependency injection throughout the app
///
/// **Functional Requirements**: Section 3.5.1 - Core Providers
/// Reference: docs/Core_development_component_identification.md
///
/// This file centralizes all singleton providers for core services:
/// - Supabase client and auth service
/// - Cache and storage services
/// - Database and realtime services
/// - Analytics and observability services
///
/// Provider Types:
/// - Provider: For immutable values and stateless services
/// - StateProvider: For simple mutable state
/// - FutureProvider: For async initialization
///
/// Dependencies: All core services (AuthService, CacheService, etc.)

// ==========================================
// Supabase Core Providers
// ==========================================

/// Provides the Supabase client instance
///
/// This is the foundation for all Supabase operations.
/// Auto-dispose is disabled as this should live for the app lifetime.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseClientManager.instance;
});

/// Provides the authentication service
///
/// Handles user authentication, OAuth flows, and session management.
/// Singleton pattern - one instance for the entire app.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ==========================================
// Data Services Providers
// ==========================================

/// Provides the database service
///
/// Handles all database queries, transactions, and RLS validation.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Provides the cache service
///
/// Manages local data caching with TTL and invalidation support.
/// Must be initialized before use.
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

/// Provides the local storage service
///
/// Handles persistent local storage using SharedPreferences and Hive.
/// Must be initialized before use.
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// Provides the storage service
///
/// Manages file uploads, downloads, and Supabase storage operations.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// ==========================================
// Real-Time & Notifications
// ==========================================

/// Provides the realtime service
///
/// Handles Supabase realtime subscriptions and updates.
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService();
});

/// Provides the notification service
///
/// Manages push notifications via OneSignal.
/// Singleton pattern - accessed via NotificationService.instance.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

// ==========================================
// Monitoring & Analytics
// ==========================================

/// Provides the analytics service
///
/// Tracks user events and app usage via Firebase Analytics.
/// Singleton pattern - accessed via AnalyticsService.instance.
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService.instance;
});

/// Provides the observability service
///
/// Handles error reporting and performance monitoring via Sentry.
final observabilityServiceProvider = Provider<ObservabilityService>((ref) {
  return ObservabilityService();
});

// ==========================================
// Auth State Provider
// ==========================================

/// Provides the current authentication state
///
/// Stream provider that emits auth state changes.
/// Auto-disposes when no longer watched.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provides the current authenticated user
///
/// Returns null if not authenticated.
/// Depends on authStateProvider to automatically update.
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// ==========================================
// Initialization State Provider
// ==========================================

/// Provider for tracking app initialization state
///
/// Manages the initialization of cache and local storage services.
/// Returns true when all services are initialized and ready.
final appInitializationProvider = FutureProvider<bool>((ref) async {
  // Initialize cache service
  final cacheService = ref.read(cacheServiceProvider);
  if (!cacheService.isInitialized) {
    await cacheService.initialize();
  }

  // Initialize local storage service
  final localStorageService = ref.read(localStorageServiceProvider);
  if (!localStorageService.isInitialized) {
    await localStorageService.initialize();
  }

  return true;
});

// ==========================================
// Helper Providers for Testing
// ==========================================

/// Provider family for creating scoped providers
///
/// Example usage:
/// ```dart
/// final myProvider = scopedProvider('my-scope');
/// ```
final scopedProvider = Provider.family<String, String>((ref, scope) {
  return scope;
});

/// Auto-dispose provider example
///
/// This provider automatically disposes when no longer used.
/// Useful for temporary data or one-off operations.
final autoDisposeExampleProvider = Provider.autoDispose<String>((ref) {
  // Clean up resources when disposed
  ref.onDispose(() {
    // Cleanup logic here
  });
  return 'auto-dispose-example';
});

// ==========================================
// Tile Providers (imported from tiles/core/providers)
// ==========================================
// Note: Tile providers are exported from this file for convenience
// but implemented in lib/tiles/core/providers/
//
// Import them as needed:
// import '../../tiles/core/providers/tile_config_provider.dart';
// import '../../tiles/core/providers/tile_visibility_provider.dart';
