import re

with open('lib/core/utils/tile_factory.dart', 'r') as f:
    content = f.read()

# Replace case 'GalleryFavoritesTile'
old_case = "      case 'GalleryFavoritesTile':\n        // TODO: Implement _GalleryFavoritesSmartTile wrapper\n        return const GalleryFavoritesTile(favorites: [], isLoading: false);"
new_case = "      case 'GalleryFavoritesTile':\n        return const _GalleryFavoritesSmartTile();"
content = content.replace(old_case, new_case)

# Patch _RecentPhotosSmartTile build
old_recent_build = """    return RecentPhotosTile(
      photos: state.photos
          .map((p) =>
              PhotoWithSquishCount(photo: p, squishCount: 0, isSquished: false))
          .toList(),
      isLoading: state.isLoading && state.photos.isEmpty,
      error: state.error,
      onRefresh: babyProfileId != null
          ? () => ref
              .read(recentPhotosProvider.notifier)
              .refresh(babyProfileId: babyProfileId)
          : null,
      onViewAll: () {},
    );"""
new_recent_build = """    import 'package:go_router/go_router.dart'; // Ensure it's imported at top
    return RecentPhotosTile(
      photos: state.photos
          .map((p) =>
              PhotoWithSquishCount(photo: p, squishCount: 0, isSquished: false))
          .toList(),
      isLoading: state.isLoading && state.photos.isEmpty,
      error: state.error,
      onPhotoTap: (photo) => context.push('/gallery/photo/detail', extra: photo),
      onRefresh: babyProfileId != null
          ? () => ref
              .read(recentPhotosProvider.notifier)
              .refresh(babyProfileId: babyProfileId)
          : null,
      onViewAll: () {},
    );"""

# I need to add import 'package:go_router/go_router.dart'; at top
if "import 'package:go_router/go_router.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:go_router/go_router.dart';")

content = content.replace(old_recent_build.replace("    import 'package:go_router/go_router.dart'; // Ensure it's imported at top\n", ""), new_recent_build.replace("    import 'package:go_router/go_router.dart'; // Ensure it's imported at top\n", ""))

new_smart_tile = """

class _GalleryFavoritesSmartTile extends ConsumerStatefulWidget {
  const _GalleryFavoritesSmartTile();

  @override
  ConsumerState<_GalleryFavoritesSmartTile> createState() =>
      _GalleryFavoritesSmartTileState();
}

class _GalleryFavoritesSmartTileState
    extends ConsumerState<_GalleryFavoritesSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      if (babyProfileId != null) {
        ref
            .read(galleryFavoritesProvider.notifier)
            .fetchFavorites(babyProfileId: babyProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryFavoritesProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    // Watch for baby profile changes and re-fetch if needed
    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(galleryFavoritesProvider.notifier)
            .fetchFavorites(babyProfileId: current);
      }
    });

    return GalleryFavoritesTile(
      favorites: state.favorites,
      isLoading: state.isLoading && state.favorites.isEmpty,
      error: state.error,
      onPhotoTap: (photo) => context.push('/gallery/photo/detail', extra: photo),
      onRefresh: babyProfileId != null
          ? () => ref
              .read(galleryFavoritesProvider.notifier)
              .refresh(babyProfileId: babyProfileId)
          : null,
      onViewAll: () {},
    );
  }
}
"""

content = content + new_smart_tile

with open('lib/core/utils/tile_factory.dart', 'w') as f:
    f.write(content)
