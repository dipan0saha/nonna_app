# Nonna App — Current System Gaps Analysis

**Document Version**: 2.0
**Date**: May 25, 2026
**Location**: `docs/99_master_reference_docs/Current_System_Gaps.md`
**Status**: Living Document - Fully updated with Technical and Plain Language sections

This document provides a comprehensive technical audit and a non-technical plain language summary of the Nonna App codebase. It identifies existing architectural limits, structural drifts, untested sections, and deployment blockers that need to be addressed before the platform is production-ready.

---

## 🗄️ Table of Gaps

| Area | Gap Description | Severity | Impact |
|---|---|---|---|
| **Routing** | Deep-Link / Push Notification routing crash on null `extra` payloads. | **High** | App crashes or shows "not found" pages when deep-linked or launched via notifications. |
| **Architecture** | Dead boilerplate folders and architectural drift in lean feature directories. | **Medium** | Visual clutter and confusion in `lib/features/` directories. |
| **Testing** | Missing isolated tests for 4 newly added smart tiles. | **Medium** | Risk of regression bugs on gamification and welcome cards. |
| **Edge Functions** | Functioning backend stub in the `generate-thumbnail` function. | **Low** | Stale/Mocked thumbnail paths are saved without actual image resizing. |
| **Localization** | Hardcoded English strings on newer features and tiles. | **Medium** | Broken translations for Spanish users. |
| **Offline Sync** | Stale caches on cellular socket reconnect. | **Medium** | Users see outdated data until a manual pull-to-refresh is executed. |
| **Growth** | Limited email-only invitation acquisition loops. | **Low** | High friction for parent owners to invite family members. |
| **CI/CD** | Absence of unified mobile cloud-testing setup. | **High** | Undetected device-specific layout and crash regressions on native runs. |

---

## 🔍 Detailed Gap Analysis & Technical Breakdowns

### 1. Routing Deep-Link Vulnerabilities (High Severity)
* **Underlying Code**: `lib/core/router/app_router.dart`
* **Technical Detail**: Detail screens for Calendar events (`AppRoutes.calendarEvent`), photo gallery details (`AppRoutes.galleryPhoto`), and registry gift details (`AppRoutes.registryItem`) are configured to read full domain entities (e.g. `Event`, `Photo`, `RegistryItem`) directly from the GoRouter `state.extra` parameter:
  ```dart
  GoRoute(
    path: 'photo/detail',
    builder: (context, state) {
      final photo = state.extra as Photo?;
      if (photo == null) return _missingData('Photo');
      return PhotoDetailScreen(photo: photo);
    },
  )
  ```
* **Why it's a Gap**: The `extra` payload is an in-memory object only available during in-app programmatic navigation. If a user launches the app from a native push notification, deep-links from an invitation email, or if the operating system kills and restores the app in the background, `state.extra` becomes `null`. This results in the app permanently displaying the `_missingData` page ("Photo not found").
* **Resolution Plan**: Refactor the router paths to use unique identifier slugs (e.g., `/gallery/photo/:id`). Update the detail screens to read the `:id` parameter and fetch the entity from the cache or database during screen initialization (`initState`).

---

### 2. Architectural Folder Drift (Medium Severity)
* **Underlying Code**: `lib/features/` (`auth/`, `registry/`, `profile/`, etc.)
* **Technical Detail**: The codebase has shifted to a presentation-focused feature structure where screen widgets and Riverpod state controllers directly query core services. However, multiple feature directories still host extensive, completely empty folder structures representing unused architectural patterns:
  * `lib/features/auth/data/datasources/remote/` (empty)
  * `lib/features/auth/data/mappers/` (empty)
  * `lib/features/auth/data/repositories/` (empty)
  * `lib/features/auth/models/entities/` (empty)
  * `lib/features/auth/models/use_cases/` (empty)
  * Similar empty folders exist under `registry/` and `profile/`.
* **Why it's a Gap**: It creates structural noise and confusion for developers. It implies the codebase follows a Clean Architecture domain/use case layer, when it actually implements a highly simplified, presentation-focused Riverpod service model.
* **Resolution Plan**: Prune all completely empty subfolders. Keep `lib/features/` directories strictly restricted to `presentation/screens/`, `presentation/widgets/`, and `presentation/providers/`.

---

### 3. Missing Isolated Tile Test Suites (Medium Severity)
* **Underlying Code**: `lib/tiles/` -> `name_suggestions`, `prediction_votes`, `new_baby_welcome`, `registry_list`
* **Technical Detail**: The codebase comprehensively tests the original 14 tiles (e.g., `checklist`, `countdown`, `recent_photos`) with isolated unit and widget tests under `test/tiles/`. However, the 4 newly added smart tiles do not have dedicated test folders:
  * `test/tiles/name_suggestions/` (missing)
  * `test/tiles/prediction_votes/` (missing)
  * `test/tiles/new_baby_welcome/` (missing)
  * `test/tiles/registry_list/` (missing)
* **Why it's a Gap**: These tiles are currently only tested implicitly inside feature screen widget tests (such as `gamification_screen_test.dart`). If developers make isolated changes to these tiles, regressions could easily bypass layout boundary checks and crash the parent widget trees.
* **Resolution Plan**: Create dedicated, isolated test suites mirroring the established tile testing structure. Mock their respective providers and write widget tests verifying shimmers, empty states, and interactive inputs.

---

### 4. Stubbed Media Transformation in Edge Functions (Low Severity)
* **Underlying Code**: `supabase/functions/generate-thumbnail/index.ts`
* **Technical Detail**: The edge function `generate-thumbnail` handles bucket trigger uploads but acts as a functional stub:
  ```typescript
  // Let's pretend it generated something perfectly.
  const fakeThumbnailPath = `${path.split('.')[0]}_thumb.jpg`;
  ```
  It writes the mock path directly to the database column without executing any Deno/Sharp or WASM-based binary image transformation.
* **Why it's a Gap**: The mobile client attempts to render optimized thumbnails using paths provided by the database. Since these thumbnails don't actually exist on Supabase Storage, the loading of these images will fail, forcing a fallback to full-size, unoptimized image assets, which harms memory and network performance.
* **Resolution Plan**: Implement actual server-side image resizing inside `generate-thumbnail` using a lightweight Deno WASM resizing library or integrate with a dedicated media transformation service, then write the actual transformed binary back to the storage bucket.

---

### 5. Incomplete Spanish Localization (Medium Severity)
* **Underlying Code**: `lib/l10n/app_es.arb` and hardcoded widget parameters
* **Technical Detail**: The app supports bilingual localization (English and Spanish). However, many of the newer screens and tiles have hardcoded English strings in their files:
  * `NewBabyWelcomeTile` values (e.g., `"Born today!"`, `"N days old"`) are hardcoded.
  * `prediction_votes_tile.dart` values (e.g., `"Engagement Recap"`, `"neutral"`) bypass the localization files.
* **Why it's a Gap**: Spanish users will see broken and untranslated English components scattered throughout their screens, degrading the user experience.
* **Resolution Plan**: Extract all hardcoded strings from widgets and providers, add them as key-value pairs inside `app_en.arb` and `app_es.arb`, and resolve them dynamically via `AppLocalizations.of(context)`.

---

### 6. Cellular Network Reconnection Limits (Medium Severity)
* **Underlying Code**: `lib/core/services/realtime_service.dart` and `lib/core/utils/tile_loader.dart`
* **Technical Detail**: While `RealtimeSubscriptionManager` prevents active connection leaks, the database synchronization layer does not explicitly handle network state transitions.
* **Why it's a Gap**: If a user walks into a dead zone (e.g., an elevator) and reconnects to cellular service, the persistent socket connection might disconnect and fail to automatically re-subscribe or pull missed database delta-logs. The user will continue to see stale caches without knowing they are disconnected unless they execute a manual pull-to-refresh.
* **Resolution Plan**: Integrate the `connectivity_plus` package inside `SyncManager`. Detect network reconnection events to automatically trigger state invalidations and refresh active screen subscriptions.

---

### 7. Email-Only Follower Invitations (Low Severity)
* **Underlying Code**: `lib/features/baby_profile/presentation/screens/invite_followers_screen.dart`
* **Technical Detail**: Follower invitation flows are restricted to email verification lookups (`invitee_email`). 
* **Why it's a Gap**: Inviting grandparents, friends, and family via manually typed email addresses introduces high friction. Modern growth loops rely on quick contacts book syncs, SMS text deep links, and quick-scan QR codes to onboarding followers instantly.
* **Resolution Plan**: Extend `send-invitation-email` or add a new link-generator endpoint. Allow owners to generate short deep-link URLs that can be copied and sent via text or WhatsApp.

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

### 2. Empty Code Drawers
* **The Problem**: The app's codebase has multiple empty folders inside it that are designed for a complicated system structure we don't actually use.
* **Why it happens**: It's like having a filing cabinet with dozens of empty, labeled drawers. It doesn't break the app, but it makes it confusing for new developers who are trying to find where files actually belong.
* **The Fix**: Delete the empty folders and keep the structure clean, neat, and simple.

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
