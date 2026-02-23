import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/registry_highlights/models/registry_item_with_status.dart';
import 'package:nonna_app/tiles/registry_highlights/widgets/registry_highlights_tile.dart';

RegistryItemWithStatus _makeItem({
  String id = 'r1',
  String name = 'Baby Monitor',
  int priority = 3,
  bool isPurchased = false,
}) {
  final now = DateTime.now();
  return RegistryItemWithStatus(
    item: RegistryItem(
      id: id,
      babyProfileId: 'bp1',
      createdByUserId: 'u1',
      name: name,
      priority: priority,
      createdAt: now,
      updatedAt: now,
    ),
    isPurchased: isPurchased,
  );
}

Widget _buildWidget({
  List<RegistryItemWithStatus> items = const [],
  bool isLoading = false,
  String? error,
  void Function(RegistryItemWithStatus)? onItemTap,
  VoidCallback? onRefresh,
  VoidCallback? onViewAll,
}) {
  return MaterialApp(
    home: Scaffold(
      body: RegistryHighlightsTile(
        items: items,
        isLoading: isLoading,
        error: error,
        onItemTap: onItemTap,
        onRefresh: onRefresh,
        onViewAll: onViewAll,
      ),
    ),
  );
}

void main() {
  group('RegistryHighlightsTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('registry_highlights_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Fetch error'));
      expect(find.text('Fetch error'), findsOneWidget);
    });

    testWidgets('shows empty state when items list is empty', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('No registry items'), findsOneWidget);
    });

    testWidgets('shows items when provided', (tester) async {
      final items = [
        _makeItem(id: 'r1', name: 'Monitor'),
        _makeItem(id: 'r2', name: 'Crib'),
      ];
      await tester.pumpWidget(_buildWidget(items: items));
      expect(find.byKey(const Key('registry_item_r1')), findsOneWidget);
      expect(find.byKey(const Key('registry_item_r2')), findsOneWidget);
    });

    testWidgets('shows at most 5 items', (tester) async {
      final items = List.generate(7, (i) => _makeItem(id: 'r$i', name: 'Item $i'));
      await tester.pumpWidget(_buildWidget(items: items));
      int count = 0;
      for (int i = 0; i < 5; i++) {
        if (tester.any(find.byKey(Key('registry_item_r$i')))) count++;
      }
      expect(count, 5);
      expect(find.byKey(const Key('registry_item_r5')), findsNothing);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Registry Highlights'), findsOneWidget);
    });

    testWidgets('calls onItemTap when item is tapped', (tester) async {
      RegistryItemWithStatus? tappedItem;
      final item = _makeItem();
      await tester.pumpWidget(
        _buildWidget(items: [item], onItemTap: (i) => tappedItem = i),
      );
      await tester.tap(find.byKey(const Key('registry_item_r1')));
      expect(tappedItem, equals(item));
    });

    testWidgets('shows priority badge for each item', (tester) async {
      final item = _makeItem(id: 'r1');
      await tester.pumpWidget(_buildWidget(items: [item]));
      expect(find.byKey(const Key('priority_badge_r1')), findsOneWidget);
    });

    testWidgets('shows purchase status icon for each item', (tester) async {
      final item = _makeItem(id: 'r1', isPurchased: true);
      await tester.pumpWidget(_buildWidget(items: [item]));
      expect(find.byKey(const Key('purchase_status_r1')), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows unpurchased icon when not purchased', (tester) async {
      final item = _makeItem(id: 'r1', isPurchased: false);
      await tester.pumpWidget(_buildWidget(items: [item]));
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('shows view all button when onViewAll is provided', (tester) async {
      await tester.pumpWidget(_buildWidget(onViewAll: () {}));
      expect(find.byKey(const Key('registry_highlights_view_all')), findsOneWidget);
    });

    testWidgets('view all button calls onViewAll callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildWidget(onViewAll: () => called = true));
      await tester.tap(find.byKey(const Key('registry_highlights_view_all')));
      expect(called, isTrue);
    });

    testWidgets('error retry calls onRefresh', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _buildWidget(error: 'Oops', onRefresh: () => called = true),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      expect(called, isTrue);
    });
  });
}
