# Testing Instructions for Mocking Fixes

## Overview
This document describes how to test the fixes made for the mocking issues reported in `test_results.txt`.

## Fixes Applied

### 1. Fixed Type Mismatch in FakePostgrestBuilder
**File:** `test/helpers/fake_postgrest_builders.dart`

**Issue:** `_createBaseBuilder()` was returning `SupabaseQueryBuilder` which is not a subtype of `PostgrestBuilder`.

**Fix:** Changed to call `.select()` which returns `PostgrestFilterBuilder` that properly extends `PostgrestBuilder`.

### 2. Fixed Nested `when()` Calls  
**File:** `test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart`

**Issue:** `mockCache.isInitialized` was being accessed during other mock stub setups, causing "Cannot call when within a stub response" error.

**Fix:** 
- Set `cache.isInitialized = true` in setUp (was false)
- Added default stubs for `cache.get()` and `cache.put()` upfront
- This ensures all mock methods have default behaviors before tests run

## How to Test

### Run the Specific Test
```bash
flutter test test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart
```

### Expected Results
All 23 tests should now pass:
- ✅ Initial State (1 test)
- ✅ Data Fetching (6 tests)
- ✅ Cache Behavior (1 test)
- ✅ Refresh (1 test)
- ✅ Active/Removed Followers (2 tests)
- ✅ Real-time Updates (2 tests)
- ✅ Time Period Options (2 tests)
- ✅ Sorting (1 test)
- ✅ Error Handling (1 test)
- ✅ Basic Functionality (4 tests)
- ✅ Dispose (1 test)

### Previously Failing Tests
These tests were failing with "Cannot call when within a stub response":
- `fetches followers from database when cache is empty`
- `force refresh bypasses cache`
- `filters only recent followers`
- `saves fetched followers to cache`
- `limits to recent followers only`
- `uses cached data when available`
- `refreshes followers with force refresh`
- `getActiveFollowers returns only active followers`
- `getRemovedFollowers returns only removed followers`
- `handles new follower`
- `handles follower removed`
- `supports 7-day period`
- `supports 30-day period`
- `sorts followers by date (newest first)`
- `error state can be set and read`
- `provider can be read from container`
- `provider has access to required services`
- `fetchFollowers method exists`
- `refresh method exists`
- `container can be disposed without errors`

These tests were failing with type mismatch:
- `sets loading state while fetching`

## Verification Commands

### 1. Run Just This Test File
```bash
flutter test test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart > test_results_after_fix.txt 2>&1
```

### 2. Compare Results
```bash
# Count passing tests before (should be 2)
grep "^00:.*+[0-9]" test_results.txt | tail -1

# Count passing tests after (should be 23)
grep "^00:.*+[0-9]" test_results_after_fix.txt | tail -1
```

### 3. Check for Errors
```bash
# Should show 0 failures
grep "Some tests failed" test_results_after_fix.txt
```

## Additional Tests to Run

### Other Tests Using FakePostgrestBuilder
These tests should also benefit from the fixes:

```bash
# Run all tests that use FakePostgrestBuilder
flutter test test/tiles/recent_purchases/providers/recent_purchases_provider_test.dart
flutter test test/tiles/new_followers/providers/new_followers_provider_test.dart
```

### Full Test Suite
After verifying individual tests pass:
```bash
flutter test
```

## Troubleshooting

### If Type Errors Persist
Check that `_createBaseBuilder()` is calling `.select()`:
```dart
// Should be:
final selectBuilder = client.from('fake_table').select();
return selectBuilder as PostgrestBuilder<...>;

// Not:
return client.from('fake_table'); // Wrong! Returns SupabaseQueryBuilder
```

### If "Cannot call when within a stub response" Errors Persist
Verify setUp has complete default stubs:
```dart
setUp(() {
  // ... create mocks ...
  
  // These must be set BEFORE any test code runs
  when(mockCache.isInitialized).thenReturn(true);  // Must be true!
  when(mockCache.get(any)).thenAnswer((_) async => null);
  when(mockCache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
      .thenAnswer((_) async => Future.value());
  when(mockRealtime.subscribe(...)).thenAnswer((_) => Stream.empty());
});
```

## Success Criteria
✅ All 23 tests in `new_followers_provider_test_refactored.dart` pass  
✅ No "Bad state: Cannot call when within a stub response" errors  
✅ No "type X is not a subtype of type Y" errors  
✅ No regressions in other test files using FakePostgrestBuilder  

## Notes
- The fixes address the root causes identified in the original `test_results.txt`
- The changes are minimal and surgical - only fixing the specific issues
- The fixes follow Flutter/Dart best practices for mocking with mockito
- The centralized mocking strategy from `MOCKING_NEXT_STEPS.md` is preserved
