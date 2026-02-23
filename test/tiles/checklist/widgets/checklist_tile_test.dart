import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/checklist/providers/checklist_provider.dart';
import 'package:nonna_app/tiles/checklist/widgets/checklist_tile.dart';

ChecklistItem _makeItem({
  String id = 'item_1',
  String title = 'Task 1',
  bool isCompleted = false,
  int order = 1,
}) {
  return ChecklistItem(
    id: id,
    title: title,
    description: 'Description for $title',
    isCompleted: isCompleted,
    order: order,
  );
}

Widget _buildWidget({
  List<ChecklistItem> items = const [],
  int completedCount = 0,
  double progressPercentage = 0.0,
  bool isLoading = false,
  String? error,
  void Function(ChecklistItem)? onItemToggle,
  VoidCallback? onRefresh,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ChecklistTile(
        items: items,
        completedCount: completedCount,
        progressPercentage: progressPercentage,
        isLoading: isLoading,
        error: error,
        onItemToggle: onItemToggle,
        onRefresh: onRefresh,
      ),
    ),
  );
}

void main() {
  group('ChecklistTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('checklist_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Load failed'));
      expect(find.text('Load failed'), findsOneWidget);
    });

    testWidgets('shows empty state when items list is empty', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('No checklist items'), findsOneWidget);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Getting Started'), findsOneWidget);
    });

    testWidgets('shows progress text with completed/total counts',
        (tester) async {
      final items = [
        _makeItem(id: 'i1', isCompleted: true),
        _makeItem(id: 'i2'),
      ];
      await tester.pumpWidget(_buildWidget(
        items: items,
        completedCount: 1,
        progressPercentage: 50,
      ));
      expect(find.byKey(const Key('checklist_progress_text')), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
    });

    testWidgets('shows progress bar when items are present', (tester) async {
      final items = [_makeItem()];
      await tester.pumpWidget(
        _buildWidget(items: items, progressPercentage: 0),
      );
      expect(find.byKey(const Key('checklist_progress_bar')), findsOneWidget);
    });

    testWidgets('hides progress bar when loading', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byKey(const Key('checklist_progress_bar')), findsNothing);
    });

    testWidgets('shows item rows when items are provided', (tester) async {
      final items = [_makeItem(id: 'i1'), _makeItem(id: 'i2')];
      await tester.pumpWidget(_buildWidget(items: items));
      expect(find.byKey(const Key('checklist_item_i1')), findsOneWidget);
      expect(find.byKey(const Key('checklist_item_i2')), findsOneWidget);
    });

    testWidgets('shows at most 5 items', (tester) async {
      final items = List.generate(7, (i) => _makeItem(id: 'i$i'));
      await tester.pumpWidget(_buildWidget(items: items));
      expect(find.byType(InkWell), findsNWidgets(5));
    });

    testWidgets('shows checked icon for completed items', (tester) async {
      final items = [_makeItem(id: 'i1', isCompleted: true)];
      await tester.pumpWidget(_buildWidget(items: items));
      expect(find.byKey(const Key('checklist_icon_i1')), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows unchecked icon for incomplete items', (tester) async {
      final items = [_makeItem(id: 'i1', isCompleted: false)];
      await tester.pumpWidget(_buildWidget(items: items));
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('calls onItemToggle when item is tapped', (tester) async {
      ChecklistItem? toggled;
      final item = _makeItem(id: 'i1');
      await tester.pumpWidget(
        _buildWidget(
          items: [item],
          onItemToggle: (i) => toggled = i,
        ),
      );
      await tester.tap(find.byKey(const Key('checklist_item_i1')));
      expect(toggled, equals(item));
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
