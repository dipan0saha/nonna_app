# Test Directory - Centralized Mocking Strategy

**IMPORTANT**: This project uses a centralized mocking strategy. All tests must use the shared mock infrastructure described below.

---

# Centralized Mocking Strategy

## Quick Start

```dart
// Import centralized mocks
import 'package:nonna_app/test/mocks/mock_services.mocks.dart';
import 'package:nonna_app/test/helpers/mock_factory.dart';
import 'package:nonna_app/test/helpers/test_data_factory.dart';

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
import 'package:nonna_app/test/mocks/mock_services.mocks.dart';
import 'package:nonna_app/test/helpers/mock_factory.dart';

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
- Import mocks from `mock_services.mocks.dart`
- Use `MockFactory` for common scenarios
- Use `TestDataFactory` for test data
- Use `MockHelpers` for common patterns
- Keep tests focused on business logic
- Mock all external dependencies

### ❌ DON'T
- Create new `@GenerateMocks` annotations
- Manually configure common defaults
- Duplicate test data setup
- Make real network/database calls
- Use inline/ad-hoc mocks
- Mix `Future.value()` and `async`

---

# Test Directory

This directory contains all unit tests, widget tests, and test utilities for the Nonna App.

## Directory Structure

```
test/
├── core/                  # Tests for core functionality
│   ├── services/         # Service layer tests
│   ├── utils/            # Utility function tests
│   └── widgets/          # Shared widget tests
│
├── tiles/                # Tests for tile components
│   ├── feeding/          # Feeding tile tests
│   ├── diaper/           # Diaper tile tests
│   └── [other tiles]     # Other tile tests
│
├── features/             # Tests for feature modules
│   ├── auth/             # Authentication feature tests
│   ├── home/             # Home/Dashboard feature tests
│   └── [other features]  # Other feature tests
│
├── helpers/              # Test helpers and utilities
│   ├── test_helpers.dart # Common test utilities
│   └── mock_data.dart    # Mock data for testing
│
└── fixtures/             # Test fixtures and data
    └── json/             # JSON fixtures
```

## Running Tests

### All Tests
```bash
flutter test
```

### With Coverage
```bash
flutter test --coverage
```

### Specific Test File
```bash
flutter test test/core/services/auth_service_test.dart
```

### Watch Mode (re-run on changes)
```bash
flutter test --watch
```

### Using Makefile
```bash
make test
```

## Test Types

### Unit Tests
Test individual functions, classes, and methods in isolation.

**Example:**
```dart
test('validates email correctly', () {
  expect(Validators.isValidEmail('test@example.com'), true);
  expect(Validators.isValidEmail('invalid'), false);
});
```

### Widget Tests
Test Flutter widgets and their behavior.

**Example:**
```dart
testWidgets('LoginButton shows text', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: LoginButton(onPressed: () {}),
    ),
  );
  
  expect(find.text('Login'), findsOneWidget);
});
```

### Integration Tests
Test complete user flows (located in `integration_test/` directory).

## Writing Tests

### Test File Naming
- Match source file name with `_test.dart` suffix
- Example: `auth_service.dart` → `auth_service_test.dart`

### Test Structure
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('FeatureName', () {
    late ServiceClass service;
    
    setUp(() {
      // Setup before each test
      service = ServiceClass();
    });
    
    tearDown(() {
      // Cleanup after each test
    });
    
    test('should do something', () {
      // Arrange
      final input = 'test';
      
      // Act
      final result = service.doSomething(input);
      
      // Assert
      expect(result, 'expected');
    });
  });
}
```

## Mocking

Use Mockito for mocking dependencies:

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([AuthService, DatabaseService])
void main() {
  late MockAuthService mockAuthService;
  
  setUp(() {
    mockAuthService = MockAuthService();
  });
  
  test('uses mocked service', () {
    when(mockAuthService.login(any, any))
        .thenAnswer((_) async => User(id: '123'));
    
    // Test code using mockAuthService
  });
}
```

Generate mocks:
```bash
flutter pub run build_runner build
```

## Test Coverage

### Target Coverage
- Overall: 80% minimum
- Core services: 90% minimum
- Utilities: 95% minimum
- UI widgets: 70% minimum

### Generate Coverage Report
```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# View report
open coverage/html/index.html
```

## Best Practices

### DO
- ✅ Write tests for new features
- ✅ Test edge cases and error conditions
- ✅ Use meaningful test descriptions
- ✅ Keep tests independent
- ✅ Mock external dependencies
- ✅ Follow Arrange-Act-Assert pattern
- ✅ Test one thing per test
- ✅ Use descriptive variable names

### DON'T
- ❌ Test Flutter framework code
- ❌ Write tests that depend on each other
- ❌ Test implementation details
- ❌ Ignore failing tests
- ❌ Write overly complex tests
- ❌ Mock everything unnecessarily
- ❌ Test private methods directly

## Common Test Patterns

### Testing Async Code
```dart
test('async function works', () async {
  final result = await asyncFunction();
  expect(result, expectedValue);
});
```

### Testing Streams
```dart
test('stream emits values', () {
  expect(
    stream,
    emitsInOrder([value1, value2, emitsDone]),
  );
});
```

### Testing Exceptions
```dart
test('throws exception on error', () {
  expect(
    () => functionThatThrows(),
    throwsA(isA<CustomException>()),
  );
});
```

### Widget Finder Patterns
```dart
// Find by text
expect(find.text('Login'), findsOneWidget);

// Find by key
expect(find.byKey(Key('login-button')), findsOneWidget);

// Find by type
expect(find.byType(ElevatedButton), findsWidgets);

// Find by icon
expect(find.byIcon(Icons.login), findsOneWidget);
```

## Troubleshooting

### Tests Failing in CI but Pass Locally
- Check for timezone differences
- Verify mock data is consistent
- Look for random data or timing issues
- Ensure all test dependencies are committed

### Slow Tests
- Avoid unnecessary `pump()` calls
- Use `pumpAndSettle()` sparingly
- Mock expensive operations
- Consider parallelization

### Flaky Tests
- Remove randomness
- Fix timing dependencies
- Use proper waits and matchers
- Ensure proper cleanup in `tearDown()`

## Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Flutter Test Package](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)

## Contributing

When adding new code:
1. Write tests first (TDD) or alongside your code
2. Ensure all tests pass before creating PR
3. Add tests for bug fixes
4. Update this README if adding new test patterns

---

**Maintained by**: Development Team  
**Questions?** Ask in team chat or create a GitHub issue
