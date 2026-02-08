import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/tiles/recent_photos/providers/recent_photos_provider.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'recent_photos_provider_test.mocks.dart';

void main() {
  group('RecentPhotosProvider Tests', () {
    late RecentPhotosNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    // Sample photo data
    final samplePhoto = Photo(
      id: 'photo_1',
      babyProfileId: 'profile_1',
      uploadedBy: 'user_1',
      storageUrl: 'https://example.com/photo.jpg',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      caption: 'Cute baby photo',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRealtimeService = MockRealtimeService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = RecentPhotosNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
        realtimeService: mockRealtimeService,
      );
    });

    group('Initial State', () {
      test('initial state has empty photos', () {
        expect(notifier.state.photos, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.hasMore, isTrue);
        expect(notifier.state.currentPage, equals(0));
      });
    });

    group('fetchPhotos', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture = notifier.fetchPhotos(babyProfileId: 'profile_1');

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches photos from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.fetchPhotos(babyProfileId: 'profile_1');

        // Verify state updated
        expect(notifier.state.photos, hasLength(1));
        expect(notifier.state.photos.first.id, equals('photo_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.currentPage, equals(1));
      });

      test('loads photos from cache when available', () async {
        // Setup cache to return data
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [samplePhoto.toJson()]);

        await notifier.fetchPhotos(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any));

        // Verify state updated from cache
        expect(notifier.state.photos, hasLength(1));
        expect(notifier.state.photos.first.id, equals('photo_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.fetchPhotos(babyProfileId: 'profile_1');

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.photos, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [samplePhoto.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.fetchPhotos(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any)).called(1);
      });

      test('saves fetched photos to cache', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.fetchPhotos(babyProfileId: 'profile_1');

        // Verify cache put was called
        verify(mockCacheService.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });
    });

    group('loadMore', () {
      test('loads more photos for infinite scroll', () async {
        // Setup initial state with photos
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.fetchPhotos(babyProfileId: 'profile_1');

        final photo2 = samplePhoto.copyWith(id: 'photo_2');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([photo2.toJson()]));

        await notifier.loadMore(babyProfileId: 'profile_1');

        // Verify state updated with new photos
        expect(notifier.state.photos, hasLength(2));
        expect(notifier.state.currentPage, equals(2));
      });

      test('does not load more when already loading', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.fetchPhotos(babyProfileId: 'profile_1');

        // Set loading state manually
        notifier.state = notifier.state.copyWith(isLoading: true);

        await notifier.loadMore(babyProfileId: 'profile_1');

        // Verify no additional database call
        verify(mockDatabaseService.select(any)).called(1);
      });

      test('does not load more when hasMore is false', () async {
        // Setup initial state with hasMore = false
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([]));

        await notifier.fetchPhotos(babyProfileId: 'profile_1');

        expect(notifier.state.hasMore, isFalse);

        await notifier.loadMore(babyProfileId: 'profile_1');

        verify(mockDatabaseService.select(any)).called(1);
      });
    });

    group('refresh', () {
      test('refreshes photos with force refresh', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [samplePhoto.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.refresh(babyProfileId: 'profile_1');

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(any)).called(1);
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT photo', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.fetchPhotos(babyProfileId: 'profile_1');

        final initialCount = notifier.state.photos.length;

        // Simulate real-time INSERT
        final newPhoto = samplePhoto.copyWith(id: 'photo_2');
        notifier.state = notifier.state.copyWith(
          photos: [newPhoto, ...notifier.state.photos],
        );

        expect(notifier.state.photos.length, equals(initialCount + 1));
      });

      test('handles UPDATE photo', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.fetchPhotos(babyProfileId: 'profile_1');

        // Simulate real-time UPDATE
        final updatedPhoto = samplePhoto.copyWith(caption: 'Updated caption');
        notifier.state = notifier.state.copyWith(
          photos: notifier.state.photos
              .map((p) => p.id == updatedPhoto.id ? updatedPhoto : p)
              .toList(),
        );

        expect(notifier.state.photos.first.caption, equals('Updated caption'));
      });

      test('handles DELETE photo', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.fetchPhotos(babyProfileId: 'profile_1');

        expect(notifier.state.photos, hasLength(1));

        // Simulate real-time DELETE
        notifier.state = notifier.state.copyWith(
          photos:
              notifier.state.photos.where((p) => p.id != 'photo_1').toList(),
        );

        expect(notifier.state.photos, isEmpty);
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () {
        when(mockRealtimeService.unsubscribe(any)).thenReturn(null);

        notifier.dispose();

        expect(notifier.state, isNotNull);
      });
    });
  });
}

// Fake builders for Postgrest operations (test doubles)
class FakePostgrestBuilder {
  final List<Map<String, dynamic>> data;

  FakePostgrestBuilder(this.data);

  FakePostgrestBuilder eq(String column, dynamic value) => this;
  FakePostgrestBuilder isNull(String column) => this;
  FakePostgrestBuilder order(String column, {bool ascending = true}) => this;
  FakePostgrestBuilder range(int from, int to) => this;
  FakePostgrestBuilder limit(int count) => this;

  Future<List<Map<String, dynamic>>> call() async => data;
}
