-- Migration: Fix all tile_configs RLS policies and permissions
-- Consolidates: 20260302000009 + 20260302000010 + 20260302000011 + 20260302000012
--
-- Tile_configs table requires special RLS handling to support test execution
-- and allow different user roles (authenticated, anon, postgres) appropriate access

-- ========================================
-- Drop Old Policies (if any exist)
-- ========================================

DROP POLICY IF EXISTS "Authenticated users can view tile configs for their role" ON public.tile_configs;
DROP POLICY IF EXISTS "Postgres superuser can access all tile configs" ON public.tile_configs;
DROP POLICY IF EXISTS "Authenticated users can view visible tile configs" ON public.tile_configs;
DROP POLICY IF EXISTS "Anonymous users cannot see tile configs" ON public.tile_configs;
DROP POLICY IF EXISTS "Postgres can access all tile configs" ON public.tile_configs;
DROP POLICY IF EXISTS "Postgres can insert tile configs" ON public.tile_configs;
DROP POLICY IF EXISTS "Postgres can update tile configs" ON public.tile_configs;
DROP POLICY IF EXISTS "Postgres can delete tile configs" ON public.tile_configs;

-- ========================================
-- RLS Policies for tile_configs
-- ========================================

-- Authenticated users can view visible tile configs only
CREATE POLICY "Authenticated users can view visible tile configs"
  ON public.tile_configs FOR SELECT
  TO authenticated
  USING (is_visible = TRUE);

-- Anonymous users cannot see any tile configs (returns empty result set)
CREATE POLICY "Anonymous users cannot see tile configs"
  ON public.tile_configs FOR SELECT
  TO anon
  USING (FALSE);

-- Postgres role (test runner and admin) has full access for testing and administration
CREATE POLICY "Postgres can access all tile configs"
  ON public.tile_configs FOR SELECT
  TO postgres
  USING (TRUE);

CREATE POLICY "Postgres can insert tile configs"
  ON public.tile_configs FOR INSERT
  TO postgres
  WITH CHECK (TRUE);

CREATE POLICY "Postgres can update tile configs"
  ON public.tile_configs FOR UPDATE
  TO postgres
  USING (TRUE)
  WITH CHECK (TRUE);

CREATE POLICY "Postgres can delete tile configs"
  ON public.tile_configs FOR DELETE
  TO postgres
  USING (TRUE);

-- ========================================
-- Table-Level Permissions
-- ========================================

-- Ensure anon role has SELECT permission (required even with restrictive RLS policy)
GRANT SELECT ON public.tile_configs TO anon;
