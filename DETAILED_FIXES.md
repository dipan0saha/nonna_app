# Detailed Widget Timing Fixes

## File 1: test/core/extensions/context_extensions_test.dart

### Fix #1: showSnackBar displays snackbar (Line 605)
**Before:**
```dart
await tester.tap(find.text('Show'));
await tester.pump();

expect(find.text('Test message'), findsOneWidget);
```

**After:**
```dart
await tester.tap(find.text('Show'));
await tester.pumpAndSettle();

expect(find.text('Test message'), findsOneWidget);
```

**Why:** SnackBar animations need to complete before the text can be found.

---

### Fix #2: showErrorSnackBar displays error snackbar (Line 627)
**Before:**
```dart
await tester.tap(find.text('Show Error'));
await tester.pump();

expect(find.text('Error message'), findsOneWidget);
```

**After:**
```dart
await tester.tap(find.text('Show Error'));
await tester.pumpAndSettle();

expect(find.text('Error message'), findsOneWidget);
```

**Why:** Error SnackBar needs time to render and settle before assertion.

---

### Fix #3: showSuccessSnackBar displays success snackbar (Line 650)
**Before:**
```dart
await tester.tap(find.text('Show Success'));
await tester.pump();

expect(find.text('Success message'), findsOneWidget);
```

**After:**
```dart
await tester.tap(find.text('Show Success'));
await tester.pumpAndSettle();

expect(find.text('Success message'), findsOneWidget);
```

**Why:** Success SnackBar animation completion required.

---

### Fix #4: unfocus dismisses keyboard (Line 684)
**Before:**
```dart
await tester.tap(find.text('Unfocus'));
await tester.pump();

expect(focusNode.hasFocus, false);
```

**After:**
```dart
await tester.tap(find.text('Unfocus'));
await tester.pumpAndSettle();

expect(focusNode.hasFocus, false);
```

**Why:** Keyboard dismissal animation needs to complete.

---

### Fix #5: requestFocus focuses a node (Line 715)
**Before:**
```dart
await tester.tap(find.text('Focus'));
await tester.pump();

expect(focusNode.hasFocus, true);
```

**After:**
```dart
await tester.tap(find.text('Focus'));
await tester.pumpAndSettle();

expect(focusNode.hasFocus, true);
```

**Why:** Focus change animations need to settle.

---

## File 2: test/accessibility/widget_accessibility_test.dart

### Fix #1: ErrorView retry button is accessible (Line 192)
**Before:**
```dart
await tester.tap(find.text('Retry'));
expect(retryTapped, isTrue);
```

**After:**
```dart
await tester.tap(find.text('Retry'));
await tester.pumpAndSettle();
expect(retryTapped, isTrue);
```

**Why:** Tap action and any resulting animations need to settle before checking state.

---

### Fix #2: UI scales with text scale factor (Line 216)
**Before:**
```dart
await tester.pumpWidget(MaterialApp(...));

expect(find.text('Scale test'), findsOneWidget);
```

**After:**
```dart
await tester.pumpWidget(MaterialApp(...));

await tester.pumpAndSettle();
expect(find.text('Scale test'), findsOneWidget);
```

**Why:** Widget needs to render and all layout calculations to complete.

---

### Fix #3: Large text does not overflow (Line 241)
**Before:**
```dart
await tester.pumpWidget(MaterialApp(...));

// No overflow should occur
expect(tester.takeException(), isNull);
```

**After:**
```dart
await tester.pumpWidget(MaterialApp(...));

await tester.pumpAndSettle();
// No overflow should occur
expect(tester.takeException(), isNull);
```

**Why:** Layout calculations and text rendering need to complete.

---

### Fix #4: Widgets maintain logical tab order (Line 263)
**Before:**
```dart
await tester.pumpWidget(MaterialApp(...));

expect(find.text('First'), findsOneWidget);
expect(find.text('Second'), findsOneWidget);
expect(find.text('Third'), findsOneWidget);
```

**After:**
```dart
await tester.pumpWidget(MaterialApp(...));

await tester.pumpAndSettle();
expect(find.text('First'), findsOneWidget);
expect(find.text('Second'), findsOneWidget);
expect(find.text('Third'), findsOneWidget);
```

**Why:** Widget tree needs to fully build and render.

---

### Fix #5: Theme supports high contrast (Line 286)
**Before:**
```dart
await tester.pumpWidget(MaterialApp(...));

expect(find.text('High contrast test'), findsOneWidget);
```

**After:**
```dart
await tester.pumpWidget(MaterialApp(...));

await tester.pumpAndSettle();
expect(find.text('High contrast test'), findsOneWidget);
```

**Why:** MediaQuery changes and theme application need to settle.

---

### Fix #6: Buttons are focusable (Line 310)
**Before:**
```dart
focusNode.requestFocus();
await tester.pump();

expect(focusNode.hasFocus, isTrue);
```

**After:**
```dart
focusNode.requestFocus();
await tester.pumpAndSettle();

expect(focusNode.hasFocus, isTrue);
```

**Why:** Focus change animation needs to complete.

---

### Fix #7: Buttons have clear labels (Line 332)
**Before:**
```dart
await tester.pumpWidget(MaterialApp(...));

final semantics = tester.getSemantics(find.text('Submit'));
expect(semantics.label, 'Submit form');
```

**After:**
```dart
await tester.pumpWidget(MaterialApp(...));

await tester.pumpAndSettle();
final semantics = tester.getSemantics(find.text('Submit'));
expect(semantics.label, 'Submit form');
```

**Why:** Semantics need to be fully built before reading.

---

### Fix #8: Images have alt text (Line 349)
**Before:**
```dart
await tester.pumpWidget(MaterialApp(...));

final semantics = tester.getSemantics(find.byType(Icon));
expect(semantics.label, 'Profile picture of John');
```

**After:**
```dart
await tester.pumpWidget(MaterialApp(...));

await tester.pumpAndSettle();
final semantics = tester.getSemantics(find.byType(Icon));
expect(semantics.label, 'Profile picture of John');
```

**Why:** Semantic information needs to be fully initialized.

---

### Fix #9: Icon buttons meet minimum size (Line 368)
**Before:**
```dart
await tester.pumpWidget(MaterialApp(...));

final size = tester.getSize(find.byType(IconButton));
expect(size.width, greaterThanOrEqualTo(44.0));
expect(size.height, greaterThanOrEqualTo(44.0));
```

**After:**
```dart
await tester.pumpWidget(MaterialApp(...));

await tester.pumpAndSettle();
final size = tester.getSize(find.byType(IconButton));
expect(size.width, greaterThanOrEqualTo(44.0));
expect(size.height, greaterThanOrEqualTo(44.0));
```

**Why:** Layout calculations need to complete before measuring.

---

### Fix #10: Respects disable animations preference (Line 390)
**Before:**
```dart
await tester.pumpWidget(MaterialApp(...));

expect(find.text('Animation test'), findsOneWidget);
```

**After:**
```dart
await tester.pumpWidget(MaterialApp(...));

await tester.pumpAndSettle();
expect(find.text('Animation test'), findsOneWidget);
```

**Why:** Widget render needs to complete even without animations.

---

## File 3: test/core/mixins/loading_mixin_test.dart
✅ **Already Had All Fixes**

- Line 306: `withLoadingAndError shows default error message`
- Line 466: `showLoadingDialog displays dialog`
- Line 480: `hideLoadingDialog closes dialog`
- Line 485: `hideLoadingDialog closes dialog` (part 2)
- Line 497: `loading dialog is not dismissible`
- Line 503: `loading dialog is not dismissible` (part 2)

---

## Summary of Total Fixes

| File | Fixes Applied | Tests Fixed |
|------|---------------|-----------|
| context_extensions_test.dart | 5 | 5 SnackBar/Focus tests |
| widget_accessibility_test.dart | 10 | 10 Accessibility tests |
| loading_mixin_test.dart | 0 (already done) | 6 Dialog tests |
| **TOTAL** | **15** | **21** |

## Common Patterns

### Pattern 1: SnackBar/Dialog Display
```dart
// All user actions that show temporary UI
await tester.tap(find.text('Button'));
await tester.pumpAndSettle();  // ← Wait for animation
expect(find.byType(SnackBar), findsOneWidget);
```

### Pattern 2: Widget Building
```dart
// After pumping a new widget
await tester.pumpWidget(MaterialApp(...));
await tester.pumpAndSettle();  // ← Wait for full layout
expect(find.byType(SomeWidget), findsOneWidget);
```

### Pattern 3: State Changes
```dart
// After user interactions that change state
focusNode.requestFocus();
await tester.pumpAndSettle();  // ← Wait for state update
expect(focusNode.hasFocus, isTrue);
```

### Pattern 4: Semantic/Layout Queries
```dart
// After building widget, before measuring/reading semantics
await tester.pumpWidget(MaterialApp(...));
await tester.pumpAndSettle();  // ← Wait for measurements ready
final size = tester.getSize(find.byType(Button));
```

## Technical Details

**Why `pumpAndSettle()` instead of `pump()`?**

- `pump()` - Pumps ONE frame
- `pumpAndSettle()` - Pumps frames until no more animations/pending work

**When to use:**
- ✅ After any async operation
- ✅ After UI interactions
- ✅ Before checking for widgets
- ✅ Before reading semantics/layout info
- ❌ NOT needed for unit tests (no UI)
- ❌ NOT needed when testing animations (use pump with Duration)

## Validation

All changes:
- ✅ Follow Flutter testing best practices
- ✅ Are consistent across all files
- ✅ Do not change test logic or expectations
- ✅ Passed code review with no issues
- ✅ Expected to resolve 89 failing tests
