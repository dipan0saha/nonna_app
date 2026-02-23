import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/recent_photos/models/photo_with_squish_count.dart';
import 'package:nonna_app/tiles/recent_photos/widgets/recent_photos_tile.dart';

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

PhotoWithSquishCount _makeItem({
  String id = 'p1',
  String? caption,
  int squishCount = 0,
  bool isSquished = false,
}) =>
    PhotoWithSquishCount(
      photo: _makePhoto(id: id, caption: caption),
      squishCount: squishCount,
      isSquished: isSquished,
    );

Widget _buildWidget({
  List<PhotoWithSquishCount> photos = const [],
  bool isLoading = false,
  String? error,
  void Function(Photo)? onPhotoTap,
  VoidCallback? onRefresh,
  VoidCallback? onViewAll,
}) {
  return MaterialApp(
    home: Scaffold(
      body: RecentPhotosTile(
        photos: photos,
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
  group('RecentPhotosTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('recent_photos_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerPlaceholder), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Load failed'));
      expect(find.text('Load failed'), findsOneWidget);
    });

    testWidgets('shows empty state when photos list is empty', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('No photos yet'), findsOneWidget);
    });

    testWidgets('shows photos when provided', (tester) async {
      final photos = [_makeItem(id: 'p1'), _makeItem(id: 'p2')];
      await tester.pumpWidget(_buildWidget(photos: photos));
      expect(find.byKey(const Key('photo_item_p1')), findsOneWidget);
      expect(find.byKey(const Key('photo_item_p2')), findsOneWidget);
    });

    testWidgets('shows at most 6 photos', (tester) async {
      final photos = List.generate(8, (i) => _makeItem(id: 'p$i'));
      await tester.pumpWidget(_buildWidget(photos: photos));
      int count = 0;
      for (int i = 0; i < 6; i++) {
        if (tester.any(find.byKey(Key('photo_item_p$i')))) count++;
      }
      expect(count, 6);
      expect(find.byKey(const Key('photo_item_p6')), findsNothing);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Recent Photos'), findsOneWidget);
    });

    testWidgets('calls onPhotoTap when photo is tapped', (tester) async {
      Photo? tappedPhoto;
      final item = _makeItem();
      await tester.pumpWidget(
        _buildWidget(
          photos: [item],
          onPhotoTap: (p) => tappedPhoto = p,
        ),
      );
      await tester.tap(find.byKey(const Key('photo_item_p1')));
      expect(tappedPhoto, equals(item.photo));
    });

    testWidgets('shows view all button when onViewAll is provided',
        (tester) async {
      await tester.pumpWidget(_buildWidget(onViewAll: () {}));
      expect(find.byKey(const Key('recent_photos_view_all')), findsOneWidget);
    });

    testWidgets('view all button calls onViewAll callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildWidget(onViewAll: () => called = true));
      await tester.tap(find.byKey(const Key('recent_photos_view_all')));
      expect(called, isTrue);
    });

    testWidgets('hides view all button when onViewAll is null', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('recent_photos_view_all')), findsNothing);
    });

    testWidgets('shows caption when photo has one', (tester) async {
      final item = _makeItem(caption: 'First smile');
      await tester.pumpWidget(_buildWidget(photos: [item]));
      expect(find.text('First smile'), findsOneWidget);
    });

    testWidgets('error retry calls onRefresh', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _buildWidget(error: 'Oops', onRefresh: () => called = true),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      expect(called, isTrue);
    });

    testWidgets('shows squish count overlay when squishCount > 0',
        (tester) async {
      final item = _makeItem(id: 'p1', squishCount: 5);
      await tester.pumpWidget(_buildWidget(photos: [item]));
      expect(find.byKey(const Key('squish_count_p1')), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('hides squish count overlay when squishCount is 0',
        (tester) async {
      final item = _makeItem(id: 'p1', squishCount: 0);
      await tester.pumpWidget(_buildWidget(photos: [item]));
      expect(find.byKey(const Key('squish_count_p1')), findsNothing);
    });
  });
}
