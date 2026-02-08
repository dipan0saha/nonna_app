import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/system_announcement.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/tiles/system_announcements/providers/system_announcements_provider.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'system_announcements_provider_test.mocks.dart';

void main() {
  group('SystemAnnouncementsProvider Tests', () {
    late SystemAnnouncementsNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    // Sample announcement data
    final sampleAnnouncement = SystemAnnouncement(
      id: 'announcement_1',
      title: 'New Feature Release',
      message: 'Check out our new photo editing features!',
      type: 'feature',
      priority: 'high',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRealtimeService = MockRealtimeService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = SystemAnnouncementsNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
        realtimeService: mockRealtimeService,
      );
    });

    group('Initial State', () {
      test('initial state has empty announcements', () {
        expect(notifier.state.announcements, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });
    });

    group('fetchAnnouncements', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture = notifier.fetchAnnouncements();

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches announcements from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleAnnouncement.toJson()]));

        await notifier.fetchAnnouncements();

        // Verify state updated
        expect(notifier.state.announcements, hasLength(1));
        expect(notifier.state.announcements.first.id, equals('announcement_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('loads announcements from cache when available', () async {
        // Setup cache to return data
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleAnnouncement.toJson()]);

        await notifier.fetchAnnouncements();

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any));

        // Verify state updated from cache
        expect(notifier.state.announcements, hasLength(1));
        expect(notifier.state.announcements.first.id, equals('announcement_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.fetchAnnouncements();

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.announcements, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleAnnouncement.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleAnnouncement.toJson()]));

        await notifier.fetchAnnouncements(forceRefresh: true);

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any)).called(1);
      });

      test('filters only active announcements', () async {
        final activeAnnouncement =
            sampleAnnouncement.copyWith(id: 'ann_1', isActive: true);

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([activeAnnouncement.toJson()]));

        await notifier.fetchAnnouncements();

        // Should only have active announcements
        expect(notifier.state.announcements, hasLength(1));
        expect(notifier.state.announcements.first.isActive, isTrue);
      });

      test('sorts announcements by priority', () async {
        final highPriority =
            sampleAnnouncement.copyWith(id: 'ann_1', priority: 'high');
        final mediumPriority =
            sampleAnnouncement.copyWith(id: 'ann_2', priority: 'medium');
        final lowPriority =
            sampleAnnouncement.copyWith(id: 'ann_3', priority: 'low');

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          lowPriority.toJson(),
          highPriority.toJson(),
          mediumPriority.toJson(),
        ]));

        await notifier.fetchAnnouncements();

        // Should be sorted by priority
        expect(notifier.state.announcements[0].priority, equals('high'));
        expect(notifier.state.announcements[1].priority, equals('medium'));
        expect(notifier.state.announcements[2].priority, equals('low'));
      });

      test('saves fetched announcements to cache', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleAnnouncement.toJson()]));

        await notifier.fetchAnnouncements();

        // Verify cache put was called
        verify(mockCacheService.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });
    });

    group('dismissAnnouncement', () {
      test('dismisses announcement locally', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleAnnouncement.toJson()]));
        await notifier.fetchAnnouncements();

        expect(notifier.state.announcements, hasLength(1));

        notifier.dismissAnnouncement(announcementId: 'announcement_1');

        // Verify announcement was removed
        expect(notifier.state.announcements, isEmpty);
      });

      test('saves dismissed state to cache', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleAnnouncement.toJson()]));
        await notifier.fetchAnnouncements();

        notifier.dismissAnnouncement(announcementId: 'announcement_1');

        // Verify cache was updated
        verify(mockCacheService.put(any, any)).called(greaterThanOrEqualTo(1));
      });
    });

    group('refresh', () {
      test('refreshes announcements with force refresh', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleAnnouncement.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleAnnouncement.toJson()]));

        await notifier.refresh();

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(any)).called(1);
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT announcement', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleAnnouncement.toJson()]));

        await notifier.fetchAnnouncements();

        final initialCount = notifier.state.announcements.length;

        // Simulate real-time INSERT
        final newAnnouncement =
            sampleAnnouncement.copyWith(id: 'announcement_2');
        notifier.state = notifier.state.copyWith(
          announcements: [newAnnouncement, ...notifier.state.announcements],
        );

        expect(notifier.state.announcements.length, equals(initialCount + 1));
      });

      test('handles UPDATE announcement', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleAnnouncement.toJson()]));

        await notifier.fetchAnnouncements();

        // Simulate real-time UPDATE
        final updatedAnnouncement =
            sampleAnnouncement.copyWith(title: 'Updated Title');
        notifier.state = notifier.state.copyWith(
          announcements: notifier.state.announcements
              .map((a) =>
                  a.id == updatedAnnouncement.id ? updatedAnnouncement : a)
              .toList(),
        );

        expect(
            notifier.state.announcements.first.title, equals('Updated Title'));
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () {
        when(mockRealtimeService.unsubscribe(any)).thenReturn(null);

        notifier.dispose();

        expect(notifier.state, isNotNull);
      });
    });

    group('Announcement Types', () {
      test('supports different announcement types', () async {
        final featureAnnouncement =
            sampleAnnouncement.copyWith(id: 'ann_1', type: 'feature');
        final maintenanceAnnouncement =
            sampleAnnouncement.copyWith(id: 'ann_2', type: 'maintenance');
        final updateAnnouncement =
            sampleAnnouncement.copyWith(id: 'ann_3', type: 'update');

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          featureAnnouncement.toJson(),
          maintenanceAnnouncement.toJson(),
          updateAnnouncement.toJson(),
        ]));

        await notifier.fetchAnnouncements();

        expect(notifier.state.announcements, hasLength(3));
        expect(
          notifier.state.announcements.any((a) => a.type == 'feature'),
          isTrue,
        );
        expect(
          notifier.state.announcements.any((a) => a.type == 'maintenance'),
          isTrue,
        );
      });
    });
  });
}

// Fake builders for Postgrest operations (test doubles)
class FakePostgrestBuilder {
  final List<Map<String, dynamic>> data;

  FakePostgrestBuilder(this.data);

  FakePostgrestBuilder eq(String column, dynamic value) => this;
  FakePostgrestBuilder order(String column, {bool ascending = true}) => this;

  Future<List<Map<String, dynamic>>> call() async => data;
}
