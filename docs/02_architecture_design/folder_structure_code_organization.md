# Folder Structure and Code Organization Plan

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Architecture Team  
**Status**: Final  
**Section**: 1.3 - Architecture Design

## Executive Summary

This document defines the comprehensive folder structure and code organization strategy for the Nonna App, a Flutter-based, tile-driven family social platform. The structure is optimized for the app's dynamic tile-based UI architecture, role-driven content aggregation, modular development, and scalability.

The organization follows Flutter and Clean Architecture best practices, with tiles as first-class citizens at the top level for maximum reusability across screens. The structure supports:
- Clear separation of concerns with layered architecture
- Tile-based modular components with independent data layers
- Feature-based organization for screen-specific logic
- Testability with parallel test structure
- Maintainability with consistent patterns across the codebase

## References

This document is informed by and aligns with:

- `discovery/App_Structure_Nonna.md` - Initial folder structure proposal from discovery phase
- `docs/02_architecture_design/system_architecture_diagram.md` - Overall architecture layers
- `docs/02_architecture_design/state_management_design.md` - State management organization
- `discovery/01_discovery/04_technical_requirements/Tile_System_Design.md` - Tile architecture requirements
- `docs/01_technical_requirements/functional_requirements_specification.md` - Feature requirements
- Flutter Best Practices: Feature-First, Clean Architecture patterns

---

## 1. Folder Structure Overview

### 1.1 Root Directory Structure

```
nonna_app/
├── android/                    # Android platform-specific code
├── ios/                        # iOS platform-specific code
├── linux/                      # Linux platform-specific code (future)
├── macos/                      # macOS platform-specific code (future)
├── web/                        # Web platform-specific code (future)
├── windows/                    # Windows platform-specific code (future)
├── lib/                        # Main Dart application code
├── test/                       # Unit and widget tests
├── integration_test/           # Integration and E2E tests
├── assets/                     # Static resources (images, fonts, animations)
├── l10n/                       # Localization files
├── docs/                       # Architecture and technical documentation
├── supabase/                   # Supabase configuration and migrations
├── scripts/                    # Build and deployment scripts
├── config/                     # Environment configurations
├── .github/                    # GitHub workflows and templates
├── pubspec.yaml               # Dart dependencies
├── analysis_options.yaml      # Linter and analyzer configuration
├── README.md                   # Project overview and setup instructions
├── CHANGELOG.md                # Version history
├── CONTRIBUTING.md             # Contribution guidelines
├── LICENSE                     # Software license
├── Makefile                    # Build automation commands
├── .gitignore                  # Git ignore patterns
├── .env.example                # Environment variables template
└── .metadata                   # Flutter metadata
```

### 1.2 Design Principles

**1. Tiles as First-Class Citizens**
- Tiles live in `lib/tiles/` for easy access across all screens
- Self-contained with own models, providers, data sources, and widgets
- Parameterized and reusable

**2. Feature-Based Organization**
- Features (screens) organized by domain in `lib/features/`
- Each feature has presentation, data, and domain layers
- Features compose tiles, not duplicate them

**3. Clear Separation of Concerns**
- Core (`lib/core/`): Shared across entire app
- Tiles (`lib/tiles/`): Reusable tile components
- Features (`lib/features/`): Screen-specific logic
- Infrastructure: Low-level services in `lib/core/services/`

**4. Testability**
- Test structure mirrors lib structure
- Mocks and fixtures shared in test directory
- Integration tests separate from unit tests

**5. Scalability**
- Easy to add new tiles without touching existing code
- Easy to add new features with consistent patterns
- Plugin-like architecture for tiles

---

## 2. Core Application Structure (`lib/`)

### 2.1 Main Entry Points

```
lib/
├── main.dart                   # Application entry point
└── app.dart                    # Root widget with routing & theme
```

**main.dart** - Application initialization:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
  );
  
  // Initialize cache
  await Hive.initFlutter();
  
  // Initialize Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn = Environment.sentryDsn;
    },
    appRunner: () => runApp(
      ProviderScope(
        child: const NonnaApp(),
      ),
    ),
  );
}
```

**app.dart** - Root widget:
```dart
class NonnaApp extends ConsumerWidget {
  const NonnaApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: 'Nonna',
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.mode,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
```

### 2.2 Core Layer (`lib/core/`)

**Purpose**: Shared functionality across the entire application

```
lib/core/
├── models/                     # Shared domain models
│   ├── user.dart
│   ├── baby_profile.dart
│   ├── event.dart
│   ├── photo.dart
│   ├── registry_item.dart
│   ├── notification.dart
│   ├── tile_config.dart
│   └── screen_config.dart
├── repositories/              # Abstract repository contracts
│   └── interfaces/
│       ├── auth_repository.dart
│       ├── user_repository.dart
│       ├── baby_profile_repository.dart
│       ├── tile_config_repository.dart
│       ├── event_repository.dart
│       ├── photo_repository.dart
│       ├── registry_repository.dart
│       └── notification_repository.dart
├── network/                   # Supabase client and configuration
│   ├── supabase_client.dart
│   ├── interceptors/
│   │   ├── auth_interceptor.dart
│   │   └── logging_interceptor.dart
│   └── endpoints/
│       ├── auth_endpoints.dart
│       ├── tile_endpoints.dart
│       ├── event_endpoints.dart
│       ├── photo_endpoints.dart
│       ├── registry_endpoints.dart
│       └── edge_functions.dart
├── utils/                     # Helper functions
│   ├── date_helpers.dart
│   ├── formatters.dart
│   ├── validators.dart
│   ├── image_helpers.dart
│   ├── role_helpers.dart
│   └── share_helpers.dart
├── extensions/                # Dart/Flutter extensions
│   ├── string_extensions.dart
│   ├── context_extensions.dart
│   ├── date_extensions.dart
│   └── list_extensions.dart
├── mixins/                    # Reusable behaviors
│   ├── role_aware_mixin.dart
│   ├── validation_mixin.dart
│   └── loading_mixin.dart
├── enums/                     # Global enums
│   ├── user_role.dart
│   ├── tile_type.dart
│   ├── screen_name.dart
│   ├── notification_type.dart
│   └── event_status.dart
├── typedefs/                  # Type aliases
│   └── callbacks.dart
├── contracts/                 # Shared interfaces
│   ├── cacheable.dart
│   └── realtime_subscribable.dart
├── di/                        # Dependency injection
│   ├── providers.dart
│   └── service_locator.dart
├── themes/                    # App-wide theming
│   ├── app_theme.dart
│   ├── colors.dart
│   ├── text_styles.dart
│   └── tile_styles.dart
├── config/                    # Environment configurations
│   ├── app_config.dart
│   └── environment.dart
├── constants/                 # App-wide constants
│   ├── strings.dart
│   ├── supabase_tables.dart
│   └── performance_limits.dart
├── services/                  # Shared services
│   ├── supabase_service.dart
│   ├── cache_service.dart
│   ├── storage_service.dart
│   ├── notification_service.dart
│   ├── realtime_service.dart
│   ├── analytics_service.dart
│   └── observability_service.dart
├── middleware/                # App-level middleware
│   ├── error_handler.dart
│   ├── cache_manager.dart
│   └── rls_validator.dart
├── exceptions/                # Custom exception classes
│   ├── app_exceptions.dart
│   ├── supabase_exceptions.dart
│   └── permission_exceptions.dart
├── router/                    # App navigation
│   ├── app_router.dart
│   └── route_guards.dart
└── widgets/                   # Shared UI widgets
    ├── loading_indicator.dart
    ├── error_view.dart
    ├── empty_state.dart
    ├── custom_button.dart
    └── shimmer_placeholder.dart
```

---

## 3. Tiles Layer (`lib/tiles/`)

**Purpose**: Reusable tile widgets used across multiple screens

### 3.1 Tile Structure

Each tile follows a consistent structure:

```
lib/tiles/[tile_name]/
├── models/
│   └── [tile_model].dart
├── providers/
│   ├── [tile_name]_provider.dart
│   └── [tile_name]_cache_provider.dart
├── data/
│   ├── datasources/
│   │   ├── remote/
│   │   │   └── [tile_name]_datasource.dart
│   │   └── local/
│   │       └── [tile_name]_cache.dart
│   └── mappers/
│       └── [tile_name]_mapper.dart
├── widgets/
│   ├── [tile_name]_tile.dart
│   └── [tile_item]_card.dart
└── test/
    ├── [tile_name]_provider_test.dart
    ├── [tile_name]_datasource_test.dart
    └── [tile_name]_tile_test.dart
```

### 3.2 Complete Tiles Directory

```
lib/tiles/
├── core/                          # Shared tile infrastructure
│   ├── models/
│   │   ├── tile_config.dart
│   │   ├── tile_params.dart
│   │   └── tile_state.dart
│   ├── widgets/
│   │   ├── tile_factory.dart
│   │   ├── base_tile.dart
│   │   └── tile_container.dart
│   ├── providers/
│   │   ├── tile_config_provider.dart
│   │   └── tile_visibility_provider.dart
│   ├── data/
│   │   ├── repositories/
│   │   │   └── tile_config_repository_impl.dart
│   │   └── datasources/
│   │       ├── remote/
│   │       │   └── tile_config_remote_datasource.dart
│   │       └── local/
│   │           └── tile_config_cache.dart
│   └── test/
│       ├── tile_factory_test.dart
│       └── tile_config_provider_test.dart
├── upcoming_events/              # Tile: Upcoming Events
│   ├── models/
│   ├── providers/
│   ├── data/
│   └── widgets/
├── recent_photos/                # Tile: Recent Photos
│   ├── models/
│   ├── providers/
│   ├── data/
│   └── widgets/
├── registry_highlights/          # Tile: Registry Highlights
├── notifications/                # Tile: Notifications
├── invites_status/               # Tile: Invitations Status (owner-only)
├── rsvp_tasks/                   # Tile: RSVP Tasks
├── due_date_countdown/           # Tile: Due Date Countdown
├── recent_purchases/             # Tile: Recent Purchases
├── registry_deals/               # Tile: Registry Deals/Recommendations
├── engagement_recap/             # Tile: Engagement Recap
├── gallery_favorites/            # Tile: Gallery Favorites
├── checklist/                    # Tile: Checklist/Onboarding (owner-only)
├── storage_usage/                # Tile: Storage Usage (owner-only)
├── system_announcements/         # Tile: System Announcements
└── new_followers/                # Tile: New Followers (owner-only)
```

### 3.3 Tile Implementation Example

**Example: `lib/tiles/upcoming_events/`**

```
upcoming_events/
├── models/
│   └── upcoming_event.dart
│       // Data model for upcoming event
│       class UpcomingEvent {
│         final String id;
│         final String babyProfileId;
│         final String title;
│         final DateTime eventDate;
│         final String? location;
│         final int rsvpCount;
│       }
├── providers/
│   └── upcoming_events_provider.dart
│       // Riverpod provider for fetching events
│       @riverpod
│       Future<List<UpcomingEvent>> upcomingEvents(
│         UpcomingEventsRef ref,
│         TileParams params,
│       ) async { ... }
├── data/
│   ├── datasources/
│   │   ├── remote/
│   │   │   └── upcoming_events_datasource.dart
│   │   │       // Supabase queries for events
│   │   │       class UpcomingEventsDataSource {
│   │   │         Future<List<UpcomingEvent>> fetchEvents(TileParams params) {
│   │   │           // Query Supabase with role-based scoping
│   │   │         }
│   │   │       }
│   │   └── local/
│   │       └── upcoming_events_cache.dart
│   │           // Hive/Isar cache for events
│   └── mappers/
│       └── upcoming_event_mapper.dart
│           // Map between DTO and domain model
├── widgets/
│   ├── upcoming_events_tile.dart
│   │   // Main tile widget
│   │   class UpcomingEventsTile extends ConsumerWidget {
│   │     final TileParams params;
│   │     @override
│   │     Widget build(BuildContext context, WidgetRef ref) {
│   │       final eventsAsync = ref.watch(upcomingEventsProvider(params));
│   │       return eventsAsync.when(...);
│   │     }
│   │   }
│   └── event_item_card.dart
│       // Individual event card UI
└── test/
    ├── upcoming_events_provider_test.dart
    ├── upcoming_events_datasource_test.dart
    └── upcoming_events_tile_test.dart
```

---

## 4. Features Layer (`lib/features/`)

**Purpose**: Screen-specific logic and composition

### 4.1 Feature Structure

Each feature follows Clean Architecture layers:

```
lib/features/[feature_name]/
├── presentation/
│   ├── providers/
│   │   ├── [feature]_provider.dart
│   │   └── [feature]_state.dart
│   ├── screens/
│   │   └── [screen_name]_screen.dart
│   └── widgets/
│       └── [widget_name].dart
├── data/
│   ├── models/
│   │   └── [model]_dto.dart
│   ├── mappers/
│   │   └── [model]_mapper.dart
│   ├── repositories/
│   │   └── [repository]_impl.dart
│   └── datasources/
│       ├── remote/
│       │   └── [datasource]_remote.dart
│       └── local/
│           └── [datasource]_local.dart
├── domain/
│   ├── use_cases/
│   │   └── [use_case].dart
│   └── entities/
│       └── [entity].dart
└── test/
    ├── [feature]_provider_test.dart
    ├── [use_case]_test.dart
    └── [screen]_test.dart
```

### 4.2 Complete Features Directory

```
lib/features/
├── auth/                         # Authentication feature
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   └── auth_state.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── role_selection_screen.dart
│   │   └── widgets/
│   │       └── auth_form_widgets.dart
│   ├── data/
│   │   ├── models/
│   │   ├── mappers/
│   │   ├── repositories/
│   │   │   └── auth_repository_impl.dart
│   │   └── datasources/
│   ├── domain/
│   │   ├── use_cases/
│   │   │   ├── login_use_case.dart
│   │   │   ├── signup_use_case.dart
│   │   │   └── logout_use_case.dart
│   │   └── entities/
│   └── test/
├── home/                         # Home screen
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── home_screen_provider.dart
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   │       ├── home_app_bar.dart
│   │       └── tile_list_view.dart
│   └── test/
├── calendar/                     # Calendar feature
│   ├── presentation/
│   │   ├── providers/
│   │   ├── screens/
│   │   │   └── calendar_screen.dart
│   │   └── widgets/
│   │       └── calendar_widget.dart
│   └── test/
├── gallery/                      # Gallery feature
│   ├── presentation/
│   │   ├── providers/
│   │   ├── screens/
│   │   │   ├── gallery_screen.dart
│   │   │   └── photo_detail_screen.dart
│   │   └── widgets/
│   │       └── squish_photo_widget.dart
│   └── test/
├── registry/                     # Registry feature
│   ├── presentation/
│   │   ├── providers/
│   │   ├── screens/
│   │   │   ├── registry_screen.dart
│   │   │   └── registry_item_detail_screen.dart
│   │   └── widgets/
│   │       └── registry_filter_bar.dart
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   │   └── registry_repository_impl.dart
│   │   └── datasources/
│   ├── domain/
│   │   ├── use_cases/
│   │   │   ├── get_registry_items.dart
│   │   │   └── purchase_item.dart
│   │   └── entities/
│   └── test/
├── photo_gallery/                # Photo Gallery feature
│   ├── presentation/
│   │   ├── providers/
│   │   ├── screens/
│   │   │   ├── photo_gallery_screen.dart
│   │   │   └── photo_upload_screen.dart
│   │   └── widgets/
│   └── test/
├── fun/                          # Fun screen (gamification)
│   ├── presentation/
│   │   ├── providers/
│   │   ├── screens/
│   │   │   └── fun_screen.dart
│   │   └── widgets/
│   └── test/
├── profile/                      # User profile feature
│   ├── presentation/
│   │   ├── providers/
│   │   ├── screens/
│   │   │   ├── profile_screen.dart
│   │   │   └── edit_profile_screen.dart
│   │   └── widgets/
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   │   └── profile_repository_impl.dart
│   │   └── datasources/
│   ├── domain/
│   │   ├── use_cases/
│   │   │   ├── update_profile.dart
│   │   │   └── get_profile.dart
│   │   └── entities/
│   └── test/
└── baby_profile/                 # Baby profile feature
    ├── presentation/
    │   ├── providers/
    │   │   └── baby_profile_provider.dart
    │   ├── screens/
    │   │   ├── baby_profile_screen.dart
    │   │   ├── create_baby_profile_screen.dart
    │   │   └── edit_baby_profile_screen.dart
    │   └── widgets/
    ├── data/
    │   ├── models/
    │   ├── repositories/
    │   │   └── baby_profile_repository_impl.dart
    │   └── datasources/
    ├── domain/
    │   ├── use_cases/
    │   │   ├── create_baby_profile.dart
    │   │   ├── update_baby_profile.dart
    │   │   └── get_baby_profiles.dart
    │   └── entities/
    └── test/
```

---

## 5. Testing Structure (`test/`, `integration_test/`)

### 5.1 Unit & Widget Tests (`test/`)

**Structure mirrors lib structure**:

```
test/
├── mocks/                        # Shared mock implementations
│   ├── mock_supabase_client.dart
│   ├── mock_repositories.dart
│   └── mock_datasources.dart
├── fixtures/                     # Test data
│   ├── tile_configs.json
│   ├── events.json
│   ├── photos.json
│   └── baby_profiles.json
├── helpers/                      # Test utilities
│   ├── test_helpers.dart
│   ├── riverpod_test_helpers.dart
│   └── pump_app.dart
├── core/                         # Core tests
│   ├── models/
│   ├── services/
│   └── utils/
├── tiles/                        # Tile tests (mirrors lib/tiles/)
│   ├── core/
│   ├── upcoming_events/
│   ├── recent_photos/
│   └── ...
└── features/                     # Feature tests (mirrors lib/features/)
    ├── auth/
    ├── home/
    ├── calendar/
    └── ...
```

### 5.2 Integration Tests (`integration_test/`)

```
integration_test/
├── app_flow_test.dart            # Complete user journeys
├── owner_flow_test.dart          # Owner-specific flows
├── follower_flow_test.dart       # Follower-specific flows
├── tile_interaction_test.dart    # Tile interaction scenarios
└── test_helpers/
    └── integration_test_helpers.dart
```

---

## 6. Assets & Resources

### 6.1 Assets Directory

```
assets/
├── images/
│   ├── icons/
│   │   ├── app_icon.png
│   │   └── notification_icon.png
│   ├── placeholders/
│   │   ├── baby_placeholder.png
│   │   ├── photo_placeholder.png
│   │   └── avatar_placeholder.png
│   └── onboarding/
│       ├── welcome_1.png
│       ├── welcome_2.png
│       └── welcome_3.png
├── fonts/
│   ├── Roboto-Regular.ttf
│   ├── Roboto-Bold.ttf
│   └── Roboto-Medium.ttf
└── animations/
    ├── loading.json              # Lottie animation
    └── success.json
```

### 6.2 Localization

```
l10n/
├── app_en.arb                    # English translations
└── app_es.arb                    # Spanish translations (future)
```

---

## 7. Configuration & Documentation

### 7.1 Documentation Directory

```
docs/
├── 00_requirement_gathering/     # Section 1.1 documents
│   ├── business_requirements_document.md
│   ├── user_personas_document.md
│   ├── user_journey_maps.md
│   ├── success_metrics_kpis.md
│   └── competitor_analysis_report.md
├── 01_technical_requirements/    # Section 1.2 documents
│   ├── functional_requirements_specification.md
│   ├── non_functional_requirements_specification.md
│   ├── data_model_diagram.md
│   ├── api_integration_plan.md
│   └── performance_scalability_targets.md
├── 02_architecture_design/       # Section 1.3 documents (THIS SECTION)
│   ├── system_architecture_diagram.md
│   ├── state_management_design.md
│   ├── security_privacy_architecture.md
│   ├── folder_structure_code_organization.md
│   └── database_schema_design.md
├── adr/                          # Architecture Decision Records
│   ├── 0001-tile-based-architecture.md
│   ├── 0002-supabase-backend.md
│   └── 0003-riverpod-state-management.md
├── Production_Readiness_Checklist.md
└── Document_Dependency_Matrix.md
```

### 7.2 Supabase Configuration

```
supabase/
├── migrations/                   # Database migrations
│   ├── 20260101000001_initial_schema.sql
│   ├── 20260101000002_rls_policies.sql
│   └── 20260101000003_triggers.sql
├── functions/                    # Edge functions
│   ├── invitation-processing/
│   │   └── index.ts
│   ├── push-notification/
│   │   └── index.ts
│   └── image-processing/
│       └── index.ts
├── seed.sql                      # Seed data for development
└── config.toml                   # Supabase configuration
```

### 7.3 Scripts Directory

```
scripts/
├── build.sh                      # Build script
├── deploy.sh                     # Deployment script
├── code_generation.sh            # Run build_runner
└── supabase_migrate.sh           # Run Supabase migrations
```

### 7.4 Environment Configuration

```
config/
├── .env.example                  # Template for environment variables
├── .env.dev                      # Development configuration
└── .env.prod                     # Production configuration
```

---

## 8. Code Organization Best Practices

### 8.1 Naming Conventions

**Files**:
- Lowercase with underscores: `upcoming_events_tile.dart`
- Test files: `[file_name]_test.dart`
- Mock files: `mock_[file_name].dart`

**Classes**:
- PascalCase: `UpcomingEventsTile`
- Providers: `[Name]Provider` (e.g., `UpcomingEventsProvider`)
- Notifiers: `[Name]Notifier` (e.g., `AuthNotifier`)
- State classes: `[Name]State` (e.g., `AuthState`)

**Variables & Functions**:
- camelCase: `fetchEvents`, `babyProfileId`
- Constants: SCREAMING_SNAKE_CASE: `MAX_FILE_SIZE`
- Private: `_privateMethod`, `_privateVariable`

**Directories**:
- Lowercase with underscores: `upcoming_events/`
- Plural for collections: `providers/`, `models/`, `widgets/`

### 8.2 Import Organization

**Order**:
1. Dart SDK imports
2. Flutter imports
3. Third-party package imports
4. Application imports
5. Relative imports

**Example**:
```dart
// Dart SDK
import 'dart:async';
import 'dart:io';

// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Third-party packages
import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Application imports
import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/tiles/upcoming_events/widgets/upcoming_events_tile.dart';

// Relative imports
import '../models/event.dart';
import '../providers/events_provider.dart';
```

### 8.3 File Size Guidelines

**Recommendations**:
- Max 300 lines per file (excluding comments and imports)
- Split large files into smaller, focused modules
- Extract reusable widgets into separate files
- Use private extensions for helper methods

**Example**:
```
// Instead of one large file:
event_screen.dart (800 lines)

// Split into:
event_screen.dart (150 lines)         // Main screen
event_screen_header.dart (50 lines)   // Header widget
event_screen_body.dart (100 lines)    // Body widget
event_card.dart (80 lines)            // Event card
event_extensions.dart (50 lines)      // Helper extensions
```

### 8.4 Dependency Management

**Layered Dependencies**:
- Core → no dependencies within app (only external packages)
- Tiles → depends on Core only
- Features → depends on Core and Tiles
- Screens → compose features and tiles

**Avoid**:
- Circular dependencies between features
- Direct dependencies between tiles
- Features depending on other features

---

## 9. Modular Development Strategy

### 9.1 Adding a New Tile

**Steps**:

1. **Create directory structure**:
   ```bash
   mkdir -p lib/tiles/new_tile/{models,providers,data/{datasources/{remote,local},mappers},widgets}
   mkdir -p test/tiles/new_tile
   ```

2. **Implement model**:
   ```dart
   // lib/tiles/new_tile/models/new_tile_data.dart
   @freezed
   class NewTileData with _$NewTileData {
     const factory NewTileData({
       required String id,
       required String content,
     }) = _NewTileData;
     
     factory NewTileData.fromJson(Map<String, dynamic> json) =>
       _$NewTileDataFromJson(json);
   }
   ```

3. **Implement data source**:
   ```dart
   // lib/tiles/new_tile/data/datasources/remote/new_tile_datasource.dart
   class NewTileDataSource {
     final SupabaseClient _client;
     
     Future<List<NewTileData>> fetch(TileParams params) async {
       final data = await _client
         .from('new_tile_table')
         .select()
         .eq('baby_profile_id', params.babyIds.first);
       
       return data.map((json) => NewTileData.fromJson(json)).toList();
     }
   }
   ```

4. **Implement provider**:
   ```dart
   // lib/tiles/new_tile/providers/new_tile_provider.dart
   @riverpod
   Future<List<NewTileData>> newTile(
     NewTileRef ref,
     TileParams params,
   ) async {
     final datasource = ref.read(newTileDataSourceProvider);
     return await datasource.fetch(params);
   }
   ```

5. **Implement widget**:
   ```dart
   // lib/tiles/new_tile/widgets/new_tile.dart
   class NewTile extends ConsumerWidget {
     final TileParams params;
     
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final dataAsync = ref.watch(newTileProvider(params));
       
       return dataAsync.when(
         loading: () => ShimmerTile(),
         error: (e, s) => ErrorTile(error: e.toString()),
         data: (data) => TileContainer(
           title: 'New Tile',
           children: data.map((item) => ItemCard(item: item)).toList(),
         ),
       );
     }
   }
   ```

6. **Register in TileFactory**:
   ```dart
   // lib/tiles/core/widgets/tile_factory.dart
   class TileFactory {
     static Widget create(TileConfig config) {
       switch (config.type) {
         // ... existing tiles
         case TileType.newTile:
           return NewTile(params: config.params);
         default:
           return ErrorTile(error: 'Unknown tile type');
       }
     }
   }
   ```

7. **Add tests**:
   ```dart
   // test/tiles/new_tile/new_tile_provider_test.dart
   test('should fetch new tile data', () async {
     final container = ProviderContainer(
       overrides: [
         newTileDataSourceProvider.overrideWithValue(mockDataSource),
       ],
     );
     
     final data = await container.read(newTileProvider(params).future);
     
     expect(data, isNotEmpty);
   });
   ```

### 9.2 Adding a New Feature

**Steps**:

1. **Create feature structure**:
   ```bash
   mkdir -p lib/features/new_feature/{presentation/{providers,screens,widgets},data/{models,repositories,datasources/{remote,local}},domain/{use_cases,entities}}
   mkdir -p test/features/new_feature
   ```

2. **Implement domain layer** (use cases, entities)

3. **Implement data layer** (repositories, data sources, DTOs)

4. **Implement presentation layer** (screens, widgets, providers)

5. **Add route** in `lib/core/router/app_router.dart`

6. **Add tests** for all layers

### 9.3 Code Generation

**Use build_runner for**:
- Freezed models (`@freezed`)
- Riverpod providers (`@riverpod`)
- JSON serialization (`json_serializable`)

**Run**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 10. Continuous Integration

### 10.1 GitHub Workflows

```
.github/
├── workflows/
│   ├── ci.yml                    # Flutter test, analyze, build
│   └── deploy.yml                # Deploy to stores
├── PULL_REQUEST_TEMPLATE.md
└── ISSUE_TEMPLATE/
    ├── bug_report.md
    ├── feature_request.md
    └── architecture_decision.md
```

### 10.2 CI/CD Pipeline

**ci.yml** - On push/PR:
1. Run `flutter analyze`
2. Run `flutter test`
3. Run `flutter test integration_test`
4. Build iOS and Android apps

**deploy.yml** - On tag (v*):
1. Build release builds
2. Submit to App Store and Play Store
3. Deploy database migrations
4. Tag release in Sentry

---

## 11. Architecture Validation

### 11.1 Structure Benefits

| Benefit | Implementation |
|---------|---------------|
| **Modularity** | Tiles and features are independent, can be developed in parallel |
| **Reusability** | Tiles reused across multiple screens without duplication |
| **Testability** | Each layer has clear boundaries, easy to mock and test |
| **Scalability** | Easy to add new tiles and features without affecting existing code |
| **Maintainability** | Consistent structure makes code predictable and easy to navigate |
| **Performance** | Lazy loading of features and tiles reduces initial bundle size |
| **Collaboration** | Team members can work on different tiles/features without conflicts |

### 11.2 Requirements Alignment

| Requirement | Folder Structure Support | Status |
|-------------|-------------------------|--------|
| Tile-based dynamic UI | `lib/tiles/` as first-class citizens | ✅ |
| Role-based content | Tile providers with role parameters | ✅ |
| Clean architecture | Layered structure (presentation, domain, data) | ✅ |
| State management | Riverpod providers organized by layer | ✅ |
| Testability | Parallel test structure, shared mocks | ✅ |
| Feature modularity | Feature-based organization in `lib/features/` | ✅ |
| Code generation | Structured for Freezed, Riverpod, JSON serialization | ✅ |
| Documentation | Comprehensive docs with ADRs | ✅ |

---

## 12. Conclusion

The Nonna App folder structure is designed to support a scalable, maintainable, and modular codebase with the following key strengths:

**Key Strengths**:
- **Tiles as First-Class Citizens**: Top-level `lib/tiles/` for maximum reusability
- **Clean Architecture**: Clear separation of concerns with presentation, domain, and data layers
- **Feature-Based Organization**: Each feature is self-contained and independent
- **Testability**: Parallel test structure mirrors lib structure for easy testing
- **Scalability**: Easy to add new tiles and features without refactoring
- **Consistency**: All tiles and features follow the same structure patterns

**Development Workflow**:
- New tiles added to `lib/tiles/` with consistent structure
- New features added to `lib/features/` following Clean Architecture
- Tests mirror lib structure for easy discovery
- Code generation via build_runner for reduced boilerplate

This folder structure provides a solid foundation for the Nonna MVP and supports future growth without major restructuring.

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Next Review**: Before Development Phase Begins  
**Approval Status**: Pending Architecture Team Review
