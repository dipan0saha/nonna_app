import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/photo.dart';

void main() {
  group('Photo', () {
    final now = DateTime.now();
    final photo = Photo(
      id: 'photo-123',
      babyProfileId: 'baby-456',
      uploadedByUserId: 'user-789',
      storagePath: 'baby-456/photos/photo-123.jpg',
      thumbnailPath: 'baby-456/photos/thumb-123.jpg',
      caption: 'First smile!',
      tags: ['milestone', 'happy'],
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates Photo from valid JSON', () {
        final json = {
          'id': 'photo-123',
          'baby_profile_id': 'baby-456',
          'uploaded_by_user_id': 'user-789',
          'storage_path': 'baby-456/photos/photo-123.jpg',
          'thumbnail_path': 'baby-456/photos/thumb-123.jpg',
          'caption': 'First smile!',
          'tags': ['milestone', 'happy'],
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': null,
        };

        final result = Photo.fromJson(json);

        expect(result.id, 'photo-123');
        expect(result.babyProfileId, 'baby-456');
        expect(result.uploadedByUserId, 'user-789');
        expect(result.storagePath, 'baby-456/photos/photo-123.jpg');
        expect(result.thumbnailPath, 'baby-456/photos/thumb-123.jpg');
        expect(result.caption, 'First smile!');
        expect(result.tags, ['milestone', 'happy']);
        expect(result.createdAt, now);
        expect(result.updatedAt, now);
        expect(result.deletedAt, null);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'photo-123',
          'baby_profile_id': 'baby-456',
          'uploaded_by_user_id': 'user-789',
          'storage_path': 'baby-456/photos/photo-123.jpg',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = Photo.fromJson(json);

        expect(result.thumbnailPath, null);
        expect(result.caption, null);
        expect(result.tags, const []);
        expect(result.deletedAt, null);
      });

      test('handles empty tags array', () {
        final json = {
          'id': 'photo-123',
          'baby_profile_id': 'baby-456',
          'uploaded_by_user_id': 'user-789',
          'storage_path': 'baby-456/photos/photo-123.jpg',
          'tags': [],
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = Photo.fromJson(json);

        expect(result.tags, const []);
      });
    });

    group('toJson', () {
      test('converts Photo to JSON', () {
        final json = photo.toJson();

        expect(json['id'], 'photo-123');
        expect(json['baby_profile_id'], 'baby-456');
        expect(json['uploaded_by_user_id'], 'user-789');
        expect(json['storage_path'], 'baby-456/photos/photo-123.jpg');
        expect(json['thumbnail_path'], 'baby-456/photos/thumb-123.jpg');
        expect(json['caption'], 'First smile!');
        expect(json['tags'], ['milestone', 'happy']);
        expect(json['created_at'], now.toIso8601String());
        expect(json['updated_at'], now.toIso8601String());
        expect(json['deleted_at'], null);
      });
    });

    group('validate', () {
      test('returns null for valid photo', () {
        expect(photo.validate(), null);
      });

      test('returns error for empty storage path', () {
        final invalidPhoto = photo.copyWith(storagePath: '');
        expect(invalidPhoto.validate(), 'Storage path is required');
      });

      test('returns error for whitespace-only storage path', () {
        final invalidPhoto = photo.copyWith(storagePath: '   ');
        expect(invalidPhoto.validate(), 'Storage path is required');
      });

      test('returns error for caption exceeding 500 characters', () {
        final invalidPhoto = photo.copyWith(caption: 'a' * 501);
        expect(
          invalidPhoto.validate(),
          'Caption must be 500 characters or less',
        );
      });

      test('returns error for more than 5 tags', () {
        final invalidPhoto = photo.copyWith(
          tags: ['tag1', 'tag2', 'tag3', 'tag4', 'tag5', 'tag6'],
        );
        expect(invalidPhoto.validate(), 'Maximum 5 tags allowed');
      });

      test('returns error for empty tag', () {
        final invalidPhoto = photo.copyWith(tags: ['valid', '']);
        expect(invalidPhoto.validate(), 'Tags cannot be empty');
      });

      test('returns error for whitespace-only tag', () {
        final invalidPhoto = photo.copyWith(tags: ['valid', '   ']);
        expect(invalidPhoto.validate(), 'Tags cannot be empty');
      });

      test('returns error for tag exceeding 50 characters', () {
        final invalidPhoto = photo.copyWith(tags: ['a' * 51]);
        expect(
          invalidPhoto.validate(),
          'Each tag must be 50 characters or less',
        );
      });
    });

    group('getters', () {
      test('isDeleted returns false when deletedAt is null', () {
        expect(photo.isDeleted, false);
      });

      test('isDeleted returns true when deletedAt is set', () {
        final deletedPhoto = photo.copyWith(deletedAt: now);
        expect(deletedPhoto.isDeleted, true);
      });

      test('hasTags returns true when tags are present', () {
        expect(photo.hasTags, true);
      });

      test('hasTags returns false when tags are empty', () {
        final photoWithoutTags = photo.copyWith(tags: []);
        expect(photoWithoutTags.hasTags, false);
      });

      test('hasCaption returns true when caption is present', () {
        expect(photo.hasCaption, true);
      });

      test('hasCaption returns false when caption is null', () {
        final photoWithoutCaption = Photo(
          id: photo.id,
          babyProfileId: photo.babyProfileId,
          uploadedByUserId: photo.uploadedByUserId,
          storagePath: photo.storagePath,
          caption: null,
          createdAt: photo.createdAt,
          updatedAt: photo.updatedAt,
        );
        expect(photoWithoutCaption.hasCaption, false);
      });

      test('hasCaption returns false when caption is empty', () {
        final photoWithEmptyCaption = photo.copyWith(caption: '');
        expect(photoWithEmptyCaption.hasCaption, false);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = photo.copyWith(
          caption: 'Updated caption',
          tags: ['newTag'],
        );

        expect(updated.id, photo.id);
        expect(updated.babyProfileId, photo.babyProfileId);
        expect(updated.uploadedByUserId, photo.uploadedByUserId);
        expect(updated.storagePath, photo.storagePath);
        expect(updated.caption, 'Updated caption');
        expect(updated.tags, ['newTag']);
      });

      test('maintains original values when no updates provided', () {
        final copy = photo.copyWith();
        expect(copy, photo);
      });
    });

    group('equality', () {
      test('equal photos are equal', () {
        final photo1 = Photo(
          id: 'photo-123',
          babyProfileId: 'baby-456',
          uploadedByUserId: 'user-789',
          storagePath: 'baby-456/photos/photo-123.jpg',
          tags: ['milestone', 'happy'],
          createdAt: now,
          updatedAt: now,
        );
        final photo2 = Photo(
          id: 'photo-123',
          babyProfileId: 'baby-456',
          uploadedByUserId: 'user-789',
          storagePath: 'baby-456/photos/photo-123.jpg',
          tags: ['milestone', 'happy'],
          createdAt: now,
          updatedAt: now,
        );

        expect(photo1, photo2);
        expect(photo1.hashCode, photo2.hashCode);
      });

      test('different photos are not equal', () {
        final photo1 = Photo(
          id: 'photo-123',
          babyProfileId: 'baby-456',
          uploadedByUserId: 'user-789',
          storagePath: 'baby-456/photos/photo-123.jpg',
          tags: ['milestone'],
          createdAt: now,
          updatedAt: now,
        );
        final photo2 = Photo(
          id: 'photo-456',
          babyProfileId: 'baby-789',
          uploadedByUserId: 'user-123',
          storagePath: 'baby-789/photos/photo-456.jpg',
          tags: ['happy'],
          createdAt: now,
          updatedAt: now,
        );

        expect(photo1, isNot(photo2));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = photo.toString();

        expect(str, contains('Photo'));
        expect(str, contains('photo-123'));
        expect(str, contains('baby-456'));
      });
    });
  });
}
