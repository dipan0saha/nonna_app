import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/system_announcement.dart';
import 'package:nonna_app/tiles/system_announcements/providers/system_announcements_provider.dart';

import '../../../helpers/mock_factory.dart';

void main() {
  group('SystemAnnouncementsProvider Tests', () {
    late ProviderContainer container;
    late MockServiceContainer mocks;

    // Sample announcement data
    final sampleAnnouncement = SystemAnnouncement(
      id: 'announcement_1',
      title: 'New Feature Release',
      body: 'Check out our new photo editing features!',
      priority: AnnouncementPriority.high,
      createdAt: DateTime.now(),
    );

    setUp(() {
      mocks = MockFactory.createServiceContainer();
      when(mocks.cache.isInitialized).thenReturn(true);

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mocks.database),
          cacheServiceProvider.overrideWithValue(mocks.cache),
          realtimeServiceProvider.overrideWithValue(mocks.realtime),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('initial state has empty announcements', () {
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .announcements,
            isEmpty);
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .isLoading,
            isFalse);
        expect(container.read(systemAnnouncementsProvider.notifier).state.error,
            isNull);
      });
    });

    group('loadAnnouncements', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mocks.cache.get(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return null;
        });

        // Start fetching
        final fetchFuture = container
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: 'test_user');

        // Verify loading state
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .isLoading,
            isTrue);

        await fetchFuture;
      });

      test('loads announcements when cache is empty', () async {
        // Setup mocks
        when(mocks.cache.get(any)).thenAnswer((_) async => null);

        await container
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: 'test_user');

        // Verify state updated with mock announcements
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .announcements,
            isNotEmpty);
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .isLoading,
            isFalse);
        expect(container.read(systemAnnouncementsProvider.notifier).state.error,
            isNull);
      });

      test('loads announcements from cache when available', () async {
        // Setup cache to return data
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleAnnouncement.toJson()]);

        await container
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: 'test_user');

        // Verify state updated from cache
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .announcements,
            hasLength(1));
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .announcements
                .first
                .id,
            equals('announcement_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mocks.cache.get(any)).thenThrow(Exception('Cache error'));

        await container
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: 'test_user');

        // Verify error state - should fall back to mock announcements
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .isLoading,
            isFalse);
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .announcements,
            isNotEmpty);
      });

      test('filters expired announcements', () async {
        final activeAnnouncement = SystemAnnouncement(
          id: 'ann_1',
          title: 'Active',
          body: 'This is active',
          priority: AnnouncementPriority.high,
          createdAt: DateTime.now(),
        );
        final expiredAnnouncement = SystemAnnouncement(
          id: 'ann_2',
          title: 'Expired',
          body: 'This is expired',
          priority: AnnouncementPriority.high,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        when(mocks.cache.get(any)).thenAnswer((_) async =>
            [activeAnnouncement.toJson(), expiredAnnouncement.toJson()]);

        await container
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: 'test_user');

        // Should only have non-expired announcements
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .announcements,
            hasLength(1));
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .announcements
                .first
                .id,
            equals('ann_1'));
      });

      test('sorts announcements by priority', () async {
        final highPriority = SystemAnnouncement(
          id: 'ann_1',
          title: 'High',
          body: 'High priority',
          priority: AnnouncementPriority.high,
          createdAt: DateTime.now(),
        );
        final mediumPriority = SystemAnnouncement(
          id: 'ann_2',
          title: 'Medium',
          body: 'Medium priority',
          priority: AnnouncementPriority.medium,
          createdAt: DateTime.now(),
        );
        final lowPriority = SystemAnnouncement(
          id: 'ann_3',
          title: 'Low',
          body: 'Low priority',
          priority: AnnouncementPriority.low,
          createdAt: DateTime.now(),
        );

        when(mocks.cache.get(any)).thenAnswer((_) async => [
              lowPriority.toJson(),
              highPriority.toJson(),
              mediumPriority.toJson(),
            ]);

        await container
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: 'test_user');

        // Should be sorted by priority (high first)
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .announcements[0]
                .priority,
            equals(AnnouncementPriority.high));
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .announcements[1]
                .priority,
            equals(AnnouncementPriority.medium));
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .announcements[2]
                .priority,
            equals(AnnouncementPriority.low));
      });

      test('saves announcements to cache', () async {
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any)).thenAnswer((_) async => Future.value());

        await container
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: 'test_user');

        // Verify cache put was called
        verify(mocks.cache.put(any, any)).called(greaterThanOrEqualTo(1));
      });
    });

    group('dismissAnnouncement', () {
      test('dismisses announcement locally', () async {
        // Setup initial state with announcements
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleAnnouncement.toJson()]);
        when(mocks.cache.put(any, any)).thenAnswer((_) async => Future.value());
        await container
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: 'test_user');

        final initialCount = container
            .read(systemAnnouncementsProvider.notifier)
            .getActiveAnnouncements()
            .length;

        await container
            .read(systemAnnouncementsProvider.notifier)
            .dismissAnnouncement(
              announcementId: 'announcement_1',
              userId: 'test_user',
            );

        // Verify announcement was dismissed
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .dismissedIds,
            contains('announcement_1'));
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .getActiveAnnouncements()
                .length,
            equals(initialCount - 1));
      });

      test('saves dismissed state to cache', () async {
        // Setup initial state
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleAnnouncement.toJson()]);
        when(mocks.cache.put(any, any)).thenAnswer((_) async => Future.value());
        await container
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: 'test_user');

        await container
            .read(systemAnnouncementsProvider.notifier)
            .dismissAnnouncement(
              announcementId: 'announcement_1',
              userId: 'test_user',
            );

        // Verify cache was updated
        verify(mocks.cache.put(any, any)).called(greaterThanOrEqualTo(1));
      });
    });

    group('getActiveAnnouncements', () {
      test('returns only non-dismissed, non-expired announcements', () async {
        final announcement1 = SystemAnnouncement(
          id: 'ann_1',
          title: 'Active 1',
          body: 'Active announcement 1',
          priority: AnnouncementPriority.high,
          createdAt: DateTime.now(),
        );
        final announcement2 = SystemAnnouncement(
          id: 'ann_2',
          title: 'Active 2',
          body: 'Active announcement 2',
          priority: AnnouncementPriority.medium,
          createdAt: DateTime.now(),
        );

        when(mocks.cache.get(any)).thenAnswer(
            (_) async => [announcement1.toJson(), announcement2.toJson()]);
        when(mocks.cache.put(any, any)).thenAnswer((_) async => Future.value());
        await container
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: 'test_user');

        // Dismiss one announcement
        await container
            .read(systemAnnouncementsProvider.notifier)
            .dismissAnnouncement(
              announcementId: 'ann_1',
              userId: 'test_user',
            );

        final activeAnnouncements = container
            .read(systemAnnouncementsProvider.notifier)
            .getActiveAnnouncements();

        // Should only return non-dismissed announcements
        expect(activeAnnouncements, hasLength(1));
        expect(activeAnnouncements.first.id, equals('ann_2'));
      });
    });

    group('getCriticalAnnouncements', () {
      test('returns only critical priority announcements', () async {
        final criticalAnnouncement = SystemAnnouncement(
          id: 'ann_1',
          title: 'Critical',
          body: 'Critical announcement',
          priority: AnnouncementPriority.critical,
          createdAt: DateTime.now(),
        );
        final highAnnouncement = SystemAnnouncement(
          id: 'ann_2',
          title: 'High',
          body: 'High announcement',
          priority: AnnouncementPriority.high,
          createdAt: DateTime.now(),
        );

        when(mocks.cache.get(any)).thenAnswer((_) async =>
            [criticalAnnouncement.toJson(), highAnnouncement.toJson()]);
        await container
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: 'test_user');

        final criticalAnnouncements = container
            .read(systemAnnouncementsProvider.notifier)
            .getCriticalAnnouncements();

        expect(criticalAnnouncements, hasLength(1));
        expect(criticalAnnouncements.first.priority,
            equals(AnnouncementPriority.critical));
      });
    });

    group('clearDismissals', () {
      test('clears all dismissals for a user', () async {
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleAnnouncement.toJson()]);
        when(mocks.cache.put(any, any)).thenAnswer((_) async => Future.value());
        await container
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: 'test_user');

        // Dismiss an announcement
        await container
            .read(systemAnnouncementsProvider.notifier)
            .dismissAnnouncement(
              announcementId: 'announcement_1',
              userId: 'test_user',
            );
        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .dismissedIds,
            isNotEmpty);

        // Clear dismissals
        await container
            .read(systemAnnouncementsProvider.notifier)
            .clearDismissals(userId: 'test_user');

        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .dismissedIds,
            isEmpty);
      });
    });

    group('Announcement Priority', () {
      test('supports different announcement priorities', () async {
        final criticalAnnouncement = SystemAnnouncement(
          id: 'ann_1',
          title: 'Critical',
          body: 'Critical announcement',
          priority: AnnouncementPriority.critical,
          createdAt: DateTime.now(),
        );
        final highAnnouncement = SystemAnnouncement(
          id: 'ann_2',
          title: 'High',
          body: 'High announcement',
          priority: AnnouncementPriority.high,
          createdAt: DateTime.now(),
        );
        final mediumAnnouncement = SystemAnnouncement(
          id: 'ann_3',
          title: 'Medium',
          body: 'Medium announcement',
          priority: AnnouncementPriority.medium,
          createdAt: DateTime.now(),
        );

        when(mocks.cache.get(any)).thenAnswer((_) async => [
              criticalAnnouncement.toJson(),
              highAnnouncement.toJson(),
              mediumAnnouncement.toJson(),
            ]);

        await container
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: 'test_user');

        expect(
            container
                .read(systemAnnouncementsProvider.notifier)
                .state
                .announcements,
            hasLength(3));
        expect(
          container
              .read(systemAnnouncementsProvider.notifier)
              .state
              .announcements
              .any((a) => a.priority == AnnouncementPriority.critical),
          isTrue,
        );
        expect(
          container
              .read(systemAnnouncementsProvider.notifier)
              .state
              .announcements
              .any((a) => a.priority == AnnouncementPriority.high),
          isTrue,
        );
      });
    });
  });
}
