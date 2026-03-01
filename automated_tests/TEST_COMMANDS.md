# Nonna App Unit Tests - Run Commands

## Test Organization Summary

**Total: 190 unit tests**

| Category | Count | Passed | Failed | Status |
|----------|-------|--------|--------|--------|
| test/accessibility | 1 | 24 | 0 | ✅ Pass |
| test/core | 108 | 2637 | 11 | ⚠️ 11 Failed |
| test/features | 37 | 377 | 36 | ⚠️ 36 Failed |
| test/l10n | 1 | 25 | 0 | ✅ Pass |
| test/tiles | 35 | 523 | 44 | ⚠️ 44 Failed |
| **TOTAL** | **190** | **3586** | **91** | **91 Failed** |

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
|-------------|-------|--------|--------|---------|
| Config | 1 | 51 | 0 | `flutter test test/core/config` |
| Constants | 4 | 66 | 0 | `flutter test test/core/constants` |
| Dependency Injection | 2 | 42 | 0 | `flutter test test/core/di` |
| Enums | 10 | 163 | 0 | `flutter test test/core/enums` |
| Extensions | 4 | 208 | 0 | `flutter test test/core/extensions` |
| Middleware | 3 | 71 | 0 | `flutter test test/core/middleware` |
| Mixins | 3 | 119 | 0 | `flutter test test/core/mixins` |
| Models | 22 | 361 | 0 | `flutter test test/core/models` |
| Navigation | 1 | 6 | 0 | `flutter test test/core/navigation` |
| Network | 6 | 88 | 0 | `flutter test test/core/network` |
| Providers | 2 | 83 | 0 | `flutter test test/core/providers` |
| Router | 2 | 30 | 0 | `flutter test test/core/router` |
| Services | 21 | 260 | 5 | `flutter test test/core/services` |
| Themes | 4 | 156 | 0 | `flutter test test/core/themes` |
| Utils | 13 | 500 | 1 | `flutter test test/core/utils` |
| Widgets | 10 | 154 | 5 | `flutter test test/core/widgets` |

---

## Features Tests (37 files)

Organized by 9 features:

| Feature | Count | Passed | Failed | Command |
|---------|-------|--------|--------|---------|
| Auth | 6 | 85 | 14 | `flutter test test/features/auth/presentation` |
| Baby Profile | 7 | 72 | 0 | `flutter test test/features/baby_profile/presentation` |
| Calendar | 5 | 40 | 17 | `flutter test test/features/calendar/presentation` |
| Gallery | 4 | 36 | 4 | `flutter test test/features/gallery/presentation` |
| Gamification | 1 | 6 | 0 | `flutter test test/features/gamification/presentation` |
| Home | 4 | 39 | 0 | `flutter test test/features/home/presentation` |
| Profile | 4 | 45 | 0 | `flutter test test/features/profile/presentation` |
| Registry | 5 | 46 | 1 | `flutter test test/features/registry/presentation` |
| Settings | 1 | 8 | 0 | `flutter test test/features/settings/presentation` |

---

## Localization Tests

| Group | File Count | Passed | Failed | Command |
|-------|-----------|--------|--------|---------|
| L10n | 1 | 25 | 0 | `flutter test test/l10n` |

---

## Tiles Tests (35 files)

Organized by 16 tile types:

| Tile Type | Count | Passed | Failed | Command |
|-----------|-------|--------|--------|---------|
| Core | 5 | 88 | 1 | `flutter test test/tiles/core` |
| Checklist | 2 | 30 | 0 | `flutter test test/tiles/checklist` |
| Due Date Countdown | 2 | 25 | 0 | `flutter test test/tiles/due_date_countdown` |
| Engagement Recap | 2 | 19 | 0 | `flutter test test/tiles/engagement_recap` |
| Gallery Favorites | 2 | 14 | 0 | `flutter test test/tiles/gallery_favorites` |
| Invites Status | 2 | 29 | 0 | `flutter test test/tiles/invites_status` |
| New Followers | 2 | 25 | 7 | `flutter test test/tiles/new_followers` |
| Notifications | 2 | 29 | 0 | `flutter test test/tiles/notifications` |
| Recent Photos | 2 | 27 | 3 | `flutter test test/tiles/recent_photos` |
| Recent Purchases | 2 | 19 | 7 | `flutter test test/tiles/recent_purchases` |
| Registry Deals | 2 | 26 | 3 | `flutter test test/tiles/registry_deals` |
| Registry Highlights | 2 | 25 | 1 | `flutter test test/tiles/registry_highlights` |
| RSVP Tasks | 2 | 27 | 0 | `flutter test test/tiles/rsvp_tasks` |
| Storage Usage | 2 | 29 | 0 | `flutter test test/tiles/storage_usage` |
| System Announcements | 2 | 28 | 0 | `flutter test test/tiles/system_announcements` |
| Upcoming Events | 2 | 28 | 2 | `flutter test test/tiles/upcoming_events` |

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

Generated: February 28, 2026
Total Test Files: 190
