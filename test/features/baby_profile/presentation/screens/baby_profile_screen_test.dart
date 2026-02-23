import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/baby_membership.dart';
import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';
import 'package:nonna_app/features/baby_profile/presentation/screens/baby_profile_screen.dart';

// ---------------------------------------------------------------------------
// Fake notifier
// ---------------------------------------------------------------------------

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
  }) async =>
      true;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

BabyProfile _makeBabyProfile({String name = 'Emma'}) {
  final now = DateTime(2024, 1, 1);
  return BabyProfile(
    id: 'baby-1',
    name: name,
    gender: Gender.female,
    createdAt: now,
    updatedAt: now,
  );
}

BabyMembership _makeMembership({
  String userId = 'follower-1',
  UserRole role = UserRole.follower,
}) {
  return BabyMembership(
    babyProfileId: 'baby-1',
    userId: userId,
    role: role,
    createdAt: DateTime(2024, 1, 1),
  );
}

Widget _buildScreen(BabyProfileState state) {
  return ProviderScope(
    overrides: [
      babyProfileProvider.overrideWith(() => _FakeBabyProfileNotifier(state)),
    ],
    child: const MaterialApp(
      home: BabyProfileScreen(
        babyProfileId: 'baby-1',
        currentUserId: 'user-1',
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BabyProfileScreen', () {
    testWidgets("renders Scaffold with key 'baby_profile_screen'",
        (tester) async {
      await tester.pumpWidget(_buildScreen(const BabyProfileState()));
      expect(find.byKey(const Key('baby_profile_screen')), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        _buildScreen(const BabyProfileState(isLoading: true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error text when error is set', (tester) async {
      await tester.pumpWidget(
        _buildScreen(const BabyProfileState(error: 'Load failed')),
      );
      expect(find.text('Load failed'), findsOneWidget);
    });

    testWidgets('shows baby name when profile is loaded', (tester) async {
      await tester.pumpWidget(
        _buildScreen(BabyProfileState(profile: _makeBabyProfile(name: 'Emma'))),
      );
      expect(find.text('Emma'), findsWidgets);
    });

    testWidgets('shows edit button for owner', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          BabyProfileState(profile: _makeBabyProfile(), isOwner: true),
        ),
      );
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('hides edit button for non-owner', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          BabyProfileState(profile: _makeBabyProfile(), isOwner: false),
        ),
      );
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('shows follower list for owner when followers exist',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          BabyProfileState(
            profile: _makeBabyProfile(),
            isOwner: true,
            memberships: [_makeMembership()],
          ),
        ),
      );
      expect(find.text('Followers'), findsOneWidget);
    });

    testWidgets('shows empty state when profile is null', (tester) async {
      await tester.pumpWidget(_buildScreen(const BabyProfileState()));
      expect(find.text('No baby profile found'), findsOneWidget);
    });
  });
}
