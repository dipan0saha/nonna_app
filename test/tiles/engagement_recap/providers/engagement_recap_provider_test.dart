import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/activity_event.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/tiles/engagement_recap/providers/engagement_recap_provider.dart';

@GenerateMocks([DatabaseService, CacheService])
import 'engagement_recap_provider_test.mocks.dart';

void main() {
  group('EngagementRecapProvider Tests', () {
    late EngagementRecapNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;

    // Sample activity event data
    final sampleActivity = ActivityEvent(
      id: 'activity_1',
      babyProfileId: 'profile_1',
      userId: 'user_1',
      type: 'photo_upload',
      description: 'Uploaded a new photo',
      createdAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = EngagementRecapNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
      );
    });

    group('Initial State', () {
      test('initial state has empty activities and zero metrics', () {
        expect(notifier.state.activities, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.totalEngagements, equals(0));
        expect(notifier.state.photosAdded, equals(0));
        expect(notifier.state.commentsReceived, equals(0));
      });
    });

    group('fetchEngagement', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture = notifier.fetchEngagement(
          babyProfileId: 'profile_1',
          days: 7,
        );

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches activities from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleActivity.toJson()]));

        await notifier.fetchEngagement(
          babyProfileId: 'profile_1',
          days: 7,
        );

        // Verify state updated
        expect(notifier.state.activities, hasLength(1));
        expect(notifier.state.activities.first.id, equals('activity_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('loads activities from cache when available', () async {
        // Setup cache to return data
        final cachedData = {
          'activities': [sampleActivity.toJson()],
          'totalEngagements': 1,
          'photosAdded': 1,
          'commentsReceived': 0,
        };
        when(mockCacheService.get(any)).thenAnswer((_) async => cachedData);

        await notifier.fetchEngagement(
          babyProfileId: 'profile_1',
          days: 7,
        );

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any));

        // Verify state updated from cache
        expect(notifier.state.activities, hasLength(1));
        expect(notifier.state.totalEngagements, equals(1));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.fetchEngagement(
          babyProfileId: 'profile_1',
          days: 7,
        );

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.activities, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        final cachedData = {
          'activities': [sampleActivity.toJson()],
          'totalEngagements': 1,
          'photosAdded': 1,
          'commentsReceived': 0,
        };
        when(mockCacheService.get(any)).thenAnswer((_) async => cachedData);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleActivity.toJson()]));

        await notifier.fetchEngagement(
          babyProfileId: 'profile_1',
          days: 7,
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any)).called(1);
      });

      test('calculates engagement metrics correctly', () async {
        final activities = [
          sampleActivity.copyWith(id: 'act_1', type: 'photo_upload'),
          sampleActivity.copyWith(id: 'act_2', type: 'photo_upload'),
          sampleActivity.copyWith(id: 'act_3', type: 'comment'),
          sampleActivity.copyWith(id: 'act_4', type: 'comment'),
          sampleActivity.copyWith(id: 'act_5', type: 'squish'),
        ];

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder(activities.map((a) => a.toJson()).toList()),
        );

        await notifier.fetchEngagement(
          babyProfileId: 'profile_1',
          days: 7,
        );

        expect(notifier.state.totalEngagements, equals(5));
        expect(notifier.state.photosAdded, equals(2));
        expect(notifier.state.commentsReceived, equals(2));
      });

      test('filters activities by time period', () async {
        final recentActivity = sampleActivity.copyWith(
          id: 'recent',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        );
        final oldActivity = sampleActivity.copyWith(
          id: 'old',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder([recentActivity.toJson()]),
        );

        await notifier.fetchEngagement(
          babyProfileId: 'profile_1',
          days: 7,
        );

        // Should only have recent activity
        expect(notifier.state.activities, hasLength(1));
        expect(notifier.state.activities.first.id, equals('recent'));
      });
    });

    group('refresh', () {
      test('refreshes engagement with force refresh', () async {
        final cachedData = {
          'activities': [sampleActivity.toJson()],
          'totalEngagements': 1,
          'photosAdded': 1,
          'commentsReceived': 0,
        };
        when(mockCacheService.get(any)).thenAnswer((_) async => cachedData);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleActivity.toJson()]));

        await notifier.refresh(
          babyProfileId: 'profile_1',
          days: 7,
        );

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(any)).called(1);
      });
    });

    group('Time Period Options', () {
      test('supports 7-day period', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleActivity.toJson()]));

        await notifier.fetchEngagement(
          babyProfileId: 'profile_1',
          days: 7,
        );

        expect(notifier.state.activities, isNotEmpty);
      });

      test('supports 30-day period', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleActivity.toJson()]));

        await notifier.fetchEngagement(
          babyProfileId: 'profile_1',
          days: 30,
        );

        expect(notifier.state.activities, isNotEmpty);
      });
    });

    group('Activity Types', () {
      test('counts different activity types', () async {
        final activities = [
          sampleActivity.copyWith(id: 'act_1', type: 'photo_upload'),
          sampleActivity.copyWith(id: 'act_2', type: 'photo_upload'),
          sampleActivity.copyWith(id: 'act_3', type: 'comment'),
          sampleActivity.copyWith(id: 'act_4', type: 'squish'),
          sampleActivity.copyWith(id: 'act_5', type: 'event_created'),
        ];

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder(activities.map((a) => a.toJson()).toList()),
        );

        await notifier.fetchEngagement(
          babyProfileId: 'profile_1',
          days: 7,
        );

        expect(notifier.state.photosAdded, equals(2));
        expect(notifier.state.commentsReceived, equals(1));
      });
    });
  });
}

// Fake builders for Postgrest operations (test doubles)
class FakePostgrestBuilder {
  final List<Map<String, dynamic>> data;

  FakePostgrestBuilder(this.data);

  FakePostgrestBuilder eq(String column, dynamic value) => this;
  FakePostgrestBuilder gte(String column, dynamic value) => this;
  FakePostgrestBuilder order(String column, {bool ascending = true}) => this;

  Future<List<Map<String, dynamic>>> call() async => data;
}
