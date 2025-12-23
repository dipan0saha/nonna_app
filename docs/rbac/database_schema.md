# Database Schema Design for RBAC System

## Overview

This document defines the database schema for the Elite Tennis Ladder Role-Based Access Control (RBAC) system. The schema supports context-specific role assignments, where users can have different roles in different ladders.

## Core Design Principles

1. **Role Separation**: Clear distinction between System Admin (platform management) and Tournament Organizer (ladder management)
2. **Context-Specific Roles**: Users can have different roles in different ladder contexts
3. **Organizer Autonomy**: Each ladder is independent with its own rules and permissions
4. **Security First**: Row Level Security (RLS) policies enforce access control at the database level

## Database Tables

### 1. users

The core user table managed by Supabase Auth with extended profile information.

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  is_system_admin BOOLEAN DEFAULT FALSE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB DEFAULT '{}'::jsonb,
  
  -- Constraints
  CONSTRAINT users_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_system_admin ON users(is_system_admin) WHERE is_system_admin = TRUE;

-- RLS Policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile (except is_system_admin)
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id AND is_system_admin = (SELECT is_system_admin FROM users WHERE id = auth.uid()));

-- System admins can view all users
CREATE POLICY "System admins can view all users"
  ON users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND is_system_admin = TRUE
    )
  );
```

### 2. roles

Defines the available roles in the system.

```sql
CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  is_global BOOLEAN DEFAULT FALSE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT roles_name_check CHECK (name IN ('system_admin', 'organizer', 'player', 'guest'))
);

-- Insert default roles
INSERT INTO roles (name, display_name, description, is_global) VALUES
  ('system_admin', 'System Admin', 'Platform superuser who manages global settings and users', TRUE),
  ('organizer', 'Tournament Organizer', 'User who owns and manages a specific ladder instance', FALSE),
  ('player', 'Player', 'End-user participating in a ladder', FALSE),
  ('guest', 'Guest', 'Non-logged-in or limited-access user', FALSE);

-- RLS Policies
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

-- Anyone can read roles (needed for UI)
CREATE POLICY "Anyone can view roles"
  ON roles FOR SELECT
  TO authenticated, anon
  USING (TRUE);
```

### 3. permissions

Defines granular permissions that can be assigned to roles.

```sql
CREATE TABLE permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT permissions_category_check CHECK (
    category IN ('platform_management', 'ladder_management', 'player_actions', 'guest_actions')
  )
);

-- Insert default permissions
INSERT INTO permissions (name, display_name, description, category) VALUES
  -- Platform Management
  ('manage_users', 'Manage Users', 'Manage global user accounts', 'platform_management'),
  ('manage_subscriptions', 'Manage Subscriptions', 'Configure subscription plans', 'platform_management'),
  ('view_platform_analytics', 'View Platform Analytics', 'View platform-wide metrics', 'platform_management'),
  ('manage_platform_settings', 'Manage Platform Settings', 'Manage global settings', 'platform_management'),
  
  -- Ladder Management
  ('create_ladder', 'Create Ladder', 'Create new ladder instances', 'ladder_management'),
  ('delete_ladder', 'Delete Ladder', 'Delete ladder instances', 'ladder_management'),
  ('configure_ladder', 'Configure Ladder', 'Configure ladder rules', 'ladder_management'),
  ('manage_ladder_members', 'Manage Ladder Members', 'Approve/kick ladder members', 'ladder_management'),
  ('resolve_disputes', 'Resolve Disputes', 'Resolve match disputes', 'ladder_management'),
  ('modify_match_results', 'Modify Match Results', 'Overturn match results', 'ladder_management'),
  ('send_broadcasts', 'Send Broadcasts', 'Send messages to ladder members', 'ladder_management'),
  ('view_ladder_analytics', 'View Ladder Analytics', 'View ladder-specific analytics', 'ladder_management'),
  
  -- Player Actions
  ('view_ladder', 'View Ladder', 'View ladder details and rankings', 'player_actions'),
  ('issue_challenges', 'Issue Challenges', 'Challenge other players', 'player_actions'),
  ('report_match_scores', 'Report Match Scores', 'Report match scores', 'player_actions'),
  ('confirm_match_scores', 'Confirm Match Scores', 'Confirm match scores', 'player_actions'),
  ('manage_own_profile', 'Manage Own Profile', 'Update own player profile', 'player_actions'),
  ('view_match_history', 'View Match History', 'View match history', 'player_actions'),
  
  -- Guest Actions
  ('view_public_ladders', 'View Public Ladders', 'View public ladder information', 'guest_actions'),
  ('view_public_rankings', 'View Public Rankings', 'View public rankings', 'guest_actions');

-- RLS Policies
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;

-- Anyone can read permissions (needed for UI)
CREATE POLICY "Anyone can view permissions"
  ON permissions FOR SELECT
  TO authenticated, anon
  USING (TRUE);
```

### 4. role_permissions

Junction table mapping roles to their permissions.

```sql
CREATE TABLE role_permissions (
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  PRIMARY KEY (role_id, permission_id)
);

-- Create indexes
CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission_id ON role_permissions(permission_id);

-- Insert default role-permission mappings
-- (This will be populated via a migration script based on RolePermissions class)

-- RLS Policies
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;

-- Anyone can read role permissions (needed for permission checks)
CREATE POLICY "Anyone can view role permissions"
  ON role_permissions FOR SELECT
  TO authenticated, anon
  USING (TRUE);

-- Only system admins can modify role permissions
CREATE POLICY "System admins can manage role permissions"
  ON role_permissions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND is_system_admin = TRUE
    )
  );
```

### 5. user_roles

Junction table assigning roles to users with optional ladder context.

```sql
CREATE TABLE user_roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  ladder_id UUID REFERENCES ladders(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb,
  
  -- Constraints to ensure valid role assignments
  CONSTRAINT user_roles_unique_assignment UNIQUE (user_id, role_id, ladder_id),
  CONSTRAINT user_roles_system_admin_global CHECK (
    (role_id != (SELECT id FROM roles WHERE name = 'system_admin')) OR ladder_id IS NULL
  ),
  CONSTRAINT user_roles_organizer_ladder_specific CHECK (
    (role_id != (SELECT id FROM roles WHERE name = 'organizer')) OR ladder_id IS NOT NULL
  ),
  CONSTRAINT user_roles_player_ladder_specific CHECK (
    (role_id != (SELECT id FROM roles WHERE name = 'player')) OR ladder_id IS NOT NULL
  )
);

-- Create indexes
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX idx_user_roles_ladder_id ON user_roles(ladder_id) WHERE ladder_id IS NOT NULL;
CREATE INDEX idx_user_roles_user_ladder ON user_roles(user_id, ladder_id) WHERE ladder_id IS NOT NULL;

-- RLS Policies
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Users can view their own role assignments
CREATE POLICY "Users can view own role assignments"
  ON user_roles FOR SELECT
  USING (auth.uid() = user_id);

-- System admins can view all role assignments
CREATE POLICY "System admins can view all role assignments"
  ON user_roles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND is_system_admin = TRUE
    )
  );

-- Ladder organizers can view role assignments for their ladder
CREATE POLICY "Organizers can view ladder role assignments"
  ON user_roles FOR SELECT
  USING (
    ladder_id IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid()
        AND ur.ladder_id = user_roles.ladder_id
        AND r.name = 'organizer'
    )
  );

-- Only system admins can assign system admin role
CREATE POLICY "System admins can assign system admin role"
  ON user_roles FOR INSERT
  WITH CHECK (
    role_id = (SELECT id FROM roles WHERE name = 'system_admin') AND
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND is_system_admin = TRUE
    )
  );

-- Ladder organizers can assign player roles in their ladder
CREATE POLICY "Organizers can assign player roles"
  ON user_roles FOR INSERT
  WITH CHECK (
    role_id = (SELECT id FROM roles WHERE name = 'player') AND
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid()
        AND ur.ladder_id = ladder_id
        AND r.name = 'organizer'
    )
  );

-- Ladder organizers can remove role assignments in their ladder (except organizer)
CREATE POLICY "Organizers can remove ladder role assignments"
  ON user_roles FOR DELETE
  USING (
    ladder_id IS NOT NULL AND
    role_id != (SELECT id FROM roles WHERE name = 'organizer') AND
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid()
        AND ur.ladder_id = user_roles.ladder_id
        AND r.name = 'organizer'
    )
  );

-- System admins can manage all role assignments
CREATE POLICY "System admins can manage all role assignments"
  ON user_roles FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND is_system_admin = TRUE
    )
  );
```

### 6. ladders

Reference table for ladder instances (to be fully defined in a separate epic).

```sql
CREATE TABLE ladders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  is_public BOOLEAN DEFAULT TRUE,
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  settings JSONB DEFAULT '{}'::jsonb,
  
  -- Additional fields will be added in Epic 27
  CONSTRAINT ladders_name_length CHECK (char_length(name) >= 3 AND char_length(name) <= 100)
);

-- Create indexes
CREATE INDEX idx_ladders_created_by ON ladders(created_by);
CREATE INDEX idx_ladders_is_public ON ladders(is_public);

-- RLS Policies will be added in Epic 27
ALTER TABLE ladders ENABLE ROW LEVEL SECURITY;
```

## Helper Functions

### Function: check_user_permission

Helper function to check if a user has a specific permission in a given context.

```sql
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
    JOIN roles r ON ur.role_id = r.id
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
```

### Function: get_user_roles_for_ladder

Get all roles a user has in a specific ladder.

```sql
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
```

## Migration Script

```sql
-- Migration: Create RBAC tables and policies
-- Version: 1.0.0
-- Date: 2024-01-15

BEGIN;

-- Create extensions if not exists
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Run all table creation scripts in order
-- (Include all the CREATE TABLE statements above)

-- Populate default data
-- (Include all INSERT statements above)

-- Create helper functions
-- (Include function definitions above)

COMMIT;
```

## Indexes Strategy

The schema includes strategic indexes to optimize common queries:

1. **User lookups**: `idx_users_email`, `idx_users_is_system_admin`
2. **Role assignment queries**: `idx_user_roles_user_id`, `idx_user_roles_ladder_id`, `idx_user_roles_user_ladder`
3. **Permission lookups**: `idx_role_permissions_role_id`, `idx_role_permissions_permission_id`
4. **Ladder queries**: `idx_ladders_created_by`, `idx_ladders_is_public`

## Security Considerations

1. **Row Level Security (RLS)**: All tables have RLS enabled with policies that enforce access control
2. **System Admin Flag**: The `is_system_admin` flag cannot be modified by regular users
3. **Constraint Validation**: Database constraints ensure role assignments are valid (e.g., System Admin must be global)
4. **Organizer Autonomy**: RLS policies ensure organizers can only manage their own ladders
5. **Permission Checking**: Helper functions use SECURITY DEFINER to safely check permissions

## Future Enhancements

1. **Audit Logging**: Add audit trail for role assignments and permission changes
2. **Role Expiration**: Add optional expiration dates for role assignments
3. **Custom Permissions**: Allow organizers to define custom permissions for their ladders
4. **Role Hierarchy**: Implement role inheritance for more flexible permission management
5. **Bulk Operations**: Add functions for bulk role assignment/removal

## References

- [Supabase Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html)
- [PostgreSQL Indexes](https://www.postgresql.org/docs/current/indexes.html)
