import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/features/baby_profile/presentation/screens/invite_followers_screen.dart';

Widget _buildScreen({
  VoidCallback? onInviteSent,
  VoidCallback? onDone,
}) {
  return ProviderScope(
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
  });
}
