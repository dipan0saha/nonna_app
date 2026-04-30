import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/models/user.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/features/registry/presentation/providers/registry_screen_provider.dart';
import 'package:nonna_app/features/registry/presentation/screens/registry_item_detail_screen.dart';

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

class _MockHomeScreenNotifier extends HomeScreenNotifier {
  final UserRole initialRole;
  _MockHomeScreenNotifier(this.initialRole);

  @override
  HomeScreenState build() {
    return HomeScreenState(selectedRole: initialRole);
  }
}

Widget _buildScreen(
  RegistryItem item, {
  bool isPurchased = false,
  int purchaseCount = 0,
  bool isOwner = false,
}) {
  final itemWithStatus = RegistryItemWithStatus(
    item: item,
    isPurchased: isPurchased,
    purchaseCount: purchaseCount,
    purchasers: isPurchased
        ? [
            User(
              userId: 'u1',
              displayName: 'John Doe',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          ]
        : [],
    isPurchasedByCurrentUser: false,
  );

  return ProviderScope(
    overrides: [
      homeScreenProvider.overrideWith(() => _MockHomeScreenNotifier(
            isOwner ? UserRole.owner : UserRole.follower,
          )),
      registryScreenProvider.overrideWith(() => _MockRegistryScreenNotifier(
            RegistryScreenState(items: [itemWithStatus]),
          )),
    ],
    child: MaterialApp(
      home: RegistryItemDetailScreen(
        item: item,
      ),
    ),
  );
}

class _MockRegistryScreenNotifier extends RegistryScreenNotifier {
  final RegistryScreenState _initialState;

  _MockRegistryScreenNotifier(this._initialState);

  @override
  RegistryScreenState build() {
    return _initialState;
  }
}

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

    testWidgets('shows purchased status when item is purchased',
        (tester) async {
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
