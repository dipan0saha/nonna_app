import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/tile_config.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';

/// Scrollable list of home screen tiles
///
/// **Functional Requirements**: Section 3.6.2 - Main App Screens Part I
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Shimmer loading state (3 cards)
/// - Empty state when no tiles
/// - Error state with retry
/// - Pull-to-refresh support
/// - Renders each TileConfig as a simple Card
class TileListView extends StatelessWidget {
  const TileListView({
    super.key,
    required this.tiles,
    this.isLoading = false,
    this.error,
    this.onRefresh,
    this.onRetry,
  });

  /// List of tile configurations to display
  final List<TileConfig> tiles;

  /// Whether tiles are currently loading
  final bool isLoading;

  /// Error message, if any
  final String? error;

  /// Called when the user pulls to refresh
  final Future<void> Function()? onRefresh;

  /// Called when the user taps retry after an error
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _ShimmerList();
    }

    if (error != null) {
      return ErrorView(
        message: error!,
        onRetry: onRetry,
      );
    }

    if (tiles.isEmpty) {
      return const EmptyState(
        key: Key('tile_list_view'),
        message: 'No tiles to display',
        icon: Icons.dashboard_outlined,
      );
    }

    final content = ListView.builder(
      key: const Key('tile_list_view'),
      padding: AppSpacing.cardPadding,
      itemCount: tiles.length,
      itemBuilder: (context, index) => _TileCard(tile: tiles[index]),
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        key: const Key('tile_list_refresh_indicator'),
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return content;
  }
}

/// Shimmer loading list showing 3 placeholder cards
class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const Key('tile_list_view'),
      padding: AppSpacing.cardPadding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, _) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.m),
        child: ShimmerCard(height: 120),
      ),
    );
  }
}

/// Simple card representing a single tile
class _TileCard extends StatelessWidget {
  const _TileCard({required this.tile});

  final TileConfig tile;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            const Icon(Icons.dashboard_outlined, size: 32),
            AppSpacing.horizontalGapM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tile.tileDefinitionId,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Order: ${tile.displayOrder}',
                    style: Theme.of(context).textTheme.bodySmall,
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
