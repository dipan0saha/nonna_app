import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/invite_accept_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/coowner/onboarding_coowner_invite_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/coowner/onboarding_coowner_welcome_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

class _FakeInviteAcceptNotifier extends InviteAcceptNotifier {
  _FakeInviteAcceptNotifier(this._state);

  final InviteAcceptState _state;

  @override
  InviteAcceptState build() => _state;
}

void main() {
  testWidgets('OnboardingCoOwnerInviteScreen shows co-own copy',
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
                invitedRole: UserRole.owner,
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          home: OnboardingThemeScope(child: OnboardingCoOwnerInviteScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sarah invited you to co-own'), findsOneWidget);
    expect(find.text('Accept & Join as Owner'), findsOneWidget);
    expect(find.textContaining('full access to edit'), findsOneWidget);
  });

  testWidgets('OnboardingCoOwnerWelcomeScreen shows crown welcome',
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
                invitedRole: UserRole.owner,
              ),
            ),
          ),
          onboardingCoordinatorProvider.overrideWith(
            OnboardingCoordinatorNotifier.new,
          ),
        ],
        child: const MaterialApp(
          home: OnboardingThemeScope(child: OnboardingCoOwnerWelcomeScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("You're officially an Owner!"), findsOneWidget);
    expect(find.text('Go to Home'), findsOneWidget);
  });
}
