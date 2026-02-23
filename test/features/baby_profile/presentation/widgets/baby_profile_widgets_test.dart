import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/baby_membership.dart';
import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/features/baby_profile/presentation/widgets/baby_profile_widgets.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

BabyProfile _makeBabyProfile({
  String name = 'Lily',
  DateTime? expectedBirthDate,
  DateTime? actualBirthDate,
  Gender gender = Gender.female,
}) {
  final now = DateTime(2024, 1, 1);
  return BabyProfile(
    id: 'baby-1',
    name: name,
    gender: gender,
    expectedBirthDate: expectedBirthDate,
    actualBirthDate: actualBirthDate,
    createdAt: now,
    updatedAt: now,
  );
}

BabyMembership _makeMembership({
  String userId = 'user-1',
  UserRole role = UserRole.follower,
  String? relationshipLabel,
}) {
  return BabyMembership(
    babyProfileId: 'baby-1',
    userId: userId,
    role: role,
    relationshipLabel: relationshipLabel,
    createdAt: DateTime(2024, 1, 1),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BabyProfileCard', () {
    testWidgets("has key 'baby_profile_card'", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BabyProfileCard(profile: _makeBabyProfile()),
          ),
        ),
      );
      expect(find.byKey(const Key('baby_profile_card')), findsOneWidget);
    });

    testWidgets('shows baby name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BabyProfileCard(profile: _makeBabyProfile(name: 'Oliver')),
          ),
        ),
      );
      expect(find.text('Oliver'), findsOneWidget);
    });

    testWidgets('shows Due date when expected birth date is set and not born',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BabyProfileCard(
              profile: _makeBabyProfile(
                expectedBirthDate: DateTime(2025, 6, 15),
              ),
            ),
          ),
        ),
      );
      expect(find.textContaining('Due'), findsOneWidget);
    });

    testWidgets('shows Born date when actualBirthDate is set', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BabyProfileCard(
              profile: _makeBabyProfile(
                actualBirthDate: DateTime(2024, 3, 10),
              ),
            ),
          ),
        ),
      );
      expect(find.textContaining('Born'), findsOneWidget);
    });
  });

  group('FollowerListItem', () {
    testWidgets('has correct key with userId', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowerListItem(
              membership: _makeMembership(userId: 'user-42'),
            ),
          ),
        ),
      );
      expect(
        find.byKey(const Key('follower_list_item_user-42')),
        findsOneWidget,
      );
    });

    testWidgets('shows remove button when onRemove is provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowerListItem(
              membership: _makeMembership(),
              onRemove: () {},
            ),
          ),
        ),
      );
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('does not show remove button when onRemove is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowerListItem(
              membership: _makeMembership(),
            ),
          ),
        ),
      );
      expect(find.byType(IconButton), findsNothing);
    });
  });
}
