# Navigation bar implementation steps

## Bottom Navigation Bar — Status: **Must Be Built**

The navigation bar shown in the prototype (HOME | GALLERY | CALENDAR | REGISTRY | FUN) **does not exist** anywhere in the codebase yet. Here's the evidence:

- `BottomNavigationBarItem` — **zero occurrences** in lib
- `ResponsiveScaffold` (responsive_scaffold.dart) — fully built with `bottomNavigationBar` and `navigationRail` slots, but **never instantiated** anywhere in the app
- `HomeScreen` uses a plain `Scaffold` with no `bottomNavigationBar` passed
- The router (app_router.dart) uses flat top-level `GoRoute` entries with **no `StatefulShellRoute`** — which is required for a persistent nav bar that preserves each tab's independent navigation stack

**The `BottomNavigationBarThemeData` IS already configured** in app_theme.dart (sage green selected color `AppColors.primary`, `AppColors.gray500` for unselected, `BottomNavigationBarType.fixed`) — theming will just work once the widget is wired.

---

## Architecture Decision: `StatefulShellRoute.indexedStack`

GoRouter v17 (used in this project) provides two shell options:

- `ShellRoute` — single shared navigator; pushing from Tab A into Tab B replaces Tab A's stack. **Not suitable** for a 5-tab app.
- `StatefulShellRoute.indexedStack` — each tab gets its own independent navigator and stack. Switching tabs restores where you left off. **This is the correct choice.**

Use `StatefulShellRoute.indexedStack` with 5 `StatefulShellBranch` entries, one per tab.

---

## What Needs to Be Built — Corrected Order

> **Note on ordering**: The original steps listed the router change first, but app_router.dart must reference `MainShellScreen`, which in turn requires `AppBottomNavBar`. The correct dependency order is: infrastructure → widget → shell screen → router → provider fixes → app bar redesign → tests.

---

### Step 1 — Branch Navigator Keys (infrastructure)

**File**: app_router.dart (add at top, or extract to `lib/core/router/shell_keys.dart`)

`StatefulShellRoute.indexedStack` requires a separate `GlobalKey<NavigatorState>` for each of the 5 branches. The existing `NavigationService.navigatorKey` remains the **root** navigator key and must not be reused for branches.

Define 5 branch keys:
- `_shellHomeKey`, `_shellGalleryKey`, `_shellCalendarKey`, `_shellRegistryKey`, `_shellFunKey`

These must be stable top-level `final` variables (not created inside `build()`).

---

### Step 2 — `AppBottomNavBar` widget

**New file**: `lib/core/widgets/app_bottom_nav_bar.dart`

A stateless `BottomNavigationBar` accepting `selectedIndex` and an `onTap` callback. 5 items matching the prototype:

| Index | Label | Unselected Icon | Selected Icon | Route |
|---|---|---|---|---|
| 0 | HOME | `Icons.home_outlined` | `Icons.home` | home |
| 1 | GALLERY | `Icons.photo_library_outlined` | `Icons.photo_library` | `/gallery` |
| 2 | CALENDAR | `Icons.calendar_today_outlined` | `Icons.calendar_today` | `/calendar` |
| 3 | REGISTRY | `Icons.card_giftcard_outlined` | `Icons.card_giftcard` | `/registry` |
| 4 | FUN | `Icons.auto_awesome_outlined` | `Icons.auto_awesome` | `/gamification` |

Styling is already in `AppTheme._bottomNavBarTheme` — no overrides needed. **Do not put navigation logic here** — let `MainShellScreen` call `navigationShell.goBranch(index)`.

---

### Step 3 — `MainShellScreen` shell body

**New file**: `lib/features/home/presentation/screens/main_shell_screen.dart`

The widget `StatefulShellRoute.indexedStack` renders as its builder. Receives a `StatefulNavigationShell navigationShell` from GoRouter.

Responsibilities:
- Wrap in `ResponsiveScaffold`
- Pass `AppBottomNavBar(selectedIndex: navigationShell.currentIndex, onTap: (i) => navigationShell.goBranch(i))` to `ResponsiveScaffold.bottomNavigationBar`
- Pass `AppNavigationRail` (Step 3a) to `ResponsiveScaffold.navigationRail`
- Pass `navigationShell` directly as the `body`
- **No `AppBar`** — each tab screen owns its own

#### Step 3a — `AppNavigationRail` widget (tablet support)

**New file**: `lib/core/widgets/app_navigation_rail.dart`

`ResponsiveScaffold.navigationRail` shows on tablet (≥ 600 dp). A `NavigationRail` with the same 5 destinations as `AppBottomNavBar` is needed here. Can be deferred until mobile works, but should not be left `null` permanently.

---

### Step 4 — Update app_router.dart with `StatefulShellRoute`

**File**: app_router.dart

**Routes that stay OUTSIDE the shell (top-level):**
- `/` (root redirect), `/login`, `/signup`, `/role-selection`

Auth routes **must** be outside — otherwise authenticated users would see the nav bar on the login screen.

**5 `StatefulShellBranch` entries inside the shell:**

| Branch | Root path | Sub-routes kept nested (nav bar shows) |
|---|---|---|
| 0 | home | _(none)_ |
| 1 | `/gallery` | `/gallery/photo/detail` |
| 2 | `/calendar` | `/calendar/event/detail` |
| 3 | `/registry` | `/registry/item/detail` |
| 4 | `/gamification` | _(none)_ |

**Routes that ESCAPE the shell** (`parentNavigatorKey: NavigationService.navigatorKey` — nav bar hidden):
- `/calendar/event/create` → `EventCreationScreen`
- `/registry/item/create` → `RegistryItemCreationScreen`
- `/gallery/photo/detail` → `PhotoDetailScreen` (full-screen)
- `/baby-profile`, `/baby-profile/create`, `/baby-profile/:id/edit`
- `/profile`, `/profile/edit`
- `/settings`

The shell builder: `builder: (context, state, navigationShell) => MainShellScreen(navigationShell: navigationShell)`

---

### Step 5 — Fix `GamificationScreen` dependency on route extra

**File**: gamification_screen.dart

Currently: `GamificationScreen(babyProfileId: _extraString(state, 'babyProfileId'))` — activating the FUN tab via the nav bar passes no `extra`. The screen must fall back to a `selectedBabyProfileProvider` (`StateProvider<String?>`) that holds the currently active profile ID, written when the user selects a baby profile from the home screen.

---

### Step 6 — Fix `HomeScreen` constructor params → providers

**File**: home_screen.dart

`HomeScreen` currently takes `babyProfileId`, `babyProfileName`, `userRole`, `isDualRole`, `notificationCount`, and callbacks as constructor args passed via route extras. With a persistent shell, `HomeScreen` is mounted once — these must move to providers:

- `babyProfileId` / `babyProfileName` → `selectedBabyProfileProvider`
- `userRole` / `isDualRole` → `currentUserRoleProvider` (derived from `authProvider`)
- `notificationCount` → `notificationCountProvider`
- Callbacks → replaced with `context.push(...)` calls inside the screen

---

### Step 7 — Redesign `HomeAppBar` to match the prototype

**File**: home_app_bar.dart

| Element | Current | Prototype |
|---|---|---|
| Leading | _(empty)_ | Search icon `Icons.search` |
| Title | Baby profile name + dropdown arrow | `"Nonna"` in `AppColors.primary` |
| Trailing | Notification bell + settings gear | Circular user avatar + `Icons.arrow_drop_down` |

- Title → static `"Nonna"` text in sage green
- Leading → `IconButton(Icons.search)`
- Actions → circular avatar `GestureDetector` (reads user from `authProvider`) that opens baby profile picker or navigates to `/profile`
- Remove the notification bell (move to a tile or dedicated screen)

---

### Step 8 — Tests

**New**:
- `test/core/widgets/app_bottom_nav_bar_test.dart`
- `test/features/home/presentation/screens/main_shell_screen_test.dart`

**Update**:
- router — route tree assertions break once `_routes` wraps 5 tabs in `StatefulShellRoute`
- home_screen_test.dart — `HomeScreen` no longer takes constructor params

---
