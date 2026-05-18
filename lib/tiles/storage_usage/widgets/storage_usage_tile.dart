import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/storage_usage/providers/storage_usage_provider.dart';
import 'package:nonna_app/tiles/core/tile_icons.dart';
import 'package:nonna_app/tiles/core/widgets/tile_header.dart';

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
            const TileHeader(
              icon: TileIcons.storageUsage,
              title: 'Storage Usage',
            ),
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
        // Centred donut chart (used vs available)
        _StorageDonutChart(info: info, usedColor: barColor),
        AppSpacing.verticalGapS,
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

// ---------------------------------------------------------------------------
// Donut chart showing used vs available storage
// ---------------------------------------------------------------------------

class _StorageDonutChart extends StatefulWidget {
  const _StorageDonutChart({required this.info, required this.usedColor});

  final StorageUsageInfo info;
  final Color usedColor;

  @override
  State<_StorageDonutChart> createState() => _StorageDonutChartState();
}

class _StorageDonutChartState extends State<_StorageDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final pct = widget.info.usagePercentage.clamp(0.0, 100.0);
    const availableColor = Color(0xFFBBDEFB); // Material blue-100

    final sections = [
      PieChartSectionData(
        color: widget.usedColor,
        value: widget.info.usedBytes.toDouble(),
        title: _touchedIndex == 0 ? '${pct.toStringAsFixed(0)}%' : '',
        radius: _touchedIndex == 0 ? 58 : 52,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: availableColor,
        value: widget.info.availableBytes.toDouble(),
        title: _touchedIndex == 1 ? '${(100 - pct).toStringAsFixed(0)}%' : '',
        radius: _touchedIndex == 1 ? 58 : 52,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    ];

    return Center(
      child: Column(
        children: [
          SizedBox(
            key: const Key('storage_donut_chart'),
            height: 130,
            width: 130,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                centerSpaceRadius: 0,
                sectionsSpace: 2,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Mini legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: widget.usedColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text('Used', style: context.textTheme.labelSmall),
              const SizedBox(width: AppSpacing.m),
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: availableColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text('Available', style: context.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
