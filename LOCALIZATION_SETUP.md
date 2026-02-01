# Phase 2: Localization (i18n) - Setup Guide

## Overview

This document describes the implementation of Phase 2: Localization (i18n) for the Nonna app. The localization system supports English and Spanish with full internationalization capabilities.

## ✅ Completed Components

### 1. English Localization (`lib/l10n/app_en.arb`)
- ✅ Complete English translations in ARB format
- ✅ ICU message formatting with placeholders
- ✅ Pluralization rules for counts
- ✅ Comprehensive coverage of all app sections:
  - Common UI elements (buttons, actions)
  - Error messages and validation
  - Empty states and placeholders
  - Navigation labels
  - Authentication flows
  - Recipe-specific strings
  - Settings and preferences
  - Success/confirmation messages

### 2. Spanish Localization (`lib/l10n/app_es.arb`)
- ✅ Complete Spanish translations matching English keys
- ✅ Culturally appropriate translations
- ✅ Proper pluralization rules for Spanish
- ✅ Matching structure with English file

### 3. Localization Configuration (`lib/l10n/l10n.dart`)
- ✅ Supported locales (en, es)
- ✅ Fallback locale (en)
- ✅ Locale resolution logic
- ✅ Helper methods for locale management
- ✅ L10n delegate setup

### 4. Configuration Files
- ✅ `l10n.yaml` - Configuration for Flutter's localization code generation
- ✅ `pubspec.yaml` - Updated with `generate: true` flag
- ✅ CI/CD workflows - Updated to include `flutter gen-l10n` step

### 5. Documentation
- ✅ `lib/l10n/README.md` - Comprehensive usage guide
- ✅ Example implementation (`lib/l10n/localization_example.dart`)
- ✅ Setup script (`scripts/setup_l10n.sh`)

### 6. Tests
- ✅ `test/l10n/localization_test.dart` - Comprehensive test suite covering:
  - L10n configuration tests
  - Locale support verification
  - English and Spanish translations
  - Parametrized messages
  - Plural forms
  - Dynamic locale switching
  - Coverage of all string categories

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Dart SDK (included with Flutter)

### Step 1: Generate Localization Files

Run the setup script:
```bash
./scripts/setup_l10n.sh
```

Or manually:
```bash
flutter pub get
flutter gen-l10n
```

This will generate the `AppLocalizations` class in `.dart_tool/flutter_gen/gen_l10n/`.

### Step 2: Verify Integration

The `lib/main.dart` file has been updated to include:
- Import statements for localization
- Localization delegates configuration
- Supported locales list
- Locale resolution callback

### Step 3: Run Tests

```bash
flutter test test/l10n/localization_test.dart
```

## 📝 Usage Examples

### Basic Usage
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Text(l10n.welcome);
  }
}
```

### With Parameters
```dart
Text(l10n.helloUser('Maria')); // "Hello, Maria!"
```

### Plural Forms
```dart
Text(l10n.plurals_recipes(5)); // "5 recipes"
```

### With Phase 1 Widgets
```dart
CustomButton(
  onPressed: () {},
  label: l10n.common_save,
)

EmptyState(
  title: l10n.empty_state_recipes_title,
  message: l10n.empty_state_recipes_message,
  actionLabel: l10n.empty_state_recipes_action,
  onAction: () {},
)

ErrorView(
  title: l10n.error_title,
  message: l10n.error_network,
  onRetry: () {},
)
```

## 📊 String Categories

The localization system includes **60+ translation keys** organized into categories:

1. **Common UI** (20 keys): Buttons, actions, navigation
2. **Errors** (10 keys): Error messages and validation
3. **Empty States** (6 keys): Empty state messages
4. **Navigation** (5 keys): Screen titles and navigation
5. **Authentication** (11 keys): Login, signup, password flows
6. **Recipes** (9 keys): Recipe-specific labels
7. **Settings** (8 keys): Settings and preferences
8. **Plurals** (4 keys): Plural forms for counts
9. **Dates** (3 keys): Date-related labels
10. **Success/Confirm** (6 keys): Success messages and confirmations

## 🧪 Test Coverage

The test suite includes:
- ✅ L10n configuration validation
- ✅ Locale support verification (en, es)
- ✅ Locale resolution callback testing
- ✅ English translations loading
- ✅ Spanish translations loading
- ✅ Parametrized message handling
- ✅ Plural form handling (both languages)
- ✅ Dynamic locale switching
- ✅ Coverage of all string categories
- ✅ Integration with Flutter localization delegates

**Total Tests**: 20+ test cases

## 🔄 CI/CD Integration

The GitHub Actions workflows have been updated:

### Analysis Job
```yaml
- name: Install dependencies
  run: flutter pub get

- name: Generate localizations
  run: flutter gen-l10n

- name: Format code
  run: dart format .
```

### Test Job
```yaml
- name: Install dependencies
  run: flutter pub get

- name: Generate localizations
  run: flutter gen-l10n

- name: Run tests with coverage
  run: flutter test --coverage
```

## 📁 File Structure

```
nonna_app/
├── l10n.yaml                          # Localization configuration
├── lib/
│   ├── l10n/
│   │   ├── app_en.arb                 # English translations (60+ keys)
│   │   ├── app_es.arb                 # Spanish translations (60+ keys)
│   │   ├── l10n.dart                  # L10n configuration class
│   │   ├── README.md                  # Comprehensive usage guide
│   │   └── localization_example.dart  # Example implementation
│   └── main.dart                      # Updated with localization
├── test/
│   └── l10n/
│       └── localization_test.dart     # Comprehensive test suite
├── scripts/
│   └── setup_l10n.sh                  # Setup script
└── .github/
    └── workflows/
        └── ci.yml                      # Updated with gen-l10n step
```

## 🎯 Next Steps

After generating the localization files:

1. **Review the generated code**: Check `.dart_tool/flutter_gen/gen_l10n/`
2. **Run the app**: Verify localization works in both English and Spanish
3. **Run tests**: `flutter test test/l10n/localization_test.dart`
4. **Add more strings**: Follow the guide in `lib/l10n/README.md`
5. **Add more languages**: Create new ARB files (e.g., `app_fr.arb` for French)

## 🐛 Troubleshooting

### Issue: `AppLocalizations` class not found
**Solution**: Run `flutter gen-l10n` to generate the class.

### Issue: Import error for `flutter_gen/gen_l10n/app_localizations.dart`
**Solution**: 
1. Ensure `generate: true` is in `pubspec.yaml` under `flutter:`
2. Run `flutter pub get`
3. Run `flutter gen-l10n`

### Issue: Tests fail with "No Localizations found"
**Solution**: Ensure localization delegates are properly configured in test widgets.

### Issue: New strings not appearing
**Solution**: 
1. Add the key to both `app_en.arb` and `app_es.arb`
2. Run `flutter gen-l10n`
3. Restart your IDE/development server

## 📚 Resources

- [Flutter Internationalization Guide](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB Format Specification](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [ICU Message Format](https://unicode-org.github.io/icu/userguide/format_parse/messages/)
- [lib/l10n/README.md](lib/l10n/README.md) - Detailed usage guide

## ✨ Features

- ✅ Support for English and Spanish
- ✅ 60+ comprehensive translation keys
- ✅ ICU message formatting with placeholders
- ✅ Proper pluralization rules
- ✅ Locale resolution logic with fallback
- ✅ Dynamic locale switching support
- ✅ CI/CD integration
- ✅ Comprehensive test coverage
- ✅ Example implementation
- ✅ Detailed documentation
- ✅ Integration with Phase 1 widgets

## 🎉 Success Criteria

All requirements from the specification have been met:

✅ English localization with ARB format  
✅ Spanish localization with matching keys  
✅ ICU message formatting  
✅ Pluralization rules  
✅ Comprehensive coverage for all app screens  
✅ Localization configuration with supported locales  
✅ Fallback locale configuration  
✅ Locale resolution logic  
✅ L10n delegate setup  
✅ Comprehensive tests  
✅ Documentation and examples  
✅ CI/CD integration  

## 📝 Notes

- The generated `AppLocalizations` class is created in `.dart_tool/flutter_gen/gen_l10n/` and should not be committed to version control
- Always run `flutter gen-l10n` after modifying ARB files
- The import path `package:flutter_gen/gen_l10n/app_localizations.dart` is automatically resolved by Flutter
- All Phase 1 widgets can now easily be localized using the provided strings
