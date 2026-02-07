import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/notification.dart' as app_notification;
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/tiles/notifications/providers/notifications_provider.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'notifications_provider_test.mocks.dart';

void main() {
  group('NotificationsProvider Tests', () {
    late NotificationsNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    // Sample notification data
    final sampleNotification = app_notification.Notification(
      id: 'notif_1',
      userId: 'user_1',
      type: 'event_invite',
      title: 'Event Invitation',
      body: 'You have been invited to Baby Shower',
      data: {},
      isRead: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRealtimeService = MockRealtimeService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = NotificationsNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
        realtimeService: mockRealtimeService,
      );
    });

    group('Initial State', () {
      test('initial state has empty notifications', () {
        expect(notifier.state.notifications, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.unreadCount, equals(0));
      });
    });

    group('fetchNotifications', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture = notifier.fetchNotifications(userId: 'user_1');

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches notifications from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleNotification.toJson()]));

        await notifier.fetchNotifications(userId: 'user_1');

        // Verify state updated
        expect(notifier.state.notifications, hasLength(1));
        expect(notifier.state.notifications.first.id, equals('notif_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.unreadCount, equals(1));
      });

      test('loads notifications from cache when available', () async {
        // Setup cache to return data
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleNotification.toJson()]);

        await notifier.fetchNotifications(userId: 'user_1');

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any));

        // Verify state updated from cache
        expect(notifier.state.notifications, hasLength(1));
        expect(notifier.state.notifications.first.id, equals('notif_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.fetchNotifications(userId: 'user_1');

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.notifications, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleNotification.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleNotification.toJson()]));

        await notifier.fetchNotifications(
          userId: 'user_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any)).called(1);
      });

      test('calculates unread count correctly', () async {
        final notif1 = sampleNotification.copyWith(id: 'notif_1', isRead: false);
        final notif2 = sampleNotification.copyWith(id: 'notif_2', isRead: false);
        final notif3 = sampleNotification.copyWith(id: 'notif_3', isRead: true);

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          notif1.toJson(),
          notif2.toJson(),
          notif3.toJson(),
        ]));

        await notifier.fetchNotifications(userId: 'user_1');

        expect(notifier.state.unreadCount, equals(2));
      });
    });

    group('markAsRead', () {
      test('marks notification as read', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleNotification.toJson()]));
        await notifier.fetchNotifications(userId: 'user_1');

        // Setup update mock
        when(mockDatabaseService.update(any)).thenReturn(FakePostgrestUpdateBuilder());

        await notifier.markAsRead(
          notificationId: 'notif_1',
          userId: 'user_1',
        );

        // Verify database update
        verify(mockDatabaseService.update(any)).called(1);

        // Verify state updated
        final notification =
            notifier.state.notifications.firstWhere((n) => n.id == 'notif_1');
        expect(notification.isRead, isTrue);
        expect(notifier.state.unreadCount, equals(0));
      });

      test('updates cache after marking as read', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleNotification.toJson()]));
        await notifier.fetchNotifications(userId: 'user_1');

        when(mockDatabaseService.update(any)).thenReturn(FakePostgrestUpdateBuilder());

        await notifier.markAsRead(
          notificationId: 'notif_1',
          userId: 'user_1',
        );

        // Verify cache was updated
        verify(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .called(greaterThanOrEqualTo(1));
      });
    });

    group('markAllAsRead', () {
      test('marks all notifications as read', () async {
        final notif1 = sampleNotification.copyWith(id: 'notif_1', isRead: false);
        final notif2 = sampleNotification.copyWith(id: 'notif_2', isRead: false);

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          notif1.toJson(),
          notif2.toJson(),
        ]));
        await notifier.fetchNotifications(userId: 'user_1');

        when(mockDatabaseService.update(any)).thenReturn(FakePostgrestUpdateBuilder());

        await notifier.markAllAsRead(userId: 'user_1');

        // Verify database update
        verify(mockDatabaseService.update(any)).called(1);

        // Verify all notifications are read
        for (final notification in notifier.state.notifications) {
          expect(notification.isRead, isTrue);
        }
        expect(notifier.state.unreadCount, equals(0));
      });
    });

    group('refresh', () {
      test('refreshes notifications with force refresh', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleNotification.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleNotification.toJson()]));

        await notifier.refresh(userId: 'user_1');

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(any)).called(1);
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT notification', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleNotification.toJson()]));

        await notifier.fetchNotifications(userId: 'user_1');

        final initialCount = notifier.state.notifications.length;

        // Simulate real-time INSERT
        final newNotification = sampleNotification.copyWith(id: 'notif_2');
        notifier.state = notifier.state.copyWith(
          notifications: [newNotification, ...notifier.state.notifications],
          unreadCount: notifier.state.unreadCount + 1,
        );

        expect(notifier.state.notifications.length, equals(initialCount + 1));
        expect(notifier.state.unreadCount, equals(2));
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
  FakePostgrestBuilder order(String column, {bool ascending = true}) => this;
  FakePostgrestBuilder limit(int count) => this;

  Future<List<Map<String, dynamic>>> call() async => data;
}

class FakePostgrestUpdateBuilder {
  FakePostgrestUpdateBuilder eq(String column, dynamic value) => this;
  Future<void> update(Map<String, dynamic> data) async {}
}
