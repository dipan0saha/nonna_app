import 'package:flutter/foundation.dart';

/// Integration / widget-test keys for onboarding flows (#54).
abstract class OnboardingIntegrationKeys {
  static const ownerCarouselPrimary = Key('onboarding_owner_carousel_primary');
  static const ownerCarouselSkip = Key('onboarding_owner_carousel_skip');
  static const signupEmail = Key('onboarding_signup_email');
  static const signupPassword = Key('onboarding_signup_password');
  static const signupPrimary = Key('onboarding_signup_primary');
  static const loginEmail = Key('onboarding_login_email');
  static const loginPassword = Key('onboarding_login_password');
  static const completeProfileName = Key('onboarding_complete_profile_name');
  static const createBabyPhoto = Key('onboarding_create_baby_photo');
  static const firstMomentNameInput = Key('onboarding_first_moment_name_input');
  static const batchInvitePrimary = Key('onboarding_batch_invite_primary');
  static const followerInviteAccept = Key('onboarding_follower_invite_accept');
  static const coOwnerInviteAccept = Key('onboarding_coowner_invite_accept');
  static const wrongEmailScreen = Key('onboarding_wrong_email_screen');
}
