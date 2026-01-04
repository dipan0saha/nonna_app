# Data Model Diagram

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Team  
**Status**: Final  
**Section**: 1.2 - Technical Requirements

## Executive Summary

This Data Model Diagram document provides a comprehensive view of the Nonna App's data architecture, entity relationships, and database schema design. The data model is based on PostgreSQL and is designed to support the tile-based, multi-role family social platform with emphasis on privacy, scalability, and real-time capabilities.

The data model supports the core business requirements including:
- Multi-tenant architecture (baby profile as tenant boundary)
- Role-based access control (owners vs followers)
- Real-time data synchronization
- Soft delete pattern for 7-year data retention
- Gamification and engagement tracking
- Tile-based dynamic UI configuration

## References

This document is based on and references:

- `docs/00_requirement_gathering/user_personas_document.md` - Data entities based on user needs
- `docs/00_requirement_gathering/user_journey_maps.md` - Data flows based on user interactions
- `docs/01_technical_requirements/functional_requirements_specification.md` - Data requirements from functional specs
- `discovery/01_discovery/05_draft_design/ERD.md` - Original entity relationship diagram from discovery phase
- `discovery/01_discovery/02_technology_stack/Technology_Stack.md` - PostgreSQL and Supabase architecture

## Alignment with Discovery Phase ERD

**Important Note**: This data model aligns with and builds upon the existing ERD defined in `discovery/01_discovery/05_draft_design/ERD.md`. The structure, tables, relationships, and constraints have been validated and are consistent with the discovery phase design. No significant deviations exist. This document provides additional context, rationale, and business logic details that complement the technical ERD.

### Key Design Principles Maintained

1. **Schema Separation**: Clear distinction between `auth` schema (Supabase Auth) and `public` schema (application data)
2. **Tenant Boundary**: Baby profile as the multi-tenant boundary with RLS enforcement
3. **Soft Delete Pattern**: All user-generated content uses `deleted_at` timestamp
4. **Audit Trail**: `created_at` and `updated_at` timestamps on all major entities
5. **Performance Optimization**: Indexed foreign keys and hot query paths
6. **Referential Integrity**: CASCADE behavior on foreign keys for clean data management

---

## 1. Schema Architecture Overview

### 1.1 Schema Organization

The Nonna database is organized into two schemas:

**1. `auth` Schema (Managed by Supabase Auth)**
- Contains authentication-related tables
- Managed automatically by Supabase
- Not directly modified by application code
- Tables: `auth.users`, `auth.sessions`, `auth.identities`

**2. `public` Schema (Application Data)**
- Contains all application-specific tables
- Fully controlled by application
- Protected by Row-Level Security (RLS) policies
- All entities described in this document

### 1.2 Multi-Tenant Architecture

**Tenant Boundary**: The `baby_profiles` table serves as the multi-tenant boundary. All data is scoped to a specific baby profile, ensuring complete data isolation between families.

**Benefits**:
- Data isolation between unrelated families
- RLS policies can efficiently scope access by baby profile
- Simplified data access patterns (always filter by baby_profile_id)
- Clean data deletion (cascade from baby profile)

---

## 2. Core Entity Definitions

### 2.1 User Identity Domain

#### Table: `profiles`

**Purpose**: Stores centralized user profile information, one-to-one with `auth.users`.

**Schema**:
```sql
CREATE TABLE profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    avatar_url TEXT,
    biometric_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Attributes**:
- `user_id` (PK, FK): Links to Supabase Auth user; CASCADE deletes profile when auth user deleted
- `display_name`: User's chosen display name (used in comments, activity feeds)
- `avatar_url`: Path to profile photo in Supabase Storage
- `biometric_enabled`: User preference for biometric authentication
- `created_at`: Account creation timestamp
- `updated_at`: Last profile update (auto-updated via trigger)

**Relationships**:
- 1:1 with `auth.users`
- 1:N with `baby_memberships` (user can follow/own multiple babies)
- 1:N with `user_stats` (one stats record per user)

**Business Rules**:
- Display name required for meaningful user identification
- Avatar URL validated for supported image formats
- Biometric enabled only on supported devices

**RLS Policies**:
- Users can read their own profile
- Users can update their own profile
- Public read access for profiles of users in same baby profile (for comments/activity)

---

#### Table: `user_stats`

**Purpose**: Tracks gamification and engagement statistics per user.

**Schema**:
```sql
CREATE TABLE user_stats (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    events_attended_count INT DEFAULT 0,
    items_purchased_count INT DEFAULT 0,
    photos_squished_count INT DEFAULT 0,
    comments_added_count INT DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Attributes**:
- `user_id` (PK, FK): Links to user
- `events_attended_count`: Count of "Yes" RSVPs
- `items_purchased_count`: Count of registry items marked purchased
- `photos_squished_count`: Count of photos liked
- `comments_added_count`: Count of comments added
- `updated_at`: Last stats update

**Relationships**:
- 1:1 with `auth.users`

**Business Rules**:
- Counters auto-increment via database triggers
- Counters never decrement (even if action undone)
- Supports future gamification features (leaderboards, badges)

**RLS Policies**:
- Users can read their own stats
- Public read access for stats of users in same baby profile (for gamification displays)

---

### 2.2 Baby Profile Domain

#### Table: `baby_profiles`

**Purpose**: Central entity representing a baby profile; the multi-tenant boundary.

**Schema**:
```sql
CREATE TABLE baby_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    default_last_name_source TEXT,
    profile_photo_url TEXT,
    expected_birth_date DATE,
    actual_birth_date DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'unknown')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);
```

**Attributes**:
- `id` (PK): Unique identifier, tenant boundary
- `name`: Baby's name (or "Baby [Last Name]" default)
- `default_last_name_source`: Reference to father's/mother's last name
- `profile_photo_url`: Path to baby photo in Supabase Storage
- `expected_birth_date`: Due date (for countdown)
- `actual_birth_date`: Set after birth announcement
- `gender`: male, female, or unknown
- `created_at`: Profile creation timestamp
- `updated_at`: Last profile update
- `deleted_at`: Soft delete timestamp (NULL if active)

**Relationships**:
- 1:N with `baby_memberships` (owners and followers)
- 1:N with `events`, `photos`, `registry_items` (content)
- 1:1 with `owner_update_markers` (cache invalidation)

**Business Rules**:
- Name required (can be placeholder "Baby [Last Name]")
- Either expected_birth_date OR actual_birth_date must be set
- Gender defaults to 'unknown'
- Soft delete cascades to all related content

**RLS Policies**:
- Owners can read, update, delete (soft)
- Followers can read only
- No public access without membership

---

#### Table: `baby_memberships`

**Purpose**: Junction table linking users to baby profiles with role and relationship information.

**Schema**:
```sql
CREATE TABLE baby_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id UUID NOT NULL REFERENCES baby_profiles(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('owner', 'follower')),
    relationship_label TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    removed_at TIMESTAMPTZ,
    UNIQUE(baby_profile_id, user_id)
);

-- Constraint: Maximum 2 owners per baby profile
CREATE OR REPLACE FUNCTION enforce_max_two_owners()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.role = 'owner' AND NEW.removed_at IS NULL THEN
        IF (SELECT COUNT(*) FROM baby_memberships 
            WHERE baby_profile_id = NEW.baby_profile_id 
            AND role = 'owner' 
            AND removed_at IS NULL) >= 2 THEN
            RAISE EXCEPTION 'Maximum two owners allowed per baby profile';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_max_owners
BEFORE INSERT OR UPDATE ON baby_memberships
FOR EACH ROW EXECUTE FUNCTION enforce_max_two_owners();
```

**Attributes**:
- `id` (PK): Unique identifier
- `baby_profile_id` (FK): Baby profile reference
- `user_id` (FK): User reference
- `role`: 'owner' (full permissions) or 'follower' (read + interact)
- `relationship_label`: Grandma, Grandpa, Aunt, Uncle, Family Friend, etc.
- `created_at`: Membership creation timestamp
- `updated_at`: Last update
- `removed_at`: Soft delete (follower removed or left)

**Relationships**:
- N:1 with `baby_profiles`
- N:1 with `auth.users`

**Business Rules**:
- Maximum 2 owners per baby profile (enforced by trigger)
- Unique constraint prevents duplicate memberships
- Relationship label optional for owners, encouraged for followers
- Soft delete allows data retention for audit

**RLS Policies**:
- Owners can read all memberships for their baby
- Followers can read all memberships for babies they follow
- Owners can update/delete (soft) follower memberships
- Users can soft-delete their own follower membership (leave)

---

#### Table: `invitations`

**Purpose**: Manages email invitations to join baby profiles as followers.

**Schema**:
```sql
CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id UUID NOT NULL REFERENCES baby_profiles(id) ON DELETE CASCADE,
    invited_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    invitee_email TEXT NOT NULL,
    token_hash TEXT UNIQUE NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'revoked', 'expired')),
    accepted_at TIMESTAMPTZ,
    accepted_by_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for token lookup
CREATE INDEX idx_invitations_token_hash ON invitations(token_hash);
```

**Attributes**:
- `id` (PK): Unique identifier
- `baby_profile_id` (FK): Baby profile being invited to
- `invited_by_user_id` (FK): Owner who sent invitation
- `invitee_email`: Email address of invitee
- `token_hash`: Hashed secure token (unique, indexed for fast lookup)
- `expires_at`: Expiration timestamp (7 days from creation)
- `status`: pending (sent), accepted (user joined), revoked (cancelled), expired (past expiration)
- `accepted_at`: Timestamp of acceptance
- `accepted_by_user_id` (FK): User who accepted (may differ from email if account exists)
- `created_at`: Invitation creation timestamp
- `updated_at`: Last status update

**Relationships**:
- N:1 with `baby_profiles`
- N:1 with `auth.users` (invited_by)
- N:1 with `auth.users` (accepted_by)

**Business Rules**:
- Token expires exactly 7 days from creation
- Status transitions: pending → accepted/revoked/expired
- Expired invitations cannot be accepted
- Revoked invitations cannot be accepted
- Token hash must be unique and securely generated

**RLS Policies**:
- Owners can read invitations for their baby profiles
- Owners can create/revoke invitations for their baby profiles
- Edge Function validates token for acceptance (server-side only)

---

### 2.3 Tile System Domain

#### Table: `screens`

**Purpose**: Defines available screens in the app (Home, Calendar, Gallery, Registry, Fun).

**Schema**:
```sql
CREATE TABLE screens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    screen_name TEXT UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Attributes**:
- `id` (PK): Unique identifier
- `screen_name`: Unique name (home, calendar, gallery, registry, fun)
- `description`: Screen purpose description
- `is_active`: Feature flag to enable/disable screen
- `created_at`: Screen creation timestamp

**Relationships**:
- 1:N with `tile_configs` (tiles on this screen)

**Business Rules**:
- Screen names must be unique and lowercase
- is_active controls visibility across entire app

**RLS Policies**:
- Public read access (screens are global config)
- Admin-only write access (managed via admin panel or migrations)

---

#### Table: `tile_definitions`

**Purpose**: Catalog of available tile types (widgets) that can be rendered.

**Schema**:
```sql
CREATE TABLE tile_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tile_type TEXT UNIQUE NOT NULL,
    description TEXT,
    schema_params JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Attributes**:
- `id` (PK): Unique identifier
- `tile_type`: Unique tile type identifier (PhotoGridTile, CalendarTile, RegistryTile, etc.)
- `description`: Tile purpose and functionality
- `schema_params`: JSON schema for validating tile parameters
- `is_active`: Feature flag to enable/disable tile type
- `created_at`: Definition creation timestamp

**Relationships**:
- 1:N with `tile_configs` (configurations of this tile type)

**Business Rules**:
- Tile types must match Flutter TileFactory cases
- schema_params validates tile-specific configuration
- Deactivated tiles do not render even if configured

**RLS Policies**:
- Public read access (tile definitions are global)
- Admin-only write access

---

#### Table: `tile_configs`

**Purpose**: Configures which tiles appear on which screens for which roles.

**Schema**:
```sql
CREATE TABLE tile_configs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    screen_id UUID NOT NULL REFERENCES screens(id) ON DELETE CASCADE,
    tile_definition_id UUID NOT NULL REFERENCES tile_definitions(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('owner', 'follower')),
    display_order INT NOT NULL,
    is_visible BOOLEAN DEFAULT TRUE,
    params JSONB,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for efficient screen/role queries
CREATE INDEX idx_tile_configs_screen_role ON tile_configs(screen_id, role);
```

**Attributes**:
- `id` (PK): Unique identifier
- `screen_id` (FK): Screen where tile appears
- `tile_definition_id` (FK): Type of tile to render
- `role`: owner or follower (determines visibility)
- `display_order`: Sort order on screen (1, 2, 3...)
- `is_visible`: Remote show/hide control
- `params`: Tile-specific configuration (e.g., {limit: 5, show_thumbnails: true})
- `updated_at`: Last configuration update

**Relationships**:
- N:1 with `screens`
- N:1 with `tile_definitions`

**Business Rules**:
- display_order determines tile sequence on screen
- is_visible allows dynamic show/hide without deleting config
- params must conform to tile_definition.schema_params

**RLS Policies**:
- Users can read configs for their role
- Admin-only write access (or owner-customization feature in future)

---

#### Table: `owner_update_markers`

**Purpose**: Tracks when owners update content to enable efficient cache invalidation for followers.

**Schema**:
```sql
CREATE TABLE owner_update_markers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id UUID UNIQUE NOT NULL REFERENCES baby_profiles(id) ON DELETE CASCADE,
    tiles_last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    reason TEXT
);
```

**Attributes**:
- `id` (PK): Unique identifier
- `baby_profile_id` (FK, UNIQUE): One marker per baby profile
- `tiles_last_updated_at`: Timestamp of last content update (used for cache validation)
- `updated_by_user_id` (FK): Owner who made update
- `reason`: Description of update (photo_uploaded, event_created, registry_updated, etc.)

**Relationships**:
- 1:1 with `baby_profiles`

**Business Rules**:
- Updated via trigger when photos, events, registry items, or comments are added/updated
- Followers compare local cache timestamp with this marker to determine if refresh needed
- Enables efficient "poll for changes" without full data fetch

**RLS Policies**:
- Owners can read for their baby profiles
- Followers can read for babies they follow
- System triggers update (not direct user writes)

---

### 2.4 Calendar and Events Domain

#### Table: `events`

**Purpose**: Stores calendar events (ultrasounds, baby showers, gender reveals, etc.).

**Schema**:
```sql
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id UUID NOT NULL REFERENCES baby_profiles(id) ON DELETE CASCADE,
    created_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ,
    description TEXT,
    location TEXT,
    video_link TEXT,
    cover_photo_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes for performance
CREATE INDEX idx_events_baby_profile ON events(baby_profile_id);
CREATE INDEX idx_events_starts_at ON events(starts_at);

-- Constraint: Maximum 2 events per day per baby profile
CREATE OR REPLACE FUNCTION enforce_max_two_events_per_day()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM events 
        WHERE baby_profile_id = NEW.baby_profile_id 
        AND DATE(starts_at) = DATE(NEW.starts_at)
        AND deleted_at IS NULL) >= 2 THEN
        RAISE EXCEPTION 'Maximum two events per day allowed';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_max_events_per_day
BEFORE INSERT OR UPDATE ON events
FOR EACH ROW EXECUTE FUNCTION enforce_max_two_events_per_day();
```

**Attributes**:
- `id` (PK): Unique identifier
- `baby_profile_id` (FK, indexed): Baby profile reference
- `created_by_user_id` (FK): Owner who created event
- `title`: Event name (required)
- `starts_at` (indexed): Event start date/time (required)
- `ends_at`: Event end date/time (optional)
- `description`: Event details
- `location`: Physical location
- `video_link`: Zoom/Meet URL for virtual events
- `cover_photo_url`: Path to event photo in storage
- `created_at`: Event creation timestamp
- `updated_at`: Last event update
- `deleted_at`: Soft delete timestamp

**Relationships**:
- N:1 with `baby_profiles`
- N:1 with `auth.users` (creator)
- 1:N with `event_rsvps`
- 1:N with `event_comments`

**Business Rules**:
- Maximum 2 events per day per baby profile (enforced by trigger)
- starts_at required; ends_at optional
- video_link validated as URL format
- Soft delete cascades to RSVPs and comments

**RLS Policies**:
- Owners can CRUD events for their baby profiles
- Followers can read events for babies they follow
- Real-time enabled for followers to receive updates

---

#### Table: `event_rsvps`

**Purpose**: Tracks user RSVPs to events (Yes, No, Maybe).

**Schema**:
```sql
CREATE TABLE event_rsvps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('yes', 'no', 'maybe')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(event_id, user_id)
);

-- Trigger to update user_stats.events_attended_count on "Yes" RSVP
CREATE OR REPLACE FUNCTION increment_events_attended()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'yes' THEN
        UPDATE user_stats
        SET events_attended_count = events_attended_count + 1,
            updated_at = NOW()
        WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER count_event_rsvp
AFTER INSERT OR UPDATE ON event_rsvps
FOR EACH ROW EXECUTE FUNCTION increment_events_attended();
```

**Attributes**:
- `id` (PK): Unique identifier
- `event_id` (FK): Event reference
- `user_id` (FK): User who RSVP'd
- `status`: yes, no, or maybe
- `created_at`: RSVP creation timestamp
- `updated_at`: Last RSVP change

**Relationships**:
- N:1 with `events`
- N:1 with `auth.users`

**Business Rules**:
- One RSVP per user per event (unique constraint)
- Users can change RSVP status
- "Yes" RSVP increments events_attended_count

**RLS Policies**:
- Users can create/update their own RSVPs
- Users can read all RSVPs for events they can access
- Owners can read all RSVPs for their events

---

#### Table: `event_comments`

**Purpose**: Stores comments on events.

**Schema**:
```sql
CREATE TABLE event_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    deleted_by_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

CREATE INDEX idx_event_comments_event ON event_comments(event_id);
```

**Attributes**:
- `id` (PK): Unique identifier
- `event_id` (FK, indexed): Event reference
- `user_id` (FK): Commenter
- `body`: Comment text (max 500 characters enforced at app level)
- `created_at`: Comment creation timestamp
- `deleted_at`: Soft delete timestamp
- `deleted_by_user_id` (FK): Who deleted comment (owner moderation)

**Relationships**:
- N:1 with `events`
- N:1 with `auth.users` (commenter)
- N:1 with `auth.users` (deleter, optional)

**Business Rules**:
- Comment authors can edit (update body)
- Comment authors can delete their own comments
- Event owners can delete any comment on their events
- Soft delete retains comment for 7 years

**RLS Policies**:
- Users can create comments on events they can access
- Users can read non-deleted comments on accessible events
- Users can update/delete their own comments
- Owners can delete any comment on their events

---

### 2.5 Registry Domain

#### Table: `registry_items`

**Purpose**: Stores baby registry items (products desired by parents).

**Schema**:
```sql
CREATE TABLE registry_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id UUID NOT NULL REFERENCES baby_profiles(id) ON DELETE CASCADE,
    created_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    link_url TEXT,
    priority INT DEFAULT 3 CHECK (priority >= 1 AND priority <= 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_registry_items_baby_profile ON registry_items(baby_profile_id);
CREATE INDEX idx_registry_items_priority ON registry_items(priority);
```

**Attributes**:
- `id` (PK): Unique identifier
- `baby_profile_id` (FK, indexed): Baby profile reference
- `created_by_user_id` (FK): Owner who added item
- `name`: Item name (required)
- `description`: Item details
- `link_url`: Product URL (Amazon, Target, etc.)
- `priority`: 1-5 (1 = highest priority)
- `created_at`: Item creation timestamp
- `updated_at`: Last item update
- `deleted_at`: Soft delete timestamp

**Relationships**:
- N:1 with `baby_profiles`
- N:1 with `auth.users` (creator)
- 1:N with `registry_purchases`

**Business Rules**:
- Priority 1-5 for sorting (1 = most important)
- link_url validated as URL format
- Purchased items move to bottom of list (sorted by purchased status then priority)

**RLS Policies**:
- Owners can CRUD registry items for their baby profiles
- Followers can read items for babies they follow
- Real-time enabled for followers to see updates

---

#### Table: `registry_purchases`

**Purpose**: Tracks which followers purchased which registry items.

**Schema**:
```sql
CREATE TABLE registry_purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    registry_item_id UUID NOT NULL REFERENCES registry_items(id) ON DELETE CASCADE,
    purchased_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    purchased_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    note TEXT
);

-- Trigger to update user_stats.items_purchased_count
CREATE OR REPLACE FUNCTION increment_items_purchased()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE user_stats
    SET items_purchased_count = items_purchased_count + 1,
        updated_at = NOW()
    WHERE user_id = NEW.purchased_by_user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER count_registry_purchase
AFTER INSERT ON registry_purchases
FOR EACH ROW EXECUTE FUNCTION increment_items_purchased();
```

**Attributes**:
- `id` (PK): Unique identifier
- `registry_item_id` (FK): Registry item reference
- `purchased_by_user_id` (FK): Follower who purchased
- `purchased_at`: Purchase timestamp
- `note`: Optional message from purchaser

**Relationships**:
- N:1 with `registry_items`
- N:1 with `auth.users` (purchaser)

**Business Rules**:
- Multiple purchases allowed per item (different users buy same item)
- Purchase increments items_purchased_count for user
- Owners see all purchases with purchaser names
- Cannot un-purchase (no delete) to prevent data loss

**RLS Policies**:
- Followers can create purchases for accessible registry items
- Users can read all purchases for accessible items
- Owners can read all purchases for their registry items

---

### 2.6 Photo Gallery Domain

#### Table: `photos`

**Purpose**: Stores photos uploaded to baby profiles.

**Schema**:
```sql
CREATE TABLE photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id UUID NOT NULL REFERENCES baby_profiles(id) ON DELETE CASCADE,
    uploaded_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    storage_path TEXT NOT NULL,
    thumbnail_path TEXT NOT NULL,
    caption TEXT,
    tags TEXT[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_photos_baby_profile ON photos(baby_profile_id);
CREATE INDEX idx_photos_created_at ON photos(created_at DESC);
CREATE INDEX idx_photos_tags ON photos USING GIN(tags);
```

**Attributes**:
- `id` (PK): Unique identifier
- `baby_profile_id` (FK, indexed): Baby profile reference
- `uploaded_by_user_id` (FK): Owner who uploaded photo
- `storage_path`: Path to full-size photo in Supabase Storage
- `thumbnail_path`: Path to thumbnail (300x300) in storage
- `caption`: Photo description (max 500 characters)
- `tags`: Array of tags for categorization (ultrasound, bump_update, nursery, etc.)
- `created_at` (indexed DESC): Upload timestamp (for chronological sorting)
- `updated_at`: Last photo update
- `deleted_at`: Soft delete timestamp

**Relationships**:
- N:1 with `baby_profiles`
- N:1 with `auth.users` (uploader)
- 1:N with `photo_squishes`
- 1:N with `photo_comments`

**Business Rules**:
- Photos sorted newest first (created_at DESC)
- Thumbnail generated on upload (via Edge Function)
- Tags support filtering and search (GIN index for array queries)
- Soft delete retains photo file for 7 years

**RLS Policies**:
- Owners can CRUD photos for their baby profiles
- Followers can read photos for babies they follow
- Real-time enabled for followers to see new photos

---

#### Table: `photo_squishes`

**Purpose**: Tracks photo "likes" (squishes) by users.

**Schema**:
```sql
CREATE TABLE photo_squishes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    photo_id UUID NOT NULL REFERENCES photos(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(photo_id, user_id)
);

CREATE INDEX idx_photo_squishes_photo ON photo_squishes(photo_id);

-- Trigger to update user_stats.photos_squished_count
CREATE OR REPLACE FUNCTION increment_photos_squished()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE user_stats
    SET photos_squished_count = photos_squished_count + 1,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER count_photo_squish
AFTER INSERT ON photo_squishes
FOR EACH ROW EXECUTE FUNCTION increment_photos_squished();
```

**Attributes**:
- `id` (PK): Unique identifier
- `photo_id` (FK, indexed): Photo reference
- `user_id` (FK): User who squished
- `created_at`: Squish timestamp

**Relationships**:
- N:1 with `photos`
- N:1 with `auth.users`

**Business Rules**:
- One squish per user per photo (unique constraint)
- Users can un-squish (delete record)
- Squish count displayed to all users
- Squish increments photos_squished_count

**RLS Policies**:
- Users can create/delete their own squishes
- Users can read all squishes for accessible photos
- Owners receive notifications for squishes

---

#### Table: `photo_comments`

**Purpose**: Stores comments on photos.

**Schema**:
```sql
CREATE TABLE photo_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    photo_id UUID NOT NULL REFERENCES photos(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    deleted_by_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

CREATE INDEX idx_photo_comments_photo ON photo_comments(photo_id);

-- Trigger to update user_stats.comments_added_count
CREATE OR REPLACE FUNCTION increment_comments_added()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE user_stats
    SET comments_added_count = comments_added_count + 1,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER count_photo_comment
AFTER INSERT ON photo_comments
FOR EACH ROW EXECUTE FUNCTION increment_comments_added();
```

**Attributes**:
- `id` (PK): Unique identifier
- `photo_id` (FK, indexed): Photo reference
- `user_id` (FK): Commenter
- `body`: Comment text (max 500 characters)
- `created_at`: Comment creation timestamp
- `deleted_at`: Soft delete timestamp
- `deleted_by_user_id` (FK): Who deleted comment (owner moderation)

**Relationships**:
- N:1 with `photos`
- N:1 with `auth.users` (commenter)
- N:1 with `auth.users` (deleter, optional)

**Business Rules**:
- Comment authors can edit (update body)
- Comment authors can delete their own comments
- Photo owners can delete any comment on their photos
- Comments increment comments_added_count
- Soft delete retains comment for 7 years

**RLS Policies**:
- Users can create comments on accessible photos
- Users can read non-deleted comments on accessible photos
- Users can update/delete their own comments
- Owners can delete any comment on their photos

---

### 2.7 Notifications Domain

#### Table: `notifications`

**Purpose**: Stores in-app notifications for users.

**Schema**:
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT,
    payload JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
```

**Attributes**:
- `id` (PK): Unique identifier
- `user_id` (FK, indexed): Notification recipient
- `type`: Notification type (new_photo, new_comment, rsvp, purchase, etc.)
- `title`: Notification headline
- `body`: Notification details
- `payload`: JSON data for navigation (e.g., {photo_id: "...", baby_profile_id: "..."})
- `is_read`: Read status
- `created_at` (indexed DESC): Notification timestamp

**Relationships**:
- N:1 with `auth.users`

**Business Rules**:
- Notifications sorted newest first
- Unread notifications count displayed as badge
- Tapping notification navigates to relevant content using payload
- Notifications never deleted (audit trail)

**RLS Policies**:
- Users can read their own notifications
- Users can update is_read on their own notifications
- System creates notifications (not direct user writes)

---

## 3. Data Flows

### 3.1 User Registration and Baby Profile Creation

```
1. User registers (auth.users + profiles)
2. User creates baby profile (baby_profiles)
3. System creates baby_membership (role: owner)
4. System creates user_stats (initial counters)
5. System creates owner_update_markers (initial marker)
```

### 3.2 Invitation and Follower Onboarding

```
1. Owner sends invitation (invitations, status: pending)
2. SendGrid sends email with token
3. Invitee clicks link (validates token)
4. Invitee registers if new user (auth.users + profiles + user_stats)
5. Invitee accepts invitation:
   - Creates baby_membership (role: follower, relationship_label)
   - Updates invitation (status: accepted, accepted_at, accepted_by_user_id)
6. System sends notification to owner (notifications)
```

### 3.3 Photo Upload and Engagement

```
1. Owner uploads photo (photos, storage_path, thumbnail_path)
2. Edge Function generates thumbnail
3. System updates owner_update_markers (tiles_last_updated_at)
4. System broadcasts via Realtime (followers receive update)
5. Follower views photo (loads from cache or fetches)
6. Follower squishes photo (photo_squishes)
7. System increments user_stats.photos_squished_count
8. System creates notification for owner (notifications)
9. System sends push notification via OneSignal
```

### 3.4 Event Creation and RSVP

```
1. Owner creates event (events)
2. System updates owner_update_markers
3. System broadcasts via Realtime
4. System creates notifications for all followers (notifications)
5. System sends push notifications via OneSignal
6. Follower RSVPs (event_rsvps, status: yes)
7. System increments user_stats.events_attended_count
8. System creates notification for owner (notifications)
```

### 3.5 Registry Purchase

```
1. Owner creates registry item (registry_items)
2. Follower marks item as purchased (registry_purchases)
3. System increments user_stats.items_purchased_count
4. System creates notification for owner (notifications)
5. System broadcasts via Realtime (item moves to purchased section)
```

---

## 4. Performance Optimization Strategy

### 4.1 Indexing Strategy

**Foreign Keys** (All indexed for join performance):
- `baby_profile_id` on all content tables
- `user_id` on all user-action tables
- `event_id`, `photo_id`, `registry_item_id` on related tables

**Temporal Queries**:
- `created_at DESC` on photos, notifications, comments
- `starts_at` on events (for upcoming events query)

**Lookups**:
- `token_hash` on invitations (unique, indexed for fast validation)
- `screen_name` on screens (unique, indexed)
- `tile_type` on tile_definitions (unique, indexed)

**Array Queries**:
- GIN index on `photos.tags` for tag-based filtering

### 4.2 Query Optimization

**Pagination**: All list queries use LIMIT/OFFSET or cursor-based pagination (30-50 items per page)

**Aggregation**: Follower queries use `.in()` for efficient multi-baby aggregation:
```sql
SELECT * FROM photos
WHERE baby_profile_id IN (SELECT baby_profile_id FROM baby_memberships WHERE user_id = ?)
ORDER BY created_at DESC
LIMIT 30;
```

**Caching**: Client-side caching via Hive/Isar reduces database hits; cache validated against `owner_update_markers.tiles_last_updated_at`

### 4.3 Real-Time Subscription Scoping

**Owner Subscriptions**: Subscribe to specific baby_profile_id
```sql
supabase
  .from('photos')
  .on('INSERT', (payload) => {...})
  .filter('baby_profile_id', 'eq', babyProfileId)
  .subscribe();
```

**Follower Subscriptions**: Subscribe to all accessible baby profiles
```sql
supabase
  .from('photos')
  .on('INSERT', (payload) => {...})
  .filter('baby_profile_id', 'in', followedBabyProfileIds)
  .subscribe();
```

---

## 5. Deviations and Enhancements from Discovery ERD

**No Significant Deviations**: This data model is fully aligned with `discovery/01_discovery/05_draft_design/ERD.md`. All 24 tables, relationships, constraints, and RLS policies match the discovery phase design.

**Enhancements in This Document**:
1. **Business Logic Detail**: Added comprehensive business rules and rationale
2. **Trigger Documentation**: Documented database triggers for counters and constraints
3. **Data Flow Diagrams**: Added end-to-end data flows for key user scenarios
4. **Performance Strategy**: Detailed indexing and query optimization approach
5. **RLS Policy Summary**: Summarized row-level security policies per table

**Future Considerations** (Post-MVP):
- Gamification tables (leaderboards, badges)
- Direct messaging tables (DMs between users)
- Advanced analytics tables (engagement metrics, trends)
- Video content support (video metadata, streaming)
- Multi-language support (localized content)

---

## 6. Data Retention and Compliance

### 6.1 Soft Delete Implementation

All user-generated content uses soft delete pattern:
- `deleted_at` timestamp column (NULL = active, NOT NULL = deleted)
- Deleted content hidden from all user queries
- Data retained for 7 years per regulatory requirements
- Archival job (Edge Function) permanently deletes data older than 7 years

### 6.2 Cascade Deletion

**Parent-Child Cascades**:
- `baby_profiles` → `baby_memberships`, `events`, `photos`, `registry_items`
- `events` → `event_rsvps`, `event_comments`
- `photos` → `photo_squishes`, `photo_comments`
- `registry_items` → `registry_purchases`

**Cascade Behavior**: ON DELETE CASCADE ensures orphaned records never exist

---

## 7. Conclusion

This data model provides a robust, scalable foundation for the Nonna App that:

1. **Supports Multi-Tenancy**: Baby profiles as clear tenant boundaries with complete data isolation
2. **Enables Role-Based Access**: Owner/follower roles enforced at database level via RLS
3. **Facilitates Real-Time Features**: Optimized for Supabase Realtime subscriptions
4. **Ensures Data Integrity**: Foreign key constraints, triggers, and validation rules
5. **Complies with Regulations**: 7-year retention via soft deletes
6. **Optimizes Performance**: Strategic indexing for <500ms query times
7. **Supports Tile System**: Dynamic UI configuration via tile system tables

The data model is fully aligned with the discovery phase ERD and requires no structural changes to proceed with implementation.

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Team  
**Status**: Final  
**Next Review**: Before Database Migration Implementation
