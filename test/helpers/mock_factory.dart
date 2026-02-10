import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../mocks/mock_services.mocks.dart';
import 'fake_postgrest_builders.dart';

/// Factory for creating pre-configured mock service instances
///
/// This factory provides convenient methods for creating mocks with
/// common default behaviors, reducing boilerplate in test setup.
///
/// ## Usage
///
/// ```dart
/// // Create individual services
/// final mockDb = MockFactory.createDatabaseService();
/// final mockCache = MockFactory.createCacheService();
///
/// // Create a complete container with all common services
/// final mocks = MockFactory.createServiceContainer();
/// ```
class MockFactory {
  // ==========================================
  // Individual Service Factory Methods
  // ==========================================

  /// Create a DatabaseService mock
  ///
  /// Returns a clean mock instance ready for custom stubbing via `when()`
  static MockDatabaseService createDatabaseService() {
    return MockDatabaseService();
  }

  /// Create a CacheService mock
  ///
  /// Returns a clean mock instance ready for custom stubbing via `when()`
  /// with isInitialized defaulting to true
  static MockCacheService createCacheService() {
    final mock = MockCacheService();
    // Default stub for isInitialized
    when(mock.isInitialized).thenReturn(true);
    return mock;
  }

  /// Create a RealtimeService mock
  ///
  /// Returns a clean mock instance ready for custom stubbing via `when()`
  static MockRealtimeService createRealtimeService() {
    return MockRealtimeService();
  }

  /// Create a StorageService mock
  ///
  /// Returns a clean mock instance ready for custom stubbing via `when()`
  static MockStorageService createStorageService() {
    return MockStorageService();
  }

  /// Create an AuthService mock
  ///
  /// Returns a clean mock instance ready for custom stubbing via `when()`
  static MockAuthService createAuthService() {
    return MockAuthService();
  }

  /// Create a LocalStorageService mock
  ///
  /// Returns a clean mock instance ready for custom stubbing via `when()`
  /// with isInitialized defaulting to true
  static MockLocalStorageService createLocalStorageService() {
    final mock = MockLocalStorageService();
    // Default stub for isInitialized
    when(mock.isInitialized).thenReturn(true);
    return mock;
  }

  /// Create a BackupService mock with common default behaviors
  static MockBackupService createBackupService() {
    final mock = MockBackupService();

    // Add default behaviors as needed based on actual BackupService methods

    return mock;
  }

  /// Create a NotificationService mock with common default behaviors
  static MockNotificationService createNotificationService() {
    final mock = MockNotificationService();

    // Add default behaviors as needed
    return mock;
  }

  /// Create an AnalyticsService mock with common default behaviors
  static MockAnalyticsService createAnalyticsService() {
    final mock = MockAnalyticsService();

    // Add default behaviors as needed based on actual AnalyticsService methods
    // Note: logEvent is not exposed directly; use specific methods like logSignUp, logLogin, etc.

    return mock;
  }

  /// Create an ObservabilityService mock with common default behaviors
  static MockObservabilityService createObservabilityService() {
    final mock = MockObservabilityService();

    // Add default behaviors as needed based on actual ObservabilityService methods

    return mock;
  }

  // ==========================================
  // Supabase Component Mocks
  // ==========================================

  /// Create a SupabaseClient mock
  /// 
  /// By default, this creates a client with realtime channel support enabled.
  /// Set [withRealtimeSupport] to false if you need a basic client without stubs.
  static MockSupabaseClient createSupabaseClient({bool withRealtimeSupport = true}) {
    final mock = MockSupabaseClient();
    if (withRealtimeSupport) {
      MockHelpers.setupSupabaseRealtimeChannels(mock);
    }
    return mock;
  }

  /// Create a GoTrueClient mock
  static MockGoTrueClient createGoTrueClient() {
    return MockGoTrueClient();
  }

  /// Create a SupabaseStorageClient mock
  static MockSupabaseStorageClient createSupabaseStorageClient() {
    return MockSupabaseStorageClient();
  }

  /// Create a RealtimeChannel mock
  static MockRealtimeChannel createRealtimeChannel() {
    return MockRealtimeChannel();
  }

  /// Create a User mock
  ///
  /// Returns a clean mock instance ready for custom stubbing via `when()`
  static MockUser createUser() {
    return MockUser();
  }

  /// Create a Session mock
  ///
  /// Returns a clean mock instance ready for custom stubbing via `when()`
  static MockSession createSession() {
    return MockSession();
  }

  // ==========================================
  // Service Container
  // ==========================================

  /// Create a complete service container with all common services
  ///
  /// This is useful for tests that need multiple services.
  /// Example:
  /// ```dart
  /// final mocks = MockFactory.createServiceContainer();
  /// container = ProviderContainer(
  ///   overrides: [
  ///     databaseServiceProvider.overrideWithValue(mocks.database),
  ///     cacheServiceProvider.overrideWithValue(mocks.cache),
  ///     realtimeServiceProvider.overrideWithValue(mocks.realtime),
  ///   ],
  /// );
  /// ```
  static MockServiceContainer createServiceContainer() {
    return MockServiceContainer(
      database: createDatabaseService(),
      cache: createCacheService(),
      realtime: createRealtimeService(),
      storage: createStorageService(),
      auth: createAuthService(),
      localStorage: createLocalStorageService(),
      backup: createBackupService(),
      notification: createNotificationService(),
      analytics: createAnalyticsService(),
      observability: createObservabilityService(),
    );
  }
}

/// Container for holding multiple mock services
///
/// Makes it easier to pass around pre-configured mocks in tests.
class MockServiceContainer {
  final MockDatabaseService database;
  final MockCacheService cache;
  final MockRealtimeService realtime;
  final MockStorageService storage;
  final MockAuthService auth;
  final MockLocalStorageService localStorage;
  final MockBackupService backup;
  final MockNotificationService notification;
  final MockAnalyticsService analytics;
  final MockObservabilityService observability;

  MockServiceContainer({
    required this.database,
    required this.cache,
    required this.realtime,
    required this.storage,
    required this.auth,
    required this.localStorage,
    required this.backup,
    required this.notification,
    required this.analytics,
    required this.observability,
  });
}

/// Helper methods for common mock configurations
///
/// These methods provide reusable patterns for setting up mocks
/// with specific behaviors that are common across tests.
class MockHelpers {
  // ==========================================
  // Database Mock Helpers
  // ==========================================

  /// Configure a database mock to return specific data for a query
  static void setupDatabaseSelect(
    MockDatabaseService mock,
    String table,
    List<Map<String, dynamic>> data,
  ) {
    when(mock.select(table, columns: anyNamed('columns')))
        .thenAnswer((_) => FakePostgrestBuilder(data));
  }

  /// Configure a database mock to throw an error
  static void setupDatabaseError(
    MockDatabaseService mock,
    String table,
    Exception error,
  ) {
    when(mock.select(table, columns: anyNamed('columns'))).thenThrow(error);
  }

  /// Configure a database mock for successful insert
  static void setupDatabaseInsert(
    MockDatabaseService mock,
    String table,
    Map<String, dynamic> returnData,
  ) {
    when(mock.insert(table, any))
        .thenAnswer((_) async => [returnData]);
  }

  /// Configure a database mock for successful update
  static void setupDatabaseUpdate(
    MockDatabaseService mock,
    String table,
    Map<String, dynamic> returnData,
  ) {
    when(mock.update(table, any))
        .thenAnswer((_) => FakePostgrestBuilder([returnData]));
  }

  // ==========================================
  // Cache Mock Helpers
  // ==========================================

  /// Configure a cache mock to return specific data for a key
  static void setupCacheGet(
    MockCacheService mock,
    String key,
    dynamic data,
  ) {
    when(mock.get(key)).thenAnswer((_) async => data);
  }

  /// Configure a cache mock to always miss (return null)
  static void setupCacheMiss(MockCacheService mock) {
    when(mock.get(any)).thenAnswer((_) async => null);
  }

  /// Configure a cache mock to always hit with data
  static void setupCacheHit(
    MockCacheService mock,
    Map<String, dynamic> allData,
  ) {
    // Setup gets for specific keys
    allData.forEach((key, value) {
      when(mock.get(key)).thenAnswer((_) async => value);
    });
  }

  // ==========================================
  // Realtime Mock Helpers
  // ==========================================

  /// Configure a realtime mock to emit data on subscription
  static void setupRealtimeSubscription(
    MockRealtimeService mock,
    String table,
    Stream<dynamic> dataStream,
  ) {
    when(mock.subscribe(
      table: table,
      channelName: anyNamed('channelName'),
      filter: anyNamed('filter'),
    )).thenReturn(dataStream);
  }

  /// Configure a realtime mock with a single emission
  static void setupRealtimeSingleEmit(
    MockRealtimeService mock,
    String table,
    dynamic data,
  ) {
    when(mock.subscribe(
      table: table,
      channelName: anyNamed('channelName'),
      filter: anyNamed('filter'),
    )).thenReturn(Stream.value(data));
  }

  /// Configure a realtime mock that emits multiple values
  static void setupRealtimeMultiEmit(
    MockRealtimeService mock,
    String table,
    List<dynamic> dataList,
  ) {
    when(mock.subscribe(
      table: table,
      channelName: anyNamed('channelName'),
      filter: anyNamed('filter'),
    )).thenReturn(Stream.fromIterable(dataList));
  }

  // ==========================================
  // Storage Mock Helpers
  // ==========================================

  /// Configure a storage mock for successful file upload
  static void setupStorageUpload(
    MockStorageService mock,
    String bucket,
    String url,
  ) {
    when(mock.uploadFile(
      filePath: anyNamed('filePath'),
      storageKey: anyNamed('storageKey'),
      bucket: bucket,
    )).thenAnswer((_) async => url);
  }

  /// Configure a storage mock to fail uploads
  static void setupStorageUploadError(
    MockStorageService mock,
    String bucket,
    Exception error,
  ) {
    when(mock.uploadFile(
      filePath: anyNamed('filePath'),
      storageKey: anyNamed('storageKey'),
      bucket: bucket,
    )).thenThrow(error);
  }

  // ==========================================
  // Auth Mock Helpers
  // ==========================================

  /// Configure an auth mock with a logged-in user
  static void setupAuthenticatedUser(
    MockAuthService mock,
    MockUser user,
  ) {
    when(mock.isAuthenticated).thenReturn(true);
    when(mock.currentUser).thenReturn(user);
  }

  /// Configure an auth mock with no user (logged out)
  static void setupUnauthenticatedUser(MockAuthService mock) {
    when(mock.isAuthenticated).thenReturn(false);
    when(mock.currentUser).thenReturn(null);
  }

  // ==========================================
  // Supabase Client Mock Helpers
  // ==========================================

  /// Configure a SupabaseClient mock to support realtime channels
  ///
  /// This sets up the client.channel() method to return a properly
  /// configured MockRealtimeChannel that can be used in tests.
  static void setupSupabaseRealtimeChannels(MockSupabaseClient mock) {
    // Create a map to track channels by name
    final channels = <String, MockRealtimeChannel>{};
    
    // Stub the channel method to return a unique mock channel per channel name
    when(mock.channel(any)).thenAnswer((invocation) {
      final channelName = invocation.positionalArguments[0] as String;
      return channels.putIfAbsent(channelName, () {
        final mockChannel = MockFactory.createRealtimeChannel();
        
        // Stub the onPostgresChanges method to return the channel (for method chaining)
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        
        // Stub the subscribe method to return the channel and immediately call the callback
        when(mockChannel.subscribe(any, any)).thenAnswer((subscribeInvocation) {
          // Get the callback from the invocation
          final callback = subscribeInvocation.positionalArguments[0];
          if (callback != null) {
            // Call the callback to simulate successful subscription
            callback(RealtimeSubscribeStatus.subscribed, null);
          }
          return mockChannel;
        });
        
        // Stub unsubscribe to return success
        when(mockChannel.unsubscribe(any))
            .thenAnswer((_) async => 'ok');
        
        return mockChannel;
      });
    });
    
    when(mock.channel(any, opts: anyNamed('opts'))).thenAnswer((invocation) {
      final channelName = invocation.positionalArguments[0] as String;
      return channels.putIfAbsent(channelName, () {
        final mockChannel = MockFactory.createRealtimeChannel();
        
        // Stub the onPostgresChanges method to return the channel (for method chaining)
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        
        // Stub the subscribe method to return the channel and immediately call the callback
        when(mockChannel.subscribe(any, any)).thenAnswer((subscribeInvocation) {
          // Get the callback from the invocation
          final callback = subscribeInvocation.positionalArguments[0];
          if (callback != null) {
            // Call the callback to simulate successful subscription
            callback(RealtimeSubscribeStatus.subscribed, null);
          }
          return mockChannel;
        });
        
        // Stub unsubscribe to return success
        when(mockChannel.unsubscribe(any))
            .thenAnswer((_) async => 'ok');
        
        return mockChannel;
      });
    });
    
    // Stub the removeChannel method to return success
    // This removes the channel from tracking by identity reference.
    // When the same channel name is requested again via channel(),
    // putIfAbsent will check if the key exists. Since we removed the entry,
    // a new channel will be created for that name.
    when(mock.removeChannel(any)).thenAnswer((invocation) async {
      final channel = invocation.positionalArguments[0];
      channels.removeWhere((_, value) => identical(value, channel));
      return 'ok';
    });
  }
}
