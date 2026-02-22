import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/registry/presentation/providers/registry_screen_provider.dart';
import 'package:nonna_app/features/registry/presentation/widgets/registry_filter_bar.dart';

Widget _buildWidget({
  RegistryFilter currentFilter = RegistryFilter.all,
  RegistrySort currentSort = RegistrySort.priorityHigh,
  ValueChanged<RegistryFilter>? onFilterChanged,
  ValueChanged<RegistrySort>? onSortChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      body: RegistryFilterBar(
        currentFilter: currentFilter,
        currentSort: currentSort,
        onFilterChanged: onFilterChanged,
        onSortChanged: onSortChanged,
      ),
    ),
  );
}

void main() {
  group('RegistryFilterBar', () {
    testWidgets('renders All filter chip as selected by default',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      final chip = tester.widget<ChoiceChip>(
        find.byKey(const Key('filter_chip_all')),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('renders all four filter chips', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('filter_chip_all')), findsOneWidget);
      expect(find.byKey(const Key('filter_chip_highPriority')), findsOneWidget);
      expect(find.byKey(const Key('filter_chip_purchased')), findsOneWidget);
      expect(find.byKey(const Key('filter_chip_unpurchased')), findsOneWidget);
    });

    testWidgets('calls onFilterChanged when a chip is tapped', (tester) async {
      RegistryFilter? selected;
      await tester.pumpWidget(
        _buildWidget(onFilterChanged: (f) => selected = f),
      );
      await tester.tap(find.byKey(const Key('filter_chip_purchased')));
      await tester.pump();
      expect(selected, RegistryFilter.purchased);
    });

    testWidgets('renders sort dropdown', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('sort_dropdown')), findsOneWidget);
    });

    testWidgets('calls onSortChanged when sort option selected', (tester) async {
      RegistrySort? selected;
      await tester.pumpWidget(
        _buildWidget(onSortChanged: (s) => selected = s),
      );
      // Open the dropdown
      await tester.tap(find.byKey(const Key('sort_dropdown')));
      await tester.pumpAndSettle();
      // Select 'Name: A–Z'
      await tester.tap(find.text('Name: A–Z').last);
      await tester.pumpAndSettle();
      expect(selected, RegistrySort.nameAsc);
    });
  });
}
