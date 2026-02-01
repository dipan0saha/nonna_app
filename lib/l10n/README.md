# Localization (i18n) Implementation

This directory contains the localization (internationalization) implementation for the Nonna app.

## Overview

The app supports multiple languages with full localization support:
- **English (en)** - Default language
- **Spanish (es)** - Spanish translations

## Files Structure

```
lib/l10n/
├── app_en.arb          # English translations (template)
├── app_es.arb          # Spanish translations
└── l10n.dart           # Localization configuration

test/l10n/
└── localization_test.dart  # Comprehensive localization tests
```

## Setup

### 1. Configuration File

The `l10n.yaml` file in the project root configures the localization generation:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
nullable-getter: false
```

### 2. Generate Localization Files

Run the following command to generate the localization files:

```bash
flutter gen-l10n
```

This will generate the `AppLocalizations` class and language-specific files in `.dart_tool/flutter_gen/gen_l10n/`.

### 3. Import in Your App

Update your `main.dart` to include localization support:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/l10n.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Localization delegates
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Supported locales
      supportedLocales: L10n.all,
      
      // Locale resolution callback
      localeResolutionCallback: L10n.localeResolutionCallback,
      
      // Rest of your app configuration
      home: MyHomePage(),
    );
  }
}
```

## Usage

### Basic Usage

Access localized strings in your widgets:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      children: [
        Text(l10n.welcome),
        Text(l10n.appTitle),
        ElevatedButton(
          onPressed: () {},
          child: Text(l10n.common_save),
        ),
      ],
    );
  }
}
```

### Parametrized Messages

For messages with parameters:

```dart
final l10n = AppLocalizations.of(context);
Text(l10n.helloUser('Maria')); // Output: "Hello, Maria!"
```

### Plural Forms

For plural messages:

```dart
final l10n = AppLocalizations.of(context);
Text(l10n.plurals_recipes(0));  // "No recipes"
Text(l10n.plurals_recipes(1));  // "1 recipe"
Text(l10n.plurals_recipes(5));  // "5 recipes"
```

### Switching Locales

To switch locales dynamically:

```dart
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  
  void setLocale(Locale locale) {
    if (L10n.isSupported(locale)) {
      _locale = locale;
      notifyListeners();
    }
  }
}

// In your widget:
ElevatedButton(
  onPressed: () {
    localeProvider.setLocale(const Locale('es'));
  },
  child: Text('Switch to Spanish'),
)
```

## Available String Categories

### Common UI Elements
- `common_ok`, `common_cancel`, `common_save`, `common_delete`
- `common_edit`, `common_add`, `common_remove`, `common_close`
- `common_done`, `common_continue`, `common_back`, `common_next`
- `common_yes`, `common_no`, `common_confirm`, `common_retry`
- `common_loading`, `common_search`, `common_filter`, `common_sort`

### Error Messages
- `error_title`, `error_generic`, `error_network`, `error_timeout`
- `error_server`, `error_unauthorized`, `error_notFound`
- `error_validation`, `error_required_field`
- `error_invalid_email`, `error_invalid_password`

### Empty States
- `empty_state_no_data`, `empty_state_no_results`, `empty_state_no_items`
- `empty_state_recipes_title`, `empty_state_recipes_message`
- `empty_state_favorites_title`, `empty_state_favorites_message`

### Navigation
- `nav_home`, `nav_recipes`, `nav_favorites`, `nav_profile`, `nav_settings`

### Authentication
- `auth_login`, `auth_logout`, `auth_signup`
- `auth_email`, `auth_password`, `auth_confirm_password`
- `auth_forgot_password`, `auth_reset_password`, `auth_create_account`

### Recipe-Related
- `recipe_title`, `recipe_ingredients`, `recipe_instructions`
- `recipe_prep_time`, `recipe_cook_time`, `recipe_servings`
- `recipe_difficulty`, `recipe_difficulty_easy`, `recipe_difficulty_medium`, `recipe_difficulty_hard`
- `recipe_add_to_favorites`, `recipe_remove_from_favorites`

### Settings
- `settings_language`, `settings_theme`, `settings_notifications`
- `settings_privacy`, `settings_about`, `settings_help`

### Success Messages
- `success_saved`, `success_deleted`, `success_updated`, `success_added`

### Confirmation Dialogs
- `confirm_delete_title`, `confirm_delete_message`
- `confirm_logout_title`, `confirm_logout_message`

## Adding New Translations

### 1. Add to English ARB file (app_en.arb)

```json
{
  "my_new_string": "My New String",
  "@my_new_string": {
    "description": "Description of what this string is used for"
  }
}
```

### 2. Add to Spanish ARB file (app_es.arb)

```json
{
  "my_new_string": "Mi Nueva Cadena",
  "@my_new_string": {
    "description": "Descripción de para qué se usa esta cadena"
  }
}
```

### 3. Regenerate Localization Files

```bash
flutter gen-l10n
```

### 4. Use in Your Code

```dart
final l10n = AppLocalizations.of(context);
Text(l10n.my_new_string);
```

## ARB Format Reference

### Simple String
```json
{
  "key": "Value",
  "@key": {
    "description": "Description"
  }
}
```

### String with Placeholder
```json
{
  "greeting": "Hello, {name}!",
  "@greeting": {
    "description": "Greeting with name",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "John"
      }
    }
  }
}
```

### Plural Form
```json
{
  "items": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@items": {
    "description": "Item count",
    "placeholders": {
      "count": {
        "type": "int",
        "example": "5"
      }
    }
  }
}
```

## Testing

Run the localization tests:

```bash
flutter test test/l10n/localization_test.dart
```

The test suite covers:
- Locale support and configuration
- English and Spanish translations
- Parametrized messages
- Plural forms
- Dynamic locale switching
- Coverage of all string categories

## Best Practices

1. **Always use localized strings** - Never hardcode user-facing text
2. **Provide context in descriptions** - Help translators understand usage
3. **Use meaningful keys** - Group related strings with prefixes (e.g., `auth_`, `error_`)
4. **Test all locales** - Ensure translations work correctly in all languages
5. **Keep translations in sync** - When adding new English strings, add Spanish translations
6. **Use plural forms correctly** - Respect language-specific plural rules
7. **Consider text length** - Some languages need more space than English

## Troubleshooting

### Generated files not found
Run `flutter gen-l10n` to generate the localization files.

### Locale not switching
Ensure you're using the locale resolution callback and rebuilding the MaterialApp when locale changes.

### Missing translation
Check that the key exists in both `app_en.arb` and `app_es.arb` with matching keys.

### Build errors after adding new strings
Regenerate localization files with `flutter gen-l10n` and restart the app.

## Future Enhancements

- Add more languages (e.g., Italian, French)
- Implement locale persistence (save user's language preference)
- Add RTL language support
- Create translation management workflow
- Add context screenshots for translators

## Resources

- [Flutter Internationalization Guide](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB Format Specification](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [ICU Message Format](https://unicode-org.github.io/icu/userguide/format_parse/messages/)
