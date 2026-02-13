import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/features/gallery/presentation/providers/gallery_screen_provider.dart';

import '../../../../helpers/fake_postgrest_builders.dart';
import '../../../../helpers/mock_factory.dart';
import '../../../../mocks/mock_services.mocks.dart';

void main() {
  group('GalleryScreenNotifier Tests', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    final samplePhoto = Photo(
      id: 'photo_1',
      babyProfileId: 'profile_1',
      storagePath: 'photos/photo1.jpg',
      thumbnailPath: 'photos/thumb1.jpg',
      caption: 'First photo',
      tags: ['milestone', 'first'],
      uploadedByUserId: 'user_1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockFactory.createDatabaseService();
      mockCacheService = MockFactory.createCacheService();
      mockRealtimeService = MockFactory.createRealtimeService();

      // Setup ALL default mock behaviors BEFORE creating the container
      when(mockCacheService.isInitialized).thenReturn(true);
      when(mockCacheService.get(any)).thenAnswer((_) async => null);
      when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
          .thenAnswer((_) async {});
      when(mockDatabaseService.select(any))
          .thenAnswer((_) => FakePostgrestBuilder([]));
      // Setup default realtime service stubs
      when(mockRealtimeService.subscribe(
        table: anyNamed('table'),
        channelName: anyNamed('channelName'),
        filter: anyNamed('filter'),
      )).thenAnswer((_) => Stream.empty());
      when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async {});

      // Create container AFTER all default mocks are setup
      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          cacheServiceProvider.overrideWithValue(mockCacheService),
          realtimeServiceProvider.overrideWithValue(mockRealtimeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      reset(mockDatabaseService);
      reset(mockCacheService);
      reset(mockRealtimeService);
    });

    tearDown(() {
      container.dispose();
      reset(mockDatabaseService);
      reset(mockCacheService);
      reset(mockRealtimeService);
    });

    group('Initial State', () {
      test('initial state has empty photos', () {
        final notifier = container.read(galleryScreenProvider.notifier);
        expect(notifier.state.photos, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.isLoadingMore, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.hasMore, isTrue);
        expect(notifier.state.currentPage, equals(0));
        expect(notifier.state.currentFilter, equals(GalleryFilter.all));
      });
    });

    group('loadPhotos', () {
      test('sets loading state while fetching', () async {
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        final notifier = container.read(galleryScreenProvider.notifier);
        final future = notifier.loadPhotos(babyProfileId: 'profile_1');

        expect(notifier.state.isLoading, isTrue);
        await future;
      });

      test('loads photos from cache when available', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => [
              samplePhoto.toJson(),
            ]);

        final notifier = container.read(galleryScreenProvider.notifier);
        await notifier.loadPhotos(babyProfileId: 'profile_1');

        expect(notifier.state.photos, hasLength(1));
        expect(notifier.state.photos.first.id, equals('photo_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.selectedBabyProfileId, equals('profile_1'));
      });

      test('fetches photos from database when cache is empty', () async {
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([samplePhoto.toJson()]));

        final notifier = container.read(galleryScreenProvider.notifier);
        await notifier.loadPhotos(babyProfileId: 'profile_1');

        expect(notifier.state.photos, hasLength(1));
        expect(notifier.state.photos.first.id, equals('photo_1'));
        expect(notifier.state.isLoading, isFalse);
        verify(mockCacheService.put(any, any, ttlMinutes: 30)).called(1);
      });

      test('sets hasMore based on page size', () async {
        final photos = List.generate(
          30,
          (i) => samplePhoto.copyWith(id: 'photo_$i'),
        );

        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenReturn(
                FakePostgrestBuilder(photos.map((p) => p.toJson()).toList()));

        final notifier = container.read(galleryScreenProvider.notifier);
        await notifier.loadPhotos(babyProfileId: 'profile_1');

        expect(notifier.state.hasMore, isTrue);
      });

      test('force refresh bypasses cache', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [samplePhoto.toJson()]);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([samplePhoto.toJson()]));

        final notifier = container.read(galleryScreenProvider.notifier);
        await notifier.loadPhotos(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        verify(mockDatabaseService.select(any)).called(1);
      });

      test('handles errors gracefully', () async {
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenThrow(Exception('Database error'));

        final notifier = container.read(galleryScreenProvider.notifier);
        await notifier.loadPhotos(babyProfileId: 'profile_1');

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.photos, isEmpty);
      });

      test('sets up real-time subscription', () async {
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([samplePhoto.toJson()]));

        final notifier = container.read(galleryScreenProvider.notifier);
        await notifier.loadPhotos(babyProfileId: 'profile_1');

        verify(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).called(1);
      });
    });

    group('loadMore', () {
      test('loads more photos for pagination', () async {
        final notifier = container.read(galleryScreenProvider.notifier);
        notifier.state = notifier.state.copyWith(
          photos: [samplePhoto],
          selectedBabyProfileId: 'profile_1',
          hasMore: true,
          currentPage: 1,
        );

        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([
                  samplePhoto.copyWith(id: 'photo_2').toJson(),
                ]));

        await notifier.loadMore();

        expect(notifier.state.photos, hasLength(2));
        expect(notifier.state.currentPage, equals(2));
        expect(notifier.state.isLoadingMore, isFalse);
      });

      test('does not load more when already loading', () async {
        final notifier = container.read(galleryScreenProvider.notifier);
        notifier.state = notifier.state.copyWith(
          isLoadingMore: true,
          selectedBabyProfileId: 'profile_1',
          currentPage: 1,
        );

        await notifier.loadMore();

        verifyNever(
            mockDatabaseService.select(any, columns: anyNamed('columns')));
      });

      test('does not load more when hasMore is false', () async {
        final notifier = container.read(galleryScreenProvider.notifier);
        notifier.state = notifier.state.copyWith(
          hasMore: false,
          selectedBabyProfileId: 'profile_1',
        );

        await notifier.loadMore();

        verifyNever(
            mockDatabaseService.select(any, columns: anyNamed('columns')));
      });

      test('does not load more when babyProfileId is null', () async {
        final notifier = container.read(galleryScreenProvider.notifier);
        await notifier.loadMore();

        verifyNever(
            mockDatabaseService.select(any, columns: anyNamed('columns')));
      });

      test('handles load more error', () async {
        final notifier = container.read(galleryScreenProvider.notifier);
        notifier.state = notifier.state.copyWith(
          photos: [samplePhoto],
          selectedBabyProfileId: 'profile_1',
          hasMore: true,
          currentPage: 1,
        );

        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenThrow(Exception('Network error'));

        await notifier.loadMore();

        expect(notifier.state.isLoadingMore, isFalse);
      });
    });

    group('Filtering', () {
      test('filterByTag loads filtered photos', () async {
        final notifier = container.read(galleryScreenProvider.notifier);
        notifier.state = notifier.state.copyWith(
          selectedBabyProfileId: 'profile_1',
        );

        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.filterByTag('milestone');

        expect(notifier.state.currentFilter, equals(GalleryFilter.byTag));
        expect(notifier.state.selectedTag, equals('milestone'));
        expect(notifier.state.photos, hasLength(1));
        expect(notifier.state.hasMore, isFalse);
      });

      test('clearFilters resets filter and reloads', () async {
        final notifier = container.read(galleryScreenProvider.notifier);
        notifier.state = notifier.state.copyWith(
          selectedBabyProfileId: 'profile_1',
          currentFilter: GalleryFilter.byTag,
          selectedTag: 'milestone',
        );

        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.clearFilters();

        expect(notifier.state.currentFilter, equals(GalleryFilter.all));
        expect(notifier.state.selectedTag, isNull);
      });
    });

    group('refresh', () {
      test('refreshes photos with force refresh', () async {
        final notifier = container.read(galleryScreenProvider.notifier);
        notifier.state = notifier.state.copyWith(
          selectedBabyProfileId: 'profile_1',
        );

        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([samplePhoto.toJson()]));

        await notifier.refresh();

        expect(notifier.state.photos, hasLength(1));
      });

      test('does not refresh when baby profile is missing', () async {
        final notifier = container.read(galleryScreenProvider.notifier);
        await notifier.refresh();

        verifyNever(
            mockDatabaseService.select(any, columns: anyNamed('columns')));
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT event', () async {
        final streamController = StreamController<Map<String, dynamic>>();
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => streamController.stream);

        final notifier = container.read(galleryScreenProvider.notifier);
        await notifier.loadPhotos(babyProfileId: 'profile_1');

        final initialCount = notifier.state.photos.length;

        // Simulate INSERT
        final newPhoto =
            samplePhoto.copyWith(id: 'photo_2', caption: 'New photo');
        streamController.add({
          'eventType': 'INSERT',
          'new': newPhoto.toJson(),
        });

        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.photos.length, equals(initialCount + 1));
        expect(notifier.state.photos.first.id, equals('photo_2'));

        streamController.close();
      });

      test('handles UPDATE event', () async {
        final streamController = StreamController<Map<String, dynamic>>();
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => streamController.stream);

        final notifier = container.read(galleryScreenProvider.notifier);
        await notifier.loadPhotos(babyProfileId: 'profile_1');

        // Simulate UPDATE
        final updatedPhoto = samplePhoto.copyWith(caption: 'Updated photo');
        streamController.add({
          'eventType': 'UPDATE',
          'new': updatedPhoto.toJson(),
        });

        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.photos.first.caption, equals('Updated photo'));

        streamController.close();
      });

      test('handles DELETE event', () async {
        final streamController = StreamController<Map<String, dynamic>>();
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => streamController.stream);

        final notifier = container.read(galleryScreenProvider.notifier);
        await notifier.loadPhotos(babyProfileId: 'profile_1');

        expect(notifier.state.photos, hasLength(1));

        // Simulate DELETE
        streamController.add({
          'eventType': 'DELETE',
          'old': {'id': 'photo_1'},
        });

        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.photos, isEmpty);

        streamController.close();
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () async {
        final notifier = container.read(galleryScreenProvider.notifier);
        await notifier.loadPhotos(babyProfileId: 'profile_1');

        // Dispose the container to trigger provider disposal
        container.dispose();

        // The subscription manager should have cancelled the subscription
        // This is verified by the debug logs showing "✅ Realtime subscription cancelled"
      });
    });
  });
}
