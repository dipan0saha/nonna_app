import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/models/invitation.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';
import 'package:nonna_app/features/baby_profile/presentation/screens/invite_followers_screen.dart';

class _FakeBabyProfileNotifier extends BabyProfileNotifier {
  _FakeBabyProfileNotifier({this.errorMessage});

  final String? errorMessage;

  @override
  BabyProfileState build() => const BabyProfileState();

  @override
  Future<Invitation> sendInvitation({
    required String babyProfileId,
    required String invitedByUserId,
    required String email,
  }) async {
    if (errorMessage != null) {
      throw Exception(errorMessage);
    }

    final now = DateTime.now();
    return Invitation(
      id: 'inv-1',
      babyProfileId: babyProfileId,
      invitedByUserId: invitedByUserId,
      inviteeEmail: email.toLowerCase(),
      tokenHash: 'token-1',
      expiresAt: now.add(const Duration(days: 7)),
      createdAt: now,
      updatedAt: now,
    );
  }
}

Widget _buildScreen({
  VoidCallback? onInviteSent,
  VoidCallback? onDone,
  String? sendError,
}) {
  return ProviderScope(
    overrides: [
      babyProfileProvider.overrideWith(
        () => _FakeBabyProfileNotifier(errorMessage: sendError),
      ),
    ],
    child: MaterialApp(
      home: InviteFollowersScreen(
        babyProfileId: 'baby-1',
        invitedByUserId: 'user-1',
        onInviteSent: onInviteSent,
        onDone: onDone,
      ),
    ),
  );
}

void main() {
  group('InviteFollowersScreen', () {
    testWidgets("renders Scaffold with key 'invite_followers_screen'",
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(find.byKey(const Key('invite_followers_screen')), findsOneWidget);
    });

    testWidgets('shows app bar title "Invite Followers"', (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(find.text('Invite Followers'), findsOneWidget);
    });

    testWidgets('renders email text field', (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(find.byKey(const Key('invite_email_field')), findsOneWidget);
    });

    testWidgets('renders send invite button', (tester) async {
      await tester.pumpWidget(_buildScreen());
      expect(find.byKey(const Key('send_invite_button')), findsOneWidget);
    });

    testWidgets('shows validation error for empty email', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.tap(find.byKey(const Key('send_invite_button')));
      await tester.pump();
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.enterText(
          find.byKey(const Key('invite_email_field')), 'notanemail');
      await tester.tap(find.byKey(const Key('send_invite_button')));
      await tester.pump();
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows success message after valid invite', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.enterText(
          find.byKey(const Key('invite_email_field')), 'test@example.com');
      await tester.tap(find.byKey(const Key('send_invite_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('invite_success_message')), findsOneWidget);
    });

    testWidgets('calls onInviteSent callback after successful invite',
        (tester) async {
      var called = false;
      await tester.pumpWidget(_buildScreen(onInviteSent: () => called = true));
      await tester.enterText(
          find.byKey(const Key('invite_email_field')), 'test@example.com');
      await tester.tap(find.byKey(const Key('send_invite_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(called, isTrue);
    });

    testWidgets('shows error message when invitation send fails',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(sendError: 'Unable to send invitation email right now'),
      );
      await tester.enterText(
          find.byKey(const Key('invite_email_field')), 'test@example.com');
      await tester.tap(find.byKey(const Key('send_invite_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('invite_error_message')), findsOneWidget);
      expect(find.text('Unable to send invitation email right now'),
          findsOneWidget);
    });
  });
}
