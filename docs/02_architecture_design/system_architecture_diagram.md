# System Architecture Diagram

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Architecture Team  
**Status**: Final  
**Section**: 1.3 - Architecture Design

## Executive Summary

This document presents the comprehensive system architecture for the Nonna App, a tile-based family social platform built with Flutter and Supabase. The architecture is designed to support real-time updates, role-based access control, scalable data management, and secure multi-tenant operations for up to 10,000 concurrent users while maintaining sub-500ms response times.

The architecture follows a mobile-first approach with a Backend-as-a-Service (BaaS) model, leveraging Supabase for authentication, database, storage, and real-time capabilities. The frontend implements a dynamic tile-based UI system with role-driven content aggregation and modular component design.

## References

This document is informed by and aligns with:

- `docs/00_requirement_gathering/business_requirements_document.md` - Business objectives and constraints
- `docs/00_requirement_gathering/user_personas_document.md` - User security and privacy needs
- `docs/00_requirement_gathering/success_metrics_kpis.md` - Performance and scalability targets
- `docs/01_technical_requirements/functional_requirements_specification.md` - Functional requirements
- `docs/01_technical_requirements/non_functional_requirements_specification.md` - Performance, security, scalability targets
- `docs/01_technical_requirements/data_model_diagram.md` - Database schema and relationships
- `discovery/01_discovery/02_technology_stack/Technology_Stack.md` - Technology stack decisions
- `discovery/01_discovery/04_technical_requirements/Tile_System_Design.md` - Tile architecture requirements
- `discovery/App_Structure_Nonna.md` - Folder structure and organization

---

## 1. High-Level Architecture Overview

### 1.1 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           EXTERNAL SERVICES LAYER                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   ┌──────────────┐ │
│  │   SendGrid   │    │  OneSignal   │    │   Sentry     │   │  Analytics   │ │
│  │   (Email)    │    │    (Push)    │    │  (Logging)   │   │  (Optional)  │ │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘   └──────┬───────┘ │
│         │                   │                   │                   │         │
└─────────┼───────────────────┼───────────────────┼───────────────────┼─────────┘
          │                   │                   │                   │
          └───────────────────┼───────────────────┼───────────────────┘
                              │                   │
          ┌───────────────────▼───────────────────▼────────────────────┐
          │                                                             │
          │              SUPABASE BACKEND LAYER                         │
          │                                                             │
          │  ┌─────────────────────────────────────────────────────┐   │
          │  │           Supabase Edge Functions                   │   │
          │  │  • Invitation Processing & Email Sending            │   │
          │  │  • Notification Trigger & Push Delivery             │   │
          │  │  • Image Processing & Thumbnail Generation          │   │
          │  │  • Analytics Event Aggregation                      │   │
          │  └─────────────┬──────────────────┬────────────────────┘   │
          │                │                  │                        │
          │  ┌─────────────▼─────────┐  ┌────▼──────────────────────┐ │
          │  │    Supabase Auth      │  │   Supabase Storage        │ │
          │  │  • JWT Authentication │  │  • Photo Storage          │ │
          │  │  • Email/Password     │  │  • Thumbnail Storage      │ │
          │  │  • OAuth (Google/FB)  │  │  • Profile Photos         │ │
          │  │  • Session Management │  │  • CDN Delivery           │ │
          │  └─────────────┬─────────┘  └───────────────────────────┘ │
          │                │                                            │
          │  ┌─────────────▼──────────────────────────────────────┐    │
          │  │          PostgreSQL Database                       │    │
          │  │  • 28 Tables (1 auth + 27 public)                 │    │
          │  │  • Row-Level Security (RLS) Policies              │    │
          │  │  • Realtime Subscriptions                         │    │
          │  │  • Database Triggers & Constraints                │    │
          │  │  • Performance Indexes                            │    │
          │  └────────────────────────────────────────────────────┘    │
          │                                                             │
          └─────────────────────────┬───────────────────────────────────┘
                                    │
                                    │ HTTPS/WSS (TLS 1.3)
                                    │
          ┌─────────────────────────▼───────────────────────────────────┐
          │                                                             │
          │              FLUTTER MOBILE APP LAYER                       │
          │                                                             │
          │  ┌──────────────────────────────────────────────────────┐  │
          │  │               Navigation Layer                        │  │
          │  │  • GoRouter (Deep Links, Route Guards)               │  │
          │  │  • Role-Based Navigation                             │  │
          │  └─────────────────────────┬────────────────────────────┘  │
          │                            │                                │
          │  ┌─────────────────────────▼────────────────────────────┐  │
          │  │            Presentation Layer                         │  │
          │  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │  │
          │  │  │   Screens    │  │    Tiles     │  │   Widgets   │ │  │
          │  │  │  • Home      │  │  • Dynamic   │  │  • Reusable │ │  │
          │  │  │  • Calendar  │  │  • Role-     │  │  • Shared   │ │  │
          │  │  │  • Gallery   │  │    Aware     │  │  • Themed   │ │  │
          │  │  │  • Registry  │  │  • Cached    │  │             │ │  │
          │  │  └──────────────┘  └──────────────┘  └─────────────┘ │  │
          │  └─────────────────────────┬────────────────────────────┘  │
          │                            │                                │
          │  ┌─────────────────────────▼────────────────────────────┐  │
          │  │         State Management Layer (Riverpod)            │  │
          │  │  • Auth Providers                                    │  │
          │  │  • Tile Providers                                    │  │
          │  │  • Feature Providers                                 │  │
          │  │  • Cache Providers                                   │  │
          │  └─────────────────────────┬────────────────────────────┘  │
          │                            │                                │
          │  ┌─────────────────────────▼────────────────────────────┐  │
          │  │           Business Logic Layer                        │  │
          │  │  • Use Cases                                         │  │
          │  │  • Domain Models                                     │  │
          │  │  • Business Rules                                    │  │
          │  └─────────────────────────┬────────────────────────────┘  │
          │                            │                                │
          │  ┌─────────────────────────▼────────────────────────────┐  │
          │  │              Data Layer                              │  │
          │  │  ┌────────────────┐  ┌────────────────┐             │  │
          │  │  │  Repositories  │  │  Data Sources  │             │  │
          │  │  │  • Abstract    │  │  • Remote      │             │  │
          │  │  │    Contracts   │  │  • Local       │             │  │
          │  │  │                │  │    Cache       │             │  │
          │  │  └────────────────┘  └────────────────┘             │  │
          │  └─────────────────────────┬────────────────────────────┘  │
          │                            │                                │
          │  ┌─────────────────────────▼────────────────────────────┐  │
          │  │           Infrastructure Layer                        │  │
          │  │  • Supabase Client                                   │  │
          │  │  • Cache Service (Hive/Isar)                         │  │
          │  │  • Storage Service                                   │  │
          │  │  • Realtime Service                                  │  │
          │  │  • Notification Service                              │  │
          │  │  • Analytics Service                                 │  │
          │  └──────────────────────────────────────────────────────┘  │
          │                                                             │
          └─────────────────────────────────────────────────────────────┘
                                    │
                                    │
          ┌─────────────────────────▼───────────────────────────────────┐
          │                                                             │
          │                  CLIENT DEVICES                             │
          │                                                             │
          │  ┌──────────────────┐        ┌──────────────────┐          │
          │  │   iOS Devices    │        │ Android Devices  │          │
          │  │  • iPhone 12+    │        │  • Android 10+   │          │
          │  │  • iPad          │        │  • Samsung       │          │
          │  │                  │        │  • Pixel         │          │
          │  └──────────────────┘        └──────────────────┘          │
          │                                                             │
          └─────────────────────────────────────────────────────────────┘
```

### 1.2 Architecture Style

**Primary Pattern**: **Mobile-First with Backend-as-a-Service (BaaS)**

**Key Characteristics**:
- **Client-Server Architecture**: Flutter mobile app as client, Supabase as backend
- **Layered Architecture**: Clear separation of concerns with distinct layers
- **Event-Driven**: Real-time updates via WebSocket subscriptions
- **Multi-Tenant**: Baby profiles as tenant boundaries with RLS enforcement
- **Stateful Client**: Local caching with server synchronization

**Design Philosophy**:
- **Mobile-First**: Optimized for mobile performance and offline capabilities
- **Security by Default**: RLS policies, JWT authentication, encrypted communications
- **Scalability**: Horizontal scaling via Supabase, efficient caching, pagination
- **Modularity**: Tile-based UI, feature-based code organization
- **Performance**: Sub-500ms response times, real-time updates within 2 seconds

---

## 2. Component Architecture

### 2.1 Frontend Architecture (Flutter Mobile App)

#### 2.1.1 Layer Structure

**1. Presentation Layer**
- **Purpose**: User interface and user interaction
- **Components**:
  - **Screens**: Full-page views (Home, Calendar, Gallery, Registry, Profile)
  - **Tiles**: Reusable, parameterized widgets with embedded data logic
  - **Widgets**: Shared UI components (buttons, cards, inputs)
- **Technology**: Flutter Widgets, Material Design
- **State**: Managed by Riverpod providers
- **Responsibilities**:
  - Render UI based on state
  - Handle user input
  - Navigation
  - Display loading/error states

**2. State Management Layer**
- **Purpose**: Manage application state and business logic orchestration
- **Technology**: Riverpod (StateNotifier, AsyncNotifier, FutureProvider)
- **Components**:
  - **Auth Providers**: Authentication state, session management
  - **Tile Providers**: Tile data fetching, caching, real-time updates
  - **Feature Providers**: Feature-specific state (calendar, gallery, registry)
  - **Global Providers**: App configuration, theme, user preferences
- **Responsibilities**:
  - State lifecycle management
  - Dependency injection
  - Data flow coordination
  - Cache invalidation

**3. Business Logic Layer**
- **Purpose**: Domain logic and business rules
- **Components**:
  - **Use Cases**: Single-responsibility operations (CreateBabyProfile, UploadPhoto)
  - **Domain Models**: Pure data models without framework dependencies
  - **Validators**: Input validation, business rule enforcement
- **Responsibilities**:
  - Enforce business rules
  - Coordinate data operations
  - Transform data between layers

**4. Data Layer**
- **Purpose**: Data access and persistence
- **Components**:
  - **Repositories**: Abstract interfaces for data operations
  - **Repository Implementations**: Concrete data access implementations
  - **Remote Data Sources**: Supabase API calls
  - **Local Data Sources**: Hive/Isar cache operations
  - **Mappers**: Convert between DTOs and domain models
- **Responsibilities**:
  - Data fetching and caching
  - API communication
  - Data transformation
  - Cache management

**5. Infrastructure Layer**
- **Purpose**: Low-level services and utilities
- **Components**:
  - **Supabase Client**: Wrapper for Supabase SDK
  - **Cache Service**: Hive/Isar local storage
  - **Storage Service**: Photo upload/download
  - **Realtime Service**: WebSocket subscriptions
  - **Notification Service**: Push notification handling
  - **Analytics Service**: Usage tracking
- **Responsibilities**:
  - Third-party service integration
  - Low-level data persistence
  - Network communication
  - Error handling and logging

#### 2.1.2 Tile-Based UI Architecture

**Tile System Overview**:
- Tiles are self-contained, parameterized widgets
- Each tile handles its own data fetching, caching, and rendering
- Tiles are instantiated by TileFactory based on Supabase configurations
- Role-based behavior: owners see editable tiles, followers see aggregated read-only tiles

**Tile Structure**:
```
lib/tiles/
├── core/                          # Tile infrastructure
│   ├── models/
│   │   ├── tile_config.dart      # Configuration model
│   │   ├── tile_params.dart      # Query parameters
│   │   └── tile_state.dart       # Common state (loading/error/data)
│   ├── widgets/
│   │   ├── tile_factory.dart     # Instantiates tiles by type
│   │   ├── base_tile.dart        # Abstract base for all tiles
│   │   └── tile_container.dart   # Common wrapper (padding, styling)
│   └── providers/
│       └── tile_config_provider.dart  # Fetches configs from Supabase
├── upcoming_events/               # Example tile
│   ├── models/
│   │   └── upcoming_event.dart
│   ├── providers/
│   │   └── upcoming_events_provider.dart
│   ├── data/
│   │   └── datasources/
│   │       ├── remote/
│   │       │   └── upcoming_events_datasource.dart
│   │       └── local/
│   │           └── upcoming_events_cache.dart
│   └── widgets/
│       └── upcoming_events_tile.dart
└── [other tiles...]
```

**Tile Types**:
1. **Upcoming Events**: Shows upcoming events with RSVP status
2. **Recent Photos**: Grid of recent photos with squish functionality
3. **Registry Highlights**: Featured registry items with purchase status
4. **Notifications**: Recent in-app notifications
5. **Invites Status**: Pending invitations (owner-only)
6. **RSVP Tasks**: Events awaiting RSVP (follower)
7. **Due Date Countdown**: Baby arrival countdown
8. **Recent Purchases**: Latest registry purchases
9. **Engagement Recap**: Activity summary
10. **Gallery Favorites**: Most liked photos
11. **Checklist**: Onboarding tasks (owner-only)
12. **Storage Usage**: Storage quota display (owner-only)
13. **System Announcements**: Platform updates
14. **New Followers**: Recent follower additions (owner-only)

**Tile Data Flow**:
1. Screen requests tiles from TileFactory based on role
2. TileFactory reads tile configs from Supabase (cached)
3. Factory instantiates tile widgets with parameters (role, babyIds, limits)
4. Each tile's provider fetches data:
   - Check local cache first
   - If stale/missing, query Supabase (scoped by RLS)
   - For owners: query per baby
   - For followers: aggregate across all followed babies
5. Provider updates state, caches data
6. Tile widget renders based on state

#### 2.1.3 Navigation Architecture

**Technology**: GoRouter

**Route Structure**:
```
/
├── /login
├── /signup
├── /role-selection
├── /home
├── /calendar
│   └── /calendar/:eventId
├── /gallery
│   └── /gallery/:photoId
├── /registry
│   └── /registry/:itemId
├── /photo-gallery
├── /fun
├── /profile
│   └── /profile/edit
└── /baby-profile
    ├── /baby-profile/create
    └── /baby-profile/:babyId/edit
```

**Navigation Guards**:
- **Auth Guard**: Redirects unauthenticated users to login
- **Role Guard**: Ensures user has appropriate role for baby profile access
- **Email Verification Guard**: Prompts unverified users to verify email

**Deep Linking**:
- Invitation acceptance: `nonna://invite?token=<token>`
- Event details: `nonna://event/:eventId`
- Photo view: `nonna://photo/:photoId`

### 2.2 Backend Architecture (Supabase)

#### 2.2.1 Authentication & Authorization

**Supabase Auth**:
- JWT-based authentication
- Email/password and OAuth 2.0 (Google, Facebook)
- Session management with 30-day expiry
- Email verification with 24-hour token expiry
- Password reset with 1-hour token expiry
- Secure token storage (iOS Keychain, Android Keystore)

**Row-Level Security (RLS)**:
- Enforced at database level for all tables
- Policies based on user role and baby profile membership
- Example policies:
  - **Photos**: Owners can CRUD, followers can read/comment
  - **Events**: Owners can CRUD, followers can read/RSVP/comment
  - **Registry**: Owners can CRUD, followers can read/purchase
  - **Invitations**: Only owners can create, recipients can accept

**Role Model**:
- Roles are per baby profile (stored in `baby_memberships`)
- User can have different roles for different babies
- Two roles: **Owner** (full CRUD) and **Follower** (read + interact)
- Maximum 2 owners per baby profile (enforced at database level)

#### 2.2.2 Database Architecture

**PostgreSQL Schema**:
- **Schema Separation**: `auth` (Supabase-managed) and `public` (application)
- **Multi-Tenant**: Baby profile as tenant boundary
- **28 Tables**: 1 auth, 27 public
- **50+ Relationships**: Foreign keys with CASCADE behavior
- **25+ Indexes**: On foreign keys and hot query paths
- **90+ RLS Policies**: Granular access control
- **30+ Triggers**: Auto-update timestamps, stat counters, realtime notifications

**Key Tables**:
1. **Identity**: `profiles`, `user_stats`
2. **Baby Profiles**: `baby_profiles`, `baby_memberships`
3. **Invitations**: `invitations`
4. **Content**: `events`, `photos`, `registry_items`
5. **Interactions**: `event_comments`, `event_rsvps`, `photo_comments`, `photo_squishes`, `registry_purchases`
6. **Gamification**: `name_suggestions`, `gender_votes`, `birth_date_predictions`
7. **Notifications**: `notifications`, `notification_preferences`
8. **Tile System**: `tile_configs`, `screen_configs`
9. **Update Tracking**: `owner_update_markers`

**Performance Optimizations**:
- Indexed foreign keys (`baby_profile_id`, `user_id`, `created_at`)
- Composite indexes for common queries
- Partial indexes for filtered queries
- BRIN indexes for time-series data
- Materialized views for complex aggregations (future)

**Data Retention**:
- Soft delete pattern with `deleted_at` timestamp
- Data retained for 7 years for compliance
- Automated cleanup via scheduled Edge Function

#### 2.2.3 File Storage

**Supabase Storage**:
- Bucket structure: `baby_profiles`, `photos`, `thumbnails`
- RLS policies on buckets (owners can upload/delete)
- CDN-backed delivery for global performance
- Client-side compression before upload
- Server-side thumbnail generation via Edge Function

**Upload Process**:
1. Client validates file type (JPEG/PNG) and size (max 10MB)
2. Client compresses image if needed
3. Client uploads to Supabase Storage with signed URL
4. Edge Function triggers on upload:
   - Generates thumbnail (300x300)
   - Stores thumbnail in separate bucket
   - Creates database entry with URLs
5. Client receives URLs and displays photo

#### 2.2.4 Realtime Architecture

**Supabase Realtime**:
- WebSocket-based real-time updates
- Built on PostgreSQL logical replication
- Selective subscriptions to reduce bandwidth

**Subscription Strategy**:

**For Owners**:
- Subscribe to tables filtered by owned baby profiles:
  ```sql
  supabase
    .channel('baby_profile:<babyId>')
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'photos',
      filter: `baby_profile_id=eq.${babyId}`
    }, (payload) => { /* handle update */ })
  ```

**For Followers**:
- Subscribe to custom channel broadcasting max timestamp:
  ```sql
  supabase
    .channel(`user_updates:${userId}`)
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'owner_update_markers',
      filter: `baby_profile_id=in.(${followedBabyIds.join(',')})`
    }, (payload) => { /* invalidate cache, refetch */ })
  ```

**Update Markers**:
- `owner_update_markers` table tracks last update timestamp per baby profile
- Updated automatically via database trigger on any content change
- Followers check marker timestamp to determine if cache is stale

#### 2.2.5 Edge Functions

**Supabase Edge Functions** (TypeScript/Deno):

1. **Invitation Processing**:
   - **Trigger**: Owner creates invitation
   - **Actions**:
     - Generate secure token
     - Set 7-day expiration
     - Send email via SendGrid
     - Create invitation record

2. **Push Notification Delivery**:
   - **Trigger**: Database event (new photo, event, comment, etc.)
   - **Actions**:
     - Determine recipients based on role
     - Check notification preferences
     - Send push via OneSignal
     - Create in-app notification record

3. **Image Processing**:
   - **Trigger**: Photo upload to Storage
   - **Actions**:
     - Validate image format
     - Generate thumbnail
     - Store thumbnail
     - Update database with URLs

4. **Analytics Aggregation** (Optional):
   - **Trigger**: Scheduled (daily)
   - **Actions**:
     - Aggregate usage metrics
     - Calculate engagement scores
     - Update analytics tables

### 2.3 External Services Integration

#### 2.3.1 SendGrid (Email)

**Purpose**: Transactional email delivery

**Use Cases**:
- Welcome emails after signup
- Email verification
- Password reset
- Invitation emails (with deep links)
- Weekly/monthly digest emails

**Integration**:
- Called from Edge Functions
- API key stored in Edge Function environment variables
- Templates managed in SendGrid dashboard
- Delivery tracking and bounce handling

#### 2.3.2 OneSignal (Push Notifications)

**Purpose**: Push notification delivery

**Use Cases**:
- New photo uploaded
- New event created
- Event RSVP received
- Registry item purchased
- New comment added
- New follower joined

**Integration**:
- Called from Edge Functions
- App registers device with OneSignal on first launch
- User can opt-in/opt-out via notification preferences
- Segmentation by user ID for targeted delivery

#### 2.3.3 Sentry (Error Tracking & Monitoring)

**Purpose**: Error tracking, performance monitoring, crash reporting

**Integration**:
- Flutter SDK integrated in app
- Captures unhandled exceptions
- Performance traces for critical operations
- User feedback collection
- Release tracking for debugging

#### 2.3.4 Analytics (Optional)

**Purpose**: Product analytics and user behavior tracking

**Options**: Amplitude, Mixpanel, or lightweight alternative

**Use Cases**:
- User acquisition tracking
- Feature adoption rates
- Retention analysis
- Funnel analysis

---

## 3. Data Flow Architecture

### 3.1 Authentication Flow

```
┌────────────┐       ┌────────────┐       ┌────────────┐       ┌────────────┐
│   User     │──────▶│   Flutter  │──────▶│  Supabase  │──────▶│  Database  │
│  Device    │       │    App     │       │    Auth    │       │ (profiles) │
└────────────┘       └────────────┘       └────────────┘       └────────────┘
      │                    │                     │                     │
      │  1. Enter email    │                     │                     │
      │     & password     │                     │                     │
      │───────────────────▶│                     │                     │
      │                    │  2. Call            │                     │
      │                    │     signIn()        │                     │
      │                    │────────────────────▶│                     │
      │                    │                     │  3. Validate        │
      │                    │                     │     credentials     │
      │                    │                     │────────────────────▶│
      │                    │                     │◀────────────────────│
      │                    │                     │  4. Return user     │
      │                    │  5. JWT token       │                     │
      │                    │◀────────────────────│                     │
      │                    │  6. Store token     │                     │
      │                    │     in secure       │                     │
      │                    │     storage         │                     │
      │  7. Navigate to    │                     │                     │
      │     home screen    │                     │                     │
      │◀───────────────────│                     │                     │
```

### 3.2 Tile Data Loading Flow

```
┌────────────┐       ┌────────────┐       ┌────────────┐       ┌────────────┐
│   Screen   │──────▶│    Tile    │──────▶│   Tile     │──────▶│  Supabase  │
│  (Home)    │       │  Factory   │       │  Provider  │       │  Database  │
└────────────┘       └────────────┘       └────────────┘       └────────────┘
      │                    │                     │                     │
      │  1. Request tiles  │                     │                     │
      │     for role       │                     │                     │
      │───────────────────▶│                     │                     │
      │                    │  2. Read tile       │                     │
      │                    │     configs         │                     │
      │                    │────────────────────▶│                     │
      │                    │                     │  3. Query configs   │
      │                    │                     │     (from cache)    │
      │                    │                     │────────────────────▶│
      │                    │                     │◀────────────────────│
      │                    │◀────────────────────│  4. Return configs  │
      │                    │  5. Instantiate     │                     │
      │                    │     tiles           │                     │
      │                    │                     │                     │
      │                    │  6. Each tile       │                     │
      │                    │     fetches data    │                     │
      │                    │────────────────────▶│                     │
      │                    │                     │  7. Check cache     │
      │                    │                     │     first           │
      │                    │                     │                     │
      │                    │                     │  8. If stale,       │
      │                    │                     │     query DB        │
      │                    │                     │────────────────────▶│
      │                    │                     │◀────────────────────│
      │                    │                     │  9. Return data     │
      │                    │◀────────────────────│                     │
      │  10. Render tiles  │                     │                     │
      │◀───────────────────│                     │                     │
```

### 3.3 Real-Time Update Flow

```
┌────────────┐       ┌────────────┐       ┌────────────┐       ┌────────────┐
│  Owner     │──────▶│  Supabase  │──────▶│  Realtime  │──────▶│ Follower   │
│  Device    │       │  Database  │       │  Service   │       │  Device    │
└────────────┘       └────────────┘       └────────────┘       └────────────┘
      │                    │                     │                     │
      │  1. Upload photo   │                     │                     │
      │───────────────────▶│                     │                     │
      │                    │  2. Insert photo    │                     │
      │                    │     record          │                     │
      │                    │                     │                     │
      │                    │  3. Trigger fires   │                     │
      │                    │     (update marker) │                     │
      │                    │                     │                     │
      │                    │  4. Broadcast       │                     │
      │                    │     change          │                     │
      │                    │────────────────────▶│                     │
      │                    │                     │  5. Push update     │
      │                    │                     │     to subscriber   │
      │                    │                     │────────────────────▶│
      │                    │                     │                     │  6. Invalidate
      │                    │                     │                     │     cache
      │                    │                     │                     │
      │                    │  7. Refetch data    │                     │
      │                    │◀─────────────────────────────────────────│
      │                    │                     │                     │
      │                    │  8. Return updated  │                     │
      │                    │     data            │                     │
      │                    │─────────────────────────────────────────▶│
      │                    │                     │                     │  9. Update UI
```

### 3.4 Photo Upload Flow

```
┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐
│  Owner     │  │   Flutter  │  │  Supabase  │  │    Edge    │  │  Follower  │
│  Device    │  │    App     │  │  Storage   │  │  Function  │  │  Device    │
└────────────┘  └────────────┘  └────────────┘  └────────────┘  └────────────┘
      │               │               │               │               │
      │  1. Select    │               │               │               │
      │     photo     │               │               │               │
      │──────────────▶│               │               │               │
      │               │  2. Validate  │               │               │
      │               │     type/size │               │               │
      │               │               │               │               │
      │               │  3. Compress  │               │               │
      │               │     image     │               │               │
      │               │               │               │               │
      │               │  4. Upload to │               │               │
      │               │     Storage   │               │               │
      │               │──────────────▶│               │               │
      │               │               │  5. Trigger   │               │
      │               │               │     function  │               │
      │               │               │──────────────▶│               │
      │               │               │               │  6. Generate  │
      │               │               │               │     thumbnail │
      │               │               │               │               │
      │               │               │  7. Store     │               │
      │               │               │     thumbnail │               │
      │               │               │◀──────────────│               │
      │               │               │               │  8. Create DB │
      │               │               │               │     record    │
      │               │               │               │               │
      │               │  9. Return    │               │               │  10. Realtime
      │               │     URLs      │               │               │      update
      │               │◀──────────────────────────────│──────────────▶│
      │               │               │               │               │
      │  11. Display  │               │               │               │  12. Display
      │      photo    │               │               │               │      photo
      │◀──────────────│               │               │               │
```

---

## 4. Security Architecture

### 4.1 Authentication Security

**JWT Token Management**:
- Tokens issued by Supabase Auth
- 30-day expiry with automatic refresh
- Stored securely in iOS Keychain / Android Keystore
- Transmitted via HTTPS only
- Included in all API requests via Authorization header

**Password Security**:
- Minimum 6 characters
- At least one number or special character
- Hashed with bcrypt before storage
- Password reset with 1-hour token expiry
- Rate limiting on login attempts (5 per 15 minutes)

**OAuth Security**:
- OAuth 2.0 for Google and Facebook
- Redirect URIs validated
- State parameter for CSRF protection
- User can revoke OAuth access

### 4.2 Authorization Security

**Row-Level Security (RLS)**:
- Enabled on all tables
- Policies based on user ID and role
- Enforced at database level (cannot be bypassed)
- Tested with pgTAP test suite

**Example RLS Policy**:
```sql
-- Photos: Owners can CRUD, followers can read
CREATE POLICY "Owners can CRUD photos"
  ON photos
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM baby_memberships
      WHERE baby_memberships.baby_profile_id = photos.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Followers can read photos"
  ON photos
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM baby_memberships
      WHERE baby_memberships.baby_profile_id = photos.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND photos.deleted_at IS NULL
  );
```

### 4.3 Data Security

**Encryption**:
- **At Rest**: AES-256 encryption for database and storage
- **In Transit**: TLS 1.3 for all network communications
- **Client-Side**: Secure storage for tokens (Keychain/Keystore)

**Data Privacy**:
- Invite-only access model (no public content)
- Multi-tenant isolation via RLS
- Soft delete with 7-year retention
- User data export/deletion on request

**Rate Limiting & Abuse Prevention**:
- Login attempts: 5 per 15 minutes
- Invitation sends: 10 per hour
- Comment creation: 20 per hour
- Photo uploads: 50 per day
- Enforced at Edge Function level

### 4.4 Network Security

**API Security**:
- All requests require JWT token
- Service role key used only in Edge Functions (never exposed to client)
- CORS configured for allowed origins only
- API rate limiting via Supabase

**Storage Security**:
- Signed URLs for upload/download
- URLs expire after 1 hour
- Bucket policies enforce ownership
- CDN respects signed URL expiry

---

## 5. Performance Architecture

### 5.1 Performance Targets

| Metric | Target | Implementation |
|--------|--------|----------------|
| App Load Time | < 2 seconds | Local cache, lazy loading, code splitting |
| Screen Load Time | < 500ms | Cache-first strategy, pagination, indexes |
| Photo Upload Time | < 5 seconds | Client-side compression, CDN delivery |
| Real-Time Update Latency | < 2 seconds | Supabase Realtime, scoped subscriptions |
| API Response Time | < 500ms | Database indexes, query optimization |
| Crash Rate | < 1% | Error handling, Sentry monitoring |
| Uptime SLA | 99.5% | Supabase infrastructure, failover |

### 5.2 Caching Strategy

**Multi-Level Caching**:

1. **Memory Cache** (Riverpod keepAlive):
   - Provider state persists across navigation
   - Cleared on app restart

2. **Local Storage Cache** (Hive/Isar):
   - Tile data cached with TTL (default 5 minutes)
   - Tile configs cached with TTL (default 1 hour)
   - User profile cached with TTL (default 30 minutes)
   - Photos cached indefinitely (invalidate on delete)

3. **CDN Cache** (Supabase Storage):
   - Images cached at edge locations
   - Reduces latency for global users

**Cache Invalidation**:
- **Time-Based**: TTL expiry triggers refetch
- **Event-Based**: Real-time updates trigger invalidation
- **Manual**: User pull-to-refresh
- **Marker-Based**: `owner_update_markers` for follower caching

### 5.3 Database Optimization

**Indexing Strategy**:
- Primary keys: Auto-indexed
- Foreign keys: Indexed for joins
- Timestamp fields: Indexed for sorting
- Composite indexes: For multi-column queries
- Partial indexes: For filtered queries (e.g., non-deleted records)

**Query Optimization**:
- Select only needed columns (avoid SELECT *)
- Pagination for large result sets (limit, offset)
- Aggregate queries pushed to database
- Materialized views for complex analytics (future)

**Connection Pooling**:
- Supabase manages connection pool
- Optimal pool size for concurrent connections
- Connection reuse to reduce overhead

### 5.4 Image Optimization

**Client-Side**:
- Compress images before upload (target < 1MB)
- Resize large images to max 2000x2000
- Use Flutter `image` package for optimization

**Server-Side**:
- Generate thumbnails (300x300) via Edge Function
- Store thumbnails separately for fast gallery loading
- Use WebP format for better compression (future)

**Delivery**:
- CDN-backed delivery via Supabase Storage
- Cache images on device after first load
- Preload next page images for smooth scrolling

### 5.5 Lazy Loading & Pagination

**List Views**:
- Use `ListView.builder` for on-demand rendering
- Pagination with page size of 30 items
- Infinite scroll for seamless UX

**Image Loading**:
- Use `CachedNetworkImage` for automatic caching
- Show shimmer placeholder during load
- Preload visible + 1 page for smooth scrolling

**Tile Loading**:
- Load only visible tiles on screen
- Defer off-screen tile data fetching
- Use `AutomaticKeepAliveClientMixin` for scroll position preservation

---

## 6. Scalability Architecture

### 6.1 Horizontal Scaling

**Client Scaling**:
- Stateless client (no server dependency)
- All state stored locally or in Supabase
- Unlimited client devices supported

**Backend Scaling** (Supabase):
- Database: Horizontal scaling via read replicas (future)
- Storage: Distributed via CDN
- Edge Functions: Auto-scaling serverless
- Realtime: Connection pooling and load balancing

### 6.2 Data Partitioning

**Current**: Single database with multi-tenant isolation via RLS

**Future** (if needed at scale):
- Partition tables by `baby_profile_id` (range or hash)
- Separate read replicas for analytics queries
- Time-series partitioning for photos/events

### 6.3 Load Testing Strategy

**Target**: 10,000 concurrent users

**Scenarios**:
1. **Peak Load**: 10,000 users browsing simultaneously
2. **Burst Load**: 5,000 photos uploaded in 1 hour
3. **Real-Time Stress**: 1,000 concurrent subscriptions
4. **Database Stress**: 50,000 queries per second

**Tools**:
- Apache JMeter for API load testing
- Supabase dashboard for database metrics
- Sentry for error rate monitoring

---

## 7. Reliability & Resilience

### 7.1 Error Handling

**Client-Side**:
- Try-catch blocks for all async operations
- User-friendly error messages (no stack traces)
- Retry logic for transient failures (3 retries with exponential backoff)
- Offline mode with queued operations

**Server-Side**:
- Database constraints for data integrity
- Edge Function error logging to Sentry
- Graceful degradation (e.g., skip push notification if OneSignal fails)

### 7.2 Monitoring & Alerting

**Monitoring Stack**:
- **Sentry**: Error tracking, performance monitoring
- **Supabase Dashboard**: Database metrics, query performance
- **Edge Function Logs**: Structured logging with correlation IDs

**Alerts**:
- Critical errors (crash rate > 1%)
- Performance degradation (API response > 1s)
- Database issues (query time > 500ms)
- Storage quota exceeded

### 7.3 Disaster Recovery

**Backup Strategy**:
- Database: Daily automated backups (7-day retention)
- Storage: Redundant storage across availability zones
- Code: Version control with Git

**Recovery Procedures**:
- Database restore from backup (RPO: 24 hours, RTO: 2 hours)
- Storage recovery from redundant copies (RPO: 0, RTO: 1 hour)
- Application redeploy from Git (RTO: 30 minutes)

---

## 8. Development & Deployment Architecture

### 8.1 Environment Strategy

**Environments**:
1. **Development**: Local Supabase instance, simulator/emulator
2. **Staging**: Cloud Supabase (staging project), TestFlight/Internal Testing
3. **Production**: Cloud Supabase (prod project), App Store/Play Store

**Configuration**:
- Environment variables for API keys, URLs
- Separate Supabase projects per environment
- Feature flags for gradual rollouts

### 8.2 CI/CD Pipeline

**GitHub Actions Workflow**:

1. **On Push/PR**:
   - Run linter (`flutter analyze`)
   - Run tests (`flutter test`)
   - Run integration tests (`flutter test integration_test`)
   - Security scan (dependency check)

2. **On Merge to Main**:
   - Build iOS and Android apps
   - Upload to TestFlight/Internal Testing
   - Run smoke tests on real devices

3. **On Tag (v*)**:
   - Build release builds
   - Submit to App Store and Play Store
   - Deploy database migrations to production
   - Tag release in Sentry

**Database Migrations**:
- Managed via Supabase CLI
- Versioned migrations in `supabase/migrations/`
- Automatically applied in CI/CD pipeline
- Rollback capability with down migrations

---

## 9. Architecture Decision Records (ADRs)

### ADR-001: Flutter for Cross-Platform Mobile

**Decision**: Use Flutter for iOS and Android development

**Rationale**:
- Single codebase for iOS and Android
- High performance (compiled to native)
- Rich widget library and Material Design support
- Strong community and ecosystem
- Cost-effective development

**Consequences**:
- Platform-specific features may require custom implementation
- Web and desktop support available but not prioritized for MVP

---

### ADR-002: Supabase as Backend-as-a-Service

**Decision**: Use Supabase for backend (database, auth, storage, realtime)

**Rationale**:
- PostgreSQL provides relational data model needed for complex relationships
- Built-in authentication with JWT
- Row-Level Security for multi-tenant isolation
- Real-time subscriptions for live updates
- Cost-effective with generous free tier
- Open-source with no vendor lock-in

**Consequences**:
- Dependent on Supabase infrastructure and reliability
- Custom backend logic limited to Edge Functions (serverless)

---

### ADR-003: Riverpod for State Management

**Decision**: Use Riverpod for state management

**Rationale**:
- Compile-time safety and better testability than Provider
- Dependency injection without context
- Automatic disposal and lifecycle management
- Seamless integration with async operations and streams
- Better performance with granular rebuilds

**Consequences**:
- Learning curve for developers unfamiliar with Riverpod
- Migration from Provider/BLoC requires refactoring

---

### ADR-004: Tile-Based UI Architecture

**Decision**: Implement dynamic tile-based UI system

**Rationale**:
- Modular and reusable components
- Dynamic configuration via Supabase (no app rebuild for UI changes)
- Role-based content aggregation (owners vs followers)
- Performance optimized with caching and lazy loading
- Supports A/B testing and personalization

**Consequences**:
- Increased initial complexity in implementation
- Requires robust caching and realtime update strategy
- Testing requires comprehensive tile coverage

---

### ADR-005: Multi-Level Caching Strategy

**Decision**: Implement memory, local storage, and CDN caching

**Rationale**:
- Reduces server load and costs
- Improves user experience with instant data access
- Enables offline functionality
- Meets performance targets (< 500ms screen load)

**Consequences**:
- Cache invalidation complexity
- Stale data risk (mitigated by TTL and realtime updates)
- Increased client-side storage usage

---

## 10. Future Architecture Considerations

### 10.1 Potential Enhancements

1. **Web Application**:
   - Flutter web or separate React/Vue frontend
   - Shared Supabase backend
   - Same tile-based architecture

2. **AI-Powered Features**:
   - Photo auto-tagging via ML models
   - Smart event suggestions based on patterns
   - Predictive analytics for engagement

3. **Advanced Analytics**:
   - Materialized views for complex queries
   - Separate analytics database (ClickHouse/BigQuery)
   - Real-time dashboards for owners

4. **Third-Party Integrations**:
   - Calendar sync (Google Calendar, Apple Calendar)
   - Registry partnerships (Amazon, Target)
   - Health data integration (Apple Health)

5. **Messaging System**:
   - Direct messaging between users
   - Group chats per baby profile
   - Message encryption

### 10.2 Migration Paths

**Database Scaling**:
- Current: Single PostgreSQL instance with RLS
- Future: Sharded database with read replicas
- Migration: Gradual, non-breaking schema changes

**Serverless to Dedicated Backend**:
- Current: Edge Functions for backend logic
- Future: Node.js/Python backend for complex workflows
- Migration: Gradual function migration

**Realtime Optimization**:
- Current: Supabase Realtime for all updates
- Future: Custom WebSocket server for high-frequency updates
- Migration: Maintain Supabase for low-frequency, migrate high-frequency

---

## 11. Architecture Validation

### 11.1 Alignment with Requirements

| Requirement | Architecture Component | Status |
|-------------|------------------------|--------|
| **Business Requirements** | | |
| Private family social platform | Multi-tenant with RLS, invite-only | ✅ |
| 10,000 concurrent users | Supabase horizontal scaling, caching | ✅ |
| Tile-based UI | TileFactory, dynamic configs | ✅ |
| Multi-role (owner/follower) | RLS policies, role-based queries | ✅ |
| **Technical Requirements** | | |
| Sub-500ms response times | Indexes, caching, CDN | ✅ |
| Real-time updates within 2s | Supabase Realtime, WebSockets | ✅ |
| Photo upload < 5s | Client compression, CDN | ✅ |
| AES-256 encryption | Supabase infrastructure | ✅ |
| TLS 1.3 in transit | HTTPS for all API calls | ✅ |
| 7-year data retention | Soft delete pattern | ✅ |
| **Non-Functional Requirements** | | |
| 99.5% uptime SLA | Supabase infrastructure | ✅ |
| < 1% crash rate | Error handling, Sentry | ✅ |
| WCAG AA compliance | Flutter Semantics, testing | ✅ |
| OAuth 2.0 authentication | Supabase Auth integration | ✅ |

### 11.2 Architecture Quality Attributes

**Scalability**: Horizontal scaling via Supabase, caching strategy, pagination  
**Performance**: Indexes, CDN, lazy loading, realtime updates  
**Security**: RLS, JWT, encryption, rate limiting  
**Reliability**: Error handling, monitoring, backups  
**Maintainability**: Layered architecture, modular tiles, clean code  
**Testability**: Dependency injection, mock-friendly interfaces  
**Flexibility**: Dynamic tile configs, feature flags  

---

## 12. Architecture Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Supabase outage | Low | High | Implement retry logic, offline mode, status page monitoring |
| Database performance degradation | Medium | High | Comprehensive indexing, query optimization, monitoring, scaling plan |
| Real-time scalability issues | Medium | Medium | Limit subscriptions per user, use update markers for followers |
| Cache invalidation bugs | Medium | Medium | Thorough testing, conservative TTLs, manual refresh option |
| Third-party service failures (SendGrid, OneSignal) | Low | Medium | Graceful degradation, queue failed operations, fallback mechanisms |
| Security vulnerabilities (RLS bypass) | Low | Critical | Comprehensive RLS testing with pgTAP, security audits, penetration testing |
| Mobile platform API changes | Medium | Medium | Stay updated with Flutter/OS releases, test on latest versions |
| Data migration complexity | Low | High | Version migrations, rollback capability, test in staging |

---

## 13. Conclusion

The Nonna App architecture is designed to support a scalable, secure, and performant family social platform with the following key strengths:

**Strengths**:
- **Mobile-First**: Optimized for iOS and Android with Flutter
- **Secure by Default**: Multi-layer security with RLS, JWT, and encryption
- **Scalable**: Horizontal scaling via Supabase, efficient caching
- **Real-Time**: WebSocket-based updates within 2 seconds
- **Modular**: Tile-based UI with dynamic configuration
- **Cost-Effective**: Leverages BaaS to minimize infrastructure costs

**Key Differentiators**:
- Dynamic tile system for personalized, role-driven UX
- Multi-tenant architecture with database-level isolation
- Real-time updates optimized for low bandwidth and battery usage
- Comprehensive caching strategy for offline-first experience

This architecture provides a solid foundation for the Nonna MVP and allows for future enhancements without major refactoring.

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Next Review**: Before Development Phase Begins  
**Approval Status**: Pending Architecture Team Review
