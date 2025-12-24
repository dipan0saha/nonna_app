# Nonna App - Supabase Database Setup

This directory contains all database-related files for the Nonna App, including migration scripts, RLS policies, triggers, and seed data.

## 📁 Directory Structure

```
supabase/
├── migrations/          # Sequential database migration scripts
│   ├── 20251224_001_create_schema.sql           # Tables, indexes, constraints
│   ├── 20251224_002_row_level_security.sql      # RLS policies & permissions
│   └── 20251224_003_triggers_functions.sql      # Automation & triggers
├── seed/                # Test data for development
│   └── seed_data.sql                             # Sample data with edge cases
├── REALTIME_CONFIGURATION.md                     # Realtime setup guide
└── README.md                                     # This file
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
   # Schema creation
   supabase db push --file migrations/20251224_001_create_schema.sql
   
   # RLS policies
   supabase db push --file migrations/20251224_002_row_level_security.sql
   
   # Triggers and functions
   supabase db push --file migrations/20251224_003_triggers_functions.sql
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

### 1. Schema Creation (`20251224_001_create_schema.sql`)

**Purpose**: Creates all tables, indexes, and constraints

**Contains**:
- ✅ 23 application tables (public schema)
- ✅ UUID generation with `gen_random_uuid()`
- ✅ Auth schema integration with CASCADE deletes
- ✅ Supabase-optimized data types (UUID, JSONB, TIMESTAMPTZ)
- ✅ 20+ performance indexes (B-tree, GIN, partial)
- ✅ 8 unique constraints for business rules
- ✅ Audit fields (id, created_at, updated_at) on all tables
- ✅ CHECK constraints for enums (role, gender, status)

**Key Tables**:
- User Identity: `profiles`, `user_stats`
- Baby Profiles: `baby_profiles`, `baby_memberships`, `invitations`
- Tile System: `screens`, `tile_definitions`, `tile_configs`
- Content: `events`, `photos`, `registry_items`
- Interactions: `event_rsvps`, `photo_squishes`, comments, likes
- Gamification: `votes`, `name_suggestions`
- Notifications: `notifications`, `activity_events`

**Extensions Required**:
- `uuid-ossp` - UUID generation
- `pg_stat_statements` - Performance monitoring
- `pg_trgm` - Text search (photo tags)
- `btree_gin` - Multi-column indexes

**Run time**: ~5-10 seconds

### 2. Row Level Security (`20251224_002_row_level_security.sql`)

**Purpose**: Implements comprehensive RLS policies for data security

**Contains**:
- ✅ RLS enabled on all 23 tables
- ✅ 80+ granular RLS policies
- ✅ Helper functions: `is_baby_member()`, `is_baby_owner()`
- ✅ Role-based access (authenticated, anon, service_role)
- ✅ Owner moderation capabilities
- ✅ Follower interaction permissions

**Security Model**:
- Members can view content for babies they follow
- Owners have full CRUD on their baby's content
- Followers can interact (RSVP, comment, like, vote)
- Owners can moderate (delete any comment)
- Users always control their own interactions

**GRANT Statements**:
- `authenticated` - SELECT on all tables (RLS handles row access)
- `anon` - Limited to invitation acceptance flow
- `service_role` - Full access for admin operations

**Run time**: ~10-15 seconds

### 3. Triggers & Functions (`20251224_003_triggers_functions.sql`)

**Purpose**: Automates common database operations

**Contains**:
- ✅ 25+ triggers for automation
- ✅ 10+ database functions
- ✅ Profile auto-creation on user signup
- ✅ Auto-update timestamps on all changes
- ✅ Cache invalidation (owner_update_markers)
- ✅ Gamification stats auto-increment
- ✅ Activity event logging
- ✅ In-app notification creation
- ✅ Business rule enforcement (max 2 owners, invitation expiry)

**Key Triggers**:
```sql
-- Auto-create profile when user signs up
on_auth_user_created → handle_new_user()

-- Update timestamps on any row change
set_updated_at_* → update_updated_at_column()

-- Invalidate follower cache on content changes
update_marker_on_* → update_owner_marker()

-- Increment gamification counters
on_photo_squish → increment_photos_squished()

-- Log significant actions
log_photo_activity → log_activity_event()

-- Create notifications for members
notify_on_photo_upload → create_content_notifications()

-- Enforce business rules
enforce_max_owners → check_max_owners()
```

**Run time**: ~5-10 seconds

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
**Last Updated**: December 24, 2025  
**Maintainer**: Nonna App Development Team
