import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/features/registry/presentation/providers/registry_screen_provider.dart';

/// A filter and sort bar for the registry screen.
///
/// Shows a sort dropdown.
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

  static const _sortLabels = <RegistrySort, String>{
    RegistrySort.priorityHigh: 'Priority: High First',
    RegistrySort.priorityLow: 'Priority: Low First',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: DropdownButton<RegistrySort>(
              key: const Key('sort_dropdown'),
              value: currentSort,
              underline: const SizedBox.shrink(),
              isDense: true,
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
          ),
        ],
      ),
    );
  }
}
