# Core Reusable UI Components

This directory contains the Phase 1 reusable UI components for the nonna_app project. These components provide a consistent user experience across the application.

## Components Overview

### 1. LoadingIndicator (`loading_indicator.dart`)

A consistent loading spinner with circular progress indicator.

#### Features
- Customizable size and color
- Adjustable stroke width
- Theme-aware color defaults
- Loading overlay variant for blocking UI

#### Usage

```dart
// Basic loading indicator
LoadingIndicator()

// Custom size and color
LoadingIndicator(
  size: 60.0,
  color: Colors.blue,
  strokeWidth: 5.0,
)

// Loading overlay
LoadingOverlay(
  isLoading: isLoadingState,
  child: YourContentWidget(),
)
```

---

### 2. ErrorView (`error_view.dart`)

Error state display with error messages and retry functionality.

#### Features
- Display error icon and messages
- Optional retry button with callback
- Custom title and icon support
- Inline variant for compact display

#### Usage

```dart
// Full error view
ErrorView(
  message: 'Failed to load data',
  onRetry: () => fetchData(),
  title: 'Connection Error',
)

// Inline error view
InlineErrorView(
  message: 'Unable to save',
  onRetry: () => saveData(),
)
```

---

### 3. EmptyState (`empty_state.dart`)

Empty data state with placeholder illustrations.

#### Features
- Customizable icon, title, and message
- Optional call-to-action button
- Additional description support
- Compact variant for smaller spaces

#### Usage

```dart
// Full empty state
EmptyState(
  icon: Icons.inbox_outlined,
  title: 'No Messages',
  message: 'You don\'t have any messages yet',
  description: 'Messages will appear here when you receive them',
  actionLabel: 'Compose',
  onAction: () => navigateToCompose(),
)

// Compact empty state
CompactEmptyState(
  icon: Icons.search,
  message: 'No results found',
)
```

---

### 4. CustomButton (`custom_button.dart`)

Branded button component with multiple variants and states.

#### Features
- Three variants: Primary, Secondary, Tertiary
- Loading state with circular indicator
- Disabled state support
- Optional icon before label
- Full-width option
- Custom padding

#### Usage

```dart
// Primary button
CustomButton(
  label: 'Save',
  onPressed: () => save(),
  variant: ButtonVariant.primary,
  icon: Icons.save,
)

// Secondary button
CustomButton(
  label: 'Cancel',
  onPressed: () => cancel(),
  variant: ButtonVariant.secondary,
)

// Loading state
CustomButton(
  label: 'Processing',
  onPressed: () => process(),
  isLoading: true,
)

// Full width button
CustomButton(
  label: 'Continue',
  onPressed: () => next(),
  fullWidth: true,
)

// Icon button
CustomIconButton(
  icon: Icons.favorite,
  onPressed: () => toggleFavorite(),
  tooltip: 'Add to favorites',
)
```

---

### 5. ShimmerPlaceholder (`shimmer_placeholder.dart`)

Loading skeleton screens with shimmer animation.

#### Features
- Customizable width, height, and shape
- Adapts to light/dark themes
- Pre-built variants: ListTile, Card, Text
- Smooth shimmer animation

#### Usage

```dart
// Basic shimmer placeholder
ShimmerPlaceholder(
  width: 100,
  height: 20,
  borderRadius: BorderRadius.circular(4),
)

// Circle shimmer
ShimmerPlaceholder(
  width: 50,
  height: 50,
  shape: BoxShape.circle,
)

// Shimmer list tile
ShimmerListTile(
  hasLeading: true,
  hasSubtitle: true,
  hasTrailing: false,
)

// Shimmer card
ShimmerCard(
  width: 200,
  height: 300,
  hasImage: true,
  hasTitle: true,
  hasSubtitle: true,
)

// Multiple text lines
ShimmerText(
  lines: 3,
  width: double.infinity,
  spacing: 8,
)
```

---

## Design Principles

All components follow these principles:

1. **Consistency**: Use Material Design guidelines and theme-aware styling
2. **Accessibility**: Proper semantic markup and screen reader support
3. **Customization**: Flexible parameters for different use cases
4. **Performance**: Optimized rendering and minimal rebuilds
5. **Testing**: Comprehensive test coverage (80%+)

---

## Dependencies

- `flutter`: Core Flutter SDK
- `shimmer`: ^3.0.0 (for ShimmerPlaceholder only)

---

## Testing

All components have comprehensive test coverage in `test/core/widgets/`:

- `loading_indicator_test.dart` - 15+ test cases
- `error_view_test.dart` - 17+ test cases
- `empty_state_test.dart` - 15+ test cases
- `custom_button_test.dart` - 25+ test cases
- `shimmer_placeholder_test.dart` - 20+ test cases

Run tests with:
```bash
flutter test test/core/widgets/
```

---

## Examples

See individual widget files for detailed documentation and parameter descriptions. Each widget includes:
- Inline documentation comments
- Parameter descriptions
- Default values
- Usage examples in tests

---

## Contributing

When adding or modifying components:

1. Follow existing code style and patterns
2. Add comprehensive documentation
3. Write thorough test cases (aim for 80%+ coverage)
4. Ensure theme compatibility (light/dark modes)
5. Test on multiple screen sizes
6. Consider accessibility requirements

---

## Related Documentation

- Phase 1 requirements: `docs/Core_development_component_identification.md` (Section 3.4.2)
- Material Design guidelines: https://m3.material.io/
- Flutter widget documentation: https://docs.flutter.dev/ui/widgets
