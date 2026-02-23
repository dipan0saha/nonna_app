import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/enums/invitation_status.dart';
import 'package:nonna_app/core/models/invitation.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/invites_status/widgets/invites_status_tile.dart';

Invitation _makeInvitation({
  String id = 'i1',
  String email = 'alice@example.com',
  InvitationStatus status = InvitationStatus.pending,
}) {
  final now = DateTime.now();
  return Invitation(
    id: id,
    babyProfileId: 'bp1',
    invitedByUserId: 'u1',
    inviteeEmail: email,
    tokenHash: 'hash_$id',
    expiresAt: now.add(const Duration(days: 7)),
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _buildWidget({
  List<Invitation> invitations = const [],
  int pendingCount = 0,
  bool isLoading = false,
  String? error,
  void Function(Invitation)? onResend,
  void Function(Invitation)? onRevoke,
  VoidCallback? onRefresh,
  VoidCallback? onViewAll,
}) {
  return MaterialApp(
    home: Scaffold(
      body: InvitesStatusTile(
        invitations: invitations,
        pendingCount: pendingCount,
        isLoading: isLoading,
        error: error,
        onResend: onResend,
        onRevoke: onRevoke,
        onRefresh: onRefresh,
        onViewAll: onViewAll,
      ),
    ),
  );
}

void main() {
  group('InvitesStatusTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('invites_status_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Fetch failed'));
      expect(find.text('Fetch failed'), findsOneWidget);
    });

    testWidgets('shows empty state when invitations list is empty',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('No invitations sent'), findsOneWidget);
    });

    testWidgets('shows invitations when provided', (tester) async {
      final invitations = [
        _makeInvitation(id: 'i1', email: 'a@b.com'),
        _makeInvitation(id: 'i2', email: 'c@d.com'),
      ];
      await tester.pumpWidget(_buildWidget(invitations: invitations));
      expect(find.byKey(const Key('invitation_item_i1')), findsOneWidget);
      expect(find.byKey(const Key('invitation_item_i2')), findsOneWidget);
    });

    testWidgets('shows at most 5 invitations', (tester) async {
      final invitations = List.generate(
          7, (i) => _makeInvitation(id: 'i$i', email: 'u$i@x.com'));
      await tester.pumpWidget(_buildWidget(invitations: invitations));
      int count = 0;
      for (int i = 0; i < 5; i++) {
        if (tester.any(find.byKey(Key('invitation_item_i$i')))) count++;
      }
      expect(count, 5);
      expect(find.byKey(const Key('invitation_item_i5')), findsNothing);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Invite Status'), findsOneWidget);
    });

    testWidgets('shows pending count badge when pendingCount > 0',
        (tester) async {
      await tester.pumpWidget(_buildWidget(pendingCount: 4));
      expect(find.byKey(const Key('pending_count_badge')), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('hides pending count badge when pendingCount is 0',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('pending_count_badge')), findsNothing);
    });

    testWidgets('shows status chip for each invitation', (tester) async {
      final inv = _makeInvitation(id: 'i1');
      await tester.pumpWidget(_buildWidget(invitations: [inv]));
      expect(find.byKey(const Key('status_chip_i1')), findsOneWidget);
    });

    testWidgets('shows resend and revoke buttons for pending invitations',
        (tester) async {
      final inv = _makeInvitation(id: 'i1', status: InvitationStatus.pending);
      await tester.pumpWidget(
        _buildWidget(invitations: [inv], onResend: (_) {}, onRevoke: (_) {}),
      );
      expect(find.byKey(const Key('resend_button_i1')), findsOneWidget);
      expect(find.byKey(const Key('revoke_button_i1')), findsOneWidget);
    });

    testWidgets('hides resend/revoke for non-pending invitations',
        (tester) async {
      final inv = _makeInvitation(id: 'i1', status: InvitationStatus.accepted);
      await tester.pumpWidget(
        _buildWidget(invitations: [inv], onResend: (_) {}, onRevoke: (_) {}),
      );
      expect(find.byKey(const Key('resend_button_i1')), findsNothing);
      expect(find.byKey(const Key('revoke_button_i1')), findsNothing);
    });

    testWidgets('resend button calls onResend callback', (tester) async {
      Invitation? resent;
      final inv = _makeInvitation(id: 'i1');
      await tester.pumpWidget(
        _buildWidget(invitations: [inv], onResend: (i) => resent = i),
      );
      await tester.tap(find.byKey(const Key('resend_button_i1')));
      expect(resent, equals(inv));
    });

    testWidgets('revoke button calls onRevoke callback', (tester) async {
      Invitation? revoked;
      final inv = _makeInvitation(id: 'i1');
      await tester.pumpWidget(
        _buildWidget(invitations: [inv], onRevoke: (i) => revoked = i),
      );
      await tester.tap(find.byKey(const Key('revoke_button_i1')));
      expect(revoked, equals(inv));
    });

    testWidgets('shows view all button when onViewAll is provided',
        (tester) async {
      await tester.pumpWidget(_buildWidget(onViewAll: () {}));
      expect(find.byKey(const Key('invites_status_view_all')), findsOneWidget);
    });

    testWidgets('view all button calls onViewAll callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildWidget(onViewAll: () => called = true));
      await tester.tap(find.byKey(const Key('invites_status_view_all')));
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
