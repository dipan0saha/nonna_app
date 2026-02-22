import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/features/gallery/presentation/widgets/squish_photo_widget.dart';

/// Photo detail screen showing full image, metadata, and squish button.
///
/// **Functional Requirements**: Section 3.6.2 - Main App Screens Part II
class PhotoDetailScreen extends StatelessWidget {
  const PhotoDetailScreen({
    super.key,
    required this.photo,
    this.squishCount = 0,
    this.isSquished = false,
    this.onSquish,
  });

  /// The photo to display
  final Photo photo;

  /// Total squish count for this photo
  final int squishCount;

  /// Whether the current user has squished this photo
  final bool isSquished;

  /// Called when the squish button is tapped
  final VoidCallback? onSquish;

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
            // Full-screen image placeholder
            Container(
              key: const Key('photo_detail_image'),
              width: double.infinity,
              height: 300,
              color: Colors.black,
              child: Center(
                child: Text(
                  'Path: ${photo.storagePath}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption
                  if (photo.caption != null) ...[
                    Text(
                      'Caption:',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    AppSpacing.verticalGapXS,
                    Text(photo.caption!),
                    AppSpacing.verticalGapM,
                  ],
                  // Tags
                  if (photo.tags.isNotEmpty) ...[
                    Text(
                      'Tags:',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    AppSpacing.verticalGapXS,
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: photo.tags
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
                    'Uploaded: ${DateFormat('MMM d, yyyy').format(photo.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  AppSpacing.verticalGapL,
                  // Squish section
                  SquishPhotoWidget(
                    squishCount: squishCount,
                    isSquished: isSquished,
                    onSquish: onSquish,
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
