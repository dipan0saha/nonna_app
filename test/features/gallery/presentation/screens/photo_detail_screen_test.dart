import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/features/gallery/presentation/screens/photo_detail_screen.dart';
import 'package:nonna_app/features/gallery/presentation/widgets/squish_photo_widget.dart';

// ---------------------------------------------------------------------------
// Helper factory for Photo
// ---------------------------------------------------------------------------

Photo _makePhoto({
  String id = 'p1',
  String? caption,
  List<String> tags = const [],
  String storagePath = 'photos/p1.jpg',
  DateTime? createdAt,
}) {
  final now = createdAt ?? DateTime(2024, 6, 15);
  return Photo(
    id: id,
    babyProfileId: 'b1',
    uploadedByUserId: 'u1',
    storagePath: storagePath,
    caption: caption,
    tags: tags,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _buildScreen(
  Photo photo, {
  int squishCount = 0,
  bool isSquished = false,
  VoidCallback? onSquish,
}) {
  return MaterialApp(
    home: PhotoDetailScreen(
      photo: photo,
      squishCount: squishCount,
      isSquished: isSquished,
      onSquish: onSquish,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PhotoDetailScreen', () {
    testWidgets('renders photo detail image container', (tester) async {
      await tester.pumpWidget(_buildScreen(_makePhoto()));
      expect(find.byKey(const Key('photo_detail_image')), findsOneWidget);
    });

    testWidgets('shows caption when photo has caption', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makePhoto(caption: 'My cute photo')),
      );
      expect(find.text('My cute photo'), findsOneWidget);
      expect(find.text('Caption:'), findsOneWidget);
    });

    testWidgets('shows tags as chips when photo has tags', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makePhoto(tags: ['birthday', 'cute'])),
      );
      expect(find.byKey(const Key('photo_tag_birthday')), findsOneWidget);
      expect(find.byKey(const Key('photo_tag_cute')), findsOneWidget);
    });

    testWidgets('shows squish count', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makePhoto(), squishCount: 12),
      );
      expect(find.text('12 squishes'), findsOneWidget);
    });

    testWidgets('calls onSquish when squish button tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _buildScreen(_makePhoto(), onSquish: () => called = true),
      );
      await tester.tap(find.byKey(const Key('squish_button')));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('renders uploaded date', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makePhoto(createdAt: DateTime(2024, 6, 15))),
      );
      expect(find.text('Uploaded: Jun 15, 2024'), findsOneWidget);
    });
  });
}
