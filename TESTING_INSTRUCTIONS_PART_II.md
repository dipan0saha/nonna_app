# Testing Instructions - After Mocking Fixes Part II

## Overview

This document provides instructions for testing the fixes applied to resolve the mocking issues documented in `test_results.txt` and explained in detail in `FIX_SUMMARY_PART_II.md`.

## What Was Fixed

1. **Incorrect use of `thenReturn` with `FakePostgrestBuilder`**
   - Fixed 22 test files across the codebase
   - Changed `.thenReturn(FakePostgrestBuilder(...))` to `.thenAnswer((_) => FakePostgrestBuilder(...))`
   - Reason: FakePostgrestBuilder implements `then()`, making it Future-like

2. **Redundant mock setup**
   - Removed redundant `when(mockCache.isInitialized).thenReturn(true)` from one test

3. **Improved async syntax**
   - Changed `.thenAnswer((_) async => Future.value())` to `.thenAnswer((_) async {})`

## Testing Commands

### Test 1: Run the Refactored Test (Primary Target)

```bash
flutter test test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart
```

**Expected Output:**
```
00:00 +23: All tests passed!
```

**What This Verifies:**
- The primary test file mentioned in the issue now passes
- All 23 tests in the file execute successfully
- No more "Invalid argument(s): thenReturn should not be used to return a Future" errors
- No more "Cannot call when within a stub response" errors

### Test 2: Run All Tile Provider Tests

```bash
flutter test test/tiles/
```

**Expected Output:**
```
All tests passed!
```

**What This Verifies:**
- All 12 tile provider test files work correctly
- The systematic fix was applied correctly across all tile tests

**Tile Tests Affected:**
- new_followers_provider_test.dart (and _refactored.dart)
- recent_purchases_provider_test.dart
- upcoming_events_provider_test.dart
- notifications_provider_test.dart
- recent_photos_provider_test.dart
- tile_config_provider_test.dart
- registry_highlights_provider_test.dart
- engagement_recap_provider_test.dart
- storage_usage_provider_test.dart
- due_date_countdown_provider_test.dart
- rsvp_tasks_provider_test.dart
- invites_status_provider_test.dart
- registry_deals_provider_test.dart

### Test 3: Run All Feature Provider Tests

```bash
flutter test test/features/
```

**Expected Output:**
```
All tests passed!
```

**What This Verifies:**
- All 6 feature provider test files work correctly
- The fix was applied to all feature tests

**Feature Tests Affected:**
- auth_provider_test.dart
- baby_profile_provider_test.dart
- calendar_screen_provider_test.dart
- gallery_screen_provider_test.dart
- profile_provider_test.dart
- registry_screen_provider_test.dart

### Test 4: Run Full Test Suite

```bash
flutter test
```

**Expected Output:**
```
All tests passed!
```

**What This Verifies:**
- No regression in any other tests
- All helper and mock files work correctly
- The entire test suite is healthy

## Troubleshooting

### Issue 1: Tests Still Failing with "thenReturn" Error

**Symptoms:**
```
Invalid argument(s): `thenReturn` should not be used to return a Future.
```

**Solution:**
1. Check if there are any other test files not covered by the fix
2. Search for the pattern: `grep -r "\.thenReturn(FakePostgrestBuilder" test/`
3. If found, apply the same fix: change `.thenReturn(` to `.thenAnswer((_) =>`

### Issue 2: Tests Failing with "Cannot call when within a stub response"

**Symptoms:**
```
Bad state: Cannot call `when` within a stub response
```

**Likely Causes:**
1. Mock setup in `setUp()` has wrong order
2. Re-stubbing a mock property that's already stubbed

**Solution:**
1. Ensure `mockCache.isInitialized` is stubbed FIRST in setUp()
2. Remove redundant stub calls in individual tests
3. Check for any nested `when()` calls

### Issue 3: Mocks Not Generated

**Symptoms:**
```
Error: Could not find a file named "mock_services.mocks.dart"
```

**Solution:**
Generate mocks using build_runner:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue 4: Type Errors with FakePostgrestBuilder

**Symptoms:**
```
type 'SupabaseQueryBuilder' is not a subtype of type 'PostgrestBuilder<...>'
```

**Solution:**
This should already be fixed in `fake_postgrest_builders.dart`. If you see this error:
1. Check that `_createBaseBuilder()` calls `.select()` on the query builder
2. Verify the return type annotation is correct
3. See `FIX_SUMMARY.md` for the complete fix details

## Verification Checklist

After running all tests, verify:

- [ ] Refactored test file passes all 23 tests
- [ ] All tile provider tests pass
- [ ] All feature provider tests pass
- [ ] Full test suite passes
- [ ] No Mockito-related errors in any test output
- [ ] No "thenReturn" errors for FakePostgrestBuilder
- [ ] No "Cannot call when within a stub response" errors

## Success Criteria

✅ **All tests should pass** with no Mockito-related errors.

If any tests are still failing:
1. Check the error message
2. Refer to the Troubleshooting section
3. Consult `FIX_SUMMARY_PART_II.md` for detailed explanations
4. Check `MOCKING_QUICK_REFERENCE.md` for best practices

## Additional Verification (Optional)

### Verify Specific Tests

To test specific scenarios from the original `test_results.txt`:

```bash
# Test that was failing with thenReturn error
flutter test test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart \
  --plain-name "sets loading state while fetching"

# Tests that were failing with "Cannot call when" error
flutter test test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart \
  --plain-name "fetches followers from database when cache is empty"

flutter test test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart \
  --plain-name "force refresh bypasses cache"

flutter test test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart \
  --plain-name "uses cached data when available"
```

### Check for Any Remaining Issues

Search for potential issues:

```bash
# Should return no results:
grep -r "\.thenReturn(FakePostgrestBuilder" test/

# Should only show results in documentation files:
grep -r "Cannot call when within a stub response" .
```

## Next Steps

After successful testing:

1. ✅ Confirm all tests pass
2. ✅ Update `MOCKING_NEXT_STEPS.md` Phase 2 as complete
3. ✅ Update `Core_development_component_identification_checklist.md`
4. ✅ Consider updating `MOCKING_QUICK_REFERENCE.md` with FakePostgrestBuilder guidance

## Summary

The fixes applied should resolve all issues documented in `test_results.txt`. The systematic approach ensures that not only the refactored test file is fixed, but all other test files with the same issue are also corrected.

---

**Related Documents:**
- `FIX_SUMMARY_PART_II.md` - Detailed explanation of fixes
- `test_results.txt` - Original failing test results
- `MOCKING_NEXT_STEPS.md` - Centralized mocking strategy
- `MOCKING_QUICK_REFERENCE.md` - Mocking best practices
