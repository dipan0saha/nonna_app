# Test Directory - Centralized Mocking Strategy

**IMPORTANT**: This project uses a centralized mocking strategy. All tests must use the shared mock infrastructure described below.

---

# Centralized Mocking Strategy

## Quick Start

```dart
// Import centralized mocks (adjust path based on your test file location)
// For tests in test/tiles/my_tile/providers/:
import '../../../mocks/mock_services.mocks.dart';
import '../../../helpers/mock_factory.dart';
import '../../../helpers/test_data_factory.dart';

// For tests in test/features/my_feature/providers/:
import '../../../mocks/mock_services.mocks.dart';
import '../../../helpers/mock_factory.dart';
import '../../../helpers/test_data_factory.dart';

// For tests directly in test/core/services/:
import '../../mocks/mock_services.mocks.dart';
import '../../helpers/mock_factory.dart';
import '../../helpers/test_data_factory.dart';

void main() {
  group('MyTest', () {
    late MockServiceContainer mocks;

    setUp(() {
      // Create all services with sensible defaults
      mocks = MockFactory.createServiceContainer();
    });

    test('example test', () {
      // Create test data
      final user = TestDataFactory.createUser();
      
      // Setup mock behavior
      MockHelpers.setupDatabaseSelect(
        mocks.database,
        'users',
        [user.toJson()],
      );

      // ... rest of test
    });
  });
}
```

## Core Mocking Components

### 1. Central Mock Generation (`test/mocks/mock_services.dart`)

**Single source of truth** for all mocks. Never create `@GenerateMocks` annotations in test files.

Provides mocks for:
- Supabase: SupabaseClient, GoTrueClient, RealtimeChannel, StorageFileApi, etc.
- Firebase: FirebaseAnalytics
- App Services: DatabaseService, CacheService, RealtimeService, StorageService, etc.

To regenerate after changes:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Mock Factory (`test/helpers/mock_factory.dart`)

Pre-configured mock instances with sensible defaults:

```dart
// Individual services
final mockDb = MockFactory.createDatabaseService();
final mockCache = MockFactory.createCacheService();

// Complete service container
final mocks = MockFactory.createServiceContainer();
```

### 3. Test Data Factory (`test/helpers/test_data_factory.dart`)

Consistent test data creation:

```dart
// Single object
final user = TestDataFactory.createUser();
final baby = TestDataFactory.createBabyProfile();

// Batches
final users = TestDataFactory.createUsers(5);
final photos = TestDataFactory.createPhotos(10);

// Convert to JSON for mocks
final jsonData = TestDataFactory.usersToJson(users);
```

### 4. Mock Helpers

Common mock configuration patterns:

```dart
// Database
MockHelpers.setupDatabaseSelect(mockDb, 'table', [data]);
MockHelpers.setupDatabaseError(mockDb, 'table', Exception('error'));

// Cache
MockHelpers.setupCacheHit(mockCache, {'key': 'value'});
MockHelpers.setupCacheMiss(mockCache);

// Realtime
MockHelpers.setupRealtimeSubscription(mockRealtime, 'table', stream);
```

## Migration from Old Pattern

### ❌ OLD (Don't do this)
```dart
@GenerateMocks([DatabaseService, CacheService])
import 'my_test.mocks.dart';

void main() {
  late MockDatabaseService mockDb;
  
  setUp(() {
    mockDb = MockDatabaseService();
    when(mockDb.select(any)).thenReturn(FakePostgrestBuilder([]));
  });
}
```

### ✅ NEW (Do this)
```dart
import '../../mocks/mock_services.mocks.dart';
import '../../helpers/mock_factory.dart';

void main() {
  late MockServiceContainer mocks;
  
  setUp(() {
    mocks = MockFactory.createServiceContainer();
    // Defaults already configured!
  });
}
```

## Common Test Patterns

### Testing Loading States
```dart
test('shows loading state', () async {
  when(mocks.database.select(any))
    .thenReturn(FakePostgrestBuilder.withDelay(
      [testData],
      delay: Duration(milliseconds: 100),
    ));

  expect(container.read(provider).isLoading, isTrue);
  await Future.delayed(Duration(milliseconds: 150));
  expect(container.read(provider).isLoading, isFalse);
});
```

### Testing Error States
```dart
test('handles error', () async {
  when(mocks.database.select(any))
    .thenReturn(FakePostgrestBuilder.withError(
      Exception('Database error'),
    ));

  await container.read(provider.notifier).fetch();
  expect(container.read(provider).error, isNotNull);
});
```

### Testing Cache Behavior
```dart
test('uses cache when available', () async {
  MockHelpers.setupCacheGet(mocks.cache, 'key', testData);
  
  await container.read(provider.notifier).fetch();
  
  verifyNever(mocks.database.select(any));
});
```

## Best Practices

### ✅ DO
- Import mocks using relative paths (e.g., `../../mocks/mock_services.mocks.dart`)
- Use `MockFactory` for common scenarios
- Use `TestDataFactory` for test data
- Use `MockHelpers` for common patterns
- Keep tests focused on business logic
- Mock all external dependencies

### ❌ DON'T
- Create new `@GenerateMocks` annotations
- Use package imports for test files (use relative imports)
- Manually configure common defaults
- Duplicate test data setup
- Make real network/database calls
- Use inline/ad-hoc mocks
- Mix `Future.value()` and `async`

---

