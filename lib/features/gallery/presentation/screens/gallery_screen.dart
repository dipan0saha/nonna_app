import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/gallery/presentation/providers/gallery_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/user_baby_profiles_provider.dart';
import 'package:nonna_app/features/home/presentation/widgets/tile_list_view.dart';
import 'package:nonna_app/tiles/gallery_favorites/providers/gallery_favorites_provider.dart';
import 'package:nonna_app/tiles/recent_photos/providers/recent_photos_provider.dart';

/// Gallery screen showing a photo gallery for a baby profile via tile configs.
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({
    super.key,
    this.babyProfileId,
    this.userRole,
    this.title = 'Gallery',
    this.screenId = 'gallery',
  });

  /// ID of the baby profile whose photos to display
  final String? babyProfileId;

  /// Current user's role (owner sees upload FAB)
  final UserRole? userRole;

  /// Screen title (e.g. "Gallery", "Favorite Photos")
  final String title;

  /// Screen ID for tile loading (e.g. "gallery", "gallery_favorites")
  final String screenId;

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
    final currentRole = widget.userRole ??
        ref.read(homeScreenProvider).selectedRole ??
        UserRole.follower;

    if (babyProfileId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(galleryScreenProvider.notifier).loadTiles(
              babyProfileId: babyProfileId,
              screenId: widget.screenId,
              role: currentRole,
            );
      });
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(galleryScreenProvider.notifier).refresh(widget.screenId);
  }

  Future<void> _onUploadTap(String babyProfileId) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again to upload photos.')),
      );
      return;
    }

    try {
      final storageService = ref.read(storageServiceProvider);
      final databaseService = ref.read(databaseServiceProvider);

      final imageFile = await storageService.pickImageFromGallery();
      if (imageFile == null) {
        return;
      }

      final captionResult = await _promptForCaption();
      if (captionResult == null) {
        return;
      }
      final caption =
          captionResult.trim().isEmpty ? null : captionResult.trim();

      String storagePath;
      String? thumbnailPath;

      try {
        final uploadResult = await storageService.uploadPhotoWithThumbnail(
          imageFile: imageFile,
          babyProfileId: babyProfileId,
          caption: caption,
        );
        storagePath = uploadResult['photo_path']!;
        thumbnailPath = uploadResult['thumbnail_path'];
      } catch (e) {
        debugPrint(
          '⚠️ Thumbnail upload failed, falling back to photo-only upload: $e',
        );
        storagePath = await storageService.uploadGalleryPhoto(
          imageFile: imageFile,
          babyProfileId: babyProfileId,
          caption: caption,
        );
      }

      await databaseService.insert(
        SupabaseTables.photos,
        {
          'baby_profile_id': babyProfileId,
          'uploaded_by_user_id': userId,
          'storage_path': storagePath,
          'thumbnail_path': thumbnailPath,
          'caption': caption,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      await ref
          .read(recentPhotosProvider.notifier)
          .refresh(babyProfileId: babyProfileId);
      await ref
          .read(galleryFavoritesProvider.notifier)
          .refresh(babyProfileId: babyProfileId);

      await ref.read(galleryScreenProvider.notifier).refresh(widget.screenId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo uploaded successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload photo: $e')),
      );
    }
  }

  Future<String?> _promptForCaption() async {
    var draftCaption = '';
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a caption'),
          content: TextField(
            maxLines: 3,
            textInputAction: TextInputAction.done,
            onChanged: (value) => draftCaption = value,
            decoration: const InputDecoration(
              hintText: 'Write something about this photo',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(draftCaption),
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the globally selected baby profile
    ref.listen<String?>(selectedBabyProfileProvider, (previous, next) {
      if (next != previous && next != null) {
        final currentRole = widget.userRole ??
            ref.read(homeScreenProvider).selectedRole ??
            UserRole.follower;
        ref.read(galleryScreenProvider.notifier).loadTiles(
              babyProfileId: next,
              screenId: widget.screenId,
              role: currentRole,
            );
      }
    });

    final currentBabyProfileId =
        widget.babyProfileId ?? ref.watch(selectedBabyProfileProvider);
    final resolvedRole = currentBabyProfileId != null
        ? ref
            .watch(currentUserRoleForBabyProfileProvider(currentBabyProfileId))
            .asData
            ?.value
        : null;
    final effectiveRole = widget.userRole ??
        ref.watch(homeScreenProvider).selectedRole ??
        resolvedRole ??
        UserRole.follower;

    if (currentBabyProfileId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
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
        title: Text(widget.title),
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: effectiveRole == UserRole.owner
          ? FloatingActionButton(
              key: const Key('upload_photo_fab'),
              heroTag: null,
              onPressed: () => _onUploadTap(currentBabyProfileId),
              child: const Icon(Icons.add),
            )
          : null,
      body: TileListView(
        tiles: state.tilesFor(widget.screenId),
        isLoading: state.isLoadingFor(widget.screenId),
        error: state.errorFor(widget.screenId),
        onRefresh: _onRefresh,
        onRetry: () =>
            ref.read(galleryScreenProvider.notifier).retry(widget.screenId),
      ),
    );
  }
}
