# Seed Data User Guide

## Overview

This guide provides comprehensive instructions for adding test data to the Nonna App database. The seed data is designed to support testing and development with realistic data volumes and relationships.

## Seed Data Summary

The seed data includes:
- **10 Baby Profiles** - representing 10 different families
- **30 Owner Users** - 3 owners per baby (typically mother, father, and one additional caregiver)
- **120 Follower Users** - 12 followers per baby (grandparents, aunts, uncles, friends, etc.)
- **150 Total User Profiles**
- **150 Baby Memberships** - defining access control relationships
- **User Stats** - gamification counters for all users
- **Tile System Configuration** - UI layout configurations for owners and followers

## Database Schema Dependencies

Before running the seed script, ensure the following database schema elements are in place:

### Required Tables (in dependency order):
1. `auth.users` (Supabase Auth managed)
2. `public.profiles` - User profile information
3. `public.user_stats` - User gamification statistics
4. `public.baby_profiles` - Baby profile information
5. `public.baby_memberships` - Access control relationships
6. `public.screens` - App screen definitions
7. `public.tile_definitions` - Tile type catalog
8. `public.tile_configs` - Tile layout configurations

### Required Migrations:
Ensure these migrations have been applied (in order):
1. `20251224_001_create_schema.sql` - Creates all tables
2. `20251224_002_row_level_security.sql` - Sets up RLS policies
3. `20251224_003_triggers_functions.sql` - Creates triggers and functions

## Installation Methods

### Method 1: Using Supabase CLI (Recommended)

This method works with both local development and remote Supabase projects.

#### Prerequisites:
- Supabase CLI installed (`npm install -g supabase`)
- Project initialized (`supabase init` or existing project)
- Database running (local: `supabase start`, remote: linked project)

#### Steps:

1. **Navigate to project root:**
   ```bash
   cd /path/to/nonna_app
   ```

2. **For Local Development:**
   ```bash
   # Ensure local Supabase is running
   supabase start
   
   # Apply migrations (if not already applied)
   supabase db reset
   
   # Run seed script
   supabase db seed
   ```

3. **For Remote/Hosted Supabase:**
   ```bash
   # Link to your project (one-time setup)
   supabase link --project-ref your-project-ref
   
   # Apply migrations
   supabase db push
   
   # Run seed script
   supabase db seed
   ```

#### Verification:
```bash
# Check that data was loaded
supabase db execute --query "
  SELECT 
    (SELECT COUNT(*) FROM public.profiles) as profiles,
    (SELECT COUNT(*) FROM public.baby_profiles) as babies,
    (SELECT COUNT(*) FROM public.baby_memberships WHERE role='owner') as owners,
    (SELECT COUNT(*) FROM public.baby_memberships WHERE role='follower') as followers;
"
```

Expected output:
```
profiles | babies | owners | followers
---------|--------|--------|----------
   150   |   10   |   30   |   120
```

### Method 2: Using psql Command Line

This method works with direct PostgreSQL connections.

#### Prerequisites:
- `psql` command-line tool installed
- Database connection string

#### Steps:

1. **Get your database connection string:**
   - Local: `postgresql://postgres:postgres@localhost:54322/postgres`
   - Remote: From Supabase Dashboard → Settings → Database → Connection string

2. **Run the seed script:**
   ```bash
   psql "your-connection-string" -f supabase/seed/seed_data.sql
   ```

3. **Verify the data:**
   ```bash
   psql "your-connection-string" -c "
   SELECT 
     (SELECT COUNT(*) FROM public.profiles) as profiles,
     (SELECT COUNT(*) FROM public.baby_profiles) as babies,
     (SELECT COUNT(*) FROM public.baby_memberships WHERE role='owner') as owners,
     (SELECT COUNT(*) FROM public.baby_memberships WHERE role='follower') as followers;
   "
   ```

### Method 3: Using Supabase Dashboard (Web UI)

This method uses the Supabase web interface.

#### Steps:

1. **Open your Supabase project dashboard**
2. **Navigate to SQL Editor** (left sidebar)
3. **Click "+ New query"**
4. **Copy the contents** of `supabase/seed/seed_data.sql`
5. **Paste into the SQL editor**
6. **Click "Run"** button
7. **Check the results panel** for success messages

#### Verification:
Create a new query and run:
```sql
SELECT 
  (SELECT COUNT(*) FROM public.profiles) as profiles,
  (SELECT COUNT(*) FROM public.baby_profiles) as babies,
  (SELECT COUNT(*) FROM public.baby_memberships WHERE role='owner') as owners,
  (SELECT COUNT(*) FROM public.baby_memberships WHERE role='follower') as followers;
```

## Manual Steps for Auth Users

### Important Note about auth.users Table

The seed data script **does not** insert records into the `auth.users` table because:
- The `auth.users` table is managed by Supabase Auth
- Direct inserts are not recommended and may cause authentication issues
- Production applications should use Supabase Auth API

### For Testing Purposes Only

If you need actual auth.users entries for integration testing:

#### Option A: Use Supabase Auth API (Recommended)

Create users programmatically using the Supabase client:

```javascript
// Example using Supabase JavaScript client
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient('YOUR_URL', 'YOUR_ANON_KEY');

// Create a user
const { data, error } = await supabase.auth.signUp({
  email: 'sarah.johnson@example.com',
  password: 'test_password_123',
  options: {
    data: {
      display_name: 'Sarah Johnson'
    }
  }
});
```

#### Option B: Use Supabase Dashboard

1. Navigate to **Authentication** → **Users**
2. Click **"Invite user"** or **"Add user"**
3. Enter email and optionally set password
4. Repeat for each test user

#### Option C: Bulk User Creation Script

For local development, you can use a script to create multiple users:

```dart
// Example using Dart/Flutter
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> createTestUsers() async {
  final users = [
    {'email': 'sarah.johnson@example.com', 'name': 'Sarah Johnson'},
    {'email': 'michael.johnson@example.com', 'name': 'Michael Johnson'},
    // ... add more users
  ];
  
  for (var user in users) {
    try {
      await Supabase.instance.client.auth.signUp(
        email: user['email']!,
        password: 'TestPassword123!',
      );
      print('Created user: ${user['name']}');
    } catch (e) {
      print('Error creating ${user['name']}: $e');
    }
  }
}
```

### Linking Seed Data to Auth Users

Once auth.users exist, the seed data profiles will link automatically via:
- The `user_id` foreign key in `profiles` table references `auth.users(id)`
- Triggers automatically create profile entries on auth user creation

## Data Structure and Relationships

### Baby-Owner-Follower Structure

The seed data creates a realistic structure:

```
Baby 1 (Johnson Family)
├── Owners (3)
│   ├── Sarah Johnson (Mother)
│   ├── Michael Johnson (Father)
│   └── Mary Johnson (Grandmother)
└── Followers (12)
    ├── Grandma Emma
    ├── Aunt Olivia
    ├── Uncle Liam
    └── ... 9 more followers

Baby 2 (Davis Family)
├── Owners (3)
│   ├── Emily Davis (Mother)
│   ├── John Davis (Father)
│   └── Grace Davis (Grandmother)
└── Followers (12)
    └── ... 12 followers

... (8 more babies with same structure)
```

### User ID Patterns

To help identify users in the data:
- **Owner IDs**: 
  - Mothers: `10000000-1001-1001-1001-...` to `10000009-1001-1001-1001-...`
  - Fathers: `20000000-2001-2001-2001-...` to `20000009-2001-2001-2001-...`
  - Additional: `30000000-3001-3001-3001-...` to `30000009-3001-3001-3001-...`
- **Follower IDs**: `40000000-4001-4001-4001-...` to `4000011f-4001-4001-4001-...`
- **Baby IDs**: `b0000000-b001-b001-b001-...` to `b0000009-b001-b001-b001-...`

## Validation and Testing

### 1. Check Record Counts

```sql
-- Should return: profiles=150, babies=10, memberships=150
SELECT 
  (SELECT COUNT(*) FROM public.profiles) as profiles,
  (SELECT COUNT(*) FROM public.baby_profiles) as babies,
  (SELECT COUNT(*) FROM public.baby_memberships) as memberships,
  (SELECT COUNT(*) FROM public.user_stats) as user_stats;
```

### 2. Verify Owner/Follower Distribution

```sql
-- Should show 3 owners and 12 followers per baby
SELECT 
  bp.name as baby_name,
  COUNT(CASE WHEN bm.role = 'owner' THEN 1 END) as owners,
  COUNT(CASE WHEN bm.role = 'follower' THEN 1 END) as followers
FROM public.baby_profiles bp
LEFT JOIN public.baby_memberships bm ON bp.id = bm.baby_profile_id
WHERE bm.removed_at IS NULL
GROUP BY bp.id, bp.name
ORDER BY bp.name;
```

### 3. Test Row Level Security (RLS)

```sql
-- Switch to a specific user context and verify they can only see their babies
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims.sub TO '10000000-1001-1001-1001-000000001001'; -- Sarah Johnson

-- Should return only Baby Johnson
SELECT * FROM public.baby_profiles;

-- Reset
RESET ROLE;
```

### 4. Verify Foreign Key Relationships

```sql
-- Check for any orphaned records (should return 0 for all)
SELECT 
  (SELECT COUNT(*) FROM public.baby_memberships bm 
   WHERE NOT EXISTS (SELECT 1 FROM public.profiles p WHERE p.user_id = bm.user_id)) 
   as orphaned_memberships,
  (SELECT COUNT(*) FROM public.baby_memberships bm 
   WHERE NOT EXISTS (SELECT 1 FROM public.baby_profiles bp WHERE bp.id = bm.baby_profile_id)) 
   as orphaned_baby_refs,
  (SELECT COUNT(*) FROM public.user_stats us 
   WHERE NOT EXISTS (SELECT 1 FROM public.profiles p WHERE p.user_id = us.user_id)) 
   as orphaned_stats;
```

## Troubleshooting

### Error: "relation does not exist"

**Cause**: Tables haven't been created yet.

**Solution**: Run migrations first:
```bash
supabase db reset  # Local
# or
supabase db push   # Remote
```

### Error: "duplicate key value violates unique constraint"

**Cause**: Seed data has already been loaded.

**Solution**: Either:
1. Clear the database and reload:
   ```sql
   TRUNCATE public.profiles, public.baby_profiles, 
            public.baby_memberships, public.user_stats CASCADE;
   ```
2. Or use the `ON CONFLICT DO NOTHING` clauses (already included in seed script)

### Error: "insert or update on table violates foreign key constraint"

**Cause**: Data is being inserted in wrong order.

**Solution**: The seed script respects dependency order. Make sure you're running the complete script, not individual statements.

### RLS Policies Blocking Inserts

**Cause**: RLS policies may prevent direct inserts.

**Solution**: Run seed script as superuser or bypass RLS:
```bash
# Local Supabase
supabase db seed  # Automatically uses superuser

# Or manually:
psql "your-connection-string" -c "SET session_replication_role = replica;" -f supabase/seed/seed_data.sql
```

### Auth Users Don't Match Profiles

**Cause**: Auth users were created separately from seed data.

**Solution**: 
- Seed data uses mock UUIDs for profiles
- Either create auth.users with matching UUIDs (not recommended)
- Or update profile user_ids to match real auth.users after creation
- Or use seed data for testing without auth.users (RLS will need to be disabled)

## Resetting Seed Data

To completely reset and reload seed data:

### Local Development:
```bash
supabase db reset
```

This will:
1. Drop the database
2. Recreate it
3. Run all migrations
4. Run seed script

### Remote/Production:
⚠️ **Warning**: This will delete all data!

```sql
-- Disable RLS temporarily
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.baby_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.baby_memberships DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats DISABLE ROW LEVEL SECURITY;
-- ... repeat for all tables

-- Truncate tables
TRUNCATE public.tile_configs, public.tile_definitions, public.screens CASCADE;
TRUNCATE public.baby_memberships CASCADE;
TRUNCATE public.baby_profiles CASCADE;
TRUNCATE public.user_stats CASCADE;
TRUNCATE public.profiles CASCADE;

-- Re-enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baby_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baby_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;
-- ... repeat for all tables

-- Run seed script again
\i supabase/seed/seed_data.sql
```

## Additional Resources

- **ERD Documentation**: `docs/01_discovery/05_draft_design/Enhanced_ERD.md`
- **Physical Data Model**: `docs/01_discovery/05_draft_design/Physical_Data_Model.md`
- **User Data Flow Scenarios**: `docs/01_discovery/05_draft_design/User_Data_Flow_Scenarios.md`
- **Supabase Documentation**: https://supabase.com/docs
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the ERD and data model documentation
3. Verify migration files have been applied
4. Check Supabase logs for detailed error messages

## Notes for Future Maintenance

### Updating Seed Data

If you need to modify the seed data:

1. Edit the generator script: `/tmp/generate_seed_data.py`
2. Regenerate the SQL: `python3 /tmp/generate_seed_data.py > supabase/seed/seed_data.sql`
3. Test the new seed data locally
4. Commit changes to version control

### Adding More Data Categories

To extend seed data with photos, events, registry items, etc.:

1. Add generation logic to the Python script
2. Follow the same dependency order (FK relationships)
3. Use realistic data that respects business constraints
4. Update this guide with new data categories

### Best Practices

- Always test seed data on local environment first
- Keep seed data size reasonable for quick testing
- Use realistic but anonymized data
- Document any special test scenarios
- Version control all seed scripts
- Maintain idempotency (use `ON CONFLICT DO NOTHING`)
