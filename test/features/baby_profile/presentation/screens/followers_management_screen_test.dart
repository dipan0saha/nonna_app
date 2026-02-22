import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/baby_membership.dart';
import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';
import 'package:nonna_app/features/baby_profile/presentation/screens/followers_management_screen.dart';

class _FakeBabyProfileNotifier extends BabyProfileNotifier {
  _FakeBabyProfileNotifier(this._initial);
  final BabyProfileState _initial;

  @override
  BabyProfileState build() => _initial;

  @override
  Future<void> loadProfile({
    required String babyProfileId,
    required String currentUserId,
    bool forceRefresh = false,
  }) async {}

  @override
  Future<bool> removeFollower({
    required String babyProfileId,
    required String membershipId,
  }) async => true;
}

BabyProfile _makeProfile() {
  final now = DateTime(2024, 1, 1);
  return BabyProfile(
    id: 'baby-1',
    name: 'Emma',
    gender: Gender.female,
    createdAt: now,
    updatedAt: now,
  );
}

BabyMembership _makeMembership(String userId) {
  return BabyMembership(
    babyProfileId: 'baby-1',
    userId: userId,
    role: UserRole.follower,
    createdAt: DateTime(2024, 1, 1),
  );
}

Widget _buildScreen(BabyProfileState state, {VoidCallback? onInviteTap}) {
  return ProviderScope(
    overrides: [
      babyProfileProvider.overrideWith(() => _FakeBabyProfileNotifier(state)),
    ],
    child: MaterialApp(
      home: FollowersManagementScreen(
        babyProfileId: 'baby-1',
        currentUserId: 'user-1',
        onInviteTap: onInviteTap,
      ),
    ),
  );
}

void main() {
  group('FollowersManagementScreen', () {
    testWidgets("renders Scaffold with key 'followers_management_screen'",
        (tester) async {
      await tester.pumpWidget(_buildScreen(const BabyProfileState()));
      expect(
          find.byKey(const Key('followers_management_screen')), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
          _buildScreen(const BabyProfileState(isLoading: true)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when error is set', (tester) async {
      await tester.pumpWidget(
          _buildScreen(const BabyProfileState(error: 'Failed')));
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('shows empty state when no followers', (tester) async {
      await tester.pumpWidget(
          _buildScreen(BabyProfileState(profile: _makeProfile())));
      expect(find.byKey(const Key('no_followers_empty_state')), findsOneWidget);
    });

    testWidgets('shows follower list items when followers exist',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          BabyProfileState(
            profile: _makeProfile(),
            memberships: [
              _makeMembership('follower-1'),
              _makeMembership('follower-2'),
            ],
          ),
        ),
      );
      expect(find.byKey(const Key('follower_item_0')), findsOneWidget);
      expect(find.byKey(const Key('follower_item_1')), findsOneWidget);
    });

    testWidgets('shows invite button in app bar', (tester) async {
      await tester.pumpWidget(_buildScreen(const BabyProfileState()));
      expect(find.byKey(const Key('invite_follower_button')), findsOneWidget);
    });

    testWidgets('calls onInviteTap when invite button pressed', (tester) async {
      var called = false;
      await tester.pumpWidget(
          _buildScreen(const BabyProfileState(), onInviteTap: () => called = true));
      await tester.tap(find.byKey(const Key('invite_follower_button')));
      await tester.pump();
      expect(called, isTrue);
    });
  });
}
