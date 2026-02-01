import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('displays message', (tester) async {
      const message = 'No items found';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(message: message),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('displays default icon when not specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(message: 'No items'),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('displays custom icon when specified', (tester) async {
      const customIcon = Icons.folder_outlined;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'No items',
              icon: customIcon,
            ),
          ),
        ),
      );

      expect(find.byIcon(customIcon), findsOneWidget);
    });

    testWidgets('displays title when provided', (tester) async {
      const title = 'Empty State';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'No items',
              title: title,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
    });

    testWidgets('hides title when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(message: 'No items'),
          ),
        ),
      );

      // Only the message should be found, not a separate title
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('displays description when provided', (tester) async {
      const description = 'Additional information';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'No items',
              description: description,
            ),
          ),
        ),
      );

      expect(find.text(description), findsOneWidget);
    });

    testWidgets('displays action button when onAction and actionLabel provided',
        (tester) async {
      const actionLabel = 'Add Item';
      var actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'No items',
              actionLabel: actionLabel,
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text(actionLabel), findsOneWidget);

      await tester.tap(find.text(actionLabel));
      expect(actionTapped, isTrue);
    });

    testWidgets('hides action button when onAction is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'No items',
              actionLabel: 'Add Item',
            ),
          ),
        ),
      );

      expect(find.text('Add Item'), findsNothing);
    });

    testWidgets('hides action button when actionLabel is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'No items',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('is centered on screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(message: 'No items'),
          ),
        ),
      );

      final center = find.ancestor(
        of: find.byType(Column),
        matching: find.byType(Center),
      );

      expect(center, findsOneWidget);
    });

    testWidgets('action button invokes callback when tapped', (tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'No items',
              actionLabel: 'Action',
              onAction: () => callCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Action'));
      expect(callCount, equals(1));

      await tester.tap(find.text('Action'));
      expect(callCount, equals(2));
    });

    testWidgets('displays all elements when fully configured', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Empty',
              message: 'No items found',
              description: 'Try adding some',
              icon: Icons.search,
              actionLabel: 'Add',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Empty'), findsOneWidget);
      expect(find.text('No items found'), findsOneWidget);
      expect(find.text('Try adding some'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });
  });

  group('CompactEmptyState', () {
    testWidgets('displays message', (tester) async {
      const message = 'No data';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactEmptyState(message: message),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('displays default icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactEmptyState(message: 'No data'),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('displays custom icon when specified', (tester) async {
      const customIcon = Icons.cloud_off;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactEmptyState(
              message: 'No data',
              icon: customIcon,
            ),
          ),
        ),
      );

      expect(find.byIcon(customIcon), findsOneWidget);
    });

    testWidgets('is centered', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactEmptyState(message: 'No data'),
          ),
        ),
      );

      final center = find.ancestor(
        of: find.byType(Column),
        matching: find.byType(Center),
      );

      expect(center, findsOneWidget);
    });

    testWidgets('has smaller icon than regular EmptyState', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactEmptyState(message: 'No data'),
          ),
        ),
      );

      final icon = tester.widget<Icon>(
        find.byIcon(Icons.inbox_outlined),
      );

      expect(icon.size, equals(48.0));
    });

    testWidgets('uses Column with minimum size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactEmptyState(message: 'No data'),
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.mainAxisSize, equals(MainAxisSize.min));
    });
  });
}
