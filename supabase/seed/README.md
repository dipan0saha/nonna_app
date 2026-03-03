# Seed Data

This directory contains comprehensive test data for the Nonna App database.

## Quick Start

### Using Supabase CLI (Recommended)

```bash
# Ensure Supabase is running locally
supabase start

# Load seed data
supabase db seed
```

### Using psql

```bash
# Connect to your database
psql "your-connection-string" -f seed_data.sql
```

## Data Contents

### User & Baby Data
- **140 User Profiles** (20 owners + 120 followers)
- **10 Baby Profiles** (10 different families)
- **150 Baby Memberships** (20 owner + 130 follower relationships)
- **140 User Stats** (gamification data)
- **Tile System Configuration** (UI layouts)

### Calendar & Events
- **6 Events** (Baby showers, gender reveals, hospital tours)
- **8 Event RSVPs** (Yes/No/Maybe responses)
- **5 Event Comments** (Discussion on events)

### Photo Gallery
- **8 Photos** (Ultrasounds, nursery setup, baby bumps)
- **8 Photo Squishes** (Likes on photos)
- **5 Photo Comments** (Comments on photos)
- **9 Photo Tags** (Searchable tags like #ultrasound, #nursery)

### Registry
- **9 Registry Items** (Cribs, strollers, monitors, etc.)
- **4 Registry Purchases** (Items marked as purchased)

### Gamification
- **8 Votes** (Gender and birthdate predictions)
- **8 Name Suggestions** (Suggested baby names)
- **7 Name Suggestion Likes** (Votes on favorite names)

### System Features
- **10 Owner Update Markers** (Cache invalidation)
- **5 Invitations** (Pending, accepted, expired, revoked)
- **8 Notifications** (In-app notifications)
- **17 Activity Events** (Recent activity feed)

### Distribution per Baby:
- 2 Owners (Mother, Father)
- ~13 Follower relationships (some followers follow multiple babies)

## Full Documentation

This README covers the key aspects. For additional details:
- **Seed Data Files**: See files in this directory
- **Validation Scripts**: Use `validate_seed_data.sql` to verify data integrity
- **Troubleshooting**: See main README.md in parent directory

## Seed Data Setup Methods

### Method 1: Supabase CLI (Recommended)

```bash
# Ensure Supabase is running locally
supabase start

# Load seed data
supabase db seed
```

### Method 2: Direct psql Import

```bash
# Connect to your database and load seed_data.sql
psql "your-connection-string" -f seed_data.sql
```

### Method 3: Manual SQL Editor

1. Open Supabase Dashboard → SQL Editor
2. Copy contents of `seed_data.sql`
3. Run in editor

### Method 4: With Authentication Users

If you also need auth.users entries:

```bash
# Load auth users first
psql "connection-string" -f auth_users_with_identities.sql

# Then load app data
psql "connection-string" -f seed_data.sql
```

## Data Structure

```
10 Babies (Johnson, Davis, Smith, Brown, Wilson, Martinez, Garcia, Lee, Anderson, Taylor)
├── Baby 1 (Johnson)
│   ├── 2 Owners: Sarah, Michael
│   └── ~13 Followers: Grandma Emma, Aunt Olivia, Uncle Liam, etc.
├── Baby 2 (Davis)
│   ├── 2 Owners: Emily, John
│   └── ~13 Followers: ...
└── ... (8 more babies)

Note: Some owners also follow other baby profiles (cross-profile relationships)
```

## Verification

After loading, verify with:

```bash
# Quick verification
psql "your-connection-string" -f validate_seed_data.sql
```

Or run individual queries:

```sql
SELECT
  (SELECT COUNT(*) FROM public.profiles) as profiles,
  (SELECT COUNT(*) FROM public.baby_profiles) as babies,
  (SELECT COUNT(*) FROM public.baby_memberships WHERE role='owner') as owners,
  (SELECT COUNT(*) FROM public.baby_memberships WHERE role='follower') as followers;
```

To verify all tables have data:
```sql
SELECT
  'profiles' as table_name, COUNT(*) as count FROM public.profiles
UNION ALL SELECT 'baby_profiles', COUNT(*) FROM public.baby_profiles
UNION ALL SELECT 'baby_memberships', COUNT(*) FROM public.baby_memberships
UNION ALL SELECT 'user_stats', COUNT(*) FROM public.user_stats
UNION ALL SELECT 'screens', COUNT(*) FROM public.screens
UNION ALL SELECT 'tile_definitions', COUNT(*) FROM public.tile_definitions
UNION ALL SELECT 'tile_configs', COUNT(*) FROM public.tile_configs
UNION ALL SELECT 'owner_update_markers', COUNT(*) FROM public.owner_update_markers
UNION ALL SELECT 'events', COUNT(*) FROM public.events
UNION ALL SELECT 'event_rsvps', COUNT(*) FROM public.event_rsvps
UNION ALL SELECT 'event_comments', COUNT(*) FROM public.event_comments
UNION ALL SELECT 'photos', COUNT(*) FROM public.photos
UNION ALL SELECT 'photo_squishes', COUNT(*) FROM public.photo_squishes
UNION ALL SELECT 'photo_comments', COUNT(*) FROM public.photo_comments
UNION ALL SELECT 'photo_tags', COUNT(*) FROM public.photo_tags
UNION ALL SELECT 'registry_items', COUNT(*) FROM public.registry_items
UNION ALL SELECT 'registry_purchases', COUNT(*) FROM public.registry_purchases
UNION ALL SELECT 'votes', COUNT(*) FROM public.votes
UNION ALL SELECT 'name_suggestions', COUNT(*) FROM public.name_suggestions
UNION ALL SELECT 'name_suggestion_likes', COUNT(*) FROM public.name_suggestion_likes
UNION ALL SELECT 'invitations', COUNT(*) FROM public.invitations
UNION ALL SELECT 'notifications', COUNT(*) FROM public.notifications
UNION ALL SELECT 'activity_events', COUNT(*) FROM public.activity_events
ORDER BY table_name;
```

## Notes

- Uses mock UUIDs for testing
- Production apps should use Supabase Auth API for auth.users
- All data respects foreign key relationships
- Designed for development and testing only
- Idempotent (safe to run multiple times)

## Utility Tools

See `../tools/` directory for Python utilities:

### generate_inserts.py
Generates SQL INSERT statements from JSON data
```bash
python3 ../tools/generate_inserts.py data.json > inserts.sql
```

### generate_auth_user_inserts.py
Creates auth.users entries with proper password hashing
```bash
python3 ../tools/generate_auth_user_inserts.py > auth_users.sql
```

### validate_seed_fk_refs.py
Validates all foreign key relationships in seed data
```bash
python3 ../tools/validate_seed_fk_refs.py
```

### convert_seed_ids_to_uuid.py
Converts test IDs to proper UUID format
```bash
python3 ../tools/convert_seed_ids_to_uuid.py
```

## Generated By

This seed data was generated using the Python utilities in `../tools/`:
- `generate_inserts.py` - Creates SQL from JSON specifications
- `validate_seed_fk_refs.py` - Validates referential integrity
- `convert_seed_ids_to_uuid.py` - UUID conversion and normalization

The data ensures:
- ✅ All foreign key constraints satisfied
- ✅ Proper UUID formats
- ✅ Realistic test scenarios
- ✅ Cross-baby relationship support
