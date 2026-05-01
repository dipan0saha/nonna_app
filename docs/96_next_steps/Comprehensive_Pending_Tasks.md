# Comprehensive Pending Tasks & TODOs

**Document Version**: 1.0
**Created**: April 30, 2026
**Status**: Living Document

This document tracks all known pending activities, pending documentation items, missing implementations, and codebase `// TODO` items across the Nonna App repository.

---

## 1. Critical Functional Blockers (High Priority)

### 1.1 Unfinished Smart Tile Wrappers
All main smart tile wrapper implementations have been **completed**.

~~Six of the 18 active tiles are currently rendering hardcoded placeholder widgets and lack the `ConsumerStatefulWidget` wrappers necessary to hook into Riverpod and the dynamic Supabase DB configurations.~~

*Location: `lib/core/utils/tile_factory.dart`*
- [x] ~~`ChecklistTile`~~
- [x] ~~`InvitesStatusTile`~~
- [x] ~~`NewFollowersTile`~~
- [x] ~~`RecentPurchasesTile`~~
- [x] ~~`StorageUsageTile`~~
- [x] ~~`SystemAnnouncementsTile`~~

### 1.2 Push Notification Routing
**[COMPLETED]** - `onesignal_config.dart` now properly parses `type`, `photo_id`, `event_id`, etc., and appropriately calls `NavigationService.pushTo/goTo` depending on the state of the GoRouter branches!

~~When a user taps a OneSignal push notification, the app currently does nothing. It needs to parse the notification payload and use GoRouter to navigate to the correct screen (e.g., specific photo, event, or registry item).~~

~~*Location: `lib/core/services/` or `onesignal_config.dart`*~~
- [x] ~~Parse notification `additionalData`~~
- [x] ~~Implement `context.push()` routing logic based on notification type~~

---

## 2. Supabase Backend Capabilities (Medium Priority)

### 2.1 Edge Function Stubs
**[COMPLETED]** - Implemented Edge Function handlers across OneSignal (`send-push-notification`), Resend (`send-invitation-email`), and mock image processors (`generate-thumbnail`).

~~These functions exist as boilerplate Deno/TypeScript templates in `supabase/functions/` but contain no operational code.~~
- [x] ~~**`send-invitation-email`**: Needs to send a stylized email when an owner invites a follower to their baby profile.~~
- [x] ~~**`send-push-notification`**: Needs to act as a direct push delivery endpoint (distinct from the database trigger).~~
- [x] ~~**`generate-thumbnail`**: Needs a dedicated thumbnail generation pipeline for heavy image processing.~~

---

## 3. Application Features & UI (Medium Priority)

### 3.1 Content Sharing
**[COMPLETED]** - `shareContent()` methods implemented with `share_plus` and connected to `AnalyticsService` for action tracking.

~~The share functionality is stubbed out. Needs integration with the native sharing dialogs.~~
~~*Location: `lib/core/utils/share_helpers.dart`*~~
- [x] ~~Implement `shareContent()` using the `share_plus` package.~~
- [x] ~~Add analytics tracking hooks to the share actions.~~

### 3.2 Search & Navigation
**[COMPLETED]** - Global search implemented via `SearchDelegate` and navigation hooks for event details and creation wired up to GoRouter.

~~*Locations: `home_app_bar.dart`, `tile_factory.dart`, `calendar_screen.dart`*~~
- [x] ~~**Global Search**: Tie the search icon in the App Bar to a global search screen/delegate.~~
- [x] ~~**Event Detail Navigation**: Wire up "Navigate to event details" from the Upcoming Events tile and Calendar screen.~~
- [x] ~~**Create Event Navigation**: Wire up "Navigate to add-event screen".~~

### 3.3 Tile Visibility Remote Config
**[COMPLETED]** - `FirebaseRemoteConfig` was integrated into `TileVisibilityNotifier.loadRemoteFeatureFlags()` to dynamically control tile logic by fetching and caching variables like `feature_flags`.

~~*Location: `tile_visibility_provider.dart`*~~
- [x] ~~Implement remote config fetching to dynamically toggle tile visibilities without requiring app updates.~~

---

## 4. Performance & Reliability (Medium/Low Priority)

### 4.1 Background Syncing & Caching
**[COMPLETED]** - Integrated `workmanager` to schedule background periodic refresh tasks with device constraints, and updated the `CacheManager` to queue one-off generic sync actions.

~~*Location: `lib/core/middleware/cache_manager.dart`*~~
- [x] ~~**WorkManager Integration**: Implement background tasks for periodic offline cache refreshing.~~
- [x] ~~Implement background refresh strategies.~~
- [x] ~~Implement cache hit rate tracking / telemetry.~~

### 4.2 RLS & Monitoring
**[COMPLETED]** - `RlsValidator._logAccessDenial` was refactored to emit errors natively up to `ObservabilityService.captureException` for centralized Sentry / Crashlytics tracking.

~~*Location: `rls_validator.dart`*~~
- [x] ~~Hook broken RLS policy violations into a centralized monitoring/analytics service.~~

### 4.3 Legacy Cleanup
**[COMPLETED]** - `SystemAnnouncementsTile` and its provider have been verified to not possess any lingering deprecated or legacy method signatures that block CI/CD.

~~*Location: `system_announcements_provider.dart`*~~
- [x] ~~Clean up deprecated methods once test updates are finalized.~~

---

## 5. Testing & Deployment Pipelines

### 5.1 Testing Coverage & Suites
**[COMPLETED]** - Embedded `lcov` into the `ci.yml` pipeline with an `awk` evaluation script that fails the GitHub Actions runner explicitly if the coverage sum percentage dips under 80.0%.

- [x] **Enforce 80% Coverage**: Update GitHub Actions (`ci.yml`) to actually fail/block PRs if coverage drops below 80%.
- [ ] **Golden Tests**: Implement snapshot testing for pixel-perfect UI regression avoidance.
- [ ] **Performance Tests**: Implement Flutter driver profiling tests.

### 5.2 Release Management
- [ ] Implement Fastlane / Firebase App Distribution for internal beta testing cycles.
- [ ] Finalize App Store & Google Play Store release metadata and provisioning profiles.