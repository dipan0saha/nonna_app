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
