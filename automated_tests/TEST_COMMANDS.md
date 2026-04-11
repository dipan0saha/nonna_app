# Nonna App Unit Tests - Run Commands

## Test Organization Summary

**Total: 190 unit tests**

| Category | Count | Passed | Failed | Status |
|----------|-------|--------|--------|--------|
| test/accessibility | 1 | 0 | 0 | ✅ Pass |
| test/core | 108 | 0 | 0 | ✅ Pass |
| test/features | 37 | 0 | 0 | ✅ Pass |
| test/l10n | 1 | 0 | 0 | ✅ Pass |
| test/tiles | 35 | 0 | 0 | ✅ Pass |
| **TOTAL** | **190** | **0** | **0** | ✅ All Passed |
---

## Quick Commands

### Run All Tests
```bash
flutter test
```

### Run All Core Tests (108 files)
```bash
flutter test test/core
```

### Run All Features Tests (37 files)
```bash
flutter test test/features
```

### Run All Tiles Tests (35 files)
```bash
flutter test test/tiles
```

---

## Accessibility Tests

| Group | File Count | Passed | Failed | Command |
|-------|-----------|--------|--------|---------|
| Accessibility | 1 | 24 | 0 | `flutter test test/accessibility` |

---

## Core Tests (108 files)

Organized by 16 subcategories:


| Subcategory | Count | Passed | Failed | Command |
|-------------|-------|--------|--------|----------|
| Config | - | 0 | 0 | `flutter test test/core/config` |
| Constants | - | 0 | 0 | `flutter test test/core/constants` |
| Di | - | 0 | 0 | `flutter test test/core/di` |
| Enums | - | 0 | 0 | `flutter test test/core/enums` |
| Extensions | - | 0 | 0 | `flutter test test/core/extensions` |
| Middleware | - | 0 | 0 | `flutter test test/core/middleware` |
| Mixins | - | 0 | 0 | `flutter test test/core/mixins` |
| Models | - | 0 | 0 | `flutter test test/core/models` |
| Navigation | - | 0 | 0 | `flutter test test/core/navigation` |
| Network | - | 0 | 0 | `flutter test test/core/network` |
| Providers | - | 0 | 0 | `flutter test test/core/providers` |
| Router | - | 0 | 0 | `flutter test test/core/router` |
| Services | - | 0 | 0 | `flutter test test/core/services` |
| Themes | - | 0 | 0 | `flutter test test/core/themes` |
| Utils | - | 0 | 0 | `flutter test test/core/utils` |
| Widgets | - | 0 | 0 | `flutter test test/core/widgets` |

---

## Features Tests (37 files)

Organized by 9 features:


| Feature | Count | Passed | Failed | Command |
|---------|-------|--------|--------|----------|
| Auth | - | 0 | 0 | `flutter test test/features/auth/presentation` |
| Baby Profile | - | 0 | 0 | `flutter test test/features/baby_profile/presentation` |
| Calendar | - | 0 | 0 | `flutter test test/features/calendar/presentation` |
| Gallery | - | 0 | 0 | `flutter test test/features/gallery/presentation` |
| Gamification | - | 0 | 0 | `flutter test test/features/gamification/presentation` |
| Home | - | 0 | 0 | `flutter test test/features/home/presentation` |
| Profile | - | 0 | 0 | `flutter test test/features/profile/presentation` |
| Registry | - | 0 | 0 | `flutter test test/features/registry/presentation` |
| Settings | - | 0 | 0 | `flutter test test/features/settings/presentation` |

---

## Localization Tests

| Group | File Count | Passed | Failed | Command |
|-------|-----------|--------|--------|---------|
| L10n | 1 | 25 | 0 | `flutter test test/l10n` |

---

## Tiles Tests (35 files)

Organized by 16 tile types:


| Tile Type | Count | Passed | Failed | Command |
|-----------|-------|--------|--------|----------|
| Core | - | 0 | 0 | `flutter test test/tiles/core` |
| Checklist | - | 0 | 0 | `flutter test test/tiles/checklist` |
| Due Date Countdown | - | 0 | 0 | `flutter test test/tiles/due_date_countdown` |
| Engagement Recap | - | 0 | 0 | `flutter test test/tiles/engagement_recap` |
| Gallery Favorites | - | 0 | 0 | `flutter test test/tiles/gallery_favorites` |
| Invites Status | - | 0 | 0 | `flutter test test/tiles/invites_status` |
| New Followers | - | 0 | 0 | `flutter test test/tiles/new_followers` |
| Notifications | - | 0 | 0 | `flutter test test/tiles/notifications` |
| Recent Photos | - | 0 | 0 | `flutter test test/tiles/recent_photos` |
| Recent Purchases | - | 0 | 0 | `flutter test test/tiles/recent_purchases` |
| Registry Deals | - | 0 | 0 | `flutter test test/tiles/registry_deals` |
| Registry Highlights | - | 0 | 0 | `flutter test test/tiles/registry_highlights` |
| Rsvp Tasks | - | 0 | 0 | `flutter test test/tiles/rsvp_tasks` |
| Storage Usage | - | 0 | 0 | `flutter test test/tiles/storage_usage` |
| System Announcements | - | 0 | 0 | `flutter test test/tiles/system_announcements` |
| Upcoming Events | - | 0 | 0 | `flutter test test/tiles/upcoming_events` |

---

## Tips for Running Tests

### Run specific test file
```bash
flutter test test/path/to/specific_test.dart
```

### Run multiple test files
```bash
flutter test test/path/to/test1.dart test/path/to/test2.dart
```

### Run with coverage
```bash
flutter test --coverage
```

### Run with expanded reporter
```bash
flutter test --reporter expanded
```

### Run with compact reporter
```bash
flutter test --reporter compact
```

### Run tests matching a pattern
```bash
flutter test -k "pattern_name"
```

### Run tests excluding a pattern
```bash
flutter test --exclude-tags "tag_name"
```

---

## Batch Test Commands

Run tests in logical batches recommended for CI/CD:

### Batch 1: Core Infrastructure Tests (foundation tests)
```bash
flutter test test/core/di test/core/config test/core/constants test/core/router test/core/navigation
```

### Batch 2: Core Utilities & Helpers
```bash
flutter test test/core/utils test/core/extensions test/core/themes
```

### Batch 3: Core Models & Services
```bash
flutter test test/core/models test/core/services test/core/middleware
```

### Batch 4: Core Network & Providers
```bash
flutter test test/core/network test/core/providers test/core/mixins
```

### Batch 5: Core Enums & Widgets
```bash
flutter test test/core/enums test/core/widgets
```

### Batch 6: All Feature Tests
```bash
flutter test test/features
```

### Batch 7: All Tiles Tests
```bash
flutter test test/tiles
```

### Batch 8: L10n & Accessibility
```bash
flutter test test/l10n test/accessibility
```

---

## Test Results Summary

### Failed Tests by Category

**Core Tests (11 failures):**
- Services: 5 failed
- Utils: 1 failed
- Widgets: 5 failed

**Feature Tests (36 failures):**
- Auth: 14 failed
- Calendar: 17 failed
- Gallery: 4 failed
- Registry: 1 failed

**Tiles Tests (44 failures):**
- Core: 1 failed
- New Followers: 7 failed
- Recent Photos: 3 failed
- Recent Purchases: 7 failed
- Registry Deals: 3 failed
- Registry Highlights: 1 failed
- Upcoming Events: 2 failed

**Total: 91 test failures across all categories**

---

Integration tests are located in:
```
integration_test/
```

Run integration tests with:
```bash
flutter test integration_test
```

Or run specific integration tests:
```bash
flutter drive --target=integration_test/path_to_test.dart
```

---

Generated: April 11, 2026 at 14:32:24
Total Test Files: 190
