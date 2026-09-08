/// Shared LocalStorage keys for onboarding coordinator state.
abstract class OnboardingStorageKeys {
  static const String path = 'onboarding_path';
  static const String step = 'onboarding_step';
  static const String carouselIndex = 'onboarding_carousel_index';
  static const String pendingInviteToken = 'onboarding_pending_invite_token';
  static const String babyStatus = 'onboarding_baby_status';
  static const String createdBabyProfileId =
      'onboarding_created_baby_profile_id';
  static const String inviteeEmail = 'onboarding_invitee_email';
  static const String usedOAuth = 'onboarding_used_oauth';
  static const String completed = 'onboarding_completed';
  static const String firstRunPendingBabyId = 'first_run_pending_baby_id';

  static String firstRunDismissedKey(String babyProfileId) =>
      'first_run_dismissed_$babyProfileId';

  /// Keys preserved across [LocalStorageService.clearAll].
  static const Set<String> protectedKeys = {
    path,
    step,
    carouselIndex,
    pendingInviteToken,
    babyStatus,
    createdBabyProfileId,
    inviteeEmail,
    usedOAuth,
    completed,
    firstRunPendingBabyId,
  };

  /// Transient coordinator keys cleared by [clearOnboardingCoordinatorState].
  static const Set<String> coordinatorKeys = {
    path,
    step,
    carouselIndex,
    pendingInviteToken,
    babyStatus,
    createdBabyProfileId,
    inviteeEmail,
    usedOAuth,
  };
}
