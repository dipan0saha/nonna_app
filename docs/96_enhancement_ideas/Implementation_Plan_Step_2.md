# Implementation Plan: Architectural Folder Drift Cleanup (Gap Item #2)

## Goal Description

The Nonna app codebase has accumulated three categories of empty, ghost, and misplaced directories across `lib/features/`, `lib/tiles/`, and `test/`. These directories contain zero Dart files, contribute nothing to the build, and create active risks for developers navigating the codebase. This plan documents every directory to be deleted with exact paths verified against the live filesystem, organized into four execution phases with zero risk of breaking any working code.

---

## Current State Audit

This plan was produced from a live filesystem audit using:
```bash
find lib/features lib/tiles -type d -empty | sort
find lib/features lib/tiles -type d -name "test" | sort
find lib/features/fun lib/features/photo_gallery lib/tiles/registry_deals -name "*.dart" | wc -l
```

### Gap Document vs. Reality Discrepancy

The gap document (`Current_System_Gaps.md`) understates the scope:

| Metric | Gap Doc Estimate | Actual (Audited) |
|---|---|---|
| Empty scaffold dirs (Category A) | 35 | ~78 (includes tiles) |
| Ghost top-level dirs (Category B) | 3 features + 1 tile dir | Confirmed — same |
| Misplaced `test/` dirs (Category C) | 8 (features only) | **24** (8 features + 16 tiles) |

The gap doc did not mention that `lib/tiles/*/test/` directories exist and are equally misplaced. Every tile that carries the heavy `data/datasources/local`, `data/datasources/remote`, `data/mappers`, and `models/` scaffolding also has a misplaced `test/` directory inside `lib/`. This plan covers the full actual scope.

---

## Risk Assessment

**Risk: Zero.**

All three categories of directories are entirely empty of Dart files. Because Dart's import system and Flutter's build system only operate on files, empty directories cannot be referenced by any import, cannot be discovered by `flutter test`, and cannot appear in any build artifact. Deleting them cannot break compilation, tests, or runtime behaviour.

The only required verification after deletion is:
1. `flutter analyze` — zero new errors (expected: none).
2. `flutter build apk --release` — build succeeds (expected: no change, since no files are touched).
3. `flutter test` — all tests pass (expected: no change, since none of these dirs contain test files).

---

## Open Questions

There are no open questions. The full set of paths to delete is verified from the live codebase.

---

## Architecture Decision Log

### Why Not Keep the `data/` and `domain/` Parent Directories?

The codebase follows a flat presentation-focused architecture. All DB access goes through `DatabaseService` directly from Riverpod notifiers in `presentation/providers/`. There are no Use Cases, Repositories, or Data Source classes anywhere in the codebase. Keeping the empty `data/` and `domain/` parent directories implies an architecture the project does not implement and will mislead future contributors. Deleting them leaves only the `presentation/` subtree, which accurately reflects the actual structure.

### Why Delete `lib/tiles/*/data/` and `lib/tiles/*/models/` Too?

The gap document focused only on `lib/features/`. However, the live audit confirms that 14 active tiles carry the identical empty `data/datasources/local/`, `data/datasources/remote/`, `data/mappers/`, and `models/` scaffolding. Leaving tiles untouched while cleaning features would create an inconsistent and confusing directory structure. This plan cleans both.

### Why Not Keep `lib/tiles/registry_deals/`?

`registry_deals` has zero Dart files. It is absent from `TileLoader._supportedComponentNames` and is not wired into `TileFactory.buildTile()`. Its corresponding `test/tiles/registry_deals/` is equally empty. It is an abandoned tile placeholder. If `registry_deals` is implemented in the future, it will be created fresh from the correct starting template.

### Why Delete `lib/features/fun/` and `lib/features/photo_gallery/`?

Both directories have zero Dart files across their entire subtrees. The active equivalents are:
- `lib/features/gamification/` — the working gamification/fun screen.
- `lib/features/gallery/` — the working photo gallery screen.

A developer navigating the file tree could easily create new code inside `lib/features/fun/` believing it is the active feature directory. Deleting eliminates this risk entirely.

### Why Delete `lib/features/*/test/` and `lib/tiles/*/test/`?

`flutter test` scans only the project-level `test/` directory. Any Dart file placed inside `lib/features/auth/test/` would be:
1. **Never run** by `flutter test` — it is invisible to the test runner.
2. **Compiled into the release build** — Dart source inside `lib/` is always compiled, increasing APK/IPA binary size.

All tests correctly live under `test/features/`, `test/tiles/`, and `test/core/`. The misplaced `test/` directories inside `lib/` are empty today, so deletion is risk-free, but they must be removed before a developer accidentally writes a test inside one and wonders why it never runs.

---

## Proposed Changes

All changes are pure filesystem deletions. No Dart code is modified.

---

### Phase 1 — Delete Ghost Top-Level Directories (Category B)

These are the highest-priority deletions because they present the risk of a developer accidentally working inside the wrong feature directory.

**`lib/features/fun/`** — Ghost duplicate of `lib/features/gamification/`. Contains 5 entirely empty directories, 0 Dart files:
```
lib/features/fun/
├── presentation/
│   ├── providers/   (empty)
│   ├── screens/     (empty)
│   └── widgets/     (empty)
└── test/            (empty)
```

**`lib/features/photo_gallery/`** — Ghost duplicate of `lib/features/gallery/`. Contains 5 entirely empty directories, 0 Dart files:
```
lib/features/photo_gallery/
├── presentation/
│   ├── providers/   (empty)
│   ├── screens/     (empty)
│   └── widgets/     (empty)
└── test/            (empty)
```

**`lib/tiles/registry_deals/`** — Unimplemented ghost tile. Contains 9 entirely empty directories, 0 Dart files. Not wired into `TileLoader` or `TileFactory`:
```
lib/tiles/registry_deals/
├── data/
│   ├── datasources/
│   │   ├── local/   (empty)
│   │   └── remote/  (empty)
│   └── mappers/     (empty)
├── models/          (empty)
├── providers/       (empty)
├── test/            (empty)
└── widgets/         (empty)
```

**`test/tiles/registry_deals/`** — Ghost test dir for the ghost tile. Contains 2 entirely empty directories, 0 Dart files:
```
test/tiles/registry_deals/
├── providers/       (empty)
└── widgets/         (empty)
```

**Execution command:**
```bash
rm -rf \
  lib/features/fun \
  lib/features/photo_gallery \
  lib/tiles/registry_deals \
  test/tiles/registry_deals
```

---

### Phase 2 — Delete Misplaced `test/` Directories Inside `lib/` (Category C)

Every directory listed below is empty and lives inside the source tree where `flutter test` cannot discover it.

**Inside `lib/features/`** (6 remaining after Phase 1 deletes `fun/test` and `photo_gallery/test`):
```
lib/features/auth/test/
lib/features/calendar/test/
lib/features/gallery/test/
lib/features/home/test/
lib/features/profile/test/
lib/features/registry/test/
```

**Inside `lib/tiles/`** (15 remaining after Phase 1 deletes `registry_deals/test`):
```
lib/tiles/activity_list/test/
lib/tiles/checklist/test/
lib/tiles/core/test/
lib/tiles/countdown/test/
lib/tiles/gallery_favorites/test/
lib/tiles/invites_status/test/
lib/tiles/new_followers/test/
lib/tiles/notifications/test/
lib/tiles/recent_photos/test/
lib/tiles/recent_purchases/test/
lib/tiles/registry_highlights/test/
lib/tiles/rsvp_tasks/test/
lib/tiles/storage_usage/test/
lib/tiles/system_announcements/test/
lib/tiles/upcoming_events/test/
```

**Execution command:**
```bash
rm -rf \
  lib/features/auth/test \
  lib/features/calendar/test \
  lib/features/gallery/test \
  lib/features/home/test \
  lib/features/profile/test \
  lib/features/registry/test \
  lib/tiles/activity_list/test \
  lib/tiles/checklist/test \
  lib/tiles/core/test \
  lib/tiles/countdown/test \
  lib/tiles/gallery_favorites/test \
  lib/tiles/invites_status/test \
  lib/tiles/new_followers/test \
  lib/tiles/notifications/test \
  lib/tiles/recent_photos/test \
  lib/tiles/recent_purchases/test \
  lib/tiles/registry_highlights/test \
  lib/tiles/rsvp_tasks/test \
  lib/tiles/storage_usage/test \
  lib/tiles/system_announcements/test \
  lib/tiles/upcoming_events/test
```

---

### Phase 3 — Delete Empty Scaffold Subdirectories in Active Feature Directories (Category A — Features)

These directories implement a Clean Architecture domain layer that the codebase does not use. Deleting leaves only the `presentation/` subtree in each feature, which reflects the actual architecture.

**`lib/features/auth/`** — Delete the entire `data/` and `models/` scaffold trees (7 empty dirs). Keep `presentation/`.

Empty dirs to delete:
```
lib/features/auth/data/datasources/local/
lib/features/auth/data/datasources/remote/
lib/features/auth/data/mappers/
lib/features/auth/data/models/
lib/features/auth/data/repositories/
lib/features/auth/models/entities/
lib/features/auth/models/use_cases/
```

After deleting leaf dirs, the parents `data/datasources/`, `data/`, and `models/` also become empty and should be deleted as well. The `rm -rf` on the parent handles this:

```bash
rm -rf lib/features/auth/data lib/features/auth/models
```

Result: `lib/features/auth/` contains only `presentation/providers/`, `presentation/screens/`, `presentation/widgets/`.

---

**`lib/features/profile/`** — Delete the entire `data/` and `domain/` scaffold trees (7 empty dirs). Keep `presentation/`.

Empty dirs to delete:
```
lib/features/profile/data/datasources/local/
lib/features/profile/data/datasources/remote/
lib/features/profile/data/mappers/
lib/features/profile/data/models/
lib/features/profile/data/repositories/
lib/features/profile/domain/entities/
lib/features/profile/domain/use_cases/
```

```bash
rm -rf lib/features/profile/data lib/features/profile/domain
```

Result: `lib/features/profile/` contains only `presentation/providers/`, `presentation/screens/`, `presentation/widgets/`.

---

**`lib/features/registry/`** — Delete the entire `data/` and `domain/` scaffold trees (7 empty dirs). Keep `presentation/`.

Empty dirs to delete:
```
lib/features/registry/data/datasources/local/
lib/features/registry/data/datasources/remote/
lib/features/registry/data/mappers/
lib/features/registry/data/models/
lib/features/registry/data/repositories/
lib/features/registry/domain/entities/
lib/features/registry/domain/use_cases/
```

```bash
rm -rf lib/features/registry/data lib/features/registry/domain
```

Result: `lib/features/registry/` contains only `presentation/providers/`, `presentation/screens/`, `presentation/widgets/`.

---

**Combined Phase 3 execution command:**
```bash
rm -rf \
  lib/features/auth/data \
  lib/features/auth/models \
  lib/features/profile/data \
  lib/features/profile/domain \
  lib/features/registry/data \
  lib/features/registry/domain
```

---

### Phase 4 — Delete Empty Scaffold Subdirectories Inside Active Tile Directories (Category A — Tiles)

This category is an extension of Category A not mentioned in the gap document but verified in the live audit. All listed directories are confirmed empty via `find -type d -empty`.

**14 tiles carry empty `data/datasources/`, `data/mappers/`, and/or `models/` scaffolding:**

| Tile | Empty dirs to delete |
|---|---|
| `activity_list` | `data/datasources/local`, `data/datasources/remote`, `data/mappers`, `models` |
| `checklist` | `data/datasources/local`, `data/datasources/remote`, `data/mappers`, `models` |
| `core` | `data/datasources/local`, `data/datasources/remote`, `data/repositories` |
| `countdown` | `data/datasources/local`, `data/datasources/remote`, `data/mappers`, `models` |
| `gallery_favorites` | `data/datasources/local`, `data/datasources/remote`, `data/mappers`, `models` |
| `invites_status` | `data/datasources/local`, `data/datasources/remote`, `data/mappers`, `models` |
| `new_followers` | `data/datasources/local`, `data/datasources/remote`, `data/mappers`, `models` |
| `notifications` | `data/datasources/local`, `data/datasources/remote`, `data/mappers`, `models` |
| `recent_photos` | `data/datasources/local`, `data/datasources/remote`, `data/mappers` |
| `recent_purchases` | `data/datasources/local`, `data/datasources/remote`, `data/mappers`, `models` |
| `registry_highlights` | `data/datasources/local`, `data/datasources/remote`, `data/mappers` |
| `rsvp_tasks` | `data/datasources/local`, `data/datasources/remote`, `data/mappers`, `models` |
| `storage_usage` | `data/datasources/local`, `data/datasources/remote`, `data/mappers`, `models` |
| `system_announcements` | `data/datasources/local`, `data/datasources/remote`, `data/mappers`, `models` |
| `upcoming_events` | `data/datasources/local`, `data/datasources/remote`, `data/mappers` |

**Additional:** `lib/tiles/registry_list/providers/` is an empty directory (the registry_list tile has a `widgets/` dir with files but an empty `providers/` dir — its provider logic lives elsewhere). Delete `lib/tiles/registry_list/providers/`.

**Execution command:**
```bash
rm -rf \
  lib/tiles/activity_list/data lib/tiles/activity_list/models \
  lib/tiles/checklist/data lib/tiles/checklist/models \
  lib/tiles/core/data \
  lib/tiles/countdown/data lib/tiles/countdown/models \
  lib/tiles/gallery_favorites/data lib/tiles/gallery_favorites/models \
  lib/tiles/invites_status/data lib/tiles/invites_status/models \
  lib/tiles/new_followers/data lib/tiles/new_followers/models \
  lib/tiles/notifications/data lib/tiles/notifications/models \
  lib/tiles/recent_photos/data \
  lib/tiles/recent_purchases/data lib/tiles/recent_purchases/models \
  lib/tiles/registry_highlights/data \
  lib/tiles/rsvp_tasks/data lib/tiles/rsvp_tasks/models \
  lib/tiles/storage_usage/data lib/tiles/storage_usage/models \
  lib/tiles/system_announcements/data lib/tiles/system_announcements/models \
  lib/tiles/upcoming_events/data \
  lib/tiles/registry_list/providers
```

---

## Files Changed Summary

| Category | Paths Deleted | Dir Count |
|---|---|---|
| B — Ghost feature dirs | `lib/features/fun/`, `lib/features/photo_gallery/` | 10 |
| B — Ghost tile dir | `lib/tiles/registry_deals/`, `test/tiles/registry_deals/` | 11 |
| C — Misplaced feature test dirs | `lib/features/{auth,calendar,gallery,home,profile,registry}/test/` | 6 |
| C — Misplaced tile test dirs | `lib/tiles/{15 tiles}/test/` | 15 |
| A — Empty feature scaffold | `lib/features/{auth,profile,registry}/data/`, `domain/`, `models/` | 21 |
| A — Empty tile scaffold | `lib/tiles/{15 tiles}/data/`, `models/`, `lib/tiles/registry_list/providers/` | ~58 |
| **Total** | | **~121 directories** |

No Dart files are modified or deleted. No test files are moved. No imports change.

---

## One-Shot Execution Script

All four phases can be executed in sequence as a single shell script. Each group is annotated for review before running:

```bash
#!/usr/bin/env bash
# Gap #2 Architectural Drift Cleanup
# Run from the nonna_app repo root.
# Safe to run multiple times (rm -rf on non-existent path is a no-op).

set -e

echo "Phase 1: Deleting ghost top-level directories..."
rm -rf \
  lib/features/fun \
  lib/features/photo_gallery \
  lib/tiles/registry_deals \
  test/tiles/registry_deals

echo "Phase 2: Deleting misplaced test/ directories inside lib/..."
rm -rf \
  lib/features/auth/test \
  lib/features/calendar/test \
  lib/features/gallery/test \
  lib/features/home/test \
  lib/features/profile/test \
  lib/features/registry/test \
  lib/tiles/activity_list/test \
  lib/tiles/checklist/test \
  lib/tiles/core/test \
  lib/tiles/countdown/test \
  lib/tiles/gallery_favorites/test \
  lib/tiles/invites_status/test \
  lib/tiles/new_followers/test \
  lib/tiles/notifications/test \
  lib/tiles/recent_photos/test \
  lib/tiles/recent_purchases/test \
  lib/tiles/registry_highlights/test \
  lib/tiles/rsvp_tasks/test \
  lib/tiles/storage_usage/test \
  lib/tiles/system_announcements/test \
  lib/tiles/upcoming_events/test

echo "Phase 3: Deleting empty data/domain scaffold in active feature directories..."
rm -rf \
  lib/features/auth/data \
  lib/features/auth/models \
  lib/features/profile/data \
  lib/features/profile/domain \
  lib/features/registry/data \
  lib/features/registry/domain

echo "Phase 4: Deleting empty data/models scaffold in active tile directories..."
rm -rf \
  lib/tiles/activity_list/data lib/tiles/activity_list/models \
  lib/tiles/checklist/data lib/tiles/checklist/models \
  lib/tiles/core/data \
  lib/tiles/countdown/data lib/tiles/countdown/models \
  lib/tiles/gallery_favorites/data lib/tiles/gallery_favorites/models \
  lib/tiles/invites_status/data lib/tiles/invites_status/models \
  lib/tiles/new_followers/data lib/tiles/new_followers/models \
  lib/tiles/notifications/data lib/tiles/notifications/models \
  lib/tiles/recent_photos/data \
  lib/tiles/recent_purchases/data lib/tiles/recent_purchases/models \
  lib/tiles/registry_highlights/data \
  lib/tiles/rsvp_tasks/data lib/tiles/rsvp_tasks/models \
  lib/tiles/storage_usage/data lib/tiles/storage_usage/models \
  lib/tiles/system_announcements/data lib/tiles/system_announcements/models \
  lib/tiles/upcoming_events/data \
  lib/tiles/registry_list/providers

echo "Done. Run: flutter analyze && flutter test"
```

---

## Verification Steps

Run in order immediately after executing the script:

1. **Confirm no empty directories remain inside `lib/`**:
   ```bash
   find lib -type d -empty | sort
   ```
   Expected output: empty (no lines).

2. **Confirm no `test/` directories remain inside `lib/`**:
   ```bash
   find lib -type d -name "test"
   ```
   Expected output: empty (no lines).

3. **Confirm ghost feature dirs are gone**:
   ```bash
   ls lib/features/
   ```
   Expected: `auth  baby_profile  calendar  gallery  gamification  home  profile  registry  settings` — no `fun` or `photo_gallery`.

4. **Confirm ghost tile dir is gone**:
   ```bash
   ls lib/tiles/
   ```
   Expected: no `registry_deals`.

5. **Confirm ghost test tile dir is gone**:
   ```bash
   ls test/tiles/
   ```
   Expected: no `registry_deals`.

6. **`flutter analyze`** — zero new errors or warnings introduced.

7. **`flutter test`** — all tests pass, no regressions.

8. **`flutter build apk --release`** — build succeeds.

---

## Scope: Included vs. Excluded

| Included | Excluded |
|---|---|
| All empty Category A scaffold dirs in `lib/features/` | Creating tests for the 4 untested tiles (Gap #3) |
| All empty Category A scaffold dirs in `lib/tiles/` (extends gap doc scope) | Moving any tests from `lib/` to `test/` — there are none to move |
| Ghost feature dirs `fun/` and `photo_gallery/` | Implementation of the `registry_deals` tile (a separate future task) |
| Ghost tile dir `registry_deals/` and its test dir | Changes to `TileLoader` or `TileFactory` |
| All 21 misplaced `test/` dirs in features and tiles | Changes to any Dart source files |
| `lib/tiles/registry_list/providers/` (empty, unneeded) | Reorganizing `gamification/` or `gallery/` internals |
| `test/tiles/registry_deals/` (ghost test dir) | Cleaning up any other test infrastructure |
