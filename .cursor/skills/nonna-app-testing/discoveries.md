# Testing discoveries log

Append-only knowledge captured while running or debugging Nonna tests. **No secrets** (no keys, tokens, DB passwords, or full `.env` values).

Newest entries at the **top**. When promoting stable facts into [reference.md](reference.md) or [SKILL.md](SKILL.md), remove or shorten the log entry and add a “Promoted YYYY-MM-DD” note.

---

## 2026-09-19 — Integration login + §1 test fixes

- **Context:** `qa_manual_section_01_test.dart`, `fd_00` / `fd_03` after `pm clear`.
- **Finding:** `signInIfNeeded` should `appRouter.go(OnboardingRoutes.login)` instead of carousel→signup link. Returning `testuser_nonna` with memberships: after complete-profile, call `setOnboardingCompleted(true)` + `completeOnboarding()` then `go('/home')`. §1.3 follower carousel needs `setCarouselIndex(0)` when switching from owner slides. Back from signup asserts `ownerCarouselPrimary`, not slide-1 headline. `fd_03` taps Profile `Settings`/`Logout` by text (not `profile_settings_item_*` keys).
- **Source:** `integration_test/test_helper.dart`, `qa_manual_section_01_test.dart`, `fd_03_settings_logout_test.dart`

---

## 2026-09-19 — “Could not save profile” on complete-profile (manual QA)

- **Context:** `testuser_nonna@example.com` after `pm clear` + `flutter run`, terms checked, name filled.
- **Finding:** `profileProvider` is `NotifierProvider.autoDispose`; onboarding complete-profile only `ref.read` during `upsertProfile` → notifier disposed mid-await → `saveSuccess` false, `saveError` null (generic snackbar). Supabase row for testuser was fine (PATCH via REST succeeded). Fix: `ref.watch(profileProvider)` on screen + `ref.keepAlive()` for upsert.
- **Source:** `onboarding_complete_profile_screen.dart`, `profile_provider.dart`

---

## 2026-09-19 — Complete profile loop in integration login helper

- **Context:** Section 1 `startAppAndLogin` / `_reachHomeAfterAuth` on emulator.
- **Finding:** Retrying complete-profile every 400ms re-tapped the terms **Checkbox** (toggle off) → alternating snackbars (“accept terms” / “Could not save profile”). Fix: single attempt; tap “I agree to the” row once; do not automate §1.6 login until testuser skips that screen.
- **Source:** `integration_test/test_helper.dart`, `qa_manual_section_01_test.dart`

---

## 2026-09-19 — Invite expired screen blank (manual QA §0.8)

- **Context:** Invalid deep-link token after Section 0 preflight on emulator.
- **Finding:** `OnboardingInviteExpiredScreen` used `Spacer()` inside `OnboardingScaffold` body (wrapped in `SingleChildScrollView`) → white screen. Replace with fixed `SizedBox` spacing.
- **Source:** `lib/features/onboarding/presentation/screens/shared/onboarding_invite_expired_screen.dart`
- **Applies when:** Invalid/expired invite token lands on invitation unavailable UI.

---

## 2026-09-19 — QA preflight + integration login path

- **Context:** Adding full emulator manual QA checklist and automation scripts.
- **Finding:** `qa_emulator_preflight.sh` should use `adb devices` (not `flutter devices | grep`) for device detection. Auth `/auth/v1/health` may return **401** when project is up. `verify_config.py` needs `python-dotenv` — use repo-local `.venv-qa` (see preflight script). Legacy `signInIfNeeded()` only hit `/login`; cold start needs carousel → signup → **Log in** → onboarding login keys.
- **Source:** `scripts/qa_emulator_preflight.sh`, `integration_test/test_helper.dart`, `scripts/qa_run_automation_gates.sh`
- **Applies when:** Running `fd_*` integration tests or manual QA after `pm clear`.

---

<!-- Template (copy for new entries):

## YYYY-MM-DD — Short title

- **Context:** what you were testing
- **Finding:** command, quirk, fix, or account pattern
- **Source:** file path or command that verified it
- **Applies when:** optional scope

-->
