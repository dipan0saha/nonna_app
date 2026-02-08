# Phase 3 Implementation Guide: Dynamic Type & RTL Support

**Version**: 1.0
**Date**: February 1, 2026
**Status**: Complete and Production Ready

---

## Overview

This guide provides practical integration instructions for the Dynamic Type Handler and RTL Support Handler utilities implemented in Phase 3 of the nonna_app development.

## Quick Start

### Import the Utilities

```dart
import 'package:nonna_app/core/utils/dynamic_type_handler.dart';
import 'package:nonna_app/core/utils/rtl_support_handler.dart';
```

### Basic Usage

#### Dynamic Type - Scale Text

```dart
// In your widget's build method
@override
Widget build(BuildContext context) {
  return Text(
    'Hello World',
    style: DynamicTypeHandler.scaledTextStyle(
      context,
      baseStyle: TextStyle(fontSize: 16.0),
    ),
  );
}
```

#### RTL Support - Mirror Icons

```dart
@override
Widget build(BuildContext context) {
  return IconButton(
    icon: RTLSupportHandler.mirrorInRTL(
      context: context,
      child: Icon(Icons.arrow_forward),
    ),
    onPressed: () {},
  );
}
```

---

## Integration Patterns

### Pattern 1: Accessible Custom Button

Create buttons that scale with text and work in RTL:

```dart
class AccessibleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const AccessibleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Get scaled font size
    final fontSize = DynamicTypeHandler.scale(
      context,
      baseFontSize: 16.0,
    );

    // Get WCAG-compliant touch target
    final minHeight = DynamicTypeHandler.getMinimumTouchTarget(context);

    // Get scaled padding
    final padding = DynamicTypeHandler.getScaledPadding(
      context,
      basePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );

    // Get text direction for RTL
    final textDirection = RTLSupportHandler.getTextDirection(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(0, minHeight),
        padding: padding,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: textDirection,
        children: [
          if (icon != null) ...[
            RTLSupportHandler.mirrorInRTL(
              context: context,
              child: Icon(
                icon,
                size: DynamicTypeHandler.getScaledIconSize(context),
              ),
            ),
            SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}
```

### Pattern 2: Adaptive Layout

Switch layouts based on text scaling:

```dart
class AdaptiveProductCard extends StatelessWidget {
  final Product product;

  const AdaptiveProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Check if we should reflow to vertical layout
    if (DynamicTypeHandler.shouldReflowLayout(context)) {
      return _buildVerticalLayout(context);
    } else {
      return _buildHorizontalLayout(context);
    }
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Card(
      child: Row(
        textDirection: RTLSupportHandler.getTextDirection(context),
        children: [
          // Product image
          Container(
            width: 100,
            height: 100,
            child: Image.network(product.imageUrl),
          ),

          // Product details
          Expanded(
            child: Padding(
              padding: RTLSupportHandler.mirrorEdgeInsets(
                context,
                EdgeInsets.only(left: 16),
              ),
              child: _buildProductInfo(context),
            ),
          ),

          // Buy button
          _buildBuyButton(context),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(product.imageUrl, fit: BoxFit.cover),
          ),

          // Product details
          Padding(
            padding: EdgeInsets.all(16),
            child: _buildProductInfo(context),
          ),

          // Buy button (full width)
          Padding(
            padding: EdgeInsets.all(16),
            child: _buildBuyButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: RTLSupportHandler.getCrossAxisAlignment(
        context,
        logicalAlignment: CrossAxisAlignment.start,
      ),
      children: [
        Text(
          product.name,
          style: DynamicTypeHandler.scaledTextStyle(
            context,
            baseStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          product.price,
          style: DynamicTypeHandler.scaledTextStyle(
            context,
            baseStyle: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildBuyButton(BuildContext context) {
    return AccessibleButton(
      label: 'Buy Now',
      icon: Icons.shopping_cart,
      onPressed: () {},
    );
  }
}
```

### Pattern 3: RTL-Aware Forms

Create forms that work in both LTR and RTL:

```dart
class RegistrationForm extends StatelessWidget {
  const RegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    final textDirection = RTLSupportHandler.getTextDirection(context);
    final textAlign = RTLSupportHandler.getTextAlign(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name field (follows locale direction)
        TextField(
          textDirection: textDirection,
          textAlign: textAlign,
          style: DynamicTypeHandler.scaledTextStyle(
            context,
            baseStyle: TextStyle(fontSize: 16),
          ),
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person),
          ),
        ),

        SizedBox(height: 16),

        // Email field (always LTR content)
        TextField(
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          keyboardType: TextInputType.emailAddress,
          style: DynamicTypeHandler.scaledTextStyle(
            context,
            baseStyle: TextStyle(fontSize: 16),
          ),
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
        ),

        SizedBox(height: 24),

        // Submit button
        AccessibleButton(
          label: 'Register',
          icon: Icons.arrow_forward,
          onPressed: () {},
        ),
      ],
    );
  }
}
```

### Pattern 4: Bidirectional Chat Interface

Handle mixed-direction content:

```dart
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    // Detect message direction from content
    final messageDirection = RTLSupportHandler.getTextDirectionFromContent(
      message,
      defaultDirection: RTLSupportHandler.getTextDirection(context),
    );

    // Get alignment based on sender
    final alignment = isMe
        ? RTLSupportHandler.getEndAlignment(context)
        : RTLSupportHandler.getStartAlignment(context);

    // Mirror decoration for RTL
    final decoration = RTLSupportHandler.mirrorDecoration(
      context,
      BoxDecoration(
        color: isMe ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: isMe ? Radius.circular(16) : Radius.zero,
          bottomRight: isMe ? Radius.zero : Radius.circular(16),
        ),
      ),
    );

    return Align(
      alignment: alignment,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: DynamicTypeHandler.getScaledPadding(
          context,
          basePadding: EdgeInsets.all(12),
        ),
        decoration: decoration,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          message,
          textDirection: messageDirection,
          style: DynamicTypeHandler.scaledTextStyle(
            context,
            baseStyle: TextStyle(
              fontSize: 16,
              color: isMe ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Theme Integration

### Create an Adaptive Theme

```dart
class AppTheme {
  static ThemeData getTheme(BuildContext context) {
    // Get text direction for theme
    final textDirection = RTLSupportHandler.getTextDirection(context);

    return ThemeData(
      useMaterial3: true,
      textTheme: _getTextTheme(context),

      // Set app-wide text direction
      // Note: MaterialApp handles this automatically based on locale
      // This is for custom theme usage
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Icon theme with scaled sizes
      iconTheme: IconThemeData(
        size: DynamicTypeHandler.getScaledIconSize(context),
      ),
    );
  }

  static TextTheme _getTextTheme(BuildContext context) {
    return TextTheme(
      displayLarge: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 57),
      ),
      displayMedium: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 45),
      ),
      displaySmall: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 36),
      ),
      headlineLarge: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 32),
      ),
      headlineMedium: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 28),
      ),
      headlineSmall: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 24),
      ),
      titleLarge: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 22),
      ),
      titleMedium: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      titleSmall: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      bodyLarge: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 16),
      ),
      bodyMedium: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 14),
      ),
      bodySmall: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 12),
      ),
      labelLarge: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      labelMedium: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      labelSmall: DynamicTypeHandler.scaledTextStyle(
        context,
        baseStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
```

### Use in MaterialApp

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Localization setup (from Phase 2)
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.all,
      localeResolutionCallback: L10n.localeResolutionCallback,

      // Builder to access context with locale
      builder: (context, child) {
        return Theme(
          data: AppTheme.getTheme(context),
          child: child!,
        );
      },

      home: HomeScreen(),
    );
  }
}
```

---

## Best Practices

### 1. Text Scaling

✅ **DO**: Use `scaledTextStyle()` for all user-facing text
```dart
Text(
  'Welcome',
  style: DynamicTypeHandler.scaledTextStyle(
    context,
    baseStyle: TextStyle(fontSize: 20),
  ),
)
```

❌ **DON'T**: Use fixed font sizes
```dart
Text('Welcome', style: TextStyle(fontSize: 20)) // Fixed size
```

### 2. Layout Reflow

✅ **DO**: Check for reflow needs in complex layouts
```dart
if (DynamicTypeHandler.shouldReflowLayout(context)) {
  return Column(children: widgets); // Stack vertically
} else {
  return Row(children: widgets); // Arrange horizontally
}
```

❌ **DON'T**: Force horizontal layouts at large scales
```dart
Row(children: widgets) // May overflow with large text
```

### 3. RTL Alignment

✅ **DO**: Use logical alignments (start/end)
```dart
crossAxisAlignment: RTLSupportHandler.getCrossAxisAlignment(
  context,
  logicalAlignment: CrossAxisAlignment.start,
)
```

❌ **DON'T**: Use physical alignments (left/right)
```dart
crossAxisAlignment: CrossAxisAlignment.start // Won't flip for RTL
```

### 4. Padding and Margins

✅ **DO**: Use EdgeInsetsDirectional or mirror EdgeInsets
```dart
padding: EdgeInsetsDirectional.only(start: 16, end: 8)
// OR
padding: RTLSupportHandler.mirrorEdgeInsets(
  context,
  EdgeInsets.only(left: 16, right: 8),
)
```

❌ **DON'T**: Use physical edge insets in RTL layouts
```dart
padding: EdgeInsets.only(left: 16, right: 8) // Fixed direction
```

### 5. Icons

✅ **DO**: Mirror directional icons
```dart
RTLSupportHandler.mirrorInRTL(
  context: context,
  child: Icon(Icons.arrow_forward),
)
```

❌ **DON'T**: Leave directional icons static
```dart
Icon(Icons.arrow_forward) // Points wrong way in RTL
```

---

## Testing Your Implementation

### Test Checklist

- [ ] Test at 100% text scale (normal)
- [ ] Test at 150% text scale (large)
- [ ] Test at 200% text scale (maximum)
- [ ] Test with Arabic locale (RTL)
- [ ] Test with Hebrew locale (RTL)
- [ ] Test with English locale (LTR)
- [ ] Verify touch targets ≥ 44x44
- [ ] Check for text overflow
- [ ] Test layout reflow behavior
- [ ] Verify icon mirroring

### Manual Testing

#### iOS
1. Settings → Accessibility → Display & Text Size → Larger Text
2. Drag slider to maximum
3. Settings → General → Language & Region → iPhone Language → العربية

#### Android
1. Settings → Accessibility → Font Size → Largest
2. Settings → System → Languages & input → Languages → العربية

### Unit Testing Example

```dart
testWidgets('Button scales with text', (WidgetTester tester) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        textScaler: TextScaler.linear(1.5),
      ),
      child: MaterialApp(
        home: Scaffold(
          body: AccessibleButton(
            label: 'Test',
            onPressed: () {},
          ),
        ),
      ),
    ),
  );

  // Verify button size increased
  final button = tester.widget<ElevatedButton>(
    find.byType(ElevatedButton),
  );
  // Add assertions here
});
```

---

## Common Issues and Solutions

### Issue 1: Text Overflow

**Problem**: Text overflows at large scales

**Solution**: Use flexible widgets
```dart
Row(
  children: [
    Flexible(
      child: Text(
        longText,
        style: DynamicTypeHandler.scaledTextStyle(context, ...),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)
```

### Issue 2: Icons Not Mirroring

**Problem**: Icons don't flip in RTL

**Solution**: Wrap with mirrorInRTL
```dart
RTLSupportHandler.mirrorInRTL(
  context: context,
  child: Icon(Icons.arrow_forward),
  shouldMirror: RTLSupportHandler.shouldMirrorIcon(Icons.arrow_forward),
)
```

### Issue 3: Layout Breaks at Large Scale

**Problem**: Complex layout breaks at 200% scale

**Solution**: Implement layout reflow
```dart
if (DynamicTypeHandler.shouldReflowLayout(context, threshold: 1.5)) {
  return SimplifiedLayout();
}
return ComplexLayout();
```

### Issue 4: Third-Party Widgets

**Problem**: External widgets don't scale

**Solution**: Override text scaling
```dart
DynamicTypeHandler.withCustomTextScale(
  context: context,
  textScaleFactor: 1.0, // Force normal scale
  child: ThirdPartyWidget(),
)
```

---

## Performance Considerations

### Optimization Tips

1. **Avoid in Loops**: Don't call handlers in tight loops
```dart
// ❌ Bad
for (var item in items) {
  DynamicTypeHandler.scale(context, baseFontSize: 16); // Called N times
}

// ✅ Good
final scaledSize = DynamicTypeHandler.scale(context, baseFontSize: 16);
for (var item in items) {
  // Use scaledSize
}
```

2. **Cache Calculations**: Store scaled values if used multiple times
```dart
@override
Widget build(BuildContext context) {
  final fontSize = DynamicTypeHandler.scale(context, baseFontSize: 16);
  final padding = DynamicTypeHandler.getScaledPadding(context, ...);

  // Use fontSize and padding multiple times
}
```

3. **Rebuild Optimization**: Methods are rebuild-safe
```dart
// ✅ Safe to call in build()
@override
Widget build(BuildContext context) {
  return Text(
    'Hello',
    style: DynamicTypeHandler.scaledTextStyle(context, ...),
  );
}
```

---

## Migration Guide

### Migrating Existing Widgets

#### Before (Static Text)
```dart
Text(
  'Hello World',
  style: TextStyle(fontSize: 16),
)
```

#### After (Dynamic Text)
```dart
Text(
  'Hello World',
  style: DynamicTypeHandler.scaledTextStyle(
    context,
    baseStyle: TextStyle(fontSize: 16),
  ),
)
```

#### Before (Fixed Alignment)
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: widgets,
)
```

#### After (RTL-Aware Alignment)
```dart
Row(
  mainAxisAlignment: RTLSupportHandler.getMainAxisAlignment(
    context,
    logicalAlignment: MainAxisAlignment.start,
  ),
  textDirection: RTLSupportHandler.getTextDirection(context),
  children: widgets,
)
```

---

## Summary

Phase 3 utilities provide production-ready support for:
- ✅ Dynamic text scaling (80%-200%)
- ✅ WCAG 2.1 Level AA compliance
- ✅ RTL layout support (9 languages)
- ✅ Bidirectional text handling
- ✅ Zero dependencies
- ✅ Comprehensive testing

Follow the patterns and best practices in this guide to create accessible, internationalized Flutter applications.

---

**Need Help?**
- Review test files for more examples
- Check documentation reports for detailed specifications
- Test with real devices using accessibility settings

**Document Version**: 1.0
**Last Updated**: February 1, 2026
