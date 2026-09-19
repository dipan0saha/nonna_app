# Nonna testing — reference

Stable catalogs and commands. Ephemeral or recent learnings live in [discoveries.md](discoveries.md) (agents append there first, then promote here when stable).

## `.env` variables (repo root)

Copy from `.env.example`. **Values live only in local `.env`** — never commit.

| Variable | Used for |
|----------|----------|
| `SUPABASE_URL` | App + tests + admin REST (`https://<ref>.supabase.co`) |
| `SUPABASE_ANON_KEY` | Flutter client (bundled via dotenv / init) |
| `SUPABASE_SERVICE_ROLE_KEY` | Integration/E2E admin (`OpsSupabaseTestSupport`), **never** in release APK logic |
| `SUPABASE_SERVICE_KEY` | Same key as service role — used by `scripts/create_test_users.py` only (name differs from `.env.example`) |
| `SUPABASE_ACCESS_TOKEN` | `supabase login --token …`, Management API |
| `SUPABASE_PROJECT_ID` | Project ref (subdomain of URL) |
| `SUPABASE_PASSWORD` | Direct Postgres (`scripts/database_*.py`, `psql` pooler) |
| `ENVIRONMENT` | `production` / `development` — app config |
| `GOOGLE_CLIENT_ID`, `FACEBOOK_APP_ID`, `ONESIGNAL_APP_ID` | OAuth / push (optional for many tests) |

Check presence without exposing values:

```bash
python3 scripts/verify_config.py
```

## Supabase access patterns

| Task | How |
|------|-----|
| Dashboard | [Supabase Dashboard](https://supabase.com/dashboard) → project `SUPABASE_PROJECT_ID` |
| CLI auth | `supabase login` (token from `.env` `SUPABASE_ACCESS_TOKEN`) |
| Link repo | `supabase link --project-ref "$SUPABASE_PROJECT_ID"` |
| SQL editor | Dashboard → SQL, or `psql` with pooler host from docs |
| Auth users (admin) | REST `/auth/v1/admin/users` or `scripts/create_test_users.py` |
| Flutter client | `Supabase.instance.client` after `AppInitializationService.initialize()` |

## Live schema — how to get it

1. **Migrations (preferred for “what should be deployed”)**  
   `supabase/migrations/` — apply order by filename timestamp.

2. **Dump from linked project**  
   ```bash
   supabase db dump --linked --schema public -f schema_snapshot.sql
   ```

3. **Documented snapshot (human-readable)**  
   `docs/99_master_reference_docs/Database_Schema_and_Functions.md`  
   - 25 public tables (summary table at top)  
   - Column definitions, RLS notes  
   - RPCs: `get_invitation_preview`, `accept_invitation`, `check_baby_membership_by_email`  
   - Edge functions under `supabase/functions/`

4. **App table constants**  
   `lib/core/constants/supabase_tables.dart`

If doc and migration disagree, **migrations + live dump win**.

## Test accounts catalog

### A. Widget/integration helper (`integration_test/test_helper.dart`)

- Email: `testuser_nonna@example.com`
- Password: `Password123!`
- Used by `signInIfNeeded()` in some integration tests — user must exist in Auth with confirmed email.

### B. Onboarding E2E (`onboarding_e2e_signoff_test.dart`)

- Password constant: `Password123!`
- Emails: generated per run, e.g. `qa-e2e-owner-<timestamp>@nonna.qa`, `qa-e2e-fol-owner-*`, `qa-e2e-co-owner-*`
- Created via `OpsSupabaseTestSupport.ensureConfirmedUser` (service role)
- Babies labeled **OPS Test Baby**; invite tokens `qa-e2e-<uuid>`
- **Cleanup:** delete auth users matching `%@nonna.qa` and related `baby_profiles` / `invitations` in dashboard or SQL

### C. Seed dataset (local/staging load)

- Script: `scripts/create_test_users.py`  
  - Args: `--url`, `--key` (service role) or env `SUPABASE_URL` / `SUPABASE_SERVICE_KEY`
  - Default password: `password123`
  - Owners: `seed+10000000@example.local` … (fixed UUIDs in script)
  - Followers: `seed+<hex>@example.local`
- Then run seed SQL: `docs/06_seed_data_creation/SEED_DATA_GUIDE.md`, `supabase/seed.sql`

### D. Manual multi-role scenarios

| Goal | Approach |
|------|----------|
| Owner flow | Seed owner email or complete owner onboarding E2E once |
| Follower flow | Owner invites `qa-e2e-fol-user-*@nonna.qa`; follower accepts via `/invite-accept?token=` |
| Co-owner flow | `createInvitationAsSignedInOwner` with `UserRole.owner` in E2E |
| Dual-role | One user owner on baby A, follower on baby B (two memberships) |

## Integration test files

| File | Purpose |
|------|---------|
| `integration_test/onboarding_e2e_signoff_test.dart` | Owner + follower + co-owner → `/home` |
| `integration_test/ops_device_signoff_test.dart` | OPS-010 email verify advance, OPS-P1-012 batch dedupe |
| `integration_test/onboarding_owner_flow_test.dart` | Carousel / invite route smoke |
| `integration_test/app_test.dart` | General app integration (Makefile default) |
| `integration_test/FLUTTER_DRIVE_E2E_SCENARIOS.md` | Drive scenarios (legacy/extra) |

## Unit test layout

```
test/
├── mocks/mock_services.dart      # @GenerateMocks — run build_runner to regen
├── helpers/mock_factory.dart
├── helpers/test_data_factory.dart
├── core/
├── features/onboarding/
├── tiles/
└── accessibility/
```

Regenerate mocks:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Categorized runner: `make test-all` → updates `automated_tests/TEST_COMMANDS.md`.

## Emulator / device

```bash
flutter devices
export ANDROID_SERIAL=emulator-5554   # optional
adb devices
```

Paused Supabase symptom: `Failed host lookup` for project URL — restore project in dashboard.

## Ops checklist cross-ref

`docs/96_enhancement_ideas/onboarding_manual_ops_checklist.md` — OPS-005 (`.env` matches project), OPS-006, E2E sign-off status, release smoke.

## Full emulator manual QA (checklist)

`docs/96_enhancement_ideas/full_emulator_manual_qa_checklist.md` — sectioned sign-off (onboarding → main app → deep links → third-party last).

| Script | Purpose |
|--------|---------|
| `scripts/qa_emulator_preflight.sh` | Section 0: device, `.env`, Supabase reachability, adb helpers (`com.la_nonna.nonna_app`) |
| `scripts/qa_run_automation_gates.sh` | Runs integration_test smoke on `emulator-5554` (+ E2E if service role in `.env`); clears app data before run |

**`fd_*` / `auth_integration_test`:** `testuser_nonna@example.com` must exist in Auth with **confirmed email**, `isOnboardingCompleted`, and at least one baby membership (or tests stop on onboarding screens).
