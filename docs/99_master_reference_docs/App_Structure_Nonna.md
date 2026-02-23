# Nonna App Project Structure (Dynamic Tile-Based Architecture)

**Document Version**: 2.3
**Last Updated**: February 23, 2026
**Location**: `docs/99_master_reference_docs/App_Structure_Nonna.md`
**Status**: Living Document - Updated to reflect current implementation state

This structure is optimized for the Nonna app's dynamic, tile-based UI with role-driven content, Supabase backend, and support for owner/follower aggregation. Tiles are parameterized, reusable widgets placed at the top level (`lib/tiles/`) for maximum reusability across screens, while features handle screen-specific logic and composition.

## Current Implementation Status

**IMPORTANT**: This document describes both the **current state** and **planned architecture** of the Nonna App. All core development components have been implemented.

### Current State (As of February 23, 2026)

All core development components are implemented: core infrastructure, tiles layer, features layer, navigation, offline-first support, and all 15 tile widgets:

```
nonna_app/
├── lib/
│   ├── core/                     # Shared across the entire app
│   │   ├── config/               # Environment configurations
│   │   ├── constants/            # App-wide constants
│   │   ├── contracts/            # Shared interfaces
│   │   ├── di/                   # Dependency injection (Riverpod providers)
│   │   ├── enums/                # Global enums
│   │   ├── examples/             # Example implementations
│   │   ├── exceptions/           # Custom exception classes
│   │   ├── extensions/           # Dart/Flutter extensions
│   │   ├── middleware/           # App-level middleware
│   │   ├── mixins/               # Reusable behaviors
│   │   ├── models/               # Shared domain models
│   │   ├── navigation/           # Context-free navigation service
│   │   ├── network/              # Supabase client and configuration
│   │   ├── providers/            # Global providers
│   │   ├── repositories/         # Shared repository contracts
│   │   ├── router/               # App navigation (GoRouter)
│   │   ├── services/             # Shared services
│   │   ├── themes/               # App-wide theming
│   │   ├── typedefs/             # Type aliases
│   │   ├── utils/                # Helper functions
│   │   └── widgets/              # Shared UI widgets
│   ├── features/                 # Screen-specific features
│   │   ├── auth/                 # Authentication feature
│   │   ├── baby_profile/         # Baby profile management
│   │   ├── calendar/             # Calendar feature
│   │   ├── gallery/              # Photo gallery feature
│   │   ├── gamification/         # Gamification (name suggestions, voting)
│   │   ├── home/                 # Home screen feature
│   │   ├── profile/              # User profile feature
│   │   ├── registry/             # Registry feature
│   │   └── settings/             # App settings feature
│   ├── flutter_gen/              # Generated code
│   ├── l10n/                     # Localization
│   │   ├── app_en.arb
│   │   ├── app_es.arb
│   │   └── l10n.dart
│   ├── main.dart
│   └── tiles/                    # Reusable tile widgets
│       ├── checklist/            # Checklist tiles
│       ├── core/                 # Shared tile infrastructure
│       ├── due_date_countdown/   # Due date countdown tile
│       ├── engagement_recap/     # Engagement recap tile
│       ├── gallery_favorites/    # Gallery favorites tile
│       ├── invites_status/       # Invites status tile
│       ├── new_followers/        # New followers tile
│       ├── notifications/        # Notifications tile
│       ├── recent_photos/        # Recent photos tile
│       ├── recent_purchases/     # Recent purchases tile
│       ├── registry_deals/       # Registry deals tile
│       ├── registry_highlights/  # Registry highlights tile
│       ├── rsvp_tasks/           # RSVP tasks tile
│       ├── storage_usage/        # Storage usage tile
│       ├── system_announcements/ # System announcements tile
│       └── upcoming_events/      # Upcoming events tile
├── test/                         # Comprehensive test coverage
│   ├── core/                     # Core layer tests
│   ├── features/                 # Feature layer tests
│   ├── tiles/                    # Tile layer tests
│   └── helpers/                  # Test helpers
├── docs/                         # Comprehensive documentation
├── supabase/                     # Supabase configuration and migrations
├── android/, ios/, linux/, macos/, windows/  # Platform-specific code
└── discovery/                    # Discovery phase documentation
```

**Current Development Status**: All core development components complete as of February 23, 2026.
- All 15 tile widgets implemented with providers and widget tests
- All feature screens implemented (auth, home, calendar, gallery, registry, profile, baby profile, gamification, settings)
- Navigation, offline-first, error boundaries, network failure handling all implemented
- Comprehensive test coverage across all layers

## Architecture Overview

- **Tiles as First-Class Citizens**: Tiles are self-contained, parameterized widgets with embedded query logic and consistent display formats. They live in `lib/tiles/` for easy access across all screens.
- **Role-Based Behavior**: Owners see editable tiles per baby; followers see aggregated, read-only tiles across all followed babies.
- **Dynamic Configuration**: TileFactory instantiates tiles based on Supabase configs (`tile_configs`, `screen_configs`), enabling runtime customization.
- **Modular Features**: Screen features (Home, Calendar, Gallery, etc.) focus on layout and composition, importing tiles as needed.
- **Supabase Backend**: All data fetching via Supabase with RLS for security, realtime subscriptions for updates.
- **Riverpod State Management**: Dependency injection and state sharing across tiles and features.

```sh
nonna_app/
├── docs/                     # Architecture docs, ADRs, technical requirements
│   ├── 01_discovery/
│   │   └── 04_technical_requirements/
│   │       ├── Technical_Requirements.md
│   │       └── Tile_System_Design.md
│   ├── adr/                  # Architecture Decision Records
│   │   ├── 0001-tile-based-architecture.md
│   │   ├── 0002-supabase-backend.md
│   │   └── 0003-riverpod-state-management.md
│   ├── architecture.md       # Overall architecture documentation
│   ├── testing.md           # Testing strategy
│   └── supabase_schema.md   # Database schema and RLS policies
├── .github/                  # GitHub templates and workflows
│   ├── workflows/
│   │   ├── ci.yml           # Flutter test, analyze, build
│   │   └── deploy.yml       # Deploy to stores
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── ISSUE_TEMPLATE/
├── supabase/                 # Supabase configuration
│   ├── migrations/          # Database migrations
│   ├── functions/           # Edge functions (e.g., /tile-configs)
│   ├── config.toml
│   └── seed.sql            # Seed data for development
├── config/                   # Environment files
│   ├── .env.example
│   ├── .env.dev
│   └── .env.prod
├── lib/
│   ├── l10n/                 # Localization
│   │   ├── app_en.arb
│   │   └── app_es.arb
│   ├── core/                     # Shared across the entire app
│   │   ├── models/               # Shared domain models
│   │   │   ├── user.dart
│   │   │   ├── baby_profile.dart
│   │   │   ├── event.dart
│   │   │   ├── photo.dart
│   │   │   ├── registry_item.dart
│   │   │   ├── notification.dart
│   │   │   ├── tile_config.dart
│   │   │   └── screen_config.dart
│   │   ├── repositories/         # Shared repository contracts
│   │   │   └── interfaces/       # Abstract contracts only
│   │   │       ├── auth_repository.dart
│   │   │       ├── user_repository.dart
│   │   │       ├── baby_profile_repository.dart
│   │   │       ├── tile_config_repository.dart
│   │   │       ├── event_repository.dart
│   │   │       ├── photo_repository.dart
│   │   │       ├── registry_repository.dart
│   │   │       └── notification_repository.dart
│   │   ├── network/              # Supabase client and configuration
│   │   │   ├── supabase_client.dart
│   │   │   ├── interceptors/
│   │   │   │   ├── auth_interceptor.dart
│   │   │   │   └── logging_interceptor.dart
│   │   │   └── endpoints/
│   │   │       ├── auth_endpoints.dart
│   │   │       ├── tile_endpoints.dart
│   │   │       ├── event_endpoints.dart
│   │   │       ├── photo_endpoints.dart
│   │   │       ├── registry_endpoints.dart
│   │   │       └── edge_functions.dart
│   │   ├── utils/                # Helper functions
│   │   │   ├── date_helpers.dart
│   │   │   ├── formatters.dart
│   │   │   ├── validators.dart
│   │   │   ├── image_helpers.dart
│   │   │   ├── role_helpers.dart
│   │   │   └── share_helpers.dart
│   │   ├── extensions/           # Dart/Flutter extensions
│   │   │   ├── string_extensions.dart
│   │   │   ├── context_extensions.dart
│   │   │   ├── date_extensions.dart
│   │   │   └── list_extensions.dart
│   │   ├── mixins/               # Reusable behaviors
│   │   │   ├── role_aware_mixin.dart      # For role-based logic
│   │   │   ├── validation_mixin.dart
│   │   │   └── loading_mixin.dart
│   │   ├── enums/                # Global enums
│   │   │   ├── user_role.dart             # owner, follower
│   │   │   ├── tile_type.dart             # upcoming_events, recent_photos, etc.
│   │   │   ├── screen_name.dart           # home, calendar, gallery, etc.
│   │   │   ├── notification_type.dart
│   │   │   └── event_status.dart
│   │   ├── typedefs/             # Type aliases
│   │   │   └── callbacks.dart
│   │   ├── contracts/            # Shared interfaces
│   │   │   ├── cacheable.dart
│   │   │   └── realtime_subscribable.dart
│   │   ├── di/                   # Dependency injection (Riverpod providers)
│   │   │   ├── providers.dart            # Global providers (auth, supabase)
│   │   │   └── service_locator.dart
│   │   ├── themes/               # App-wide theming
│   │   │   ├── app_theme.dart
│   │   │   ├── colors.dart
│   │   │   ├── text_styles.dart
│   │   │   └── tile_styles.dart          # Consistent tile styling
│   │   ├── config/               # Environment configurations
│   │   │   ├── app_config.dart
│   │   │   └── environment.dart
│   │   ├── constants/            # App-wide constants
│   │   │   ├── strings.dart
│   │   │   ├── supabase_tables.dart
│   │   │   └── performance_limits.dart   # Cache TTL, query limits
│   │   ├── services/             # Shared services
│   │   │   ├── supabase_service.dart     # Wrapper for Supabase operations
│   │   │   ├── cache_service.dart        # Hive/Isar caching
│   │   │   ├── storage_service.dart      # Supabase Storage for photos
│   │   │   ├── notification_service.dart # Push notifications
│   │   │   ├── realtime_service.dart     # Supabase realtime subscriptions
│   │   │   ├── realtime_subscription_manager.dart # Safe lifecycle management for realtime subscriptions
│   │   │   ├── analytics_service.dart    # Usage tracking
│   │   │   └── observability_service.dart # Sentry/logging
│   │   ├── middleware/           # App-level middleware
│   │   │   ├── error_handler.dart
│   │   │   ├── cache_manager.dart
│   │   │   └── rls_validator.dart        # Validate RLS policies
│   │   ├── exceptions/           # Custom exception classes
│   │   │   ├── app_exceptions.dart
│   │   │   ├── supabase_exceptions.dart
│   │   │   └── permission_exceptions.dart
│   │   ├── router/               # App navigation (GoRouter)
│   │   │   ├── app_router.dart
│   │   │   └── route_guards.dart         # Auth/role guards
│   │   └── widgets/              # Shared UI widgets
│   │       ├── loading_indicator.dart
│   │       ├── error_view.dart
│   │       ├── empty_state.dart
│   │       ├── custom_button.dart
│   │       └── shimmer_placeholder.dart
│   │
│   ├── tiles/                    # Reusable tile widgets (top-level for cross-screen use)
│   │   ├── core/                 # Shared tile infrastructure
│   │   │   ├── models/
│   │   │   │   ├── tile_config.dart      # Tile configuration model
│   │   │   │   ├── tile_params.dart      # Parameters for tile queries
│   │   │   │   └── tile_state.dart       # Common tile state (loading, error, data)
│   │   │   ├── widgets/
│   │   │   │   ├── tile_factory.dart     # Instantiates tiles based on configs
│   │   │   │   ├── base_tile.dart        # Abstract base for all tiles
│   │   │   │   └── tile_container.dart   # Common tile wrapper (padding, styling)
│   │   │   ├── providers/
│   │   │   │   ├── tile_config_provider.dart  # Fetches configs from Supabase
│   │   │   │   └── tile_visibility_provider.dart # Manages visibility flags
│   │   │   ├── data/
│   │   │   │   ├── repositories/
│   │   │   │   │   └── tile_config_repository_impl.dart
│   │   │   │   └── datasources/
│   │   │   │       ├── remote/
│   │   │   │       │   └── tile_config_remote_datasource.dart
│   │   │   │       └── local/
│   │   │   │           └── tile_config_cache.dart
│   │   │   └── test/
│   │   │       ├── tile_factory_test.dart
│   │   │       └── tile_config_provider_test.dart
│   │   │
│   │   ├── upcoming_events/      # Tile 1: Upcoming Events (Home, Calendar)
│   │   │   ├── models/
│   │   │   │   └── upcoming_event.dart
│   │   │   ├── providers/
│   │   │   │   └── upcoming_events_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── upcoming_events_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── upcoming_events_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── upcoming_event_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── upcoming_events_tile.dart        # Main tile widget
│   │   │   │   └── event_item_card.dart             # Individual event UI
│   │   │   └── test/
│   │   │       ├── upcoming_events_provider_test.dart
│   │   │       ├── upcoming_events_datasource_test.dart
│   │   │       └── upcoming_events_tile_test.dart
│   │   │
│   │   ├── recent_photos/        # Tile 2: Recent Photos (Home, Gallery)
│   │   │   ├── models/
│   │   │   │   └── recent_photo.dart
│   │   │   ├── providers/
│   │   │   │   └── recent_photos_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── recent_photos_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── recent_photos_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── recent_photo_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── recent_photos_tile.dart          # Main tile widget (grid layout)
│   │   │   │   └── photo_thumbnail.dart             # Photo grid item
│   │   │   └── test/
│   │   │       ├── recent_photos_provider_test.dart
│   │   │       └── recent_photos_tile_test.dart
│   │   │
│   │   ├── registry_highlights/  # Tile 3: Registry Highlights (Home, Registry)
│   │   │   ├── models/
│   │   │   │   └── registry_highlight.dart
│   │   │   ├── providers/
│   │   │   │   └── registry_highlights_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── registry_highlights_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── registry_highlights_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── registry_highlight_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── registry_highlights_tile.dart    # Main tile widget
│   │   │   │   └── registry_item_card.dart          # Individual item UI
│   │   │   └── test/
│   │   │       ├── registry_highlights_provider_test.dart
│   │   │       └── registry_highlights_tile_test.dart
│   │   │
│   │   ├── notifications/        # Tile 4: Notifications (Home)
│   │   │   ├── models/
│   │   │   │   └── notification_item.dart
│   │   │   ├── providers/
│   │   │   │   └── notifications_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── notifications_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── notifications_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── notification_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── notifications_tile.dart
│   │   │   │   └── notification_item_card.dart
│   │   │   └── test/
│   │   │       ├── notifications_provider_test.dart
│   │   │       └── notifications_tile_test.dart
│   │   │
│   │   ├── invites_status/       # Tile 5: Invitations Status (Home, owner-only)
│   │   │   ├── models/
│   │   │   │   └── invite_status.dart
│   │   │   ├── providers/
│   │   │   │   └── invites_status_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── invites_status_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── invites_status_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── invite_status_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── invites_status_tile.dart
│   │   │   │   └── invite_item_card.dart
│   │   │   └── test/
│   │   │       ├── invites_status_provider_test.dart
│   │   │       └── invites_status_tile_test.dart
│   │   │
│   │   ├── rsvp_tasks/           # Tile 6: RSVP Tasks (Home, Calendar)
│   │   │   ├── models/
│   │   │   │   └── rsvp_task.dart
│   │   │   ├── providers/
│   │   │   │   └── rsvp_tasks_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── rsvp_tasks_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── rsvp_tasks_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── rsvp_task_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── rsvp_tasks_tile.dart
│   │   │   │   └── rsvp_task_card.dart
│   │   │   └── test/
│   │   │       ├── rsvp_tasks_provider_test.dart
│   │   │       └── rsvp_tasks_tile_test.dart
│   │   │
│   │   ├── due_date_countdown/   # Tile 7: Due Date Countdown (Home)
│   │   │   ├── models/
│   │   │   │   └── due_date_countdown.dart
│   │   │   ├── providers/
│   │   │   │   └── due_date_countdown_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── due_date_countdown_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── due_date_countdown_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── due_date_countdown_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── due_date_countdown_tile.dart
│   │   │   │   └── countdown_display.dart
│   │   │   └── test/
│   │   │       ├── due_date_countdown_provider_test.dart
│   │   │       └── due_date_countdown_tile_test.dart
│   │   │
│   │   ├── recent_purchases/     # Tile 8: Recent Purchases (Home, Registry)
│   │   │   ├── models/
│   │   │   │   └── recent_purchase.dart
│   │   │   ├── providers/
│   │   │   │   └── recent_purchases_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── recent_purchases_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── recent_purchases_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── recent_purchase_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── recent_purchases_tile.dart
│   │   │   │   └── purchase_item_card.dart
│   │   │   └── test/
│   │   │       ├── recent_purchases_provider_test.dart
│   │   │       └── recent_purchases_tile_test.dart
│   │   │
│   │   ├── registry_deals/       # Tile 9: Registry Deals/Recommendations (Registry)
│   │   │   ├── models/
│   │   │   │   └── registry_deal.dart
│   │   │   ├── providers/
│   │   │   │   └── registry_deals_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── registry_deals_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── registry_deals_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── registry_deal_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── registry_deals_tile.dart
│   │   │   │   └── deal_item_card.dart
│   │   │   └── test/
│   │   │       ├── registry_deals_provider_test.dart
│   │   │       └── registry_deals_tile_test.dart
│   │   │
│   │   ├── engagement_recap/     # Tile 10: Engagement Recap (Home)
│   │   │   ├── models/
│   │   │   │   └── engagement_recap.dart
│   │   │   ├── providers/
│   │   │   │   └── engagement_recap_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── engagement_recap_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── engagement_recap_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── engagement_recap_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── engagement_recap_tile.dart
│   │   │   │   └── recap_item_card.dart
│   │   │   └── test/
│   │   │       ├── engagement_recap_provider_test.dart
│   │   │       └── engagement_recap_tile_test.dart
│   │   │
│   │   ├── gallery_favorites/    # Tile 11: Gallery Favorites (Gallery)
│   │   │   ├── models/
│   │   │   │   └── gallery_favorite.dart
│   │   │   ├── providers/
│   │   │   │   └── gallery_favorites_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── gallery_favorites_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── gallery_favorites_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── gallery_favorite_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── gallery_favorites_tile.dart
│   │   │   │   └── favorite_photo_card.dart
│   │   │   └── test/
│   │   │       ├── gallery_favorites_provider_test.dart
│   │   │       └── gallery_favorites_tile_test.dart
│   │   │
│   │   ├── checklist/            # Tile 12: Checklist/Onboarding (Home, owner-only)
│   │   │   ├── models/
│   │   │   │   └── checklist_item.dart
│   │   │   ├── providers/
│   │   │   │   └── checklist_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── checklist_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── checklist_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── checklist_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── checklist_tile.dart
│   │   │   │   └── checklist_item_card.dart
│   │   │   └── test/
│   │   │       ├── checklist_provider_test.dart
│   │   │       └── checklist_tile_test.dart
│   │   │
│   │   ├── storage_usage/        # Tile 13: Storage Usage (Home, owner-only)
│   │   │   ├── models/
│   │   │   │   └── storage_usage.dart
│   │   │   ├── providers/
│   │   │   │   └── storage_usage_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── storage_usage_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── storage_usage_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── storage_usage_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── storage_usage_tile.dart
│   │   │   │   └── usage_display.dart
│   │   │   └── test/
│   │   │       ├── storage_usage_provider_test.dart
│   │   │       └── storage_usage_tile_test.dart
│   │   │
│   │   ├── system_announcements/ # Tile 14: System Announcements (Global)
│   │   │   ├── models/
│   │   │   │   └── system_announcement.dart
│   │   │   ├── providers/
│   │   │   │   └── system_announcements_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── system_announcements_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── system_announcements_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── system_announcement_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── system_announcements_tile.dart
│   │   │   │   └── announcement_card.dart
│   │   │   └── test/
│   │   │       ├── system_announcements_provider_test.dart
│   │   │       └── system_announcements_tile_test.dart
│   │   │
│   │   └── new_followers/        # Tile 15: New Followers (Home, owner-only)
│   │       ├── models/
│   │   │   │   └── new_follower.dart
│   │   │   ├── providers/
│   │   │   │   └── new_followers_provider.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── new_followers_datasource.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── new_followers_cache.dart
│   │   │   │   └── mappers/
│   │   │   │       └── new_follower_mapper.dart
│   │   │   ├── widgets/
│   │   │   │   ├── new_followers_tile.dart
│   │   │   │   └── follower_card.dart
│   │   │   └── test/
│   │   │       ├── new_followers_provider_test.dart
│   │   │       └── new_followers_tile_test.dart
│   │
│   ├── features/             # Screen features (composition & navigation)
│   │   ├── auth/
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   ├── auth_provider.dart
│   │   │   │   │   └── auth_state.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── login_screen.dart
│   │   │   │   │   ├── signup_screen.dart
│   │   │   │   │   └── role_selection_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── auth_form_widgets.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── auth_response_dto.dart
│   │   │   │   ├── mappers/
│   │   │   │   │   └── auth_mapper.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository_impl.dart
│   │   │   │   └── datasources/
│   │   │   │       ├── remote/
│   │   │   │       │   └── auth_remote_datasource.dart
│   │   │   │       └── local/
│   │   │   │           └── auth_local_datasource.dart
│   │   │   ├── domain/
│   │   │   │   ├── use_cases/
│   │   │   │   │   ├── login_use_case.dart
│   │   │   │   │   ├── signup_use_case.dart
│   │   │   │   │   └── logout_use_case.dart
│   │   │   │   └── entities/
│   │   │   │       └── user_entity.dart
│   │   │   └── test/
│   │   │       ├── auth_provider_test.dart
│   │   │       ├── login_use_case_test.dart
│   │   │       └── auth_screen_test.dart
│   │   │
│   │   ├── home/                 # Home screen (composes tiles)
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   └── home_screen_provider.dart    # Fetches tile configs for home
│   │   │   │   ├── screens/
│   │   │   │   │   └── home_screen.dart             # Renders tiles via TileFactory
│   │   │   │   └── widgets/
│   │   │   │       ├── home_app_bar.dart
│   │   │   │       └── tile_list_view.dart          # ListView for tiles
│   │   │   └── test/
│   │   │       └── home_screen_test.dart
│   │   │
│   │   ├── calendar/             # Calendar screen (composes tiles + calendar widget)
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   └── calendar_screen_provider.dart
│   │   │   │   ├── screens/
│   │   │   │   │   └── calendar_screen.dart         # Renders tiles + calendar widget
│   │   │   │   └── widgets/
│   │   │   │       └── calendar_widget.dart
│   │   │   └── test/
│   │   │       └── calendar_screen_test.dart
│   │   │
│   │   ├── gallery/              # Gallery screen (composes tiles + photo grid)
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   └── gallery_screen_provider.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── gallery_screen.dart
│   │   │   │   │   └── photo_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── squish_photo_widget.dart
│   │   │   └── test/
│   │   │       └── gallery_screen_test.dart
│   │   │
│   │   ├── registry/             # Registry screen (composes tiles + filters)
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   └── registry_screen_provider.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── registry_screen.dart
│   │   │   │   │   └── registry_item_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── registry_filter_bar.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── registry_item_dto.dart
│   │   │   │   ├── mappers/
│   │   │   │   ├── repositories/
│   │   │   │   │   └── registry_repository_impl.dart
│   │   │   │   └── datasources/
│   │   │   │       ├── remote/
│   │   │   │       │   └── registry_remote_datasource.dart
│   │   │   │       └── local/
│   │   │   │           └── registry_cache.dart
│   │   │   ├── domain/
│   │   │   │   ├── use_cases/
│   │   │   │   │   ├── get_registry_items.dart
│   │   │   │   │   └── purchase_item.dart
│   │   │   │   └── entities/
│   │   │   │       └── registry_item_entity.dart
│   │   │   └── test/
│   │   │       ├── registry_repository_impl_test.dart
│   │   │       ├── get_registry_items_test.dart
│   │   │       └── registry_screen_test.dart
│   │   │
│   │   ├── gamification/         # Gamification (name suggestions, voting)
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   └── gamification_provider.dart
│   │   │   │   └── screens/
│   │   │   │       └── gamification_screen.dart
│   │   │   └── test/
│   │   │       └── gamification_screen_test.dart
│   │   │
│   │   ├── settings/             # App settings
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   └── settings_provider.dart
│   │   │   │   └── screens/
│   │   │   │       └── settings_screen.dart
│   │   │   └── test/
│   │   │       └── settings_screen_test.dart
│   │   │
│   │   ├── profile/              # User profile management
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   └── profile_provider.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── profile_screen.dart
│   │   │   │   │   └── edit_profile_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── profile_widgets.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── profile_dto.dart
│   │   │   │   ├── mappers/
│   │   │   │   ├── repositories/
│   │   │   │   │   └── profile_repository_impl.dart
│   │   │   │   └── datasources/
│   │   │   │       ├── remote/
│   │   │   │       │   └── profile_remote_datasource.dart
│   │   │   │       └── local/
│   │   │   │           └── profile_cache.dart
│   │   │   ├── domain/
│   │   │   │   ├── use_cases/
│   │   │   │   │   ├── update_profile.dart
│   │   │   │   │   └── get_profile.dart
│   │   │   │   └── entities/
│   │   │   │       └── profile_entity.dart
│   │   │   └── test/
│   │   │       ├── profile_provider_test.dart
│   │   │       └── profile_screen_test.dart
│   │   │
│   │   └── baby_profile/         # Baby profile management
│   │       ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   └── baby_profile_provider.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── baby_profile_screen.dart
│   │   │   │   │   ├── create_baby_profile_screen.dart
│   │   │   │   │   ├── edit_baby_profile_screen.dart
│   │   │   │   │   ├── invite_followers_screen.dart
│   │   │   │   │   └── followers_management_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── baby_profile_widgets.dart
│   │
│   ├── main.dart                 # App entry point
│
├── test/                         # Unit & widget tests
│   ├── mocks/                    # Shared mock implementations
│   │   ├── mock_supabase_client.dart
│   │   ├── mock_repositories.dart
│   │   └── mock_datasources.dart
│   ├── fixtures/                 # Test data
│   │   ├── tile_configs.json
│   │   ├── events.json
│   │   ├── photos.json
│   │   └── baby_profiles.json
│   ├── helpers/                  # Test utilities
│   │   ├── test_helpers.dart
│   │   ├── riverpod_test_helpers.dart
│   │   └── pump_app.dart
│   ├── core/
│   │   ├── models/
│   │   ├── services/
│   │   └── utils/
│   ├── tiles/                    # Mirror tile structure
│   │   ├── core/
│   │   ├── upcoming_events/
│   │   ├── recent_photos/
│   │   └── ...
│   └── features/                 # Mirror feature structure
│       ├── auth/
│       ├── home/
│       ├── calendar/
│       └── ...
│
├── integration_test/             # Full app integration tests
│   ├── app_flow_test.dart        # Complete user journeys
│   ├── owner_flow_test.dart      # Owner-specific flows
│   ├── follower_flow_test.dart   # Follower-specific flows
│   └── tile_interaction_test.dart
│
├── assets/                       # Static resources
│   ├── images/
│   │   ├── icons/
│   │   ├── placeholders/
│   │   └── onboarding/
│   ├── fonts/
│   └── animations/               # Lottie/Rive animations
│
├── l10n/                         # Localization files
│   ├── app_en.arb
│   └── app_es.arb
│
├── scripts/                      # Build and deployment scripts
│   ├── build.sh
│   ├── deploy.sh
│   ├── code_generation.sh        # Run build_runner
│   └── supabase_migrate.sh       # Run Supabase migrations
│
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── .gitignore
```

---

## How It All Works Together

### 1. **App Launch and Initialization**
   - `main.dart` initializes Supabase client, Riverpod providers, and cache service.
   - Auth state is restored from cache; if valid, user navigates to Home; otherwise, Login screen.
   - TileConfigProvider fetches tile configs for the user's role from Supabase (with cache-first strategy).

### 2. **Screen Rendering with Tiles**
   - **User opens Home screen** → `home_screen.dart` calls `HomeScreenProvider`.
   - Provider fetches screen config from Supabase (e.g., `screen_configs` table filtered by `screen_name='home'` and `role`).
   - Screen config returns tile IDs and order (e.g., `['upcoming_events', 'recent_photos', 'notifications']`).
   - TileFactory instantiates tiles based on IDs, passing parameters (`role`, `babyIds`, `limit`).
   - Each tile executes its own query via its provider/datasource, fetching data from Supabase or cache.
   - Tiles render in a `ListView` with consistent styling from `tile_container.dart`.

### 3. **Tile Data Flow (Example: Upcoming Events Tile)**
   ```
   ┌─────────────────────────────────────────────────────────────────┐
   │ 1. HOME SCREEN REQUESTS TILE                                    │
   │    Location: features/home/presentation/screens/home_screen.dart│
   │    Action: TileFactory.create('upcoming_events', params)        │
   └────────────────────────────┬────────────────────────────────────┘
                                ↓
   ┌─────────────────────────────────────────────────────────────────┐
   │ 2. TILEFACTORY INSTANTIATES TILE                                │
   │    Location: tiles/core/widgets/tile_factory.dart               │
   │    Action: return UpcomingEventsTile(params: params)            │
   └────────────────────────────┬────────────────────────────────────┘
                                ↓
   ┌─────────────────────────────────────────────────────────────────┐
   │ 3. TILE WIDGET BUILDS WITH PROVIDER                             │
   │    Location: tiles/upcoming_events/widgets/upcoming_events_tile.dart│
   │    Action: ref.watch(upcomingEventsProvider(params))            │
   └────────────────────────────┬────────────────────────────────────┘
                                ↓
   ┌─────────────────────────────────────────────────────────────────┐
   │ 4. PROVIDER FETCHES DATA                                        │
   │    Location: tiles/upcoming_events/providers/upcoming_events_provider.dart│
   │    Strategy:                                                     │
   │    - Check cache via UpcomingEventsCache                        │
   │    - If stale/missing, query Supabase via RemoteDatasource     │
   │    - For owners: SELECT * FROM events WHERE baby_id = ?         │
   │    - For followers: SELECT * FROM events WHERE baby_id IN (?)   │
   │      (aggregates across all followed babies)                    │
   └────────────────────────────┬────────────────────────────────────┘
                                ↓
   ┌─────────────────────────────────────────────────────────────────┐
   │ 5. DATASOURCE QUERIES SUPABASE                                  │
   │    Location: tiles/upcoming_events/data/datasources/remote/     │
   │    Action: supabaseClient.from('events').select()...            │
   │    Returns: List<Map<String, dynamic>> (DTOs)                   │
   └────────────────────────────┬────────────────────────────────────┘
                                ↓
   ┌─────────────────────────────────────────────────────────────────┐
   │ 6. MAPPER CONVERTS DTO TO ENTITY                                │
   │    Location: tiles/upcoming_events/data/mappers/                │
   │    Action: UpcomingEventMapper.fromDto(dto)                     │
   │    Returns: UpcomingEvent entity                                │
   └────────────────────────────┬────────────────────────────────────┘
                                ↓
   ┌─────────────────────────────────────────────────────────────────┐
   │ 7. PROVIDER UPDATES STATE & CACHES DATA                         │
   │    Location: upcoming_events_provider.dart                      │
   │    Action: state = AsyncData(events); cache.save(events)        │
   └────────────────────────────┬────────────────────────────────────┘
                                ↓
   ┌─────────────────────────────────────────────────────────────────┐
   │ 8. TILE WIDGET REBUILDS WITH DATA                               │
   │    Location: upcoming_events_tile.dart                          │
   │    Action: Render events in list/card format                    │
   └─────────────────────────────────────────────────────────────────┘
   ```

### 4. **Role-Based Behavior**
   - **Owners**:
     - Tiles query data per baby (passed via `babyIds` param).
     - See editable controls (e.g., add event, upload photo).
     - Subscribe to realtime updates for their babies via `RealtimeService`.
   - **Followers**:
     - Tiles query data across all followed babies (from `user_followers` table).
     - See read-only content with interaction options (RSVP, like, comment).
     - Subscribe to per-user channel for aggregated updates.

### 5. **Realtime Updates**
   - Owners: Subscribe to `events` table filtered by `baby_id`.
   - Followers: Subscribe to custom channel broadcasting max timestamp across followed babies.
   - On update: Provider invalidates cache, refetches data, tile rebuilds.

### 6. **Performance Optimizations**
   - **Cache-First Strategy**: Tiles load from cache instantly; background refresh if stale.
   - **Lazy Loading**: `ListView.builder` with pagination for large tile lists.
   - **Image Optimization**: Thumbnails cached via `CachedNetworkImage`, preloaded for smooth scrolling.
   - **Riverpod `keepAlive`**: Tile state persists across navigation to avoid refetching.

### 7. **Testing Strategy**
   - **Tile Unit Tests**: Mock datasources, test provider logic, verify query parameters.
   - **Tile Widget Tests**: Test UI rendering with mocked state (loading, error, data).
   - **Feature Integration Tests**: Test screen composition with real TileFactory.
   - **End-to-End Tests**: Validate full flows (owner adds event → follower sees update).

---

## Key Design Decisions

### Why Tiles at Top Level (`lib/tiles/`)?
- **Reusability**: Same tile (e.g., `UpcomingEventsTile`) used on Home, Calendar, and other screens without duplication.
- **Clarity**: Emphasizes tiles as first-class, parameterized widgets, not nested features.
- **Simplicity**: Easier imports (`import 'package:nonna_app/tiles/upcoming_events/widgets/upcoming_events_tile.dart'`).
- **Modularity**: Each tile is self-contained with its own data layer, testable independently.

### Why Separate Features for Screens?
- **Composition**: Screens focus on layout and orchestration, importing tiles as needed.
- **Screen-Specific Logic**: Some features (e.g., Registry, Gallery) have complex logic beyond tiles (filters, search).
- **Navigation**: Screen features handle routing and deep linking.

### Tile vs Feature Data Layer
- **Tiles**: Lightweight, focused on single data entity (e.g., events, photos). Use simple datasources and providers.
- **Features**: May have complex domain logic (e.g., purchase flow in Registry). Use full repository/use case pattern.

---

## Database Changes and Impact

### If a Tile's Data Structure Changes (e.g., adding `location` to events)

**Localized Updates (Tile-Specific)**:
1. **Supabase Migration**: Add column to `events` table.
2. **Tile Data Layer**:
   - Update `tiles/upcoming_events/models/upcoming_event.dart` (add `location` field).
   - Update `tiles/upcoming_events/data/mappers/upcoming_event_mapper.dart` (map new field).
   - Update `tiles/upcoming_events/data/datasources/remote/upcoming_events_datasource.dart` (select `location`).
3. **Tile Widget**: Update `upcoming_events_tile.dart` to display location.
4. **Tests**: Update fixtures and tests for new field.

**Other Tiles/Features**: Unaffected unless they also query `events` table.

### If a Core Model Changes (e.g., `User` model adds `phoneNumber`)

**Cross-Feature Updates**:
1. **Supabase Migration**: Add column to `users` table.
2. **Core Model**: Update `core/models/user.dart`.
3. **Affected Features**: Update `auth` and `profile` features:
   - Update DTOs, mappers, datasources in both features.
   - Update providers and UI if displaying phone number.
4. **Tiles**: Unaffected unless tiles display user info (e.g., Engagement Recap).

### If a Tile Config Changes (e.g., adding `refresh_interval` param)

**Minimal Impact**:
1. **Supabase Migration**: Add column to `tile_configs` table.
2. **Tile Core**: Update `tiles/core/models/tile_config.dart`.
3. **TileFactory**: Update to pass new param to tiles.
4. **Individual Tiles**: Optionally use param in providers (e.g., set cache TTL).

**Benefit of Tile Architecture**: Most changes are isolated to tile folders. Cross-tile changes are rare.

---

## FAQ

### Q: How do I add a new tile?
**A**:
1. Create folder under `lib/tiles/` (e.g., `new_tile/`).
2. Add `models/`, `providers/`, `data/`, `widgets/`.
3. Implement datasource with Supabase query.
4. Create widget extending `BaseTile`.
5. Update `TileFactory` to handle new tile type.
6. Add tile to Supabase `tile_configs` table.
7. Write tests mirroring structure in `test/tiles/`.

### Q: Can the same tile have different queries for different screens?
**A**: Yes, via parameters. Example:
- Home: `UpcomingEventsTile(limit: 3, filterByDate: true)`
- Calendar: `UpcomingEventsTile(limit: 10, filterByDate: false)`
- Same widget, same query logic, different params.

### Q: How do tiles handle role-based logic?
**A**: Via `role` param passed from TileFactory. Datasources adjust queries:
```dart
if (params.role == UserRole.owner) {
  query = query.eq('baby_id', params.babyIds.first);
} else {
  query = query.in_('baby_id', params.babyIds); // Aggregate across followed babies
}
```

### Q: How do I test a tile independently?
**A**:
1. Mock datasource in `test/tiles/tile_name/`.
2. Test provider logic with mocked data.
3. Test widget with `ProviderScope` and mocked provider.
4. Example:
```dart
test('should load events for owner', () async {
  final container = ProviderContainer(
    overrides: [
      upcomingEventsProvider.overrideWith((ref) => mockProvider),
    ],
  );
  final events = await container.read(upcomingEventsProvider(params).future);
  expect(events.length, 3);
});
```

### Q: How do screens know which tiles to display?
**A**: Via Supabase `screen_configs` table:
- Columns: `screen_name` ('home', 'calendar'), `role`, `tile_ids` (array).
- Home screen fetches config, gets tile IDs, passes to TileFactory.

### Q: How do I handle caching for tiles?
**A**: Each tile datasource has local cache:
- Check cache in provider: `cache.get(params)`.
- If stale (> TTL), query Supabase, update cache.
- Use Hive/Isar for fast local storage.

### Q: What happens if a tile query is slow?
**A**:
- Show shimmer placeholder via `tile_state` (loading).
- Optimize Supabase query (indexes, RLS).
- Implement pagination for large datasets.
- Monitor via `ObservabilityService`.

### Q: Can tiles communicate with each other?
**A**: Generally no (self-contained). But:
- Share data via global Riverpod providers if needed.
- Use events/streams for cross-tile updates (e.g., photo upload triggers Recent Photos tile refresh).

---

## Critical Implementation Checklist

### Architecture Setup
- [ ] Initialize Supabase project with tables (`tile_configs`, `screen_configs`, `events`, `photos`, etc.)
- [ ] Set up RLS policies for all tables (owners can edit, followers can read)
- [ ] Configure Riverpod providers in `core/di/`
- [ ] Implement TileFactory with initial tile types
- [ ] Set up cache service (Hive/Isar)
- [ ] Configure realtime subscriptions for owners and followers

### Core Development
- [ ] Implement Supabase client wrapper (`core/network/supabase_client.dart`)
- [ ] Create base tile classes (`tiles/core/widgets/base_tile.dart`, `tile_container.dart`)
- [ ] Build TileConfigProvider to fetch configs from Supabase
- [ ] Implement role-based routing guards
- [ ] Set up error handling and logging

### Tile Development (Priority Order)
- [ ] Tile 1: Upcoming Events (most common, cross-screen)
- [ ] Tile 2: Recent Photos (high engagement)
- [ ] Tile 3: Registry Highlights (business-critical)
- [ ] Tile 4: Notifications (user engagement)
- [ ] Tiles 5-13: Implement based on priority

### Feature Development
- [ ] Auth feature (login, signup, role selection)
- [ ] Home screen (tile composition)
- [ ] Calendar screen (tiles + calendar widget)
- [ ] Gallery screen (tiles + photo grid)
- [ ] Registry screen (tiles + filters)
- [ ] Profile features (user, baby profiles)

### Testing
- [ ] Unit tests for each tile's provider and datasource
- [ ] Widget tests for tile UI
- [ ] Integration tests for screen composition
- [ ] E2E tests for owner and follower flows
- [ ] Performance tests (load times, scrolling)

### Performance
- [ ] Implement caching for all tiles
- [ ] Optimize Supabase queries (indexes, select specific columns)
- [ ] Implement lazy loading and pagination
- [ ] Precache images and thumbnails
- [ ] Set up monitoring (Sentry, Analytics)

### Documentation
- [ ] Document tile architecture in `docs/architecture.md`
- [ ] Create ADRs for major decisions
- [ ] Write tile development guide
- [ ] Document Supabase schema and RLS policies
- [ ] Update README with setup instructions

---

## Quick Start Guide

### 1. Clone and Setup
```bash
git clone <repo-url>
cd nonna_app
flutter pub get
```

### 2. Configure Supabase
```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Initialize and link to project
supabase init
supabase link --project-ref <your-project-ref>

# Run migrations
supabase db push
```

### 3. Set Up Environment
```bash
cp config/.env.example config/.env.dev
# Edit .env.dev with Supabase URL and anon key
```

### 4. Run Code Generation
```bash
./scripts/code_generation.sh
```

### 5. Run App
```bash
flutter run --dart-define-from-file=config/.env.dev
```

### 6. Create a New Tile
```bash
# Example: Creating "Activity Feed" tile
mkdir -p lib/tiles/activity_feed/{models,providers,data/{datasources/{remote,local},mappers},widgets}
mkdir -p test/tiles/activity_feed

# Follow tile template structure
# Update TileFactory to register new tile
# Add config to Supabase tile_configs table
```

---

## Best Practices

### Tile Development
- **Keep Queries Simple**: One tile, one primary query. Complex joins should be in Supabase views.
- **Parameterize Everything**: Role, baby IDs, limits—all via params, not hardcoded.
- **Cache Aggressively**: Default TTL 5 minutes for tiles, 1 hour for configs.
- **Test Thoroughly**: Unit tests for datasources, widget tests for UI, integration tests for flows.

### Performance
- **Optimize Queries**: Use indexes, select only needed columns, paginate large datasets.
- **Lazy Load**: Use `ListView.builder`, not `ListView` with all tiles at once.
- **Monitor**: Track query times, cache hit rates, error rates via observability service.

### Code Quality
- **Consistent Naming**: `TileName` + `Provider`/`Datasource`/`Tile` (e.g., `UpcomingEventsProvider`).
- **Follow Structure**: Every tile has same folder structure—no exceptions.
- **Document**: Add comments for complex queries or business logic.

### Collaboration
- **Tile Ownership**: Assign tiles to developers; they own tests and updates.
- **Code Reviews**: Focus on query efficiency, RLS compliance, and test coverage.
- **ADRs**: Document architectural decisions in `docs/adr/`.

---

This structure ensures the Nonna app is scalable, maintainable, and performant, with tiles as reusable building blocks for dynamic, role-driven UIs. 🚀
