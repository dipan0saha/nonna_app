# Database Setup Document

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Team  
**Status**: Configuration Guide  
**Section**: 2.3 - Third-Party Integrations Setup

## Executive Summary

This document provides step-by-step guidance for setting up the PostgreSQL database schema for the Nonna App using Supabase. It covers database initialization, schema creation via migrations, Row-Level Security (RLS) policy implementation, index creation for performance optimization, and triggers/constraints setup. The database follows the comprehensive design specified in `docs/02_architecture_design/database_schema_design.md` and `docs/01_technical_requirements/data_model_diagram.md`.

## References

This document is informed by:

- `docs/02_architecture_design/database_schema_design.md` - Complete database schema architecture
- `docs/01_technical_requirements/data_model_diagram.md` - Comprehensive table definitions and RLS policies
- `docs/02_architecture_design/security_privacy_architecture.md` - RLS policy requirements
- `docs/05_third_party_integrations/01_Supabase_Project_Configuration.md` - Supabase setup
- `docs/Production_Readiness_Checklist.md` - Section 2.3 requirements

---

## 1. Database Setup Overview

### 1.1 Schema Organization

**Schemas**:
1. **`auth` schema**: Managed by Supabase Auth (users, sessions, identities)
2. **`public` schema**: Application data (28 tables across 8 domains)

**Entity Domains**:
1. User Identity Domain (2 tables): `profiles`, `user_stats`
2. Baby Profile Domain (4 tables): `baby_profiles`, `baby_memberships`, `invitations`, `owner_update_markers`
3. Photo Domain (4 tables): `photos`, `photo_comments`, `photo_squishes`, `photo_tags`
4. Event Domain (3 tables): `events`, `event_comments`, `event_rsvps`
5. Registry Domain (2 tables): `registry_items`, `registry_purchases`
6. Gamification Domain (3 tables): `name_suggestions`, `gender_votes`, `birth_date_predictions`
7. Notification Domain (2 tables): `notifications`, `notification_preferences`
8. Tile System Domain (3 tables): `screens`, `tile_definitions`, `tile_configs`

### 1.2 Prerequisites

- [ ] Supabase project created (see `01_Supabase_Project_Configuration.md`)
- [ ] Supabase CLI installed (`brew install supabase/tap/supabase`)
- [ ] Project linked (`supabase link --project-ref [your-ref]`)
- [ ] Understanding of PostgreSQL and RLS concepts

---

## 2. Database Initialization

### 2.1 Enable Required Extensions

```sql
-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pgcrypto for encryption functions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Enable pg_stat_statements for query performance monitoring
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Set timezone to UTC (recommended)
ALTER DATABASE postgres SET timezone TO 'UTC';
```

### 2.2 Create Migration Directory

```bash
# Initialize Supabase migrations
mkdir -p supabase/migrations

# Link to your Supabase project
supabase link --project-ref [your-project-ref]
```

---

## 3. Schema Creation

### 3.1 Create Core Tables

**Migration File**: `supabase/migrations/20260104000001_initial_schema.sql`

```sql
-- ========================================
-- User Identity Domain
-- ========================================

-- Table: profiles
CREATE TABLE IF NOT EXISTS public.profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL CHECK (char_length(display_name) >= 1 AND char_length(display_name) <= 50),
  avatar_url TEXT,
  bio TEXT CHECK (char_length(bio) <= 500),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: user_stats
CREATE TABLE IF NOT EXISTS public.user_stats (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  photos_uploaded INT NOT NULL DEFAULT 0,
  comments_added INT NOT NULL DEFAULT 0,
  events_created INT NOT NULL DEFAULT 0,
  squishes_given INT NOT NULL DEFAULT 0,
  last_active_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ========================================
-- Baby Profile Domain
-- ========================================

-- Table: baby_profiles
CREATE TABLE IF NOT EXISTS public.baby_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL CHECK (char_length(name) >= 1 AND char_length(name) <= 100),
  profile_photo_url TEXT,
  expected_birth_date DATE,
  actual_birth_date DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'unknown')),
  bio TEXT CHECK (char_length(bio) <= 1000),
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (expected_birth_date IS NOT NULL OR actual_birth_date IS NOT NULL)
);

-- Table: baby_memberships
CREATE TABLE IF NOT EXISTS public.baby_memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner', 'follower')),
  relationship_label TEXT CHECK (char_length(relationship_label) <= 50),
  removed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(baby_profile_id, user_id)
);

-- Table: invitations
CREATE TABLE IF NOT EXISTS public.invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  invited_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  invitee_email TEXT NOT NULL,
  relationship_label TEXT NOT NULL CHECK (char_length(relationship_label) <= 50),
  token_hash TEXT UNIQUE NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'revoked', 'expired')),
  accepted_by_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  accepted_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '7 days'),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: owner_update_markers
CREATE TABLE IF NOT EXISTS public.owner_update_markers (
  baby_profile_id UUID PRIMARY KEY REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  photo_updated_at TIMESTAMPTZ,
  event_updated_at TIMESTAMPTZ,
  registry_updated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ========================================
-- Photo Domain
-- ========================================

-- Table: photos
CREATE TABLE IF NOT EXISTS public.photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  uploaded_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  thumbnail_path TEXT,
  caption TEXT CHECK (char_length(caption) <= 500),
  tags TEXT[],
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: photo_comments
CREATE TABLE IF NOT EXISTS public.photo_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_id UUID NOT NULL REFERENCES public.photos(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  comment_text TEXT NOT NULL CHECK (char_length(comment_text) >= 1 AND char_length(comment_text) <= 500),
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: photo_squishes
CREATE TABLE IF NOT EXISTS public.photo_squishes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_id UUID NOT NULL REFERENCES public.photos(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(photo_id, user_id)
);

-- Table: photo_tags
CREATE TABLE IF NOT EXISTS public.photo_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tag_name TEXT NOT NULL CHECK (char_length(tag_name) >= 1 AND char_length(tag_name) <= 50),
  usage_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(tag_name)
);

-- ========================================
-- Event Domain
-- ========================================

-- Table: events
CREATE TABLE IF NOT EXISTS public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  created_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL CHECK (char_length(title) >= 1 AND char_length(title) <= 100),
  description TEXT CHECK (char_length(description) <= 1000),
  event_date TIMESTAMPTZ NOT NULL,
  location TEXT CHECK (char_length(location) <= 200),
  cover_photo_path TEXT,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: event_comments
CREATE TABLE IF NOT EXISTS public.event_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  comment_text TEXT NOT NULL CHECK (char_length(comment_text) >= 1 AND char_length(comment_text) <= 500),
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: event_rsvps
CREATE TABLE IF NOT EXISTS public.event_rsvps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL CHECK (status IN ('attending', 'not_attending', 'maybe')),
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

-- ========================================
-- Registry Domain
-- ========================================

-- Table: registry_items
CREATE TABLE IF NOT EXISTS public.registry_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  created_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  item_name TEXT NOT NULL CHECK (char_length(item_name) >= 1 AND char_length(item_name) <= 200),
  description TEXT CHECK (char_length(description) <= 1000),
  url TEXT,
  price NUMERIC(10, 2),
  priority INT CHECK (priority BETWEEN 1 AND 5),
  quantity_needed INT NOT NULL DEFAULT 1 CHECK (quantity_needed > 0),
  quantity_purchased INT NOT NULL DEFAULT 0 CHECK (quantity_purchased >= 0),
  image_url TEXT,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: registry_purchases
CREATE TABLE IF NOT EXISTS public.registry_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  registry_item_id UUID NOT NULL REFERENCES public.registry_items(id) ON DELETE CASCADE,
  purchased_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ========================================
-- Gamification Domain
-- ========================================

-- Table: name_suggestions
CREATE TABLE IF NOT EXISTS public.name_suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  suggested_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (char_length(name) >= 1 AND char_length(name) <= 100),
  votes_count INT NOT NULL DEFAULT 0,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: gender_votes
CREATE TABLE IF NOT EXISTS public.gender_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vote TEXT NOT NULL CHECK (vote IN ('male', 'female')),
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(baby_profile_id, user_id)
);

-- Table: birth_date_predictions
CREATE TABLE IF NOT EXISTS public.birth_date_predictions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  predicted_date DATE NOT NULL,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(baby_profile_id, user_id)
);

-- ========================================
-- Notification Domain
-- ========================================

-- Table: notifications
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  baby_profile_id UUID REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL CHECK (char_length(title) <= 100),
  body TEXT NOT NULL CHECK (char_length(body) <= 500),
  type TEXT NOT NULL CHECK (type IN ('new_photo', 'new_comment', 'event_rsvp', 'registry_purchase', 'new_follower', 'birth_announcement')),
  payload JSONB,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: notification_preferences
CREATE TABLE IF NOT EXISTS public.notification_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  push_new_photos BOOLEAN NOT NULL DEFAULT TRUE,
  push_new_comments BOOLEAN NOT NULL DEFAULT TRUE,
  push_event_rsvps BOOLEAN NOT NULL DEFAULT TRUE,
  push_registry_purchases BOOLEAN NOT NULL DEFAULT TRUE,
  push_new_followers BOOLEAN NOT NULL DEFAULT TRUE,
  push_birth_announcements BOOLEAN NOT NULL DEFAULT TRUE,
  email_new_photos BOOLEAN NOT NULL DEFAULT FALSE,
  email_weekly_digest BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ========================================
-- Tile System Domain
-- ========================================

-- Table: screens
CREATE TABLE IF NOT EXISTS public.screens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  screen_name TEXT UNIQUE NOT NULL CHECK (char_length(screen_name) <= 50),
  screen_title TEXT NOT NULL CHECK (char_length(screen_title) <= 100),
  description TEXT CHECK (char_length(description) <= 500),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: tile_definitions
CREATE TABLE IF NOT EXISTS public.tile_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tile_type TEXT UNIQUE NOT NULL CHECK (char_length(tile_type) <= 50),
  tile_name TEXT NOT NULL CHECK (char_length(tile_name) <= 100),
  description TEXT CHECK (char_length(description) <= 500),
  default_config JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: tile_configs
CREATE TABLE IF NOT EXISTS public.tile_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  screen_id UUID NOT NULL REFERENCES public.screens(id) ON DELETE CASCADE,
  tile_definition_id UUID NOT NULL REFERENCES public.tile_definitions(id) ON DELETE CASCADE,
  baby_profile_id UUID REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  position INT NOT NULL CHECK (position >= 0),
  is_visible BOOLEAN NOT NULL DEFAULT TRUE,
  params JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 3.2 Apply Migration

```bash
# Apply migration to local database (for testing)
supabase db reset

# Apply migration to remote Supabase project
supabase db push

# Verify migration applied successfully
supabase db diff
```

---

## 4. Row-Level Security (RLS) Setup

### 4.1 Enable RLS on All Tables

**Migration File**: `supabase/migrations/20260104000002_enable_rls.sql`

```sql
-- Enable RLS on all public tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baby_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baby_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.owner_update_markers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photo_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photo_squishes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photo_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_rsvps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registry_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registry_purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.name_suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gender_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.birth_date_predictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.screens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tile_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tile_configs ENABLE ROW LEVEL SECURITY;
```

### 4.2 Create RLS Policies

**Migration File**: `supabase/migrations/20260104000003_rls_policies.sql`

```sql
-- ========================================
-- Profiles RLS Policies
-- ========================================

CREATE POLICY "Users can view all profiles"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ========================================
-- Baby Profiles RLS Policies
-- ========================================

CREATE POLICY "Followers can view baby profiles"
  ON public.baby_profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = baby_profiles.id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND baby_profiles.deleted_at IS NULL
  );

CREATE POLICY "Owners can CRUD baby profiles"
  ON public.baby_profiles FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = baby_profiles.id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

-- ========================================
-- Photos RLS Policies
-- ========================================

CREATE POLICY "Followers can view photos"
  ON public.photos FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = photos.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND photos.deleted_at IS NULL
  );

CREATE POLICY "Owners can CRUD photos"
  ON public.photos FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = photos.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

-- ========================================
-- Photo Comments RLS Policies
-- ========================================

CREATE POLICY "Followers can view photo comments"
  ON public.photo_comments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.photos p
      INNER JOIN public.baby_memberships bm
        ON bm.baby_profile_id = p.baby_profile_id
      WHERE p.id = photo_comments.photo_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
    AND photo_comments.deleted_at IS NULL
  );

CREATE POLICY "Followers can add photo comments"
  ON public.photo_comments FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.photos p
      INNER JOIN public.baby_memberships bm
        ON bm.baby_profile_id = p.baby_profile_id
      WHERE p.id = photo_comments.photo_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Users can delete own comments"
  ON public.photo_comments FOR DELETE
  USING (auth.uid() = user_id);

-- ========================================
-- Events RLS Policies (Similar pattern to Photos)
-- ========================================

CREATE POLICY "Followers can view events"
  ON public.events FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = events.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND events.deleted_at IS NULL
  );

CREATE POLICY "Owners can CRUD events"
  ON public.events FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = events.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

-- ========================================
-- Registry Items RLS Policies
-- ========================================

CREATE POLICY "Followers can view registry items"
  ON public.registry_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = registry_items.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND registry_items.deleted_at IS NULL
  );

CREATE POLICY "Owners can CRUD registry items"
  ON public.registry_items FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = registry_items.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Followers can mark items as purchased"
  ON public.registry_purchases FOR INSERT
  WITH CHECK (
    auth.uid() = purchased_by_user_id
    AND EXISTS (
      SELECT 1 FROM public.registry_items ri
      INNER JOIN public.baby_memberships bm
        ON bm.baby_profile_id = ri.baby_profile_id
      WHERE ri.id = registry_purchases.registry_item_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

-- ========================================
-- Notifications RLS Policies
-- ========================================

CREATE POLICY "Users can view own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- ========================================
-- Apply similar RLS policies for remaining tables
-- (See docs/01_technical_requirements/data_model_diagram.md for complete policies)
-- ========================================
```

---

## 5. Indexes for Performance

**Migration File**: `supabase/migrations/20260104000004_indexes.sql`

```sql
-- Foreign key indexes (critical for joins)
CREATE INDEX idx_baby_memberships_baby_profile_id ON public.baby_memberships(baby_profile_id);
CREATE INDEX idx_baby_memberships_user_id ON public.baby_memberships(user_id);
CREATE INDEX idx_photos_baby_profile_id ON public.photos(baby_profile_id);
CREATE INDEX idx_photos_uploaded_by_user_id ON public.photos(uploaded_by_user_id);
CREATE INDEX idx_photo_comments_photo_id ON public.photo_comments(photo_id);
CREATE INDEX idx_photo_comments_user_id ON public.photo_comments(user_id);
CREATE INDEX idx_events_baby_profile_id ON public.events(baby_profile_id);
CREATE INDEX idx_registry_items_baby_profile_id ON public.registry_items(baby_profile_id);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);

-- Composite indexes for common queries
CREATE INDEX idx_photos_baby_created ON public.photos(baby_profile_id, created_at DESC);
CREATE INDEX idx_events_baby_date ON public.events(baby_profile_id, event_date ASC);
CREATE INDEX idx_memberships_user_active ON public.baby_memberships(user_id, removed_at) WHERE removed_at IS NULL;

-- Partial indexes for filtered queries
CREATE INDEX idx_baby_profiles_active ON public.baby_profiles(id) WHERE deleted_at IS NULL;
CREATE INDEX idx_invitations_pending ON public.invitations(baby_profile_id, status) WHERE status = 'pending';

-- GIN indexes for JSONB and array columns
CREATE INDEX idx_tile_configs_params ON public.tile_configs USING GIN (params);
CREATE INDEX idx_photos_tags ON public.photos USING GIN (tags);
```

---

## 6. Triggers and Automation

**Migration File**: `supabase/migrations/20260104000005_triggers.sql`

```sql
-- ========================================
-- Auto-update updated_at timestamp
-- ========================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at column
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.baby_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.photos FOR EACH ROW EXECUTE FUNCTION update_updated_at();
-- ... (apply to all tables with updated_at)

-- ========================================
-- Update owner_update_markers on content changes
-- ========================================

CREATE OR REPLACE FUNCTION update_photo_marker()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.owner_update_markers
  SET last_updated_at = NOW(),
      photo_updated_at = NOW()
  WHERE baby_profile_id = COALESCE(NEW.baby_profile_id, OLD.baby_profile_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER photo_marker_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.photos
FOR EACH ROW EXECUTE FUNCTION update_photo_marker();

-- Similar triggers for events and registry items...

-- ========================================
-- Enforce max 2 owners per baby profile
-- ========================================

CREATE OR REPLACE FUNCTION enforce_max_two_owners()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'owner' AND NEW.removed_at IS NULL THEN
    IF (SELECT COUNT(*) FROM public.baby_memberships 
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
BEFORE INSERT OR UPDATE ON public.baby_memberships
FOR EACH ROW EXECUTE FUNCTION enforce_max_two_owners();
```

---

## 7. Testing RLS Policies

### 7.1 Manual RLS Testing

```sql
-- Set JWT context to test as specific user
SET LOCAL jwt.claims.sub = 'test-user-id';

-- Test: Follower can view photos
SELECT * FROM public.photos WHERE baby_profile_id = 'baby-id';

-- Test: Follower cannot insert photos (should fail)
INSERT INTO public.photos (baby_profile_id, uploaded_by_user_id, storage_path)
VALUES ('baby-id', 'test-user-id', 'test.jpg');
```

### 7.2 Automated Testing with pgTAP

Install pgTAP:

```bash
# Install pgTAP extension
CREATE EXTENSION IF NOT EXISTS pgtap;
```

Create test file: `supabase/tests/rls_policies_test.sql`

```sql
BEGIN;
SELECT plan(10);

-- Setup test data
INSERT INTO auth.users (id) VALUES ('test_owner_id');
INSERT INTO auth.users (id) VALUES ('test_follower_id');
INSERT INTO public.baby_profiles (id) VALUES ('test_baby_id');
INSERT INTO public.baby_memberships (baby_profile_id, user_id, role)
VALUES ('test_baby_id', 'test_owner_id', 'owner');
INSERT INTO public.baby_memberships (baby_profile_id, user_id, role)
VALUES ('test_baby_id', 'test_follower_id', 'follower');

-- Test 1: Owner can insert photo
SET LOCAL jwt.claims.sub = 'test_owner_id';
SELECT lives_ok(
  $$INSERT INTO public.photos (baby_profile_id, uploaded_by_user_id, storage_path)
    VALUES ('test_baby_id', 'test_owner_id', 'photo.jpg')$$,
  'Owner can insert photo'
);

-- Test 2: Follower cannot insert photo
SET LOCAL jwt.claims.sub = 'test_follower_id';
SELECT throws_ok(
  $$INSERT INTO public.photos (baby_profile_id, uploaded_by_user_id, storage_path)
    VALUES ('test_baby_id', 'test_follower_id', 'photo.jpg')$$,
  'Follower cannot insert photo'
);

-- Test 3: Follower can view photos
SELECT ok(
  (SELECT COUNT(*) FROM public.photos WHERE baby_profile_id = 'test_baby_id') > 0,
  'Follower can view photos'
);

-- Add more tests...

SELECT finish();
ROLLBACK;
```

Run tests:

```bash
supabase test db
```

---

## 8. Production Checklist

Before deploying to production:

- [ ] All migrations applied successfully
- [ ] RLS enabled on all tables
- [ ] RLS policies tested comprehensively
- [ ] Indexes created for all foreign keys and hot query paths
- [ ] Triggers functioning correctly
- [ ] Test data populated in staging environment
- [ ] Performance benchmarks met (queries < 100ms)
- [ ] Backup strategy configured
- [ ] Monitoring and alerts set up

---

## Conclusion

This Database Setup Document provides step-by-step instructions for creating the Nonna App database schema in Supabase. The complete table definitions, relationships, and business rules are documented in `docs/01_technical_requirements/data_model_diagram.md`. Following these guidelines ensures a secure, performant, and scalable database ready for production.

**Next Steps**:

- Review `05_Push_Notification_Configuration.md` for push notifications setup
- Review `06_Analytics_Setup_Document.md` for analytics tracking

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Status**: Configuration Guide - Ready for Implementation
