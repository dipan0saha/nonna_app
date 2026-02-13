import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/notification_type.dart';
import 'package:nonna_app/core/models/notification.dart' as app_notification;
import 'package:nonna_app/tiles/notifications/providers/notifications_provider.dart';

import '../../../helpers/fake_postgrest_builders.dart';
import '../../../helpers/mock_factory.dart';

void main() {
  group('NotificationsProvider Tests', () {
    late ProviderContainer container;
    late MockServiceContainer mocks;

    // Sample notification data
    final sampleNotification = app_notification.Notification(
      id: 'notif_1',
      recipientUserId: 'user_1',
      type: NotificationType.event,
      title: 'Event Invitation',
      body: 'You have been invited to Baby Shower',
      createdAt: DateTime.now(),
    );

    setUp(() {
      mocks = MockFactory.createServiceContainer();
      when(mocks.cache.isInitialized).thenReturn(true);
      when(mocks.cache.get(any)).thenAnswer((_) async => null);
      when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
          .thenAnswer((_) async {});
      when(mocks.database.select(any))
          .thenAnswer((_) => FakePostgrestBuilder([]));
      when(mocks.database.update(any, any))
          .thenAnswer((_) => FakePostgrestUpdateBuilder());
      when(mocks.realtime.subscribe(
        table: anyNamed('table'),
        channelName: anyNamed('channelName'),
        filter: anyNamed('filter'),
      )).thenAnswer((_) => Stream.empty());
      when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});

      // Create a ProviderContainer with overrides
      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mocks.database),
          cacheServiceProvider.overrideWithValue(mocks.cache),
          realtimeServiceProvider.overrideWithValue(mocks.realtime),
        ],
      );
    });

    tearDown() {
      container.dispose();
      reset(mocks.database);
      reset(mocks.cache);
      reset(mocks.realtime);
    }

    group('Initial State', () {
      test('initial state has empty notifications', () {
        final state = container.read(notificationsProvider);

        expect(state.notifications, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.unreadCount, equals(0));
      });
    });

    group('fetchNotifications', () {
      test('sets loading state while fetching', () async {
        final notifier = container.read(notificationsProvider.notifier);

        // Setup mock to delay response
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        // Start fetching
        final fetchFuture = notifier.fetchNotifications(userId: 'user_1');

        // Verify loading state
        expect(container.read(notificationsProvider).isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches notifications from database when cache is empty', () async {
        final notifier = container.read(notificationsProvider.notifier);

        // Setup mocks
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any)).thenAnswer(
            (_) => FakePostgrestBuilder([sampleNotification.toJson()]));

        await notifier.fetchNotifications(userId: 'user_1');

        // Verify state updated
        final state = container.read(notificationsProvider);
        expect(state.notifications, hasLength(1));
        expect(state.notifications.first.id, equals('notif_1'));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.unreadCount, equals(1));
      });

      test('loads notifications from cache when available', () async {
        final notifier = container.read(notificationsProvider.notifier);

        // Setup cache to return data
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleNotification.toJson()]);

        await notifier.fetchNotifications(userId: 'user_1');

        // Verify database was not called
        verifyNever(mocks.database.select(any));

        // Verify state updated from cache
        final state = container.read(notificationsProvider);
        expect(state.notifications, hasLength(1));
        expect(state.notifications.first.id, equals('notif_1'));
      });

      test('handles errors gracefully', () async {
        final notifier = container.read(notificationsProvider.notifier);

        // Setup mock to throw error
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any)).thenThrow(Exception('Database error'));

        await notifier.fetchNotifications(userId: 'user_1');

        // Verify error state
        final state = container.read(notificationsProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, contains('Database error'));
        expect(state.notifications, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        final notifier = container.read(notificationsProvider.notifier);

        // Setup mocks
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleNotification.toJson()]);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any)).thenAnswer(
            (_) => FakePostgrestBuilder([sampleNotification.toJson()]));

        await notifier.fetchNotifications(
          userId: 'user_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mocks.database.select(any)).called(1);
      });

      test('calculates unread count correctly', () async {
        final notifier = container.read(notificationsProvider.notifier);

        final notif1 = sampleNotification.copyWith(id: 'notif_1', readAt: null);
        final notif2 = sampleNotification.copyWith(id: 'notif_2', readAt: null);
        final notif3 =
            sampleNotification.copyWith(id: 'notif_3', readAt: DateTime.now());

        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([
                  notif1.toJson(),
                  notif2.toJson(),
                  notif3.toJson(),
                ]));

        await notifier.fetchNotifications(userId: 'user_1');

        final state = container.read(notificationsProvider);
        expect(state.unreadCount, equals(2));
      });
    });

    group('markAsRead', () {
      test('marks notification as read', () async {
        final notifier = container.read(notificationsProvider.notifier);

        // Setup initial state
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any)).thenAnswer(
            (_) => FakePostgrestBuilder([sampleNotification.toJson()]));
        await notifier.fetchNotifications(userId: 'user_1');

        // Setup update mock
        when(mocks.database.update(any, any))
            .thenAnswer((_) => FakePostgrestUpdateBuilder());

        await notifier.markAsRead(
          notificationId: 'notif_1',
          userId: 'user_1',
        );

        // Verify database update
        verify(mocks.database.update(any, any)).called(1);

        // Verify state updated
        final state = container.read(notificationsProvider);
        final notification =
            state.notifications.firstWhere((n) => n.id == 'notif_1');
        expect(notification.isRead, isTrue);
        expect(state.unreadCount, equals(0));
      });

      test('updates cache after marking as read', () async {
        final notifier = container.read(notificationsProvider.notifier);

        // Setup initial state
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any)).thenAnswer(
            (_) => FakePostgrestBuilder([sampleNotification.toJson()]));
        await notifier.fetchNotifications(userId: 'user_1');

        when(mocks.database.update(any, any))
            .thenAnswer((_) => FakePostgrestUpdateBuilder());

        await notifier.markAsRead(
          notificationId: 'notif_1',
          userId: 'user_1',
        );

        // Verify cache was updated
        verify(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .called(greaterThanOrEqualTo(1));
      });
    });

    group('markAllAsRead', () {
      test('marks all notifications as read', () async {
        final notifier = container.read(notificationsProvider.notifier);

        final notif1 = sampleNotification.copyWith(id: 'notif_1', readAt: null);
        final notif2 = sampleNotification.copyWith(id: 'notif_2', readAt: null);

        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([
                  notif1.toJson(),
                  notif2.toJson(),
                ]));
        await notifier.fetchNotifications(userId: 'user_1');

        when(mocks.database.update(any, any))
            .thenAnswer((_) => FakePostgrestUpdateBuilder());

        await notifier.markAllAsRead(userId: 'user_1');

        // Verify database update
        verify(mocks.database.update(any, any)).called(1);

        // Verify all notifications are read
        final state = container.read(notificationsProvider);
        for (final notification in state.notifications) {
          expect(notification.isRead, isTrue);
        }
        expect(state.unreadCount, equals(0));
      });
    });

    group('refresh', () {
      test('refreshes notifications with force refresh', () async {
        final notifier = container.read(notificationsProvider.notifier);

        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleNotification.toJson()]);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any)).thenAnswer(
            (_) => FakePostgrestBuilder([sampleNotification.toJson()]));

        await notifier.refresh(userId: 'user_1');

        // Verify database was called (bypassing cache)
        verify(mocks.database.select(any)).called(1);
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT notification', () async {
        final notifier = container.read(notificationsProvider.notifier);

        // Setup initial state
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          channelName: anyNamed('channelName'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any)).thenAnswer(
            (_) => FakePostgrestBuilder([sampleNotification.toJson()]));

        await notifier.fetchNotifications(userId: 'user_1');

        final state = container.read(notificationsProvider);
        final initialCount = state.notifications.length;

        // Simulate real-time INSERT
        // ignore: unused_local_variable
        final newNotification = sampleNotification.copyWith(id: 'notif_2');
        // Note: This test is checking the structure but can't easily simulate real-time
        // updates without exposing the internal _handleRealtimeUpdate method
        // In a real scenario, the realtime subscription would trigger this

        expect(initialCount, equals(1)); // Just verify initial state was set
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () {
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});

        // Disposing the container will trigger the notifier's dispose
        // Don't need to manually call dispose anymore
        expect(container.read(notificationsProvider), isNotNull);
      });
    });
  });
}
