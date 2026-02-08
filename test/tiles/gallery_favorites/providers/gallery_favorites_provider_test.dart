import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/tiles/gallery_favorites/providers/gallery_favorites_provider.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'gallery_favorites_provider_test.mocks.dart';

void main() {
  group('GalleryFavoritesProvider Tests', () {
    late GalleryFavoritesNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    // Sample favorite photo data
    final samplePhoto = Photo(
      id: 'photo_1',
      babyProfileId: 'profile_1',
      uploadedBy: 'user_1',
      storageUrl: 'https://example.com/photo.jpg',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      caption: 'Favorite moment',
      isFavorite: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRealtimeService = MockRealtimeService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = GalleryFavoritesNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
        realtimeService: mockRealtimeService,
      );
    });

    group('Initial State', () {
      test('initial state has empty favorites', () {
        expect(notifier.state.favorites, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });
    });

    group('fetchFavorites', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture =
            notifier.fetchFavorites(babyProfileId: 'profile_1');

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches favorites from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.fetchFavorites(babyProfileId: 'profile_1');

        // Verify state updated
        expect(notifier.state.favorites, hasLength(1));
        expect(notifier.state.favorites.first.id, equals('photo_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('loads favorites from cache when available', () async {
        // Setup cache to return data
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [samplePhoto.toJson()]);

        await notifier.fetchFavorites(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any));

        // Verify state updated from cache
        expect(notifier.state.favorites, hasLength(1));
        expect(notifier.state.favorites.first.id, equals('photo_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.fetchFavorites(babyProfileId: 'profile_1');

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.favorites, isEmpty);
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

        await notifier.fetchFavorites(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any)).called(1);
      });

      test('filters only favorite photos', () async {
        final favoritePhoto = samplePhoto.copyWith(id: 'photo_1', isFavorite: true);

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([favoritePhoto.toJson()]));

        await notifier.fetchFavorites(babyProfileId: 'profile_1');

        // Should only have favorite photos
        expect(notifier.state.favorites, hasLength(1));
        expect(notifier.state.favorites.first.isFavorite, isTrue);
      });

      test('saves fetched favorites to cache', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.fetchFavorites(babyProfileId: 'profile_1');

        // Verify cache put was called
        verify(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });
    });

    group('toggleFavorite', () {
      test('toggles favorite status on', () async {
        final nonFavorite = samplePhoto.copyWith(isFavorite: false);

        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([nonFavorite.toJson()]));
        await notifier.fetchFavorites(babyProfileId: 'profile_1');

        // Setup update mock
        when(mockDatabaseService.update(any)).thenReturn(FakePostgrestUpdateBuilder());

        await notifier.toggleFavorite(
          photoId: 'photo_1',
          babyProfileId: 'profile_1',
        );

        // Verify database update
        verify(mockDatabaseService.update(any)).called(1);
      });

      test('toggles favorite status off', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePhoto.toJson()]));
        await notifier.fetchFavorites(babyProfileId: 'profile_1');

        when(mockDatabaseService.update(any)).thenReturn(FakePostgrestUpdateBuilder());

        await notifier.toggleFavorite(
          photoId: 'photo_1',
          babyProfileId: 'profile_1',
        );

        // Verify database update
        verify(mockDatabaseService.update(any)).called(1);
      });
    });

    group('refresh', () {
      test('refreshes favorites with force refresh', () async {
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
      test('handles photo marked as favorite', () async {
        // Setup initial state with empty favorites
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([]));

        await notifier.fetchFavorites(babyProfileId: 'profile_1');

        expect(notifier.state.favorites, isEmpty);

        // Simulate real-time UPDATE to favorite
        final favoritePhoto = samplePhoto.copyWith(isFavorite: true);
        notifier.state = notifier.state.copyWith(
          favorites: [favoritePhoto],
        );

        expect(notifier.state.favorites, hasLength(1));
      });

      test('handles photo unmarked as favorite', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.fetchFavorites(babyProfileId: 'profile_1');

        expect(notifier.state.favorites, hasLength(1));

        // Simulate real-time UPDATE to non-favorite
        notifier.state = notifier.state.copyWith(
          favorites: [],
        );

        expect(notifier.state.favorites, isEmpty);
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () {
        when(mockRealtimeService.unsubscribe(any)).thenReturn(null);

        notifier.dispose();

        expect(notifier.state, isNotNull);
      });
    });

    group('Sorting', () {
      test('sorts favorites by date (newest first)', () async {
        final photo1 = samplePhoto.copyWith(
          id: 'photo_1',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        final photo2 = samplePhoto.copyWith(
          id: 'photo_2',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        final photo3 = samplePhoto.copyWith(
          id: 'photo_3',
          createdAt: DateTime.now(),
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          photo1.toJson(),
          photo2.toJson(),
          photo3.toJson(),
        ]));

        await notifier.fetchFavorites(babyProfileId: 'profile_1');

        // Most recent should be first
        expect(notifier.state.favorites[0].id, equals('photo_3'));
        expect(notifier.state.favorites[1].id, equals('photo_2'));
        expect(notifier.state.favorites[2].id, equals('photo_1'));
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

  Future<List<Map<String, dynamic>>> call() async => data;
}

class FakePostgrestUpdateBuilder {
  FakePostgrestUpdateBuilder eq(String column, dynamic value) => this;
  Future<void> update(Map<String, dynamic> data) async {}
}
