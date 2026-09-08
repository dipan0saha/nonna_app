import 'package:nonna_app/core/config/app_config.dart';
import 'package:nonna_app/core/enums/user_role.dart';

/// Canonical invitation deep-link builder (Phase 0b).
class InvitationLinkHelpers {
  InvitationLinkHelpers._();

  /// Builds `nonna://app/invite-accept?token=...` with optional co-owner hint.
  static String buildInviteAcceptUrl(
    String token, {
    UserRole invitedRole = UserRole.follower,
  }) {
    final trimmed = token.trim();
    final roleParam = invitedRole == UserRole.owner ? '&role=owner' : '';
    return AppConfig.getDeepLinkUrl('/invite-accept?token=$trimmed$roleParam');
  }
}
