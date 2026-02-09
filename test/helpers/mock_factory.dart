import 'package:mockito/mockito.dart';
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

  /// Create a DatabaseService mock with common default behaviors
  ///
  /// Default behaviors:
  /// - `select()` returns empty FakePostgrestBuilder
  /// - Ready for custom stubbing via `when()`
  static MockDatabaseService createDatabaseService({
    List<Map<String, dynamic>>? defaultSelectData,
  }) {
    final mock = MockDatabaseService();

    // Default select behavior - return empty or provided data
    when(mock.select(any, columns: anyNamed('columns')))
        .thenAnswer((_) => FakePostgrestBuilder(defaultSelectData ?? []));

    return mock;
  }

  /// Create a CacheService mock with common default behaviors
  ///
  /// Default behaviors:
  /// - `isInitialized` returns true
  /// - `get()` returns null (cache miss)
  /// - `put()` completes successfully
  static MockCacheService createCacheService({
    bool isInitialized = true,
    Map<String, dynamic>? defaultGetData,
  }) {
    final mock = MockCacheService();

    // Default initialization state
    when(mock.isInitialized).thenReturn(isInitialized);

    // Default get behavior - cache miss
    when(mock.get(any)).thenAnswer((_) async => defaultGetData);

    // Default put behavior - success
    when(mock.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
        .thenAnswer((_) async => null);

    // Default clear behavior - success
    when(mock.clear()).thenAnswer((_) async => null);

    return mock;
  }

  /// Create a RealtimeService mock with common default behaviors
  ///
  /// Default behaviors:
  /// - `isConnected` returns true
  /// - `subscribe()` returns empty stream
  /// - `unsubscribe()` completes successfully
  static MockRealtimeService createRealtimeService({
    bool isConnected = true,
    Stream<dynamic>? defaultStream,
  }) {
    final mock = MockRealtimeService();

    // Default connection state
    when(mock.isConnected).thenReturn(isConnected);

    // Default subscribe behavior - empty stream
    when(mock.subscribe(
      table: anyNamed('table'),
      channelName: anyNamed('channelName'),
      filter: anyNamed('filter'),
    )).thenReturn(defaultStream ?? Stream.empty());

    // Default unsubscribe behavior - success
    when(mock.unsubscribe(any)).thenAnswer((_) async => null);

    return mock;
  }

  /// Create a StorageService mock with common default behaviors
  ///
  /// Default behaviors:
  /// - `uploadFile()` returns test URL
  /// - `deleteFile()` completes successfully
  /// - `getPublicUrl()` returns test URL
  static MockStorageService createStorageService({
    String defaultUploadUrl = 'https://test.storage.com/test-file.jpg',
  }) {
    final mock = MockStorageService();

    // Default upload behavior using uploadFile
    when(mock.uploadFile(
      filePath: anyNamed('filePath'),
      storageKey: anyNamed('storageKey'),
      bucket: anyNamed('bucket'),
    )).thenAnswer((_) async => defaultUploadUrl);

    // Default delete behavior - success
    when(mock.deleteFile(any, any)).thenAnswer((_) async => null);

    // Default getPublicUrl behavior
    when(mock.getPublicUrl(any, any)).thenReturn(defaultUploadUrl);

    return mock;
  }

  /// Create an AuthService mock with common default behaviors
  ///
  /// Default behaviors:
  /// - `isAuthenticated` returns true
  /// - `currentUser` returns mock user
  /// - Auth state changes stream available
  static MockAuthService createAuthService({
    bool isAuthenticated = true,
    MockUser? currentUser,
  }) {
    final mock = MockAuthService();

    // Default authentication state
    when(mock.isAuthenticated).thenReturn(isAuthenticated);

    // Default current user
    if (currentUser != null) {
      when(mock.currentUser).thenReturn(currentUser);
    }

    return mock;
  }

  /// Create a LocalStorageService mock with common default behaviors
  ///
  /// Default behaviors:
  /// - `isInitialized` returns true
  /// - `getString()` returns null by default
  /// - `setString()` completes successfully
  static MockLocalStorageService createLocalStorageService({
    bool isInitialized = true,
  }) {
    final mock = MockLocalStorageService();

    // Default initialization state
    when(mock.isInitialized).thenReturn(isInitialized);

    // Default getString behavior - synchronous
    when(mock.getString(any)).thenReturn(null);

    // Default setString behavior
    when(mock.setString(any, any)).thenAnswer((_) async => null);

    // Default getBool behavior - synchronous
    when(mock.getBool(any)).thenReturn(null);

    // Default setBool behavior
    when(mock.setBool(any, any)).thenAnswer((_) async => null);

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

  // ==========================================
  // Supabase Component Mocks
  // ==========================================

  /// Create a SupabaseClient mock
  static MockSupabaseClient createSupabaseClient() {
    return MockSupabaseClient();
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

  /// Create a User mock with test data
  static MockUser createUser({
    String id = 'test-user-id',
    String email = 'test@example.com',
  }) {
    final mock = MockUser();
    when(mock.id).thenReturn(id);
    when(mock.email).thenReturn(email);
    return mock;
  }

  /// Create a Session mock with test data
  static MockSession createSession({
    String accessToken = 'test-access-token',
    MockUser? user,
  }) {
    final mock = MockSession();
    when(mock.accessToken).thenReturn(accessToken);
    if (user != null) {
      when(mock.user).thenReturn(user);
    }
    return mock;
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
  static MockServiceContainer createServiceContainer({
    bool cacheInitialized = true,
    bool realtimeConnected = true,
    bool authenticated = true,
  }) {
    return MockServiceContainer(
      database: createDatabaseService(),
      cache: createCacheService(isInitialized: cacheInitialized),
      realtime: createRealtimeService(isConnected: realtimeConnected),
      storage: createStorageService(),
      auth: createAuthService(isAuthenticated: authenticated),
      localStorage: createLocalStorageService(),
      backup: createBackupService(),
      notification: createNotificationService(),
      analytics: createAnalyticsService(),
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
}
