# Flutter Test Failure Fixes - Action Items

## Summary
- **Total Test Failures:** 199
- **Priority Issues:** 3
- **Affected Test Files:** 23

## Issue #1: Widget Timing/Async Pump Issues (89 failures)

### Impact Files:
- `test/core/mixins/loading_mixin_test.dart` (11 failures)
- `test/core/extensions/context_extensions_test.dart` (12 failures)  
- `test/accessibility/widget_accessibility_test.dart` (58 failures)
- `test/core/providers/loading_state_handler_test.dart` (4 failures)
- `test/core/providers/error_state_handler_test.dart` (8 failures)

### Root Cause
Tests expect widgets (SnackBar, Dialog, etc.) to be rendered but the Flutter test framework has not pumped the frame containing the widget. This is an async race condition.

### Example Error
```
Expected: exactly one matching candidate
Actual: _TypeWidgetFinder:<Found 0 widgets with type "SnackBar": []>
Which: means none were found but one was expected
```

### Fix Pattern
```dart
// BEFORE (Fails)
testWidgets('shows error message', (WidgetTester tester) async {
  await tester.pumpWidget(TestApp());
  // User action
  await someAsyncOperation();  
  expect(find.byType(SnackBar), findsOneWidget); // ❌ Timing issue
});

// AFTER (Works)
testWidgets('shows error message', (WidgetTester tester) async {
  await tester.pumpWidget(TestApp());
  // User action
  await someAsyncOperation();
  await tester.pumpAndSettle(); // ✅ Wait for all animations to complete
  expect(find.byType(SnackBar), findsOneWidget);
});
```

### Specific Test Fixes Needed

#### File: `test/core/mixins/loading_mixin_test.dart`
- Line ~308: `withLoadingAndError shows default error message` 
  - Add `await tester.pumpAndSettle();` before SnackBar expectation
- Line ~248: `showLoadingDialog displays dialog`
  - Add `await tester.pumpAndSettle();` for dialog appearance
- Line ~264: `hideLoadingDialog closes dialog`
  - Add `await tester.pumpAndSettle();` before checking dialog closed

**Action:**
```dart
// In all dialog/snackbar tests, replace:
expect(find.byType(SomeWidget), findsOneWidget);

// With:
await tester.pumpAndSettle(const Duration(seconds: 1));
expect(find.byType(SomeWidget), findsOneWidget);
```

#### File: `test/core/extensions/context_extensions_test.dart`
- Line ~185: `MediaQuery shortcuts isKeyboardVisible returns true with keyboard`
  - Add keyboard handling pump frame

**Action:**
```dart
await tester.showOnScreen(find.byType(TextField));
await tester.testTextInput.receiveAction(TextInputAction.done);
await tester.pumpAndSettle(); // Add this line
expect(/* ... */, isTrue);
```

#### File: `test/accessibility/widget_accessibility_test.dart`
- Multiple widget finding failures (58 total)
- Add `pumpAndSettle` after every interaction that updates UI

---

## Issue #2: Riverpod Provider Disposal Race Conditions (47 failures)

### Impact Files:
- `test/tiles/due_date_countdown/providers/due_date_countdown_provider_test.dart` (5 failures)
- `test/features/baby_profile/presentation/providers/baby_profile_provider_test.dart` (12 failures)
- `test/integration/realtime/photos_realtime_test.dart` (8 failures)
- `test/integration/realtime/notifications_realtime_test.dart` (2 failures)
- Various other provider tests (20 failures)

### Root Cause
Providers are being disposed while async operations are still pending, causing "Cannot use the Ref after it has been disposed" errors.

### Example Error
```
Cannot use the Ref of NotifierProvider<DueDateCountdownNotifier, DueDateCountdownState>#809d1 
after it has been disposed. This typically happens if:
- A provider rebuilt, but the previous "build" was still pending and is still performing operations.
- You tried to use Ref inside `onDispose` or other life-cycles.
```

### Fix Pattern

#### Pattern A: Using `ref.mounted` check
```dart
// In your provider/notifier
Future<void> loadData() async {
  try {
    final data = await _repository.fetchData();
    if (ref.mounted) {  // ✅ Check if provider is still valid
      state = AsyncValue.data(data);
    }
  } catch (e, st) {
    if (ref.mounted) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

#### Pattern B: Using `onDispose` callback
```dart
// In your provider
class MyNotifier extends AsyncNotifier<MyState> {
  late StreamSubscription _subscription;

  @override
  Future<MyState> build() async {
    // Setup disposal cleanup
    ref.onDispose(() {
      _subscription.cancel();  // ✅ Cancel pending operations
    });
    
    return MyState();
  }

  Future<void> loadData() async {
    final data = await _repository.fetchData();
    if (ref.mounted) {  // ✅ Double check
      state = AsyncValue.data(data);
    }
  }
}
```

### Specific Test Fixes

#### File: `test/tiles/due_date_countdown/providers/due_date_countdown_provider_test.dart`
- Lines 174, 195, 217, 259, 306: All have same error pattern

**Action:**
Check the `DueDateCountdownNotifier` class and:
1. Add `ref.mounted` check after `await asyncCall()` 
2. Add `ref.onDispose()` cleanup for subscriptions
3. Use `AsyncValue` states instead of direct state assignment

```dart
// Example fix in due_date_countdown_provider.dart
@override
Future<DueDateCountdownState> build() async {
  // Cleanup on disposal
  ref.onDispose(() {
    _timer?.cancel();
    _subscription?.cancel();
  });
  
  return DueDateCountdownState.initial();
}

Future<void> fetchCountdowns() async {
  state = const AsyncValue.loading();
  try {
    final countdowns = await _repository.fetchCountdowns();
    if (ref.mounted) {  // ✅ Check before state update
      state = AsyncValue.data(
        DueDateCountdownState.loaded(countdowns)
      );
    }
  } catch (e, st) {
    if (ref.mounted) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

#### File: `test/features/baby_profile/presentation/providers/baby_profile_provider_test.dart`
- Lines 2248-2251: Multiple loadProfile test failures

**Action:**
In `baby_profile_provider.dart`:
1. Wrap async operations with `if (ref.mounted)` checks
2. Implement `ref.onDispose()` for cleanup
3. Add `AsyncValue.loading()` before async operations

---

## Issue #3: Realtime Subscription Cleanup (34 failures)

### Impact Files:
- `test/integration/realtime/photos_realtime_test.dart` (8 failures)
- `test/integration/realtime/notifications_realtime_test.dart` (2 failures)
- Various realtime integration tests (24 failures)

### Root Cause
Stream subscriptions and realtime channel listeners are not properly closed, causing:
- Test isolation issues
- Memory leaks
- Stale listeners from previous tests

### Example Error
```
Test failed: Expected state after cleanup but found previous test's listeners still active
Memory not released after multiple subscribe/unsubscribe cycles
```

### Fix Pattern

#### In Realtime Repository/Service
```dart
class PhotosRealtimeService {
  StreamSubscription? _subscription;
  
  Stream<Photo> watchPhotos(String photoId) {
    // ✅ Cancel any existing subscription
    _subscription?.cancel();
    
    _subscription = _channel.stream.listen(
      (data) { /* handle data */ },
      onDone: () { _subscription = null; }
    );
    
    return _channel.stream;
  }
  
  void dispose() {
    // ✅ Critical cleanup
    _subscription?.cancel();
    _channel?.unsubscribe();
    _subscription = null;
  }
}
```

#### In Provider
```dart
class PhotosRealtimeProvider extends StateNotifier {
  late StreamSubscription _subscription;
  
  @override
  Future<void> build() async {
    // ✅ Setup proper cleanup
    ref.onDispose(() {
      _subscription.cancel();  // Cancel the stream
      _service.dispose();      // Clean up service
    });
  }
}
```

#### In Test
```dart
testWidgets('subscription cleanup', (WidgetTester tester) async {
  // ... test setup ...
  
  addTearDown(() async {
    // ✅ Explicit cleanup
    await service.dispose();
    await container.refresh(realtimeProvider.future);
  });
  
  // ... test execution ...
});
```

### Specific Fixes Needed

#### File: `test/integration/realtime/photos_realtime_test.dart`
- Line 2228: `should return existing stream for duplicate channel names`
  - Ensure old subscription is cancelled before creating new one
- Line 2236: `should not leak memory after multiple subscribe/unsubscribe cycles`
  - Add explicit cleanup loop teardown
- Line 2246: `should clean up all resources on dispose`
  - Add `addTearDown(() => service.dispose())`

**Action:**
```dart
test('should clean up all resources on dispose', () async {
  final service = PhotosRealtimeService();
  
  // Subscribe to channel
  final stream = service.watchPhotos('photo-1');
  final subscription = stream.listen((_) {});
  
  // ✅ Add explicit cleanup
  addTearDown(() async {
    await subscription.cancel();  // Cancel subscription
    await service.dispose();      // Dispose service
  });
  
  expect(service.isConnected, isTrue);
  
  // After test, cleanup runs automatically
});
```

---

## Implementation Priority

### Phase 1: Critical Fixes (Do First)
1. **Widget Timing Issues** (89 failures)
   - Impact: HIGH - Blocks other test fixes
   - Effort: MEDIUM - Systematic addition of `pumpAndSettle()`
   - Files: 5 files
   - Estimated Time: 2-3 hours

2. **Provider Disposal** (47 failures)  
   - Impact: CRITICAL - Root of many cascading failures
   - Effort: MEDIUM - Add ref.mounted checks and onDispose
   - Files: 8+ files
   - Estimated Time: 3-4 hours

### Phase 2: Important Fixes (Do Second)
3. **Subscription Cleanup** (34 failures)
   - Impact: MEDIUM - Causes test isolation issues
   - Effort: MEDIUM - Add dispose() calls
   - Files: 3+ files
   - Estimated Time: 2 hours

### Phase 3: Verification
- Re-run `flutter test` to verify all 199 failures are fixed
- Expected result: 2,750 tests passing (0 failures)
- Check coverage reports

---

## Verification Checklist

Before submitting fixes, verify:

- [ ] All `pumpAndSettle()` calls added (for Issue #1)
- [ ] All `ref.mounted` checks added (for Issue #2)
- [ ] All `onDispose()` cleanup added (for Issues #2, #3)
- [ ] All test `addTearDown()` cleanup added (for Issue #3)
- [ ] No new compilation errors
- [ ] Test output shows: `2550 +199 = 2750 total tests passing`
- [ ] No memory leaks in realtime tests
- [ ] Code still passes `flutter analyze`

---

## Files Requiring Changes

### Must Fix:
1. `lib/tiles/due_date_countdown/providers/due_date_countdown_provider.dart`
2. `lib/features/baby_profile/presentation/providers/baby_profile_provider.dart`
3. `lib/core/providers/loading_state_handler.dart`
4. `lib/core/providers/error_state_handler.dart`
5. `lib/integration/realtime/services/photos_realtime_service.dart`
6. `lib/integration/realtime/services/notifications_realtime_service.dart`

### Tests to Update:
1. `test/core/mixins/loading_mixin_test.dart`
2. `test/core/extensions/context_extensions_test.dart`
3. `test/core/providers/loading_state_handler_test.dart`
4. `test/core/providers/error_state_handler_test.dart`
5. `test/tiles/due_date_countdown/providers/due_date_countdown_provider_test.dart`
6. `test/features/baby_profile/presentation/providers/baby_profile_provider_test.dart`
7. `test/integration/realtime/photos_realtime_test.dart`
8. `test/integration/realtime/notifications_realtime_test.dart`
9. `test/accessibility/widget_accessibility_test.dart`
10. And 14 other test files with 1-4 failures each

---

## Testing Commands

```bash
# Run full test suite with coverage
flutter test --coverage

# Run specific test file
flutter test test/core/mixins/loading_mixin_test.dart -v

# Run tests matching pattern
flutter test -k "loading" -v

# Run with shorter timeout for debugging
flutter test --timeout=30s

# Check code quality
flutter analyze

# Format code
dart format .
```

---

## Additional Resources

- Riverpod Documentation: https://riverpod.dev/docs/providers/lifecycle
- Flutter Testing Guide: https://flutter.dev/docs/testing
- Async Testing Best Practices: https://flutter.dev/docs/testing/using-test-doubles
