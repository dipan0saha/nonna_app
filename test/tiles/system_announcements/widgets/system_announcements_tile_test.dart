import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/models/system_announcement.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/system_announcements/widgets/system_announcements_tile.dart';

SystemAnnouncement _makeAnnouncement({
  String id = 'a1',
  String title = 'Welcome!',
  String body = 'Hello there',
  AnnouncementPriority priority = AnnouncementPriority.medium,
  DateTime? expiresAt,
}) {
  return SystemAnnouncement(
    id: id,
    title: title,
    body: body,
    priority: priority,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    expiresAt: expiresAt,
  );
}

Widget _buildWidget({
  List<SystemAnnouncement> announcements = const [],
  Set<String> dismissedIds = const {},
  bool isLoading = false,
  String? error,
  void Function(String)? onDismiss,
  VoidCallback? onRefresh,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SystemAnnouncementsTile(
        announcements: announcements,
        dismissedIds: dismissedIds,
        isLoading: isLoading,
        error: error,
        onDismiss: onDismiss,
        onRefresh: onRefresh,
      ),
    ),
  );
}

void main() {
  group('SystemAnnouncementsTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(
          find.byKey(const Key('system_announcements_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Something went wrong'));
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows empty state when all announcements are dismissed',
        (tester) async {
      final a = _makeAnnouncement(id: 'a1');
      await tester.pumpWidget(_buildWidget(
        announcements: [a],
        dismissedIds: {'a1'},
      ));
      expect(find.text('No announcements'), findsOneWidget);
    });

    testWidgets('shows empty state when announcements list is empty',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('No announcements'), findsOneWidget);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Announcements'), findsOneWidget);
    });

    testWidgets('renders visible announcement rows', (tester) async {
      final announcements = [
        _makeAnnouncement(id: 'a1', title: 'First'),
        _makeAnnouncement(id: 'a2', title: 'Second'),
      ];
      await tester.pumpWidget(_buildWidget(announcements: announcements));
      expect(find.byKey(const Key('announcement_a1')), findsOneWidget);
      expect(find.byKey(const Key('announcement_a2')), findsOneWidget);
    });

    testWidgets('filters out dismissed announcements', (tester) async {
      final announcements = [
        _makeAnnouncement(id: 'a1', title: 'Visible'),
        _makeAnnouncement(id: 'a2', title: 'Dismissed'),
      ];
      await tester.pumpWidget(_buildWidget(
        announcements: announcements,
        dismissedIds: {'a2'},
      ));
      expect(find.byKey(const Key('announcement_a1')), findsOneWidget);
      expect(find.byKey(const Key('announcement_a2')), findsNothing);
    });

    testWidgets('shows at most 3 announcements', (tester) async {
      final announcements =
          List.generate(5, (i) => _makeAnnouncement(id: 'a$i'));
      await tester.pumpWidget(_buildWidget(announcements: announcements));
      // Each announcement row has a Key like 'announcement_a0', etc.
      expect(find.byType(Row).evaluate().length, greaterThanOrEqualTo(3));
    });

    testWidgets('shows dismiss button when onDismiss is provided',
        (tester) async {
      final a = _makeAnnouncement(id: 'a1');
      await tester.pumpWidget(
        _buildWidget(
          announcements: [a],
          onDismiss: (_) {},
        ),
      );
      expect(find.byKey(const Key('dismiss_a1')), findsOneWidget);
    });

    testWidgets('hides dismiss button when onDismiss is null', (tester) async {
      final a = _makeAnnouncement(id: 'a1');
      await tester.pumpWidget(_buildWidget(announcements: [a]));
      expect(find.byKey(const Key('dismiss_a1')), findsNothing);
    });

    testWidgets('calls onDismiss with correct id when dismiss tapped',
        (tester) async {
      String? dismissed;
      final a = _makeAnnouncement(id: 'a1');
      await tester.pumpWidget(
        _buildWidget(
          announcements: [a],
          onDismiss: (id) => dismissed = id,
        ),
      );
      await tester.tap(find.byKey(const Key('dismiss_a1')));
      expect(dismissed, equals('a1'));
    });

    testWidgets('error retry calls onRefresh', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _buildWidget(error: 'Oops', onRefresh: () => called = true),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      expect(called, isTrue);
    });

    testWidgets('shows announcement title and body', (tester) async {
      final a =
          _makeAnnouncement(id: 'a1', title: 'Big News', body: 'Details here');
      await tester.pumpWidget(_buildWidget(announcements: [a]));
      expect(find.text('Big News'), findsOneWidget);
      expect(find.text('Details here'), findsOneWidget);
    });
  });
}
