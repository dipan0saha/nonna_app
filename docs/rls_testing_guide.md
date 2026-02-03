# RLS Testing Guide

**Document Version**: 1.0  
**Created**: February 3, 2026  
**Purpose**: Guide for testing Row Level Security (RLS) policies using pgTAP

---

## Overview

This guide provides a comprehensive approach to testing Row Level Security (RLS) policies in the Nonna app's Supabase database. It covers test methodology, execution, and troubleshooting.

---

## What is RLS?

Row Level Security (RLS) is a PostgreSQL feature that allows you to restrict which rows a user can access in a table. In Supabase, RLS policies enforce data access rules based on user authentication and custom logic.

### Why Test RLS?

- **Security**: Ensure users can only access data they're authorized to see
- **Privacy**: Protect user data from unauthorized access
- **Compliance**: Meet GDPR and data protection requirements
- **Confidence**: Deploy with assurance that access controls work correctly

---

## Testing Framework: pgTAP

[pgTAP](https://pgtap.org/) is a unit testing framework for PostgreSQL. It provides functions to test database objects, including RLS policies.

### Installing pgTAP

pgTAP should be installed in your Supabase instance:

```sql
CREATE EXTENSION IF NOT EXISTS pgtap;
```

---

## RLS Test Structure

### Directory Organization

```
supabase/tests/rls_policies/
├── profiles_rls_test.sql           # User profile tests (structure tests only)
├── baby_profiles_rls_test.sql      # Baby profile tests (structure tests only)
├── events_rls_test.sql             # Event tests (structure tests only)
├── photos_rls_test.sql             # Photo tests (structure tests only)
└── [additional test files to be added as coverage expands]
```

### Test File Template

```sql
-- ========================================
-- RLS Policy Tests for [table_name]
-- ========================================

BEGIN;

-- Define number of tests
SELECT plan(10);

-- Test 1: Table exists
SELECT has_table('public'::name, 'table_name'::name, 
  'table_name table should exist');

-- Test 2: RLS is enabled
SELECT rls_enabled('public'::name, 'table_name'::name, 
  'RLS should be enabled on table_name');

-- Test 3: Check columns
SELECT has_column('public'::name, 'table_name'::name, 
  'column_name'::name, 'table should have column');

-- Test 4-10: Access control tests
-- ... specific policy tests ...

-- Finish
SELECT * FROM finish();

ROLLBACK;
```

---

## Test Execution

### Running All Tests

```bash
# In Supabase CLI
supabase test db

# Or with psql
psql -U postgres -d postgres -f supabase/tests/rls_policies/profiles_rls_test.sql
```

### Running Specific Test File

```bash
supabase test db --file supabase/tests/rls_policies/profiles_rls_test.sql
```

### Running Tests in CI/CD

Add to your GitHub Actions workflow:

```yaml
- name: Run RLS Tests
  run: |
    supabase start
    supabase test db
```

---

## Test Case Templates

### 1. Owner Access Test

```sql
-- Test: Owner can read their own data
PREPARE owner_read AS
  SELECT * FROM public.baby_profiles
  WHERE id = $1;

-- Set auth context for owner
SET LOCAL role = authenticated;
SET LOCAL request.jwt.claim.sub = 'owner-user-id';

-- Execute and verify
SELECT results_eq(
  'EXECUTE owner_read(''baby-profile-id'')',
  $$VALUES ('baby-profile-id', 'Baby Name', ...)$$,
  'Owner should be able to read their baby profile'
);
```

### 2. Follower Access Test

```sql
-- Test: Follower can read baby profile they follow
SET LOCAL request.jwt.claim.sub = 'follower-user-id';

SELECT results_eq(
  'SELECT id FROM public.baby_profiles WHERE id = ''baby-id''',
  $$VALUES ('baby-id')$$,
  'Follower should be able to read baby profile they follow'
);
```

### 3. Cross-Baby Isolation Test

```sql
-- Test: User cannot access baby profiles they don't belong to
SET LOCAL request.jwt.claim.sub = 'user-id';

SELECT is_empty(
  'SELECT * FROM public.baby_profiles WHERE id = ''other-baby-id''',
  'User should not see baby profiles they are not a member of'
);
```

### 4. Permission Boundary Test

```sql
-- Test: Follower cannot update baby profile (owner-only action)
SET LOCAL request.jwt.claim.sub = 'follower-user-id';

PREPARE follower_update AS
  UPDATE public.baby_profiles
  SET name = 'New Name'
  WHERE id = $1;

-- Should fail due to RLS policy
SELECT throws_ok(
  'EXECUTE follower_update(''baby-id'')',
  'Follower should not be able to update baby profile'
);
```

---

## RLS Policy Coverage Matrix

Track which policies are tested. This matrix reflects the current implementation status.
Note: Currently only 4 tables have initial structure tests (schema validation).
Full auth-based CRUD assertions are planned for future implementation.

| Table | SELECT (Read) | INSERT (Create) | UPDATE (Modify) | DELETE (Remove) | Coverage |
|-------|--------------|-----------------|-----------------|-----------------|----------|
| profiles | ⚠️ Structure | ⚠️ Planned | ⚠️ Planned | ⚠️ Planned | Structure Only |
| baby_profiles | ⚠️ Structure | ⚠️ Planned | ⚠️ Planned | ⚠️ Planned | Structure Only |
| events | ⚠️ Structure | ⚠️ Planned | ⚠️ Planned | ⚠️ Planned | Structure Only |
| photos | ⚠️ Structure | ⚠️ Planned | ⚠️ Planned | ⚠️ Planned | Structure Only |
| ... | ❌ Not tested | ❌ Not tested | ❌ Not tested | ❌ Not tested | Not Yet Implemented |

---

## Common pgTAP Functions

### Table Tests
```sql
has_table(schema, table, description)
hasnt_table(schema, table, description)
has_column(schema, table, column, description)
col_type_is(schema, table, column, type, description)
```

### RLS Tests
```sql
rls_enabled(schema, table, description)
policy_cmd_is(schema, table, policy, command, description)
policy_roles_are(schema, table, policy, roles, description)
```

### Result Tests
```sql
results_eq(query, expected, description)
is_empty(query, description)
row_eq(query, expected, description)
```

### Error Tests
```sql
throws_ok(query, description)
lives_ok(query, description)
```

---

## Setting Auth Context for Tests

To test RLS policies properly, you need to set the authentication context:

```sql
-- Set role to authenticated user
SET LOCAL role = authenticated;

-- Set user ID
SET LOCAL request.jwt.claim.sub = 'user-uuid-here';

-- Set custom claims (if needed)
SET LOCAL request.jwt.claim.role = 'owner';
```

### Example: Full Auth Context Test

```sql
BEGIN;

-- Create test data
INSERT INTO auth.users (id, email) VALUES 
  ('owner-id', 'owner@test.com'),
  ('follower-id', 'follower@test.com');

INSERT INTO public.baby_profiles (id, name) VALUES
  ('baby-id', 'Test Baby');

INSERT INTO public.baby_memberships (baby_profile_id, user_id, role) VALUES
  ('baby-id', 'owner-id', 'owner'),
  ('baby-id', 'follower-id', 'follower');

-- Test as owner
SET LOCAL role = authenticated;
SET LOCAL request.jwt.claim.sub = 'owner-id';

SELECT ok(
  (SELECT COUNT(*) FROM public.baby_profiles WHERE id = 'baby-id') = 1,
  'Owner can see baby profile'
);

-- Test as follower
SET LOCAL request.jwt.claim.sub = 'follower-id';

SELECT ok(
  (SELECT COUNT(*) FROM public.baby_profiles WHERE id = 'baby-id') = 1,
  'Follower can see baby profile'
);

-- Test as non-member
SET LOCAL request.jwt.claim.sub = 'non-member-id';

SELECT ok(
  (SELECT COUNT(*) FROM public.baby_profiles WHERE id = 'baby-id') = 0,
  'Non-member cannot see baby profile'
);

ROLLBACK;
```

---

## Edge Cases to Test

### 1. Soft Deleted Records
```sql
-- Test that soft-deleted records are not visible
SELECT is_empty(
  $$SELECT * FROM public.photos 
    WHERE deleted_at IS NOT NULL$$,
  'Soft deleted photos should not be visible'
);
```

### 2. Expired Tokens/Sessions
```sql
-- Test that expired invitations are not accessible
SELECT is_empty(
  $$SELECT * FROM public.invitations 
    WHERE expires_at < NOW()$$,
  'Expired invitations should not be visible'
);
```

### 3. Removed Memberships
```sql
-- Test that removed members cannot access data
SELECT is_empty(
  $$SELECT * FROM public.baby_profiles bp
    JOIN public.baby_memberships bm ON bp.id = bm.baby_profile_id
    WHERE bm.removed_at IS NOT NULL$$,
  'Removed members should not see baby profiles'
);
```

### 4. Anonymous Access
```sql
-- Test that anonymous users cannot access data
SET LOCAL role = anon;

SELECT is_empty(
  'SELECT * FROM public.profiles',
  'Anonymous users should not see profiles'
);
```

---

## Troubleshooting

### Test Fails: "Policy not found"

**Problem**: RLS policy doesn't exist
**Solution**: Ensure migration with RLS policies has been applied

```bash
supabase db push
```

### Test Fails: "RLS not enabled"

**Problem**: RLS is not enabled on the table
**Solution**: Add to migration:

```sql
ALTER TABLE public.table_name ENABLE ROW LEVEL SECURITY;
```

### Test Passes But App Fails

**Problem**: Test doesn't match real-world scenario
**Solution**: 
1. Review auth context in tests
2. Check JWT claims used in app vs tests
3. Verify helper functions used in policies

### Can't Set Auth Context

**Problem**: Missing permissions or extensions
**Solution**:

```sql
-- Ensure pgTAP is installed
CREATE EXTENSION IF NOT EXISTS pgtap;

-- Grant permissions
GRANT USAGE ON SCHEMA auth TO authenticated;
```

---

## Best Practices

1. **Test All CRUD Operations**: Test SELECT, INSERT, UPDATE, DELETE for each table
2. **Test All Roles**: Test owner, follower, non-member, anonymous
3. **Test Edge Cases**: Soft deletes, expired data, removed memberships
4. **Use Transactions**: Wrap tests in BEGIN/ROLLBACK for isolation
5. **Clear Test Data**: Don't rely on existing data; create test fixtures
6. **Descriptive Messages**: Use clear test descriptions
7. **Keep Tests Simple**: One concept per test
8. **Run Regularly**: Include in CI/CD pipeline
9. **Document Policies**: Comment complex policy logic
10. **Version Control**: Track test files alongside migrations

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: RLS Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Supabase
        uses: supabase/setup-cli@v1
        
      - name: Start Supabase
        run: supabase start
        
      - name: Run RLS Tests
        run: supabase test db
        
      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: rls-test-results
          path: test-results/
```

---

## Performance Considerations

### Policy Performance

Monitor slow policies:

```sql
-- Check policy execution time
EXPLAIN ANALYZE
SELECT * FROM public.photos
WHERE baby_profile_id = 'some-id';
```

### Optimization Tips

1. **Add Indexes**: Index columns used in RLS policies
2. **Simplify Policies**: Avoid complex subqueries
3. **Use Security Definer Functions**: For complex logic
4. **Cache Results**: Use temporary tables for repeated checks

---

## Resources

- [pgTAP Documentation](https://pgtap.org/)
- [PostgreSQL RLS Documentation](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Supabase RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase pgTAP Guide](https://supabase.com/docs/guides/database/testing)

---

## Contact and Support

For questions about RLS testing:
- Security Team: [Contact Info]
- Database Team: [Contact Info]
- Slack Channel: #database-security

---

**Document Maintainer**: Technical Lead  
**Last Updated**: February 3, 2026  
**Next Review**: March 3, 2026
