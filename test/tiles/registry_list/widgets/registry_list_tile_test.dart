import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/features/registry/presentation/providers/registry_screen_provider.dart';
import 'package:nonna_app/tiles/registry_list/widgets/registry_list_tile.dart';

// ---------------------------------------------------------------------------
// Fake notifiers
// ---------------------------------------------------------------------------

class _FakeRegistryScreenNotifier extends RegistryScreenNotifier {
  _FakeRegistryScreenNotifier(this._state);
  final RegistryScreenState _state;

  @override
  RegistryScreenState build() => _state;

  @override
  Future<void> loadItems({
    required String babyProfileId,
    UserRole role = UserRole.follower,
    bool forceRefresh = false,
  }) async {}

  @override
  void applySort(RegistrySort sort) {}

  @override
  void applyFilter(RegistryFilter filter) {}

  @override
  Future<void> togglePurchase(RegistryItemWithStatus itemWithStatus) async {}
}

class _FakeHomeScreenNotifier extends HomeScreenNotifier {
  _FakeHomeScreenNotifier(this._state);
  final HomeScreenState _state;

  @override
  HomeScreenState build() => _state;

  @override
  Future<void> loadTiles({
    required String babyProfileId,
    required UserRole role,
  }) async {}
}

// ---------------------------------------------------------------------------
// Factory helpers
// ---------------------------------------------------------------------------

RegistryItem _makeItem({
  String id = 'ri_1',
  String name = 'Stroller',
  int priority = 3,
}) {
  final now = DateTime.now();
  return RegistryItem(
    id: id,
    babyProfileId: 'bp_1',
    createdByUserId: 'u_1',
    name: name,
    priority: priority,
    createdAt: now,
    updatedAt: now,
  );
}

RegistryItemWithStatus _makeItemWithStatus({
  String id = 'ri_1',
  String name = 'Stroller',
  bool isPurchased = false,
  bool isPurchasedByCurrentUser = false,
}) {
  return RegistryItemWithStatus(
    item: _makeItem(id: id, name: name),
    isPurchased: isPurchased,
    isPurchasedByCurrentUser: isPurchasedByCurrentUser,
  );
}

/// Wraps the tile in a ProviderScope + GoRouter-backed MaterialApp.router so
/// that `context.push()` calls inside the tile don't throw during tests.
Widget _buildWidget(
  RegistryScreenState registryState, {
  UserRole role = UserRole.follower,
}) {
  final homeState = HomeScreenState(selectedRole: role);
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(
          body: RegistryListSmartTile(),
        ),
      ),
      GoRoute(
        path: '/registry/item',
        builder: (_, __) => const Scaffold(body: Text('Registry Item')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      registryScreenProvider
          .overrideWith(() => _FakeRegistryScreenNotifier(registryState)),
      homeScreenProvider.overrideWith(() => _FakeHomeScreenNotifier(homeState)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RegistryListSmartTile', () {
    testWidgets('shows ShimmerListTile widgets when isLoading', (tester) async {
      await tester
          .pumpWidget(_buildWidget(const RegistryScreenState(isLoading: true)));
      await tester.pump();
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('no root key present during loading state', (tester) async {
      await tester
          .pumpWidget(_buildWidget(const RegistryScreenState(isLoading: true)));
      await tester.pump();
      expect(find.byKey(const Key('registry_list_smart_tile')), findsNothing);
    });

    testWidgets('renders with correct widget key when not loading',
        (tester) async {
      await tester.pumpWidget(_buildWidget(const RegistryScreenState()));
      await tester.pump();
      expect(find.byKey(const Key('registry_list_smart_tile')), findsOneWidget);
    });

    testWidgets('shows Available Items section header', (tester) async {
      final item = _makeItemWithStatus(id: 'ri_1', name: 'Stroller');
      await tester.pumpWidget(_buildWidget(RegistryScreenState(items: [item])));
      await tester.pump();
      expect(find.text('Available Items'), findsOneWidget);
    });

    testWidgets('shows Purchased Items section when purchased items exist',
        (tester) async {
      final purchased =
          _makeItemWithStatus(id: 'ri_1', name: 'Crib', isPurchased: true);
      await tester
          .pumpWidget(_buildWidget(RegistryScreenState(items: [purchased])));
      await tester.pump();
      expect(find.text('Purchased Items'), findsOneWidget);
    });

    testWidgets('does not show Purchased Items section when none purchased',
        (tester) async {
      final available = _makeItemWithStatus(id: 'ri_1', name: 'Stroller');
      await tester
          .pumpWidget(_buildWidget(RegistryScreenState(items: [available])));
      await tester.pump();
      expect(find.text('Purchased Items'), findsNothing);
    });

    testWidgets('renders item name in the list', (tester) async {
      final item = _makeItemWithStatus(id: 'ri_1', name: 'Baby Monitor');
      await tester.pumpWidget(_buildWidget(RegistryScreenState(items: [item])));
      await tester.pump();
      expect(find.text('Baby Monitor'), findsOneWidget);
    });

    testWidgets('shows lock icon for item purchased by someone else',
        (tester) async {
      final purchased = _makeItemWithStatus(
          id: 'ri_1',
          name: 'Crib',
          isPurchased: true,
          isPurchasedByCurrentUser: false);
      await tester
          .pumpWidget(_buildWidget(RegistryScreenState(items: [purchased])));
      await tester.pump();
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('shows undo icon for item purchased by current user',
        (tester) async {
      final purchased = _makeItemWithStatus(
          id: 'ri_1',
          name: 'Crib',
          isPurchased: true,
          isPurchasedByCurrentUser: true);
      await tester
          .pumpWidget(_buildWidget(RegistryScreenState(items: [purchased])));
      await tester.pump();
      expect(find.byIcon(Icons.undo), findsOneWidget);
    });

    testWidgets('shows check_circle_outline icon for available item',
        (tester) async {
      final item = _makeItemWithStatus(id: 'ri_1', name: 'Stroller');
      await tester.pumpWidget(_buildWidget(RegistryScreenState(items: [item])));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('shows empty state widget when items list is empty',
        (tester) async {
      await tester.pumpWidget(_buildWidget(const RegistryScreenState()));
      await tester.pump();
      expect(find.text('No registry items found'), findsOneWidget);
    });

    testWidgets('shows Registry Items header', (tester) async {
      await tester.pumpWidget(_buildWidget(const RegistryScreenState()));
      await tester.pump();
      expect(find.text('Registry Items'), findsOneWidget);
    });
  });
}
