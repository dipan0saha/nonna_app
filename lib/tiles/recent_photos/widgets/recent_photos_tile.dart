import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/tiles/recent_photos/models/photo_with_squish_count.dart';

export 'package:nonna_app/tiles/recent_photos/models/photo_with_squish_count.dart';

/// Tile widget that displays a grid of recent photos with squish counts.
class RecentPhotosTile extends StatelessWidget {
  const RecentPhotosTile({
    super.key,
    required this.photos,
    this.isLoading = false,
    this.error,
    this.onPhotoTap,
    this.onRefresh,
    this.onViewAll,
  });

  /// Photos to display. Use [PhotoWithSquishCount] to include engagement
  /// counts and the current user's squish state alongside each photo.
  final List<PhotoWithSquishCount> photos;
  final bool isLoading;
  final String? error;
  final void Function(Photo)? onPhotoTap;
  final VoidCallback? onRefresh;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('recent_photos_tile'),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              AppSpacing.verticalGapS,
              _buildBody(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('Recent Photos', style: context.textTheme.titleMedium),
        ),
        if (onViewAll != null)
          TextButton(
            key: const Key('recent_photos_view_all'),
            onPressed: onViewAll,
            child: const Text('View all'),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.xs,
        crossAxisSpacing: AppSpacing.xs,
        children: List.generate(
          6,
          (_) => ShimmerPlaceholder(
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
        ),
      );
    }

    if (error != null) {
      return InlineErrorView(message: error!, onRetry: onRefresh);
    }

    if (photos.isEmpty) {
      return const CompactEmptyState(
        message: 'No photos yet',
        icon: Icons.photo_outlined,
      );
    }

    final displayPhotos = photos.take(6).toList();
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.xs,
      crossAxisSpacing: AppSpacing.xs,
      children: displayPhotos
          .map(
            (item) => _PhotoItem(
              item: item,
              onTap: onPhotoTap,
            ),
          )
          .toList(),
    );
  }
}

class _PhotoItem extends StatelessWidget {
  const _PhotoItem({required this.item, this.onTap});

  final PhotoWithSquishCount item;
  final void Function(Photo)? onTap;

  @override
  Widget build(BuildContext context) {
    final photo = item.photo;

    return InkWell(
      key: Key('photo_item_${photo.id}'),
      onTap: onTap != null ? () => onTap!(photo) : null,
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: Stack(
        children: [
          // Photo thumbnail placeholder (coloured background)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: photo.caption != null
                  ? Center(
                      child: Padding(
                        padding: AppSpacing.compactPadding,
                        child: Text(
                          photo.caption!,
                          style: context.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.photo, color: AppColors.primaryDark),
                    ),
            ),
          ),
          // Squish count overlay
          if (item.squishCount > 0)
            Positioned(
              bottom: AppSpacing.xs / 2,
              right: AppSpacing.xs / 2,
              child: Container(
                key: Key('squish_count_${photo.id}'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.isSquished ? Icons.favorite : Icons.favorite_border,
                      size: 12,
                      color:
                          item.isSquished ? AppColors.secondary : Colors.white,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${item.squishCount}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
