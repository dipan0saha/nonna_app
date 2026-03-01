# Nonna App — Test Data Setup Guide

**Version**: 1.0.0  
**Last Updated**: March 2026

This guide walks you through loading comprehensive test data into a Supabase database (local or remote) so that every feature of nonna_app can be exercised end-to-end.

---

## Table of Contents

1. [What the Test Data Covers](#1-what-the-test-data-covers)
2. [Data Structure at a Glance](#2-data-structure-at-a-glance)
3. [Method A — Local Supabase (Recommended for Development)](#3-method-a--local-supabase-recommended-for-development)
4. [Method B — Remote Supabase via SQL Editor](#4-method-b--remote-supabase-via-sql-editor)
5. [Method C — Remote Supabase via Python Script](#5-method-c--remote-supabase-via-python-script)
6. [Test User Credentials](#6-test-user-credentials)
7. [Data Coverage Map](#7-data-coverage-map)
8. [Verification Queries](#8-verification-queries)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. What the Test Data Covers

| Domain | Records | Purpose |
|---|---|---|
| Auth users (auth.users + identities) | 150 | Log in as owner or follower |
| User profiles | 150 | Profile screen, avatars |
| User stats | 150 | Gamification counters |
| Baby profiles | 10 | Core entity (one per family) |
| Baby memberships | 150 | Owner (20) + Follower (130) relationships |
| Screens & tile configs | Full set | Tile layout for every screen |
| Calendar events | 6 | Upcoming / past events |
| Event RSVPs | 8 | Yes / No / Maybe responses |
| Event comments | 5 | Comment threads |
| Photos | 8 | Ultrasound, nursery, bump photos |
| Photo squishes (likes) | 8 | Engagement data |
| Photo comments | 5 | Comment threads on photos |
| Photo tags | 9 | Searchable tag index |
| Registry items | 9 | Cribs, strollers, monitors … |
| Registry purchases | 4 | Items marked as purchased |
| Votes | 8 | Gender & birth-date predictions |
| Name suggestions | 8 | Suggested baby names |
| Name suggestion likes | 7 | Votes on favourite names |
| Invitations | 5 | Pending, accepted, expired, revoked |
| Notifications | 8 | In-app notification inbox |
| Activity events | 17 | Recent activity feed |
| Owner update markers | 10 | Cache-invalidation records |

---

## 2. Data Structure at a Glance

```
10 Baby families (Johnson, Davis, Smith, Brown, Wilson, Martinez, Garcia, Lee, Anderson, Taylor)
│
├── Each baby has:
│   ├── 2 Owners   (Mother = 1000000N-... · Father = 2000000N-...)
│   └── 13 Followers (40000000-... through 40000???-...)
│
├── Content per baby:
│   ├── Photos, Events, Registry items
│   ├── Votes (gender + birth-date predictions)
│   └── Name suggestions
│
└── Cross-baby relationships:
    └── Some followers follow multiple babies
```

> **Note**: Owners from one family may also appear as followers in another family's profile,
> creating realistic multi-baby scenarios for testing.

---

## 3. Method A — Local Supabase (Recommended for Development)

This is the easiest method. The Supabase CLI applies all migrations and the seed file in a single command.

### Prerequisites

- Docker Desktop running
- Supabase CLI installed (`brew install supabase/tap/supabase` or `npm i -g supabase`)

### Steps

#### Step 1 — Install and verify tools

```bash
docker --version          # must be running
supabase --version        # 1.x or higher
```

#### Step 2 — Start local Supabase

From the project root:

```bash
supabase start
```

This downloads Docker images (first run takes a few minutes) and starts:

| Service | URL |
|---|---|
| API / PostgREST | `http://localhost:54321` |
| Studio dashboard | `http://localhost:54323` |
| Database (PostgreSQL) | `postgresql://postgres:postgres@localhost:54322/postgres` |
| Inbucket (email testing) | `http://localhost:54324` |

#### Step 3 — Apply schema + seed data

```bash
supabase db reset
```

This single command:
1. Runs all migrations in `supabase/migrations/` (creates schema, enables RLS, creates indexes, functions and triggers)
2. Runs `supabase/seed.sql` which creates **all 150 auth users** and **all application data**

> ⚠️ `db reset` drops and recreates the database. Any local data will be lost.

#### Step 4 — Retrieve connection details

```bash
supabase status
```

Note the `anon key` and `service_role key` — you will need them in `.env`.

#### Step 5 — Connect the app

Copy the example env file and fill in the local values:

```bash
cp .env.example .env
```

Then update `.env`:

```
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=<anon key from supabase status>
```

#### Step 6 — Verify

```bash
psql "postgresql://postgres:postgres@localhost:54322/postgres" \
     -f supabase/seed/validate_seed_data.sql
```

Expected result: every table shows `✓ Has data`.

---

## 4. Method B — Remote Supabase via SQL Editor

Use this method when seeding a shared dev/staging Supabase project.

### Prerequisites

- Access to Supabase project dashboard
- **Service role** SQL access (execute the scripts as service role, not anon)

### Steps

#### Step 1 — Open the SQL Editor

In the Supabase dashboard go to **SQL Editor** → **New query**.

Make sure the session is running as `service_role`. You can verify with:

```sql
SELECT current_setting('request.jwt.claims', true)::json->>'role';
```

If this returns `null` or `anon`, you are in the wrong context. Use the service role key in the Supabase CLI `db push` approach below, or tick "Run as service_role" in Studio.

#### Step 2 — Set up the database schema

> Skip this step if the schema already exists (check with `SELECT tablename FROM pg_tables WHERE schemaname='public'`).

Paste the entire contents of `supabase/seed/manual_db_and_seed_creation.sql` into the SQL Editor and click **Run**.

This script:
- Drops and recreates the `public` schema (⚠️ **destructive**)
- Creates all tables, indexes, RLS policies, triggers, and functions
- Sets up storage buckets

> **Alternative**: If your project already has migrations applied (via `supabase db push`), skip this step entirely.

#### Step 3 — Load auth users and seed data

Paste the entire contents of `supabase/seed.sql` into the SQL Editor and click **Run**.

This single file:
1. Truncates all existing test data (safe to re-run)
2. Creates **150 auth.users** with encrypted passwords
3. Creates corresponding **auth.identities** entries (enables email/password login)
4. Inserts all application data

> **Why seed.sql and not seed/seed_data.sql?**  
> `supabase/seed.sql` (root-level) is the complete file that includes auth user creation.  
> `supabase/seed/seed_data.sql` contains only the application data and must be preceded by auth user creation.

#### Step 4 — Alternative: using psql

If you have direct PostgreSQL access (available under **Project Settings → Database → Connection string**):

```bash
# Schema setup (if needed)
psql "postgresql://postgres:<password>@db.<project-ref>.supabase.co:5432/postgres" \
     -f supabase/seed/manual_db_and_seed_creation.sql

# Full seed (auth users + data)
psql "postgresql://postgres:<password>@db.<project-ref>.supabase.co:5432/postgres" \
     -f supabase/seed.sql
```

#### Step 5 — Verify

Run the validation script in SQL Editor:

```sql
-- Paste contents of supabase/seed/validate_seed_data.sql
```

Or use the quick check:

```sql
SELECT
  (SELECT COUNT(*) FROM public.profiles)         AS profiles,
  (SELECT COUNT(*) FROM public.baby_profiles)     AS babies,
  (SELECT COUNT(*) FROM auth.users)               AS auth_users,
  (SELECT COUNT(*) FROM public.baby_memberships WHERE role = 'owner')    AS owners,
  (SELECT COUNT(*) FROM public.baby_memberships WHERE role = 'follower') AS followers;
```

Expected: `profiles=150, babies=10, auth_users=150, owners=20, followers=130`.

---

## 5. Method C — Remote Supabase via Python Script

Use this method when you need to create auth users programmatically through the **Supabase Admin API** (no direct PostgreSQL access required).

### Prerequisites

```bash
pip install requests
```

### Steps

#### Step 1 — Set environment variables

```bash
export SUPABASE_URL="https://<your-project-ref>.supabase.co"
export SUPABASE_SERVICE_KEY="<your-service-role-key>"
```

> Find these in your Supabase dashboard under **Project Settings → API**.

#### Step 2 — Run schema setup

Apply the schema via SQL Editor or psql (see Step 2 of Method B above).

#### Step 3 — Run the Python script

```bash
python scripts/create_test_users.py
```

The script creates all 150 test auth users with fixed UUIDs and `password123` via the Admin API.

#### Step 4 — Load application data via SQL Editor

After users are created, load the application data:

```sql
-- Run in SQL Editor (paste supabase/seed/seed_data.sql)
```

#### Step 5 — Verify

```sql
SELECT COUNT(*) FROM auth.users;    -- Expected: 150
SELECT COUNT(*) FROM public.profiles; -- Expected: 150
```

---

## 6. Test User Credentials

All test users share the same password: **`password123`**

### Owner Accounts (can create and manage baby profiles)

| Display Name | Email | Baby Family | Role |
|---|---|---|---|
| Sarah Johnson | `seed+10000000@example.local` | Johnson (Baby 0) | Mother / Owner |
| Michael Johnson | `seed+20000000@example.local` | Johnson (Baby 0) | Father / Owner |
| Emily Davis | `seed+10000001@example.local` | Davis (Baby 1) | Mother / Owner |
| John Davis | `seed+20000001@example.local` | Davis (Baby 1) | Father / Owner |
| Jennifer Smith | `seed+10000002@example.local` | Smith (Baby 2) | Mother / Owner |
| David Smith | `seed+20000002@example.local` | Smith (Baby 2) | Father / Owner |
| Jessica Brown | `seed+10000003@example.local` | Brown (Baby 3) | Mother / Owner |
| Robert Brown | `seed+20000003@example.local` | Brown (Baby 3) | Father / Owner |
| Amanda Wilson | `seed+10000004@example.local` | Wilson (Baby 4) | Mother / Owner |
| James Wilson | `seed+20000004@example.local` | Wilson (Baby 4) | Father / Owner |
| Maria Martinez | `seed+10000005@example.local` | Martinez (Baby 5) | Mother / Owner |
| Carlos Martinez | `seed+20000005@example.local` | Martinez (Baby 5) | Father / Owner |
| Sofia Garcia | `seed+10000006@example.local` | Garcia (Baby 6) | Mother / Owner |
| Miguel Garcia | `seed+20000006@example.local` | Garcia (Baby 6) | Father / Owner |
| Michelle Lee | `seed+10000007@example.local` | Lee (Baby 7) | Mother / Owner |
| Kevin Lee | `seed+20000007@example.local` | Lee (Baby 7) | Father / Owner |
| Rachel Anderson | `seed+10000008@example.local` | Anderson (Baby 8) | Mother / Owner |
| Christopher Anderson | `seed+20000008@example.local` | Anderson (Baby 8) | Father / Owner |
| Lauren Taylor | `seed+10000009@example.local` | Taylor (Baby 9) | Mother / Owner |
| Daniel Taylor | `seed+20000009@example.local` | Taylor (Baby 9) | Father / Owner |

### Follower Accounts (can view and interact, but not manage)

Follower emails follow the pattern `seed+40000000@example.local` through `seed+40000081@example.local`
(UUIDs from `40000000-4001-...` to `40000081-4001-...`, 130 followers total).

A few representative examples:

| Display Name | Email | Relationship |
|---|---|---|
| Grandma Emma | `seed+40000000@example.local` | Grandparent |
| Grandpa Olivia | `seed+40000001@example.local` | Grandparent |
| Aunt Ava | `seed+40000002@example.local` | Relative |
| Uncle Isabella | `seed+40000003@example.local` | Relative |
| Cousin Sophia | `seed+40000004@example.local` | Relative |
| Friend Mia | `seed+40000005@example.local` | Friend |

> **Quick test tip**: Use `seed+10000000@example.local` / `password123` (Sarah Johnson)
> as your primary test owner account — Baby 0 (Johnson) has the most comprehensive data.

### Manually Creating Auth Users in Supabase Dashboard

If you need to create individual test users manually (outside of the bulk seed):

1. Go to **Authentication → Users** in the Supabase dashboard
2. Click **Add user → Create new user**
3. Enter email and password
4. Toggle **Auto Confirm User** to `ON`
5. Click **Create User**
6. Copy the generated UUID and use it when inserting into `public.profiles`

For the seed users, you can also use the Supabase Auth Admin API directly:

```bash
curl -X POST 'https://<project-ref>.supabase.co/auth/v1/admin/users' \
  -H 'Authorization: Bearer <service-role-key>' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "test.owner@example.com",
    "password": "testpassword123",
    "email_confirm": true,
    "user_metadata": {"display_name": "Test Owner"}
  }'
```

---

## 7. Data Coverage Map

The following table maps each app feature to the test data that exercises it:

| App Feature | Covered By | Test User(s) |
|---|---|---|
| **Sign in / Sign up** | 150 auth users created | Any email from §6 |
| **Profile screen** | 150 profiles with display names & avatars | Any user |
| **Baby profile view** | 10 baby_profiles (different stages: some born, some expected) | Any member |
| **Owner dashboard** | Baby memberships with `role='owner'` | Sarah Johnson (`seed+10000000@`) |
| **Follower feed** | Baby memberships with `role='follower'` | Grandma Emma (`seed+40000000@`) |
| **Tile layout (Home screen)** | screens + tile_definitions + tile_configs | Any member |
| **Photo gallery** | 8 photos with captions and tags | Any member of Baby 0 |
| **Photo squish (like)** | 8 photo_squishes | Followers of Baby 0 |
| **Photo comments** | 5 photo_comments | Followers of Baby 0 |
| **Photo tag search** | 9 photo_tags | Any user |
| **Calendar / Events** | 6 events (past and upcoming) | Any member |
| **Event RSVP** | 8 event_rsvps (attending / not_attending / maybe) | Followers |
| **Event comments** | 5 event_comments | Members |
| **Registry view** | 9 registry_items at varying priorities | Any member |
| **Registry purchase** | 4 registry_purchases | Followers |
| **Gender vote** | votes with `vote_type='gender'` | Members of Baby 0 |
| **Birth-date prediction** | votes with `vote_type='birthdate'` | Members of Baby 0 |
| **Name suggestions** | 8 name_suggestions | Members |
| **Name suggestion likes** | 7 name_suggestion_likes | Members |
| **Invitation flow** | 5 invitations (pending/accepted/expired/revoked) | Owners (send), followers (accept) |
| **Notification inbox** | 8 notifications | Various users |
| **Activity feed** | 17 activity_events | Any member |
| **Gamification stats** | user_stats per user | Any user |
| **Cache invalidation** | owner_update_markers (1 per baby) | Owners |
| **Biometric flag** | `biometric_enabled` column on profiles | Edit a profile |

---

## 8. Verification Queries

Run in SQL Editor (or via psql) after seeding.

### Quick count check

```sql
SELECT
  (SELECT COUNT(*) FROM auth.users)                                          AS "auth users",
  (SELECT COUNT(*) FROM public.profiles)                                     AS "profiles",
  (SELECT COUNT(*) FROM public.baby_profiles)                                AS "babies",
  (SELECT COUNT(*) FROM public.baby_memberships WHERE role = 'owner')        AS "owners",
  (SELECT COUNT(*) FROM public.baby_memberships WHERE role = 'follower')     AS "followers",
  (SELECT COUNT(*) FROM public.events)                                       AS "events",
  (SELECT COUNT(*) FROM public.photos)                                       AS "photos",
  (SELECT COUNT(*) FROM public.registry_items)                               AS "registry items",
  (SELECT COUNT(*) FROM public.votes)                                        AS "votes",
  (SELECT COUNT(*) FROM public.name_suggestions)                             AS "name suggestions",
  (SELECT COUNT(*) FROM public.notifications)                                AS "notifications";
```

### Verify a full owner login flow

```sql
-- Check Sarah Johnson can log in and owns Baby Johnson
SELECT
  u.email,
  p.display_name,
  b.name AS baby_name,
  m.role
FROM auth.users u
JOIN public.profiles p ON p.user_id = u.id
JOIN public.baby_memberships m ON m.user_id = u.id
JOIN public.baby_profiles b ON b.id = m.baby_profile_id
WHERE u.email = 'seed+10000000@example.local';
```

### Verify follower relationships

```sql
-- Show how many babies each follower follows
SELECT
  p.display_name,
  COUNT(*) AS baby_count
FROM public.profiles p
JOIN public.baby_memberships m ON m.user_id = p.user_id
WHERE m.role = 'follower' AND m.removed_at IS NULL
GROUP BY p.display_name
ORDER BY baby_count DESC
LIMIT 10;
```

### Verify content per baby

```sql
SELECT
  b.name                                                    AS baby,
  COUNT(DISTINCT ph.id)                                     AS photos,
  COUNT(DISTINCT e.id)                                      AS events,
  COUNT(DISTINCT ri.id)                                     AS registry_items,
  COUNT(DISTINCT ns.id)                                     AS name_suggestions
FROM public.baby_profiles b
LEFT JOIN public.photos ph ON ph.baby_profile_id = b.id AND ph.deleted_at IS NULL
LEFT JOIN public.events e  ON e.baby_profile_id  = b.id AND e.deleted_at  IS NULL
LEFT JOIN public.registry_items ri ON ri.baby_profile_id = b.id AND ri.deleted_at IS NULL
LEFT JOIN public.name_suggestions ns ON ns.baby_profile_id = b.id AND ns.deleted_at IS NULL
GROUP BY b.name
ORDER BY b.name;
```

### Full table-by-table validation

```bash
# Run the dedicated validation script
psql "postgresql://postgres:<password>@<host>:5432/postgres" \
     -f supabase/seed/validate_seed_data.sql
```

---

## 9. Troubleshooting

### "relation does not exist"

The schema has not been applied. For local Supabase run `supabase db reset`. For remote, run `supabase/seed/manual_db_and_seed_creation.sql` first.

### "foreign key violation" when loading seed_data.sql separately

`supabase/seed/seed_data.sql` (in the `seed/` subdirectory) does **not** include auth user creation. Load `supabase/seed.sql` (root level) instead, or run `supabase/seed/auth_users_with_identities.sql` before `seed_data.sql`.

### Users cannot sign in after seeding

The `auth_users_with_identities.sql` file creates users with encrypted passwords. Verify:

```sql
SELECT id, email, encrypted_password IS NOT NULL AS has_password
FROM auth.users
WHERE email = 'seed+10000000@example.local';
```

If `has_password` is `FALSE`, re-run `supabase/seed.sql` which includes `crypt('password123', gen_salt('bf'))`.

For local Supabase, email confirmation is automatic. For remote Supabase, users are created with `email_confirmed_at = NOW()`, so confirmation emails are not required.

### "permission denied for table auth.users"

You are not running as `service_role`. In the Supabase SQL Editor, ensure you are using the service role context. Via psql, connect as `postgres` (the superuser) using the database password from **Project Settings → Database**.

### Seed runs but RLS blocks all data queries

The seed uses `SET session_replication_role = 'origin'` (or `'replica'` in some versions) to bypass triggers during loading. After seeding, verify RLS is enabled and working:

```sql
-- Should return rows if Sarah Johnson is queried as herself
SET request.jwt.claims = '{"sub":"10000000-1001-1001-1001-000000001001","role":"authenticated"}';
SELECT COUNT(*) FROM public.photos;
RESET request.jwt.claims;
```

### "duplicate key value" when re-running seed

The seed uses `ON CONFLICT DO NOTHING` for most inserts. If you see duplicate key errors on `auth.users`, the seed file's `TRUNCATE ... CASCADE` block at the top did not complete. Run it manually:

```sql
TRUNCATE TABLE auth.identities CASCADE;
TRUNCATE TABLE auth.users CASCADE;
```

Then re-run the seed.

### Want to reset without dropping schema

```sql
-- Truncate all app data (keeps schema intact)
TRUNCATE TABLE public.activity_events CASCADE;
TRUNCATE TABLE public.baby_memberships CASCADE;
TRUNCATE TABLE public.baby_profiles CASCADE;
TRUNCATE TABLE public.event_comments CASCADE;
TRUNCATE TABLE public.event_rsvps CASCADE;
TRUNCATE TABLE public.events CASCADE;
TRUNCATE TABLE public.invitations CASCADE;
TRUNCATE TABLE public.name_suggestion_likes CASCADE;
TRUNCATE TABLE public.name_suggestions CASCADE;
TRUNCATE TABLE public.notifications CASCADE;
TRUNCATE TABLE public.owner_update_markers CASCADE;
TRUNCATE TABLE public.photo_comments CASCADE;
TRUNCATE TABLE public.photo_squishes CASCADE;
TRUNCATE TABLE public.photo_tags CASCADE;
TRUNCATE TABLE public.photos CASCADE;
TRUNCATE TABLE public.profiles CASCADE;
TRUNCATE TABLE public.registry_items CASCADE;
TRUNCATE TABLE public.registry_purchases CASCADE;
TRUNCATE TABLE public.tile_configs CASCADE;
TRUNCATE TABLE public.tile_definitions CASCADE;
TRUNCATE TABLE public.screens CASCADE;
TRUNCATE TABLE public.user_stats CASCADE;
TRUNCATE TABLE public.votes CASCADE;
-- Then re-run the seed
```

---

> ⚠️ **This guide is for development and testing only. Never load seed data into a production database.**
