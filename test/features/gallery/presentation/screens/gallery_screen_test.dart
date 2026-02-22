import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/features/gallery/presentation/providers/gallery_screen_provider.dart';
import 'package:nonna_app/features/gallery/presentation/screens/gallery_screen.dart';

// ---------------------------------------------------------------------------
// Fake GalleryScreenNotifier
// ---------------------------------------------------------------------------

class _FakeGalleryNotifier extends GalleryScreenNotifier {
  _FakeGalleryNotifier(this._initial);

  final GalleryScreenState _initial;

  @override
  GalleryScreenState build() => _initial;

  @override
  Future<void> loadPhotos({
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> filterByTag(String tag) async {}

  @override
  Future<void> clearFilters() async {}

  @override
  Future<void> refresh() async {}
}

// ---------------------------------------------------------------------------
// Helper factory for Photo
// ---------------------------------------------------------------------------

Photo _makePhoto(String id, {String? caption, List<String> tags = const []}) {
  final now = DateTime(2024, 6, 1);
  return Photo(
    id: id,
    babyProfileId: 'p1',
    uploadedByUserId: 'u1',
    storagePath: 'photos/$id.jpg',
    caption: caption,
    tags: tags,
    createdAt: now,
    updatedAt: now,
  );
}

// ---------------------------------------------------------------------------
// Helper: build wrapped screen
// ---------------------------------------------------------------------------

Widget _buildScreen(
  GalleryScreenState state, {
  String? babyProfileId,
  UserRole? userRole,
  Function(Photo)? onPhotoTap,
}) {
  return ProviderScope(
    overrides: [
      galleryScreenProvider.overrideWith(() => _FakeGalleryNotifier(state)),
    ],
    child: MaterialApp(
      home: GalleryScreen(
        babyProfileId: babyProfileId,
        userRole: userRole,
        onPhotoTap: onPhotoTap,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GalleryScreen', () {
    testWidgets('renders app bar with title Gallery', (tester) async {
      await tester.pumpWidget(_buildScreen(const GalleryScreenState()));
      expect(find.text('Gallery'), findsOneWidget);
    });

    testWidgets('shows shimmer cards when loading', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const GalleryScreenState(isLoading: true),
          babyProfileId: 'p1',
        ),
      );
      await tester.pump();
      expect(find.byType(ShimmerCard), findsNWidgets(6));
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const GalleryScreenState(error: 'Load failed'),
          babyProfileId: 'p1',
        ),
      );
      expect(find.text('Load failed'), findsOneWidget);
    });

    testWidgets('shows empty state when no photos', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const GalleryScreenState(),
          babyProfileId: 'p1',
        ),
      );
      await tester.pump();
      expect(find.text('No photos yet'), findsOneWidget);
    });

    testWidgets('renders photo tiles when photos are loaded', (tester) async {
      final photos = [
        _makePhoto('1', caption: 'First photo'),
        _makePhoto('2', caption: 'Second photo'),
      ];
      await tester.pumpWidget(
        _buildScreen(
          GalleryScreenState(photos: photos),
          babyProfileId: 'p1',
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('photo_tile_0')), findsOneWidget);
      expect(find.byKey(const Key('photo_tile_1')), findsOneWidget);
    });

    testWidgets('shows upload FAB for owner role', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const GalleryScreenState(),
          userRole: UserRole.owner,
        ),
      );
      expect(find.byKey(const Key('upload_photo_fab')), findsOneWidget);
    });

    testWidgets('hides upload FAB for follower role', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const GalleryScreenState(),
          userRole: UserRole.follower,
        ),
      );
      expect(find.byKey(const Key('upload_photo_fab')), findsNothing);
    });

    testWidgets('shows snackbar when owner taps upload FAB', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const GalleryScreenState(),
          userRole: UserRole.owner,
        ),
      );
      await tester.tap(find.byKey(const Key('upload_photo_fab')));
      await tester.pump();
      expect(find.text('Upload photo – coming soon!'), findsOneWidget);
    });
  });
}
