## Reset database by dropping and recreating the public schema
DROP SCHEMA public CASCADE;
CREATE SCHEMA public AUTHORIZATION CURRENT_USER;
GRANT ALL ON SCHEMA public TO CURRENT_USER;
GRANT ALL ON SCHEMA public TO public;

TRUNCATE TABLE auth.users CASCADE;
TRUNCATE TABLE auth.identities CASCADE;

## Add authenticated users
Execute supabase/auth_users_seed.sql

## Ideal scenario
### from repo root
supabase login
supabase link --project-ref ubptybhhrgdiyfkcqgwu

### See the current migration status
supabase migrations list

### mark each displayed version as reverted
supabase migration repair --status reverted 202512240001
supabase migration repair --status reverted 202512240002
supabase migration repair --status reverted 202512240003

### Push the local migrations and seed data to the database
supabase db push --include-seed
