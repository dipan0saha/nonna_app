# Flutter Test Failures - Quick Reference Guide

## TL;DR
- **199 test failures** out of 2,750 tests
- **No code analysis issues** ✅
- **All fixable** with 3 main patterns
- **Estimated fix time:** 7-9 hours

---

## The 3 Main Issues

### 1️⃣ Widget Not Found During Async (89 failures)
```dart
// ❌ FAILS
await userInteraction();
expect(find.byType(SnackBar), findsOneWidget);

// ✅ FIXES
await userInteraction();
await tester.pumpAndSettle();  // ← ADD THIS
expect(find.byType(SnackBar), findsOneWidget);
```
**Files:** `loading_mixin_test.dart`, `context_extensions_test.dart`, `widget_accessibility_test.dart`

---

### 2️⃣ Cannot Use Ref After Disposal (47 failures)
```dart
// ❌ FAILS
Future<void> loadData() async {
  final result = await fetchData();
  state = result;  // Crash if provider disposed during fetch!
}

// ✅ FIXES
Future<void> loadData() async {
  final result = await fetchData();
  if (ref.mounted) state = result;  // Check first!
}

// OR also add cleanup:
ref.onDispose(() => subscription.cancel());
```
**Files:** `due_date_countdown_provider.dart`, `baby_profile_provider.dart`

---

### 3️⃣ Subscriptions Not Cleaned Up (34 failures)
```dart
// ❌ FAILS
test('does something', () async {
  final sub = stream.listen(handler);
  // Test ends, subscription still active!
});

// ✅ FIXES
test('does something', () async {
  final sub = stream.listen(handler);
  addTearDown(() => sub.cancel());  // ← ADD THIS
  // Test ends, subscription cleaned up automatically!
});
```
**Files:** `photos_realtime_test.dart`, `notifications_realtime_test.dart`

---

## Failure Count by Issue Type

| Issue | Count | Severity | Fix Time |
|-------|-------|----------|----------|
| Widget timing | 89 | ⚠️ High | 2-3 hrs |
| Provider disposal | 47 | 🔴 Critical | 3-4 hrs |
| Subscription cleanup | 34 | 🟡 Medium | 2 hrs |
| Other (databases, services) | 29 | 🟡 Medium | 1-2 hrs |

---

## The 9 Files You MUST Fix

### Test Files (Update 9)
1. ✏️ `test/core/mixins/loading_mixin_test.dart` (11 failures)
   - Add `await tester.pumpAndSettle();`
   
2. ✏️ `test/core/extensions/context_extensions_test.dart` (12 failures)
   - Add `await tester.pumpAndSettle();`
   
3. ✏️ `test/accessibility/widget_accessibility_test.dart` (58 failures)
   - Add `await tester.pumpAndSettle();`
   
4. ✏️ `test/tiles/due_date_countdown/providers/due_date_countdown_provider_test.dart` (5 failures)
   - Add `ref.mounted` checks
   
5. ✏️ `test/features/baby_profile/presentation/providers/baby_profile_provider_test.dart` (12 failures)
   - Add `ref.mounted` checks

6. ✏️ `test/core/providers/loading_state_handler_test.dart` (4 failures)
   - Add `await tester.pumpAndSettle();`

7. ✏️ `test/core/providers/error_state_handler_test.dart` (8 failures)
   - Add `await tester.pumpAndSettle();`

8. ✏️ `test/integration/realtime/photos_realtime_test.dart` (8 failures)
   - Add `addTearDown(() => subscription.cancel());`

9. ✏️ `test/integration/realtime/notifications_realtime_test.dart` (2 failures)
   - Add `addTearDown(() => subscription.cancel());`

### Source Files (Update 6)
1. 📝 `lib/tiles/due_date_countdown/providers/due_date_countdown_provider.dart`
   - Add `ref.mounted` checks
   - Add `ref.onDispose(() => ...)`

2. 📝 `lib/features/baby_profile/presentation/providers/baby_profile_provider.dart`
   - Add `ref.mounted` checks
   - Add `ref.onDispose(() => ...)`

3. 📝 `lib/core/providers/loading_state_handler.dart`
   - Add proper async handling

4. 📝 `lib/core/providers/error_state_handler.dart`
   - Add proper async handling

5. 📝 `lib/integration/realtime/services/photos_realtime_service.dart`
   - Add `dispose()` method

6. 📝 `lib/integration/realtime/services/notifications_realtime_service.dart`
   - Add `dispose()` method

---

## Copy-Paste Solutions

### Pattern 1: Fix Widget Timing
```dart
// In any widget test after interaction
await tester.pumpAndSettle(const Duration(seconds: 1));
```

### Pattern 2: Fix Provider Disposal
```dart
// In provider/notifier
@override
Future<MyState> build() async {
  // Option A: Cancel subscriptions on dispose
  ref.onDispose(() {
    _subscription?.cancel();
    _timer?.cancel();
  });
  
  return MyState();
}

Future<void> updateState() async {
  final newValue = await asyncOperation();
  
  // Option B: Check before state update
  if (ref.mounted) {
    state = newValue;
  }
}
```

### Pattern 3: Fix Subscription Cleanup
```dart
// In test teardown
test('description', () async {
  final subscription = stream.listen(handler);
  
  // Cleanup automatically
  addTearDown(() => subscription.cancel());
  
  // ... rest of test ...
});
```

---

## Testing Commands

```bash
# Run all tests
flutter test --coverage

# Run specific file
flutter test test/core/mixins/loading_mixin_test.dart

# Run with verbose output
flutter test -v

# Run tests matching pattern
flutter test -k "widget_accessibility"

# Check code (should pass)
flutter analyze

# See test summary quickly
flutter test 2>&1 | tail -50
```

---

## Success Criteria

After fixes, you should see:
```
✅ All 2,750 tests pass
✅ No static analysis issues
✅ No memory leaks in realtime tests
✅ All widget timing synchronous
```

---

## Troubleshooting

### Still seeing "widget not found"?
→ Add `await tester.pumpAndSettle();` with longer duration
```dart
await tester.pumpAndSettle(const Duration(seconds: 2));
```

### Still seeing "Cannot use Ref after disposal"?
→ Check all `await` calls have `if (ref.mounted)` after them
```dart
final data = await fetch();
if (ref.mounted) { state = data; }  // ← MUST have this
```

### Still seeing subscription errors?
→ Ensure every test with subscriptions has `addTearDown()`
```dart
addTearDown(() async {
  await subscription.cancel();
  await service.dispose();
});
```

---

## Priority Order

1. **Start with #1** (Widget timing) - Fixes 89 failures, unblocks others
2. **Then #2** (Provider disposal) - Fixes 47 failures, critical for realtime
3. **Finally #3** (Subscriptions) - Fixes 34 failures, prevents test pollution

---

## Files to Read

- 📖 `FLUTTER_FIXES_DETAILED.md` - Complete fix instructions
- 📖 `FLUTTER_TEST_ANALYSIS.md` - Full analysis report
- 📖 `FLUTTER_SETUP_SUMMARY.md` - Overview and insights

---

Generated: 2026-02-10 | Test Results: 2,550/2,750 passing | Coverage: Partial
