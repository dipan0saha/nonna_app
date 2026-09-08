import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/invite_accept_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/follower/onboarding_follower_invite_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/follower/onboarding_relationship_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

class _FakeInviteAcceptNotifier extends InviteAcceptNotifier {
  _FakeInviteAcceptNotifier(this._state);

  final InviteAcceptState _state;

  @override
  InviteAcceptState build() => _state;
}

void main() {
  testWidgets('OnboardingFollowerInviteScreen shows prototype copy',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inviteAcceptProvider.overrideWith(
            () => _FakeInviteAcceptNotifier(
              const InviteAcceptState(
                status: InviteAcceptStatus.found,
                babyName: 'Baby Parker',
                inviterName: 'Sarah',
                invitedRole: UserRole.follower,
                relationshipLabel: 'Grandma',
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          home: OnboardingThemeScope(child: OnboardingFollowerInviteScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sarah invited you to follow'), findsOneWidget);
    expect(find.text('Baby Parker'), findsOneWidget);
    expect(find.text('Accept Invitation'), findsOneWidget);
  });

  testWidgets('OnboardingRelationshipScreen shows relationship badge',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inviteAcceptProvider.overrideWith(
            () => _FakeInviteAcceptNotifier(
              const InviteAcceptState(
                status: InviteAcceptStatus.accepted,
                babyName: 'Baby Parker',
                inviterName: 'Sarah',
                relationshipLabel: 'Grandma',
              ),
            ),
          ),
          onboardingCoordinatorProvider.overrideWith(
            OnboardingCoordinatorNotifier.new,
          ),
        ],
        child: const MaterialApp(
          home: OnboardingThemeScope(child: OnboardingRelationshipScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining("Baby Parker's circle"), findsOneWidget);
    expect(find.text('Grandma'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
