# Dynamic, Database-Driven Control of Tiles & Screens

This document outlines the detailed architectural concept, database override
design, and step-by-step implementation guide to migrate hardcoded tile
configurations and parameters to a centralized, database-driven system
controlled from Supabase's `tile_configs` table.

By shifting these parameters to the database via the JSONB `params` column, we
enable instant, over-the-air (OTA) updates, personalized content rendering, and
centralized A/B testing of limits and messaging—all while maintaining robust
compile-time client fallback mechanisms for offline resiliency.

---

## Architectural Paradigm: The Hybrid Override Strategy

To balance **dynamic remote control** with **offline resilience**, we employ a
hybrid strategy:

```
        +-----------------------------------+
        |      Supabase tile_configs        |
        |     (JSONB 'params' payload)      |
        +-----------------------------------+
                          |
                          | [Fetches over API / Hive Cache]
                          v
        +-----------------------------------+
        |       Smart Tile Wrapper          |
        |  (Uses params?['key'] if present) |
        +-----------------------------------+
                     /         \
       [If present] /           \ [If null / Offline]
                   v             v
+----------------------+     +----------------------+
|   Dynamic DB Value   |     | Hardcoded Fallback   |
|  (Over-the-air OTA)  |     |   (Type-safe Dart)   |
+----------------------+     +----------------------+
```

1. **DB Override**: The client fetches the screen configuration and individual
   tile configs. If a key is configured in a tile's `params` dictionary, that
   value is used.
2. **Compile-Time Fallback**: If the key is missing from the database (null), or
   if the user is offline without a cache, the smart tile wrapper falls back to
   hardcoded, type-safe constants.
3. **Safe Serialization**: Non-primitive types (such as Material icons) are
   represented in database JSON as unique string identifiers (e.g.
   `'card_giftcard_outlined'`) and mapped to actual `IconData` elements via a
   type-safe enum mapper on the client.

---

## Proposed Changes

We will introduce a centralized icon mapper, update the smart tile wrappers in
the factory engine to extract overrides, and update screens to dynamically apply
overrides.

---

### 1. Centralized Core Utilities Component

We will create a centralized utility class to map database string identifiers to
Material `IconData` tokens.

#### [NEW] [tile_icon_mapper.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/core/utils/tile_icon_mapper.dart)

Create a bulletproof utility class to map database-configured string keys into
Material icons:

```dart
import 'package:flutter/material.dart';

/// Centralized mapper to convert string representations of icons stored 
/// in database configs to Material IconData tokens.
class TileIconMapper {
  TileIconMapper._();

  /// Maps a dynamic string identifier to its corresponding IconData.
  /// Falls back to [fallback] (default: Icons.extension) if the string is empty or unrecognized.
  static IconData mapStringToIcon(String? iconName, [IconData fallback = Icons.extension]) {
    if (iconName == null || iconName.trim().isEmpty) {
      return fallback;
    }

    switch (iconName.trim().toLowerCase()) {
      case 'card_giftcard_outlined':
      case 'card_giftcard':
        return Icons.card_giftcard_outlined;
      case 'dashboard_outlined':
      case 'dashboard':
        return Icons.dashboard_outlined;
      case 'checklist_outlined':
      case 'checklist':
        return Icons.checklist_outlined;
      case 'child_care_outlined':
      case 'child_care':
        return Icons.child_care_outlined;
      case 'child_friendly_outlined':
      case 'child_friendly':
        return Icons.child_friendly_outlined;
      case 'favorite_outline':
      case 'favorite_border':
        return Icons.favorite_outline;
      case 'favorite':
        return Icons.favorite;
      case 'mail_outlined':
      case 'mail':
        return Icons.mail_outlined;
      case 'people_outline':
      case 'people':
        return Icons.people_outline;
      case 'notifications_none_outlined':
      case 'notifications_none':
        return Icons.notifications_none_outlined;
      case 'photo_outlined':
      case 'photo':
        return Icons.photo_outlined;
      case 'shopping_bag_outlined':
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'check_circle_outline':
      case 'check_circle':
        return Icons.check_circle_outline;
      case 'storage_outlined':
      case 'storage':
        return Icons.storage_outlined;
      case 'event_outlined':
      case 'event':
        return Icons.event_outlined;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'error_outline':
        return Icons.error_outline;
      case 'extension':
      default:
        return fallback;
    }
  }
}
```

---

### 2. Smart Tile Factory Component

We will modify the Smart Tile wrappers in the factory engine to read
configuration dictionaries and dynamically apply parameter and layout overrides.

#### [MODIFY] [tile_factory.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/core/utils/tile_factory.dart)

Apply a consistent parsing design to all Smart Tile wrappers inside
`tile_factory.dart`. Ensure that every wrapper defines standard defaults and
cleanly maps options:

#### Refactoring Specifications:

1. **`_RecentPhotosSmartTile`**:
   - **Default parameters**: `fullView` = `false`
   - **DB parameters**: `params?['full'] as bool?`
   - **Empty State defaults**: Message: `'No photos yet'`, Icon:
     `Icons.photo_outlined`
   - **DB Empty overrides**: `params?['emptyMessage']`, `params?['emptyIcon']`

2. **`_GalleryFavoritesSmartTile`**:
   - **Default parameters**: `fullView` = `false`
   - **DB parameters**: `params?['full'] as bool?`
   - **Empty State defaults**: Message: `'No favorites yet'`, Icon:
     `Icons.favorite_outline`
   - **DB Empty overrides**: `params?['emptyMessage']`, `params?['emptyIcon']`

3. **`_RecentPurchasesSmartTile`**:
   - **Default parameters**: `maxItems` = `3`
   - **DB parameters**: `params?['maxItems'] as int?`
   - **Empty State defaults**: Message: `'No recent purchases'`, Icon:
     `Icons.shopping_bag_outlined`
   - **DB Empty overrides**: `params?['emptyMessage']`, `params?['emptyIcon']`

4. **`_ChecklistSmartTile`**:
   - **Empty State defaults**: Message: `'No checklist items'`, Icon:
     `Icons.checklist_outlined`
   - **DB Empty overrides**: `params?['emptyMessage']`, `params?['emptyIcon']`

5. **`_CountdownSmartTile`**:
   - **Empty State defaults**: Message: `'No due dates to display'`, Icon:
     `Icons.child_care_outlined`
   - **DB Empty overrides**: `params?['emptyMessage']`, `params?['emptyIcon']`

6. **`_InvitesStatusSmartTile`**:
   - **Empty State defaults**: Message: `'No invitations sent'`, Icon:
     `Icons.mail_outlined`
   - **DB Empty overrides**: `params?['emptyMessage']`, `params?['emptyIcon']`

7. **`_NewFollowersSmartTile`**:
   - **Empty State defaults**: Message: `'No new followers recently'`, Icon:
     `Icons.people_outline`
   - **DB Empty overrides**: `params?['emptyMessage']`, `params?['emptyIcon']`

8. **`_NotificationsSmartTile`**:
   - **Empty State defaults**: Message: `'No notifications'`, Icon:
     `Icons.notifications_none_outlined`
   - **DB Empty overrides**: `params?['emptyMessage']`, `params?['emptyIcon']`

9. **`_RsvpTasksSmartTile`**:
   - **Empty State defaults**: Message: `'No RSVP tasks'`, Icon:
     `Icons.check_circle_outline`
   - **DB Empty overrides**: `params?['emptyMessage']`, `params?['emptyIcon']`

10. **`_UpcomingEventsSmartTile`**:
    - **Empty State defaults**: Message: `'No upcoming events'`, Icon:
      `Icons.event_outlined`
    - **DB Empty overrides**: `params?['emptyMessage']`, `params?['emptyIcon']`

#### Code Refactoring Pattern (Example: `_RecentPurchasesSmartTile`):

```dart
class _RecentPurchasesSmartTileState extends ConsumerState<_RecentPurchasesSmartTile> {
  // ... existing initState and listen methods ...

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recentPurchasesProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    // Extract database parameters with compile-time fallbacks
    final maxItems = widget.config.params?['maxItems'] as int? ?? 3;
    
    final emptyMessage = widget.config.params?['emptyMessage'] as String? 
        ?? 'No recent purchases';
        
    final emptyIconName = widget.config.params?['emptyIcon'] as String? 
        ?? 'shopping_bag_outlined';
        
    final emptyIcon = TileIconMapper.mapStringToIcon(
      emptyIconName, 
      Icons.shopping_bag_outlined,
    );

    return RecentPurchasesTile(
      purchases: state.purchases,
      isLoading: state.isLoading && state.purchases.isEmpty,
      error: state.error,
      maxItems: maxItems,
      // Pass custom-defined empty state details if supported by the widget
      emptyWidget: CompactEmptyState(
        message: emptyMessage,
        icon: emptyIcon,
      ),
      onRefresh: babyProfileId != null
          ? () => ref
              .read(recentPurchasesProvider.notifier)
              .fetchPurchases(babyProfileId: babyProfileId, forceRefresh: true)
          : null,
    );
  }
}
```

---

### 3. Feature Screens Component

We will modify screen-level container structures to look up screen
configurations and dynamic overrides instead of relying on hardcoded UI
fallbacks.

#### [MODIFY] [registry_screen.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/lib/features/registry/presentation/screens/registry_screen.dart)

Refactor `registry_screen.dart` to read registry screen configurations. Modify
`_buildBody` to extract screen config params dynamically:

```dart
  Widget _buildBody(RegistryScreenState state, Map<String, dynamic>? screenParams) {
    if (state.isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const ShimmerListTile(),
          childCount: 5,
        ),
      );
    }

    if (state.error != null) {
      return SliverFillRemaining(
        child: ErrorView(
          message: state.error!,
          onRetry: _onRefresh,
        ),
      );
    }

    // Dynamic database overrides with strict client fallback safety
    final emptyTitle = screenParams?['emptyTitle'] as String? 
        ?? 'Your registry is empty';
        
    final emptyMessage = screenParams?['emptyMessage'] as String? 
        ?? 'Add your first item!';
        
    final emptyDesc = screenParams?['emptyDescription'] as String? 
        ?? 'Tap the + button below to get started.';
        
    final emptyIconName = screenParams?['emptyIcon'] as String? 
        ?? 'card_giftcard_outlined';
        
    final emptyIcon = TileIconMapper.mapStringToIcon(
      emptyIconName, 
      Icons.card_giftcard_outlined,
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TileListView(
          tiles: state.tiles,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          emptyWidget: EmptyState(
            icon: emptyIcon,
            title: emptyTitle,
            message: emptyMessage,
            description: emptyDesc,
          ),
        ),
      ),
    );
  }
```

---

## Verification & Testing Plan

A rigorous automated and manual test plan ensures zero regression.

### 1. Centralized Unit Verification

Create an automated test suite specifically to verify the mapper's accuracy
under normal, empty, and invalid input strings:

#### [NEW] [tile_icon_mapper_test.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/test/core/utils/tile_icon_mapper_test.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/tile_icon_mapper.dart';

void main() {
  group('TileIconMapper Tests', () {
    test('Should return correct IconData for standard strings', () {
      expect(
        TileIconMapper.mapStringToIcon('card_giftcard_outlined'), 
        Icons.card_giftcard_outlined,
      );
      expect(
        TileIconMapper.mapStringToIcon('shopping_bag_outlined'), 
        Icons.shopping_bag_outlined,
      );
    });

    test('Should handle casing and whitespace robustly', () {
      expect(
        TileIconMapper.mapStringToIcon('  Card_Giftcard_Outlined  '), 
        Icons.card_giftcard_outlined,
      );
    });

    test('Should return fallback icon on invalid or missing strings', () {
      expect(
        TileIconMapper.mapStringToIcon('non_existent_icon'), 
        Icons.extension,
      );
      expect(
        TileIconMapper.mapStringToIcon(null, Icons.error), 
        Icons.error,
      );
    });
  });
}
```

Execute tests via standard CLI:

```bash
flutter test test/core/utils/tile_icon_mapper_test.dart
```

### 2. Manual Configuration Validation Setup

Verify dynamically by modifying the `tile_configs` params row in Supabase:

1. Set a tile’s parameters to:
   ```json
   {
       "maxItems": 1,
       "emptyMessage": "No items to show!",
       "emptyIcon": "notifications_none_outlined"
   }
   ```
2. Verify that the UI constraints react in real-time, matching exactly 1 item.
3. Empty out the data source under high network latency, or toggle airplane mode
   on the emulator/device, and verify that compile-time fallback configurations
   render beautifully without errors.
