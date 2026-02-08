# TileLoader Test Setup

## Generating Mock Files

The `tile_loader_test.dart` test file requires mock classes to be generated using Mockito.

### To generate the mocks, run:

```bash
# Generate mocks for all test files
flutter pub run build_runner build --delete-conflicting-outputs

# Or generate mocks for just this test file
flutter pub run build_runner build --delete-conflicting-outputs test/core/utils/tile_loader_test.dart
```

This will create `tile_loader_test.mocks.dart` with the necessary mock classes:
- `MockDatabaseService`
- `MockCacheService`

### Running the test:

```bash
# Run just this test file
flutter test test/core/utils/tile_loader_test.dart

# Run all utils tests
flutter test test/core/utils/

# Run with coverage
flutter test --coverage test/core/utils/tile_loader_test.dart
```

## Test Coverage

The test file provides comprehensive coverage for `TileLoader`:

### Methods tested:
- `loadForScreen()` - Main loading method with caching logic
  - Cache hit scenarios
  - Cache miss scenarios
  - Force refresh behavior
  - Filtering invisible tiles
  - Sorting by display order
  - Error handling for corrupted cache
  - Proper database queries
  
- `clearCache()` - Clear cache for specific screen/role
- `clearAllCaches()` - Clear all tile caches

### Edge cases covered:
- Empty database responses
- Tiles with same display order
- Tiles with null parameters
- Corrupted cache data
- Different screen IDs and user roles
