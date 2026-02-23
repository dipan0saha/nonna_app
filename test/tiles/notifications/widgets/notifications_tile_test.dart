import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/enums/notification_type.dart';
import 'package:nonna_app/core/models/notification.dart' as app_notification;
import 'package:nonna_app/tiles/notifications/widgets/notifications_tile.dart';

app_notification.Notification _makeNotification({
  String id = 'n1',
  String title = 'New Event',
  String body = 'An event was created',
  bool isRead = false,
  NotificationType type = NotificationType.event,
}) {
  return app_notification.Notification(
    id: id,
    recipientUserId: 'u1',
    type: type,
    title: title,
    body: body,
    readAt: isRead ? DateTime.now() : null,
    createdAt: DateTime.now(),
  );
}

Widget _buildWidget({
  List<app_notification.Notification> notifications = const [],
  int unreadCount = 0,
  bool isLoading = false,
  String? error,
  void Function(app_notification.Notification)? onNotificationTap,
  VoidCallback? onMarkAllRead,
  VoidCallback? onRefresh,
  VoidCallback? onViewAll,
}) {
  return MaterialApp(
    home: Scaffold(
      body: NotificationsTile(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: isLoading,
        error: error,
        onNotificationTap: onNotificationTap,
        onMarkAllRead: onMarkAllRead,
        onRefresh: onRefresh,
        onViewAll: onViewAll,
      ),
    ),
  );
}

void main() {
  group('NotificationsTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('notifications_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Network error'));
      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('shows empty state when notifications list is empty', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('No notifications'), findsOneWidget);
    });

    testWidgets('shows notifications when provided', (tester) async {
      final notifications = [
        _makeNotification(id: 'n1', title: 'Alert 1'),
        _makeNotification(id: 'n2', title: 'Alert 2'),
      ];
      await tester.pumpWidget(_buildWidget(notifications: notifications));
      expect(find.byKey(const Key('notification_item_n1')), findsOneWidget);
      expect(find.byKey(const Key('notification_item_n2')), findsOneWidget);
    });

    testWidgets('shows at most 5 notifications', (tester) async {
      final notifications =
          List.generate(7, (i) => _makeNotification(id: 'n$i', title: 'N $i'));
      await tester.pumpWidget(_buildWidget(notifications: notifications));
      int count = 0;
      for (int i = 0; i < 5; i++) {
        if (tester.any(find.byKey(Key('notification_item_n$i')))) count++;
      }
      expect(count, 5);
      expect(find.byKey(const Key('notification_item_n5')), findsNothing);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows unread badge when unreadCount > 0', (tester) async {
      await tester.pumpWidget(_buildWidget(unreadCount: 3));
      expect(find.byKey(const Key('unread_badge')), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('hides unread badge when unreadCount is 0', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('unread_badge')), findsNothing);
    });

    testWidgets('shows mark all read button when applicable', (tester) async {
      await tester.pumpWidget(
        _buildWidget(unreadCount: 2, onMarkAllRead: () {}),
      );
      expect(find.byKey(const Key('mark_all_read_button')), findsOneWidget);
    });

    testWidgets('hides mark all read when unreadCount is 0', (tester) async {
      await tester.pumpWidget(_buildWidget(onMarkAllRead: () {}));
      expect(find.byKey(const Key('mark_all_read_button')), findsNothing);
    });

    testWidgets('mark all read button calls onMarkAllRead', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _buildWidget(
          unreadCount: 1,
          onMarkAllRead: () => called = true,
        ),
      );
      await tester.tap(find.byKey(const Key('mark_all_read_button')));
      expect(called, isTrue);
    });

    testWidgets('calls onNotificationTap when item is tapped', (tester) async {
      app_notification.Notification? tapped;
      final notification = _makeNotification();
      await tester.pumpWidget(
        _buildWidget(
          notifications: [notification],
          onNotificationTap: (n) => tapped = n,
        ),
      );
      await tester.tap(find.byKey(const Key('notification_item_n1')));
      expect(tapped, equals(notification));
    });

    testWidgets('shows view all button when onViewAll is provided', (tester) async {
      await tester.pumpWidget(_buildWidget(onViewAll: () {}));
      expect(find.byKey(const Key('notifications_view_all')), findsOneWidget);
    });

    testWidgets('view all button calls onViewAll callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildWidget(onViewAll: () => called = true));
      await tester.tap(find.byKey(const Key('notifications_view_all')));
      expect(called, isTrue);
    });

    testWidgets('error retry calls onRefresh', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _buildWidget(error: 'Oops', onRefresh: () => called = true),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      expect(called, isTrue);
    });
  });
}
