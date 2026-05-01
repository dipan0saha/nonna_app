import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/features/gallery/presentation/providers/gallery_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/widgets/tile_list_view.dart';

/// Gallery screen showing a photo gallery for a baby profile via tile configs.
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({
    super.key,
    this.babyProfileId,
    this.userRole,
  });

  /// ID of the baby profile whose photos to display
  final String? babyProfileId;

  /// Current user's role (owner sees upload FAB)
  final UserRole? userRole;

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  @override
  void initState() {
    super.initState();
    _loadTilesIfReady();
  }

  @override
  void didUpdateWidget(GalleryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.babyProfileId != oldWidget.babyProfileId) {
      _loadTilesIfReady();
    }
  }

  void _loadTilesIfReady() {
    final babyProfileId =
        widget.babyProfileId ?? ref.read(selectedBabyProfileProvider);
    // Determine the role or default to follower
    final currentRole = widget.userRole ?? UserRole.follower;

    if (babyProfileId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(galleryScreenProvider.notifier).loadTiles(
              babyProfileId: babyProfileId,
              role: currentRole,
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
    // Listen to changes in the globally selected baby profile
    ref.listen<String?>(selectedBabyProfileProvider, (previous, next) {
      if (next != previous && next != null) {
        final currentRole = widget.userRole ?? UserRole.follower;
        ref.read(galleryScreenProvider.notifier).loadTiles(
              babyProfileId: next,
              role: currentRole,
            );
      }
    });

    final currentBabyProfileId =
        widget.babyProfileId ?? ref.watch(selectedBabyProfileProvider);

    if (currentBabyProfileId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gallery')),
        body: const Center(
          child: EmptyState(
            message: 'Select a baby profile to view gallery',
            icon: Icons.child_care,
          ),
        ),
      );
    }

    final state = ref.watch(galleryScreenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
      ),
      floatingActionButton: widget.userRole == UserRole.owner
          ? FloatingActionButton(
              key: const Key('upload_photo_fab'),
              onPressed: _onUploadTap,
              child: const Icon(Icons.upload),
            )
          : null,
      body: TileListView(
        tiles: state.tiles,
        isLoading: state.isLoading,
        error: state.error,
        onRefresh: _onRefresh,
        onRetry: () => ref.read(galleryScreenProvider.notifier).retry(),
      ),
    );
  }
}
