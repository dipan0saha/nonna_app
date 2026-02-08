import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/network/endpoints/photo_endpoints.dart';

void main() {
  group('PhotoEndpoints', () {
    const testBabyProfileId = 'baby-123';
    const testPhotoId = 'photo-456';
    const testUserId = 'user-789';
    const testCommentId = 'comment-101';
    const testSquishId = 'squish-202';
    const testTagId = 'tag-303';
    const testStartDate = '2024-01-01T00:00:00Z';
    const testEndDate = '2024-12-31T23:59:59Z';

    group('Photo CRUD Operations', () {
      test('getPhotos returns correct endpoint', () {
        final endpoint = PhotoEndpoints.getPhotos(testBabyProfileId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=created_at.desc'));
      });

      test('getPhoto returns correct endpoint', () {
        final endpoint = PhotoEndpoints.getPhoto(testPhotoId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('id=eq.$testPhotoId'));
      });

      test('getRecentPhotos uses default limit', () {
        final endpoint = PhotoEndpoints.getRecentPhotos(testBabyProfileId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('limit=10'));
        expect(endpoint, contains('order=created_at.desc'));
      });

      test('getRecentPhotos uses custom limit', () {
        final endpoint =
            PhotoEndpoints.getRecentPhotos(testBabyProfileId, limit: 25);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('limit=25'));
      });

      test('createPhoto returns correct endpoint', () {
        final endpoint = PhotoEndpoints.createPhoto();

        expect(endpoint, equals('photos'));
      });

      test('updatePhoto returns correct endpoint', () {
        final endpoint = PhotoEndpoints.updatePhoto(testPhotoId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('id=eq.$testPhotoId'));
      });

      test('deletePhoto returns correct endpoint', () {
        final endpoint = PhotoEndpoints.deletePhoto(testPhotoId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('id=eq.$testPhotoId'));
      });
    });

    group('Photo Squishes (Likes)', () {
      test('getPhotoSquishes returns correct endpoint', () {
        final endpoint = PhotoEndpoints.getPhotoSquishes(testPhotoId);

        expect(endpoint, contains('photo_squishes'));
        expect(endpoint, contains('photo_id=eq.$testPhotoId'));
      });

      test('getUserSquish returns correct endpoint', () {
        final endpoint = PhotoEndpoints.getUserSquish(testPhotoId, testUserId);

        expect(endpoint, contains('photo_squishes'));
        expect(endpoint, contains('photo_id=eq.$testPhotoId'));
        expect(endpoint, contains('user_id=eq.$testUserId'));
      });

      test('createSquish returns correct endpoint', () {
        final endpoint = PhotoEndpoints.createSquish();

        expect(endpoint, equals('photo_squishes'));
      });

      test('deleteSquish returns correct endpoint', () {
        final endpoint = PhotoEndpoints.deleteSquish(testSquishId);

        expect(endpoint, contains('photo_squishes'));
        expect(endpoint, contains('id=eq.$testSquishId'));
      });

      test('getSquishCount returns correct endpoint', () {
        final endpoint = PhotoEndpoints.getSquishCount(testPhotoId);

        expect(endpoint, contains('photo_squishes'));
        expect(endpoint, contains('photo_id=eq.$testPhotoId'));
        expect(endpoint, contains('select=count'));
      });
    });

    group('Photo Comments', () {
      test('getPhotoComments returns correct endpoint', () {
        final endpoint = PhotoEndpoints.getPhotoComments(testPhotoId);

        expect(endpoint, contains('photo_comments'));
        expect(endpoint, contains('photo_id=eq.$testPhotoId'));
        expect(endpoint, contains('order=created_at.desc'));
      });

      test('createPhotoComment returns correct endpoint', () {
        final endpoint = PhotoEndpoints.createPhotoComment();

        expect(endpoint, equals('photo_comments'));
      });

      test('updatePhotoComment returns correct endpoint', () {
        final endpoint = PhotoEndpoints.updatePhotoComment(testCommentId);

        expect(endpoint, contains('photo_comments'));
        expect(endpoint, contains('id=eq.$testCommentId'));
      });

      test('deletePhotoComment returns correct endpoint', () {
        final endpoint = PhotoEndpoints.deletePhotoComment(testCommentId);

        expect(endpoint, contains('photo_comments'));
        expect(endpoint, contains('id=eq.$testCommentId'));
      });
    });

    group('Photo Tags', () {
      test('getPhotoTags returns correct endpoint', () {
        final endpoint = PhotoEndpoints.getPhotoTags(testPhotoId);

        expect(endpoint, contains('photo_tags'));
        expect(endpoint, contains('photo_id=eq.$testPhotoId'));
      });

      test('getPhotosByTag returns correct endpoint', () {
        final endpoint =
            PhotoEndpoints.getPhotosByTag(testBabyProfileId, testUserId);

        expect(endpoint, contains('photo_tags'));
        expect(endpoint, contains('photo_id.baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('tagged_user_id=eq.$testUserId'));
        expect(endpoint, contains('select=photo_id(*)'));
      });

      test('createPhotoTag returns correct endpoint', () {
        final endpoint = PhotoEndpoints.createPhotoTag();

        expect(endpoint, equals('photo_tags'));
      });

      test('deletePhotoTag returns correct endpoint', () {
        final endpoint = PhotoEndpoints.deletePhotoTag(testTagId);

        expect(endpoint, contains('photo_tags'));
        expect(endpoint, contains('id=eq.$testTagId'));
      });
    });

    group('Photo Search & Filter', () {
      test('searchPhotos returns correct endpoint with encoded search term', () {
        const searchTerm = 'first steps';
        final endpoint = PhotoEndpoints.searchPhotos(testBabyProfileId, searchTerm);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('caption=ilike.'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=created_at.desc'));
        // Search term should be encoded
        expect(endpoint, isNot(contains(' ')));
      });

      test('searchPhotos encodes special characters', () {
        const searchTerm = 'baby & me!';
        final endpoint = PhotoEndpoints.searchPhotos(testBabyProfileId, searchTerm);

        expect(endpoint, contains('photos'));
        expect(endpoint, isNot(contains('&')));
        expect(endpoint, isNot(contains('!')));
      });

      test('getPhotosByDateRange returns correct endpoint', () {
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

      test('getPhotosByUploader returns correct endpoint', () {
        final endpoint =
            PhotoEndpoints.getPhotosByUploader(testBabyProfileId, testUserId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('uploaded_by_user_id=eq.$testUserId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=created_at.desc'));
      });

      test('getFavoritePhotos uses default limit', () {
        final endpoint = PhotoEndpoints.getFavoritePhotos(testBabyProfileId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=squish_count.desc'));
        expect(endpoint, contains('limit=10'));
      });

      test('getFavoritePhotos uses custom limit', () {
        final endpoint =
            PhotoEndpoints.getFavoritePhotos(testBabyProfileId, limit: 20);

        expect(endpoint, contains('limit=20'));
      });
    });

    group('Helper Methods', () {
      test('getPhotosWithPagination uses default values', () {
        final endpoint =
            PhotoEndpoints.getPhotosWithPagination(testBabyProfileId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('limit=20'));
        expect(endpoint, contains('offset=0'));
        expect(endpoint, contains('order=created_at.desc'));
      });

      test('getPhotosWithPagination uses custom values', () {
        final endpoint = PhotoEndpoints.getPhotosWithPagination(
          testBabyProfileId,
          limit: 50,
          offset: 100,
        );

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('limit=50'));
        expect(endpoint, contains('offset=100'));
      });

      test('getPhotosWithPagination handles large offset', () {
        final endpoint = PhotoEndpoints.getPhotosWithPagination(
          testBabyProfileId,
          limit: 100,
          offset: 2000,
        );

        expect(endpoint, contains('limit=100'));
        expect(endpoint, contains('offset=2000'));
      });

      test('getPhotoStats returns correct endpoint', () {
        final endpoint = PhotoEndpoints.getPhotoStats(testPhotoId);

        expect(endpoint, contains('photos'));
        expect(endpoint, contains('id=eq.$testPhotoId'));
        expect(endpoint, contains('select=squish_count,comment_count'));
      });
    });
  });
}
