import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/registry_deals/widgets/registry_deals_tile.dart';

RegistryItem _makeDeal({
  String id = 'd1',
  String name = 'Baby Monitor',
  int priority = 4,
  String? description,
  String? linkUrl,
}) {
  final now = DateTime.now();
  return RegistryItem(
    id: id,
    babyProfileId: 'bp1',
    createdByUserId: 'u1',
    name: name,
    description: description,
    linkUrl: linkUrl,
    priority: priority,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _buildWidget({
  List<RegistryItem> deals = const [],
  bool isLoading = false,
  String? error,
  void Function(RegistryItem)? onDealTap,
  VoidCallback? onRefresh,
  VoidCallback? onViewAll,
}) {
  return MaterialApp(
    home: Scaffold(
      body: RegistryDealsTile(
        deals: deals,
        isLoading: isLoading,
        error: error,
        onDealTap: onDealTap,
        onRefresh: onRefresh,
        onViewAll: onViewAll,
      ),
    ),
  );
}

void main() {
  group('RegistryDealsTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('registry_deals_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Network error'));
      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('shows empty state when deals list is empty', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('No recommended items'), findsOneWidget);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Registry Deals'), findsOneWidget);
    });

    testWidgets('shows deals when provided', (tester) async {
      final deals = [
        _makeDeal(id: 'd1', name: 'Monitor'),
        _makeDeal(id: 'd2', name: 'Crib'),
      ];
      await tester.pumpWidget(_buildWidget(deals: deals));
      expect(find.byKey(const Key('deal_row_d1')), findsOneWidget);
      expect(find.byKey(const Key('deal_row_d2')), findsOneWidget);
    });

    testWidgets('shows at most 5 deals', (tester) async {
      final deals = List.generate(7, (i) => _makeDeal(id: 'd$i'));
      await tester.pumpWidget(_buildWidget(deals: deals));
      for (int i = 0; i < 5; i++) {
        expect(find.byKey(Key('deal_row_d$i')), findsOneWidget);
      }
      expect(find.byKey(const Key('deal_row_d5')), findsNothing);
    });

    testWidgets('shows priority badge for each deal', (tester) async {
      final deal = _makeDeal(id: 'd1', priority: 5);
      await tester.pumpWidget(_buildWidget(deals: [deal]));
      expect(find.byKey(const Key('deal_priority_badge_d1')), findsOneWidget);
    });

    testWidgets('shows link icon when linkUrl is present', (tester) async {
      final deal = _makeDeal(id: 'd1', linkUrl: 'https://example.com');
      await tester.pumpWidget(_buildWidget(deals: [deal]));
      expect(find.byKey(const Key('deal_link_d1')), findsOneWidget);
    });

    testWidgets('hides link icon when linkUrl is null', (tester) async {
      final deal = _makeDeal(id: 'd1');
      await tester.pumpWidget(_buildWidget(deals: [deal]));
      expect(find.byKey(const Key('deal_link_d1')), findsNothing);
    });

    testWidgets('shows description when present', (tester) async {
      final deal = _makeDeal(id: 'd1', description: 'Great deal!');
      await tester.pumpWidget(_buildWidget(deals: [deal]));
      expect(find.text('Great deal!'), findsOneWidget);
    });

    testWidgets('calls onDealTap when row is tapped', (tester) async {
      RegistryItem? tapped;
      final deal = _makeDeal(id: 'd1');
      await tester.pumpWidget(
        _buildWidget(deals: [deal], onDealTap: (d) => tapped = d),
      );
      await tester.tap(find.byKey(const Key('deal_row_d1')));
      expect(tapped, equals(deal));
    });

    testWidgets('shows view all button when onViewAll is provided',
        (tester) async {
      await tester.pumpWidget(_buildWidget(onViewAll: () {}));
      expect(find.byKey(const Key('registry_deals_view_all')), findsOneWidget);
    });

    testWidgets('hides view all button when onViewAll is null', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('registry_deals_view_all')), findsNothing);
    });

    testWidgets('view all button calls onViewAll callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildWidget(onViewAll: () => called = true));
      await tester.tap(find.byKey(const Key('registry_deals_view_all')));
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
