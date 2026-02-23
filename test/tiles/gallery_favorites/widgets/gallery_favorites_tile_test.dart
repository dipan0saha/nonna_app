import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/gallery_favorites/providers/gallery_favorites_provider.dart';
import 'package:nonna_app/tiles/gallery_favorites/widgets/gallery_favorites_tile.dart';

Photo _makePhoto({String id = 'p1', String? caption}) {
  final now = DateTime.now();
  return Photo(
    id: id,
    babyProfileId: 'bp1',
    uploadedByUserId: 'u1',
    storagePath: 'photos/$id.jpg',
    caption: caption,
    createdAt: now,
    updatedAt: now,
  );
}

PhotoWithSquishes _makeItem({
  String id = 'p1',
  String? caption,
  int squishCount = 5,
}) {
  return PhotoWithSquishes(
    photo: _makePhoto(id: id, caption: caption),
    squishCount: squishCount,
  );
}

Widget _buildWidget({
  List<PhotoWithSquishes> favorites = const [],
  bool isLoading = false,
  String? error,
  void Function(Photo)? onPhotoTap,
  VoidCallback? onRefresh,
  VoidCallback? onViewAll,
}) {
  return MaterialApp(
    home: Scaffold(
      body: GalleryFavoritesTile(
        favorites: favorites,
        isLoading: isLoading,
        error: error,
        onPhotoTap: onPhotoTap,
        onRefresh: onRefresh,
        onViewAll: onViewAll,
      ),
    ),
  );
}

void main() {
  group('GalleryFavoritesTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('gallery_favorites_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Failed to load'));
      expect(find.text('Failed to load'), findsOneWidget);
    });

    testWidgets('shows empty state when favorites list is empty',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('No favorites yet'), findsOneWidget);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Gallery Favorites'), findsOneWidget);
    });

    testWidgets('shows favorite rows when favorites are provided',
        (tester) async {
      final items = [
        _makeItem(id: 'p1'),
        _makeItem(id: 'p2'),
      ];
      await tester.pumpWidget(_buildWidget(favorites: items));
      expect(find.byKey(const Key('favorite_photo_p1')), findsOneWidget);
      expect(find.byKey(const Key('favorite_photo_p2')), findsOneWidget);
    });

    testWidgets('shows at most 5 favorites', (tester) async {
      final items = List.generate(7, (i) => _makeItem(id: 'p$i'));
      await tester.pumpWidget(_buildWidget(favorites: items));
      expect(find.byType(InkWell), findsNWidgets(5));
    });

    testWidgets('shows squish badge for each favorite', (tester) async {
      final items = [_makeItem(id: 'p1', squishCount: 8)];
      await tester.pumpWidget(_buildWidget(favorites: items));
      expect(find.byKey(const Key('squish_badge_p1')), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('calls onPhotoTap when row is tapped', (tester) async {
      Photo? tapped;
      final item = _makeItem(id: 'p1');
      await tester.pumpWidget(
        _buildWidget(
          favorites: [item],
          onPhotoTap: (p) => tapped = p,
        ),
      );
      await tester.tap(find.byKey(const Key('favorite_photo_p1')));
      expect(tapped, equals(item.photo));
    });

    testWidgets('shows view all button when onViewAll is provided',
        (tester) async {
      await tester.pumpWidget(_buildWidget(onViewAll: () {}));
      expect(
          find.byKey(const Key('gallery_favorites_view_all')), findsOneWidget);
    });

    testWidgets('view all button calls onViewAll callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildWidget(onViewAll: () => called = true));
      await tester.tap(find.byKey(const Key('gallery_favorites_view_all')));
      expect(called, isTrue);
    });

    testWidgets('hides view all button when onViewAll is null', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('gallery_favorites_view_all')), findsNothing);
    });

    testWidgets('error retry calls onRefresh', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _buildWidget(error: 'Oops', onRefresh: () => called = true),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      expect(called, isTrue);
    });

    testWidgets('shows caption when photo has one', (tester) async {
      final item = _makeItem(id: 'p1', caption: 'Cute baby!');
      await tester.pumpWidget(_buildWidget(favorites: [item]));
      expect(find.text('Cute baby!'), findsOneWidget);
    });
  });
}
