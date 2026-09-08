# Nonna App — Current System Gaps Analysis

**Document Version**: 2.2
**Date**: September 8, 2026
**Location**: `docs/99_master_reference_docs/Current_System_Gaps.md`
**Status**: Living Document - Fully updated with Technical and Plain Language sections

This document provides a comprehensive technical audit and a non-technical plain language summary of the Nonna App codebase. It identifies existing architectural limits, structural drifts, untested sections, and deployment blockers that need to be addressed before the platform is production-ready.

---

## 🗄️ Table of Gaps

| Area | Gap Description | Severity | Impact |
|---|---|---|---|
| ~~**Routing**~~ | ~~Deep-Link / Push Notification routing crash on null `extra` payloads.~~ | ~~**High**~~ | ✅ **RESOLVED (May 2026)** — ID-embedded routes + hybrid constructor pattern implemented across all 5 detail/edit screens. |
| **Architecture** | Dead boilerplate folders, ghost feature/tile directories, and misplaced test folders. | **Medium** | 35+ empty directories across `lib/features/` and `lib/tiles/`; ghost duplicates of active features; test files inside `lib/` that are never run by `flutter test` and are compiled into release builds. |
| **Testing** | Missing isolated tests for 4 newly added smart tiles. | **Medium** | Risk of regression bugs on gamification and welcome cards. |
| ~~**Edge Functions**~~ | ~~Functioning backend stub in the `generate-thumbnail` function.~~ | ~~**Low**~~ | ✅ **RESOLVED (May 2026)** — Real `imagescript` WASM resize (300×300 JPEG, quality 80) implemented. Correct `thumbnail_path` column written. 9 unit tests passing. |
| **Localization** | Hardcoded English strings on newer features and tiles. | **Medium** | Broken translations for Spanish users. |
| ~~**Offline Sync**~~ | ~~Stale caches on cellular socket reconnect.~~ | ~~**Medium**~~ | ✅ **RESOLVED (May 2026)** — `connectivity_plus` integrated via `NetworkStatusNotifier` + `ConnectivityWrapper`. Offline banner, silent cache retention, and per-tile error suppression all implemented and emulator-validated. |
| ~~**Onboarding**~~ | ~~No prototype first-run flow for owner/follower/co-owner.~~ | ~~**High**~~ | ✅ **RESOLVED (September 2026)** — `lib/features/onboarding/`; coordinator + theme; see §7b. |
| **Growth** | Email-only invitation acquisition (phone/contacts still disabled in prototype UI). | **Low** | Batch invite added during onboarding; SMS/contacts/QR not yet implemented. |
| **CI/CD** | Absence of unified mobile cloud-testing setup. | **High** | Undetected device-specific layout and crash regressions on native runs. |

---

## 🔍 Detailed Gap Analysis & Technical Breakdowns

### 1. ~~Routing Deep-Link Vulnerabilities~~ ✅ RESOLVED (May 2026)
* **Underlying Code**: `lib/core/router/app_router.dart`, 5 detail/edit screens, 4 call-site files
* **What Was Fixed**:
  * **`AppRoutes` constants** updated to embed `:id` path slugs for all 5 problematic routes:
    * `calendarEvent` → `/calendar/event/:id`, `calendarEventEdit` → `/calendar/event/:id/edit`
    * `galleryPhoto` → `/gallery/photo/:id`
    * `registryItem` → `/registry/item/:id`, `registryItemEdit` → `/registry/item/:id/edit`
  * **5 static URL builder helpers** added to `AppRoutes` (`galleryPhotoRoute`, `calendarEventRoute`, `calendarEventEditRoute`, `registryItemRoute`, `registryItemEditRoute`) — all call sites use these.
  * **Route ordering fixed**: Static `event/create` and `item/create` routes now appear before their dynamic `:id` siblings to prevent GoRouter matching `create` as an ID.
  * **5 screens adapted** with hybrid constructor (`entity?` + `entityId?` + assert): `PhotoDetailScreen`, `EventDetailScreen`, `EventEditScreen`, `RegistryItemDetailScreen` (also converted from `ConsumerWidget` → `ConsumerStatefulWidget`), `RegistryItemEditScreen`. Each screen branches in `initState()`: if the entity is available (in-app navigation via `extra`), initializes instantly; if only `entityId` is present (deep link / OS restore), fetches from DB via `DatabaseService` + `SupabaseTables` constants.
  * **7 navigation call sites** updated across 4 files to use ID-embedded URLs — `tile_factory.dart` (×3), `upcoming_events_screen.dart` (×1), `registry_list_tile.dart` (×2), `onesignal_config.dart` (×2). The `onesignal_config.dart` bug (passing raw String IDs as `extra`) is fixed as a side effect — push notification deep-links now work correctly.
  * **`_missingData` orphan** helper removed from `app_router.dart` (no longer needed).
* **Verification**: Zero analyzer errors/warnings in all 10 modified files. Release APK builds clean (65.5 MB). App validated on `emulator-5554`.
* **Files Changed**: `lib/core/router/app_router.dart`, `lib/core/config/onesignal_config.dart`, `lib/core/utils/tile_factory.dart`, `lib/features/calendar/presentation/screens/event_detail_screen.dart`, `lib/features/calendar/presentation/screens/event_edit_screen.dart`, `lib/features/calendar/presentation/screens/upcoming_events_screen.dart`, `lib/features/gallery/presentation/screens/photo_detail_screen.dart`, `lib/features/registry/presentation/screens/registry_item_detail_screen.dart`, `lib/features/registry/presentation/screens/registry_item_edit_screen.dart`, `lib/tiles/registry_list/widgets/registry_list_tile.dart`.

---

### 2. ~~Architectural Folder Drift~~ ✅ RESOLVED (June 2026)
* **Underlying Code**: `lib/features/`, `lib/tiles/`
* **What Was Fixed**:
  * **Phase 1 — Ghost top-level directories (Category B):** Deleted `lib/features/fun/`, `lib/features/photo_gallery/`, and `lib/tiles/registry_deals/`. These were entirely empty directories with no Dart files. `test/tiles/registry_deals/` had already been deleted as part of Gap #3 resolution.
  * **Phase 2 — Misplaced `test/` dirs in `lib/` (Category C):** Deleted 21 empty `test/` subdirectories that had been placed inside the source tree across `lib/features/` (auth, calendar, gallery, home, profile, registry) and `lib/tiles/` (activity_list, checklist, core, countdown, gallery_favorites, invites_status, new_followers, notifications, recent_photos, recent_purchases, registry_highlights, rsvp_tasks, storage_usage, system_announcements, upcoming_events). Any Dart files placed there would have been compiled into the release APK and silently skipped by `flutter test`.
  * **Phase 3 — Empty feature scaffold (Category A):** Deleted empty `data/` and `models/`/`domain/` trees from `lib/features/auth/`, `lib/features/profile/`, and `lib/features/registry/`. Each now contains only `presentation/`.
  * **Phase 4 — Empty tile scaffold (Category A):** Deleted empty `data/` and `models/` trees from 15 active tile directories (activity_list, checklist, core, countdown, gallery_favorites, invites_status, new_followers, notifications, recent_photos, recent_purchases, registry_highlights, rsvp_tasks, storage_usage, system_announcements, upcoming_events). Also deleted the empty `lib/tiles/registry_list/providers/` stub.
  * **Verification**: `find lib/features lib/tiles -type d -empty` returns zero results. Zero errors in `lib/` from `flutter analyze`. Release APK builds clean (65.5 MB). All 43 tile unit tests continue to pass. App validated on emulator-5554.
* **Files Changed**: ~121 empty directories deleted across `lib/features/`, `lib/tiles/`. Zero Dart source files modified.

---

### 3. ~~Missing Isolated Tile Test Suites~~ ✅ RESOLVED (May 2026)
* **Underlying Code**: `lib/tiles/` -> `name_suggestions`, `prediction_votes`, `new_baby_welcome`, `registry_list`
* **What Was Fixed**:
  * Deleted the empty ghost directory `test/tiles/registry_deals/` (matched the ghost tile `lib/tiles/registry_deals/` in Gap 2, Category B).
  * Created 4 isolated widget test suites, each with ~10 coverage assertions:
    * `test/tiles/new_baby_welcome/widgets/new_baby_welcome_tile_test.dart` — 11 tests. StatelessWidget, wrapped in `MaterialApp` with `AppLocalizations` delegates. Tests: key, shimmer, error + retry callback, null profile → SizedBox.shrink, name/weight/height display, born-today badge, singular/plural day counter.
    * `test/tiles/prediction_votes/widgets/prediction_votes_tile_test.dart` — 9 tests. ConsumerStatefulWidget; providers overridden via `ProviderScope`. Fakes: `_FakePredictionVotesNotifier`, `_FakeAuthNotifier`, `_FakeSelectedBabyProfileNotifier`. Tests: key, loading indicator, error, Boy/Girl buttons, "Pick a date" vs "Change your prediction" birthdate label, vote summary hidden/shown.
    * `test/tiles/name_suggestions/widgets/name_suggestions_tile_test.dart` — 9 tests. ConsumerStatefulWidget; same provider override pattern. Tests: key, loading, error, empty state, suggestion rows with `Key('name_suggestion_<id>')`, add button toggle, form fields + gender chips, title header.
    * `test/tiles/registry_list/widgets/registry_list_tile_test.dart` — 12 tests. ConsumerWidget; uses `MaterialApp.router` + `GoRouter` to satisfy `context.push()` calls. Providers: `registryScreenProvider` + `homeScreenProvider` overridden. Tests: shimmer when loading, no root key during load, correct key when loaded, Available/Purchased section headers, item name, lock/undo/check_circle_outline purchase icons, empty state.
  * All **43 tests pass** (`flutter test test/tiles/new_baby_welcome/ test/tiles/prediction_votes/ test/tiles/name_suggestions/ test/tiles/registry_list/`).
* **Files Changed**: 4 new test files created; `test/tiles/registry_deals/` deleted.

---

### 4. ~~Stubbed Media Transformation in Edge Functions~~ ✅ RESOLVED (May 2026)
* **Underlying Code**: `supabase/functions/generate-thumbnail/index.ts`
* **What Was Fixed**:
  * Replaced the fake path stub with a real pipeline: download from Storage → `imagescript` WASM decode → cover-resize to 300×300 → JPEG encode at quality 80 → upload to Storage → update `thumbnail_path` DB column.
  * Fixed the wrong DB column name (`thumbnail_url` → `thumbnail_path`) matching the `photos` table schema and `Photo` Flutter model.
  * Added proper HTTP 400 validation for missing `bucket`/`path` fields; processing errors now return HTTP 500 (not 400).
  * Replaced the single stub assertion test with 9 behavioural unit tests (path derivation × 4, request validation × 3, response shape × 1, optional fields × 1) — all passing.
  * Added `imagescript` import map entry to `deno.json`.
  * Upload uses `upsert: true` for idempotent retries.
* **Files Changed**: `supabase/functions/generate-thumbnail/deno.json`, `index.ts`, `index.test.ts`.
* **Flutter client**: No changes required — `gallery_screen.dart` / `StorageService.uploadPhotoWithThumbnail()` already write `thumbnail_path` correctly via the client-side path.

---

### 5. Incomplete Spanish Localization (Medium Severity)
* **Underlying Code**: `lib/l10n/app_es.arb` and hardcoded widget parameters
* **Technical Detail**: The app supports bilingual localization (English and Spanish). However, many of the newer screens and tiles have hardcoded English strings in their files:
  * `NewBabyWelcomeTile` values (e.g., `"Born today!"`, `"N days old"`) are hardcoded.
  * `prediction_votes_tile.dart` values (e.g., `"neutral"`) bypass the localization files.
  * `activity_list_tile.dart` values (e.g., `"Engagement Recap"`) are hardcoded directly in the widget, not in `app_en.arb`.
* **Why it's a Gap**: Spanish users will see broken and untranslated English components scattered throughout their screens, degrading the user experience.
* **Resolution Plan**: Extract all hardcoded strings from widgets and providers, add them as key-value pairs inside `app_en.arb` and `app_es.arb`, and resolve them dynamically via `AppLocalizations.of(context)`.

---

### 6. ~~Cellular Network Reconnection Limits~~ ✅ RESOLVED (May 2026)
* **Underlying Code (was)**: `lib/core/services/realtime_service.dart` and `lib/core/utils/tile_loader.dart`
* **Resolution**:
  * Added `connectivity_plus: ^6.1.5` to `pubspec.yaml`.
  * Created `lib/core/di/connectivity_wrapper.dart` — a thin `ConnectivityWrapper` abstraction over `Connectivity.onConnectivityChanged` to enable full test isolation.
  * Created `lib/core/di/network_status_notifier.dart` — a non-autoDispose `Notifier<bool>` (`NetworkStatusNotifier`) that translates `ConnectivityResult` changes into a single boolean `isOnlineProvider`. Exposes a `markOffline()` method so providers can immediately flag an offline state on HTTP failure without waiting for the OS connectivity event (which can lag 100–500 ms or never fire on emulators).
  * Added three providers to `lib/core/di/providers.dart`: `connectivityWrapperProvider`, `isOnlineProvider`, and `syncManagerProvider`. All three are eagerly activated inside `appInitializationProvider` **after** `AppInitializationService.initialize()` completes to avoid a Supabase-not-initialized crash.
  * Wired `OfflineIndicator` as the first child of the `Column` in `lib/features/home/presentation/screens/home_screen.dart`.
  * Updated `loadTiles()` and `refresh()` catch blocks in `home_screen_provider.dart` to detect `SocketException` and call `markOffline()` — no `state.error` is set for network failures, so tiles retain their last-seen cached data.
  * Converted `InlineErrorView` in `lib/core/widgets/error_view.dart` from `StatelessWidget` to `ConsumerWidget`. It now returns `SizedBox.shrink()` when `isOnlineProvider` is false, suppressing per-tile error boxes across all 14 tile widgets simultaneously.
  * **Tests**: `test/helpers/fake_connectivity_wrapper.dart` (new test helper), `test/core/di/network_status_notifier_test.dart` (7 unit tests), `test/features/home/home_screen_offline_test.dart` (4 widget tests) — all 11 passing.
* **Emulator Validation**: App launches clean → home tiles load → disabling WiFi shows red banner, tiles retain last cached data, no inline error boxes → re-enabling WiFi hides banner and triggers silent background refresh.

---

### 7. Email-Only Follower Invitations (Low Severity)
* **Underlying Code**: `lib/features/baby_profile/presentation/screens/invite_followers_screen.dart`, `lib/features/onboarding/presentation/screens/owner/onboarding_batch_invite_screen.dart`
* **Technical Detail**: Follower invitation flows are restricted to email verification lookups (`invitee_email`). Onboarding batch invite adds multi-row email invites with co-owner (Wife/Husband) badges; **phone field is disabled** in prototype UI.
* **Why it's a Gap**: Inviting grandparents, friends, and family via manually typed email addresses introduces high friction. Modern growth loops rely on quick contacts book syncs, SMS text deep links, and quick-scan QR codes to onboarding followers instantly.
* **Resolution Plan**: Extend `send-invitation-email` or add a new link-generator endpoint. Allow owners to generate short deep-link URLs that can be copied and sent via text or WhatsApp.

---

### 7b. ~~Prototype Onboarding Flow~~ ✅ RESOLVED (September 2026)
* **Underlying Code**: `lib/features/onboarding/presentation/`, `lib/core/themes/onboarding_theme.dart`, `lib/core/router/route_guards.dart`
* **What Was Fixed**: Owner carousel → auth → profile → create baby → first moment → batch invite → first-run home; follower and co-owner invite deep-link paths; coordinator persistence; `OnboardingTheme` isolated from main shell.
* **Deprecated**: `RoleSelectionScreen` — `/role-selection` redirects to `/onboarding/owner/carousel`.
* **Terms checkbox (#34)**: UI-only on `OnboardingCompleteProfileScreen`; no `terms_accepted_at` column persisted (documented here).
* **Device sign-off (September 2026):** ✅ Emulator E2E 3/3; release APK smoke (build + carousel + Skip → signup); OPS-P1-012 + OPS-010 automated; release invite cold-start. **Optional:** OPS-010 real signup email tap; manual edge cases.

---

### 8. Cloud Testing CI/CD Pipeline Deficiencies (High Severity)
* **Underlying Code**: `.github/workflows/ci.yml` and `Makefile`
* **Technical Detail**: Integration tests (`make test-integration`) run fine locally on an active Android Emulator or iOS Simulator, but there is no pipeline for cloud-hosted physical device testing.
* **Why it's a Gap**: Local developer execution cannot guarantee that layout scales, dynamic text behaviors, biometric integrations, or native camera picker features will work across the highly fragmented list of real Android and iOS devices.
* **Resolution Plan**: Integrate native integration testing with **Firebase Test Lab** or **AWS Device Farm** in the GitHub Actions configuration. Configure matrix runs testing layouts across multiple OS versions and screen resolutions.

---

## 📢 Plain Language Summary (For Non-Technical Stakeholders)

This section translates the technical issues identified above into plain language, explaining **the problem** and **how we will fix it** in everyday terms.

### 1. Push Notification / Link Crashing
* **The Problem**: If a user receives a push notification (e.g., *"Grandpa added a new photo!"*) and taps it to open the app, or if they click a link in an email, the app gets confused and displays a blank screen saying "Photo not found" or "Event not found." 
* **Why it happens**: When you tap a notification, the app opens that specific screen directly, but it expects the previous screen to "hand over" the photo details. Since there was no previous screen, there's no data, and the app fails.
* **The Fix**: Teach the app how to find the photo or event by itself using its unique ID code, instead of expecting another screen to pass it along.

### 2. Empty Code Drawers & Ghost Feature Folders
* **The Problem**: The app's codebase contains two types of structural clutter. First, there are dozens of empty folders designed for a complicated system structure we don't actually use (like labeled filing cabinet drawers with nothing in them). Second — and more dangerous — there are two entire "ghost" feature sections (`fun/` and `photo_gallery/`) that look like real parts of the app but are completely empty imposters of the actual working sections (`gamification/` and `gallery/`). There is also a ghost registry tile (`registry_deals/`) that has a folder but no code at all.
* **Why it happens**: Early development scaffolded a Clean Architecture structure that was later simplified. The ghost directories were likely early naming attempts before the final feature names were settled. The empty test folders inside `lib/` were created by mistake — tests should live in the project-level `test/` folder, not inside the source code folder.
* **The Fix**: Delete all empty folders. Delete the ghost feature directories (`fun/`, `photo_gallery/`) and the ghost tile (`registry_deals/`). Remove the misplaced test folders from inside the source code directory.

### 3. Missing Feature Check-Ups
* **The Problem**: We added 4 excellent new features recently (the congratulations welcome banner, baby gender guessing, baby name suggestions, and the full registry page), but we didn't write dedicated automated check-ups (tests) specifically for them.
* **Why it happens**: While the rest of the app has automated checks that run every time we update the code, these four new features are unchecked. If a developer breaks them by accident in the future, we might not find out until a user complains.
* **The Fix**: Write automated "check-up" scripts specifically for these four features to catch any future breaks instantly.

### 4. Fake Photo-Shrinking (Large Files)
* **The Problem**: When you upload a photo, the app pretends to make a small, quick-loading "thumbnail" version for previews, but it actually just uses the massive original photo.
* **Why it happens**: The system that is supposed to shrink the photos is currently just a placeholder that makes up a fake file name without actually doing any resizing.
* **The Fix**: Turn on the actual photo-shrinking technology on the server so previews load instantly and save users' mobile data.

### 5. Spanish Translation Gaps
* **The Problem**: Some of our newest features (like the new baby congratulations banner and name suggestions) only have English text, so Spanish-speaking users will see a messy mix of English and Spanish.
* **Why it happens**: The new text was written directly in English code rather than being placed in the app's central translation files.
* **The Fix**: Move all text into translation files and provide Spanish equivalents so translations work seamlessly for everyone.

### 6. Elevator Reception Freeze
* **The Problem**: If you lose cell service (like in an elevator or parking garage) and then get it back, the app doesn't automatically download new updates. You have to manually drag the screen down to refresh it.
* **Why it happens**: The app doesn't listen to the phone's signal status, so it doesn't realize reception has returned.
* **The Fix**: Program the app to recognize when service returns and automatically refresh the screen for the user.

### 7. Annoying Invitation typing
* **The Problem**: Parents have to manually type out email addresses to invite family members to follow their baby, which is annoying and slow.
* **Why it happens**: The app only supports email invitations. There is no way to send a quick text or scan a code.
* **The Fix**: Allow parents to generate a simple invite link that they can copy and text or WhatsApp to family members, or show a QR code they can scan directly.

### 8. Untested Phone Types
* **The Problem**: We test the app on our developers' computers, but we don't test it across different kinds of physical phones (different screen sizes, camera types, and software versions).
* **Why it happens**: Setting up native physical phone tests requires special cloud configurations that are not yet established.
* **The Fix**: Connect our system to a cloud-based phone library (like Google's or Amazon's device libraries) so we can automatically test our updates on real phones before release.
