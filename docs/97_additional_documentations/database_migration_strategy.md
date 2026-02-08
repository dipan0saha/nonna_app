# Database Migration Strategy

**Document Version**: 1.0  
**Created**: February 3, 2026  
**Purpose**: Define database migration workflow, rollback procedures, and best practices

---

## Overview

This document outlines the strategy for managing database schema changes in the Nonna app using Supabase migrations. It covers migration creation, testing, deployment, and rollback procedures to ensure safe and reliable database evolution.

---

## Migration Workflow

### 1. Migration Creation

#### Naming Convention
```
YYYYMMDDHHMMSS_description.sql
```

Example:
```
20260203120000_add_app_versions_table.sql
```

#### Migration Structure
Each migration file should:
- Be idempotent (use `IF NOT EXISTS`, `IF EXISTS`)
- Include descriptive comments
- Define rollback procedures
- Follow a logical order:
  1. Extensions
  2. Tables
  3. Indexes
  4. RLS policies
  5. Triggers
  6. Functions
  7. Initial data

#### Template
```sql
-- ========================================
-- [Migration Title]
-- ========================================
-- Purpose: [Describe the purpose]
-- Date: YYYY-MM-DD

-- Tables
CREATE TABLE IF NOT EXISTS public.table_name (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_table_name_field 
  ON public.table_name(field);

-- Enable RLS
ALTER TABLE public.table_name ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "policy_name"
  ON public.table_name
  FOR SELECT
  TO authenticated
  USING (true);

-- Triggers
CREATE OR REPLACE FUNCTION update_table_name_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER table_name_updated_at
  BEFORE UPDATE ON public.table_name
  FOR EACH ROW
  EXECUTE FUNCTION update_table_name_updated_at();

-- Comments
COMMENT ON TABLE public.table_name IS 'Description';
```

### 2. Local Testing

Before applying migrations to staging/production:

1. **Test in Local Supabase Instance**
   ```bash
   supabase start
   supabase migration up
   ```

2. **Verify Schema Changes**
   ```bash
   supabase db dump --schema-only
   ```

3. **Test RLS Policies**
   - Run pgTAP tests
   - Test with different user roles
   - Verify access controls

4. **Test Application Integration**
   - Run Dart integration tests
   - Verify data access patterns
   - Check performance

### 3. Migration Deployment

#### Development Environment
```bash
# Apply all pending migrations
supabase db push

# Or apply specific migration
supabase migration up --to 20260203120000
```

#### Staging Environment
1. Create backup before migration
2. Apply migrations
3. Run smoke tests
4. Verify application functionality

#### Production Environment
1. **Pre-Deployment Checklist**
   - [ ] All tests pass in staging
   - [ ] Rollback plan documented
   - [ ] Team notified of deployment window
   - [ ] Database backup completed
   - [ ] Maintenance mode enabled (if needed)

2. **Deployment Steps**
   ```bash
   # 1. Backup database
   supabase db dump -f backup_$(date +%Y%m%d_%H%M%S).sql
   
   # 2. Apply migrations
   supabase db push
   
   # 3. Verify migration
   supabase migration list
   
   # 4. Run post-migration tests
   ```

3. **Post-Deployment**
   - Monitor error logs
   - Check application metrics
   - Verify user functionality
   - Document any issues

---

## Rollback Procedures

### Automatic Rollback

For simple migrations, create a rollback migration:

```sql
-- 20260203120001_rollback_app_versions.sql
DROP TABLE IF EXISTS public.app_versions CASCADE;
```

### Manual Rollback

1. **Restore from Backup**
   ```bash
   supabase db restore backup_20260203_120000.sql
   ```

2. **Selective Rollback**
   - Identify problematic migration
   - Create compensating migration
   - Test thoroughly before applying

### Emergency Rollback

If production is impacted:

1. Enable maintenance mode
2. Restore from last known good backup
3. Investigate root cause
4. Create fix migration
5. Test in staging
6. Re-deploy with fix

---

## Version Control Practices

### Git Workflow

1. **Feature Branch**
   ```bash
   git checkout -b feature/add-app-versions-table
   ```

2. **Create Migration**
   ```bash
   supabase migration new add_app_versions_table
   ```

3. **Commit with Description**
   ```bash
   git add supabase/migrations/20260203120000_add_app_versions_table.sql
   git commit -m "feat: add app_versions table for force update"
   ```

4. **Pull Request**
   - Include migration description
   - Document breaking changes
   - Add testing instructions

### Migration Review Checklist

- [ ] Idempotent operations (IF EXISTS/IF NOT EXISTS)
- [ ] RLS policies defined
- [ ] Indexes for query optimization
- [ ] Foreign key constraints
- [ ] Default values specified
- [ ] NOT NULL constraints where appropriate
- [ ] Triggers for updated_at
- [ ] Comments for documentation
- [ ] Rollback plan documented

---

## Testing Protocols

### Unit Testing (pgTAP)

```sql
-- Test table exists
SELECT has_table('public', 'app_versions', 'app_versions table should exist');

-- Test columns
SELECT has_column('public', 'app_versions', 'platform', 'platform column should exist');

-- Test RLS
SELECT policies_are('public', 'app_versions', 
  ARRAY['Allow authenticated users to read app versions']);
```

### Integration Testing (Dart)

```dart
test('app_versions table accessible', () async {
  final response = await supabase
    .from('app_versions')
    .select()
    .eq('platform', 'android')
    .single();
  
  expect(response, isNotEmpty);
});
```

### Performance Testing

Monitor:
- Query execution time
- Index usage
- Table scan frequency
- Lock contention

---

## Production Deployment Checklist

### Pre-Deployment

- [ ] All migrations tested in local environment
- [ ] All migrations tested in staging environment
- [ ] pgTAP tests pass
- [ ] Integration tests pass
- [ ] Performance benchmarks acceptable
- [ ] Rollback procedure documented
- [ ] Database backup completed
- [ ] Team notified of deployment window
- [ ] Monitoring alerts configured

### During Deployment

- [ ] Maintenance mode enabled (if breaking changes)
- [ ] Migrations applied successfully
- [ ] Post-migration tests executed
- [ ] Application connectivity verified
- [ ] User-facing functionality tested

### Post-Deployment

- [ ] Monitor error logs for 24 hours
- [ ] Check performance metrics
- [ ] Verify RLS policies working correctly
- [ ] Document any issues or learnings
- [ ] Disable maintenance mode

---

## Common Migration Patterns

### Adding a Column

```sql
ALTER TABLE public.table_name
ADD COLUMN IF NOT EXISTS new_column TEXT;
```

### Modifying a Column

```sql
-- Add new column
ALTER TABLE public.table_name
ADD COLUMN new_column_v2 TEXT;

-- Copy data
UPDATE public.table_name
SET new_column_v2 = new_column;

-- Drop old column (in separate migration after verification)
ALTER TABLE public.table_name
DROP COLUMN IF EXISTS new_column;
```

### Creating Indexes

```sql
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_table_column
ON public.table_name(column)
WHERE condition;
```

### Adding RLS Policy

```sql
CREATE POLICY "policy_name"
ON public.table_name
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);
```

---

## Troubleshooting

### Migration Fails to Apply

1. Check migration syntax
2. Verify dependencies exist
3. Check for conflicting constraints
4. Review error logs
5. Test in isolation

### RLS Policy Issues

1. Verify policy logic
2. Test with different users
3. Check policy order
4. Review auth context

### Performance Degradation

1. Check for missing indexes
2. Analyze query plans
3. Monitor lock contention
4. Review trigger efficiency

---

## Best Practices

1. **Keep Migrations Small**: One logical change per migration
2. **Test Thoroughly**: Test in local and staging before production
3. **Document Changes**: Include comments and migration descriptions
4. **Version Control**: Always commit migrations with descriptive messages
5. **Backup First**: Always backup before production migrations
6. **Monitor After**: Watch logs and metrics after deployment
7. **Plan Rollback**: Document rollback procedure before deployment
8. **Communicate**: Notify team of breaking changes
9. **Use Transactions**: Wrap multiple operations in transactions when possible
10. **Review Together**: Have migrations peer-reviewed

---

## Tools and Resources

### Supabase CLI Commands

```bash
# List migrations
supabase migration list

# Create new migration
supabase migration new migration_name

# Apply migrations
supabase db push

# Reset database (WARNING: destructive)
supabase db reset

# Dump schema
supabase db dump --schema-only

# Diff schemas
supabase db diff
```

### Useful SQL Queries

```sql
-- List all tables
SELECT * FROM information_schema.tables WHERE table_schema = 'public';

-- List all indexes
SELECT * FROM pg_indexes WHERE schemaname = 'public';

-- List all RLS policies
SELECT * FROM pg_policies WHERE schemaname = 'public';

-- Check table sizes
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## Contact and Support

For questions about database migrations:
- Technical Lead: [Contact Info]
- DBA Team: [Contact Info]
- Supabase Docs: https://supabase.com/docs/guides/database

---

**Document Maintainer**: Technical Lead  
**Last Updated**: February 3, 2026  
**Next Review**: March 3, 2026
