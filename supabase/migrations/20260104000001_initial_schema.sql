-- ========================================
-- User Identity Domain
-- ========================================

-- Table: profiles
CREATE TABLE IF NOT EXISTS public.profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  biometric_enabled BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: user_stats
CREATE TABLE IF NOT EXISTS public.user_stats (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  events_attended_count INT DEFAULT 0,
  items_purchased_count INT DEFAULT 0,
  photos_squished_count INT DEFAULT 0,
  comments_added_count INT DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ========================================
-- Baby Profile Domain
-- ========================================

-- Table: baby_profiles
CREATE TABLE IF NOT EXISTS public.baby_profiles (
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

-- Table: baby_memberships
CREATE TABLE IF NOT EXISTS public.baby_memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner', 'follower')),
  relationship_label TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  removed_at TIMESTAMPTZ,
  UNIQUE(baby_profile_id, user_id)
);

-- Table: invitations
CREATE TABLE IF NOT EXISTS public.invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  invited_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  invitee_email TEXT NOT NULL,
  token_hash TEXT UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'revoked', 'expired')),
  accepted_at TIMESTAMPTZ,
  accepted_by_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: owner_update_markers
CREATE TABLE IF NOT EXISTS public.owner_update_markers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID UNIQUE NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  tiles_last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_by_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  reason TEXT
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
  caption TEXT,
  tags TEXT[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Table: photo_squishes
CREATE TABLE IF NOT EXISTS public.photo_squishes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_id UUID NOT NULL REFERENCES public.photos(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(photo_id, user_id)
);

-- Table: photo_comments
CREATE TABLE IF NOT EXISTS public.photo_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_id UUID NOT NULL REFERENCES public.photos(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  deleted_by_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Table: photo_tags
CREATE TABLE IF NOT EXISTS public.photo_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_id UUID NOT NULL REFERENCES public.photos(id) ON DELETE CASCADE,
  tag TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ========================================
-- Event Domain
-- ========================================

-- Table: events
CREATE TABLE IF NOT EXISTS public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
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

-- Table: event_comments
CREATE TABLE IF NOT EXISTS public.event_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  deleted_by_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Table: event_rsvps
CREATE TABLE IF NOT EXISTS public.event_rsvps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL CHECK (status IN ('yes', 'no', 'maybe')),
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
  name TEXT NOT NULL,
  description TEXT,
  link_url TEXT,
  priority INT DEFAULT 3 CHECK (priority >= 1 AND priority <= 5),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Table: registry_purchases
CREATE TABLE IF NOT EXISTS public.registry_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  registry_item_id UUID NOT NULL REFERENCES public.registry_items(id) ON DELETE CASCADE,
  purchased_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  purchased_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  note TEXT
);

-- ========================================
-- Gamification Domain
-- ========================================

-- Table: votes (unified gender and birthdate predictions)
CREATE TABLE IF NOT EXISTS public.votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vote_type TEXT NOT NULL CHECK (vote_type IN ('gender', 'birthdate')),
  value_text TEXT,
  value_date DATE,
  is_anonymous BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: name_suggestions
CREATE TABLE IF NOT EXISTS public.name_suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  gender TEXT CHECK (gender IN ('male', 'female', 'unknown')),
  suggested_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Table: name_suggestion_likes
CREATE TABLE IF NOT EXISTS public.name_suggestion_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_suggestion_id UUID NOT NULL REFERENCES public.name_suggestions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(name_suggestion_id, user_id)
);

-- ========================================
-- Notification Domain
-- ========================================

-- Table: notifications
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  baby_profile_id UUID REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  payload JSONB DEFAULT '{}'::jsonb,
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
  screen_name TEXT UNIQUE NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: tile_definitions
CREATE TABLE IF NOT EXISTS public.tile_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tile_type TEXT UNIQUE NOT NULL,
  description TEXT,
  schema_params JSONB,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: tile_configs
CREATE TABLE IF NOT EXISTS public.tile_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  screen_id UUID NOT NULL REFERENCES public.screens(id) ON DELETE CASCADE,
  tile_definition_id UUID NOT NULL REFERENCES public.tile_definitions(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner', 'follower')),
  display_order INT NOT NULL,
  is_visible BOOLEAN NOT NULL DEFAULT TRUE,
  params JSONB,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ========================================
-- Activity Domain
-- ========================================

-- Table: activity_events
CREATE TABLE IF NOT EXISTS public.activity_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baby_profile_id UUID NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
  actor_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  payload JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
