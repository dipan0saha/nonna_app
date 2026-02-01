# Core Examples

This directory contains example implementations demonstrating the usage of core utilities in the nonna_app.

## Examples

### Accessibility Example

**File**: `accessibility_example.dart`

Demonstrates the integration of Phase 3 utilities:
- Dynamic Type Handler
- RTL Support Handler

**Features Shown**:
- Text scaling with system font settings
- RTL layout mirroring for right-to-left languages
- Adaptive layouts based on text scale
- Icon mirroring for navigation
- WCAG 2.1 Level AA compliance

**How to Use**:
```dart
import 'package:nonna_app/core/examples/accessibility_example.dart';

// Navigate to the example screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AccessibilityExample(),
  ),
);
```

**Testing**:
1. **iOS**: Settings → Accessibility → Display & Text Size → Larger Text
2. **Android**: Settings → Accessibility → Font Size
3. Change app locale to Arabic or Hebrew for RTL testing

## Adding New Examples

When creating new examples:
1. Create a new file in this directory
2. Follow the naming convention: `feature_example.dart`
3. Include comprehensive dartdoc comments
4. Provide usage instructions
5. Update this README

## Best Practices

Examples should:
- Be self-contained and runnable
- Demonstrate real-world usage patterns
- Include comments explaining key concepts
- Follow Flutter and Dart style guidelines
- Be accessible and internationalized
