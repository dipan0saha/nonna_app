import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/checklist/providers/checklist_provider.dart';

export 'package:nonna_app/tiles/checklist/providers/checklist_provider.dart'
    show ChecklistItem;

/// Tile widget that displays the onboarding checklist with completion progress.
class ChecklistTile extends StatelessWidget {
  const ChecklistTile({
    super.key,
    required this.items,
    this.completedCount = 0,
    this.progressPercentage = 0.0,
    this.isLoading = false,
    this.error,
    this.onItemToggle,
    this.onRefresh,
  });

  final List<ChecklistItem> items;
  final int completedCount;
  final double progressPercentage;
  final bool isLoading;
  final String? error;

  /// Called when the user taps a checklist item to toggle its completion.
  final void Function(ChecklistItem)? onItemToggle;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('checklist_tile'),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            AppSpacing.verticalGapS,
            _buildBody(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Getting Started', style: context.textTheme.titleMedium),
            ),
            Text(
              key: const Key('checklist_progress_text'),
              '$completedCount/${items.isEmpty ? 0 : items.length}',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceSecondary(context.colorScheme),
              ),
            ),
          ],
        ),
        if (!isLoading && error == null && items.isNotEmpty) ...[
          AppSpacing.verticalGapXS,
          LinearProgressIndicator(
            key: const Key('checklist_progress_bar'),
            value: progressPercentage / 100,
            backgroundColor:
                AppColors.onSurfaceHint(context.colorScheme).withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Column(
        children: [
          ShimmerListTile(),
          ShimmerListTile(),
          ShimmerListTile(),
        ],
      );
    }

    if (error != null) {
      return InlineErrorView(message: error!, onRetry: onRefresh);
    }

    if (items.isEmpty) {
      return const CompactEmptyState(
        message: 'No checklist items',
        icon: Icons.checklist_outlined,
      );
    }

    final display = items.take(5).toList();
    return Column(
      children: display
          .map((item) => _ChecklistRow(item: item, onToggle: onItemToggle))
          .toList(),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item, this.onToggle});

  final ChecklistItem item;
  final void Function(ChecklistItem)? onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('checklist_item_${item.id}'),
      onTap: onToggle != null ? () => onToggle!(item) : null,
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              item.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              key: Key('checklist_icon_${item.id}'),
              color: item.isCompleted
                  ? AppColors.primary
                  : AppColors.onSurfaceHint(context.colorScheme),
              size: 20,
            ),
            AppSpacing.horizontalGapS,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: item.isCompleted
                          ? AppColors.onSurfaceHint(context.colorScheme)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
