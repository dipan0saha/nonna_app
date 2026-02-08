# Centralized Mocking - Quick Reference

## 🚀 Quick Start

```dart
import '../../mocks/mock_services.mocks.dart';
import '../../helpers/mock_factory.dart';
import '../../helpers/test_data_factory.dart';

void main() {
  group('MyTest', () {
    late MockServiceContainer mocks;

    setUp(() {
      mocks = MockFactory.createServiceContainer();
    });

    test('my test', () {
      final user = TestDataFactory.createUser();
      MockHelpers.setupDatabaseSelect(
        mocks.database,
        'users',
        [user.toJson()],
      );
      // ... test code
    });
  });
}
```

---

## 📚 Common Patterns Cheat Sheet

### Create Mock Services

```dart
// All services with defaults
final mocks = MockFactory.createServiceContainer();

// Or individual services
final mockDb = MockFactory.createDatabaseService();
final mockCache = MockFactory.createCacheService();
final mockRealtime = MockFactory.createRealtimeService();
```

### Setup Database Mocks

```dart
// Return data
MockHelpers.setupDatabaseSelect(mockDb, 'table', [data]);

// Return error
MockHelpers.setupDatabaseError(mockDb, 'table', Exception('error'));

// Successful insert
MockHelpers.setupDatabaseInsert(mockDb, 'table', returnData);

// Successful update
MockHelpers.setupDatabaseUpdate(mockDb, 'table', returnData);
```

### Setup Cache Mocks

```dart
// Cache hit
MockHelpers.setupCacheGet(mockCache, 'key', data);

// Cache miss (all keys)
MockHelpers.setupCacheMiss(mockCache);

// Multiple cache hits
MockHelpers.setupCacheHit(mockCache, {
  'key1': 'value1',
  'key2': 'value2',
});
```

### Setup Realtime Mocks

```dart
// Empty subscription
MockHelpers.setupRealtimeSubscription(
  mockRealtime,
  'table',
  Stream.empty(),
);

// Single emit
MockHelpers.setupRealtimeSingleEmit(
  mockRealtime,
  'table',
  data,
);

// Multiple emits
MockHelpers.setupRealtimeMultiEmit(
  mockRealtime,
  'table',
  [data1, data2, data3],
);
```

### Setup Storage Mocks

```dart
// Successful upload
MockHelpers.setupStorageUpload(mockStorage, 'bucket', 'url');

// Upload error
MockHelpers.setupStorageUploadError(
  mockStorage,
  'bucket',
  Exception('error'),
);
```

### Setup Auth Mocks

```dart
// Authenticated user
final user = MockFactory.createUser();
MockHelpers.setupAuthenticatedUser(mockAuth, user);

// Not authenticated
MockHelpers.setupUnauthenticatedUser(mockAuth);
```

---

## 🏭 Test Data Creation

### Create Single Objects

```dart
final user = TestDataFactory.createUser();
final baby = TestDataFactory.createBabyProfile();
final event = TestDataFactory.createEvent();
final photo = TestDataFactory.createPhoto();
final item = TestDataFactory.createRegistryItem();
final notif = TestDataFactory.createNotification();
```

### Create with Custom Values

```dart
final user = TestDataFactory.createUser(
  id: 'custom-id',
  email: 'custom@example.com',
  displayName: 'Custom Name',
);
```

### Create Batches

```dart
final users = TestDataFactory.createUsers(5);
final babies = TestDataFactory.createBabyProfiles(3);
final events = TestDataFactory.createEvents(10);
final photos = TestDataFactory.createPhotos(20);
```

### Convert to JSON

```dart
// Single
final json = TestDataFactory.userToJson(user);

// Batch
final jsonList = TestDataFactory.usersToJson(users);
```

---

## 🔧 Advanced Patterns

### Simulate Loading State

```dart
test('shows loading', () async {
  when(mocks.database.select(any))
    .thenReturn(FakePostgrestBuilder.withDelay(
      [data],
      delay: Duration(milliseconds: 100),
    ));

  // Start async operation
  final future = provider.fetch();
  
  // Check loading state
  expect(state.isLoading, isTrue);
  
  await future;
  
  expect(state.isLoading, isFalse);
});
```

### Simulate Error

```dart
test('handles error', () async {
  when(mocks.database.select(any))
    .thenReturn(FakePostgrestBuilder.withError(
      Exception('Database error'),
    ));

  await provider.fetch();

  expect(state.error, isNotNull);
});
```

### Test Cache Hit/Miss

```dart
test('uses cache', () async {
  MockHelpers.setupCacheGet(mocks.cache, 'key', cachedData);

  await provider.fetch();

  verifyNever(mocks.database.select(any));
});

test('fetches on cache miss', () async {
  MockHelpers.setupCacheMiss(mocks.cache);
  MockHelpers.setupDatabaseSelect(mocks.database, 'table', [data]);

  await provider.fetch();

  verify(mocks.database.select('table')).called(1);
});
```

### Provider Override Pattern

```dart
setUp(() {
  mocks = MockFactory.createServiceContainer();
  
  container = ProviderContainer(
    overrides: [
      databaseServiceProvider.overrideWithValue(mocks.database),
      cacheServiceProvider.overrideWithValue(mocks.cache),
      realtimeServiceProvider.overrideWithValue(mocks.realtime),
      storageServiceProvider.overrideWithValue(mocks.storage),
      authServiceProvider.overrideWithValue(mocks.auth),
    ],
  );
});
```

---

## ⚠️ Common Mistakes to Avoid

### ❌ DON'T: Create new mock annotations
```dart
// ❌ BAD
@GenerateMocks([DatabaseService])
import 'my_test.mocks.dart';
```

### ✅ DO: Use centralized mocks
```dart
// ✅ GOOD (use relative imports in test files)
import '../../mocks/mock_services.mocks.dart';
import '../../helpers/mock_factory.dart';
```

---

### ❌ DON'T: Manually configure defaults
```dart
// ❌ BAD
mockCache = MockCacheService();
when(mockCache.isInitialized).thenReturn(true);
when(mockCache.get(any)).thenAnswer((_) async => null);
```

### ✅ DO: Use factory with defaults
```dart
// ✅ GOOD
final mocks = MockFactory.createServiceContainer();
// Defaults already configured!
```

---

### ❌ DON'T: Mix Future.value() and async
```dart
// ❌ BAD
when(mock.method()).thenReturn(Future.value(data));
```

### ✅ DO: Use thenAnswer with async
```dart
// ✅ GOOD
when(mock.method()).thenAnswer((_) async => data);
```

---

### ❌ DON'T: Create test data manually
```dart
// ❌ BAD
final user = User(
  id: 'test-id',
  email: 'test@example.com',
  displayName: 'Test User',
  profilePictureUrl: 'url',
  createdAt: DateTime.now(),
);
```

### ✅ DO: Use test data factory
```dart
// ✅ GOOD
final user = TestDataFactory.createUser();
```

---

## 📖 Need More Details?

- **Full Documentation**: See `test/README.md`
- **Migration Guide**: See `MOCKING_NEXT_STEPS.md`
- **Example Test**: See `test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart`

---

## 🎯 Remember

1. **Always import from centralized mocks**
2. **Use MockFactory for services**
3. **Use TestDataFactory for data**
4. **Use MockHelpers for common patterns**
5. **Follow the examples**

---

**Happy Testing! 🚀**
