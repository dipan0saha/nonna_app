# Implementation Plan: Deep-Link Routing Recovery & Null extra Fallbacks (Gap Item #1)

## Goal Description
The Nonna application uses GoRouter for dynamic page routing. Detail and editor screens (Calendar events, Photo detail, and Registry items) are currently configured to read the entire object entity from the GoRouter `state.extra` parameter. 

While highly efficient for in-app navigation, this poses a critical vulnerability: **`state.extra` is in-memory only**. When the app is launched directly from a native push notification, deep-linked from a sharing URL (e.g., an invitation email), or restored after background termination by the OS, `state.extra` is null. As a result, the app displays a blank "Data not found" page, breaking push notifications and deep linking.

This plan details the technical steps to:
1. Refactor GoRouter paths to include dynamic path slug identifiers (`/:id`).
2. Update the screen constructors to accept either the full entity (for fast, zero-latency in-app navigation) OR an ID parameter (for deep links).
3. Implement state-based fetch resolvers on screen initialization to load missing entities directly from the database if only the ID is supplied.

---

## User Review Required
No breaking changes or database modifications. 

> [!IMPORTANT]
> **Router Path Changes**:
> - We refactor calendar, gallery, and registry paths to include `:id`.
> - **English/Spanish URL standard**: Using clean slugs (e.g. `/gallery/photo/:id`) that resolve nicely.
> - We maintain the `parentNavigatorKey: NavigationService.navigatorKey` structure for full-screen escapes.

---

## Open Questions
There are no open questions. All dynamic paths and entity loading models are mapped below.

---

## Proposed Changes

### Router Definition Refactoring

#### [MODIFY] [app_router.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/core/router/app_router.dart)
We will update `AppRoutes` paths to support slugs, and rewrite route builders to handle both `extra` and dynamic path parameters.

*Draft route updates:*
```dart
abstract class AppRoutes {
  // ...
  // From: static const calendarEvent = '/calendar/event/detail';
  static const calendarEvent = '/calendar/event/:id';
  
  // From: static const calendarEventEdit = '/calendar/event/edit';
  static const calendarEventEdit = '/calendar/event/:id/edit';
  
  // From: static const galleryPhoto = '/gallery/photo/detail';
  static const galleryPhoto = '/gallery/photo/:id';
  
  // From: static const registryItem = '/registry/item/detail';
  static const registryItem = '/registry/item/:id';
  
  // From: static const registryItemEdit = '/registry/item/edit';
  static const registryItemEdit = '/registry/item/:id/edit';

  // Navigation helper methods — build valid URL strings for context.push() and
  // NavigationService.pushTo(). The `:id` constants above are GoRoute path
  // patterns (used only inside GoRoute builders) and cannot be used as
  // navigation targets directly, since they contain the literal colon-id token.
  static String galleryPhotoRoute(String id) => '/gallery/photo/$id';
  static String calendarEventRoute(String id) => '/calendar/event/$id';
  static String calendarEventEditRoute(String id) => '/calendar/event/$id/edit';
  static String registryItemRoute(String id) => '/registry/item/$id';
  static String registryItemEditRoute(String id) => '/registry/item/$id/edit';
}
```

*Draft route builder updates:*
```dart
// Gallery Photo Detail
GoRoute(
  parentNavigatorKey: NavigationService.navigatorKey,
  path: 'photo/:id',
  builder: (context, state) {
    final photo = state.extra as Photo?;
    final id = state.pathParameters['id'] ?? '';
    return PhotoDetailScreen(photo: photo, photoId: id);
  },
),

// Calendar Event Detail
GoRoute(
  path: 'event/:id',
  builder: (context, state) {
    final event = state.extra as Event?;
    final id = state.pathParameters['id'] ?? '';
    return EventDetailScreen(event: event, eventId: id);
  },
),

// Calendar Event Edit
GoRoute(
  parentNavigatorKey: NavigationService.navigatorKey,
  path: 'event/:id/edit',
  builder: (context, state) {
    final event = state.extra as Event?;
    final id = state.pathParameters['id'] ?? '';
    return EventEditScreen(event: event, eventId: id);
  },
),

// Registry Item Detail
GoRoute(
  path: 'item/:id',
  builder: (context, state) {
    final item = state.extra as RegistryItem?;
    final id = state.pathParameters['id'] ?? '';
    return RegistryItemDetailScreen(item: item, itemId: id);
  },
),

// Registry Item Edit
GoRoute(
  parentNavigatorKey: NavigationService.navigatorKey,
  path: 'item/:id/edit',
  builder: (context, state) {
    final item = state.extra as RegistryItem?;
    final id = state.pathParameters['id'] ?? '';
    return RegistryItemEditScreen(item: item, itemId: id);
  },
),
```

---

### Detail Screen Adaptations

Each detail screen will be adapted to support the hybrid data initialization pattern.

#### [MODIFY] [photo_detail_screen.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/features/gallery/presentation/screens/photo_detail_screen.dart)
- Update `PhotoDetailScreen` constructor:
  ```dart
  const PhotoDetailScreen({
    super.key,
    this.photo,
    this.photoId,
  }) : assert(photo != null || photoId != null, 'Either photo or photoId must be supplied');
  
  final Photo? photo;
  final String? photoId;
  ```
- In `_PhotoDetailScreenState`, add loading and fetched photo states:
  ```dart
  Photo? _resolvedPhoto;
  bool _isLoadingPhoto = false;
  String? _resolveError;
  ```
- In `initState()`, check if `widget.photo != null`. If so, assign `_resolvedPhoto = widget.photo!`. Otherwise, set `_isLoadingPhoto = true` and query Supabase:
  ```dart
  Future<void> _fetchPhoto() async {
    setState(() => _isLoadingPhoto = true);
    try {
      final databaseService = ref.read(databaseServiceProvider);
      final response = await databaseService
          .select(SupabaseTables.photos)
          .eq(SupabaseTables.id, widget.photoId!)
          .single();
      
      if (!mounted) return;
      setState(() {
        _resolvedPhoto = Photo.fromJson(response as Map<String, dynamic>);
        _isLoadingPhoto = false;
      });
      // Trigger other comments/details loaders using _resolvedPhoto
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resolveError = 'Failed to load photo: $e';
        _isLoadingPhoto = false;
      });
    }
  }
  ```
- Adapt `build()` to render a `CircularProgressIndicator` while loading, and an error screen if the resolve fails. Otherwise, run the existing rendering logic utilizing `_resolvedPhoto!`.

#### [MODIFY] [event_detail_screen.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/features/calendar/presentation/screens/event_detail_screen.dart)
- Update constructor signature to support `Event? event` and `String? eventId`.
- Implement `_isLoadingEvent` and dynamic resolver in `initState()` fetching from `SupabaseTables.events` table if `widget.event` is null.
- Handle state progress and errors inside `build()`.

#### [MODIFY] [event_edit_screen.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/features/calendar/presentation/screens/event_edit_screen.dart)
- Support constructor hybrid parameters.
- Resolve event details on startup if missing.

#### [MODIFY] [registry_item_detail_screen.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/features/registry/presentation/screens/registry_item_detail_screen.dart)
- Convert `RegistryItemDetailScreen` from a stateless `ConsumerWidget` to a stateful `ConsumerStatefulWidget`.
- Accept `RegistryItem? item` and `String? itemId` in the constructor.
- Add async loader query in `initState()` fetching from `SupabaseTables.registryItems` if the item is null.
- Implement corresponding UI loaders in `build()`.

#### [MODIFY] [registry_item_edit_screen.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/features/registry/presentation/screens/registry_item_edit_screen.dart)
- Support hybrid initialization constructor.
- Resolve missing model details on startup.

---

### Navigation Call Sites

> [!WARNING]
> **Critical Gap**: Changing the `AppRoutes` constants to `:id` path patterns means those constants can no longer be passed directly to `context.push()` or `NavigationService.pushTo()`. Every existing call site must be updated to embed the actual entity ID using the static helper methods added above.

All seven affected call sites and their required changes are listed below.

#### [MODIFY] [tile_factory.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/core/utils/tile_factory.dart) *(lines 185 and 553)*
```dart
// Before:
context.push(AppRoutes.galleryPhoto, extra: photo)
// After:
context.push(AppRoutes.galleryPhotoRoute(photo.id), extra: photo)
```

#### [MODIFY] [tile_factory.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/core/utils/tile_factory.dart) *(line 609)*
```dart
// Before:
context.push(AppRoutes.calendarEvent, extra: event)
// After:
context.push(AppRoutes.calendarEventRoute(event.id), extra: event)
```

#### [MODIFY] [upcoming_events_screen.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/features/calendar/presentation/screens/upcoming_events_screen.dart) *(line 91)*
```dart
// Before:
context.push(AppRoutes.calendarEvent, extra: event)
// After:
context.push(AppRoutes.calendarEventRoute(event.id), extra: event)
```

#### [MODIFY] [registry_list_tile.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/tiles/registry_list/widgets/registry_list_tile.dart) *(lines 77 and 95)*
```dart
// Before:
context.push(AppRoutes.registryItem, extra: item)
// After:
context.push(AppRoutes.registryItemRoute(item.id), extra: item)
```

#### [MODIFY] [event_detail_screen.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/features/calendar/presentation/screens/event_detail_screen.dart) *(line 158)*
```dart
// Before:
context.push<Event>(AppRoutes.calendarEventEdit, extra: _event)
// After:
context.push<Event>(AppRoutes.calendarEventEditRoute(_event.id), extra: _event)
```

#### [MODIFY] [registry_item_detail_screen.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/features/registry/presentation/screens/registry_item_detail_screen.dart) *(line 72)*
```dart
// Before:
context.push<bool>(AppRoutes.registryItemEdit, extra: item)
// After:
context.push<bool>(AppRoutes.registryItemEditRoute(item.id), extra: item)
```

#### [MODIFY] [onesignal_config.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/core/config/onesignal_config.dart) *(lines 66 and 75)*

> [!NOTE]
> **Pre-existing Bug Resolved**: `onesignal_config.dart` already passes `extra: photoId` (a raw `String` ID, not a `Photo` object) to the gallery photo route, and `extra: eventId` (a raw `String`) to the calendar event route. In the current codebase, `state.extra as Photo?` yields `null` for these string values, silently displaying the `_missingData` page for all push notification deep-links. Step 1 resolves this side-effect bug.
>
> With path-parameter routing the ID is in the URL path — `extra` is no longer needed:

```dart
// Before (line 66):
NavigationService.pushTo(AppRoutes.galleryPhoto, extra: photoId);
// After:
NavigationService.pushTo(AppRoutes.galleryPhotoRoute(photoId));

// Before (line 75):
NavigationService.pushTo(AppRoutes.calendarEvent, extra: eventId);
// After:
NavigationService.pushTo(AppRoutes.calendarEventRoute(eventId));
```

---

## Verification Plan

### Automated Tests
1. **Routing tests**: Run tests to ensure routing maps exist and compile correctly:
   ```bash
   make format
   ```
2. **Static code analyzer**: Verify type safety and assert configurations:
   ```bash
   make analyze
   ```
3. **Run existing widgets tests**: Ensure that navigation triggers still pass widget assertions:
   ```bash
   make test
   ```

### Manual Verification
1. **In-App Navigation**: Click standard events, photos, and gifts inside the app, and verify pages load immediately with zero network latency (verifying `extra` is still used).
2. **Simulating OS Background Restores**: Navigate to photo details, put the app in the background, simulate an OS memory wipe, restore the app, and verify it successfully queries the database and renders the detail view instead of crashing.
3. **Push/Deep-link triggers**: Execute manual CLI deep link launches:
   - Android:
     ```bash
     adb shell am start -W -a android.intent.action.VIEW -d "nonna://gallery/photo/test-photo-id-123" com.nonna.nonna_app
     ```
   - iOS:
     ```bash
     xcrun simctl openurl booted "nonna://gallery/photo/test-photo-id-123"
     ```
   Verify the app launches directly to the photo detail page and loads successfully.
