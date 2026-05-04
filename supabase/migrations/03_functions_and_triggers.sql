-- Functions, Helpers and Triggers
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
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.user_stats FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.baby_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.baby_memberships FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.invitations FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.photos FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.event_rsvps FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.registry_items FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.votes FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.name_suggestions FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.notification_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.photo_comments FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.tile_configs FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ========================================
-- Update owner_update_markers on content changes
-- ========================================

CREATE OR REPLACE FUNCTION update_photo_marker()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.owner_update_markers
  SET tiles_last_updated_at = NOW(),
      reason = 'photo_updated'
  WHERE baby_profile_id = COALESCE(NEW.baby_profile_id, OLD.baby_profile_id);
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER photo_marker_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.photos
FOR EACH ROW EXECUTE FUNCTION update_photo_marker();

CREATE OR REPLACE FUNCTION update_event_marker()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.owner_update_markers
  SET tiles_last_updated_at = NOW(),
      reason = 'event_updated'
  WHERE baby_profile_id = COALESCE(NEW.baby_profile_id, OLD.baby_profile_id);
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER event_marker_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.events
FOR EACH ROW EXECUTE FUNCTION update_event_marker();

CREATE OR REPLACE FUNCTION update_registry_marker()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.owner_update_markers
  SET tiles_last_updated_at = NOW(),
      reason = 'registry_updated'
  WHERE baby_profile_id = COALESCE(NEW.baby_profile_id, OLD.baby_profile_id);
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER registry_marker_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.registry_items
FOR EACH ROW EXECUTE FUNCTION update_registry_marker();

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

-- ========================================
-- Enforce max 2 events per day per baby profile
-- ========================================

CREATE OR REPLACE FUNCTION enforce_max_two_events_per_day()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT COUNT(*) FROM public.events
      WHERE baby_profile_id = NEW.baby_profile_id
      AND DATE(starts_at) = DATE(NEW.starts_at)
      AND deleted_at IS NULL
      AND id != NEW.id) >= 2 THEN
    RAISE EXCEPTION 'Maximum two events per day allowed per baby profile';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_max_events_per_day
BEFORE INSERT OR UPDATE ON public.events
FOR EACH ROW EXECUTE FUNCTION enforce_max_two_events_per_day();

-- ========================================
-- Increment user_stats counters
-- ========================================

-- Increment events_attended_count on 'yes' RSVP
CREATE OR REPLACE FUNCTION increment_events_attended()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'yes' AND (TG_OP = 'INSERT' OR OLD.status != 'yes') THEN
    UPDATE public.user_stats
    SET events_attended_count = events_attended_count + 1,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER count_event_rsvp
AFTER INSERT OR UPDATE ON public.event_rsvps
FOR EACH ROW EXECUTE FUNCTION increment_events_attended();

-- Increment items_purchased_count on registry purchase
CREATE OR REPLACE FUNCTION increment_items_purchased()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.user_stats
  SET items_purchased_count = items_purchased_count + 1,
      updated_at = NOW()
  WHERE user_id = NEW.purchased_by_user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER count_registry_purchase
AFTER INSERT ON public.registry_purchases
FOR EACH ROW EXECUTE FUNCTION increment_items_purchased();

-- Increment photos_squished_count on photo squish
CREATE OR REPLACE FUNCTION increment_photos_squished()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.user_stats
  SET photos_squished_count = photos_squished_count + 1,
      updated_at = NOW()
  WHERE user_id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER count_photo_squish
AFTER INSERT ON public.photo_squishes
FOR EACH ROW EXECUTE FUNCTION increment_photos_squished();

-- Increment comments_added_count on photo comment
CREATE OR REPLACE FUNCTION increment_comments_added()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.user_stats
  SET comments_added_count = comments_added_count + 1,
      updated_at = NOW()
  WHERE user_id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER count_photo_comment
AFTER INSERT ON public.photo_comments
FOR EACH ROW EXECUTE FUNCTION increment_comments_added();

-- ========================================
-- Photo Comment Count Synchronizer
-- ========================================

CREATE OR REPLACE FUNCTION public.update_photo_comment_count()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    IF NEW.deleted_at IS NOT NULL THEN
      RETURN NEW;
    END IF;

    UPDATE public.photos
    SET comment_count = comment_count + 1
    WHERE id = NEW.photo_id;
    RETURN NEW;
  ELSIF (TG_OP = 'DELETE') THEN
    UPDATE public.photos
    SET comment_count = GREATEST(comment_count - 1, 0)
    WHERE id = OLD.photo_id;
    RETURN OLD;
  ELSIF (TG_OP = 'UPDATE') THEN
    -- Handle soft delete (if used)
    IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
      UPDATE public.photos
      SET comment_count = GREATEST(comment_count - 1, 0)
      WHERE id = NEW.photo_id;
    ELSIF OLD.deleted_at IS NOT NULL AND NEW.deleted_at IS NULL THEN
      UPDATE public.photos
      SET comment_count = (comment_count + 1)
      WHERE id = NEW.photo_id;
    END IF;
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER photo_comment_count_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.photo_comments
FOR EACH ROW EXECUTE FUNCTION public.update_photo_comment_count();

-- Backfill comment_count from existing comments to keep historical data aligned.
UPDATE public.photos p
SET comment_count = COALESCE(c.comment_count, 0)
FROM (
  SELECT photo_id, COUNT(*)::INTEGER AS comment_count
  FROM public.photo_comments
  WHERE deleted_at IS NULL
  GROUP BY photo_id
) c
WHERE p.id = c.photo_id;

UPDATE public.photos p
SET comment_count = 0
WHERE NOT EXISTS (
  SELECT 1
  FROM public.photo_comments pc
  WHERE pc.photo_id = p.id
    AND pc.deleted_at IS NULL
);
-- ========================================
-- Profile Creation Trigger
-- ========================================
-- This migration creates a database trigger that automatically
-- creates profiles and user_stats records when a new user
-- signs up via Supabase Auth.

-- ========================================
-- Function: handle_new_user
-- ========================================
-- Creates user profile and stats when auth.users record is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert new user profile when auth.users record is created
  INSERT INTO public.profiles (
    user_id,
    display_name,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'display_name',
      split_part(NEW.email, '@', 1)
    ),
    NOW(),
    NOW()
  );

  -- Also create user_stats record
  INSERT INTO public.user_stats (
    user_id,
    events_attended_count,
    items_purchased_count,
    photos_squished_count,
    comments_added_count,
    updated_at
  )
  VALUES (
    NEW.id,
    0,
    0,
    0,
    0,
    NOW()
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- Trigger: on_auth_user_created
-- ========================================
-- Trigger the handle_new_user function after each new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ========================================
-- Grant necessary permissions
-- ========================================
-- Allow the trigger to insert into user tables
GRANT USAGE ON SCHEMA public TO postgres, authenticated;
GRANT INSERT ON public.profiles TO postgres;
GRANT INSERT ON public.user_stats TO postgres;

-- ========================================
-- Comments
-- ========================================
COMMENT ON FUNCTION public.handle_new_user() IS
  'Automatically creates profiles and user_stats records when a new user signs up. '
  'Ensures data consistency between auth.users and application tables.';

-- Test Helper Functions for RLS Validation
-- This migration ensures pgTAP is installed and creates additional wrapper functions for testing

-- Ensure pgTAP is installed (provides has_table, has_column, plan, etc.)
CREATE EXTENSION IF NOT EXISTS pgtap;

-- Create a test schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS testing;

-- Custom helper: rls_enabled - checks if RLS is enabled on a table
-- This wraps pgTAP's similar function to ensure compatibility
CREATE OR REPLACE FUNCTION rls_enabled(p_schema name, p_table name, p_description text)
RETURNS text AS $$
DECLARE
  v_rls_status boolean;
BEGIN
  -- Check if RLS is enabled on the table
  SELECT relrowsecurity INTO v_rls_status
  FROM pg_class
  WHERE relname = p_table
    AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = p_schema);

  IF v_rls_status IS NULL THEN
    RETURN 'not ok - ' || p_description || ' (table not found)';
  ELSIF v_rls_status THEN
    RETURN 'ok - ' || p_description;
  ELSE
    RETURN 'not ok - ' || p_description;
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Custom helper: has_policy - checks if a policy exists on a table
-- pgTAP provides many functions but not specifically for RLS policies
CREATE OR REPLACE FUNCTION has_policy(p_schema text, p_table text, p_policy text, p_description text)
RETURNS text AS $$
DECLARE
  v_exists boolean;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM pg_policies
    WHERE schemaname = p_schema
      AND tablename = p_table
      AND policyname = p_policy
  ) INTO v_exists;

  IF v_exists THEN
    RETURN 'ok - ' || p_description;
  ELSE
    RETURN 'not ok - ' || p_description;
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;



-- Migration: Make trigger functions SECURITY DEFINER
-- Updated from: 20260302000008_make_trigger_functions_security_definer.sql
--
-- Trigger functions need to bypass RLS when updating system tables like user_stats.
-- SECURITY DEFINER allows them to execute with owner privileges rather than the
-- calling user's privileges (authenticated role).

-- ========================================
-- Update Trigger Functions to SECURITY DEFINER
-- ========================================

-- Update increment_events_attended to execute with owner privileges
CREATE OR REPLACE FUNCTION public.increment_events_attended()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'yes' AND (TG_OP = 'INSERT' OR OLD.status != 'yes') THEN
    UPDATE public.user_stats
    SET events_attended_count = events_attended_count + 1,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Update increment_items_purchased to execute with owner privileges
CREATE OR REPLACE FUNCTION public.increment_items_purchased()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.user_stats
  SET items_purchased_count = items_purchased_count + 1,
      updated_at = NOW()
  WHERE user_id = NEW.purchased_by_user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Update increment_photos_squished to execute with owner privileges
CREATE OR REPLACE FUNCTION public.increment_photos_squished()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.user_stats
  SET photos_squished_count = photos_squished_count + 1,
      updated_at = NOW()
  WHERE user_id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Update increment_comments_added to execute with owner privileges
CREATE OR REPLACE FUNCTION public.increment_comments_added()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.user_stats
  SET comments_added_count = comments_added_count + 1,
      updated_at = NOW()
  WHERE user_id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
