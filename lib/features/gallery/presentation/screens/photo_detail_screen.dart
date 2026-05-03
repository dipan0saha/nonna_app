import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/features/gallery/presentation/widgets/squish_photo_widget.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';

import 'package:nonna_app/tiles/gallery_favorites/providers/gallery_favorites_provider.dart';

/// Photo detail screen showing full image, metadata, and squish button.
class PhotoDetailScreen extends ConsumerStatefulWidget {
  const PhotoDetailScreen({
    super.key,
    required this.photo,
  });

  final Photo photo;

  @override
  ConsumerState<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends ConsumerState<PhotoDetailScreen> {
  int _squishCount = 0;
  bool _isSquished = false;
  bool _isLoadingSquish = true;
  String? _squishId;

  @override
  void initState() {
    super.initState();
    _loadSquishData();
  }

  Future<void> _loadSquishData() async {
    try {
      final db = ref.read(databaseServiceProvider);
      final userId = ref.read(authProvider).user?.id;

      // Get total count
      final countResponse = await db
          .select(SupabaseTables.photoSquishes, columns: 'id')
          .eq('photo_id', widget.photo.id);

      final count = (countResponse as List).length;

      // Check current user squish
      bool isSquished = false;
      String? squishId;
      if (userId != null) {
        final userSquish = await db
            .select(SupabaseTables.photoSquishes, columns: 'id')
            .eq('photo_id', widget.photo.id)
            .eq('user_id', userId)
            .maybeSingle();

        if (userSquish != null) {
          isSquished = true;
          squishId = userSquish['id'] as String;
        }
      }

      if (mounted) {
        setState(() {
          _squishCount = count;
          _isSquished = isSquished;
          _squishId = squishId;
          _isLoadingSquish = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load squish data: $e');
      if (mounted) {
        setState(() => _isLoadingSquish = false);
      }
    }
  }

  Future<void> _toggleSquish() async {
    if (_isLoadingSquish) return;

    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to respond.')),
      );
      return;
    }

    final db = ref.read(databaseServiceProvider);

    setState(() {
      _isLoadingSquish = true;
    });

    try {
      if (_isSquished && _squishId != null) {
        // Remove squish
        await db.delete(SupabaseTables.photoSquishes).eq('id', _squishId!);

        setState(() {
          _isSquished = false;
          _squishCount = (_squishCount > 0) ? _squishCount - 1 : 0;
          _squishId = null;
        });

        // Refresh favorites tile so it disappears if count goes below 1
        ref.read(galleryFavoritesProvider.notifier).refresh(
              babyProfileId: widget.photo.babyProfileId,
            );
      } else {
        // Add squish
        final responseList = await db.insert(SupabaseTables.photoSquishes, {
          'photo_id': widget.photo.id,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });

        setState(() {
          _isSquished = true;
          _squishCount++;
          if (responseList.isNotEmpty) {
            _squishId = responseList.first['id'] as String;
          }
        });

        // Refresh favorites tile so it appears
        ref.read(galleryFavoritesProvider.notifier).refresh(
              babyProfileId: widget.photo.babyProfileId,
            );
      }
    } catch (e) {
      debugPrint('Error toggling squish: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update favorite. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSquish = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-screen interactive image
            Container(
              key: const Key('photo_detail_image'),
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: 300,
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              color: Colors.black,
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: widget.photo.storagePath,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.broken_image,
                        color: Colors.white54, size: 50),
                  ),
                ),
              ),
            ),
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption
                  if (widget.photo.caption != null) ...[
                    Text(
                      'Caption:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    AppSpacing.verticalGapXS,
                    Text(widget.photo.caption!),
                    AppSpacing.verticalGapM,
                  ],
                  // Tags
                  if (widget.photo.tags.isNotEmpty) ...[
                    Text(
                      'Tags:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    AppSpacing.verticalGapXS,
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: widget.photo.tags
                          .map(
                            (tag) => Chip(
                              key: Key('photo_tag_$tag'),
                              label: Text(tag),
                            ),
                          )
                          .toList(),
                    ),
                    AppSpacing.verticalGapM,
                  ],
                  // Uploaded date
                  Text(
                    'Uploaded: ${DateFormat('MMM d, yyyy').format(widget.photo.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  AppSpacing.verticalGapL,
                  // Squish section
                  Row(
                    children: [
                      SquishPhotoWidget(
                        squishCount: _squishCount,
                        isSquished: _isSquished,
                        onSquish: _isLoadingSquish ? null : _toggleSquish,
                      ),
                      if (_isLoadingSquish) ...[
                        AppSpacing.horizontalGapS,
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      ]
                    ],
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
