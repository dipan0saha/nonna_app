import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/network/endpoints/photo_endpoints.dart';

void main() {
  group('PhotoEndpoints', () {
    const testBabyProfileId = 'baby_123';
    const testPhotoId = 'photo_456';
    const testUserId = 'user_789';
    const testCommentId = 'comment_101';
    const testSquishId = 'squish_202';
    const testTagId = 'tag_303';
    const testStartDate = '2024-01-01T00:00:00.000Z';
    const testEndDate = '2024-12-31T23:59:59.999Z';

    group('Photo CRUD Operations', () {
      test('generates correct getPhotos endpoint', () {
        final endpoint = PhotoEndpoints.getPhotos(testBabyProfileId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('select=*'));
        expect(endpoint, contains('order=created_at.desc'));
      });

      test('generates correct getPhoto endpoint', () {
        final endpoint = PhotoEndpoints.getPhoto(testPhotoId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('id=eq.$testPhotoId'));
        expect(endpoint, contains('select=*'));
      });

      test('generates correct getRecentPhotos endpoint with default limit', () {
        final endpoint = PhotoEndpoints.getRecentPhotos(testBabyProfileId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=created_at.desc'));
        expect(endpoint, contains('limit=10'));
      });

      test('generates correct getRecentPhotos endpoint with custom limit', () {
        final endpoint = PhotoEndpoints.getRecentPhotos(testBabyProfileId, limit: 25);

        expect(endpoint, contains('limit=25'));
      });

      test('generates correct createPhoto endpoint', () {
        final endpoint = PhotoEndpoints.createPhoto();

        expect(endpoint, equals('photos'));
      });

      test('generates correct updatePhoto endpoint', () {
        final endpoint = PhotoEndpoints.updatePhoto(testPhotoId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('id=eq.$testPhotoId'));
      });

      test('generates correct deletePhoto endpoint', () {
        final endpoint = PhotoEndpoints.deletePhoto(testPhotoId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('id=eq.$testPhotoId'));
      });
    });

    group('Photo Squishes (Likes)', () {
      test('generates correct getPhotoSquishes endpoint', () {
        final endpoint = PhotoEndpoints.getPhotoSquishes(testPhotoId);

        expect(endpoint, contains('photo_squishes'));
        expect(endpoint, contains('photo_id=eq.$testPhotoId'));
        expect(endpoint, contains('select=*'));
      });

      test('generates correct getUserSquish endpoint', () {
        final endpoint = PhotoEndpoints.getUserSquish(testPhotoId, testUserId);

        expect(endpoint, contains('photo_squishes'));
        expect(endpoint, contains('photo_id=eq.$testPhotoId'));
        expect(endpoint, contains('user_id=eq.$testUserId'));
        expect(endpoint, contains('select=*'));
      });

      test('generates correct createSquish endpoint', () {
        final endpoint = PhotoEndpoints.createSquish();

        expect(endpoint, equals('photo_squishes'));
      });

      test('generates correct deleteSquish endpoint', () {
        final endpoint = PhotoEndpoints.deleteSquish(testSquishId);

        expect(endpoint, contains('photo_squishes'));
        expect(endpoint, contains('id=eq.$testSquishId'));
      });

      test('generates correct getSquishCount endpoint', () {
        final endpoint = PhotoEndpoints.getSquishCount(testPhotoId);

        expect(endpoint, contains('photo_squishes'));
        expect(endpoint, contains('photo_id=eq.$testPhotoId'));
        expect(endpoint, contains('select=count'));
      });
    });

    group('Photo Comments', () {
      test('generates correct getPhotoComments endpoint', () {
        final endpoint = PhotoEndpoints.getPhotoComments(testPhotoId);

        expect(endpoint, contains('photo_comments'));
        expect(endpoint, contains('photo_id=eq.$testPhotoId'));
        expect(endpoint, contains('select=*'));
        expect(endpoint, contains('order=created_at.desc'));
      });

      test('generates correct createPhotoComment endpoint', () {
        final endpoint = PhotoEndpoints.createPhotoComment();

        expect(endpoint, equals('photo_comments'));
      });

      test('generates correct updatePhotoComment endpoint', () {
        final endpoint = PhotoEndpoints.updatePhotoComment(testCommentId);

        expect(endpoint, contains('photo_comments'));
        expect(endpoint, contains('id=eq.$testCommentId'));
      });

      test('generates correct deletePhotoComment endpoint', () {
        final endpoint = PhotoEndpoints.deletePhotoComment(testCommentId);

        expect(endpoint, contains('photo_comments'));
        expect(endpoint, contains('id=eq.$testCommentId'));
      });
    });

    group('Photo Tags', () {
      test('generates correct getPhotoTags endpoint', () {
        final endpoint = PhotoEndpoints.getPhotoTags(testPhotoId);

        expect(endpoint, contains('photo_tags'));
        expect(endpoint, contains('photo_id=eq.$testPhotoId'));
        expect(endpoint, contains('select=*'));
      });

      test('generates correct getPhotosByTag endpoint', () {
        final endpoint = PhotoEndpoints.getPhotosByTag(testBabyProfileId, testUserId);

        expect(endpoint, contains('photo_tags'));
        expect(endpoint, contains('photo_id.baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('tagged_user_id=eq.$testUserId'));
        expect(endpoint, contains('select=photo_id(*)'));
      });

      test('generates correct createPhotoTag endpoint', () {
        final endpoint = PhotoEndpoints.createPhotoTag();

        expect(endpoint, equals('photo_tags'));
      });

      test('generates correct deletePhotoTag endpoint', () {
        final endpoint = PhotoEndpoints.deletePhotoTag(testTagId);

        expect(endpoint, contains('photo_tags'));
        expect(endpoint, contains('id=eq.$testTagId'));
      });
    });

    group('Photo Search & Filter', () {
      test('generates correct searchPhotos endpoint', () {
        const searchTerm = 'birthday';
        final endpoint = PhotoEndpoints.searchPhotos(testBabyProfileId, searchTerm);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('caption=ilike.'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=created_at.desc'));
      });

      test('encodes special characters in search term', () {
        const searchTerm = 'test & special chars!';
        final endpoint = PhotoEndpoints.searchPhotos(testBabyProfileId, searchTerm);

        expect(endpoint, contains('caption=ilike.'));
        // Should be URL encoded
        expect(endpoint, isNot(contains('&')));
      });

      test('generates correct getPhotosByDateRange endpoint', () {
        final endpoint = PhotoEndpoints.getPhotosByDateRange(
          testBabyProfileId,
          testStartDate,
          testEndDate,
        );

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('created_at=gte.$testStartDate'));
        expect(endpoint, contains('created_at=lte.$testEndDate'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=created_at.desc'));
      });

      test('generates correct getPhotosByUploader endpoint', () {
        final endpoint =
            PhotoEndpoints.getPhotosByUploader(testBabyProfileId, testUserId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('uploaded_by_user_id=eq.$testUserId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=created_at.desc'));
      });

      test('generates correct getFavoritePhotos endpoint with default limit', () {
        final endpoint = PhotoEndpoints.getFavoritePhotos(testBabyProfileId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=squish_count.desc'));
        expect(endpoint, contains('limit=10'));
      });

      test('generates correct getFavoritePhotos endpoint with custom limit', () {
        final endpoint = PhotoEndpoints.getFavoritePhotos(testBabyProfileId, limit: 20);

        expect(endpoint, contains('limit=20'));
      });
    });

    group('Helper Methods', () {
      test('generates correct getPhotosWithPagination endpoint with defaults', () {
        final endpoint = PhotoEndpoints.getPhotosWithPagination(testBabyProfileId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=created_at.desc'));
        expect(endpoint, contains('limit=20'));
        expect(endpoint, contains('offset=0'));
      });

      test('generates correct getPhotosWithPagination endpoint with custom values', () {
        final endpoint = PhotoEndpoints.getPhotosWithPagination(
          testBabyProfileId,
          limit: 50,
          offset: 100,
        );

        expect(endpoint, contains('limit=50'));
        expect(endpoint, contains('offset=100'));
      });

      test('generates correct getPhotoStats endpoint', () {
        final endpoint = PhotoEndpoints.getPhotoStats(testPhotoId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('id=eq.$testPhotoId'));
        expect(endpoint, contains('select=squish_count,comment_count'));
      });
    });
  });
}
