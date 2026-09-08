import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/utils/invitation_link_helpers.dart';

void main() {
  group('InvitationLinkHelpers', () {
    test('buildInviteAcceptUrl uses canonical deep link scheme', () {
      final url = InvitationLinkHelpers.buildInviteAcceptUrl('token-abc');
      expect(url, 'nonna://app/invite-accept?token=token-abc');
    });

    test('buildInviteAcceptUrl adds role=owner for co-owner invites', () {
      final url = InvitationLinkHelpers.buildInviteAcceptUrl(
        'token-abc',
        invitedRole: UserRole.owner,
      );
      expect(url, 'nonna://app/invite-accept?token=token-abc&role=owner');
    });

    test('buildInviteAcceptUrl trims token', () {
      final url = InvitationLinkHelpers.buildInviteAcceptUrl('  token  ');
      expect(url, 'nonna://app/invite-accept?token=token');
    });
  });
}
