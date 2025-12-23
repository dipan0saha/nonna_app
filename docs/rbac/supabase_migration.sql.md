# Supabase Migration Script for RBAC System

This migration script creates all necessary tables, constraints, and Row Level Security (RLS) policies for the Role-Based Access Control system.

## Prerequisites

- Supabase project created
- PostgreSQL extensions: uuid-ossp

## Migration Steps

### Step 1: Create Tables

```sql
-- ============================================================================
-- Elite Tennis Ladder RBAC Migration
-- Version: 1.0.0
-- Description: Creates tables and policies for Role-Based Access Control
-- ============================================================================

BEGIN;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE: roles
-- Description: Defines the available roles in the system
-- ============================================================================

CREATE TABLE IF NOT EXISTS roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  is_global BOOLEAN DEFAULT FALSE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT roles_name_check CHECK (name IN ('system_admin', 'organizer', 'player', 'guest'))
);

-- ============================================================================
-- TABLE: permissions
-- Description: Defines granular permissions
-- ============================================================================

CREATE TABLE IF NOT EXISTS permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT permissions_category_check CHECK (
    category IN ('platform_management', 'ladder_management', 'player_actions', 'guest_actions')
  )
);

-- ============================================================================
-- TABLE: role_permissions
-- Description: Junction table mapping roles to permissions
-- ============================================================================

CREATE TABLE IF NOT EXISTS role_permissions (
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  PRIMARY KEY (role_id, permission_id)
);

CREATE INDEX IF NOT EXISTS idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_permission_id ON role_permissions(permission_id);

-- ============================================================================
-- TABLE: ladders (placeholder for future implementation)
-- Description: Ladder instances (will be fully implemented in Epic 27)
-- ============================================================================

CREATE TABLE IF NOT EXISTS ladders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  is_public BOOLEAN DEFAULT TRUE,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  settings JSONB DEFAULT '{}'::jsonb,
  
  CONSTRAINT ladders_name_length CHECK (char_length(name) >= 3 AND char_length(name) <= 100)
);

CREATE INDEX IF NOT EXISTS idx_ladders_created_by ON ladders(created_by);
CREATE INDEX IF NOT EXISTS idx_ladders_is_public ON ladders(is_public);

-- ============================================================================
-- TABLE: user_roles
-- Description: Junction table assigning roles to users with optional ladder context
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  ladder_id UUID REFERENCES ladders(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb,
  
  CONSTRAINT user_roles_unique_assignment UNIQUE (user_id, role_id, ladder_id)
);

CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_ladder_id ON user_roles(ladder_id) WHERE ladder_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_user_roles_user_ladder ON user_roles(user_id, ladder_id) WHERE ladder_id IS NOT NULL;

COMMIT;
```

### Step 2: Insert Default Data

```sql
BEGIN;

-- ============================================================================
-- Insert default roles
-- ============================================================================

INSERT INTO roles (name, display_name, description, is_global) VALUES
  ('system_admin', 'System Admin', 'Platform superuser who manages global settings and users', TRUE),
  ('organizer', 'Tournament Organizer', 'User who owns and manages a specific ladder instance', FALSE),
  ('player', 'Player', 'End-user participating in a ladder', FALSE),
  ('guest', 'Guest', 'Non-logged-in or limited-access user', FALSE)
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- Insert default permissions
-- ============================================================================

-- Platform Management Permissions
INSERT INTO permissions (name, display_name, description, category) VALUES
  ('manage_users', 'Manage Users', 'Manage global user accounts (ban, delete, restore)', 'platform_management'),
  ('manage_subscriptions', 'Manage Subscriptions', 'Configure subscription plans and pricing', 'platform_management'),
  ('view_platform_analytics', 'View Platform Analytics', 'View platform-wide analytics and metrics', 'platform_management'),
  ('manage_platform_settings', 'Manage Platform Settings', 'Manage global platform settings', 'platform_management')
ON CONFLICT (name) DO NOTHING;

-- Ladder Management Permissions
INSERT INTO permissions (name, display_name, description, category) VALUES
  ('create_ladder', 'Create Ladder', 'Create new ladder instances', 'ladder_management'),
  ('delete_ladder', 'Delete Ladder', 'Delete ladder instances', 'ladder_management'),
  ('configure_ladder', 'Configure Ladder', 'Configure ladder rules and settings', 'ladder_management'),
  ('manage_ladder_members', 'Manage Ladder Members', 'Approve/kick players from ladder', 'ladder_management'),
  ('resolve_disputes', 'Resolve Disputes', 'Resolve match disputes', 'ladder_management'),
  ('modify_match_results', 'Modify Match Results', 'Overturn or modify match results', 'ladder_management'),
  ('send_broadcasts', 'Send Broadcasts', 'Send messages to all ladder members', 'ladder_management'),
  ('view_ladder_analytics', 'View Ladder Analytics', 'View ladder-specific analytics', 'ladder_management')
ON CONFLICT (name) DO NOTHING;

-- Player Action Permissions
INSERT INTO permissions (name, display_name, description, category) VALUES
  ('view_ladder', 'View Ladder', 'View ladder details and rankings', 'player_actions'),
  ('issue_challenges', 'Issue Challenges', 'Challenge other players', 'player_actions'),
  ('report_match_scores', 'Report Match Scores', 'Report match scores', 'player_actions'),
  ('confirm_match_scores', 'Confirm Match Scores', 'Confirm match scores reported by opponent', 'player_actions'),
  ('manage_own_profile', 'Manage Own Profile', 'Update own player profile', 'player_actions'),
  ('view_match_history', 'View Match History', 'View match history', 'player_actions')
ON CONFLICT (name) DO NOTHING;

-- Guest Action Permissions
INSERT INTO permissions (name, display_name, description, category) VALUES
  ('view_public_ladders', 'View Public Ladders', 'View public ladder information', 'guest_actions'),
  ('view_public_rankings', 'View Public Rankings', 'View public rankings', 'guest_actions')
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- Insert role-permission mappings
-- ============================================================================

-- System Admin permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'system_admin'
  AND p.name IN (
    'manage_users',
    'manage_subscriptions',
    'view_platform_analytics',
    'manage_platform_settings',
    'view_ladder',
    'view_public_ladders',
    'view_public_rankings',
    'view_ladder_analytics'
  )
ON CONFLICT DO NOTHING;

-- Organizer permissions (includes all player permissions)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'organizer'
  AND p.name IN (
    'create_ladder',
    'delete_ladder',
    'configure_ladder',
    'manage_ladder_members',
    'resolve_disputes',
    'modify_match_results',
    'send_broadcasts',
    'view_ladder_analytics',
    'view_ladder',
    'issue_challenges',
    'report_match_scores',
    'confirm_match_scores',
    'manage_own_profile',
    'view_match_history'
  )
ON CONFLICT DO NOTHING;

-- Player permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'player'
  AND p.name IN (
    'view_ladder',
    'issue_challenges',
    'report_match_scores',
    'confirm_match_scores',
    'manage_own_profile',
    'view_match_history'
  )
ON CONFLICT DO NOTHING;

-- Guest permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'guest'
  AND p.name IN (
    'view_public_ladders',
    'view_public_rankings'
  )
ON CONFLICT DO NOTHING;

COMMIT;
```

### Step 3: Enable Row Level Security

```sql
BEGIN;

-- ============================================================================
-- Enable RLS on all tables
-- ============================================================================

ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE ladders ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS Policies for roles table
-- ============================================================================

-- Anyone can read roles (needed for UI)
CREATE POLICY "Anyone can view roles"
  ON roles FOR SELECT
  TO authenticated, anon
  USING (TRUE);

-- ============================================================================
-- RLS Policies for permissions table
-- ============================================================================

-- Anyone can read permissions (needed for UI)
CREATE POLICY "Anyone can view permissions"
  ON permissions FOR SELECT
  TO authenticated, anon
  USING (TRUE);

-- ============================================================================
-- RLS Policies for role_permissions table
-- ============================================================================

-- Anyone can read role permissions (needed for permission checks)
CREATE POLICY "Anyone can view role permissions"
  ON role_permissions FOR SELECT
  TO authenticated, anon
  USING (TRUE);

-- ============================================================================
-- RLS Policies for user_roles table
-- ============================================================================

-- Users can view their own role assignments
CREATE POLICY "Users can view own role assignments"
  ON user_roles FOR SELECT
  USING (auth.uid() = user_id);

-- Note: Additional policies for INSERT/UPDATE/DELETE will depend on the
-- auth.users table structure and should be added after Supabase Auth is configured

COMMIT;
```

### Step 4: Create Helper Functions

```sql
BEGIN;

-- ============================================================================
-- Function: check_user_permission
-- Description: Check if a user has a specific permission in a given context
-- ============================================================================

CREATE OR REPLACE FUNCTION check_user_permission(
  p_user_id UUID,
  p_permission_name TEXT,
  p_ladder_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM user_roles ur
    JOIN role_permissions rp ON ur.role_id = rp.role_id
    JOIN permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = p_user_id
      AND p.name = p_permission_name
      AND (
        -- Global role (no ladder context required)
        ur.ladder_id IS NULL
        OR
        -- Ladder-specific role with matching context
        (p_ladder_id IS NOT NULL AND ur.ladder_id = p_ladder_id)
      )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- Function: get_user_roles_for_ladder
-- Description: Get all roles a user has in a specific ladder
-- ============================================================================

CREATE OR REPLACE FUNCTION get_user_roles_for_ladder(
  p_user_id UUID,
  p_ladder_id UUID
)
RETURNS TABLE (
  role_name TEXT,
  role_display_name TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT r.name, r.display_name
  FROM user_roles ur
  JOIN roles r ON ur.role_id = r.id
  WHERE ur.user_id = p_user_id
    AND (ur.ladder_id = p_ladder_id OR ur.ladder_id IS NULL);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMIT;
```

## Verification Queries

After running the migration, verify the setup:

```sql
-- Check roles
SELECT * FROM roles ORDER BY name;

-- Check permissions by category
SELECT category, COUNT(*) as permission_count
FROM permissions
GROUP BY category
ORDER BY category;

-- Check role-permission mappings
SELECT 
  r.display_name as role,
  COUNT(rp.permission_id) as permission_count
FROM roles r
LEFT JOIN role_permissions rp ON r.id = rp.role_id
GROUP BY r.id, r.display_name
ORDER BY r.display_name;

-- View all permissions for a role
SELECT 
  r.display_name as role,
  p.display_name as permission,
  p.category
FROM role_permissions rp
JOIN roles r ON rp.role_id = r.id
JOIN permissions p ON rp.permission_id = p.id
WHERE r.name = 'organizer'
ORDER BY p.category, p.display_name;
```

## Rollback Script

If you need to rollback the migration:

```sql
BEGIN;

-- Drop helper functions
DROP FUNCTION IF EXISTS check_user_permission(UUID, TEXT, UUID);
DROP FUNCTION IF EXISTS get_user_roles_for_ladder(UUID, UUID);

-- Drop tables (in reverse order of creation)
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS role_permissions CASCADE;
DROP TABLE IF EXISTS ladders CASCADE;
DROP TABLE IF EXISTS permissions CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

COMMIT;
```

## Next Steps

1. Configure Supabase Auth and link to the `user_roles` table
2. Add additional RLS policies based on auth.users table structure
3. Implement the full `ladders` table schema in Epic 27
4. Create admin interface for managing role assignments
5. Integrate with Flutter app using Supabase SDK

## Notes

- The `is_system_admin` flag should be added to the Supabase auth.users table or a profiles extension table
- The `ladders` table is a placeholder and will be fully implemented in Epic 27
- Additional RLS policies may be needed based on specific security requirements
- Consider adding audit logging for role assignment changes in production
