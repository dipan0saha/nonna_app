import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/storage_usage/providers/storage_usage_provider.dart';

export 'package:nonna_app/tiles/storage_usage/providers/storage_usage_provider.dart'
    show StorageUsageInfo;

/// Tile widget that displays storage quota usage for the owner's baby profile.
class StorageUsageTile extends StatelessWidget {
  const StorageUsageTile({
    super.key,
    this.info,
    this.isLoading = false,
    this.error,
    this.onRefresh,
  });

  final StorageUsageInfo? info;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('storage_usage_tile'),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Storage Usage', style: context.textTheme.titleMedium),
            AppSpacing.verticalGapS,
            _buildBody(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Column(
        children: [
          ShimmerListTile(),
          ShimmerListTile(),
        ],
      );
    }

    if (error != null) {
      return InlineErrorView(message: error!, onRetry: onRefresh);
    }

    if (info == null) {
      return const _StorageEmpty();
    }

    return _StorageSummary(info: info!);
  }
}

class _StorageEmpty extends StatelessWidget {
  const _StorageEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        children: [
          Icon(
            Icons.storage_outlined,
            size: 20,
            color: AppColors.onSurfaceHint(context.colorScheme),
          ),
          AppSpacing.horizontalGapS,
          Text(
            'Storage data unavailable',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceHint(context.colorScheme),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageSummary extends StatelessWidget {
  const _StorageSummary({required this.info});

  final StorageUsageInfo info;

  static const _warningThreshold = 80.0;
  static const _criticalThreshold = 95.0;

  Color _barColor(double pct) {
    if (pct >= _criticalThreshold) return Colors.red;
    if (pct >= _warningThreshold) return Colors.orange;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final pct = info.usagePercentage.clamp(0.0, 100.0);
    final barColor = _barColor(pct);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${info.usedFormatted} of ${info.totalFormatted}',
              key: const Key('storage_used_text'),
              style: context.textTheme.bodyMedium,
            ),
            Text(
              '${pct.toStringAsFixed(1)}%',
              key: const Key('storage_percentage_text'),
              style: context.textTheme.bodySmall?.copyWith(
                color: barColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        AppSpacing.verticalGapXS,
        LinearProgressIndicator(
          key: const Key('storage_progress_bar'),
          value: pct / 100,
          backgroundColor:
              AppColors.onSurfaceHint(context.colorScheme).withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
        ),
        AppSpacing.verticalGapXS,
        Text(
          '${info.photoCount} photo${info.photoCount == 1 ? '' : 's'} · ${info.availableFormatted} available',
          key: const Key('storage_detail_text'),
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceSecondary(context.colorScheme),
          ),
        ),
      ],
    );
  }
}
