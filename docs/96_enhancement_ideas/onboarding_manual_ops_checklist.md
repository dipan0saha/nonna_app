# Onboarding — Manual Ops Checklist

**Purpose:** Track work that cannot be done in code alone (Supabase dashboard, emulator QA, deploys, env config).  
**Companion doc:** [onboarding_prototype_implementation_plan.md](./onboarding_prototype_implementation_plan.md)

> **Living document:** When a phase introduces manual steps (ops, QA, dashboard config), add a row under **Pending** with phase tag, owner hint, and verification steps. Move items to **Done** when completed (date + who).

**Last updated:** 2026-09-08 (release APK smoke ✅; E2E 3/3 + invite cold-start ✅)

### Prod validation (2026-09-08)

Connected to linked project **nonna_app** (`ubptybhhrgdiyfkcqgwu`, East US) via Postgres pooler — **not** local Docker.

| Check | Result |
|-------|--------|
| Connection | ✅ OK |
| Public tables | 25 tables, data present |
| **Phase 0b migration** | ✅ Applied 2026-09-08 — columns + RPCs live on prod |
| Prod migration track | Uses `supabase_migrations.schema_migrations` versions like `20260104000001` — differs from repo filenames (`02_schema.sql`, `20260908000000_...`) |

**Row counts (prod):** 156 users/profiles · 27 baby profiles · 171 memberships (35 owner / 135 follower) · 14 invitations · 30 events · 54 photos · 40 registry items · 84 name suggestions · 64 votes

**Before Phase 1 invite testing on prod:** use a **non-expired** invitation token for OPS-007 (current prod invites are mostly past `expires_at`; preview RPC correctly returns `expired`).

---

## Phase 1 — Pre-flight

Run **before** starting Phase 1 owner UI work and again **before** shipping Phase 1 to prod testers. Cross-ref: [plan § Production database baseline](./onboarding_prototype_implementation_plan.md#production-database-baseline-2026-09-08).

### A. Phase 0b must be green first

| ID | Task | Blocker? | How to verify |
|----|------|----------|---------------|
| OPS-P1-001 | **Phase 0b ops complete** | Yes | OPS-003 ✅ redirect URLs · OPS-004 ✅ edge fn (if sending email) · OPS-005/006 ✅ env matches Supabase project |
| OPS-P1-002 | **Phase 0b emulator gate** | Yes | OPS-007 ✅ unauthenticated preview · OPS-008 ✅ authenticated incomplete · OPS-009 ✅ co-owner path from DB `invited_role` |
| OPS-P1-003 | **Auth email callback** | Yes for signup QA | OPS-010 ✅ confirm link opens app |

### B. Test data on prod (or staging mirror)

| ID | Task | Blocker? | How to verify |
|----|------|----------|---------------|
| OPS-P1-004 | ~~**Fresh follower invite**~~ | Done 2026-09-08 | Token `qa-follower-0b-20260908-0001` → preview RPC returns `pending` + baby name |
| OPS-P1-005 | ~~**Fresh co-owner invite**~~ | Done 2026-09-08 | Token `qa-coowner-0b-20260908-0001` → `invited_role: owner` |
| OPS-P1-006 | ~~**Active baby profile**~~ | Done 2026-09-08 | Tied to **Test Baby 1** (`379c9dc4-...`) |

**Quick SQL check (read-only):**

```sql
SELECT id, status, expires_at > now() AS not_expired, invited_role
FROM invitations
WHERE status = 'pending' AND expires_at > now()
ORDER BY created_at DESC LIMIT 5;
```

### C. Existing-user upgrade (critical — 156 prod accounts)

| ID | Task | Blocker? | How to verify |
|----|------|----------|---------------|
| OPS-P1-007 | **Membership backfill (#55)** | Yes before prod rollout | Sign in as account **with** active `baby_membership` + `isOnboardingCompleted = false` → lands on **`/home`**, not owner carousel |
| OPS-P1-008 | **Mid-owner flow not backfilled (#55)** | Yes | Account mid-owner (coordinator step saved, membership exists after create-baby) → resumes **First Moment / invite**, not `/home` |
| OPS-P1-009 | **Brand-new owner** | Yes | Fresh account, no memberships → owner carousel → full path still works |

### D. Phase 1 build / infra spot-checks

| ID | Task | Blocker? | How to verify |
|----|------|----------|---------------|
| OPS-P1-010 | **Storage buckets** | Before avatar/baby photo QA | Upload uses `user-avatars` / `baby-profile-photos` (not legacy `avatars` / `baby_profiles` bucket names) |
| OPS-P1-011 | **Registry insert shape** | Before First Moment registry branch | Insert matches prod `registry_items` (`priority`, `link_url`; no `purchased` column) |
| OPS-P1-012 | **Batch invite membership dedupe (#29)** | Yes before prod testers | On batch invite screen, enter email of **existing follower** on same baby → row shows skip message (`Already a member`); no duplicate invitation sent. **RPC applied to prod 2026-09-08** via `supabase db query --linked`. |

**Pre-flight sign-off:** All **Yes** rows in A + C marked ✅ before Phase 1 prod tester build. B required for invite/co-owner paths; D before relevant sub-phase QA. **OPS-P1-012** required after Phase 1e follow-up migration is applied.

---

## Phase 0 — Foundation

**No Supabase, deploy, or dashboard steps.** Phase 0 was client-only (theme, coordinator, routes, guards, unit tests).

| ID | Task | Required? | How to verify |
|----|------|-----------|---------------|
| OPS-P0-001 | **Smoke test:** app boots to owner carousel | Optional | `flutter run` → lands on `/onboarding/owner/carousel`; back/continue on carousel works |
| OPS-P0-002 | **Unit tests** | Optional (CI/local) | `flutter test test/features/onboarding/ test/core/router/route_guards_test.dart` |

**Not in scope for Phase 0:** migrations, redirect URL whitelist, deep-link emulator QA (those are Phase 0b — OPS-001+).

---

## Pending

### Database & Supabase (Phase 0b) — **BLOCKER for invite flows**

| ID | Task | Why | How to verify |
|----|------|-----|---------------|
| OPS-001 | ~~**Apply invitation migration**~~ | Done 2026-09-08 on prod | Columns + RPCs verified via `psql` |
| OPS-002 | **Run SQL tests** (optional CI/local) | Confirms RPC shape after migration | `supabase test db` or run [invitation_rpcs_test.sql](../../supabase/tests/invitation_rpcs_test.sql) |
| OPS-003 | ~~**Whitelist redirect URLs**~~ | Done 2026-09-08 via Management API | `uri_allow_list` includes auth callback + invite deep links + web fallbacks |
| OPS-004 | ~~**Deploy edge function**~~ | Done 2026-09-08 | `send-invitation-email` deployed to `ubptybhhrgdiyfkcqgwu` |

**Redirect URLs to whitelist (OPS-003):**

```
nonna://app/auth/callback
nonna://app/invite-accept
nonna://invite-accept
```

For local/staging web fallbacks (legacy email links), also add as needed:

```
https://dev.nonna.app/invite
https://staging.nonna.app/invite
https://nonna.app/invite
```

### Environment alignment (Phase 0b)

| ID | Task | Why | How to verify |
|----|------|-----|---------------|
| OPS-005 | ~~**Align app environment**~~ | Done 2026-09-08 — `.env` has `ENVIRONMENT=production` | Matches prod Supabase project |
| OPS-006 | ~~**Confirm `.env` points at same Supabase**~~ | Done 2026-09-08 | `SUPABASE_URL` host = `ubptybhhrgdiyfkcqgwu.supabase.co` |

### Phase 0b gate — emulator / device QA

| ID | Task | Why | How to verify |
|----|------|-----|---------------|
| OPS-007 | ~~**Unauthenticated invite preview**~~ | Done 2026-09-08 on emulator | Fresh install → deep link → **Test Baby 1** + **testuser_nonna** shown before signup |
| OPS-008 | ~~**Authenticated incomplete invite**~~ | Done 2026-09-08 on emulator | Signed-in QA user (`qa-ops008-incomplete@nonna.qa`) → deep link → preview still shows **Test Baby 1** + **testuser_nonna** |
| OPS-009 | ~~**Co-owner role without `role=owner` in URL**~~ | Done 2026-09-08 on emulator | Token `qa-coowner-0b-20260908-0001` → **Co-own with testuser_nonna** (no `role=owner` param) |

**ADB deep-link commands (Android emulator/device):**

```bash
# Canonical
adb shell am start -a android.intent.action.VIEW \
  -d "nonna://app/invite-accept?token=YOUR_TOKEN_HERE"

# Legacy formats (should also work)
adb shell am start -a android.intent.action.VIEW \
  -d "nonna://invite-accept?token=YOUR_TOKEN_HERE"
```

**iOS Simulator:**

```bash
xcrun simctl openurl booted "nonna://app/invite-accept?token=YOUR_TOKEN_HERE"
```

**Create a test invitation:** Use owner flow → send invite email, or insert a row in `invitations` with a known `token_hash` and valid `baby_profile_id` / `invited_by_user_id`.

### Auth email flow (Phase 0b / Phase 1)

| ID | Task | Why | How to verify |
|----|------|-----|---------------|
| OPS-010 | **Email confirmation deep link** | **Partial 2026-09-08** — callback URL parsed; PKCE `?code=` + hash `refresh_token` reach Supabase auth (no longer `No code detected`). **Full cold-start signup → real confirm email** still required before prod testers. |

**OPS-010 result (2026-09-08):** Initial device test failed (`No code detected`). **Fix landed Phase 1b (#24)** — PKCE `?code=` + hash `refresh_token` fallback in `deep_link_service.dart`. **Re-test 2026-09-08:** `test/core/services/deep_link_service_test.dart` — **7/7 passed**. **Emulator re-test 2026-09-08:** `nonna://app/auth/callback?code=…` → `exchangeCodeForSession` (expected PKCE verifier error without prior signup); `#refresh_token=…` → `setSession` attempt (expected invalid token without real email). **Remaining:** one real signup confirm tap on device.

| OPS-P1-012-DEVICE | **Batch invite skip on device** | **Done 2026-09-08** — `ops_device_signoff_test.dart` OPS-P1-012 ✅ on `emulator-5554` |

---

## Done

| ID | Completed | Notes |
|----|-----------|-------|
| OPS-001 | 2026-09-08 | `20260908000000_invitation_preview_and_accept_rpcs.sql` applied to prod; recorded in `schema_migrations` |
| OPS-001b | 2026-09-08 | `check_baby_membership_by_email` RPC applied to prod via `supabase db query --linked` (Phase 1e follow-up #29) |
| OPS-003 | 2026-09-08 | Auth `uri_allow_list` updated via Management API (callback + invite deep links + web fallbacks) |
| OPS-004 | 2026-09-08 | `send-invitation-email` deployed to prod |
| OPS-005 | 2026-09-08 | `.env` `ENVIRONMENT=production` |
| OPS-006 | 2026-09-08 | `.env` `SUPABASE_URL` matches `ubptybhhrgdiyfkcqgwu` |
| OPS-P1-004 | 2026-09-08 | QA follower token `qa-follower-0b-20260908-0001` (expires 2026-09-15) |
| OPS-P1-005 | 2026-09-08 | QA co-owner token `qa-coowner-0b-20260908-0001` (expires 2026-09-15) |
| OPS-P1-006 | 2026-09-08 | Both invites on **Test Baby 1** |
| OPS-007 | 2026-09-08 | Unauthenticated invite preview on emulator (`qa-follower-0b-20260908-0001`) |
| OPS-008 | 2026-09-08 | Authenticated incomplete user + invite preview (`qa-ops008-incomplete@nonna.qa`) |
| OPS-009 | 2026-09-08 | Co-owner invite without URL role param (`qa-coowner-0b-20260908-0001`) |
| OPS-P4-001 | 2026-09-08 | `flutter test integration_test/onboarding_owner_flow_test.dart -d emulator-5554` — **2/2 passed** (carousel cold start + deep-link route) |
| OPS-P4-002 | 2026-09-08 | Follower deep link re-verified on emulator (`Test Baby 1`, `Accept Invitation`) — debug APK |
| OPS-P4-003 | 2026-09-08 | Co-owner deep link re-verified (`co-own`, `Accept & Join as Owner`) — debug APK |
| OPS-P4-004 | 2026-09-08 | Owner carousel cold start (`Your baby's story…`, `Next`, `Skip`) — debug APK after `pm clear` |

---

## Template for new items

When adding from a future phase, copy this block under **Pending**:

```markdown
### Short title (Phase N)

| ID | Task | Why | How to verify |
|----|------|-----|---------------|
| OPS-0XX | **Task name** | One-line reason | Concrete pass/fail steps |
```

**ID convention:** `OPS-###` sequential. Reference in PR test plans as `OPS-007 ✅`.

---

## Phase 4 — Emulator sign-off (2026-09-08)

| Item | Status |
|------|--------|
| `integration_test/onboarding_owner_flow_test.dart` on `emulator-5554` | ✅ 2/2 |
| Owner carousel cold start | ✅ (debug APK) |
| Follower invite deep link | ✅ token `qa-follower-0b-20260908-0001` |
| Co-owner invite deep link | ✅ token `qa-coowner-0b-20260908-0001` |
| OPS-010 full email confirm E2E | ⬜ needs real signup email tap |
| OPS-P1-012 batch invite skip UI | ✅ `ops_device_signoff_test.dart` on emulator |
| Full owner/follower/co-owner E2E to `/home` | ✅ `onboarding_e2e_signoff_test.dart` 3/3 on `emulator-5554` (2026-09-08) |
| Release APK invite cold-start | ✅ `nonna://app/invite-accept?token=...` → invite landing (2026-09-08) |
| Release APK owner smoke (carousel → signup) | ✅ release APK cold start + Skip → Create Account (2026-09-08) |
| Release APK owner path → `/home` | ✅ owner E2E 1/1 on emulator (debug harness; Flutter cannot drive release integration tests) |

These are not actionable yet; move to **Pending** when that phase starts.

- ~~Release APK install + abbreviated owner happy path on emulator~~ → carousel ✅; Skip → signup ✅; owner → home via debug E2E (2026-09-08)
- ~~`make test-integration` / onboarding integration tests on emulator~~ → ✅ `onboarding_owner_flow_test.dart`
- ~~Emulator sign-off recorded in [05_day_log.md](../95_atlabs_program/05_day_log.md) or PR test plan~~ → ✅ day log updated
- Universal links / App Links for desktop email (explicitly **out of MVP scope**)
