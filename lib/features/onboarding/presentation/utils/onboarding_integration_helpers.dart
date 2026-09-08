import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/services/deep_link_service.dart';
import 'package:nonna_app/core/utils/invitation_link_helpers.dart';

/// Route helpers for onboarding integration / deep-link tests (#54).
String onboardingInviteAcceptRouteForToken(String token) {
  final url = InvitationLinkHelpers.buildInviteAcceptUrl(
    token,
    invitedRole: UserRole.follower,
  );
  return DeepLinkService.normalizeToRoute(Uri.parse(url))!;
}
