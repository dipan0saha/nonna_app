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
