import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/models/registry_purchase.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/recent_purchases/widgets/recent_purchases_tile.dart';

RegistryPurchase _makePurchase({
  String id = 'p1',
  String registryItemId = 'ri-abcdef12',
  String? note,
}) {
  final now = DateTime.now();
  return RegistryPurchase(
    id: id,
    registryItemId: registryItemId,
    purchasedByUserId: 'u1',
    purchasedAt: now.subtract(const Duration(hours: 2)),
    note: note,
    createdAt: now,
  );
}

Widget _buildWidget({
  List<RegistryPurchase> purchases = const [],
  bool isLoading = false,
  String? error,
  void Function(RegistryPurchase)? onPurchaseTap,
  VoidCallback? onRefresh,
  VoidCallback? onViewAll,
}) {
  return MaterialApp(
    home: Scaffold(
      body: RecentPurchasesTile(
        purchases: purchases,
        isLoading: isLoading,
        error: error,
        onPurchaseTap: onPurchaseTap,
        onRefresh: onRefresh,
        onViewAll: onViewAll,
      ),
    ),
  );
}

void main() {
  group('RecentPurchasesTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('recent_purchases_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Fetch failed'));
      expect(find.text('Fetch failed'), findsOneWidget);
    });

    testWidgets('shows empty state when purchases list is empty',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('No recent purchases'), findsOneWidget);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Recent Purchases'), findsOneWidget);
    });

    testWidgets('shows purchases when provided', (tester) async {
      final purchases = [
        _makePurchase(id: 'p1'),
        _makePurchase(id: 'p2'),
      ];
      await tester.pumpWidget(_buildWidget(purchases: purchases));
      expect(find.byKey(const Key('purchase_row_p1')), findsOneWidget);
      expect(find.byKey(const Key('purchase_row_p2')), findsOneWidget);
    });

    testWidgets('shows at most 5 purchases', (tester) async {
      final purchases = List.generate(7, (i) => _makePurchase(id: 'p$i'));
      await tester.pumpWidget(_buildWidget(purchases: purchases));
      for (int i = 0; i < 5; i++) {
        expect(find.byKey(Key('purchase_row_p$i')), findsOneWidget);
      }
      expect(find.byKey(const Key('purchase_row_p5')), findsNothing);
    });

    testWidgets('shows note when purchase has note', (tester) async {
      final purchase = _makePurchase(id: 'p1', note: 'With love!');
      await tester.pumpWidget(_buildWidget(purchases: [purchase]));
      expect(find.text('With love!'), findsOneWidget);
    });

    testWidgets('calls onPurchaseTap when row is tapped', (tester) async {
      RegistryPurchase? tapped;
      final purchase = _makePurchase(id: 'p1');
      await tester.pumpWidget(
        _buildWidget(purchases: [purchase], onPurchaseTap: (p) => tapped = p),
      );
      await tester.tap(find.byKey(const Key('purchase_row_p1')));
      expect(tapped, equals(purchase));
    });

    testWidgets('shows view all button when onViewAll is provided',
        (tester) async {
      await tester.pumpWidget(_buildWidget(onViewAll: () {}));
      expect(
          find.byKey(const Key('recent_purchases_view_all')), findsOneWidget);
    });

    testWidgets('hides view all button when onViewAll is null', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('recent_purchases_view_all')), findsNothing);
    });

    testWidgets('view all button calls onViewAll callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildWidget(onViewAll: () => called = true));
      await tester.tap(find.byKey(const Key('recent_purchases_view_all')));
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
