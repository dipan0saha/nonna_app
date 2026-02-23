import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/registry/presentation/screens/registry_item_creation_screen.dart';

Widget _buildScreen({VoidCallback? onCreated, VoidCallback? onCancelled}) {
  return ProviderScope(
    child: MaterialApp(
      home: RegistryItemCreationScreen(
        babyProfileId: 'baby-1',
        createdByUserId: 'user-1',
        onCreated: onCreated,
        onCancelled: onCancelled,
      ),
    ),
  );
}

void main() {
  group('RegistryItemCreationScreen', () {
    testWidgets("renders Scaffold with key 'registry_item_creation_screen'",
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(
        find.byKey(const Key('registry_item_creation_screen')),
        findsOneWidget,
      );
    });

    testWidgets('shows app bar title "Add Registry Item"', (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(find.text('Add Registry Item'), findsOneWidget);
    });

    testWidgets('renders name, description and link fields', (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(find.byKey(const Key('item_name_field')), findsOneWidget);
      expect(find.byKey(const Key('item_description_field')), findsOneWidget);
      expect(find.byKey(const Key('item_link_field')), findsOneWidget);
    });

    testWidgets('renders priority slider', (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(find.byKey(const Key('priority_slider')), findsOneWidget);
    });

    testWidgets('shows validation error when name is empty', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.tap(find.byKey(const Key('save_item_button')));
      await tester.pump();
      expect(find.text('Item name is required'), findsOneWidget);
    });

    testWidgets('calls onCreated after saving valid item', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildScreen(onCreated: () => called = true));
      await tester.enterText(
          find.byKey(const Key('item_name_field')), 'Baby Crib');
      await tester.tap(find.byKey(const Key('save_item_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(called, isTrue);
    });

    testWidgets('renders save item button', (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(find.byKey(const Key('save_item_button')), findsOneWidget);
    });
  });
}
