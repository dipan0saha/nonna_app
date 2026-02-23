import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/features/registry/presentation/providers/registry_screen_provider.dart';
import 'package:nonna_app/features/registry/presentation/screens/registry_screen.dart';

// ---------------------------------------------------------------------------
// Fake RegistryScreenNotifier
// ---------------------------------------------------------------------------

class _FakeRegistryNotifier extends RegistryScreenNotifier {
  _FakeRegistryNotifier(this._initial);

  final RegistryScreenState _initial;

  @override
  RegistryScreenState build() => _initial;

  @override
  Future<void> loadItems({
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {}

  @override
  void applyFilter(RegistryFilter filter) {}

  @override
  void applySort(RegistrySort sort) {}

  @override
  Future<void> refresh() async {}
}

// ---------------------------------------------------------------------------
// Helper factory for RegistryItem
// ---------------------------------------------------------------------------

RegistryItemWithStatus _makeItem(String id, String name,
    {bool isPurchased = false}) {
  final now = DateTime(2024, 6, 1);
  return RegistryItemWithStatus(
    item: RegistryItem(
      id: id,
      babyProfileId: 'p1',
      createdByUserId: 'u1',
      name: name,
      priority: 3,
      createdAt: now,
      updatedAt: now,
    ),
    isPurchased: isPurchased,
  );
}

// ---------------------------------------------------------------------------
// Helper: build wrapped screen
// ---------------------------------------------------------------------------

Widget _buildScreen(
  RegistryScreenState state, {
  String? babyProfileId,
  UserRole? userRole,
  Function(RegistryItem)? onItemTap,
}) {
  return ProviderScope(
    overrides: [
      registryScreenProvider.overrideWith(() => _FakeRegistryNotifier(state)),
    ],
    child: MaterialApp(
      home: RegistryScreen(
        babyProfileId: babyProfileId,
        userRole: userRole,
        onItemTap: onItemTap,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RegistryScreen', () {
    testWidgets('renders app bar with title Registry', (tester) async {
      await tester.pumpWidget(_buildScreen(const RegistryScreenState()));
      expect(find.text('Registry'), findsOneWidget);
    });

    testWidgets('shows shimmer list tiles when loading', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const RegistryScreenState(isLoading: true),
          babyProfileId: 'p1',
        ),
      );
      await tester.pump();
      expect(find.byType(ShimmerListTile), findsNWidgets(5));
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const RegistryScreenState(error: 'Load failed'),
          babyProfileId: 'p1',
        ),
      );
      expect(find.text('Load failed'), findsOneWidget);
    });

    testWidgets('shows empty state when no items', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const RegistryScreenState(),
          babyProfileId: 'p1',
        ),
      );
      await tester.pump();
      expect(find.text('No registry items yet'), findsOneWidget);
    });

    testWidgets('renders registry items when loaded', (tester) async {
      final items = [
        _makeItem('1', 'Crib'),
        _makeItem('2', 'Stroller'),
      ];
      await tester.pumpWidget(
        _buildScreen(
          RegistryScreenState(items: items),
          babyProfileId: 'p1',
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('registry_item_0')), findsOneWidget);
      expect(find.byKey(const Key('registry_item_1')), findsOneWidget);
    });

    testWidgets('shows add FAB for owner role', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const RegistryScreenState(),
          userRole: UserRole.owner,
        ),
      );
      expect(find.byKey(const Key('add_registry_item_fab')), findsOneWidget);
    });

    testWidgets('hides add FAB for follower role', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const RegistryScreenState(),
          userRole: UserRole.follower,
        ),
      );
      expect(find.byKey(const Key('add_registry_item_fab')), findsNothing);
    });

    testWidgets('shows snackbar when owner taps add FAB', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const RegistryScreenState(),
          userRole: UserRole.owner,
        ),
      );
      await tester.tap(find.byKey(const Key('add_registry_item_fab')));
      await tester.pump();
      expect(find.text('Add registry item – coming soon!'), findsOneWidget);
    });
  });
}
