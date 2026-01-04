# Project Structure Diagram

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Lead  
**Status**: Verified  
**Section**: 2.2 - Project Initialization

## Executive Summary

This document provides a comprehensive visual and textual representation of the Nonna App project structure. The structure follows Flutter best practices, Clean Architecture principles, and is optimized for the tile-driven architecture that is central to the application.

## Root Directory Structure

```
nonna_app/
├── .github/                    # GitHub configuration and workflows
│   ├── workflows/              # GitHub Actions CI/CD workflows
│   │   ├── ci.yml             # Continuous Integration pipeline
│   │   ├── android-build.yml  # Android build workflow
│   │   ├── ios-build.yml      # iOS build workflow
│   │   └── web-deploy.yml     # Web deployment workflow
│   └── PULL_REQUEST_TEMPLATE/ # PR templates
│       └── pull_request_template.md
│
├── android/                    # Android platform-specific code
│   ├── app/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── kotlin/    # Kotlin platform code
│   │   │       ├── AndroidManifest.xml
│   │   │       └── res/       # Android resources
│   │   └── build.gradle.kts   # Android app build config
│   ├── gradle/                # Gradle wrapper
│   ├── build.gradle.kts       # Root build configuration
│   ├── settings.gradle.kts    # Gradle settings
│   └── key.properties         # Signing configuration (not in VCS)
│
├── ios/                        # iOS platform-specific code
│   ├── Runner/
│   │   ├── AppDelegate.swift
│   │   ├── Info.plist
│   │   ├── Assets.xcassets/
│   │   └── Runner.xcodeproj/
│   ├── Podfile                # CocoaPods dependencies
│   └── Runner.xcworkspace/
│
├── linux/                      # Linux platform code
│   ├── flutter/
│   └── CMakeLists.txt
│
├── macos/                      # macOS platform code
│   ├── Flutter/
│   ├── Runner/
│   └── Podfile
│
├── web/                        # Web platform code
│   ├── index.html
│   ├── manifest.json
│   ├── favicon.png
│   └── icons/
│
├── windows/                    # Windows platform code
│   ├── flutter/
│   ├── runner/
│   └── CMakeLists.txt
│
├── lib/                        # Main Dart application code
│   ├── main.dart              # Application entry point
│   │
│   ├── core/                  # Core shared functionality
│   │   ├── constants/         # App-wide constants
│   │   │   ├── app_constants.dart
│   │   │   ├── api_constants.dart
│   │   │   └── route_constants.dart
│   │   │
│   │   ├── config/            # App configuration
│   │   │   ├── app_config.dart
│   │   │   ├── environment.dart
│   │   │   └── supabase_config.dart
│   │   │
│   │   ├── theme/             # Theme and styling
│   │   │   ├── app_theme.dart
│   │   │   ├── colors.dart
│   │   │   ├── typography.dart
│   │   │   └── dimensions.dart
│   │   │
│   │   ├── router/            # Navigation configuration
│   │   │   ├── app_router.dart
│   │   │   └── route_guards.dart
│   │   │
│   │   ├── services/          # Core services
│   │   │   ├── supabase_service.dart
│   │   │   ├── auth_service.dart
│   │   │   ├── storage_service.dart
│   │   │   ├── analytics_service.dart
│   │   │   └── notification_service.dart
│   │   │
│   │   ├── utils/             # Utility functions
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   ├── date_utils.dart
│   │   │   └── extensions.dart
│   │   │
│   │   ├── widgets/           # Shared widgets
│   │   │   ├── buttons/
│   │   │   ├── inputs/
│   │   │   ├── loading/
│   │   │   └── error/
│   │   │
│   │   └── errors/            # Error handling
│   │       ├── exceptions.dart
│   │       └── failures.dart
│   │
│   ├── tiles/                 # Tile system (first-class citizens)
│   │   ├── tile_registry.dart # Tile factory and registration
│   │   │
│   │   ├── base/              # Base tile classes
│   │   │   ├── base_tile.dart
│   │   │   ├── tile_config.dart
│   │   │   └── tile_data_source.dart
│   │   │
│   │   ├── feeding/           # Feeding tile
│   │   │   ├── feeding_tile.dart
│   │   │   ├── feeding_tile_provider.dart
│   │   │   ├── feeding_data_source.dart
│   │   │   └── models/
│   │   │       └── feeding_data.dart
│   │   │
│   │   ├── diaper/            # Diaper tile
│   │   │   ├── diaper_tile.dart
│   │   │   ├── diaper_tile_provider.dart
│   │   │   ├── diaper_data_source.dart
│   │   │   └── models/
│   │   │       └── diaper_data.dart
│   │   │
│   │   ├── sleep/             # Sleep tile
│   │   │   └── [similar structure]
│   │   │
│   │   ├── growth/            # Growth tile
│   │   │   └── [similar structure]
│   │   │
│   │   ├── photos/            # Photos tile
│   │   │   └── [similar structure]
│   │   │
│   │   └── milestones/        # Milestones tile
│   │       └── [similar structure]
│   │
│   ├── features/              # Feature modules (screens)
│   │   │
│   │   ├── auth/              # Authentication feature
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── login_screen.dart
│   │   │   │   │   ├── signup_screen.dart
│   │   │   │   │   └── forgot_password_screen.dart
│   │   │   │   ├── widgets/
│   │   │   │   └── providers/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   └── repositories/
│   │   │   └── data/
│   │   │       ├── models/
│   │   │       ├── datasources/
│   │   │       └── repositories/
│   │   │
│   │   ├── home/              # Home/Dashboard feature
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── home_screen.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── tile_grid.dart
│   │   │   │   │   └── baby_selector.dart
│   │   │   │   └── providers/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   │
│   │   ├── profile/           # Profile management
│   │   │   └── [similar structure]
│   │   │
│   │   ├── baby_management/   # Baby profile management
│   │   │   └── [similar structure]
│   │   │
│   │   └── settings/          # App settings
│   │       └── [similar structure]
│   │
│   └── l10n/                  # Localization (generated)
│       ├── app_localizations.dart
│       └── app_localizations_*.dart
│
├── test/                       # Unit and widget tests
│   ├── core/                  # Core functionality tests
│   │   ├── services/
│   │   ├── utils/
│   │   └── widgets/
│   │
│   ├── tiles/                 # Tile tests
│   │   ├── feeding/
│   │   ├── diaper/
│   │   └── [other tiles]
│   │
│   ├── features/              # Feature tests
│   │   ├── auth/
│   │   ├── home/
│   │   └── [other features]
│   │
│   ├── helpers/               # Test helpers
│   │   ├── test_helpers.dart
│   │   └── mock_data.dart
│   │
│   └── fixtures/              # Test fixtures
│       └── json/
│
├── integration_test/           # Integration tests
│   ├── auth_flow_test.dart
│   ├── tile_interaction_test.dart
│   └── app_test.dart
│
├── supabase/                   # Supabase configuration
│   ├── config.toml            # Supabase CLI config
│   ├── migrations/            # Database migrations
│   │   ├── 20240101000000_initial_schema.sql
│   │   └── [other migrations]
│   ├── functions/             # Edge Functions
│   │   └── [function directories]
│   └── seed/                  # Seed data
│       └── seed_data.sql
│
├── docs/                       # Documentation
│   ├── 00_requirement_gathering/
│   ├── 01_technical_requirements/
│   ├── 02_architecture_design/
│   ├── 03_environment_setup/
│   ├── 04_project_initialization/  # This document's location
│   └── Production_Readiness_Checklist.md
│
├── discovery/                  # Discovery and research documents
│   └── [discovery documents]
│
├── assets/                     # Static assets (to be created)
│   ├── images/
│   ├── icons/
│   ├── fonts/
│   └── animations/
│
├── l10n/                       # Localization source files (to be created)
│   ├── app_en.arb             # English translations
│   ├── app_es.arb             # Spanish translations
│   └── [other language files]
│
├── scripts/                    # Build and deployment scripts (to be created)
│   ├── build.sh
│   ├── deploy.sh
│   └── test.sh
│
├── config/                     # Environment configurations (to be created)
│   ├── dev.env
│   ├── staging.env
│   └── prod.env
│
├── .github/                    # GitHub configuration
├── pubspec.yaml               # Dart dependencies and metadata
├── pubspec.lock               # Locked dependency versions
├── analysis_options.yaml      # Linter and analyzer configuration
├── .pre-commit-config.yaml    # Pre-commit hooks configuration
├── .secrets.baseline          # Detect-secrets baseline
├── .gitignore                 # Git ignore patterns
├── .metadata                  # Flutter project metadata
├── .env.example               # Environment variables template
├── Makefile                   # Build automation commands
├── README.md                  # Project overview
├── CHANGELOG.md               # Version history (to be created)
├── CONTRIBUTING.md            # Contribution guidelines (to be created)
├── LICENSE                    # Software license (to be created)
└── run_all_tests.sh           # Test runner script
```

## Directory Purpose and Organization

### Platform Directories

#### android/
**Purpose**: Android-specific native code and configuration  
**Key Files**:
- `app/build.gradle.kts`: Android build configuration with applicationId
- `app/src/main/AndroidManifest.xml`: App manifest with permissions
- `app/src/main/kotlin/`: Native Kotlin code for platform channels

#### ios/
**Purpose**: iOS-specific native code and configuration  
**Key Files**:
- `Runner/Info.plist`: iOS app configuration
- `Podfile`: CocoaPods dependencies
- `Runner.xcodeproj/`: Xcode project configuration

#### web/, linux/, macos/, windows/
**Purpose**: Platform-specific configurations for web and desktop platforms  
**Status**: Basic configurations in place, ready for platform-specific features

### Application Code (lib/)

#### core/
**Purpose**: Shared functionality used across the entire application  
**Key Characteristics**:
- No feature-specific code
- Reusable services, utilities, and widgets
- App-wide configuration and theme
- Navigation setup

**Organization Pattern**: By type (services, utils, widgets, etc.)

#### tiles/
**Purpose**: Self-contained, reusable tile components  
**Key Characteristics**:
- First-class citizens in the architecture
- Each tile has its own data layer, state management, and UI
- Parameterized and reusable across features
- Independent and modular

**Organization Pattern**: By tile type (feeding, diaper, sleep, etc.)

#### features/
**Purpose**: Feature-specific screens and logic  
**Key Characteristics**:
- Organized by business feature
- Clean Architecture layers (presentation, domain, data)
- Features compose tiles, not duplicate them
- Screen-specific state management

**Organization Pattern**: By feature, then by architectural layer

### Testing Structure (test/ & integration_test/)

#### test/
**Purpose**: Unit and widget tests  
**Organization**: Mirrors the lib/ structure
- `test/core/`: Tests for core functionality
- `test/tiles/`: Tests for tile components
- `test/features/`: Tests for feature modules

#### integration_test/
**Purpose**: End-to-end integration tests  
**Organization**: By user flow or critical path
- Authentication flows
- Tile interactions
- Multi-screen workflows

### Configuration and Documentation

#### docs/
**Purpose**: Comprehensive project documentation  
**Organization**: By development phase and topic
- Requirements, architecture, environment setup
- This document is located in `04_project_initialization/`

#### supabase/
**Purpose**: Backend configuration and database management  
**Key Contents**:
- Database migrations
- Edge Functions
- Seed data
- Supabase CLI configuration

## Architectural Patterns

### Clean Architecture Layers (within features/)

```
feature/
├── presentation/     # UI layer
│   ├── screens/     # Screen widgets
│   ├── widgets/     # Feature-specific widgets
│   └── providers/   # Riverpod providers
├── domain/          # Business logic layer
│   ├── entities/    # Business objects
│   └── repositories/ # Repository interfaces
└── data/            # Data layer
    ├── models/      # Data models
    ├── datasources/ # Data sources (API, local)
    └── repositories/ # Repository implementations
```

### Tile Architecture Pattern

```
tile/
├── {tile_name}_tile.dart           # Main tile widget
├── {tile_name}_tile_provider.dart  # State management
├── {tile_name}_data_source.dart    # Data layer
└── models/                         # Tile-specific models
    └── {tile_name}_data.dart
```

## Key Design Principles

1. **Separation of Concerns**: Clear boundaries between layers
2. **Modularity**: Tiles and features are independent modules
3. **Testability**: Parallel test structure, mockable dependencies
4. **Scalability**: Easy to add new tiles and features
5. **Maintainability**: Consistent patterns, clear organization

## Navigation Structure

The application uses a hierarchical navigation structure managed by go_router:

```
/ (Root)
├── /auth
│   ├── /login
│   ├── /signup
│   └── /forgot-password
│
├── /home (Protected)
│   ├── Dashboard with tile grid
│   └── Baby profile selector
│
├── /profile (Protected)
│   └── User profile management
│
├── /baby-management (Protected)
│   ├── /create-baby
│   ├── /edit-baby/:id
│   └── /invite-followers
│
└── /settings (Protected)
    ├── Account settings
    ├── Notifications
    └── Privacy
```

## File Naming Conventions

- **Dart Files**: `snake_case.dart` (e.g., `feeding_tile.dart`)
- **Classes**: `PascalCase` (e.g., `FeedingTile`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `MAX_TILE_COUNT`)
- **Private Members**: Prefix with underscore `_privateMember`
- **Test Files**: Match source file with `_test.dart` suffix (e.g., `feeding_tile_test.dart`)

## Import Organization

Imports should be organized in the following order:

1. Dart SDK imports
2. Flutter SDK imports
3. Third-party package imports
4. Project imports (relative imports)

Example:
```dart
// Dart SDK
import 'dart:async';

// Flutter SDK
import 'package:flutter/material.dart';

// Third-party packages
import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports
import '../../core/services/auth_service.dart';
import '../models/user.dart';
```

## State Management Organization

Using Riverpod for state management with the following patterns:

- **Providers**: Defined close to their usage (in feature or tile)
- **Global Providers**: Defined in `core/` for app-wide state
- **Scoped Providers**: Defined within features/tiles for local state

## Validation Checklist

- [x] Root directory structure matches Flutter standards
- [x] Platform directories (android, ios, web, desktop) present
- [x] lib/ directory organized by architectural layers
- [x] Tiles organized as first-class independent modules
- [x] Features follow Clean Architecture pattern
- [x] Test directory mirrors lib/ structure
- [x] Documentation properly organized
- [x] Supabase configuration in dedicated directory
- [x] Configuration files at root level
- [x] .gitignore configured for Flutter projects

## References

- Flutter Project Structure: https://docs.flutter.dev/development/tools/pubspec
- Clean Architecture: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- Riverpod Architecture: https://riverpod.dev/docs/concepts/providers
- Supabase Setup: https://supabase.com/docs/guides/getting-started/quickstarts/flutter

## Future Enhancements

As the project evolves, the following directories may be added:

- `assets/`: Static assets (images, fonts, icons)
- `l10n/`: Localization source files
- `scripts/`: Build and deployment automation
- `config/`: Environment-specific configurations
- Additional platform directories as needed

---

**Document Maintained By**: Technical Lead Team  
**Review Frequency**: On structural changes or new modules added
