---
name: nonna-app-testing
description: Runs and debugs Nonna app tests (unit, widget, integration, E2E) against Supabase. Covers .env credentials, live schema inspection, test users by role, emulator sign-off, cleanup, and updating this skill's testing knowledge base when new facts are verified. Use when testing nonna_app, running flutter test, integration/E2E, Supabase test data, manual QA login accounts, or documenting test learnings.
---

# Nonna App — Testing

Repo root: `nonna_app/`. **Never commit or paste secrets** from `.env` into chat, skills, or git. Read credentials locally only.

If the workspace root is the parent **`Git_Repos`** monorepo, use slash **`/nonna-app-testing`** (launcher in `Git_Repos/.cursor/skills/nonna-app-testing/`). Canonical skill files stay in this folder.

## Before any live-backend test

1. Confirm Supabase project is **ACTIVE** (paused projects have no DNS):
   ```bash
   curl -sI "$(grep '^SUPABASE_URL=' .env | cut -d= -f2)/auth/v1/health" | head -1
   ```
2. Load env: `set -a && source .env && set +a` (from repo root).
3. Verify config (no DB required): `python3 scripts/verify_config.py`

Full credential names, schema sources, and account catalogs: [reference.md](reference.md). Session learnings: [discoveries.md](discoveries.md).

## Test layers (what to run)

| Layer | Command | Backend |
|-------|---------|---------|
| Unit / widget | `make test` or `flutter test test/<path>` | Mocked (`test/mocks/`, `MockFactory`) — see `test/README.md` |
| Theme / onboarding / a11y | `flutter test test/core/themes/ test/features/onboarding/ test/accessibility/` | Mostly mocked |
| Integration (device) | `make test-integration-auto` or `scripts/ops_emulator_signoff.sh` | **Live** Supabase from `.env` |
| Onboarding E2E sign-off | See “E2E sign-off” below | Live + **service role** dart-defines |

**Formatting:** use `dart format lib test integration_test` (not flutter format-only workflows unless user asks).

**Analyze before push:** `make analyze` or `dart analyze lib`.

## E2E / OPS sign-off (Android emulator)

Requires `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` in `.env` (admin API for creating `qa-e2e-*@nonna.qa` users — **not** bundled in the Flutter app).

```bash
# Device default: emulator-5554
./scripts/ops_emulator_signoff.sh
```

Or manually:

```bash
set -a && source .env && set +a
flutter test integration_test/onboarding_e2e_signoff_test.dart -d emulator-5554 \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY="$SUPABASE_SERVICE_ROLE_KEY"
```

Also runs: `integration_test/ops_device_signoff_test.dart` (OPS-010, OPS-P1-012).

Implementation: `integration_test/ops_supabase_test_support.dart`, `integration_test/test_helper.dart`.

## Manual app login (fixed accounts)

Use when exercising UI without E2E harness:

| Account | Email | Password | Role / notes |
|---------|-------|----------|----------------|
| Integration default | `testuser_nonna@example.com` | `Password123!` | Documented in `Nonna_Architecture_and_Workflow_Reference.md`; must exist in **your** Supabase Auth |
| Seed owners/followers | `seed+10000000@example.local` (etc.) | `password123` | 20 owners + 130 followers — create via `scripts/create_test_users.py` + `supabase/seed/` — see `docs/06_seed_data_creation/SEED_DATA_GUIDE.md` |

E2E creates **disposable** users: `qa-e2e-*@nonna.qa` with `Password123!` — safe to delete after runs.

**Roles in app:** `owner` and `follower` per baby (`baby_memberships`); co-owner is `owner` with invitation metadata. Dual-role users switch baby profile on home.

## Supabase CLI & live schema

From repo root (after `supabase login` with `SUPABASE_ACCESS_TOKEN` from `.env`):

```bash
supabase projects list
supabase link --project-ref "$SUPABASE_PROJECT_ID"
supabase db dump --linked -f /tmp/nonna_schema.sql   # live DDL snapshot
```

**Canonical docs (may lag code — prefer migrations when in doubt):**

- `docs/99_master_reference_docs/Database_Schema_and_Functions.md` — tables, RPCs, edge functions
- `supabase/migrations/*.sql` — source of truth for schema changes
- `lib/core/constants/supabase_tables.dart` — table/column names in Flutter

**Onboarding RPCs (integration):** `get_invitation_preview`, `accept_invitation`, `check_baby_membership_by_email` — documented in Database master doc.

**Python helpers** (need `SUPABASE_URL` + `SUPABASE_PASSWORD` in `.env`):

- `python3 scripts/database_stats.py` — row counts / sizes
- `scripts/database_query.py` — ad hoc queries (see `scripts/sample_queries.json`)

## Agent workflow

When user asks to test a feature:

1. Classify: unit (mock) vs integration (emulator + live DB).
2. For live tests, confirm `.env` and project not paused.
3. Run smallest relevant `flutter test` path first; then integration if needed.
4. For onboarding/regression, prefer `onboarding_e2e_signoff_test.dart` when emulator available.
5. After prod E2E, remind user to clean up `qa-e2e-*` auth users and `OPS Test Baby` rows if desired.
6. **Before testing:** skim [discoveries.md](discoveries.md) for recent gotchas relevant to the task.

## Knowledge base maintenance (required)

**Grow this skill** when you verify something important that future test runs would need and that is not already in SKILL.md / reference.md.

| What to capture | Where |
|-----------------|--------|
| One-off gotcha, flake, version-specific fix, “we tried X and Y worked” | Append to **discoveries.md** (newest first) |
| Stable catalog item (env var name, test file, account pattern, command) | **reference.md** |
| Every-run workflow change (default command, preflight step) | **SKILL.md** (keep under ~500 lines; link out for detail) |

**Record only when verified** — you ran the command, read the source, or reproduced the failure/fix. Link to repo paths (`integration_test/…`, `scripts/…`, migrations), not long code dumps.

**Never store:** service role keys, anon keys, access tokens, `SUPABASE_PASSWORD`, user-specific dashboard URLs with embedded credentials, or production PII.

**Do store:** public test passwords already documented in repo, email patterns (`qa-e2e-*@nonna.qa`), device IDs, Makefile targets, error messages and fixes.

After editing skill files, tell the user in one line what was added (no need to ask permission unless the finding is uncertain or environment-specific).

**Promotion:** When the same discovery appears twice or becomes canonical, merge into reference.md or SKILL.md and trim the log entry.

**Also update master docs** when the fact is architectural (not just QA trivia): e.g. new RPC → `Database_Schema_and_Functions.md`; new E2E file → `test/README.md` or ops checklist — and add a pointer in discoveries if the skill led the change.

## Key docs

- `test/README.md` — mocks, factories, onboarding test map
- `docs/96_enhancement_ideas/full_emulator_manual_qa_checklist.md` — full manual emulator QA (use `./scripts/qa_emulator_preflight.sh` + `./scripts/qa_run_automation_gates.sh`)
- `docs/96_enhancement_ideas/onboarding_manual_ops_checklist.md` — OPS checklist
- `docs/99_master_reference_docs/Current_System_Gaps.md` — known test/CI gaps
- `Makefile` — `test`, `test-all`, `test-integration`, `ci`

## Security rules for agents

- Do **not** write `SUPABASE_SERVICE_ROLE_KEY` into Dart source, commits, or skills.
- Integration tests pass service role via `--dart-define` only.
- Do not push `.env` or print full keys in logs.
