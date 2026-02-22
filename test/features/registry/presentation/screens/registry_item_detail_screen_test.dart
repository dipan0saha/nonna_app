import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/features/registry/presentation/screens/registry_item_detail_screen.dart';

// ---------------------------------------------------------------------------
// Helper factory for RegistryItem
// ---------------------------------------------------------------------------

RegistryItem _makeItem({
  String id = 'i1',
  String name = 'Crib',
  String? description,
  String? linkUrl,
  int priority = 3,
  DateTime? createdAt,
}) {
  final now = createdAt ?? DateTime(2024, 6, 1);
  return RegistryItem(
    id: id,
    babyProfileId: 'b1',
    createdByUserId: 'u1',
    name: name,
    description: description,
    linkUrl: linkUrl,
    priority: priority,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _buildScreen(
  RegistryItem item, {
  bool isPurchased = false,
  int purchaseCount = 0,
  bool isOwner = false,
  VoidCallback? onPurchase,
  VoidCallback? onEdit,
  VoidCallback? onLinkTap,
}) {
  return MaterialApp(
    home: RegistryItemDetailScreen(
      item: item,
      isPurchased: isPurchased,
      purchaseCount: purchaseCount,
      isOwner: isOwner,
      onPurchase: onPurchase,
      onEdit: onEdit,
      onLinkTap: onLinkTap,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RegistryItemDetailScreen', () {
    testWidgets('renders item name in app bar', (tester) async {
      await tester.pumpWidget(_buildScreen(_makeItem(name: 'Crib')));
      expect(find.text('Crib'), findsOneWidget);
    });

    testWidgets('shows edit button for owner', (tester) async {
      await tester.pumpWidget(_buildScreen(_makeItem(), isOwner: true));
      expect(find.byKey(const Key('edit_item_button')), findsOneWidget);
    });

    testWidgets('hides edit button for non-owner', (tester) async {
      await tester.pumpWidget(_buildScreen(_makeItem(), isOwner: false));
      expect(find.byKey(const Key('edit_item_button')), findsNothing);
    });

    testWidgets('shows description when present', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makeItem(description: 'A safe crib')),
      );
      expect(find.text('A safe crib'), findsOneWidget);
      expect(find.text('Description:'), findsOneWidget);
    });

    testWidgets('shows purchased status when item is purchased', (tester) async {
      await tester.pumpWidget(_buildScreen(_makeItem(), isPurchased: true));
      expect(find.text('Purchased'), findsOneWidget);
    });

    testWidgets('shows not purchased status when item is not purchased',
        (tester) async {
      await tester.pumpWidget(_buildScreen(_makeItem(), isPurchased: false));
      expect(find.text('Not yet purchased'), findsOneWidget);
    });

    testWidgets('shows purchase button for non-owner when not purchased',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makeItem(), isOwner: false, isPurchased: false),
      );
      expect(find.byKey(const Key('purchase_button')), findsOneWidget);
    });

    testWidgets('hides purchase button for owner', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makeItem(), isOwner: true, isPurchased: false),
      );
      expect(find.byKey(const Key('purchase_button')), findsNothing);
    });
  });
}
