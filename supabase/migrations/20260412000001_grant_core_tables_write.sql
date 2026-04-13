-- Migration: Grant write permissions on core tables
-- Ensures authenticated users can create and manage baby profiles and memberships

-- Baby Profiles
GRANT INSERT, UPDATE, DELETE ON public.baby_profiles TO authenticated;

-- Baby Memberships
GRANT INSERT, UPDATE, DELETE ON public.baby_memberships TO authenticated;
