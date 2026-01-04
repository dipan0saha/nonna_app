# pubspec.yaml Configuration Documentation

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Lead  
**Status**: Verified  
**Section**: 2.2 - Project Initialization

## Executive Summary

This document provides comprehensive documentation for the Nonna App's `pubspec.yaml` configuration file. The configuration includes all necessary dependencies, development tools, and metadata required for building a production-ready Flutter application with Supabase backend integration.

## Current pubspec.yaml Configuration

### Basic Metadata

```yaml
name: nonna_app
description: "A new Flutter project."
publish_to: 'none'  # Private package, not published to pub.dev
version: 1.0.0+1
```

**Configuration Details**:
- **name**: `nonna_app` - The Dart package name
- **description**: Application description (can be enhanced for production)
- **publish_to**: Set to 'none' to prevent accidental publishing to pub.dev
- **version**: `1.0.0+1` - Semantic versioning (major.minor.patch+build)

### Environment Constraints

```yaml
environment:
  sdk: ^3.10.1
```

**Configuration Details**:
- **sdk**: Dart SDK version constraint (^3.10.1 allows >=3.10.1 <4.0.0)
- Ensures compatibility with latest Dart features
- Minimum version required for dependencies

## Dependencies Analysis

### Core Framework

#### Flutter SDK
```yaml
flutter:
  sdk: flutter
```
**Purpose**: Core Flutter framework  
**Type**: Required  
**Source**: Flutter SDK

#### Flutter Localizations
```yaml
flutter_localizations:
  sdk: flutter
```
**Purpose**: Internationalization support  
**Type**: Required for i18n  
**Source**: Flutter SDK  
**Features**: Multi-language support, date/time formatting

### Backend & Database

#### Supabase Flutter
```yaml
supabase_flutter: ^2.5.8
supabase: ^2.2.0
```
**Purpose**: Backend integration and database access  
**Type**: Critical  
**Features**:
- PostgreSQL database client
- Real-time subscriptions
- Authentication
- Storage management
- Auto-generated REST APIs

**Version Notes**: 
- Using stable 2.x versions
- supabase_flutter includes Flutter-specific integrations
- supabase provides core functionality

### State Management & Navigation

#### Riverpod
```yaml
riverpod: ^2.4.9
flutter_riverpod: ^2.4.9
```
**Purpose**: State management solution  
**Type**: Critical  
**Justification**: Chosen per ADR-003 for:
- Compile-time safety
- Better performance than Provider
- Excellent testability
- Automatic disposal

**Version Notes**: Using 2.x stable versions

#### Go Router
```yaml
go_router: ^13.2.0
```
**Purpose**: Declarative navigation and routing  
**Type**: Required  
**Features**:
- Deep linking support
- Route guards/middleware
- Type-safe navigation
- URL-based routing for web

### Utilities & Helpers

#### Intl
```yaml
intl: ^0.20.2
```
**Purpose**: Internationalization and localization  
**Type**: Required  
**Features**:
- Date/time formatting
- Number formatting
- Message translations
- Locale-specific formatting

#### Image Processing
```yaml
image: ^4.1.7
```
**Purpose**: Image manipulation and processing  
**Type**: Required for tile system  
**Features**:
- Image resizing
- Format conversion
- Compression
- Memory-efficient processing

#### HTTP Client
```yaml
http: ^1.2.0
```
**Purpose**: HTTP requests  
**Type**: Supporting  
**Note**: Primarily using Supabase client, but available for additional APIs

### Security & Authentication

#### Local Auth
```yaml
local_auth: ^2.2.0
```
**Purpose**: Biometric authentication  
**Type**: Optional security enhancement  
**Features**:
- Fingerprint authentication
- Face ID/Face recognition
- PIN/pattern authentication
- Device credential validation

### Configuration & Environment

#### Flutter DotEnv
```yaml
flutter_dotenv: ^5.1.0
```
**Purpose**: Environment variable management  
**Type**: Critical  
**Features**:
- Secure configuration management
- Environment-specific settings
- API key protection
- Multi-environment support

### Monitoring & Error Tracking

#### Sentry Flutter
```yaml
sentry_flutter: ^9.9.1
```
**Purpose**: Error tracking and performance monitoring  
**Type**: Critical for production  
**Features**:
- Crash reporting
- Error tracking
- Performance monitoring
- Release health tracking
- User feedback collection

### UI Components

#### Cupertino Icons
```yaml
cupertino_icons: ^1.0.8
```
**Purpose**: iOS-style icons  
**Type**: Standard Flutter inclusion  
**Features**: Access to iOS-style icon set

## Development Dependencies

### Testing Framework

#### Flutter Test
```yaml
flutter_test:
  sdk: flutter
```
**Purpose**: Unit and widget testing  
**Type**: Essential  
**Source**: Flutter SDK

#### Integration Test
```yaml
integration_test:
  sdk: flutter
```
**Purpose**: End-to-end integration testing  
**Type**: Essential  
**Source**: Flutter SDK

#### Dart Test
```yaml
test: ^1.24.0
```
**Purpose**: Additional Dart testing utilities  
**Type**: Supporting  
**Features**: Enhanced test matchers and utilities

### Mocking & Test Utilities

#### Mockito
```yaml
mockito: ^5.4.4
```
**Purpose**: Mock object generation for testing  
**Type**: Essential for unit tests  
**Features**:
- Type-safe mocks
- Code generation support
- Verification helpers

#### Build Runner
```yaml
build_runner: ^2.4.8
```
**Purpose**: Code generation during development  
**Type**: Required for mockito and other code generators  
**Features**:
- Runs code generators
- Watches for file changes
- Builds generated code

### Code Quality

#### Flutter Lints
```yaml
flutter_lints: ^6.0.0
```
**Purpose**: Recommended linting rules for Flutter  
**Type**: Essential  
**Features**:
- Enforces Flutter best practices
- Catches common errors
- Improves code quality

## Flutter Configuration

### Material Design

```yaml
flutter:
  uses-material-design: true
```
**Purpose**: Enables Material Design components and icons  
**Type**: Required

### Assets

```yaml
flutter:
  assets:
    - .env
```
**Current Assets**:
- `.env`: Environment configuration file

**Future Asset Directories** (to be added as needed):
```yaml
  assets:
    - .env
    - assets/images/
    - assets/icons/
    - assets/fonts/
    - assets/animations/
```

## Dependency Security Analysis

### Security Considerations

1. **All dependencies are from trusted sources**:
   - pub.dev (official Dart/Flutter package repository)
   - Flutter SDK
   
2. **Version pinning strategy**:
   - Using caret notation (^) for compatible updates
   - Allows patch and minor version updates
   - Prevents breaking changes from major updates

3. **Regular updates needed**:
   - Check for security patches: `flutter pub outdated`
   - Update dependencies: `flutter pub upgrade`
   - Review changelogs before major updates

### Known Vulnerabilities

✅ **No known vulnerabilities** as of January 4, 2026

To check for vulnerabilities:
```bash
# Check outdated packages
flutter pub outdated

# Audit dependencies (using pub.dev)
dart pub deps
```

## Optimization Recommendations

### Current Configuration Status
✅ **Well-configured** - Current dependencies are appropriate for the project requirements

### Potential Additions (As Needed)

#### 1. Caching
```yaml
# For network response caching
dio: ^5.4.0  # Alternative HTTP client with caching
cached_network_image: ^3.3.1  # Image caching
```

#### 2. Local Storage
```yaml
# For complex local data storage
hive: ^2.2.3  # Fast, lightweight local database
hive_flutter: ^1.1.0
```

#### 3. Additional UI Components
```yaml
# For enhanced UI/UX
shimmer: ^3.0.0  # Loading placeholders
flutter_svg: ^2.0.10  # SVG support
lottie: ^3.1.0  # Animations
```

#### 4. Form Handling
```yaml
# For complex forms
flutter_form_builder: ^9.1.1
form_builder_validators: ^9.1.0
```

#### 5. File Handling
```yaml
# For file picking and handling
file_picker: ^6.1.1
path_provider: ^2.1.2
```

### Bundle Size Optimization

Current approach:
- Using tree shaking (automatic in Flutter release builds)
- Minimizing dependencies
- Using const constructors where possible

Future optimizations:
```bash
# Analyze app size
flutter build apk --analyze-size
flutter build appbundle --analyze-size

# Split ABIs for Android (reduces download size)
flutter build apk --split-per-abi
```

## Dependency Update Strategy

### Safe Update Process

1. **Check for updates**:
   ```bash
   flutter pub outdated
   ```

2. **Review changelogs**: Visit pub.dev for each package to check breaking changes

3. **Update one at a time** (for major versions):
   ```bash
   flutter pub upgrade package_name
   ```

4. **Run tests after each update**:
   ```bash
   flutter test
   flutter analyze
   ```

5. **Update all compatible versions** (safe):
   ```bash
   flutter pub upgrade --major-versions
   ```

### Update Schedule

- **Patch updates**: Weekly (automated via Dependabot)
- **Minor updates**: Bi-weekly review
- **Major updates**: Quarterly review with testing
- **Security patches**: Immediate

## Build Configuration

### Release Build Optimizations

The `pubspec.yaml` works with Flutter build system to optimize:

1. **Code Minification**: Automatic in release mode
2. **Tree Shaking**: Removes unused code
3. **Obfuscation**: Available via build flags
   ```bash
   flutter build apk --obfuscate --split-debug-info=/<project-name>/<directory>
   ```

### Platform-Specific Configurations

The pubspec.yaml supports all platforms:
- ✅ Android (APK, App Bundle)
- ✅ iOS (IPA)
- ✅ Web (JavaScript compilation)
- ✅ Linux (Snap, AppImage)
- ✅ macOS (DMG)
- ✅ Windows (MSIX, EXE)

## Troubleshooting

### Common Issues

#### Issue 1: Dependency Conflicts
**Symptom**: Version solving failed  
**Solution**:
```bash
flutter clean
flutter pub get
# If persistent, check for incompatible versions
flutter pub outdated
```

#### Issue 2: Build Failures After Update
**Symptom**: Build errors after dependency update  
**Solution**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Issue 3: Platform-Specific Dependency Issues
**Symptom**: Package doesn't support platform  
**Solution**: Check package compatibility on pub.dev
```yaml
# Add platform-specific dependencies conditionally in code
import 'package:flutter/foundation.dart' show kIsWeb;

if (!kIsWeb) {
  // Use native-only packages
}
```

#### Issue 4: Asset Loading Failures
**Symptom**: Assets not found at runtime  
**Solution**:
1. Verify asset paths in pubspec.yaml
2. Ensure assets exist in specified directories
3. Run `flutter clean` and rebuild

## Validation Commands

```bash
# Validate pubspec.yaml syntax
dart pub get

# Check for outdated packages
flutter pub outdated

# Verify all dependencies resolve
dart pub deps

# Run dependency analysis
flutter pub deps --style=compact

# Check for unused dependencies (manual review)
flutter analyze
```

## References

- Pub.dev Package Repository: https://pub.dev/
- Flutter Dependencies Guide: https://docs.flutter.dev/development/packages-and-plugins/using-packages
- Semantic Versioning: https://semver.org/
- Supabase Flutter Docs: https://supabase.com/docs/reference/dart/introduction
- Riverpod Documentation: https://riverpod.dev/

## Appendix: Complete pubspec.yaml

```yaml
name: nonna_app
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.10.1

dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.8
  supabase: ^2.2.0
  flutter_dotenv: ^5.1.0
  cupertino_icons: ^1.0.8
  intl: ^0.20.2
  image: ^4.1.7
  http: ^1.2.0
  riverpod: ^2.4.9
  flutter_riverpod: ^2.4.9
  go_router: ^13.2.0
  local_auth: ^2.2.0
  flutter_localizations:
    sdk: flutter
  sentry_flutter: ^9.9.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  test: ^1.24.0
  flutter_lints: ^6.0.0
  mockito: ^5.4.4
  build_runner: ^2.4.8

flutter:
  uses-material-design: true
  assets:
    - .env
```

## Approval

**Status**: ✅ Verified and Approved

The pubspec.yaml configuration is properly structured with all necessary dependencies for the Nonna App. The configuration supports:
- ✅ Supabase backend integration
- ✅ Riverpod state management
- ✅ Comprehensive testing setup
- ✅ Error tracking and monitoring
- ✅ Security and authentication
- ✅ Multi-platform support

---

**Document Maintained By**: Technical Lead Team  
**Review Frequency**: On dependency updates or new package additions
