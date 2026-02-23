import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/gallery_favorites/providers/gallery_favorites_provider.dart';

export 'package:nonna_app/tiles/gallery_favorites/providers/gallery_favorites_provider.dart'
    show PhotoWithSquishes;

/// Tile widget that displays the gallery's most-squished (favorite) photos.
class GalleryFavoritesTile extends StatelessWidget {
  const GalleryFavoritesTile({
    super.key,
    required this.favorites,
    this.isLoading = false,
    this.error,
    this.onPhotoTap,
    this.onRefresh,
    this.onViewAll,
  });

  /// Most-squished photos to display.
  final List<PhotoWithSquishes> favorites;
  final bool isLoading;
  final String? error;
  final void Function(Photo)? onPhotoTap;
  final VoidCallback? onRefresh;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('gallery_favorites_tile'),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TileHeader(
              title: 'Gallery Favorites',
              onViewAll: onViewAll,
              viewAllKey: const Key('gallery_favorites_view_all'),
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
          ShimmerListTile(),
        ],
      );
    }

    if (error != null) {
      return InlineErrorView(message: error!, onRetry: onRefresh);
    }

    if (favorites.isEmpty) {
      return const CompactEmptyState(
        message: 'No favorites yet',
        icon: Icons.favorite_outline,
      );
    }

    final display = favorites.take(5).toList();
    return Column(
      children: display
          .map((item) => _FavoriteRow(item: item, onTap: onPhotoTap))
          .toList(),
    );
  }
}

class _FavoriteRow extends StatelessWidget {
  const _FavoriteRow({required this.item, this.onTap});

  final PhotoWithSquishes item;
  final void Function(Photo)? onTap;

  @override
  Widget build(BuildContext context) {
    final photo = item.photo;
    return InkWell(
      key: Key('favorite_photo_${photo.id}'),
      onTap: onTap != null ? () => onTap!(photo) : null,
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              Icons.photo_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            AppSpacing.horizontalGapS,
            Expanded(
              child: Text(
                photo.caption ?? photo.id,
                style: context.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppSpacing.horizontalGapS,
            _SquishBadge(
              key: Key('squish_badge_${photo.id}'),
              count: item.squishCount,
            ),
          ],
        ),
      ),
    );
  }
}

class _SquishBadge extends StatelessWidget {
  const _SquishBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.favorite, size: 14, color: Colors.pink),
        AppSpacing.horizontalGapXS,
        Text(
          '$count',
          style: context.textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceSecondary(context.colorScheme),
          ),
        ),
      ],
    );
  }
}

class _TileHeader extends StatelessWidget {
  const _TileHeader({
    required this.title,
    this.onViewAll,
    this.viewAllKey,
  });

  final String title;
  final VoidCallback? onViewAll;
  final Key? viewAllKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: context.textTheme.titleMedium),
        ),
        if (onViewAll != null)
          TextButton(
            key: viewAllKey,
            onPressed: onViewAll,
            child: const Text('View all'),
          ),
      ],
    );
  }
}
