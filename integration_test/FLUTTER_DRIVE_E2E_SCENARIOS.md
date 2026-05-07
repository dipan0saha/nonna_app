# Nonna App Flutter Drive E2E Scenarios

## Purpose
This document defines production-grade end-to-end scenarios for Flutter drive/integration tests, based on the current Nonna architecture:
- Dynamic tile engine (edge-first tile-configs + DB fallback)
- Riverpod state + profile/role-driven reloads
- GoRouter auth guards + 5-tab shell navigation
- Owner/follower behavior and profile-scoped data

## Source Alignment
These scenarios are aligned to current code and master docs, including:
- docs/99_master_reference_docs/Nonna_Project_Understanding.md
- docs/99_master_reference_docs/Database_Schema_and_Functions.md
- docs/99_master_reference_docs/Nonna_Architecture_and_Workflow_Reference.md
- lib/main.dart
- lib/core/router/app_router.dart
- lib/core/utils/tile_loader.dart
- lib/core/utils/tile_factory.dart
- lib/features/home/presentation/screens/home_screen.dart

## Test Account
Use this account for login in all primary scenarios:
- Email: testuser_nonna@example.com
- Password: Password123!

## Execution Mode
You can run these using either style:

1) Integration-style (recommended for current repo setup)
- flutter test integration_test/fd_app_test.dart -d <device_id>

2) Drive-style target execution
- flutter drive --driver=test_driver/fd_integration_driver.dart --target=integration_test/fd_app_test.dart

## Flutter Drive File Prefix
All newly created flutter drive/integration scenario files use this prefix:
- fd_

Implemented files:
- integration_test/fd_app_test.dart
- integration_test/fd_00_auth_navigation_test.dart
- integration_test/fd_01_profile_followers_test.dart
- integration_test/fd_02_feature_flows_test.dart
- integration_test/fd_03_settings_logout_test.dart
- integration_test/fd_04_gallery_notifications_test.dart
- integration_test/fd_05_context_constraints_test.dart
- integration_test/fd_scenario_utils.dart
- test_driver/fd_integration_driver.dart

## Critical Notes Before Automating
1. Tile visibility is dynamic. The tile-configs edge function can hide tiles when data is empty.
2. Some checks are conditional based on role and data (owner-only FABs/actions).
3. Prefer Key-based selectors whenever available.
4. Where keys are unavailable, use text selectors with stable labels.
5. Keep tests idempotent by using unique suffixes for created records.

## Global Test Data Strategy
Use a run id in created entities to avoid collisions:
- runId format: e2e_<yyyyMMdd_HHmmss>
- Example event title: E2E Event e2e_20260506_201500
- Example profile name: E2E Baby e2e_20260506_201500

## Suggested File Split
Map scenarios to your existing integration files:
- integration_test/auth_integration_test.dart
- integration_test/baby_profile_integration_test.dart
- integration_test/dashboard_integration_test.dart
- integration_test/gallery_integration_test.dart
- integration_test/events_integration_test.dart
- integration_test/registry_integration_test.dart
- integration_test/gamification_integration_test.dart
- integration_test/notifications_integration_test.dart

## Scenario Matrix

| ID | Priority | Area | Summary |
|---|---|---|---|
| E2E-001 | P0 | Auth | Cold launch route guard to Sign In when unauthenticated |
| E2E-002 | P0 | Auth | Login with provided credentials and land on Home |
| E2E-003 | P0 | Navigation | 5-tab shell navigation and state persistence |
| E2E-004 | P0 | Home/Profile Context | Baby profile selection reloads tile list |
| E2E-005 | P0 | Baby Profile | Create baby profile from Home and auto-select |
| E2E-006 | P0 | Followers | Owner opens follower management and sends invite |
| E2E-007 | P0 | Gallery | Owner uploads photo and sees success |
| E2E-008 | P0 | Photo Detail | Squish + comment create/edit/delete flow |
| E2E-009 | P0 | Calendar | Owner creates event and opens event detail |
| E2E-010 | P0 | Registry | Owner creates item and toggles purchase |
| E2E-011 | P0 | Gamification | Name suggestion and prediction vote flow |
| E2E-012 | P0 | Logout | Logout from profile and redirect to Sign In |
| E2E-013 | P1 | Session | Re-login and verify persisted artifacts |
| E2E-014 | P1 | Settings | Toggle dark mode + language change UI |
| E2E-015 | P1 | Announcements | Dismiss system announcement tile item |
| E2E-016 | P1 | Invites Tile | Validate pending invite appears and revoke works |
| E2E-017 | P1 | Gallery Nav | Recent/Favorites view-all navigation |
| E2E-018 | P1 | Calendar Nav | Upcoming view-all and event card navigation |
| E2E-019 | P1 | Registry Nav | Registry detail and edit (owner only if not purchased) |
| E2E-020 | P2 | Empty/Error States | No-profile empty states and retry flows |
| E2E-021 | P2 | Pull to Refresh | Refresh indicators on Home/Calendar/Registry |
| E2E-022 | P2 | Follower Constraints | Verify owner-only actions absent in follower context |

---

## Detailed Scenarios

### E2E-001 (P0) Cold Launch Auth Guard
Preconditions:
- No active session (signed out)

Steps:
1. Launch app.
2. Wait for initialization to complete.

Assertions:
1. Sign in form is visible.
2. auth_email_field exists.
3. sign_in_button exists.

Selectors:
- auth_email_field
- auth_password_field
- sign_in_button

### E2E-002 (P0) Login With Provided Credentials
Preconditions:
- On Sign In screen

Steps:
1. Enter email testuser_nonna@example.com.
2. Enter password Password123!.
3. Tap sign_in_button.
4. Wait for navigation.

Assertions:
1. home_app_bar is visible.
2. tile_list_view appears (or home empty-state CTA if no profile).

Selectors:
- auth_email_field
- auth_password_field
- sign_in_button
- home_app_bar
- tile_list_view

### E2E-003 (P0) 5-Tab Shell Navigation
Preconditions:
- Logged in

Steps:
1. Verify app_bottom_nav_bar exists.
2. Tap tabs in order: Home, Gallery, Calendar, Registry, Fun.
3. Return to Home.

Assertions:
1. Each destination screen root appears:
- Gallery AppBar title Gallery
- Calendar AppBar title Calendar
- Registry AppBar title Registry
- Gamification screen key gamification_screen
2. No crash or stuck loading state.

Selectors:
- app_bottom_nav_bar
- gamification_screen

### E2E-004 (P0) Profile Selection Reloads Home Tiles
Preconditions:
- Logged in
- User has at least 2 baby profiles (if not, mark conditional)

Steps:
1. On Home, open profile dropdown in title.
2. Select a different profile.
3. Wait for tile reload.

Assertions:
1. tile_list_view refreshes without error.
2. Home title changes to selected profile name.

Selectors:
- home_app_bar
- tile_list_view

### E2E-005 (P0) Create Baby Profile And Auto-Switch
Preconditions:
- Logged in

Steps:
1. From Home app bar, tap create profile icon.
2. Verify create_baby_profile_screen.
3. Enter unique baby name with run id.
4. Optionally choose gender/date.
5. Tap Create.

Assertions:
1. Success snackbar appears.
2. Returns to Home.
3. New profile is selected in app bar dropdown.
4. Tiles load for new profile context.

Selectors:
- create_baby_profile_screen
- tile_list_view

### E2E-006 (P0) Follower Management And Invite
Preconditions:
- Logged in as owner for selected profile

Steps:
1. Tap app bar action Invite & Manage Followers.
2. Verify followers_management_screen.
3. Tap invite_follower_button.
4. Verify invite_followers_screen.
5. Enter unique email in invite_email_field.
6. Tap send_invite_button.

Assertions:
1. invite_success_message appears.
2. Navigate back to management screen.
3. Pending invitation row appears.

Selectors:
- followers_management_screen
- invite_follower_button
- invite_followers_screen
- invite_email_field
- send_invite_button
- invite_success_message

### E2E-007 (P0) Owner Upload Photo
Preconditions:
- Logged in
- Selected profile role is owner
- Device/test environment can provide an image for picker

Steps:
1. Go to Gallery tab.
2. Tap upload_photo_fab.
3. Pick image.
4. In caption dialog, enter text and confirm Upload.

Assertions:
1. SnackBar shows upload success.
2. New photo appears in recent photos/favorites flows after refresh.

Selectors:
- upload_photo_fab
- photo_item_<id> (dynamic)

### E2E-008 (P0) Photo Detail Social Interactions
Preconditions:
- At least one photo available

Steps:
1. Open a photo from Recent Photos tile or Gallery list.
2. Verify photo_detail_image.
3. Tap squish_button.
4. Add comment via input + send icon.
5. Edit own comment.
6. Delete comment and confirm.

Assertions:
1. Squish count/state updates.
2. Comment appears after create.
3. Comment body updates after edit.
4. Comment removed after delete.

Selectors:
- photo_detail_image
- squish_button
- edit_caption_button (owner conditional)

### E2E-009 (P0) Calendar Event Creation And Detail
Preconditions:
- Logged in as owner for selected profile

Steps:
1. Go to Calendar tab.
2. Tap add_event_fab.
3. Verify event_creation_screen.
4. Fill event_title_field, optional description/location.
5. Tap save_event_button.
6. Tap created event card to open details.

Assertions:
1. Event appears on selected date.
2. event_detail_screen opens.
3. event_title_text matches created title.

Selectors:
- add_event_fab
- event_creation_screen
- event_title_field
- save_event_button
- event_detail_screen
- event_title_text

### E2E-010 (P0) Registry Item Lifecycle
Preconditions:
- Logged in
- Selected profile role is owner

Steps:
1. Go to Registry tab.
2. Tap add_registry_item_fab.
3. Verify registry_item_creation_screen.
4. Enter item_name_field and optional values.
5. Tap save_item_button.
6. Open item detail.
7. Tap purchase_button.
8. If purchased by same user, tap Unmark as Purchased.

Assertions:
1. Item appears in registry list tile.
2. purchase_status_row changes as expected.
3. Purchase/unpurchase state is consistent after refresh.

Selectors:
- add_registry_item_fab
- registry_item_creation_screen
- item_name_field
- save_item_button
- purchase_button
- purchase_status_row

### E2E-011 (P0) Gamification End-To-End
Preconditions:
- Logged in
- Selected profile available

Steps:
1. Go to Fun tab.
2. In Name Suggestions tile, open form and submit a unique name.
3. Like the newly created suggestion.
4. In Prediction Votes tile, vote gender.
5. Tap vote_birthdate_button and pick a date.

Assertions:
1. New suggestion row appears.
2. Like state toggles.
3. Gender vote selection is retained.
4. Birthdate vote shows chosen date.

Selectors:
- gamification_screen
- name_suggestions_tile
- add_name_suggestion_button
- name_suggestion_text_field
- submit_name_suggestion_button
- prediction_votes_tile
- vote_birthdate_button

### E2E-012 (P0) Logout From Profile
Preconditions:
- Logged in

Steps:
1. Tap profile_avatar_button on Home app bar.
2. In Profile screen, tap Logout.

Assertions:
1. Redirect to Sign In screen.
2. sign_in_button visible.

Selectors:
- profile_avatar_button
- profile_screen
- profile_settings_item_Logout (dynamic key pattern)
- sign_in_button

### E2E-013 (P1) Re-Login And Verify Persisted Artifacts
Preconditions:
- Completed at least one content-creation scenario

Steps:
1. Log in again with test credentials.
2. Navigate to feature where data was created.

Assertions:
1. Recently created event/item/suggestion/photo still visible.

Selectors:
- Same as corresponding feature scenario

### E2E-014 (P1) Settings Preferences
Preconditions:
- Logged in

Steps:
1. Open Profile, then Settings.
2. Toggle dark_mode_toggle.
3. Open language_tile and choose language_option_es (or en).
4. Return to app shell.

Assertions:
1. Theme changes immediately.
2. Language setting updates displayed label in settings.

Selectors:
- settings_screen
- dark_mode_toggle
- language_tile
- language_option_es

### E2E-015 (P1) System Announcements Dismiss
Preconditions:
- At least one active announcement

Steps:
1. On Home, locate system_announcements_tile.
2. Tap dismiss_<announcementId> for first item.

Assertions:
1. Announcement row disappears.
2. If all dismissed, tile may disappear entirely (expected).

Selectors:
- system_announcements_tile
- announcement_<id>
- dismiss_<id>

### E2E-016 (P1) Invite Status Tile Revoke
Preconditions:
- Pending invitation exists for selected profile

Steps:
1. On Home, locate invites_status_tile.
2. Tap revoke_button_<invitationId>.

Assertions:
1. Invitation status updates or item disappears from pending list.

Selectors:
- invites_status_tile
- invitation_item_<id>
- revoke_button_<id>

### E2E-017 (P1) Gallery View-All Navigation
Preconditions:
- Recent/Favorites tiles available

Steps:
1. From Home tile, tap recent_photos_view_all and/or gallery_favorites_view_all.
2. Validate route transitions to gallery recent/favorites screen variant.

Assertions:
1. Correct Gallery variant title and content load.

Selectors:
- recent_photos_view_all
- gallery_favorites_view_all

### E2E-018 (P1) Upcoming Events View-All And Card Navigation
Preconditions:
- Upcoming events tile visible with at least one event

Steps:
1. Tap upcoming_events_view_all.
2. Tap event_card_<id>.

Assertions:
1. Calendar upcoming screen opens.
2. Event detail opens from card tap.

Selectors:
- upcoming_events_view_all
- event_card_<id>
- event_detail_screen

### E2E-019 (P1) Registry Detail And Edit Path
Preconditions:
- At least one unpurchased registry item owned by current owner

Steps:
1. Open registry item detail.
2. Tap edit_item_button.
3. Save changes.

Assertions:
1. Edited fields persist and display correctly.

Selectors:
- edit_item_button
- purchase_status_row

### E2E-020 (P2) Empty/Error State Coverage
Preconditions:
- Use controlled test profile with minimal data

Steps:
1. Switch to profile with no content.
2. Visit Home/Gallery/Calendar/Registry/Fun.

Assertions:
1. Empty states render gracefully.
2. No crashes when tiles are hidden by empty-data policy.

Selectors:
- tile_list_view
- no_followers_empty_state

### E2E-021 (P2) Pull-To-Refresh Coverage
Preconditions:
- Logged in and data visible

Steps:
1. Pull-to-refresh on Home tile list.
2. Pull-to-refresh on Calendar.
3. Pull-to-refresh on Registry.

Assertions:
1. Refresh completes without errors.
2. Lists remain consistent.

Selectors:
- tile_list_refresh_indicator

### E2E-022 (P2) Follower Role Constraint Checks
Preconditions:
- Profile context where current user is follower (or dedicated follower account)

Steps:
1. Switch to follower context profile.
2. Visit Gallery/Calendar/Registry.

Assertions:
1. upload_photo_fab is absent.
2. add_event_fab is absent.
3. add_registry_item_fab is absent.
4. Owner-only follower management action is absent from Home app bar.

Selectors:
- upload_photo_fab
- add_event_fab
- add_registry_item_fab

---

## Recommended Execution Order
1. E2E-001 to E2E-003
2. E2E-005 (ensures controllable owner profile)
3. E2E-006, E2E-007, E2E-009, E2E-010, E2E-011
4. E2E-008 (depends on photos)
5. E2E-015, E2E-016, E2E-017, E2E-018, E2E-019
6. E2E-014, E2E-020, E2E-021, E2E-022
7. E2E-012 and E2E-013 at end

## Existing Helper Update Recommendation
Your current integration helper uses different credentials. Update test helper login defaults to:
- Email: testuser_nonna@example.com
- Password: Password123!

This should be changed in integration_test/test_helper.dart before implementing the full suite.

## Pass/Fail Rule
A scenario passes only if:
1. Primary assertions pass.
2. No uncaught Flutter exception occurs.
3. Route remains responsive after scenario completion.
4. Cleanup or idempotency strategy is preserved for reruns.
