-- Migration: Fix baby_profiles RLS SELECT policy paradox
-- Adds a created_by column to baby_profiles and updates the SELECT policy 
-- to allow creators to read their newly inserted rows before the membership is created.

-- 1. Add created_by column defaulting to the inserting user's ID
ALTER TABLE public.baby_profiles 
ADD COLUMN IF NOT EXISTS created_by uuid DEFAULT auth.uid();

-- 2. Drop the old SELECT policy
DROP POLICY IF EXISTS "Members can view baby profiles" ON public.baby_profiles;

-- 3. Create the new SELECT policy that includes the created_by check
CREATE POLICY "Members can view baby profiles" ON public.baby_profiles FOR SELECT
USING (is_baby_member(auth.uid(), id) OR created_by = auth.uid());

-- 4. Fix baby_memberships SELECT policy paradox
DROP POLICY IF EXISTS "Members can view memberships for their babies" ON public.baby_memberships;

CREATE POLICY "Members can view memberships for their babies" ON public.baby_memberships FOR SELECT
USING (user_id = auth.uid() OR is_baby_member(auth.uid(), baby_profile_id));
