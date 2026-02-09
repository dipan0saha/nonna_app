# Test Fix Verification Guide

## Purpose
This guide helps verify that the mocking fixes for `new_followers_provider_test_refactored.dart` have resolved all issues.

## Changes Made

### 1. Enhanced setUp() in test file
**File**: `test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart`

**Changes**:
- Added default database mock configuration: `when(mockDatabase.select(any)).thenAnswer((_) => FakePostgrestBuilder([]))`
- Added realtime unsubscribe mock: `when(mockRealtime.unsubscribe(any)).thenAnswer((_) async {})`
- Ensures all mocks are fully configured before ProviderContainer creation

**Why**: Prevents "Cannot call `when` within a stub response" errors by ensuring all mock methods are stubbed before any test code executes.

### 2. Enhanced tearDown() in test file
**File**: `test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart`

**Changes**:
- Added explicit mock reset calls: `reset(mockDatabase)`, `reset(mockCache)`, `reset(mockRealtime)`
- Called after container.dispose()

**Why**: Prevents mock state leakage between tests, ensuring each test starts with a clean slate.

## Verification Steps

### Step 1: Regenerate Mocks (if needed)
```bash
cd /path/to/nonna_app

# Clean any previous build artifacts
flutter clean

# Get dependencies
flutter pub get

# Regenerate mocks
flutter pub run build_runner build --delete-conflicting-outputs
```

**Expected Output**:
- File `test/mocks/mock_services.mocks.dart` should be generated/updated
- File should be ~240KB in size
- Should contain MockDatabaseService, MockCacheService, MockRealtimeService, etc.

### Step 2: Run the Specific Test
```bash
flutter test test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart --reporter expanded
```

**Expected Output** (if fixes work):
```
00:00 +0: loading test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart
00:01 +0: NewFollowersProvider Tests Refactored Initial State initial state has empty followers
00:01 +1: NewFollowersProvider Tests Refactored Data Fetching fetchFollowers handles database errors
00:01 +2: NewFollowersProvider Tests Refactored Data Fetching sets loading state while fetching
00:01 +3: NewFollowersProvider Tests Refactored Data Fetching fetches followers from database when cache is empty
... (more tests)
00:02 +23: All tests passed!
```

**If tests still fail**, proceed to Step 3.

### Step 3: Check for Specific Errors

#### Error Type 1: "Invalid argument(s): `thenReturn` should not be used to return a Future"
**What this means**: Somewhere in the code, `thenReturn()` is being used with a Future or Future-like object.

**How to fix**:
1. Find the line mentioned in the error
2. Change `thenReturn(futureValue)` to `thenAnswer((_) async => value)` or `thenAnswer((_) => futureValue)`
3. For FakePostgrestBuilder specifically, ALWAYS use `thenAnswer`, never `thenReturn`

**Example**:
```dart
// ❌ WRONG
when(mockDatabase.select(any)).thenReturn(FakePostgrestBuilder([...]));

// ✅ CORRECT
when(mockDatabase.select(any)).thenAnswer((_) => FakePostgrestBuilder([...]));
```

#### Error Type 2: "Cannot call `when` within a stub response"
**What this means**: Mockito detected a `when()` call happening while another stub is being executed.

**Possible causes**:
1. Mock not configured in setUp()
2. Async operation from previous test still running
3. Provider accessing mock during initialization

**How to fix**:
1. Ensure ALL mock methods are stubbed in setUp() before creating ProviderContainer
2. Ensure tearDown() properly resets mocks
3. Consider adding delays or explicit waits in tests

**Example fix**:
```dart
setUp(() {
  mockService = MockService();
  
  // Configure ALL methods that might be called
  when(mockService.method1()).thenAnswer((_) async => null);
  when(mockService.method2()).thenReturn(true);
  when(mockService.method3(any)).thenAnswer((_) async => []);
  // etc.
  
  // THEN create the container
  container = ProviderContainer(overrides: [...]);
});

tearDown(() {
  container.dispose();
  reset(mockService); // Clean state for next test
});
```

### Step 4: Run with Verbose Output
If issues persist, run with verbose output:

```bash
flutter test test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart --reporter expanded --verbose
```

Save the output to a file:
```bash
flutter test test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart > test_output_new.txt 2>&1
```

Then examine `test_output_new.txt` for detailed error messages and stack traces.

### Step 5: Verify Individual Test
If specific tests are failing, run them individually:

```bash
# Run a specific test by name
flutter test test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart --name "sets loading state"
```

This helps isolate which test is causing issues.

## Common Issues and Solutions

### Issue: Tests pass when run individually but fail when run together
**Cause**: Mock state leakage between tests
**Solution**: Ensure tearDown() calls reset() on all mocks

### Issue: First few tests pass, then all remaining tests fail
**Cause**: A failing test leaves mocks in bad state
**Solution**: 
1. Identify the first failing test
2. Fix that test
3. Ensure it properly cleans up

### Issue: Intermittent failures (tests sometimes pass, sometimes fail)
**Cause**: Race conditions in async code
**Solution**:
1. Use proper async/await patterns
2. Don't check state synchronously during async operations
3. Add explicit waits if needed

### Issue: "Bad state" errors
**Cause**: Riverpod provider lifecycle issues
**Solution**:
1. Ensure provider container is properly initialized
2. Don't read from provider during setup
3. Consider using different provider types if needed

## Next Steps if Issues Persist

### 1. Check Mock Generation
```bash
# Verify the generated mock file exists and is recent
ls -lh test/mocks/mock_services.mocks.dart

# Check it contains expected mocks
grep "class MockDatabaseService" test/mocks/mock_services.mocks.dart
grep "class MockCacheService" test/mocks/mock_services.mocks.dart
grep "class MockRealtimeService" test/mocks/mock_services.mocks.dart
```

### 2. Compare with Working Test
If the refactored test still fails, compare with the original non-refactored test:

```bash
# Run the original test
flutter test test/tiles/new_followers/providers/new_followers_provider_test.dart
```

If the original passes but refactored fails, the issue is in the refactoring.

### 3. Check for Conflicting Mocks
```bash
# Search for other mock files that might conflict
find test -name "*.mocks.dart" -type f
```

If there are multiple mock files for the same services, they might conflict.

### 4. Verify Imports
Check that the test file imports from the centralized mocks:
```dart
// ✅ CORRECT - imports from centralized location
import '../../../mocks/mock_services.mocks.dart';

// ❌ WRONG - imports from individual test mock file
import 'new_followers_provider_test.mocks.dart';
```

## Success Criteria

The fixes are successful when:
- ✅ All 23 tests pass
- ✅ No "Cannot call when within stub response" errors
- ✅ No "thenReturn should not be used with Future" errors
- ✅ Tests run in <5 seconds
- ✅ Tests are deterministic (pass consistently)

## Reporting Results

After testing, please report:
1. **Test command used**: (e.g., `flutter test test/tiles/...`)
2. **Result**: Pass/Fail and number of tests (e.g., "21/23 passed")
3. **Error messages**: Full error output if tests still fail
4. **Flutter version**: Output of `flutter --version`
5. **Dart version**: Output of `dart --version`

This information helps diagnose any remaining issues.

## Contact/Support

If issues persist after following this guide:
1. Capture the full test output
2. Check if the errors match the patterns described above
3. Review the test file line by line for any remaining `thenReturn` with Futures
4. Consider seeking help with specific error messages and context

---

**Document Version**: 1.0
**Last Updated**: 2026-02-08
**Related Files**: 
- `test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart`
- `test_results.txt` (original errors)
- `FIX_SUMMARY.md` (previous fix attempts)
- `MOCKING_QUICK_REFERENCE.md` (best practices)
