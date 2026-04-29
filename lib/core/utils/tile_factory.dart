import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/models/tile_config.dart';
import 'package:nonna_app/core/di/providers.dart';

// Tiles and Providers
import 'package:nonna_app/tiles/recent_photos/providers/recent_photos_provider.dart';
import 'package:nonna_app/tiles/recent_photos/widgets/recent_photos_tile.dart';

/// Factory for instantiating dynamic tiles based on their configuration.
class TileFactory {
  /// Builds the appropriate smart tile widget for a given configuration.
  static Widget buildTile(BuildContext context, TileConfig config) {
    if (config.componentName == null) {
      return _buildFallback(config);
    }

    switch (config.componentName) {
      case 'RecentPhotosTile':
        return const _RecentPhotosSmartTile();
      default:
        return _buildFallback(config);
    }
  }

  static Widget _buildFallback(TileConfig config) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.extension, size: 32, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.componentName ?? config.tileDefinitionId,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('Coming soon...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Smart Tile Wrappers
// -----------------------------------------------------------------------------

class _RecentPhotosSmartTile extends ConsumerStatefulWidget {
  const _RecentPhotosSmartTile();

  @override
  ConsumerState<_RecentPhotosSmartTile> createState() => _RecentPhotosSmartTileState();
}

class _RecentPhotosSmartTileState extends ConsumerState<_RecentPhotosSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      if (babyProfileId != null) {
        ref.read(recentPhotosProvider.notifier).fetchPhotos(babyProfileId: babyProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recentPhotosProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    // Watch for baby profile changes and re-fetch if needed
    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref.read(recentPhotosProvider.notifier).fetchPhotos(babyProfileId: current);
      }
    });

    return RecentPhotosTile(
      photos: state.photos.map((p) => PhotoWithSquishCount(photo: p, squishCount: 0, isSquished: false)).toList(),
      isLoading: state.isLoading && state.photos.isEmpty,
      error: state.error,
      onRefresh: babyProfileId != null
          ? () => ref.read(recentPhotosProvider.notifier).refresh(babyProfileId: babyProfileId)
          : null,
      onViewAll: () {},
    );
  }
}
