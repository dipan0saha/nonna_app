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
