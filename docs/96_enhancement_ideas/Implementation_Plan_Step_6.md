# Implementation Plan: Cellular Network Reconnection & Offline Indicator (Gap Item #6)

## Goal Description

The Nonna app uses Supabase Realtime for live data and Hive-cached tile configs with a 30-minute TTL. When a user loses cellular connectivity (e.g., enters an elevator) and regains it, the app continues showing stale data silently. The RealtimeService socket may have dropped during the outage, and there is no mechanism to detect the network transition and re-fetch data. The user must manually pull to refresh.

This plan details the steps to:
1. Add the `connectivity_plus` package for native connectivity state detection.
2. Create a `NetworkStatusNotifier` Riverpod provider that owns the connectivity subscription, tracks online/offline transitions, and automatically triggers a forced data refresh via `homeScreenProvider.notifier.refresh()` and `SyncManager.forceFullSync()` when the network comes back.
3. Create a `syncManagerProvider` to give `SyncManager` (already fully implemented but unused) a proper Riverpod lifecycle.
4. Wire the existing `OfflineIndicator` widget (already built but unused) into the home screen so users see a banner when offline with a manual Retry button.

### What Already Exists — Zero Changes Needed

| Asset | Location | Status |
|---|---|---|
| `SyncManager` — `forceFullSync()`, delta-sync, retry, background timer | `lib/core/services/sync_manager.dart` | Fully implemented; never called |
| `OfflineIndicator` + `StreamOfflineIndicator` widgets | `lib/core/widgets/offline_indicator.dart` | Fully implemented; never used in any screen |
| `homeScreenProvider.notifier.refresh()` | `lib/features/home/presentation/providers/home_screen_provider.dart` | Calls `TileLoader.loadForScreen(forceRefresh: true)` |
| `realtimeServiceProvider` | `lib/core/di/providers.dart` | Existing provider for `RealtimeService` |

---

## User Review Required

No database schema changes. No breaking changes to existing APIs.

**IMPORTANT**: `homeScreenProvider` is `NotifierProvider.autoDispose`. The reconnect watcher (`NetworkStatusNotifier`) must live in a non-autoDispose provider so that it survives screen navigation. The watcher calls `ref.read(homeScreenProvider.notifier).refresh()` directly. If `homeScreenProvider` has been auto-disposed (user is not on the home screen), this call is a no-op because `refresh()` guards against null `selectedBabyProfileId`. This is intentional behavior.

**NOTE**: `connectivity_plus` reports the type of network (WiFi, mobile, none), NOT internet reachability. In edge cases, a device may be connected to WiFi with no internet access (captive portals, DHCP failures). In these cases, `isOnlineProvider` will report `true` even though requests fail. This is acceptable — a failed refresh after reconnect will be handled by the existing `SyncManager` retry logic (2s/4s/8s exponential backoff).

---

## Open Questions

There are no open questions. Architecture is finalized.

---

## Architecture Decision Log

### Why Not Modify `SyncManager` Directly?

`SyncManager` is a pure Dart class with no Riverpod dependency. The gap document's resolution says "integrate `connectivity_plus` inside `SyncManager`," but injecting a raw `Stream<bool>` into the constructor would couple two separate concerns and make testing harder. The cleaner approach is to wire connectivity awareness at the Riverpod provider layer, keeping `SyncManager` as a pure, independently testable service.

### Why `NotifierProvider<bool>` Instead of `StreamProvider<ConnectivityResult>`?

`StreamProvider` exposes `AsyncValue<List<ConnectivityResult>>` — consumers would need to handle `loading`/`error` states everywhere. "Are we online?" is a boolean with a sensible default (`true`). A `Notifier<bool>` has no loading state, provides a simple API, and allows the offline-to-online transition detection logic to live in one place.

### Why Not Register the Reconnect Watch in `homeScreenProvider.build()`?

`homeScreenProvider` is `NotifierProvider.autoDispose`. It disposes when the home screen is not in the widget tree. Any `ref.listen` in its `build()` would be cancelled during navigation. The reconnect watch must live in a non-autoDispose provider to be reliable across screen transitions.

### Why a Separate File for `NetworkStatusNotifier`?

All providers are declared in `lib/core/di/providers.dart`, but provider classes with non-trivial logic live in their own files for maintainability and testability. Precedent: `HomeScreenNotifier` lives in `home_screen_provider.dart`, not inline in `providers.dart`.

---

## Proposed Changes

### Phase 1 — Package Addition

#### [MODIFY] `pubspec.yaml`

Add `connectivity_plus: ^6.1.0` under `dependencies`, alongside the existing `http:` and other network packages. Run `flutter pub get` after saving.

---

### Phase 2 — `NetworkStatusNotifier` Class

#### [CREATE] `lib/core/di/network_status_notifier.dart`

This is the core of the implementation. It is a Riverpod `Notifier<bool>` (state = `isOnline`) that owns the `connectivity_plus` subscription and triggers refresh on reconnect.

**Class**: `NetworkStatusNotifier extends Notifier<bool>`

**Instance fields**:
- `StreamSubscription<List<ConnectivityResult>>? _subscription`
- `bool _previousIsOnline = true`

**`build()` method**:
1. Create `final connectivity = Connectivity()` (from `connectivity_plus`)
2. Call `connectivity.checkConnectivity()` asynchronously — update `state` and `_previousIsOnline` when the future resolves (do not block `build()`, which must be synchronous)
3. Subscribe to `connectivity.onConnectivityChanged` stream. In the listener:
   - Map `List<ConnectivityResult>` to `bool isOnline` — any result that is NOT `ConnectivityResult.none` means online
   - If `!_previousIsOnline && isOnline` — call `_handleReconnect()`
   - Update `_previousIsOnline = isOnline`
   - Update `state = isOnline`
4. Register `ref.onDispose(() { _subscription?.cancel(); _subscription = null; })`
5. Return `true` as the synchronous default (assume online until `checkConnectivity` resolves)

**`_handleReconnect()` private method**:
```dart
void _handleReconnect() {
  // Trigger SyncManager full sync cycle (clears delta lastSyncTime, uses retry/backoff)
  ref.read(syncManagerProvider).forceFullSync();

  // Force-refresh home screen tile configs (bypasses Hive cache).
  // No-op if homeScreenProvider has been auto-disposed (user not on home screen).
  // Note: creates a dependency from core DI layer to feature layer.
  // Alternative: homeScreenProvider calls ref.listen(isOnlineProvider, ...) to self-register.
  ref.read(homeScreenProvider.notifier).refresh();
}
```

**Key imports**:
- `package:connectivity_plus/connectivity_plus.dart`
- `package:flutter_riverpod/flutter_riverpod.dart`
- `providers.dart` (for `syncManagerProvider`)
- `../../features/home/presentation/providers/home_screen_provider.dart` (for `homeScreenProvider`)

---

### Phase 3 — Provider Declarations

#### [MODIFY] `lib/core/di/providers.dart`

Add to the "Real-Time & Notifications" section.

**New imports**:
```dart
import 'dart:async' show unawaited;
import '../services/sync_manager.dart';
import 'network_status_notifier.dart';
```

**3a. `syncManagerProvider`** — Creates, initializes, and disposes the `SyncManager` singleton:
```dart
final syncManagerProvider = Provider<SyncManager>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  final manager = SyncManager(realtimeService: realtimeService);
  unawaited(manager.initialize());
  ref.onDispose(() => unawaited(manager.dispose()));
  return manager;
});
```

**3b. `isOnlineProvider`** — Exposes the bool connectivity state. Must NOT be autoDispose:
```dart
final isOnlineProvider = NotifierProvider<NetworkStatusNotifier, bool>(
  NetworkStatusNotifier.new,
);
```

**3c. Early activation** — In `appInitializationProvider` body, BEFORE the `AppInitializationService.initialize()` call:
```dart
ref.read(syncManagerProvider);  // starts 5-min background sync timer
ref.read(isOnlineProvider);     // starts connectivity monitoring subscription
```

---

### Phase 4 — `OfflineIndicator` in Home Screen

#### [MODIFY] `lib/features/home/presentation/screens/home_screen.dart`

**Add imports**:
```dart
import '../../../../core/di/providers.dart' show isOnlineProvider;
import '../../../../core/widgets/offline_indicator.dart';
```

In `_HomeScreenState.build()`, in the `Scaffold.body` Column, add `OfflineIndicator` as the **first** child (before the role toggle and the `Expanded` body):
```dart
OfflineIndicator(
  isOffline: !ref.watch(isOnlineProvider),
  onRetry: () => ref.read(homeScreenProvider.notifier).refresh(),
),
```

`OfflineIndicator` returns `const SizedBox.shrink()` when `isOffline: false` — zero layout overhead when online.

---

### Phase 5 — SyncManager Sync Handler *(Optional — Defer to Sprint 2)*

#### [MODIFY] `lib/features/home/presentation/providers/home_screen_provider.dart`

In `HomeScreenNotifier.build()`, register a tile-refresh handler with `SyncManager`:
```dart
ref.read(syncManagerProvider).registerSyncHandler(
  'home_tiles',
  (DateTime? since) async {
    await refresh();
    return true;
  },
);
ref.onDispose(
  () => ref.read(syncManagerProvider).unregisterSyncHandler('home_tiles'),
);
```

This step is **NOT required** for the initial fix. Phases 1–4 fully address Gap #6 independently.

---

## Files Changed Summary

| File | Change |
|---|---|
| `pubspec.yaml` | Add `connectivity_plus: ^6.1.0` |
| `lib/core/di/network_status_notifier.dart` | New file — `NetworkStatusNotifier` class |
| `lib/core/di/providers.dart` | Add `syncManagerProvider`, `isOnlineProvider`; activate both in `appInitializationProvider`; add 3 new imports |
| `lib/features/home/presentation/screens/home_screen.dart` | Add `OfflineIndicator` as first Column child |
| `lib/features/home/presentation/providers/home_screen_provider.dart` | *(Phase 5 — optional)* SyncManager handler in `build()` |
| `lib/core/services/sync_manager.dart` | No changes |
| `lib/core/widgets/offline_indicator.dart` | No changes |

---

## New Test Files

### `test/core/di/network_status_notifier_test.dart`

Unit tests using `ProviderContainer` with overrides. Use Mocktail to mock `SyncManager` and `HomeScreenNotifier`.

| # | Test | Assert |
|---|---|---|
| 1 | Initial state | State is `true` before first stream event |
| 2 | Goes offline | Stream emits `[ConnectivityResult.none]` → state becomes `false` |
| 3 | Comes back online | Stream emits `[ConnectivityResult.wifi]` after none → state becomes `true` |
| 4 | Reconnect triggers SyncManager | `syncManager.forceFullSync()` called exactly once on offline→online |
| 5 | Reconnect triggers home refresh | `homeScreenProvider.notifier.refresh()` called exactly once on offline→online |
| 6 | No double trigger | Online→online (no transition) — `forceFullSync()` is NOT called |
| 7 | Cleanup on dispose | `_subscription.cancel()` invoked when container is disposed |

### `test/features/home/home_screen_offline_test.dart`

Widget tests using `ProviderScope` with overrides.

| # | Test | Assert |
|---|---|---|
| 1 | Banner hidden when online | `isOnlineProvider` true → "No internet connection" text not found |
| 2 | Banner visible when offline | `isOnlineProvider` false → "No internet connection" text visible |
| 3 | Retry button present when offline | `isOnlineProvider` false → "Retry" text button found |
| 4 | Tapping Retry calls `refresh()` | Tap "Retry" → `homeScreenNotifier.refresh()` called once |

---

## Verification Steps

1. `flutter analyze` — zero new errors after all modifications.
2. `flutter test test/core/di/network_status_notifier_test.dart` — all 7 cases green.
3. `flutter test test/features/home/home_screen_offline_test.dart` — all 4 cases green.
4. `flutter test` — no previously passing tests break.
5. `flutter pub outdated` — `connectivity_plus` resolved without version conflicts.
6. **Manual**: Disable WiFi + mobile data on device. Open home screen. Confirm red banner "No internet connection" appears. Re-enable network. Confirm banner disappears automatically without user pull-to-refresh.
7. **Manual**: Load home screen (tiles cached). Disable network, then re-enable. Confirm tiles silently refresh within ~2 seconds without user pull-to-refresh.
8. **Manual**: While offline, tap "Retry" button. Confirm refresh attempt is triggered.

---

## Scope: Included vs. Excluded

| Included | Excluded |
|---|---|
| Connectivity detection and `isOnlineProvider` | `RealtimeService` socket re-subscription (Supabase SDK handles internally) |
| `OfflineIndicator` banner on the home screen | Offline banners on Registry, Gallery, Calendar screens (follow-up sprint) |
| `SyncManager` Riverpod lifecycle via `syncManagerProvider` | SyncManager handlers for registry/gallery tile data |
| Auto-refresh of home screen tile configs on reconnect | Per-tile provider invalidation (photos, events, purchases — fetched lazily on next render) |
| Unit + widget test coverage | Device-farm integration tests (addressed by Gap #8 plan) |
