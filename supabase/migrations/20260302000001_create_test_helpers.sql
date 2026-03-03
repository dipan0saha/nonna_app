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



