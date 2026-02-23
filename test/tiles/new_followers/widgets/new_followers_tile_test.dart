import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/baby_membership.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/new_followers/widgets/new_followers_tile.dart';

BabyMembership _makeFollower({
  String userId = 'u1',
  String? relationshipLabel,
  bool isActive = true,
}) {
  final now = DateTime.now();
  return BabyMembership(
    babyProfileId: 'bp1',
    userId: userId,
    role: UserRole.follower,
    relationshipLabel: relationshipLabel,
    createdAt: now.subtract(const Duration(days: 5)),
    removedAt: isActive ? null : now.subtract(const Duration(days: 1)),
  );
}

Widget _buildWidget({
  List<BabyMembership> followers = const [],
  int activeCount = 0,
  bool isLoading = false,
  String? error,
  void Function(BabyMembership)? onFollowerTap,
  VoidCallback? onRefresh,
  VoidCallback? onViewAll,
}) {
  return MaterialApp(
    home: Scaffold(
      body: NewFollowersTile(
        followers: followers,
        activeCount: activeCount,
        isLoading: isLoading,
        error: error,
        onFollowerTap: onFollowerTap,
        onRefresh: onRefresh,
        onViewAll: onViewAll,
      ),
    ),
  );
}

void main() {
  group('NewFollowersTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('new_followers_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Could not load'));
      expect(find.text('Could not load'), findsOneWidget);
    });

    testWidgets('shows empty state when followers list is empty', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('No new followers recently'), findsOneWidget);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('New Followers'), findsOneWidget);
    });

    testWidgets('shows follower rows when followers are provided', (tester) async {
      final followers = [
        _makeFollower(userId: 'u1'),
        _makeFollower(userId: 'u2'),
      ];
      await tester.pumpWidget(_buildWidget(followers: followers));
      expect(find.byKey(const Key('follower_u1')), findsOneWidget);
      expect(find.byKey(const Key('follower_u2')), findsOneWidget);
    });

    testWidgets('shows at most 5 followers', (tester) async {
      final followers = List.generate(7, (i) => _makeFollower(userId: 'u$i'));
      await tester.pumpWidget(_buildWidget(followers: followers));
      expect(find.byType(InkWell), findsNWidgets(5));
    });

    testWidgets('shows active badge for active follower', (tester) async {
      final follower = _makeFollower(userId: 'u1', isActive: true);
      await tester.pumpWidget(_buildWidget(followers: [follower]));
      expect(find.byKey(const Key('active_badge_u1')), findsOneWidget);
    });

    testWidgets('shows removed badge for removed follower', (tester) async {
      final follower = _makeFollower(userId: 'u1', isActive: false);
      await tester.pumpWidget(_buildWidget(followers: [follower]));
      expect(find.byKey(const Key('removed_badge_u1')), findsOneWidget);
    });

    testWidgets('shows active count badge when activeCount > 0', (tester) async {
      await tester.pumpWidget(_buildWidget(activeCount: 3));
      expect(
          find.byKey(const Key('new_followers_count_badge')), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('hides count badge when activeCount is 0', (tester) async {
      await tester.pumpWidget(_buildWidget(activeCount: 0));
      expect(
          find.byKey(const Key('new_followers_count_badge')), findsNothing);
    });

    testWidgets('shows relationship label when present', (tester) async {
      final follower =
          _makeFollower(userId: 'u1', relationshipLabel: 'Aunt Mary');
      await tester.pumpWidget(_buildWidget(followers: [follower]));
      expect(find.text('Aunt Mary'), findsOneWidget);
    });

    testWidgets('calls onFollowerTap when row is tapped', (tester) async {
      BabyMembership? tapped;
      final follower = _makeFollower(userId: 'u1');
      await tester.pumpWidget(
        _buildWidget(
          followers: [follower],
          onFollowerTap: (f) => tapped = f,
        ),
      );
      await tester.tap(find.byKey(const Key('follower_u1')));
      expect(tapped, equals(follower));
    });

    testWidgets('shows view all button when onViewAll is provided',
        (tester) async {
      await tester.pumpWidget(_buildWidget(onViewAll: () {}));
      expect(
          find.byKey(const Key('new_followers_view_all')), findsOneWidget);
    });

    testWidgets('view all button calls onViewAll callback', (tester) async {
      var called = false;
      await tester.pumpWidget(
          _buildWidget(onViewAll: () => called = true));
      await tester.tap(find.byKey(const Key('new_followers_view_all')));
      expect(called, isTrue);
    });

    testWidgets('hides view all button when onViewAll is null', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(
          find.byKey(const Key('new_followers_view_all')), findsNothing);
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
