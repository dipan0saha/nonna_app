-- ========================================
-- Profile Creation Trigger
-- ========================================
-- This migration creates a database trigger that automatically
-- creates user_profiles and user_stats records when a new user
-- signs up via Supabase Auth.
--
-- Issue: #3.23 Fix Services implementation review comments
-- Reference: docs/Services_Review_Report.md (Section 3.1)
-- Reference: docs/Services_Implementation_Recommendations.md (Section 1)

-- ========================================
-- Function: handle_new_user
-- ========================================
-- Creates user profile and stats when auth.users record is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert new user profile when auth.users record is created
  INSERT INTO public.user_profiles (
    user_id,
    email,
    display_name,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
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
    photos_uploaded,
    events_created,
    comments_made,
    reactions_given,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    0,
    0,
    0,
    0,
    NOW(),
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
GRANT INSERT ON public.user_profiles TO postgres;
GRANT INSERT ON public.user_stats TO postgres;

-- ========================================
-- Comments
-- ========================================
COMMENT ON FUNCTION public.handle_new_user() IS 
  'Automatically creates user_profiles and user_stats records when a new user signs up. '
  'Ensures data consistency between auth.users and application tables.';

COMMENT ON TRIGGER on_auth_user_created ON auth.users IS 
  'Triggers handle_new_user() function to create user profile and stats on signup.';
