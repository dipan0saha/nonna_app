# Utils & Helpers Cross-Component Utilization Guide

**Document Version**: 1.0  
**Created**: February 2, 2026  
**Status**: Active  
**Purpose**: Document how utility components should interact and leverage each other for maximum code reuse

---

## Overview

This guide documents the recommended patterns for cross-component utilization in the Nonna App's utility layer. Following these patterns ensures code reuse, consistency, and maintainability.

---

## 1. Validators Using Sanitizers

**Pattern**: Always sanitize input before validation to ensure clean data.

```dart
import 'package:nonna_app/core/utils/validators.dart';
import 'package:nonna_app/core/utils/sanitizers.dart';

// ❌ Don't validate raw input
String? result = Validators.email(userInput);

// ✅ Do sanitize before validating
String? cleanInput = Sanitizers.sanitizeEmail(userInput);
String? result = Validators.email(cleanInput);
```

**Why**: Sanitization removes malicious code and normalizes input, making validation more effective.

**Recommended Combinations**:
- `Sanitizers.sanitizeEmail()` → `Validators.email()`
- `Sanitizers.sanitizeHtml()` → `Validators.required()`
- `Sanitizers.sanitizeUrl()` → `Validators.url()`
- `Sanitizers.trimWhitespace()` → Any validator

---

## 2. Formatters Using Date Extensions

**Pattern**: Leverage DateTime extensions for cleaner date formatting code.

```dart
import 'package:nonna_app/core/utils/date_helpers.dart';
import 'package:nonna_app/core/extensions/date_extensions.dart';

// ❌ Don't use DateHelpers for simple operations
if (DateTime.now().difference(date).inDays == 0) {
  return DateHelpers.formatShort(date);
}

// ✅ Do use extensions for cleaner code
if (date.isToday) {
  return date.formatShort();
}
```

**Why**: Extensions provide more natural, fluent APIs and reduce boilerplate.

**Recommended Patterns**:
- Use `date.isToday`, `date.isFuture`, etc. for comparisons
- Use `date.formatShort()` for quick formatting
- Use `DateHelpers` for complex operations (age calculations, timezone handling)

---

## 3. Extensions Using Context Extensions

**Pattern**: Use ContextExtensions for accessing theme and MediaQuery data in widgets.

```dart
import 'package:flutter/material.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';

// ❌ Don't repeat Theme.of(context) and MediaQuery
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final width = MediaQuery.of(context).size.width;
  final color = theme.colorScheme.primary;
  
  return Container(
    width: width,
    color: color,
  );
}

// ✅ Do use context extensions
Widget build(BuildContext context) {
  return Container(
    width: context.screenWidth,
    color: context.primaryColor,
  );
}
```

**Why**: Reduces verbosity, improves readability, and eliminates repetitive code.

**Available Extensions**:
- Theme: `context.theme`, `context.textTheme`, `context.colorScheme`
- Colors: `context.primaryColor`, `context.secondaryColor`, `context.backgroundColor`
- MediaQuery: `context.screenWidth`, `context.screenHeight`, `context.isPortrait`
- Navigation: `context.push()`, `context.pop()`, `context.showSnackBar()`

---

## 4. Widgets Using Mixins

**Pattern**: Apply mixins to StatefulWidget states for shared behavior.

```dart
import 'package:flutter/material.dart';
import 'package:nonna_app/core/mixins/loading_mixin.dart';
import 'package:nonna_app/core/mixins/role_aware_mixin.dart';

// ❌ Don't duplicate loading state logic
class MyWidgetState extends State<MyWidget> {
  bool _isLoading = false;
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load data
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

// ✅ Do use mixins for shared behavior
class MyWidgetState extends State<MyWidget> 
    with LoadingMixin, RoleAwareMixin {
  
  @override
  UserRole get currentRole => widget.userRole;
  
  Future<void> _loadData() async {
    await executeAsync(() async {
      // Load data - loading state handled automatically
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ownerOnly(
      buildWithLoading(
        context: context,
        child: MyContent(),
      ),
    );
  }
}
```

**Why**: Eliminates code duplication and provides consistent patterns across widgets.

**Available Mixins**:
- **LoadingMixin**: Loading state management, async helpers, loading indicators
- **RoleAwareMixin**: Role checks, permissions, conditional rendering
- **ValidationMixin**: Form validation, error handling

---

## 5. Services Using Constants

**Pattern**: Reference constants instead of hardcoding values.

```dart
import 'package:nonna_app/core/constants/performance_limits.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/services/cache_service.dart';

// ❌ Don't hardcode limits and table names
await cache.set('user_profile', data, duration: Duration(minutes: 15));
final users = await supabase.from('profiles').select();

// ✅ Do use constants
await cache.set(
  'user_profile',
  data,
  duration: PerformanceLimits.userProfileCacheDuration,
);
final users = await supabase.from(SupabaseTables.profiles).select();
```

**Why**: Single source of truth, easy to update, prevents typos.

**Available Constants**:
- **PerformanceLimits**: Cache TTLs, query limits, pagination sizes, timeouts
- **SupabaseTables**: Table names, column names
- **AppStrings**: Error messages, validation messages, UI labels
- **AppSpacing**: Spacing values, EdgeInsets, SizedBox presets

---

## 6. Widgets Using AppSpacing

**Pattern**: Use AppSpacing for consistent spacing instead of hardcoded values.

```dart
import 'package:flutter/material.dart';
import 'package:nonna_app/core/constants/spacing.dart';

// ❌ Don't hardcode spacing values
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      children: [
        Text('Title'),
        SizedBox(height: 8.0),
        Text('Content'),
      ],
    ),
  );
}

// ✅ Do use AppSpacing
Widget build(BuildContext context) {
  return Padding(
    padding: AppSpacing.paddingMedium,
    child: Column(
      children: [
        Text('Title'),
        AppSpacing.verticalGapSmall,
        Text('Content'),
      ],
    ),
  );
}
```

**Why**: Consistent spacing across the app, easy to adjust globally, follows design system.

**Available Spacing**:
- Values: `xs`, `s`, `m`, `l`, `xl`, `xxl` (8px scale)
- EdgeInsets: `paddingSmall`, `paddingMedium`, `screenPadding`, `cardPadding`
- SizedBox: `verticalGapS`, `horizontalGapM`, etc.

---

## 7. Role Helpers and RoleAware Mixin

**Pattern**: Use RoleHelpers for static role checks, RoleAwareMixin for widget-based logic.

```dart
import 'package:nonna_app/core/utils/role_helpers.dart';
import 'package:nonna_app/core/mixins/role_aware_mixin.dart';
import 'package:nonna_app/core/enums/user_role.dart';

// For standalone logic (services, models)
class EventService {
  bool canCreateEvent(UserRole role, String userId, String ownerId) {
    return RoleHelpers.canCreate(role, userId, ownerId);
  }
}

// For widget logic
class EventFormState extends State<EventForm> with RoleAwareMixin {
  @override
  UserRole get currentRole => widget.userRole;
  
  @override
  Widget build(BuildContext context) {
    return ownerOnly(
      ElevatedButton(
        onPressed: canCreate ? _createEvent : null,
        child: Text('Create Event'),
      ),
    );
  }
}
```

**Why**: RoleHelpers for utility functions, RoleAwareMixin for widget integration.

---

## 8. String Extensions for Text Manipulation

**Pattern**: Use string extensions for common text operations.

```dart
import 'package:nonna_app/core/extensions/string_extensions.dart';

// ❌ Don't manually manipulate strings
String capitalized = text.isNotEmpty 
    ? '${text[0].toUpperCase()}${text.substring(1)}'
    : text;
bool isValid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    .hasMatch(email);

// ✅ Do use string extensions
String capitalized = text.capitalize();
bool isValid = email.isValidEmail;
```

**Why**: Cleaner code, consistent behavior, less error-prone.

**Available Extensions**:
- `capitalize()`, `capitalizeFirst()`, `capitalizeEachWord()`
- `truncate(length)`, `truncateWithEllipsis(length)`
- `isValidEmail`, `isValidUrl`, `isNumeric`
- `removeWhitespace()`, `toTitleCase()`

---

## 9. List Extensions for Safe Operations

**Pattern**: Use list extensions for null-safe list operations.

```dart
import 'package:nonna_app/core/extensions/list_extensions.dart';

// ❌ Don't manually check list bounds
final firstItem = list.isNotEmpty ? list.first : null;
final itemAt5 = list.length > 5 ? list[5] : null;

// ✅ Do use list extensions
final firstItem = list.firstOrNull;
final itemAt5 = list.getOrNull(5);
```

**Why**: Prevents IndexOutOfBoundsException, cleaner code, null-safe.

**Available Extensions**:
- `firstOrNull`, `lastOrNull`, `getOrNull(index)`
- `groupBy()`, `partition()`, `chunk(size)`
- `unique()`, `distinctBy()`
- `sortedBy()`, `sortedByDescending()`

---

## 10. Environment Configuration

**Pattern**: Use AppConfig for environment-specific settings.

```dart
import 'package:nonna_app/core/config/app_config.dart';
import 'package:nonna_app/core/utils/share_helpers.dart';

// ❌ Don't hardcode URLs
const String baseUrl = 'https://nonna.app';
final link = '$baseUrl/profile/$profileId';

// ✅ Do use AppConfig
final link = ShareHelpers.generateProfileLink(profileId);
// Or directly:
final link = AppConfig.getFullUrl('/profile/$profileId');
```

**Why**: Environment-specific URLs (dev/staging/prod), feature flags, centralized configuration.

**Available Config**:
- URLs: `baseUrl`, `apiBaseUrl`, `webAppUrl`
- Flags: `debugLogging`, `analyticsEnabled`, `betaFeaturesEnabled`
- Environment: `isDevelopment`, `isStaging`, `isProduction`

---

## 11. Validation Mixin in Forms

**Pattern**: Use ValidationMixin in form widgets for consistent validation.

```dart
import 'package:flutter/material.dart';
import 'package:nonna_app/core/mixins/validation_mixin.dart';

class SignupFormState extends State<SignupForm> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Email'),
            validator: emailValidator,  // From ValidationMixin
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Password'),
            validator: strongPasswordValidator,  // From ValidationMixin
            obscureText: true,
          ),
        ],
      ),
    );
  }
}
```

**Why**: Consistent validation across forms, pre-built validators, error handling.

**Available Validators from ValidationMixin**:
- `requiredValidator`, `emailValidator`, `strongPasswordValidator`
- `minLengthValidator`, `maxLengthValidator`, `urlValidator`
- `phoneValidator`, `dateValidator`, `numericValidator`

---

## 12. Image Helpers for Photo Processing

**Pattern**: Use ImageHelpers for all image operations.

```dart
import 'package:nonna_app/core/utils/image_helpers.dart';
import 'dart:io';

// Process uploaded photo
Future<void> uploadPhoto(File imageFile) async {
  // Validate size
  final isValidSize = await ImageHelpers.isValidFileSize(
    imageFile,
    maxSizeMB: 10,
  );
  
  if (!isValidSize) {
    throw Exception('File too large');
  }
  
  // Compress image
  final compressed = await ImageHelpers.compressImage(
    imageFile,
    quality: 85,
  );
  
  // Generate thumbnail
  final thumbnail = await ImageHelpers.generateThumbnail(
    compressed,
    width: 200,
    height: 200,
  );
  
  // Upload both
  await uploadToStorage(compressed, thumbnail);
}
```

**Why**: Consistent image processing, memory-efficient, handles edge cases.

---

## Summary Table

| Use Case | Primary Component | Supporting Components |
|----------|-------------------|----------------------|
| **Form Validation** | ValidationMixin | Validators, Sanitizers |
| **Date Display** | DateExtensions | DateHelpers |
| **Theme Access** | ContextExtensions | AppTheme, AppColors |
| **Loading States** | LoadingMixin | ContextExtensions |
| **Role-Based UI** | RoleAwareMixin | RoleHelpers, UserRole enum |
| **Spacing** | AppSpacing | (none) |
| **Constants** | AppStrings, PerformanceLimits | (none) |
| **String Operations** | StringExtensions | Formatters |
| **List Operations** | ListExtensions | (none) |
| **Configuration** | AppConfig | ShareHelpers |
| **Image Processing** | ImageHelpers | (none) |
| **Database Queries** | SupabaseTables | (none) |

---

## Best Practices

1. **Import Only What You Need**: Don't import entire utility files if you only need one method
2. **Prefer Extensions**: Use extensions for natural, fluent APIs
3. **Use Mixins for Widgets**: Apply mixins to StatefulWidget states for shared behavior
4. **Reference Constants**: Never hardcode values that are defined in constants
5. **Sanitize Before Validating**: Always clean input before validation
6. **Use AppConfig for URLs**: Never hardcode environment-specific URLs
7. **Leverage Context Extensions**: Reduce verbosity in widget build methods
8. **Apply AppSpacing**: Consistent spacing across all widgets
9. **Check Edge Cases**: Extensions handle null-safety, use them
10. **Document Usage**: Add examples to custom components showing cross-component usage

---

## Anti-Patterns to Avoid

❌ **Don't duplicate logic**
```dart
// Bad: Duplicating loading state in every widget
class MyWidget extends State {
  bool _isLoading = false;
  // ...
}
```

❌ **Don't hardcode values**
```dart
// Bad: Hardcoded spacing
Padding(padding: EdgeInsets.all(16.0))
```

❌ **Don't bypass sanitization**
```dart
// Bad: Validating unsanitized input
Validators.email(rawUserInput)
```

❌ **Don't repeat Theme.of(context)**
```dart
// Bad: Verbose theme access
final color = Theme.of(context).colorScheme.primary;
```

❌ **Don't hardcode URLs**
```dart
// Bad: Environment-specific URL
const baseUrl = 'https://nonna.app';
```

---

## Conclusion

Following these cross-component utilization patterns ensures:
- **Code Reuse**: Eliminate duplication
- **Consistency**: Same patterns across the app
- **Maintainability**: Changes in one place affect all usages
- **Readability**: Cleaner, more fluent code
- **Safety**: Proper null-handling and validation

**Next Steps**: 
- Review existing code for opportunities to apply these patterns
- Update widgets to use mixins where appropriate
- Replace hardcoded values with constants
- Add examples to component documentation

