import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/features/registry/presentation/providers/registry_screen_provider.dart';

/// A filter and sort bar for the registry screen.
///
/// Shows filter chips (All, High Priority, Purchased, Unpurchased) and
/// a sort dropdown.
class RegistryFilterBar extends StatelessWidget {
  const RegistryFilterBar({
    super.key,
    required this.currentFilter,
    required this.currentSort,
    this.onFilterChanged,
    this.onSortChanged,
  });

  /// Currently active filter
  final RegistryFilter currentFilter;

  /// Currently active sort
  final RegistrySort currentSort;

  /// Called when filter chip is tapped
  final ValueChanged<RegistryFilter>? onFilterChanged;

  /// Called when sort option is selected
  final ValueChanged<RegistrySort>? onSortChanged;

  static const _filterLabels = <RegistryFilter, String>{
    RegistryFilter.all: 'All',
    RegistryFilter.highPriority: 'High Priority',
    RegistryFilter.purchased: 'Purchased',
    RegistryFilter.unpurchased: 'Unpurchased',
  };

  static const _sortLabels = <RegistrySort, String>{
    RegistrySort.priorityHigh: 'Priority: High First',
    RegistrySort.priorityLow: 'Priority: Low First',
    RegistrySort.nameAsc: 'Name: A–Z',
    RegistrySort.nameDesc: 'Name: Z–A',
    RegistrySort.dateNewest: 'Date: Newest',
    RegistrySort.dateOldest: 'Date: Oldest',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: RegistryFilter.values.map((filter) {
                  final isSelected = filter == currentFilter;
                  final label = _filterLabels[filter]!;
                  final filterName = filter.name;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      key: Key('filter_chip_$filterName'),
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: AppColors.primaryDark,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                      ),
                      onSelected: (_) => onFilterChanged?.call(filter),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          AppSpacing.horizontalGapXS,
          DropdownButton<RegistrySort>(
            key: const Key('sort_dropdown'),
            value: currentSort,
            underline: const SizedBox.shrink(),
            items: RegistrySort.values
                .map(
                  (sort) => DropdownMenuItem(
                    value: sort,
                    child: Text(_sortLabels[sort]!),
                  ),
                )
                .toList(),
            onChanged: (sort) {
              if (sort != null) onSortChanged?.call(sort);
            },
          ),
        ],
      ),
    );
  }
}
