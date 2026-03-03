# Nonna App - Supabase Database Setup

This directory contains all database-related files for the Nonna App, including migration scripts, RLS policies, triggers, and seed data.

## 📁 Directory Structure

```
supabase/
├── migrations/              # 9 sequential database migration scripts
│   ├── 20260104000000_install_extensions.sql              # PostgreSQL extensions
│   ├── 20260104000001_initial_schema.sql                  # Tables & constraints
│   ├── 20260104000002_enable_rls.sql                      # Enable RLS on tables
│   ├── 20260104000003_rls_policies.sql                    # RLS policies & permissions
│   ├── 20260104000004_indexes.sql                         # Performance indexes
│   ├── 20260104000005_triggers.sql                        # Automation triggers
│   ├── 20260104000006_create_storage_buckets.sql          # Cloud Storage setup
│   ├── 20260203000001_app_versions_table.sql              # App version tracking
│   └── 20260206000001_profile_creation_trigger.sql        # Auth profile creation
├── functions/               # 6 Deno/TypeScript Edge Functions
│   ├── generate-thumbnail/                                # Photo thumbnail generation
│   ├── image-processing/                                  # Image optimization
│   ├── notification-trigger/                              # Notification creation
│   ├── send-invitation-email/                             # Email service
│   ├── send-push-notification/                            # Push notification service
│   └── tile-configs/                                      # Dynamic tile configuration
├── seed/                    # Test data & seed utilities
│   ├── seed_data.sql                                      # Sample data script
│   ├── validate_seed_data.sql                             # Verification queries
│   ├── auth_users_seed.sql                                # Auth user inserts
│   ├── auth_users_with_identities.sql                     # Auth with identities
│   ├── manual_db_and_seed_creation.sql                    # Manual setup guide
│   └── README.md                                          # Seed data documentation
├── tests/                   # Database & RLS testing
│   ├── rls_policies/                                      # RLS policy tests
│   │   ├── baby_profiles_rls_test.sql
│   │   ├── events_rls_test.sql
│   │   ├── profiles_rls_test.sql
│   │   └── photos_rls_test.sql
├── tools/                   # Utility scripts for development
│   ├── convert_seed_ids_to_uuid.py                        # UUID conversion
│   ├── generate_auth_user_inserts.py                      # Auth user generation
│   ├── generate_inserts.py                                # Seed data generation
│   └── validate_seed_fk_refs.py                           # FK reference validation
├── monitoring/              # Database monitoring
│   └── queries.sql                                        # Performance monitoring queries
├── config.toml              # Supabase CLI configuration
├── seed.sql                 # Root-level seed data script
└── docs/                    # Documentation
    ├── README.md                                          # This file
    ├── REALTIME_CONFIGURATION.md                          # Realtime setup guide
    ├── LOCAL vs PROD.md                                   # Local vs Production comparison
    └── Local Supabase Setup Guide.md                      # Local development guide
```

## 🚀 Quick Start

### Prerequisites

- Supabase account and project
- Supabase CLI installed: `npm install -g supabase`
- PostgreSQL 15+ (for local development)

### Initial Setup

1. **Initialize Supabase** (if not already done):
   ```bash
   supabase init
   ```

2. **Link to your Supabase project**:
   ```bash
   supabase link --project-ref your-project-ref
   ```

3. **Run migrations in order**:
   ```bash
   supabase db push
   ```

   All migrations run automatically in sequence. They can also be run individually:
   ```bash
   # Extensions
   supabase db push --file migrations/20260104000000_install_extensions.sql

   # Schema (tables, constraints, foreign keys)
   supabase db push --file migrations/20260104000001_initial_schema.sql

   # Enable RLS on all tables
   supabase db push --file migrations/20260104000002_enable_rls.sql

   # RLS policies - define access rules
   supabase db push --file migrations/20260104000003_rls_policies.sql

   # Indexes - performance optimization
   supabase db push --file migrations/20260104000004_indexes.sql

   # Triggers & Functions - automation
   supabase db push --file migrations/20260104000005_triggers.sql

   # Storage buckets for media
   supabase db push --file migrations/20260104000006_create_storage_buckets.sql

   # App versioning feature
   supabase db push --file migrations/20260203000001_app_versions_table.sql

   # Profile auto-creation on signup
   supabase db push --file migrations/20260206000001_profile_creation_trigger.sql
   ```

4. **Load seed data** (development only):
   ```bash
   supabase db push --file seed/seed_data.sql
   ```

5. **Configure Realtime**:
   - Follow instructions in `REALTIME_CONFIGURATION.md`
   - Or via dashboard: Database → Replication → Enable for required tables

### Alternative: All-in-One Setup

For new projects, you can run all migrations at once:
```bash
supabase db push --include-all
```

## 📋 Migration Scripts Overview

### Migration Execution Order

All migrations run in filename order (they're numbered 00000-00009). Execute all with:
```bash
supabase db push
```

### 1. Install Extensions (`20260104000000_install_extensions.sql`)

**Purpose**: Load required PostgreSQL extensions

**Installs**:
- ✅ `uuid-ossp` - UUID generation functions
- ✅ `pg_stat_statements` - Performance monitoring
- ✅ `pg_trgm` - Text search using trigrams (full-text search)
- ✅ `btree_gin` - GIN indexes (multi-column searches)

**Run time**: ~1-2 seconds

### 2. Initial Schema (`20260104000001_initial_schema.sql`)

**Purpose**: Creates all tables, constraints, and relationships

**Contains**:
- ✅ 23 application tables (public schema)
- ✅ UUID primary keys with `gen_random_uuid()`
- ✅ Auth schema integration with CASCADE deletes
- ✅ Foreign key constraints for referential integrity
- ✅ Audit fields (id, created_at, updated_at) on all tables
- ✅ CHECK constraints for enums (role, gender, status)
- ✅ Unique constraints for business rules

**Key Table Categories**:
- User Identity: `profiles`, `user_stats`
- Baby Management: `baby_profiles`, `baby_memberships`, `invitations`
- UI Configuration: `screens`, `tile_definitions`, `tile_configs`
- Content: `events`, `photos`, `registry_items`
- Interactions: `event_rsvps`, `photo_squishes`, `event_comments`, `photo_comments`
- Gamification: `votes`, `name_suggestions`, `name_suggestion_likes`
- System: `notifications`, `activity_events`, `owner_update_markers`

**Run time**: ~3-5 seconds

### 3. Enable RLS (`20260104000002_enable_rls.sql`)

**Purpose**: Enable Row-Level Security on all tables

**Enables**:
- ✅ RLS on all 23 application tables
- ✅ Default-deny policy (blocks all access by default)
- ✅ Preparation for granular RLS policies

**Run time**: ~1-2 seconds

### 4. RLS Policies (`20260104000003_rls_policies.sql`)

**Purpose**: Define granular access control rules

**Implements**:
- ✅ 80+ RLS policies across all tables
- ✅ Role-based access (authenticated, anon, service_role)
- ✅ Helper functions: `is_baby_member()`, `is_baby_owner()`, `is_owner_or_self()`
- ✅ Owner moderation capabilities
- ✅ Follower interaction permissions
- ✅ Public/private content rules

**Access Model**:
| Action | Owner | Follower | Anon |
|--------|-------|----------|------|
| Read content | ✅ | ✅ | Limited |
| Create content | ✅ | ❌ | ❌ |
| Comment | ✅ | ✅ | ❌ |
| Delete comment | ✅ (any) | Own only | ❌ |
| RSVP/Vote | ✅ | ✅ | ❌ |

**Run time**: ~5-8 seconds

### 5. Indexes (`20260104000004_indexes.sql`)

**Purpose**: Optimize query performance

**Creates**:
- ✅ B-tree indexes on foreign keys
- ✅ GIN indexes for full-text search (photo tags)
- ✅ Partial indexes (e.g., active memberships only)
- ✅ Multi-column indexes (member lookups)
- ✅ ~20+ indexes total

**Run time**: ~3-5 seconds

### 6. Triggers & Functions (`20260104000005_triggers.sql`)

**Purpose**: Automate common database operations

**Includes**:
- ✅ 25+ triggers for automation
- ✅ 10+ database functions
- ✅ Profile auto-creation on user signup
- ✅ Auto-update timestamps (`updated_at`)
- ✅ Cache invalidation (`owner_update_markers`)
- ✅ Gamification stats auto-increment
- ✅ Activity event logging
- ✅ In-app notification creation
- ✅ Business rule enforcement

**Key Automation**:
```
User signs up
  ↓ trigger: on_auth_user_created
  ↓ function: handle_new_user()
  ↓ creates: profiles, user_stats

Photo uploaded
  ↓ trigger: on_photo_insert
  ↓ function: log_activity_event()
  ↓ creates: activity_events, notifications
  ↓ function: update_owner_marker()
  ↓ invalidates: follower cache
```

**Run time**: ~2-3 seconds

### 7. Storage Buckets (`20260104000006_create_storage_buckets.sql`)

**Purpose**: Set up Supabase Storage for media files

**Creates**:
- ✅ `photos` bucket - Photo gallery storage
- ✅ `documents` bucket - Document storage
- ✅ `profiles` bucket - Profile pictures
- ✅ Storage policies (RLS integration)

**Run time**: ~1-2 seconds

### 8. App Versions (`20260203000001_app_versions_table.sql`)

**Purpose**: Track app version history and notifications

**Adds**:
- ✅ `app_versions` table
- ✅ Version tracking for updates
- ✅ Notification triggers for new versions

**Run time**: ~1 second

### 9. Profile Creation Trigger (`20260206000001_profile_creation_trigger.sql`)

**Purpose**: Enhance profile creation workflow

**Improves**:
- ✅ Additional profile creation logic
- ✅ Default configuration setup
- ✅ Initial user stats creation

**Run time**: ~1 second

**Total Migration Time**: ~20-30 seconds (all migrations)

## 🌱 Seed Data

### Purpose
Provides realistic test data for development and testing, covering:
- 8 mock user profiles (2 families)
- 2 baby profiles with different stages
- Active and historical memberships
- Completed and pending invitations
- Calendar events (past and upcoming)
- Registry items (purchased and available)
- Photo gallery with interactions
- Gamification data (votes, name suggestions)

### Data Highlights
- ✅ Respects all FK dependencies (ordered inserts)
- ✅ Covers edge cases (expired invitations, soft deletes)
- ✅ Multiple user roles (owners, followers, family types)
- ✅ Realistic timestamps (relative to NOW())
- ✅ Active interactions (RSVPs, comments, likes)
- ✅ Statistics summary at end

### Usage
```bash
# Load seed data
supabase db push --file seed/seed_data.sql

# Verify
supabase db status
```

⚠️ **Warning**: This is for development only. Do NOT run in production.

See `seed/README.md` for detailed seed data documentation.

## ⚡ Edge Functions (Deno/TypeScript)

**Purpose**: Serverless functions for backend logic

### Available Functions

Located in `functions/` with configuration in `config.toml`

#### 1. **generate-thumbnail**
- Generates thumbnail images from uploaded photos
- Optimizes file sizes automatically
- Triggered on photo upload events
- Response time: <500ms
- Imports: image processing libraries

#### 2. **image-processing**
- Advanced image optimization
- Format conversion (WebP, JPEG, PNG)
- Metadata extraction
- Batch processing support
- Includes unit tests

#### 3. **send-invitation-email**
- Email notifications for baby profile invitations
- Template-based messages
- Async delivery queue
- Email verification links
- Resend capability

#### 4. **send-push-notification**
- Push notifications via OneSignal
- Batch sending support
- Dynamic payload formatting
- Delivery tracking
- Retry logic

#### 5. **notification-trigger**
- Real-time notification generator
- Event-driven architecture
- OneSignal integration
- Multi-user broadcasting
- Includes unit tests

#### 6. **tile-configs**
- Dynamic UI tile configuration generation
- Role-based filtering (owner vs follower views)
- Performance optimized (<100ms response)
- Cache-friendly output
- Includes unit tests

### Function Configuration

All functions configured in `config.toml`:
```toml
[functions.function-name]
enabled = true                              # Toggle function
verify_jwt = true                          # Require JWT auth
import_map = "./functions/.../deno.json"   # Dependencies
entrypoint = "./functions/.../index.ts"    # Entry file
```

### Development

```bash
# Run locally
supabase functions dev

# View logs
supabase functions logs function-name

# Deploy to production
supabase functions deploy function-name
```

## 🧪 Testing

### Database Tests

Located in `tests/rls_policies/`

**Available Tests**:
- `baby_profiles_rls_test.sql` - Baby profile access control
- `events_rls_test.sql` - Event visibility and permissions
- `photos_rls_test.sql` - Photo gallery permissions
- `profiles_rls_test.sql` - Profile visibility rules

**Run Tests**:
```bash
# Single test
psql "connection-string" -f tests/rls_policies/baby_profiles_rls_test.sql

# All tests
for test in tests/rls_policies/*.sql; do
  psql "connection-string" -f "$test"
done
```

**Test Output**:
- ✅ PASS - Policy correctly allows/blocks access
- ❌ FAIL - Unexpected behavior detected
- Tests include assertions for:
  - Owner access (full CRUD)
  - Follower access (read-only)
  - Anon access (limited)
  - Cross-baby isolation

### Function Tests

Edge functions include unit tests:
- `functions/*/index.test.ts` - Deno test suite
- Run with Deno CLI or Supabase function testing

## 🛠️ Developer Tools

Located in `tools/`

### Python Utilities

#### 1. **generate_inserts.py**
- Generates SQL INSERT statements from JSON data
- UUID conversion
- Foreign key relationship handling
- Batch insert optimization
- Usage: `python3 tools/generate_inserts.py data.json`

#### 2. **generate_auth_user_inserts.py**
- Creates auth.users insert statements
- Password hashing
- Email configuration
- Identity linking
- Usage: `python3 tools/generate_auth_user_inserts.py`

#### 3. **convert_seed_ids_to_uuid.py**
- Converts test IDs to proper UUIDs
- Maintains relationships
- Idempotent transformations
- Usage: `python3 tools/convert_seed_ids_to_uuid.py`

#### 4. **validate_seed_fk_refs.py**
- Validates all foreign key references
- Detects orphaned records
- Reports referential integrity issues
- Usage: `python3 tools/validate_seed_fk_refs.py`

### Running Tools

```bash
# Generate seed data
python3 tools/generate_inserts.py

# Validate seed integrity
python3 tools/validate_seed_fk_refs.py

# Convert IDs to UUIDs
python3 tools/convert_seed_ids_to_uuid.py

# Create auth users
python3 tools/generate_auth_user_inserts.py > auth_users.sql
```

## 📊 Monitoring

### Performance Monitoring

Located in `monitoring/queries.sql`

**Key Queries**:
```sql
-- Slow queries
SELECT * FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Index usage
SELECT * FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

-- Table sizes
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Via Supabase Dashboard

1. **Database** → **Indexes** - View index performance
2. **Database** → **Query Performance** - Real-time monitoring
3. **Logs** → **Database** - Query logs and errors
4. **Reports** → **Database** - Custom reports

## ⚡ Realtime Setup

### Tables Requiring Realtime

**High Priority** (Immediate updates):
- photos, events, event_rsvps, event_comments
- photo_comments, photo_squishes, registry_purchases
- notifications, owner_update_markers

**Medium Priority** (Enhanced UX):
- registry_items, baby_memberships, activity_events
- name_suggestion_likes

**Low Priority** (Optional):
- votes, name_suggestions

### Configuration

1. **Via SQL**:
   ```sql
   ALTER PUBLICATION supabase_realtime ADD TABLE public.photos;
   ALTER PUBLICATION supabase_realtime ADD TABLE public.events;
   -- ... (see REALTIME_CONFIGURATION.md for complete list)
   ```

2. **Via Dashboard**:
   - Navigate to: Database → Replication
   - Toggle "Enable replication" for each table

3. **Verify**:
   ```sql
   SELECT * FROM pg_publication_tables
   WHERE pubname = 'supabase_realtime';
   ```

### Performance Targets
- ✅ Update latency: < 2 seconds
- ✅ Concurrent connections: 10,000+
- ✅ RLS integrated: Yes (automatic)

Full details: See `REALTIME_CONFIGURATION.md`

## 🔒 Security Best Practices

1. **Never disable RLS** on any table
2. **Test RLS policies** with different user roles before deployment
3. **Use service_role key** only in Edge Functions, never in client apps
4. **Rotate API keys** periodically
5. **Monitor suspicious activity** via Supabase dashboard
6. **Backup before migrations** in production

### Testing RLS

```sql
-- Test as specific user
SET request.jwt.claims.sub = '11111111-1111-1111-1111-111111111111';

-- Verify what they can see
SELECT * FROM events;

-- Reset
RESET request.jwt.claims.sub;
```

## 📊 Performance Optimization

### Indexes Created
- 15 B-tree indexes for FK lookups and sorting
- 8 Partial indexes for active records (`WHERE removed_at IS NULL`)
- 2 GIN indexes for JSONB and text search
- 6 Unique indexes for business rule enforcement

### Query Optimization
- All baby-scoped queries use `baby_profile_id` index
- Time-based sorting uses `created_at DESC` indexes
- RLS helper functions use indexed membership checks
- Photo tag search uses trigram GIN index

### Performance Targets
- ✅ RLS evaluation: < 5ms
- ✅ API response time: < 500ms (P95)
- ✅ Tile load: < 100ms per tile
- ✅ Tag search: < 50ms

### Monitoring

```sql
-- View slow queries
SELECT * FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Check index usage
SELECT * FROM pg_stat_user_indexes
WHERE schemaname = 'public';
```

## 🧪 Testing

### Unit Tests
Test database functions and triggers in isolation:
```sql
-- Test profile creation
INSERT INTO auth.users (id, email)
VALUES ('test-uuid', 'test@example.com');

-- Verify profile auto-created
SELECT * FROM profiles WHERE user_id = 'test-uuid';
```

### Integration Tests
Test complete user flows with RLS:
```bash
# Use Supabase Test Helpers
supabase test db
```

### Load Tests
Simulate 10K+ concurrent users:
- Use tools like k6, Artillery, or Apache JMeter
- Target: < 500ms response time at P95
- Monitor: CPU, memory, connection pool

## 🔄 Migration Best Practices

### Before Running in Production
1. ✅ Backup database
2. ✅ Test in staging environment
3. ✅ Review migration scripts
4. ✅ Plan rollback strategy
5. ✅ Schedule during low-traffic window
6. ✅ Monitor performance post-migration

### Rollback Plan
If migration fails:
```bash
# Restore from backup
supabase db restore backup-name

# Or use Supabase dashboard: Database → Backups
```

### Version Control
- All migrations are versioned (YYYYMMDD_NNN_description.sql)
- Never modify existing migrations after deployment
- Create new migrations for schema changes

## 📖 Additional Documentation

- **Enhanced ERD**: `docs/01_discovery/05_draft_design/Enhanced_ERD.md`
- **Comparison Document**: `docs/01_discovery/05_draft_design/PDM_Enhancement_Comparison.md`
- **Original PDM**: `docs/01_discovery/05_draft_design/Physical_Data_Model.md`
- **Technical Requirements**: `docs/01_discovery/04_technical_requirements/Technical_Requirements.md`
- **Tile System Design**: `docs/01_discovery/04_technical_requirements/Tile_System_Design.md`

## 🆘 Troubleshooting

### Common Issues

**Issue**: Migration fails with "relation already exists"
```bash
# Solution: Drop and recreate (dev only!)
supabase db reset
supabase db push --include-all
```

**Issue**: RLS policies blocking valid queries
```sql
-- Solution: Check policies for specific table
SELECT * FROM pg_policies WHERE tablename = 'photos';

-- Test as user
SET request.jwt.claims.sub = 'user-uuid';
SELECT * FROM photos;
```

**Issue**: Realtime not receiving updates
```bash
# Solution: Verify replication enabled
SELECT * FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
  AND tablename = 'photos';
```

**Issue**: Slow queries
```sql
-- Solution: Check missing indexes
EXPLAIN ANALYZE
SELECT * FROM events WHERE baby_profile_id = 'uuid';

-- Create index if needed
CREATE INDEX IF NOT EXISTS idx_name
ON table_name (column_name);
```

## 🤝 Contributing

When adding new features:
1. Create new migration file with next sequence number
2. Add RLS policies for new tables
3. Add appropriate indexes
4. Update seed data if needed
5. Document changes in comparison doc
6. Test with different user roles

## 📞 Support

For issues or questions:
- Review documentation in `docs/01_discovery/`
- Check Supabase logs in dashboard
- Consult Supabase community forums
- Review PostgreSQL documentation for advanced features

## ✅ Deployment Checklist

Before deploying to production:

- [ ] All migration scripts reviewed and tested in staging
- [ ] RLS policies tested with multiple user roles
- [ ] Performance benchmarks meet targets (< 500ms API, < 2s realtime)
- [ ] Seed data NOT loaded in production
- [ ] Realtime configured for required tables
- [ ] Backup strategy in place
- [ ] Monitoring alerts configured
- [ ] Rollback plan documented
- [ ] Team trained on new schema
- [ ] Documentation updated

---

**Version**: 1.0.0
**Last Updated**: March 2, 2026
**Maintainer**: Nonna App Development Team

---

## 🔗 Related Development Tools

**Database Query & Statistics Tools** (in `../scripts/`):
- `database_stats.py` - Get comprehensive database statistics and schema overview
- `database_query.py` - Execute custom queries from JSON configuration files
- `sample_queries.json` - Pre-configured example queries
- See [DATABASE_QUERY_README.md](../scripts/DATABASE_QUERY_README.md) for details

These tools complement the Supabase setup and are useful for:
- ✅ Database inspection during development
- ✅ Custom reporting and analysis
- ✅ Testing database connectivity
- ✅ Monitoring table statistics
