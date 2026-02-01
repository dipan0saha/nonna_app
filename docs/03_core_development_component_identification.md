# Core Development Component Identification (Section 3)

**Document Version**: 1.0  
**Created**: February 1, 2026  
**Status**: Active  
**Purpose**: Comprehensive component list and architectural map for Production Readiness Checklist Section 3

---

## Executive Summary

This document provides a complete inventory of all components that must be developed for Section 3 (Core Development) of the Production Readiness Checklist. It includes:

1. **Detailed component definitions** with functionalities
2. **Exact folder locations** within the app directory structure
3. **Architectural rationale** for component placement
4. **Dependencies and relationships** between components
5. **Implementation priorities** and sequencing

The Nonna App follows a **dynamic tile-based architecture** with role-driven content (owner vs. follower), Supabase backend integration, and Riverpod state management. All components are organized following Clean Architecture principles with clear separation of concerns.

---

## Table of Contents

- [1. Document Dependencies](#1-document-dependencies)
- [2. Architectural Overview](#2-architectural-overview)
- [3. Component Identification by Subsection](#3-component-identification-by-subsection)
  - [3.1 Models Development](#31-models-development)
  - [3.2 Services Implementation](#32-services-implementation)
  - [3.3 Utils & Helpers](#33-utils--helpers)
  - [3.4 Theme & Styling](#34-theme--styling)
  - [3.5 State Management (Providers)](#35-state-management-providers)
  - [3.6 UI Development (Screens)](#36-ui-development-screens)
- [4. Complete Component Directory Map](#4-complete-component-directory-map)
- [5. Implementation Sequence](#5-implementation-sequence)
- [6. Testing Requirements](#6-testing-requirements)

---

## 1. Document Dependencies

This document was created by referencing the following mandatory documents per the Document Dependency Matrix:

### Primary References:
1. **Production_Readiness_Checklist.md** - Section 3: Core Development requirements
2. **App_Structure_Nonna.md** - Complete application structure and architecture
3. **Document_Dependency_Matrix.md** - Input dependencies and creation order

### Secondary References (from docs/):
4. **01_technical_requirements/data_model_diagram.md** - 28 data models and relationships
5. **01_technical_requirements/functional_requirements_specification.md** - Feature requirements and tile functionality
6. **01_technical_requirements/non_functional_requirements_specification.md** - Performance, security, and quality requirements
7. **01_technical_requirements/api_integration_plan.md** - Supabase integration specifications
8. **01_technical_requirements/performance_scalability_targets.md** - Performance benchmarks
9. **02_architecture_design/system_architecture_diagram.md** - High-level system design
10. **02_architecture_design/state_management_design.md** - Riverpod state management approach
11. **02_architecture_design/folder_structure_code_organization.md** - Code organization patterns
12. **02_architecture_design/database_schema_design.md** - Database schema and RLS policies
13. **02_architecture_design/security_privacy_architecture.md** - Security requirements
14. **00_requirement_gathering/user_personas_document.md** - Target users (owners, followers)
15. **00_requirement_gathering/user_journey_maps.md** - User workflows and interactions

---

## 2. Architectural Overview

### 2.1 Application Structure Philosophy

The Nonna App architecture is organized into three primary layers:

1. **Core Layer** (`lib/core/`): Shared infrastructure used across the entire application
2. **Tiles Layer** (`lib/tiles/`): Reusable, self-contained tile widgets (first-class citizens)
3. **Features Layer** (`lib/features/`): Screen-specific features that compose tiles and handle navigation

### 2.2 Key Architectural Principles

- **Tiles as First-Class Citizens**: Tiles live at the top level for maximum reusability across screens
- **Role-Based Behavior**: All components respect owner/follower roles enforced by Supabase RLS
- **Dynamic Configuration**: TileFactory instantiates tiles based on Supabase configurations
- **Offline-First**: Local caching (Hive/Isar) with real-time synchronization
- **Clean Architecture**: Domain/Data/Presentation separation within each feature
- **Riverpod State Management**: Dependency injection and reactive state

### 2.3 Performance Targets

All components must meet these requirements:
- **Screen Load**: <500ms
- **Per-Tile Fetch**: <300ms
- **Real-Time Updates**: <2 seconds
- **Notification Delivery**: <30 seconds
- **Code Coverage**: ≥80%

---

## 3. Component Identification by Subsection


## 3.1 Models Development

**Checklist Reference**: Section 3.1 - Models Development  
**Dependencies**: Data Model Diagram, Database Schema Design, Functional Requirements Specification

### Overview

Models represent the core data structures and business entities. The Nonna App requires 28 data models corresponding to database tables, organized by domain.

### Components List

#### 3.1.1 User Identity Models

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **User Profile Model** | `lib/core/models/user.dart` | User profile data (user_id, display_name, avatar_url, biometric_enabled); JSON serialization (fromJson/toJson); validation logic; equals/hashCode override | auth.users reference |
| **User Stats Model** | `lib/core/models/user_stats.dart` | Gamification counters (events_attended_count, items_purchased_count, photos_squished_count, comments_added_count); read-only model; fromJson deserialization | profiles model |

**Test Files**:
- `test/core/models/user_test.dart`
- `test/core/models/user_stats_test.dart`

---

#### 3.1.2 Baby Profile Models

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Baby Profile Model** | `lib/core/models/baby_profile.dart` | Baby profile data (id, name, default_last_name_source, profile_photo_url, expected_birth_date, actual_birth_date, gender); soft delete support (deleted_at); JSON serialization; validation (name required, dates logical) | None |
| **Baby Membership Model** | `lib/core/models/baby_membership.dart` | Role association (baby_profile_id, user_id, role enum [owner/follower], relationship_label); membership status (removed_at); validation (max 2 owners); JSON serialization | baby_profile, user |
| **Invitation Model** | `lib/core/models/invitation.dart` | Invitation lifecycle (baby_profile_id, invited_by_user_id, invitee_email, token_hash, expires_at, status enum [pending/accepted/revoked/expired]); validation (7-day expiration, status transitions); JSON serialization | baby_profile, user |

**Test Files**:
- `test/core/models/baby_profile_test.dart`
- `test/core/models/baby_membership_test.dart`
- `test/core/models/invitation_test.dart`

---

#### 3.1.3 Tile System Models

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Tile Config Model** | `lib/core/models/tile_config.dart` | Dynamic tile configuration (screen_id, tile_definition_id, role enum, display_order, is_visible, params JSONB); JSON serialization with type-safe params; validation (display_order ≥ 0) | screen, tile_definition |
| **Screen Config Model** | `lib/core/models/screen_config.dart` | Screen definitions (screen_name enum [home/calendar/gallery/registry/fun], description, is_active); JSON serialization; feature flag support | None |
| **Tile Definition Model** | `lib/tiles/core/models/tile_definition.dart` | Tile type catalog (tile_type enum, description, schema_params JSONB, is_active); matches TileFactory cases; JSON serialization | None |
| **Tile Params Model** | `lib/tiles/core/models/tile_params.dart` | Query parameters for tile data fetching (baby_profile_ids, date_range, limit, offset); immutable; copyWith support | None |
| **Tile State Model** | `lib/tiles/core/models/tile_state.dart` | Common tile state wrapper (loading/error/data/empty); generic type support; error details | None |

**Test Files**:
- `test/core/models/tile_config_test.dart`
- `test/core/models/screen_config_test.dart`
- `test/tiles/core/models/tile_definition_test.dart`
- `test/tiles/core/models/tile_params_test.dart`
- `test/tiles/core/models/tile_state_test.dart`

---

#### 3.1.4 Calendar & Events Models

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Event Model** | `lib/core/models/event.dart` | Event details (id, baby_profile_id, created_by_user_id, title, starts_at, ends_at, description, location, video_link, cover_photo_url); soft delete support; JSON serialization; validation (title required, starts_at < ends_at, max 2 events/day) | baby_profile, user |
| **Event RSVP Model** | `lib/core/models/event_rsvp.dart` | RSVP response (event_id, user_id, status enum [yes/no/maybe]); unique per user/event; JSON serialization | event, user |
| **Event Comment Model** | `lib/core/models/event_comment.dart` | Event comment (event_id, user_id, body, deleted_at, deleted_by_user_id); soft delete with moderation tracking; JSON serialization; validation (body required) | event, user |

**Test Files**:
- `test/core/models/event_test.dart`
- `test/core/models/event_rsvp_test.dart`
- `test/core/models/event_comment_test.dart`

---

#### 3.1.5 Registry Models

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Registry Item Model** | `lib/core/models/registry_item.dart` | Registry item (id, baby_profile_id, created_by_user_id, name, description, link_url, priority [1-5]); soft delete support; JSON serialization; validation (name required, priority 1-5) | baby_profile, user |
| **Registry Purchase Model** | `lib/core/models/registry_purchase.dart` | Purchase record (registry_item_id, purchased_by_user_id, purchased_at, note); immutable audit trail; JSON serialization | registry_item, user |

**Test Files**:
- `test/core/models/registry_item_test.dart`
- `test/core/models/registry_purchase_test.dart`

---

#### 3.1.6 Photo Gallery Models

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Photo Model** | `lib/core/models/photo.dart` | Photo metadata (id, baby_profile_id, uploaded_by_user_id, storage_path, thumbnail_path, caption, tags array); soft delete support; realtime updates; JSON serialization; validation (storage_path required, max 5 tags) | baby_profile, user |
| **Photo Squish Model** | `lib/core/models/photo_squish.dart` | Like/favorite (photo_id, user_id); unique per user/photo; JSON serialization; toggle support (can un-squish) | photo, user |
| **Photo Comment Model** | `lib/core/models/photo_comment.dart` | Photo comment (photo_id, user_id, body, deleted_at, deleted_by_user_id); soft delete with moderation tracking; JSON serialization; validation (body required) | photo, user |
| **Photo Tag Model** | `lib/core/models/photo_tag.dart` | Individual tag record (photo_id, tag); supports tag popularity queries; JSON serialization | photo |

**Test Files**:
- `test/core/models/photo_test.dart`
- `test/core/models/photo_squish_test.dart`
- `test/core/models/photo_comment_test.dart`
- `test/core/models/photo_tag_test.dart`

---

#### 3.1.7 Gamification Models

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Vote Model** | `lib/core/models/vote.dart` | Prediction vote (baby_profile_id, user_id, vote_type enum [gender/birthdate], value_text, value_date, is_anonymous); updateable before birth; JSON serialization | baby_profile, user |
| **Name Suggestion Model** | `lib/core/models/name_suggestion.dart` | Baby name suggestion (baby_profile_id, user_id, gender enum [male/female/unknown], suggested_name); soft delete support; realtime updates; JSON serialization | baby_profile, user |
| **Name Suggestion Like Model** | `lib/core/models/name_suggestion_like.dart` | Name vote (name_suggestion_id, user_id); unique per user/suggestion; realtime updates; JSON serialization; toggle support | name_suggestion, user |

**Test Files**:
- `test/core/models/vote_test.dart`
- `test/core/models/name_suggestion_test.dart`
- `test/core/models/name_suggestion_like_test.dart`

---

#### 3.1.8 Notifications & Activity Models

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Notification Model** | `lib/core/models/notification.dart` | Notification record (recipient_user_id, baby_profile_id, type, title, body, payload JSONB, read_at); realtime updates; deep-linking support; JSON serialization; never deleted (audit trail) | user, baby_profile |
| **Activity Event Model** | `lib/core/models/activity_event.dart` | Activity log entry (baby_profile_id, actor_user_id, type enum [photo_uploaded/comment_added/rsvp_yes/item_purchased/etc.], payload JSONB); realtime updates; JSON serialization; auto-created via triggers | baby_profile, user |

**Test Files**:
- `test/core/models/notification_test.dart`
- `test/core/models/activity_event_test.dart`

---

#### 3.1.9 Supporting Models

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Owner Update Marker Model** | `lib/core/models/owner_update_marker.dart` | Cache invalidation tracker (baby_profile_id, tiles_last_updated_at, updated_by_user_id, reason); 1:1 with baby_profile; JSON serialization | baby_profile, user |

**Test Files**:
- `test/core/models/owner_update_marker_test.dart`

---

### 3.1 Summary

**Total Components**: 28 data models + converters/factories  
**Total Test Files**: 28 unit test files  
**Primary Locations**: 
- `lib/core/models/` (27 core models)
- `lib/tiles/core/models/` (3 tile-specific models)

**Deliverables**:
- ✅ 28 Dart model classes with JSON serialization
- ✅ Validation logic for all constraints
- ✅ Model factories and converters for API integration
- ✅ Equals/hashCode overrides for value comparison
- ✅ 28 comprehensive unit test files (≥80% coverage)

---


## 3.2 Services Implementation

**Checklist Reference**: Section 3.2 - Services Implementation  
**Dependencies**: API Integration Plan, Database Schema Design, Security and Privacy Requirements Document

### Overview

Services handle data fetching, caching, third-party integrations, and business logic. This is the most extensive subsection with 14 major deliverables including RLS policy testing and real-time subscriptions.

### Components List

#### 3.2.1 Core Supabase Services

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Supabase Service** | `lib/core/services/supabase_service.dart` | Wrapper for Supabase operations; authenticated client management; connection pooling; error handling; RLS policy enforcement | supabase_flutter package |
| **Supabase Client** | `lib/core/network/supabase_client.dart` | Singleton Supabase client; initialization from environment config; auth interceptors; logging interceptors | supabase_flutter package |
| **Auth Service** | `lib/core/services/auth_service.dart` | Email/password authentication; OAuth 2.0 (Google, Facebook); JWT session management; password reset; biometric authentication; token refresh | Supabase Auth |
| **Database Service** | `lib/core/services/database_service.dart` | Query builder wrapper; typed query execution; transaction support; error mapping; pagination helpers | Supabase Database |
| **Storage Service** | `lib/core/services/storage_service.dart` | Supabase Storage operations; photo upload/download; thumbnail generation; presigned URLs; storage quota management; batch operations | Supabase Storage |

**Test Files**:
- `test/core/services/supabase_service_test.dart`
- `test/core/network/supabase_client_test.dart`
- `test/core/services/auth_service_test.dart`
- `test/core/services/database_service_test.dart`
- `test/core/services/storage_service_test.dart`

---

#### 3.2.2 Data Persistence Services

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Cache Service** | `lib/core/services/cache_service.dart` | Local caching using Hive/Isar; cache expiration (TTL); cache invalidation via owner_update_markers; offline data access; cache size management; background sync | hive/isar packages |
| **Local Storage Service** | `lib/core/services/local_storage_service.dart` | SharedPreferences wrapper; secure storage for sensitive data; user preferences; app settings; onboarding flags | shared_preferences, flutter_secure_storage |

**Test Files**:
- `test/core/services/cache_service_test.dart`
- `test/core/services/local_storage_service_test.dart`

---

#### 3.2.3 Real-Time & Notifications

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Realtime Service** | `lib/core/services/realtime_service.dart` | Supabase realtime subscriptions; role/baby-scoped channels; connection management; reconnection logic; batched updates; <2 second latency; subscription lifecycle management | Supabase Realtime |
| **Notification Service** | `lib/core/services/notification_service.dart` | OneSignal integration; push notification registration; notification payload handling; deep-linking; notification preferences; local notifications; badge count management | OneSignal SDK |

**Test Files**:
- `test/core/services/realtime_service_test.dart`
- `test/core/services/notification_service_test.dart`

---

#### 3.2.4 Monitoring & Analytics

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Analytics Service** | `lib/core/services/analytics_service.dart` | Usage tracking; event logging; user properties; screen tracking; custom events; A/B testing support; GDPR-compliant tracking | Firebase Analytics or similar |
| **Observability Service** | `lib/core/services/observability_service.dart` | Crash reporting (Sentry); error logging; performance monitoring; custom breadcrumbs; user context; release tracking | Sentry SDK |

**Test Files**:
- `test/core/services/analytics_service_test.dart`
- `test/core/services/observability_service_test.dart`

---

#### 3.2.5 Network Layer

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Auth Interceptor** | `lib/core/network/interceptors/auth_interceptor.dart` | JWT token injection; token refresh on 401; logout on persistent auth failures; request retry logic | None |
| **Logging Interceptor** | `lib/core/network/interceptors/logging_interceptor.dart` | Request/response logging; sensitive data redaction; performance metrics; debug mode only | None |

**Test Files**:
- `test/core/network/interceptors/auth_interceptor_test.dart`
- `test/core/network/interceptors/logging_interceptor_test.dart`

---

#### 3.2.6 Endpoint Definitions

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Auth Endpoints** | `lib/core/network/endpoints/auth_endpoints.dart` | Supabase Auth API endpoints; OAuth URLs; password reset URLs | None |
| **Tile Endpoints** | `lib/core/network/endpoints/tile_endpoints.dart` | Tile config queries; screen config queries; tile data endpoints | None |
| **Event Endpoints** | `lib/core/network/endpoints/event_endpoints.dart` | Event CRUD endpoints; RSVP endpoints; comment endpoints | None |
| **Photo Endpoints** | `lib/core/network/endpoints/photo_endpoints.dart` | Photo CRUD endpoints; squish endpoints; comment endpoints; tag queries | None |
| **Registry Endpoints** | `lib/core/network/endpoints/registry_endpoints.dart` | Registry item CRUD endpoints; purchase endpoints | None |
| **Edge Functions** | `lib/core/network/endpoints/edge_functions.dart` | Supabase Edge Function URLs; invocation helpers; payload builders | None |

**Test Files**:
- `test/core/network/endpoints/auth_endpoints_test.dart`
- `test/core/network/endpoints/tile_endpoints_test.dart`
- `test/core/network/endpoints/event_endpoints_test.dart`
- `test/core/network/endpoints/photo_endpoints_test.dart`
- `test/core/network/endpoints/registry_endpoints_test.dart`
- `test/core/network/endpoints/edge_functions_test.dart`

---

#### 3.2.7 Middleware

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Error Handler** | `lib/core/middleware/error_handler.dart` | Global error handling; error mapping (network/auth/validation); user-friendly error messages; retry strategies; error reporting to Sentry | None |
| **Cache Manager** | `lib/core/middleware/cache_manager.dart` | Cache strategy coordination; cache invalidation logic; background sync scheduling; cache warming; eviction policies | Cache Service |
| **RLS Validator** | `lib/core/middleware/rls_validator.dart` | Development-mode RLS policy validation; access denial logging; role simulation; permission testing | None |

**Test Files**:
- `test/core/middleware/error_handler_test.dart`
- `test/core/middleware/cache_manager_test.dart`
- `test/core/middleware/rls_validator_test.dart`

---

#### 3.2.8 Database Migrations

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Migration Scripts** | `supabase/migrations/` | SQL migration files; numbered sequentially; CREATE TABLE, ALTER TABLE, CREATE INDEX; trigger definitions; RLS policy definitions; rollback scripts | PostgreSQL |
| **Migration Strategy Document** | `docs/database_migration_strategy.md` | Migration workflow; rollback procedures; testing protocols; production deployment checklist; version control practices | N/A (Documentation) |

**Test Files**:
- Migration scripts tested via Supabase CLI and integration tests

---

#### 3.2.9 Force Update Mechanism

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Force Update Service** | `lib/core/services/force_update_service.dart` | Version checking against Supabase custom table or API; app version comparison; update prompt UI; App Store/Play Store deep links; bypass logic for development | Database Service |

**Test Files**:
- `test/core/services/force_update_service_test.dart`

---

#### 3.2.10 Data Backup & Recovery

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Backup Service** | `lib/core/services/backup_service.dart` | User data export (JSON format); photo backup to Supabase Storage; restore from backup; scheduled backups; GDPR data portability compliance | Storage Service, Database Service |
| **Data Export Handler** | `lib/core/services/data_export_handler.dart` | GDPR-compliant user data export; ZIP file generation; email delivery or download; includes all user-created content and metadata | Backup Service |
| **Data Deletion Handler** | `lib/core/services/data_deletion_handler.dart` | GDPR-compliant data deletion; hard delete user account; cascade deletion of user content; anonymization of historical records; confirmation workflow | Database Service |

**Test Files**:
- `test/core/services/backup_service_test.dart`
- `test/core/services/data_export_handler_test.dart`
- `test/core/services/data_deletion_handler_test.dart`

---

#### 3.2.11 RLS Policy Testing

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **RLS Test Suite (pgTAP)** | `supabase/tests/rls_policies/` | pgTAP test files for all 90+ RLS policies; owner/follower access tests; cross-baby isolation tests; permission boundary tests; edge case scenarios; CI integration | pgTAP extension |
| **RLS Test Documentation** | `docs/rls_testing_guide.md` | RLS testing methodology; test case templates; policy coverage matrix; test execution guide; troubleshooting | N/A (Documentation) |

**Test Files**:
- `supabase/tests/rls_policies/profiles_rls_test.sql`
- `supabase/tests/rls_policies/baby_profiles_rls_test.sql`
- `supabase/tests/rls_policies/events_rls_test.sql`
- `supabase/tests/rls_policies/photos_rls_test.sql`
- And 24 more files (one per table)

---

#### 3.2.12 Real-Time Subscription Testing

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Real-Time Test Suite** | `test/integration/realtime/` | Integration tests for all realtime-enabled tables (15 tables); subscription lifecycle tests; batched update tests; reconnection scenarios; latency benchmarks; memory leak detection | Realtime Service |
| **Real-Time Test Reports** | `test/integration/realtime/test_reports/` | Automated test reports; latency measurements; throughput benchmarks; error rate tracking; performance regression detection | N/A (Generated) |

**Test Files**:
- `test/integration/realtime/photos_realtime_test.dart`
- `test/integration/realtime/notifications_realtime_test.dart`
- `test/integration/realtime/name_suggestions_realtime_test.dart`
- And 12 more files

---

#### 3.2.13 Supabase Edge Functions

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Tile Config Function** | `supabase/functions/tile-configs/` | Serverless function for dynamic tile config generation; role-based filtering; caching headers; <100ms response time | Deno runtime |
| **Notification Trigger Function** | `supabase/functions/notification-trigger/` | Serverless function for notification generation; OneSignal integration; payload formatting; batching logic | Deno runtime, OneSignal API |
| **Image Processing Function** | `supabase/functions/image-processing/` | Thumbnail generation; image optimization; metadata extraction; format conversion | Deno runtime |
| **Edge Functions Configuration** | `supabase/config.toml` | Function deployment configuration; environment variables; CORS settings; timeout limits | N/A (Config) |

**Test Files**:
- `supabase/functions/tile-configs/index.test.ts`
- `supabase/functions/notification-trigger/index.test.ts`
- `supabase/functions/image-processing/index.test.ts`

---

#### 3.2.14 Supabase Monitoring

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Monitoring Dashboard** | Supabase Studio | Built-in monitoring; query performance; storage usage; API request analytics; realtime connection stats | Supabase Platform |
| **Custom Monitoring Queries** | `supabase/monitoring/queries.sql` | Custom SQL queries for business metrics; tile performance queries; cache hit rate queries; error rate queries | PostgreSQL |

**Documentation**:
- `docs/supabase_monitoring_guide.md` - Dashboard setup and alert configuration

---

### 3.2 Summary

**Total Components**: 40+ service classes + Edge Functions + RLS tests  
**Total Test Files**: 60+ unit/integration test files  
**Primary Locations**: 
- `lib/core/services/` (12 core services)
- `lib/core/network/` (network layer + endpoints)
- `lib/core/middleware/` (middleware components)
- `supabase/migrations/` (database migrations)
- `supabase/functions/` (Edge Functions)
- `supabase/tests/rls_policies/` (RLS test suite)

**Deliverables**:
- ✅ API service layer with Supabase client integration
- ✅ Supabase services (Auth, Database, Storage) configuration
- ✅ Local storage (SharedPreferences, Hive/Isar) setup
- ✅ Push notification service (OneSignal) implementation
- ✅ Integration test files (60+ tests)
- ✅ Database migration scripts with rollback capabilities
- ✅ Force update mechanism
- ✅ Data backup and recovery handlers
- ✅ GDPR-compliant data export/deletion handlers
- ✅ Comprehensive RLS policy test suite (pgTAP)
- ✅ Real-time subscription test reports
- ✅ Supabase Edge Functions (3 functions)
- ✅ Database migration strategy documentation
- ✅ Supabase monitoring dashboard and custom queries

---


## 3.3 Utils & Helpers

**Checklist Reference**: Section 3.3 - Utils & Helpers  
**Dependencies**: Functional Requirements Specification, Security and Privacy Requirements Document

### Overview

Utilities and helper functions provide reusable, cross-cutting functionality for the entire application.

### Components List

#### 3.3.1 Date/Time Helpers

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Date Helpers** | `lib/core/utils/date_helpers.dart` | Date formatting (relative, absolute); due date calculations; age calculations; timezone handling; date range utilities; countdown logic | intl package |
| **Date Extensions** | `lib/core/extensions/date_extensions.dart` | Extension methods on DateTime; isToday, isFuture, isPast; add/subtract helpers; format shortcuts | None |

**Test Files**:
- `test/core/utils/date_helpers_test.dart`
- `test/core/extensions/date_extensions_test.dart`

---

#### 3.3.2 Formatters

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Text Formatters** | `lib/core/utils/formatters.dart` | Phone number formatting; email validation; URL formatting; name capitalization; text truncation; pluralization helpers | None |
| **String Extensions** | `lib/core/extensions/string_extensions.dart` | Extension methods on String; capitalize, truncate, isEmail, isUrl; null-safe helpers | None |

**Test Files**:
- `test/core/utils/formatters_test.dart`
- `test/core/extensions/string_extensions_test.dart`

---

#### 3.3.3 Validators

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Input Validators** | `lib/core/utils/validators.dart` | Form validation rules; email validation; password strength; required field checks; length validators; URL validation; date range validation | None |
| **Input Sanitization** | `lib/core/utils/sanitizers.dart` | XSS prevention; SQL injection prevention; HTML entity encoding; whitespace trimming; special character handling | None |

**Test Files**:
- `test/core/utils/validators_test.dart`
- `test/core/utils/sanitizers_test.dart`

---

#### 3.3.4 Image Helpers

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Image Helpers** | `lib/core/utils/image_helpers.dart` | Image compression; thumbnail generation; file size validation; format conversion; aspect ratio calculations; cropping utilities | image package |

**Test Files**:
- `test/core/utils/image_helpers_test.dart`

---

#### 3.3.5 Role & Permission Helpers

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Role Helpers** | `lib/core/utils/role_helpers.dart` | Role checking utilities; permission calculations; owner/follower logic; role-specific UI helpers; dual-role handling | None |
| **Share Helpers** | `lib/core/utils/share_helpers.dart` | Social sharing utilities; deep link generation; invitation link creation; share sheet integration | share_plus package |

**Test Files**:
- `test/core/utils/role_helpers_test.dart`
- `test/core/utils/share_helpers_test.dart`

---

#### 3.3.6 Extensions

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Context Extensions** | `lib/core/extensions/context_extensions.dart` | BuildContext shortcuts; theme access; MediaQuery helpers; navigator shortcuts; scaffold messenger helpers | Flutter SDK |
| **List Extensions** | `lib/core/extensions/list_extensions.dart` | List utility methods; safe indexing; grouping; filtering; sorting helpers; null-safe operations | None |

**Test Files**:
- `test/core/extensions/context_extensions_test.dart`
- `test/core/extensions/list_extensions_test.dart`

---

#### 3.3.7 Constants

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **App Strings** | `lib/core/constants/strings.dart` | App-wide string constants; error messages; validation messages; default values | None |
| **Supabase Tables** | `lib/core/constants/supabase_tables.dart` | Table name constants; column name constants; prevents typos; refactoring safety | None |
| **Performance Limits** | `lib/core/constants/performance_limits.dart` | Cache TTL values; query limits; pagination sizes; timeout durations; batch sizes | None |

**Test Files**:
- `test/core/constants/strings_test.dart`
- `test/core/constants/supabase_tables_test.dart`
- `test/core/constants/performance_limits_test.dart`

---

#### 3.3.8 Mixins

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Role Aware Mixin** | `lib/core/mixins/role_aware_mixin.dart` | Role-based behavior for widgets; isOwner, isFollower checks; role-specific rendering | None |
| **Validation Mixin** | `lib/core/mixins/validation_mixin.dart` | Form validation utilities; error message generation; field validation | None |
| **Loading Mixin** | `lib/core/mixins/loading_mixin.dart` | Loading state management; loading indicators; async operation handling | None |

**Test Files**:
- `test/core/mixins/role_aware_mixin_test.dart`
- `test/core/mixins/validation_mixin_test.dart`
- `test/core/mixins/loading_mixin_test.dart`

---

#### 3.3.9 Enums & Type Definitions

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **User Role Enum** | `lib/core/enums/user_role.dart` | owner, follower enum; string conversion; icon mapping | None |
| **Tile Type Enum** | `lib/core/enums/tile_type.dart` | All tile types (upcoming_events, recent_photos, etc.); matches TileFactory cases | None |
| **Screen Name Enum** | `lib/core/enums/screen_name.dart` | home, calendar, gallery, registry, fun; route mapping | None |
| **Notification Type Enum** | `lib/core/enums/notification_type.dart` | Notification categories; icon mapping; color mapping | None |
| **Event Status Enum** | `lib/core/enums/event_status.dart` | Event lifecycle states; color mapping | None |
| **Callbacks TypeDef** | `lib/core/typedefs/callbacks.dart` | Common callback type definitions; VoidCallback aliases; typed callbacks | None |

**Test Files**:
- `test/core/enums/user_role_test.dart`
- `test/core/enums/tile_type_test.dart`
- `test/core/enums/screen_name_test.dart`
- `test/core/enums/notification_type_test.dart`
- `test/core/enums/event_status_test.dart`

---

### 3.3 Summary

**Total Components**: 25+ utility classes/extensions/enums  
**Total Test Files**: 25+ unit test files  
**Primary Locations**: 
- `lib/core/utils/` (10 helper classes)
- `lib/core/extensions/` (5 extension classes)
- `lib/core/constants/` (3 constant classes)
- `lib/core/mixins/` (3 mixin classes)
- `lib/core/enums/` (5 enum classes)
- `lib/core/typedefs/` (1 typedef file)

**Deliverables**:
- ✅ Utility functions and constants
- ✅ Input validation and sanitization code
- ✅ Date/time helper classes
- ✅ Unit test files for all utilities (≥80% coverage)

---

## 3.4 Theme & Styling

**Checklist Reference**: Section 3.4 - Theme & Styling  
**Dependencies**: User Personas Document, Business Requirements Document, Non-Functional Requirements Specification

### Overview

Theme and styling components define the visual identity, responsive design, accessibility, and internationalization support.

### Components List

#### 3.4.1 Core Theme

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **App Theme** | `lib/core/themes/app_theme.dart` | ThemeData definitions; light/dark theme configurations; color schemes; font families; component themes (button, card, input) | Flutter SDK |
| **Colors** | `lib/core/themes/colors.dart` | Color palette definitions; brand colors; semantic colors (success, error, warning); role-specific colors; opacity variants | None |
| **Text Styles** | `lib/core/themes/text_styles.dart` | Typography system; heading styles (H1-H6); body text styles; caption styles; dynamic type support | None |
| **Tile Styles** | `lib/core/themes/tile_styles.dart` | Consistent tile styling; tile container padding; tile header styles; tile shadow/elevation; tile border radius | None |

**Test Files**:
- `test/core/themes/app_theme_test.dart`
- `test/core/themes/colors_test.dart`
- `test/core/themes/text_styles_test.dart`
- `test/core/themes/tile_styles_test.dart`

---

#### 3.4.2 Reusable UI Components

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Loading Indicator** | `lib/core/widgets/loading_indicator.dart` | Consistent loading spinner; circular progress indicator; custom animations; role-based styling | None |
| **Error View** | `lib/core/widgets/error_view.dart` | Error state display; error messages; retry button; error icon; user-friendly messaging | None |
| **Empty State** | `lib/core/widgets/empty_state.dart` | Empty data state; placeholder illustrations; call-to-action; context-specific messaging | None |
| **Custom Button** | `lib/core/widgets/custom_button.dart` | Branded button component; primary/secondary/tertiary variants; loading state; disabled state; icon support | None |
| **Shimmer Placeholder** | `lib/core/widgets/shimmer_placeholder.dart` | Loading skeleton screens; shimmer animation; adaptive sizing; tile placeholders | shimmer package |

**Test Files**:
- `test/core/widgets/loading_indicator_test.dart`
- `test/core/widgets/error_view_test.dart`
- `test/core/widgets/empty_state_test.dart`
- `test/core/widgets/custom_button_test.dart`
- `test/core/widgets/shimmer_placeholder_test.dart`

---

#### 3.4.3 Responsive Design

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Responsive Layout** | `lib/core/widgets/responsive_layout.dart` | Breakpoint-based layouts; mobile/tablet/desktop variants; adaptive grid; responsive padding/margins | None |
| **Screen Size Utilities** | `lib/core/utils/screen_size_utils.dart` | Device type detection; breakpoint constants; orientation helpers; safe area calculations | None |

**Test Files**:
- `test/core/widgets/responsive_layout_test.dart`
- `test/core/utils/screen_size_utils_test.dart`

---

#### 3.4.4 Localization (i18n)

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **English Localization** | `lib/l10n/app_en.arb` | English strings; ARB format; ICU message formatting; pluralization rules | flutter_localizations |
| **Spanish Localization** | `lib/l10n/app_es.arb` | Spanish translations; matching English keys; pluralization rules | flutter_localizations |
| **Localization Configuration** | `lib/l10n/l10n.dart` | Supported locales; fallback locale; locale resolution; l10n delegate | flutter_localizations |

**Test Files**:
- `test/l10n/localization_test.dart`

---

#### 3.4.5 Accessibility

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Accessibility Helpers** | `lib/core/utils/accessibility_helpers.dart` | Semantic labels; screen reader support; keyboard navigation; focus management; WCAG 2.1 Level AA compliance | None |
| **Color Contrast Validator** | `lib/core/utils/color_contrast_validator.dart` | WCAG contrast ratio calculations; color pair validation; accessible color suggestions | None |
| **Accessibility Widget Tests** | `test/accessibility/` | Widget accessibility tests; semantic label tests; contrast tests; keyboard navigation tests | flutter_test |

**Test Files**:
- `test/core/utils/accessibility_helpers_test.dart`
- `test/core/utils/color_contrast_validator_test.dart`
- `test/accessibility/widget_accessibility_test.dart`

**Reports**:
- `docs/accessibility_compliance_report.md` - Accessibility audit results

---

#### 3.4.6 Dynamic Type & RTL Support

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Dynamic Type Handler** | `lib/core/utils/dynamic_type_handler.dart` | System font scaling support; text size adaptation; layout reflow; minimum/maximum scale factors | None |
| **RTL Support Handler** | `lib/core/utils/rtl_support_handler.dart` | Right-to-left layout support; bidirectional text; mirrored icons; locale-aware layout direction | None |

**Test Files**:
- `test/core/utils/dynamic_type_handler_test.dart`
- `test/core/utils/rtl_support_handler_test.dart`

**Test Reports**:
- `docs/dynamic_type_testing_results.md` - Font scaling test results
- `docs/rtl_support_testing_results.md` - RTL language test results

---

### 3.4 Summary

**Total Components**: 20+ theme/styling components  
**Total Test Files**: 20+ unit/widget test files  
**Primary Locations**: 
- `lib/core/themes/` (4 theme files)
- `lib/core/widgets/` (7 reusable widgets)
- `lib/l10n/` (3 localization files)
- `lib/core/utils/` (4 accessibility/responsive utilities)

**Deliverables**:
- ✅ Color palette and typography definitions
- ✅ Reusable UI components library
- ✅ Responsive design implementation
- ✅ Dark/light theme configuration
- ✅ Localization files (English, Spanish ARB files)
- ✅ Accessibility compliance implementation (WCAG 2.1 Level AA)
- ✅ Dynamic type testing support
- ✅ RTL language support
- ✅ Accessibility compliance report
- ✅ Dynamic type testing results
- ✅ RTL support testing results

---


## 3.5 State Management (Providers)

**Checklist Reference**: Section 3.5 - State Management (Providers)  
**Dependencies**: State Management Design Document, Functional Requirements Specification, Performance and Scalability Targets Document

### Overview

State management using Riverpod providers for dependency injection, reactive state, and state persistence.

### Components List

#### 3.5.1 Core Providers

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Global Providers** | `lib/core/di/providers.dart` | Singleton providers (Supabase client, auth service, cache service); scoped providers; family providers; auto-dispose configuration | riverpod |
| **Service Locator** | `lib/core/di/service_locator.dart` | Manual dependency registration; provider overrides for testing; initialization logic | riverpod |

**Test Files**:
- `test/core/di/providers_test.dart`
- `test/core/di/service_locator_test.dart`

---

#### 3.5.2 Tile Providers

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Tile Config Provider** | `lib/tiles/core/providers/tile_config_provider.dart` | Fetches tile configurations from Supabase; caches configs; role-based filtering; screen-specific configs; reactive updates | Tile Config Repository |
| **Tile Visibility Provider** | `lib/tiles/core/providers/tile_visibility_provider.dart` | Manages tile visibility flags; user preferences; feature flags; conditional rendering logic | Cache Service |

**Test Files**:
- `test/tiles/core/providers/tile_config_provider_test.dart`
- `test/tiles/core/providers/tile_visibility_provider_test.dart`

---

#### 3.5.3 Feature Providers

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Auth Provider** | `lib/features/auth/presentation/providers/auth_provider.dart` | Authentication state (user, session); login/logout methods; OAuth flow; biometric auth; auto-refresh; session persistence | Auth Service |
| **Auth State** | `lib/features/auth/presentation/providers/auth_state.dart` | Auth state model (authenticated, unauthenticated, loading, error); user model; session data | None |
| **Home Screen Provider** | `lib/features/home/presentation/providers/home_screen_provider.dart` | Home screen state; tile list; refresh logic; error handling; pull-to-refresh | Tile Config Provider |
| **Calendar Screen Provider** | `lib/features/calendar/presentation/providers/calendar_screen_provider.dart` | Calendar view state; event list; date selection; tile visibility; month navigation | Event Repository |
| **Gallery Screen Provider** | `lib/features/gallery/presentation/providers/gallery_screen_provider.dart` | Photo gallery state; photo grid; filters; pagination; upload state | Photo Repository |
| **Registry Screen Provider** | `lib/features/registry/presentation/providers/registry_screen_provider.dart` | Registry state; item list; filters; purchase state; sorting | Registry Repository |
| **Profile Provider** | `lib/features/profile/presentation/providers/profile_provider.dart` | User profile state; edit mode; validation; save state | User Repository |
| **Baby Profile Provider** | `lib/features/baby_profile/presentation/providers/baby_profile_provider.dart` | Baby profile management; CRUD operations; membership management; owner operations | Baby Profile Repository |

**Test Files**:
- `test/features/auth/presentation/providers/auth_provider_test.dart`
- `test/features/auth/presentation/providers/auth_state_test.dart`
- `test/features/home/presentation/providers/home_screen_provider_test.dart`
- `test/features/calendar/presentation/providers/calendar_screen_provider_test.dart`
- `test/features/gallery/presentation/providers/gallery_screen_provider_test.dart`
- `test/features/registry/presentation/providers/registry_screen_provider_test.dart`
- `test/features/profile/presentation/providers/profile_provider_test.dart`
- `test/features/baby_profile/presentation/providers/baby_profile_provider_test.dart`

---

#### 3.5.4 Tile-Specific Providers (15 Tiles)

Each tile has its own provider for data fetching and state management:

| Tile | Provider Location | Functionality |
|------|-------------------|---------------|
| **Upcoming Events** | `lib/tiles/upcoming_events/providers/upcoming_events_provider.dart` | Fetches upcoming events; role-based filtering; pagination; real-time updates |
| **Recent Photos** | `lib/tiles/recent_photos/providers/recent_photos_provider.dart` | Fetches recent photos; aggregation logic; thumbnail loading; infinite scroll |
| **Registry Highlights** | `lib/tiles/registry_highlights/providers/registry_highlights_provider.dart` | Fetches top registry items; priority sorting; purchase status |
| **Notifications** | `lib/tiles/notifications/providers/notifications_provider.dart` | Fetches notifications; read/unread state; real-time updates; badge count |
| **Invites Status** | `lib/tiles/invites_status/providers/invites_status_provider.dart` | Fetches pending invitations (owner only); acceptance tracking |
| **RSVP Tasks** | `lib/tiles/rsvp_tasks/providers/rsvp_tasks_provider.dart` | Fetches events needing RSVP; status tracking; reminders |
| **Due Date Countdown** | `lib/tiles/due_date_countdown/providers/due_date_countdown_provider.dart` | Calculates days until due date; countdown formatting; multiple babies |
| **Recent Purchases** | `lib/tiles/recent_purchases/providers/recent_purchases_provider.dart` | Fetches recent registry purchases; thank you status |
| **Registry Deals** | `lib/tiles/registry_deals/providers/registry_deals_provider.dart` | Fetches recommended items; deal tracking |
| **Engagement Recap** | `lib/tiles/engagement_recap/providers/engagement_recap_provider.dart` | Aggregates social engagement metrics; activity summary |
| **Gallery Favorites** | `lib/tiles/gallery_favorites/providers/gallery_favorites_provider.dart` | Fetches most squished photos; popularity ranking |
| **Checklist** | `lib/tiles/checklist/providers/checklist_provider.dart` | Onboarding checklist (owner only); completion tracking |
| **Storage Usage** | `lib/tiles/storage_usage/providers/storage_usage_provider.dart` | Storage quota tracking (owner only); usage visualization |
| **System Announcements** | `lib/tiles/system_announcements/providers/system_announcements_provider.dart` | Global announcements; dismissal tracking |
| **New Followers** | `lib/tiles/new_followers/providers/new_followers_provider.dart` | Recent follower additions (owner only); approval status |

**Test Files**: 15 test files (one per tile provider)

---

#### 3.5.5 State Persistence

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **State Persistence Manager** | `lib/core/services/state_persistence_manager.dart` | Persists Riverpod state to local storage; hydration on app start; selective persistence; background sync | Cache Service |
| **Persistence Strategies** | `lib/core/services/persistence_strategies.dart` | Different persistence strategies (memory, disk, Supabase); TTL management; eviction policies | None |

**Test Files**:
- `test/core/services/state_persistence_manager_test.dart`
- `test/core/services/persistence_strategies_test.dart`

---

#### 3.5.6 Error & Loading State Handlers

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Error State Handler** | `lib/core/providers/error_state_handler.dart` | Centralized error state management; error recovery; user notifications; retry logic | None |
| **Loading State Handler** | `lib/core/providers/loading_state_handler.dart` | Loading indicators coordination; skeleton screens; progress tracking; cancellation support | None |

**Test Files**:
- `test/core/providers/error_state_handler_test.dart`
- `test/core/providers/loading_state_handler_test.dart`

---

### 3.5 Summary

**Total Components**: 35+ provider classes  
**Total Test Files**: 35+ unit test files  
**Primary Locations**: 
- `lib/core/di/` (2 dependency injection files)
- `lib/tiles/core/providers/` (2 tile infrastructure providers)
- `lib/tiles/*/providers/` (15 tile-specific providers)
- `lib/features/*/presentation/providers/` (8 feature providers)
- `lib/core/services/` (2 persistence managers)
- `lib/core/providers/` (2 state handlers)

**Deliverables**:
- ✅ Provider classes for all features
- ✅ State persistence and synchronization
- ✅ Error handling and loading indicators
- ✅ Unit test files for all providers (≥80% coverage)

---


## 3.6 UI Development (Screens)

**Checklist Reference**: Section 3.6 - UI Development (Screens)  
**Dependencies**: User Journey Maps, System Architecture Diagram, State Management Design Document, Security and Privacy Requirements Document

### Overview

Screen implementations including authentication flows, main app screens, feature-specific screens, responsive layouts, error boundaries, and offline-first capabilities.

### Components List

#### 3.6.1 Authentication Screens

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Login Screen** | `lib/features/auth/presentation/screens/login_screen.dart` | Email/password login; OAuth buttons (Google, Facebook); "Forgot Password" link; field validation; loading state; error messages | Auth Provider |
| **Signup Screen** | `lib/features/auth/presentation/screens/signup_screen.dart` | Email/password registration; OAuth signup; terms acceptance; email verification prompt; validation; error handling | Auth Provider |
| **Role Selection Screen** | `lib/features/auth/presentation/screens/role_selection_screen.dart` | First-time user role selection (create baby profile or follow existing); onboarding flow; navigation | Auth Provider |
| **Auth Form Widgets** | `lib/features/auth/presentation/widgets/auth_form_widgets.dart` | Reusable auth forms; input fields; password visibility toggle; OAuth buttons; validators | None |

**Test Files**:
- `test/features/auth/presentation/screens/login_screen_test.dart`
- `test/features/auth/presentation/screens/signup_screen_test.dart`
- `test/features/auth/presentation/screens/role_selection_screen_test.dart`
- `test/features/auth/presentation/widgets/auth_form_widgets_test.dart`

---

#### 3.6.2 Main App Screens

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Home Screen** | `lib/features/home/presentation/screens/home_screen.dart` | Renders tiles via TileFactory; pull-to-refresh; role toggle (if dual-role); baby selector; app bar with profile/settings; tile list view | Home Screen Provider, TileFactory |
| **Home App Bar** | `lib/features/home/presentation/widgets/home_app_bar.dart` | Custom app bar; baby profile switcher; notification icon with badge; settings icon | None |
| **Tile List View** | `lib/features/home/presentation/widgets/tile_list_view.dart` | Scrollable tile container; shimmer loading; empty state; error retry; pull-to-refresh integration | None |
| **Calendar Screen** | `lib/features/calendar/presentation/screens/calendar_screen.dart` | Calendar widget; event tiles; date selection; month navigation; add event FAB (owner only) | Calendar Screen Provider |
| **Calendar Widget** | `lib/features/calendar/presentation/widgets/calendar_widget.dart` | Custom calendar UI; event markers; date highlighting; month/week views; gesture navigation | table_calendar package |
| **Gallery Screen** | `lib/features/gallery/presentation/screens/gallery_screen.dart` | Photo grid; filters (by baby, date, tags); infinite scroll; upload FAB (owner only); photo tiles | Gallery Screen Provider |
| **Photo Detail Screen** | `lib/features/gallery/presentation/screens/photo_detail_screen.dart` | Full-screen photo view; squish button; comments; photo metadata; swipe navigation; share/download | Photo Repository |
| **Squish Photo Widget** | `lib/features/gallery/presentation/widgets/squish_photo_widget.dart` | Squish button with animation; squish count; user list popup | None |
| **Registry Screen** | `lib/features/registry/presentation/screens/registry_screen.dart` | Registry item list; filters (priority, purchased status); add item FAB (owner only); registry tiles | Registry Screen Provider |
| **Registry Item Detail Screen** | `lib/features/registry/presentation/screens/registry_item_detail_screen.dart` | Item details; purchase button; purchase history; item link; edit (owner only) | Registry Repository |
| **Registry Filter Bar** | `lib/features/registry/presentation/widgets/registry_filter_bar.dart` | Filter chips; priority filter; purchased filter; sort dropdown | None |

**Test Files**:
- `test/features/home/presentation/screens/home_screen_test.dart`
- `test/features/home/presentation/widgets/home_app_bar_test.dart`
- `test/features/home/presentation/widgets/tile_list_view_test.dart`
- `test/features/calendar/presentation/screens/calendar_screen_test.dart`
- `test/features/calendar/presentation/widgets/calendar_widget_test.dart`
- `test/features/gallery/presentation/screens/gallery_screen_test.dart`
- `test/features/gallery/presentation/screens/photo_detail_screen_test.dart`
- `test/features/gallery/presentation/widgets/squish_photo_widget_test.dart`
- `test/features/registry/presentation/screens/registry_screen_test.dart`
- `test/features/registry/presentation/screens/registry_item_detail_screen_test.dart`
- `test/features/registry/presentation/widgets/registry_filter_bar_test.dart`

---

#### 3.6.3 Profile Management Screens

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Profile Screen** | `lib/features/profile/presentation/screens/profile_screen.dart` | User profile display; edit button; settings access; logout button; user stats; gamification badges | Profile Provider |
| **Edit Profile Screen** | `lib/features/profile/presentation/screens/edit_profile_screen.dart` | Profile editing form; avatar upload; display name; biometric toggle; validation; save/cancel | Profile Provider |
| **Profile Widgets** | `lib/features/profile/presentation/widgets/profile_widgets.dart` | Avatar widget; stats cards; settings list items; reusable components | None |
| **Baby Profile Screen** | `lib/features/baby_profile/presentation/screens/baby_profile_screen.dart` | Baby profile details; follower list (owner only); invitation management (owner only); edit button (owner only) | Baby Profile Provider |
| **Create Baby Profile Screen** | `lib/features/baby_profile/presentation/screens/create_baby_profile_screen.dart` | Baby profile creation form; name, photo, due date; co-owner invitation; validation | Baby Profile Provider |
| **Edit Baby Profile Screen** | `lib/features/baby_profile/presentation/screens/edit_baby_profile_screen.dart` | Baby profile editing; update fields; delete profile (with confirmation); save/cancel | Baby Profile Provider |
| **Baby Profile Widgets** | `lib/features/baby_profile/presentation/widgets/baby_profile_widgets.dart` | Baby profile card; follower list items; invitation dialog; reusable components | None |

**Test Files**:
- `test/features/profile/presentation/screens/profile_screen_test.dart`
- `test/features/profile/presentation/screens/edit_profile_screen_test.dart`
- `test/features/profile/presentation/widgets/profile_widgets_test.dart`
- `test/features/baby_profile/presentation/screens/baby_profile_screen_test.dart`
- `test/features/baby_profile/presentation/screens/create_baby_profile_screen_test.dart`
- `test/features/baby_profile/presentation/screens/edit_baby_profile_screen_test.dart`
- `test/features/baby_profile/presentation/widgets/baby_profile_widgets_test.dart`

---

#### 3.6.4 Additional Feature Screens

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Photo Gallery Screen** | `lib/features/photo_gallery/presentation/screens/photo_gallery_screen.dart` | Dedicated photo gallery view; masonry/grid layout; filters; zoom; slideshow | Photo Gallery Provider |
| **Photo Upload Screen** | `lib/features/photo_gallery/presentation/screens/photo_upload_screen.dart` | Photo upload; caption input; tag input; multi-select; upload progress; batch upload | Storage Service |
| **Photo Grid Widget** | `lib/features/photo_gallery/presentation/widgets/photo_grid.dart` | Grid layout; lazy loading; thumbnail caching; tap handling | None |
| **Fun Screen** | `lib/features/fun/presentation/screens/fun_screen.dart` | Gamification features; name suggestions; prediction voting; leaderboard; engagement recap | Fun Provider |
| **Fun Tile Grid** | `lib/features/fun/presentation/widgets/fun_tile_grid.dart` | Grid layout for fun tiles; vote widgets; name suggestion widgets | None |

**Test Files**:
- `test/features/photo_gallery/presentation/screens/photo_gallery_screen_test.dart`
- `test/features/photo_gallery/presentation/screens/photo_upload_screen_test.dart`
- `test/features/photo_gallery/presentation/widgets/photo_grid_test.dart`
- `test/features/fun/presentation/screens/fun_screen_test.dart`
- `test/features/fun/presentation/widgets/fun_tile_grid_test.dart`

---

#### 3.6.5 Navigation & Routing

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **App Router** | `lib/core/router/app_router.dart` | GoRouter configuration; route definitions; deep linking; route guards; navigation stack; tab navigation | go_router package |
| **Route Guards** | `lib/core/router/route_guards.dart` | Authentication guards; role-based guards; onboarding completion checks; redirect logic | Auth Provider |

**Test Files**:
- `test/core/router/app_router_test.dart`
- `test/core/router/route_guards_test.dart`

---

#### 3.6.6 Responsive Layouts

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Responsive Layouts** | Applied across all screens | Breakpoint-based layouts; mobile (portrait/landscape); tablet; desktop; adaptive padding; responsive typography | LayoutBuilder, MediaQuery |

**Test Files**:
- Responsive tests within each screen test file

---

#### 3.6.7 Error Boundaries & Recovery

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Global Error Boundary** | `lib/core/widgets/error_boundary.dart` | Catches all uncaught errors; crash recovery UI; error reporting to Sentry; restart option; error details (debug mode) | Observability Service |
| **Error Recovery Manager** | `lib/core/services/error_recovery_manager.dart` | Recovery strategies; state restoration; automatic retry; user guidance | None |

**Test Files**:
- `test/core/widgets/error_boundary_test.dart`
- `test/core/services/error_recovery_manager_test.dart`

---

#### 3.6.8 Offline-First Implementation

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Offline Cache Manager** | `lib/core/services/offline_cache_manager.dart` | Offline data caching; sync queue management; conflict resolution; background sync; online/offline detection | Cache Service |
| **Sync Manager** | `lib/core/services/sync_manager.dart` | Background data synchronization; delta sync; conflict resolution; retry logic; sync status UI | Realtime Service |
| **Offline Indicator Widget** | `lib/core/widgets/offline_indicator.dart` | Offline status banner; sync status; retry button; connectivity detection | None |

**Test Files**:
- `test/core/services/offline_cache_manager_test.dart`
- `test/core/services/sync_manager_test.dart`
- `test/core/widgets/offline_indicator_test.dart`

---

#### 3.6.9 Network Failure Handling

| Component | Location | Functionality | Dependencies |
|-----------|----------|---------------|--------------|
| **Network Error Handler** | `lib/core/services/network_error_handler.dart` | Network error detection; timeout handling; retry strategies; exponential backoff; user notifications | Error Handler |
| **Retry Dialog** | `lib/core/widgets/retry_dialog.dart` | Retry confirmation dialog; manual retry button; error message; cancel option | None |

**Test Files**:
- `test/core/services/network_error_handler_test.dart`
- `test/core/widgets/retry_dialog_test.dart`

---

#### 3.6.10 Tile Widgets (15 Tiles)

Each tile has its own widget implementation in `lib/tiles/*/widgets/`:

| Tile | Widget Location | Functionality |
|------|-----------------|---------------|
| **Upcoming Events Tile** | `lib/tiles/upcoming_events/widgets/upcoming_events_tile.dart` | Displays upcoming events; event cards; RSVP status; tap navigation |
| **Recent Photos Tile** | `lib/tiles/recent_photos/widgets/recent_photos_tile.dart` | Photo grid; thumbnails; squish counts; tap to enlarge |
| **Registry Highlights Tile** | `lib/tiles/registry_highlights/widgets/registry_highlights_tile.dart` | Top registry items; priority badges; purchase status; tap navigation |
| **Notifications Tile** | `lib/tiles/notifications/widgets/notifications_tile.dart` | Recent notifications; read/unread state; tap to mark read; navigation |
| **Invites Status Tile** | `lib/tiles/invites_status/widgets/invites_status_tile.dart` | Pending invitations (owner); resend/revoke buttons; acceptance tracking |
| **RSVP Tasks Tile** | `lib/tiles/rsvp_tasks/widgets/rsvp_tasks_tile.dart` | Events needing RSVP; quick RSVP buttons; event details |
| **Due Date Countdown Tile** | `lib/tiles/due_date_countdown/widgets/due_date_countdown_tile.dart` | Countdown display; days/weeks remaining; baby name; visual progress |
| **Recent Purchases Tile** | `lib/tiles/recent_purchases/widgets/recent_purchases_tile.dart` | Recent registry purchases; purchaser names; thank you status |
| **Registry Deals Tile** | `lib/tiles/registry_deals/widgets/registry_deals_tile.dart` | Recommended items; deal badges; external links |
| **Engagement Recap Tile** | `lib/tiles/engagement_recap/widgets/engagement_recap_tile.dart` | Activity summary; engagement metrics; time period selector |
| **Gallery Favorites Tile** | `lib/tiles/gallery_favorites/widgets/gallery_favorites_tile.dart` | Most squished photos; squish counts; tap to view |
| **Checklist Tile** | `lib/tiles/checklist/widgets/checklist_tile.dart` | Onboarding checklist (owner); checkboxes; progress bar |
| **Storage Usage Tile** | `lib/tiles/storage_usage/widgets/storage_usage_tile.dart` | Storage quota (owner); usage visualization; upgrade prompt |
| **System Announcements Tile** | `lib/tiles/system_announcements/widgets/system_announcements_tile.dart` | Global announcements; dismiss button; importance badges |
| **New Followers Tile** | `lib/tiles/new_followers/widgets/new_followers_tile.dart` | Recent followers (owner); follower avatars; relationship labels |

**Test Files**: 15 widget test files (one per tile widget)

---

### 3.6 Summary

**Total Components**: 50+ screen/widget components  
**Total Test Files**: 50+ widget/integration test files  
**Primary Locations**: 
- `lib/features/auth/presentation/` (4 auth screens + widgets)
- `lib/features/home/presentation/` (1 home screen + 2 widgets)
- `lib/features/calendar/presentation/` (1 calendar screen + 1 widget)
- `lib/features/gallery/presentation/` (2 gallery screens + 1 widget)
- `lib/features/registry/presentation/` (2 registry screens + 1 widget)
- `lib/features/profile/presentation/` (2 profile screens + 1 widget)
- `lib/features/baby_profile/presentation/` (3 baby profile screens + 1 widget)
- `lib/features/photo_gallery/presentation/` (2 photo screens + 1 widget)
- `lib/features/fun/presentation/` (1 fun screen + 1 widget)
- `lib/tiles/*/widgets/` (15 tile widgets)
- `lib/core/router/` (2 routing files)
- `lib/core/widgets/` (3 error/offline widgets)
- `lib/core/services/` (4 offline/error services)

**Deliverables**:
- ✅ Authentication screens (login, signup, role selection)
- ✅ Main app screens and navigation (home, calendar, gallery, registry, fun)
- ✅ Feature-specific screens (profile, baby profile, photo gallery)
- ✅ Responsive layouts for all screens
- ✅ Global error boundary and crash recovery
- ✅ Offline-first caching implementation
- ✅ Network failure handling with retry logic
- ✅ 15 tile widget implementations
- ✅ Navigation and routing with guards
- ✅ 50+ comprehensive widget test files

---


## 4. Complete Component Directory Map

This section provides a comprehensive directory structure showing the exact location of every component to be developed.

```
lib/
├── core/                           # Shared infrastructure (Section 3.1-3.4)
│   ├── models/                     # 27 data models (3.1)
│   │   ├── user.dart
│   │   ├── user_stats.dart
│   │   ├── baby_profile.dart
│   │   ├── baby_membership.dart
│   │   ├── invitation.dart
│   │   ├── tile_config.dart
│   │   ├── screen_config.dart
│   │   ├── event.dart
│   │   ├── event_rsvp.dart
│   │   ├── event_comment.dart
│   │   ├── registry_item.dart
│   │   ├── registry_purchase.dart
│   │   ├── photo.dart
│   │   ├── photo_squish.dart
│   │   ├── photo_comment.dart
│   │   ├── photo_tag.dart
│   │   ├── vote.dart
│   │   ├── name_suggestion.dart
│   │   ├── name_suggestion_like.dart
│   │   ├── notification.dart
│   │   ├── activity_event.dart
│   │   └── owner_update_marker.dart
│   │
│   ├── services/                   # 12 core services (3.2)
│   │   ├── supabase_service.dart
│   │   ├── auth_service.dart
│   │   ├── database_service.dart
│   │   ├── storage_service.dart
│   │   ├── cache_service.dart
│   │   ├── local_storage_service.dart
│   │   ├── realtime_service.dart
│   │   ├── notification_service.dart
│   │   ├── analytics_service.dart
│   │   ├── observability_service.dart
│   │   ├── force_update_service.dart
│   │   ├── backup_service.dart
│   │   ├── data_export_handler.dart
│   │   ├── data_deletion_handler.dart
│   │   ├── state_persistence_manager.dart
│   │   ├── persistence_strategies.dart
│   │   ├── error_recovery_manager.dart
│   │   ├── offline_cache_manager.dart
│   │   ├── sync_manager.dart
│   │   └── network_error_handler.dart
│   │
│   ├── network/                    # Network layer (3.2)
│   │   ├── supabase_client.dart
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart
│   │   │   └── logging_interceptor.dart
│   │   └── endpoints/
│   │       ├── auth_endpoints.dart
│   │       ├── tile_endpoints.dart
│   │       ├── event_endpoints.dart
│   │       ├── photo_endpoints.dart
│   │       ├── registry_endpoints.dart
│   │       └── edge_functions.dart
│   │
│   ├── utils/                      # Helper functions (3.3)
│   │   ├── date_helpers.dart
│   │   ├── formatters.dart
│   │   ├── validators.dart
│   │   ├── sanitizers.dart
│   │   ├── image_helpers.dart
│   │   ├── role_helpers.dart
│   │   ├── share_helpers.dart
│   │   ├── accessibility_helpers.dart
│   │   ├── color_contrast_validator.dart
│   │   ├── dynamic_type_handler.dart
│   │   ├── rtl_support_handler.dart
│   │   └── screen_size_utils.dart
│   │
│   ├── extensions/                 # Dart extensions (3.3)
│   │   ├── date_extensions.dart
│   │   ├── string_extensions.dart
│   │   ├── context_extensions.dart
│   │   └── list_extensions.dart
│   │
│   ├── mixins/                     # Reusable behaviors (3.3)
│   │   ├── role_aware_mixin.dart
│   │   ├── validation_mixin.dart
│   │   └── loading_mixin.dart
│   │
│   ├── enums/                      # Global enums (3.3)
│   │   ├── user_role.dart
│   │   ├── tile_type.dart
│   │   ├── screen_name.dart
│   │   ├── notification_type.dart
│   │   └── event_status.dart
│   │
│   ├── typedefs/                   # Type aliases (3.3)
│   │   └── callbacks.dart
│   │
│   ├── constants/                  # App constants (3.3)
│   │   ├── strings.dart
│   │   ├── supabase_tables.dart
│   │   └── performance_limits.dart
│   │
│   ├── themes/                     # Theming (3.4)
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   ├── text_styles.dart
│   │   └── tile_styles.dart
│   │
│   ├── widgets/                    # Shared widgets (3.4, 3.6)
│   │   ├── loading_indicator.dart
│   │   ├── error_view.dart
│   │   ├── empty_state.dart
│   │   ├── custom_button.dart
│   │   ├── shimmer_placeholder.dart
│   │   ├── responsive_layout.dart
│   │   ├── error_boundary.dart
│   │   ├── offline_indicator.dart
│   │   └── retry_dialog.dart
│   │
│   ├── middleware/                 # Middleware (3.2)
│   │   ├── error_handler.dart
│   │   ├── cache_manager.dart
│   │   └── rls_validator.dart
│   │
│   ├── exceptions/                 # Custom exceptions (3.2)
│   │   ├── app_exceptions.dart
│   │   ├── supabase_exceptions.dart
│   │   └── permission_exceptions.dart
│   │
│   ├── di/                         # Dependency injection (3.5)
│   │   ├── providers.dart
│   │   └── service_locator.dart
│   │
│   ├── providers/                  # Core providers (3.5)
│   │   ├── error_state_handler.dart
│   │   └── loading_state_handler.dart
│   │
│   ├── router/                     # Navigation (3.6)
│   │   ├── app_router.dart
│   │   └── route_guards.dart
│   │
│   └── config/                     # Configuration
│       ├── app_config.dart
│       └── environment.dart
│
├── tiles/                          # Tile widgets (15 tiles) (3.5, 3.6)
│   ├── core/                       # Tile infrastructure
│   │   ├── models/
│   │   │   ├── tile_definition.dart
│   │   │   ├── tile_params.dart
│   │   │   └── tile_state.dart
│   │   ├── widgets/
│   │   │   ├── tile_factory.dart
│   │   │   ├── base_tile.dart
│   │   │   └── tile_container.dart
│   │   ├── providers/
│   │   │   ├── tile_config_provider.dart
│   │   │   └── tile_visibility_provider.dart
│   │   └── data/
│   │       ├── repositories/
│   │       │   └── tile_config_repository_impl.dart
│   │       └── datasources/
│   │           ├── remote/
│   │           │   └── tile_config_remote_datasource.dart
│   │           └── local/
│   │               └── tile_config_cache.dart
│   │
│   ├── upcoming_events/            # Tile 1
│   │   ├── models/
│   │   │   └── upcoming_event.dart
│   │   ├── providers/
│   │   │   └── upcoming_events_provider.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── remote/
│   │   │   │   │   └── upcoming_events_datasource.dart
│   │   │   │   └── local/
│   │   │   │       └── upcoming_events_cache.dart
│   │   │   └── mappers/
│   │   │       └── upcoming_event_mapper.dart
│   │   └── widgets/
│   │       ├── upcoming_events_tile.dart
│   │       └── event_item_card.dart
│   │
│   ├── recent_photos/              # Tile 2
│   │   ├── models/
│   │   │   └── recent_photo.dart
│   │   ├── providers/
│   │   │   └── recent_photos_provider.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── remote/
│   │   │   │   │   └── recent_photos_datasource.dart
│   │   │   │   └── local/
│   │   │   │       └── recent_photos_cache.dart
│   │   │   └── mappers/
│   │   │       └── recent_photo_mapper.dart
│   │   └── widgets/
│   │       ├── recent_photos_tile.dart
│   │       └── photo_thumbnail.dart
│   │
│   ├── registry_highlights/        # Tile 3
│   ├── notifications/              # Tile 4
│   ├── invites_status/             # Tile 5
│   ├── rsvp_tasks/                 # Tile 6
│   ├── due_date_countdown/         # Tile 7
│   ├── recent_purchases/           # Tile 8
│   ├── registry_deals/             # Tile 9
│   ├── engagement_recap/           # Tile 10
│   ├── gallery_favorites/          # Tile 11
│   ├── checklist/                  # Tile 12
│   ├── storage_usage/              # Tile 13
│   ├── system_announcements/       # Tile 14
│   └── new_followers/              # Tile 15
│       └── (same structure as tiles 1-2)
│
├── features/                       # Screen features (3.6)
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   ├── auth_provider.dart
│   │   │   │   └── auth_state.dart
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── signup_screen.dart
│   │   │   │   └── role_selection_screen.dart
│   │   │   └── widgets/
│   │   │       └── auth_form_widgets.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── auth_response_dto.dart
│   │   │   ├── mappers/
│   │   │   │   └── auth_mapper.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository_impl.dart
│   │   │   └── datasources/
│   │   │       ├── remote/
│   │   │       │   └── auth_remote_datasource.dart
│   │   │       └── local/
│   │   │           └── auth_local_datasource.dart
│   │   └── domain/
│   │       ├── use_cases/
│   │       │   ├── login_use_case.dart
│   │       │   ├── signup_use_case.dart
│   │       │   └── logout_use_case.dart
│   │       └── entities/
│   │           └── user_entity.dart
│   │
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── home_screen_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── home_app_bar.dart
│   │   │       └── tile_list_view.dart
│   │
│   ├── calendar/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── calendar_screen_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── calendar_screen.dart
│   │   │   └── widgets/
│   │   │       └── calendar_widget.dart
│   │
│   ├── gallery/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── gallery_screen_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── gallery_screen.dart
│   │   │   │   └── photo_detail_screen.dart
│   │   │   └── widgets/
│   │   │       └── squish_photo_widget.dart
│   │
│   ├── registry/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── registry_screen_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── registry_screen.dart
│   │   │   │   └── registry_item_detail_screen.dart
│   │   │   └── widgets/
│   │   │       └── registry_filter_bar.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── registry_item_dto.dart
│   │   │   ├── mappers/
│   │   │   ├── repositories/
│   │   │   │   └── registry_repository_impl.dart
│   │   │   └── datasources/
│   │   │       ├── remote/
│   │   │       │   └── registry_remote_datasource.dart
│   │   │       └── local/
│   │   │           └── registry_cache.dart
│   │   └── domain/
│   │       ├── use_cases/
│   │       │   ├── get_registry_items.dart
│   │       │   └── purchase_item.dart
│   │       └── entities/
│   │           └── registry_item_entity.dart
│   │
│   ├── photo_gallery/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── photo_gallery_screen_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── photo_gallery_screen.dart
│   │   │   │   └── photo_upload_screen.dart
│   │   │   └── widgets/
│   │   │       └── photo_grid.dart
│   │
│   ├── fun/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── fun_screen_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── fun_screen.dart
│   │   │   └── widgets/
│   │   │       └── fun_tile_grid.dart
│   │
│   ├── profile/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── profile_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   └── edit_profile_screen.dart
│   │   │   └── widgets/
│   │   │       └── profile_widgets.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── profile_dto.dart
│   │   │   ├── mappers/
│   │   │   ├── repositories/
│   │   │   │   └── profile_repository_impl.dart
│   │   │   └── datasources/
│   │   │       ├── remote/
│   │   │       │   └── profile_remote_datasource.dart
│   │   │       └── local/
│   │   │           └── profile_cache.dart
│   │   └── domain/
│   │       ├── use_cases/
│   │       │   ├── update_profile.dart
│   │       │   └── get_profile.dart
│   │       └── entities/
│   │           └── profile_entity.dart
│   │
│   └── baby_profile/
│       ├── presentation/
│       │   ├── providers/
│       │   │   └── baby_profile_provider.dart
│       │   ├── screens/
│       │   │   ├── baby_profile_screen.dart
│       │   │   ├── create_baby_profile_screen.dart
│       │   │   └── edit_baby_profile_screen.dart
│       │   └── widgets/
│       │       └── baby_profile_widgets.dart
│       ├── data/
│       │   ├── models/
│       │   │   └── baby_profile_dto.dart
│       │   ├── mappers/
│       │   ├── repositories/
│       │   │   └── baby_profile_repository_impl.dart
│       │   └── datasources/
│       │       ├── remote/
│       │       │   └── baby_profile_remote_datasource.dart
│       │       └── local/
│       │           └── baby_profile_cache.dart
│       └── domain/
│           ├── use_cases/
│           │   ├── create_baby_profile.dart
│           │   ├── update_baby_profile.dart
│           │   └── get_baby_profiles.dart
│           └── entities/
│               └── baby_profile_entity.dart
│
├── l10n/                           # Localization (3.4)
│   ├── app_en.arb
│   ├── app_es.arb
│   └── l10n.dart
│
├── main.dart                       # App entry point
└── app.dart                        # Root widget

test/                               # Comprehensive tests
├── core/
│   ├── models/                     # 28 model tests
│   ├── services/                   # 20 service tests
│   ├── network/                    # 8 network tests
│   ├── utils/                      # 12 utility tests
│   ├── extensions/                 # 4 extension tests
│   ├── mixins/                     # 3 mixin tests
│   ├── enums/                      # 5 enum tests
│   ├── themes/                     # 4 theme tests
│   ├── widgets/                    # 9 widget tests
│   ├── middleware/                 # 3 middleware tests
│   ├── di/                         # 2 DI tests
│   ├── providers/                  # 2 provider tests
│   └── router/                     # 2 router tests
├── tiles/
│   ├── core/                       # Tile infrastructure tests
│   ├── upcoming_events/            # Tile 1 tests
│   ├── recent_photos/              # Tile 2 tests
│   └── (13 more tile test dirs)
├── features/
│   ├── auth/                       # Auth feature tests
│   ├── home/                       # Home feature tests
│   ├── calendar/                   # Calendar feature tests
│   ├── gallery/                    # Gallery feature tests
│   ├── registry/                   # Registry feature tests
│   ├── photo_gallery/              # Photo gallery feature tests
│   ├── fun/                        # Fun feature tests
│   ├── profile/                    # Profile feature tests
│   └── baby_profile/               # Baby profile feature tests
├── l10n/                           # Localization tests
├── integration/
│   └── realtime/                   # Real-time subscription tests
└── accessibility/                  # Accessibility tests

supabase/                           # Supabase configuration (3.2)
├── migrations/                     # Database migrations
├── tests/
│   └── rls_policies/              # RLS policy tests (pgTAP)
├── functions/                      # Edge Functions
│   ├── tile-configs/
│   ├── notification-trigger/
│   └── image-processing/
└── config.toml

docs/                               # Additional documentation (3.2)
├── database_migration_strategy.md
├── rls_testing_guide.md
├── supabase_monitoring_guide.md
├── accessibility_compliance_report.md
├── dynamic_type_testing_results.md
└── rtl_support_testing_results.md
```

---


## 5. Implementation Sequence

This section provides a recommended order for implementing components to minimize dependencies and enable parallel development.

### Phase 1: Foundation (Week 1-2)

**Priority**: Critical foundation - all subsequent work depends on these

1. **Core Models** (3.1)
   - Start with: User, BabyProfile, BabyMembership, TileConfig, ScreenConfig
   - Then: Event, Photo, RegistryItem models
   - Finally: Supporting models (Vote, Notification, ActivityEvent)
   - **Rationale**: Models have no dependencies and are needed everywhere

2. **Core Services & Network** (3.2)
   - Start with: SupabaseClient, SupabaseService, AuthService
   - Then: DatabaseService, StorageService
   - Then: CacheService, LocalStorageService
   - **Rationale**: Services depend on models; required for all data operations

3. **Utils & Helpers** (3.3)
   - All utilities in parallel (no dependencies)
   - Focus on: Validators, Formatters, DateHelpers first
   - **Rationale**: Utilities are leaf nodes; needed for validation and UI

### Phase 2: Infrastructure (Week 3-4)

**Priority**: High - enables UI development and state management

4. **Dependency Injection** (3.5)
   - ServiceLocator, GlobalProviders
   - **Rationale**: Required for all Riverpod providers

5. **Theming & Core Widgets** (3.4)
   - AppTheme, Colors, TextStyles
   - LoadingIndicator, ErrorView, EmptyState, CustomButton
   - **Rationale**: Required for all UI development

6. **Navigation & Routing** (3.6)
   - AppRouter, RouteGuards
   - **Rationale**: Required for screen navigation

7. **Error Handling & Middleware** (3.2, 3.6)
   - ErrorHandler, ErrorBoundary
   - CacheManager, RLSValidator
   - **Rationale**: Critical for app stability and debugging

### Phase 3: Tile Infrastructure (Week 5)

**Priority**: High - prerequisite for all tiles

8. **Tile Core System** (3.5, 3.6)
   - TileDefinition, TileParams, TileState models
   - TileFactory, BaseTile, TileContainer widgets
   - TileConfigProvider, TileVisibilityProvider
   - TileConfigRepository and datasources
   - **Rationale**: All individual tiles depend on this infrastructure

### Phase 4: Authentication & Core Screens (Week 6-7)

**Priority**: High - users need to authenticate to access app

9. **Authentication Feature** (3.6)
   - AuthProvider, AuthState
   - LoginScreen, SignupScreen, RoleSelectionScreen
   - AuthRepository and datasources
   - **Rationale**: Gateway to app; required for all user-facing features

10. **Home Screen** (3.6)
    - HomeScreenProvider
    - HomeScreen, HomeAppBar, TileListView
    - **Rationale**: Primary screen; demonstrates tile system

### Phase 5: Tiles Development (Week 8-12)

**Priority**: Medium-High - can be parallelized across developers

Recommended tile implementation order:

**Batch 1 (Week 8): Core Tiles**
- Upcoming Events Tile (#1)
- Recent Photos Tile (#2)
- Notifications Tile (#4)
- **Rationale**: Most frequently used; demonstrate all tile patterns

**Batch 2 (Week 9): Owner-Specific Tiles**
- Invites Status Tile (#5)
- Checklist Tile (#12)
- Storage Usage Tile (#13)
- New Followers Tile (#15)
- **Rationale**: Owner-only features; can be tested with owner accounts

**Batch 3 (Week 10): Social/Engagement Tiles**
- RSVP Tasks Tile (#6)
- Recent Purchases Tile (#8)
- Engagement Recap Tile (#10)
- Gallery Favorites Tile (#11)
- **Rationale**: Social features; moderate complexity

**Batch 4 (Week 11): Specialized Tiles**
- Registry Highlights Tile (#3)
- Due Date Countdown Tile (#7)
- Registry Deals Tile (#9)
- System Announcements Tile (#14)
- **Rationale**: Specialized functionality; lower priority

### Phase 6: Feature Screens (Week 13-16)

**Priority**: Medium - completes core user journeys

**Batch 1 (Week 13): Calendar & Events**
- CalendarScreenProvider
- CalendarScreen, CalendarWidget
- Event datasources and repository
- **Rationale**: Depends on Events tile

**Batch 2 (Week 14): Gallery & Photos**
- GalleryScreenProvider, PhotoGalleryScreenProvider
- GalleryScreen, PhotoDetailScreen, PhotoUploadScreen
- Photo datasources and repository
- **Rationale**: Depends on Photos tile

**Batch 3 (Week 15): Registry**
- RegistryScreenProvider
- RegistryScreen, RegistryItemDetailScreen
- Registry datasources and repository
- **Rationale**: Depends on Registry tiles

**Batch 4 (Week 16): Profile & Fun**
- ProfileProvider, BabyProfileProvider, FunProvider
- All profile and fun screens
- Profile datasources and repositories
- **Rationale**: Lower priority; ancillary features

### Phase 7: Advanced Services (Week 17-18)

**Priority**: Medium - enhances app resilience

11. **Real-Time & Notifications** (3.2)
    - RealtimeService, NotificationService
    - Real-time subscription testing
    - **Rationale**: Enhances UX with live updates

12. **Offline Support** (3.6)
    - OfflineCacheManager, SyncManager
    - OfflineIndicator, NetworkErrorHandler
    - **Rationale**: Critical for mobile app UX

13. **Monitoring & Analytics** (3.2)
    - AnalyticsService, ObservabilityService
    - **Rationale**: Production monitoring essentials

### Phase 8: Database & Deployment (Week 19-20)

**Priority**: High - production readiness

14. **Database Migrations** (3.2)
    - All migration scripts
    - Migration strategy documentation
    - **Rationale**: Production database setup

15. **RLS Policy Testing** (3.2)
    - pgTAP test suite for all 90+ policies
    - RLS testing documentation
    - **Rationale**: Security validation before production

16. **Edge Functions** (3.2)
    - Tile-configs function
    - Notification-trigger function
    - Image-processing function
    - **Rationale**: Serverless operations for scalability

### Phase 9: Quality & Compliance (Week 21-22)

**Priority**: Critical - production gate

17. **Localization** (3.4)
    - English and Spanish ARB files
    - Localization configuration
    - **Rationale**: Internationalization support

18. **Accessibility** (3.4)
    - Accessibility helpers and validators
    - Accessibility widget tests
    - Accessibility compliance report
    - **Rationale**: WCAG 2.1 Level AA compliance required

19. **Data Compliance** (3.2)
    - BackupService, DataExportHandler, DataDeletionHandler
    - ForceUpdateService
    - **Rationale**: GDPR/CCPA compliance

20. **Testing & Documentation** (All sections)
    - Comprehensive unit tests (≥80% coverage)
    - Integration tests for all services
    - Widget tests for all screens
    - Documentation completion
    - **Rationale**: Quality assurance and maintainability

---

## 6. Testing Requirements

### 6.1 Unit Testing

**Target**: ≥80% code coverage

| Component Type | Test Count | Coverage Target |
|---------------|------------|-----------------|
| Models (3.1) | 28 files | 90% (data validation critical) |
| Services (3.2) | 60+ files | 85% (business logic critical) |
| Utils & Helpers (3.3) | 25+ files | 90% (pure functions) |
| Providers (3.5) | 35+ files | 80% (state management) |
| Widgets (3.4, 3.6) | 50+ files | 75% (UI components) |

**Total Unit Tests**: ~200+ test files

### 6.2 Widget Testing

**Target**: All screens and custom widgets

| Feature | Widget Tests | Focus Areas |
|---------|-------------|-------------|
| Auth (3.6) | 4 files | Form validation, OAuth flows |
| Home (3.6) | 3 files | Tile rendering, pull-to-refresh |
| Calendar (3.6) | 2 files | Calendar interactions, event display |
| Gallery (3.6) | 3 files | Photo grid, upload, squish interactions |
| Registry (3.6) | 3 files | Item list, filters, purchase flow |
| Profile (3.6) | 7 files | Profile editing, baby management |
| Tiles (3.6) | 15 files | Individual tile widgets |

**Total Widget Tests**: ~40+ test files

### 6.3 Integration Testing

**Target**: All critical user flows

| Integration Test Suite | Test Count | Focus Areas |
|------------------------|------------|-------------|
| Authentication Flow | 5 tests | Login, signup, OAuth, logout |
| Data Services (3.2) | 20 tests | CRUD operations, caching, sync |
| Real-Time Subscriptions (3.2) | 15 tests | All realtime-enabled tables |
| Role-Based Access | 10 tests | Owner/follower permissions |
| Offline Functionality | 8 tests | Cache, sync, conflict resolution |
| Navigation | 5 tests | Deep linking, route guards |

**Total Integration Tests**: ~60+ scenarios

### 6.4 Database Testing

**Target**: All RLS policies and triggers

| Database Test Suite | Test Count | Focus Areas |
|---------------------|------------|-------------|
| RLS Policies (3.2) | 90+ tests | Owner/follower access, cross-baby isolation |
| Database Triggers | 30+ tests | Auto-increments, cascade deletes |
| Migration Tests | 10+ tests | Migration/rollback, data integrity |

**Total Database Tests**: ~130+ pgTAP tests

### 6.5 Accessibility Testing

**Target**: WCAG 2.1 Level AA compliance

| Accessibility Test Suite | Test Count | Focus Areas |
|-------------------------|------------|-------------|
| Semantic Labels | 20+ tests | Screen reader support |
| Color Contrast | 10+ tests | Minimum contrast ratios |
| Keyboard Navigation | 15+ tests | Tab order, focus management |
| Dynamic Type | 10+ tests | Font scaling (100%-200%) |
| RTL Support | 5+ tests | Right-to-left layouts |

**Total Accessibility Tests**: ~60+ tests

### 6.6 Performance Testing

**Target**: Meet performance benchmarks

| Performance Test Suite | Benchmarks | Acceptance Criteria |
|------------------------|-----------|---------------------|
| Screen Load Time | 10 tests | <500ms per screen |
| Tile Fetch Time | 15 tests | <300ms per tile |
| Real-Time Latency | 5 tests | <2 seconds update delay |
| Database Query Performance | 20 tests | <100ms for indexed queries |
| Image Loading | 5 tests | Progressive loading, thumbnails |

**Total Performance Tests**: ~55+ benchmarks

---

## 7. Summary Statistics

### Component Totals

| Category | Components | Test Files | Subsection |
|----------|-----------|------------|------------|
| **Models** | 28 models | 28 tests | 3.1 |
| **Services** | 20 services | 60+ tests | 3.2 |
| **Network Layer** | 8 components | 8 tests | 3.2 |
| **Middleware** | 3 components | 3 tests | 3.2 |
| **Utils & Helpers** | 25 utilities | 25 tests | 3.3 |
| **Theme & Styling** | 20 components | 20 tests | 3.4 |
| **State Management** | 35 providers | 35 tests | 3.5 |
| **UI Screens** | 30 screens | 30 tests | 3.6 |
| **Tile Widgets** | 15 tiles × 4 files | 60 files | 3.6 |
| **Core Widgets** | 10 widgets | 10 tests | 3.4, 3.6 |
| **Database** | Migrations + RLS | 130+ tests | 3.2 |
| **Edge Functions** | 3 functions | 3 tests | 3.2 |
| **Documentation** | 7 documents | N/A | 3.2, 3.4 |

### Grand Totals

- **Total Dart Components**: ~250+ files
- **Total Test Files**: ~400+ test files
- **Total Lines of Code**: ~50,000-70,000 LOC (estimated)
- **Test Coverage Target**: ≥80%
- **Development Timeline**: 22 weeks (5.5 months) with 3-4 developers

---

## 8. Architectural Rationale

### Why This Structure?

1. **Clean Architecture Compliance**
   - Clear separation: Domain → Data → Presentation
   - Independent layers enable parallel development
   - Testable components with dependency injection

2. **Tiles as First-Class Citizens**
   - Top-level `lib/tiles/` ensures maximum reusability
   - Tiles are self-contained with their own data layers
   - TileFactory enables dynamic, configuration-driven rendering

3. **Feature-Based Organization**
   - Each feature in `lib/features/` has complete vertical slice
   - Screens compose tiles rather than owning tile logic
   - Easy to add new features without affecting existing code

4. **Role-Based Access at Every Layer**
   - RLS policies at database level (Supabase)
   - Repository layer respects role context
   - Provider layer filters data by role
   - UI layer renders role-specific components

5. **Offline-First Architecture**
   - Cache Service provides transparent caching
   - SyncManager handles background synchronization
   - Conflict resolution for concurrent edits
   - Network failure handling with retry logic

6. **Comprehensive Testing Strategy**
   - Unit tests for business logic
   - Widget tests for UI components
   - Integration tests for user flows
   - RLS tests for security validation
   - Performance tests for benchmarks

---

## 9. Dependency Management

### External Package Dependencies

Based on the Document Dependency Matrix and architecture requirements:

**Core Dependencies**:
- `supabase_flutter` - Supabase client
- `riverpod` / `flutter_riverpod` - State management
- `go_router` - Navigation
- `hive` / `isar` - Local caching
- `shared_preferences` - Simple storage
- `flutter_secure_storage` - Secure storage

**UI Dependencies**:
- `cached_network_image` - Image caching
- `shimmer` - Loading skeletons
- `flutter_localizations` - Internationalization
- `intl` - Formatting

**Service Dependencies**:
- `image` - Image processing
- `share_plus` - Social sharing
- `table_calendar` - Calendar widget

**Monitoring Dependencies**:
- `sentry_flutter` - Crash reporting
- OneSignal SDK - Push notifications
- Firebase Analytics (optional) - Analytics

**Testing Dependencies**:
- `flutter_test` - Widget testing
- `mockito` / `mocktail` - Mocking
- `integration_test` - Integration testing

---

## 10. Next Steps

After completing the component identification:

1. **Review & Approval**: Technical leads review this document
2. **Estimation & Planning**: Break down components into sprint stories
3. **Team Assignment**: Assign features/components to developers
4. **Development Kickoff**: Begin Phase 1 (Foundation)
5. **Continuous Integration**: Set up CI/CD for automated testing
6. **Progress Tracking**: Regular reviews against this checklist

---

## Document Maintenance

This document should be updated:
- ✅ When new components are identified
- ✅ When architectural decisions change
- ✅ When implementation reveals missing dependencies
- ✅ After each sprint to reflect completed work
- ✅ When performance benchmarks are adjusted

---

**Document End**

**Version**: 1.0  
**Last Updated**: February 1, 2026  
**Status**: Complete and Ready for Review  
**Next Review Date**: March 1, 2026

