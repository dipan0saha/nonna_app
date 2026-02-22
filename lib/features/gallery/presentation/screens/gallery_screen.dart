import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/widgets/error_view.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/features/gallery/presentation/providers/gallery_screen_provider.dart';

/// Gallery screen showing a photo grid for a baby profile.
///
/// **Functional Requirements**: Section 3.6.2 - Main App Screens Part II
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({
    super.key,
    this.babyProfileId,
    this.userRole,
    this.onPhotoTap,
  });

  /// ID of the baby profile whose photos to display
  final String? babyProfileId;

  /// Current user's role (owner sees upload FAB)
  final UserRole? userRole;

  /// Called when a photo tile is tapped
  final Function(Photo)? onPhotoTap;

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.babyProfileId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(galleryScreenProvider.notifier).loadPhotos(
              babyProfileId: widget.babyProfileId!,
            );
      });
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(galleryScreenProvider.notifier).refresh();
  }

  void _onUploadTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload photo – coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryScreenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          PopupMenuButton<GalleryFilter>(
            onSelected: (filter) {
              if (filter == GalleryFilter.all) {
                ref.read(galleryScreenProvider.notifier).clearFilters();
              }
              // filterByTag requires a tag input; filtering by tag is handled
              // via a separate tag-selection flow (coming soon)
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: GalleryFilter.all,
                child: Text('All'),
              ),
              const PopupMenuItem(
                value: GalleryFilter.byTag,
                child: Text('By Tag'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: widget.userRole == UserRole.owner
          ? FloatingActionButton(
              key: const Key('upload_photo_fab'),
              onPressed: _onUploadTap,
              child: const Icon(Icons.upload),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(GalleryScreenState state) {
    if (state.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.xs),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.xs,
          mainAxisSpacing: AppSpacing.xs,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const ShimmerCard(),
      );
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(galleryScreenProvider.notifier).refresh(),
      );
    }

    if (state.photos.isEmpty) {
      return const EmptyState(
        message: 'No photos yet',
        icon: Icons.photo_library_outlined,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.xs),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
      ),
      itemCount: state.photos.length,
      itemBuilder: (context, index) {
        final photo = state.photos[index];
        return GestureDetector(
          key: Key('photo_tile_$index'),
          onTap: () => widget.onPhotoTap?.call(photo),
          child: Container(
            color: Colors.grey[300],
            child: Center(
              child: Text(
                photo.caption ?? 'No caption',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        );
      },
    );
  }
}
