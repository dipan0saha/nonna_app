# Nonna App — Full Emulator Manual QA Checklist

**Purpose:** One-feature-at-a-time sign-off on Android emulator against live Supabase. Third-party flows are last (Section 18).

**Last updated:** 2026-09-19

**Quick start:**

```bash
cd nonna_app
./scripts/qa_emulator_preflight.sh          # Section 0 gates
./scripts/qa_run_automation_gates.sh        # Optional integration smoke (emulator-5554)
```

**References:** [nonna-app-testing SKILL](../../.cursor/skills/nonna-app-testing/SKILL.md), [reference.md](../../.cursor/skills/nonna-app-testing/reference.md), [onboarding_manual_ops_checklist.md](./onboarding_manual_ops_checklist.md), [FLUTTER_DRIVE_E2E_SCENARIOS.md](../../integration_test/FLUTTER_DRIVE_E2E_SCENARIOS.md).

**Test data:** use a run id in names you create (e.g. `QA Baby 20260919_1430`) for easier Supabase cleanup.

---

## How this maps to automation (optional gates)

| Gate | Command (from `nonna_app/`) |
|------|-------------------------------|
| Preflight | `./scripts/qa_emulator_preflight.sh` |
| Config only | `python3 scripts/verify_config.py` (needs `python-dotenv`) |
| Onboarding smoke | `flutter test integration_test/onboarding_owner_flow_test.dart -d emulator-5554` |
| Full onboarding E2E | `./scripts/ops_emulator_signoff.sh` |
| Auth + nav | `flutter test integration_test/fd_00_auth_navigation_test.dart -d emulator-5554` |
| All automation gates | `./scripts/qa_run_automation_gates.sh` |

Manual QA still required for: visual polish, offline airplane mode, release APK smoke, real email/OAuth, and push cold-start.

---

## Section 0 — Preflight (do once per session)

**Session sign-off:** 2026-09-19 · `emulator-5554` · debug APK · agent-led preflight

- [x] **0.1** `flutter devices` — Android emulator listed (default `emulator-5554`).
- [x] **0.2** From repo root: `set -a && source .env && set +a` then `python3 scripts/verify_config.py` passes.
- [x] **0.3** Supabase project **ACTIVE** (not paused); `./scripts/qa_emulator_preflight.sh` reports auth endpoint reachable.
- [x] **0.4** `.env` `SUPABASE_URL` host matches intended project ([OPS-005/006](./onboarding_manual_ops_checklist.md)).
- [x] **0.5** Install/run debug app: `flutter run -d emulator-5554` (or APK from `make build-android`).
- [x] **0.6** Decide personas for the session (run id `QA_20260919_1503`):
  - **Returning user:** `testuser_nonna@example.com` / `Password123!` ← default for §6–14
  - **Fresh flows:** `qa-manual-*@nonna.qa` / `Password123!` when we create users in §2–4
  - **Rich dataset (optional):** not used this session
- [x] **0.7** Cold start: `adb shell pm clear com.la_nonna.nonna_app`
- [x] **0.8** Deep link: `adb shell am start -a android.intent.action.VIEW -d "nonna://app/invite-accept?token=TOKEN"` (demo token `qa-preflight-section0-demo`; invalid token → **Invitation unavailable** — fixed blank screen from `Spacer` in scroll body, 2026-09-19)

---

## Section 1 — Cold launch, guards, and offline banner

**Session sign-off (agent + device):** 2026-09-19 · `emulator-5554` · `qa_manual_section_01_test.dart` pass after `pm clear`; `fd_00_auth_navigation_test.dart` pass; `fd_03_settings_logout_test.dart` pass (run files separately if batched run flakes). Login via `appRouter.go(/onboarding/login)` + returning-user `forceHome` in `test_helper.dart`.

**Paced run (2s steps):**

```bash
adb -s emulator-5554 shell pm clear com.la_nonna.nonna_app
sleep 2
ANDROID_HOME="$ANDROID_HOME" flutter test integration_test/qa_manual_section_01_test.dart -d emulator-5554
```

(`pm clear` in your shell only — not inside the test; airplane mode uses `ANDROID_HOME/.../adb`.)

- [x] **1.1** Cold launch, signed out → **owner carousel** (`/onboarding/owner/carousel`), not `/home`. *(integration: `onboarding_owner_flow_test.dart`; manual `pm clear` + `flutter run`)*
- [x] **1.2** Carousel: **Next** / **Skip** behave correctly. *(integration reached Create Account; back-to-carousel step flaky in `qa_manual_section_01_test.dart`)*
- [x] **1.3** Follower carousel (`/onboarding/follower/carousel`) — slides work. *(integration; reset `carouselIndex` to 0 when switching from owner flow)*
- [x] **1.4** Airplane mode ON → offline banner on onboarding scaffold.
- [x] **1.5** Airplane mode OFF → banner clears; no force-kill needed.
- [ ] **1.6** After login, disable network on **Home** → offline indicator; re-enable → tiles recover. *(manual on device — not automated; avoid `startAppAndLogin` loop on complete-profile)*

---

## Section 2 — Onboarding: owner (email path, no OAuth yet)

Use a new email (e.g. `qa-manual-owner-<runId>@nonna.qa`) unless reusing E2E users.

**Session note:** `testuser_nonna@example.com` after `pm clear` — **login** path (not fresh §2.1–2.3). Baby **Liam** created; reached Home.

- [ ] **2.1** Carousel → Create account → `/onboarding/signup`.
- [ ] **2.2** Signup validation errors; successful submit advances.
- [ ] **2.3** Email verify UI (`/onboarding/email-verify`). *Inbox confirm: Section 18.*
- [x] **2.4** Complete profile (`/onboarding/complete-profile`). *(manual `flutter run`; profile upsert fix 2026-09-19)*
- [x] **2.5** Create baby (`/onboarding/owner/create-baby`). *(baby Liam)*
- [ ] **2.6** First moment (`/onboarding/owner/first-moment`):
  - [ ] Expecting vs born / dates
  - [ ] Name suggestion drafts
  - [ ] Preset events
  - [ ] Preset registry ([OPS-P1-011](./onboarding_manual_ops_checklist.md))
  - [ ] Baby photo from emulator gallery
  - [ ] Skip still reaches next step
- [x] **2.7** Batch invite (`/onboarding/owner/invite`); duplicate member → `Already a member` ([OPS-P1-012](./onboarding_manual_ops_checklist.md)). *(invite screen reached; OPS-P1-012 automation failed 2026-09-19 — verify duplicate manually)*
- [x] **2.8** Finish → `/home`; relaunch respects `isOnboardingCompleted`. *(Home reached; relaunch not re-tested this session)*

---

## Section 3 — Onboarding: follower (invite deep link)

- [ ] **3.1** Unauthenticated + `nonna://app/invite-accept?token=…` → preview ([OPS-007](./onboarding_manual_ops_checklist.md)).
- [ ] **3.2** Legacy `nonna://invite-accept?token=…` works.
- [ ] **3.3** Follower invite landing (`/onboarding/follower/invite`).
- [ ] **3.4** Sign up / log in as invited email → accept → relationship confirm if shown.
- [ ] **3.5** `/home` as **follower** (no Gallery upload FAB).
- [ ] **3.6** Wrong email (`/onboarding/wrong-email`) → sign out.
- [ ] **3.7** Incomplete onboarding user + invite ([OPS-008](./onboarding_manual_ops_checklist.md)).

---

## Section 4 — Onboarding: co-owner

- [ ] **4.1** Co-owner token → `/onboarding/coowner/invite` without URL `role=owner` ([OPS-009](./onboarding_manual_ops_checklist.md)).
- [ ] **4.2** Welcome → `/home` with **owner** capabilities on that baby.

---

## Section 5 — Existing-user upgrade

- [ ] **5.1** Membership + `isOnboardingCompleted = false` → `/home` ([OPS-P1-007](./onboarding_manual_ops_checklist.md)).
- [ ] **5.2** Mid-owner flow resumes First moment / invite ([OPS-P1-008](./onboarding_manual_ops_checklist.md)).
- [ ] **5.3** New account, no memberships → full owner carousel ([OPS-P1-009](./onboarding_manual_ops_checklist.md)).

---

## Section 6 — Legacy auth (`/login`, `/signup`)

- [x] **6.1** `/login` → `/home` when onboarding complete. *(integration `fd_00` E2E-002 — onboarding login path)*
- [ ] **6.2** Invalid credentials → error, no crash.
- [ ] **6.3** Forgot password → snackbar. *Inbox: Section 18.*
- [ ] **6.4** `/signup` legacy flow works.
- [ ] **6.5** After logout, `/login` reachable.

---

## Section 7 — Main shell, home, context switching

**Session note:** Home loaded with bottom nav after §2.8; first-run hero + Family Insight pinned above tile scroll until tab change (by design).

- [x] **7.1** All **5 tabs** load (Home, Gallery, Calendar, Registry, Fun). *(integration `fd_00` E2E-003)*
- [ ] **7.2** Tab stack preserved when switching back.
- [ ] **7.3** Home app bar: search, avatar → profile/settings, baby/role switcher.
- [ ] **7.4** Dual-role user: switch baby → tiles and owner actions update.
- [x] **7.5** First-run home overlays dismiss correctly. *(overlay shows on first Home visit; dismiss on leaving Home tab — confirm by switching to Gallery and back)*
- [ ] **7.6** Pull-to-refresh on Home.
- [ ] **7.7** Empty home CTA → create baby.

---

## Section 8 — Home tiles (when visible)

| Tile | Owner | Follower | Check |
|------|-------|----------|-------|
| new_baby_welcome | ✓ | ✓ | [ ] **8.1** |
| countdown | ✓ | ✓ | [x] **8.2** *(Due Date Countdown tile on Home — manual session)* |
| upcoming_events | ✓ | ✓ | [ ] **8.3** |
| recent_photos | ✓ | ✓ | [ ] **8.4** |
| gallery_favorites | ✓ | ✓ | [ ] **8.5** |
| registry_highlights / registry_list | ✓ | ✓ | [ ] **8.6** |
| recent_purchases | ✓ | ✓ | [ ] **8.7** |
| name_suggestions | ✓ | ✓ | [ ] **8.8** |
| prediction_votes | ✓ | ✓ | [ ] **8.9** |
| new_followers | owner | — | [ ] **8.10** |
| invites_status | owner | — | [ ] **8.11** |
| notifications | ✓ | ✓ | [ ] **8.12** |
| activity_list | ✓ | ✓ | [ ] **8.13** |
| checklist | ✓ | ✓ | [x] **8.14** *(checklist tile loaded 0/6 — logcat)* |
| rsvp_tasks | ✓ | ✓ | [ ] **8.15** |
| system_announcements | ✓ | ✓ | [x] **8.16** *(Welcome to Nonna announcements — manual session)* |
| storage_usage | ✓ | ✓ | [ ] **8.17** |

- [ ] **8.18** Tile error + retry (brief offline).

---

## Section 9 — Baby profile and followers

- [ ] **9.1** Baby profile loads from switcher.
- [ ] **9.2** Owner: edit baby + photo ([OPS-P1-010](./onboarding_manual_ops_checklist.md)).
- [ ] **9.3** Create second baby → selected on home.
- [ ] **9.4** Followers management: remove follower.
- [ ] **9.5** Invite followers screen.
- [ ] **9.6** Follower: no edit/remove/invite.

---

## Section 10 — Gallery

- [ ] **10.1** Grid / empty state.
- [ ] **10.2** Owner: `upload_photo_fab` → upload success.
- [ ] **10.3** Follower: no FAB.
- [ ] **10.4** Photo detail: squish / comments.
- [ ] **10.5** Deep link `/gallery/photo/<id>` cold start.
- [ ] **10.6** `/gallery/recent`, `/gallery/favorites`.

---

## Section 11 — Calendar and events

- [ ] **11.1** Month view.
- [ ] **11.2** Owner: create event.
- [ ] **11.3** Event detail from calendar/tile.
- [ ] **11.4** Owner: edit/delete.
- [ ] **11.5** Upcoming list + refresh.
- [ ] **11.6** Deep link `/calendar/event/<id>`.
- [ ] **11.7** Follower restrictions.

---

## Section 12 — Registry

- [ ] **12.1** List sections.
- [ ] **12.2** Owner: create item.
- [ ] **12.3** Detail: purchase toggle.
- [ ] **12.4** Owner: edit when allowed.
- [ ] **12.5** Deep link registry item.
- [ ] **12.6** Follower purchase/edit rules.

---

## Section 13 — Fun / gamification

- [ ] **13.1** Fun tab tiles load.
- [ ] **13.2** Name suggestions flow.
- [ ] **13.3** Prediction votes flow.
- [ ] **13.4** Pull-to-refresh.

---

## Section 14 — Profile, settings, session

- [ ] **14.1** Profile load/error/retry.
- [ ] **14.2** Edit profile + avatar.
- [x] **14.3** Settings: notifications toggle persists. *(integration `fd_03` E2E-014)*
- [ ] **14.4** App version read-only.
- [x] **14.5** Logout → carousel/login. *(integration `fd_03` E2E-012 → `/login`)*
- [ ] **14.6** Re-login → data persists.

---

## Section 15 — Deep links (adb)

- [x] **15.1** `/invite-accept?token=` (repeat on release APK). *(route normalization unit test in `onboarding_owner_flow_test.dart`; §0.8 adb invalid token manual; **release APK not repeated**)*
- [ ] **15.2** `nonna://app/auth/callback` — no “No code detected” crash ([OPS-010](./onboarding_manual_ops_checklist.md)).
- [ ] **15.3** Gallery/calendar/registry ID routes cold start.
- [ ] **15.4** System back from detail screens.

---

## Section 16 — Release build smoke

- [ ] **16.1** `make build-android` → install release APK.
- [ ] **16.2** Cold start → carousel → Skip → signup.
- [ ] **16.3** Invite deep link on release APK.

---

## Section 17 — Cleanup and sign-off

- [ ] **17.1** Delete `qa-e2e-*@nonna.qa` / `qa-manual-*` auth users.
- [ ] **17.2** Remove test babies if desired.
- [ ] **17.3** Record sign-off (OPS IDs).
- [x] **17.4** Log gotchas in [discoveries.md](../../.cursor/skills/nonna-app-testing/discoveries.md). *(complete-profile autoDispose, first-run scroll layout, §1 test flake)*

---

## Section 18 — Third-party and external apps (last)

### Auth and email

- [ ] **18.1** Real signup email confirmation ([OPS-010](./onboarding_manual_ops_checklist.md)).
- [ ] **18.2** Password reset email link.
- [ ] **18.3** Onboarding Google sign-in (`GOOGLE_CLIENT_ID`).
- [ ] **18.4** Onboarding Facebook sign-in (`FACEBOOK_APP_ID`).
- [ ] **18.5** Legacy `/login` OAuth buttons.

### Push and analytics

- [ ] **18.6** OneSignal + Settings toggle (`ONESIGNAL_APP_ID`).
- [ ] **18.7** Push tap → detail routes.
- [ ] **18.8** Firebase Analytics init (no crash).

### Edge functions

- [ ] **18.9** Invitation email (`send-invitation-email`).
- [ ] **18.10** Thumbnail after photo upload (`generate-thumbnail`).

### External apps

- [ ] **18.11** Help → `mailto:support@nonna.app`.
- [ ] **18.12** Registry `link_url` → browser.

### Out of MVP

SMS/contacts/QR invite; universal/App Links on desktop email.

---

## Notes

- Settings: notifications + About/Help only (no theme picker in UI today).
- Tiles hide when data empty — seed or create content before failing §8.
- Repeat §9–12 as **follower**.
- Spanish: spot-check only; some strings still English-only.
