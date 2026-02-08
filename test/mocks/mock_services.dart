import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core App Services
import 'package:nonna_app/core/services/analytics_service.dart';
import 'package:nonna_app/core/services/auth_service.dart';
import 'package:nonna_app/core/services/backup_service.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/local_storage_service.dart';
import 'package:nonna_app/core/services/notification_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/core/services/storage_service.dart';
import 'package:nonna_app/core/services/supabase_service.dart';

/// Centralized Mock Generation
///
/// This file generates all mocks used across the test suite.
/// All tests should import mocks from this single location to ensure consistency.
///
/// To regenerate mocks after changes, run:
/// ```
/// flutter pub run build_runner build --delete-conflicting-outputs
/// ```
///
/// Generated mocks will be available in `mock_services.mocks.dart`
///
/// IMPORTANT: The import below is a forward reference to the generated file
/// which doesn't exist until build_runner is executed.
// ignore: unused_import
import 'mock_services.mocks.dart';

@GenerateMocks([
  // ==========================================
  // Supabase Core Components
  // ==========================================
  SupabaseClient,
  GoTrueClient,
  User,
  Session,
  AuthResponse,
  RealtimeClient,
  RealtimeChannel,
  SupabaseStorageClient,
  StorageFileApi,
  PostgrestClient,
  PostgrestFilterBuilder,
  PostgrestTransformBuilder,
  PostgrestBuilder,

  // ==========================================
  // Firebase Components
  // ==========================================
  FirebaseAnalytics,

  // ==========================================
  // App Services - Core Infrastructure
  // ==========================================
  AnalyticsService,
  AuthService,
  DatabaseService,
  CacheService,
  LocalStorageService,
  RealtimeService,
  StorageService,
  SupabaseService,

  // ==========================================
  // App Services - Additional Features
  // ==========================================
  BackupService,
  NotificationService,

  // ==========================================
  // System Components (for file operations)
  // ==========================================
  File,
])
void _dummyFunction() {
  // This empty function is required for the @GenerateMocks annotation
}

/// Mock Services Documentation
///
/// ## Usage Examples
///
/// ### Basic Mock Setup
/// ```dart
/// import 'package:nonna_app/test/mocks/mock_services.mocks.dart';
/// import 'package:nonna_app/test/helpers/mock_factory.dart';
///
/// void main() {
///   group('MyTest', () {
///     late MockDatabaseService mockDatabase;
///
///     setUp(() {
///       mockDatabase = MockFactory.createDatabaseService();
///     });
///   });
/// }
/// ```
///
/// ### Using Mock Factory for Common Scenarios
/// ```dart
/// // Create a complete mock service container
/// final mocks = MockFactory.createServiceContainer();
///
/// // Access individual services
/// mocks.database
/// mocks.cache
/// mocks.realtime
/// mocks.storage
/// ```
///
/// ### Configuring Mock Behaviors
/// ```dart
/// import 'package:mockito/mockito.dart';
///
/// // Configure database mock
/// when(mockDatabase.select(any))
///   .thenAnswer((_) => FakePostgrestBuilder([...]));
///
/// // Configure cache mock
/// when(mockCache.get(any))
///   .thenAnswer((_) async => testData);
///
/// // Configure realtime mock
/// when(mockRealtime.subscribe(
///   table: anyNamed('table'),
///   channelName: anyNamed('channelName'),
/// )).thenReturn(Stream.value(testData));
/// ```
///
/// ## Best Practices
///
/// 1. **Always use centralized mocks** from this file instead of creating
///    new @GenerateMocks annotations in individual test files
///
/// 2. **Use MockFactory** helpers to get pre-configured mocks for common
///    scenarios rather than manually configuring every mock
///
/// 3. **Avoid inline/ad-hoc mocks** - if a new service needs mocking,
///    add it to this file and regenerate
///
/// 4. **Keep async behavior consistent** - use `thenAnswer((_) async => ...)`
///    for async operations, not `thenReturn(Future.value(...))`
///
/// 5. **Mock at the right level** - mock services, not low-level Supabase
///    components unless testing service implementations
///
/// 6. **Verify no network calls** - all external dependencies should be
///    mocked to ensure deterministic, fast tests
