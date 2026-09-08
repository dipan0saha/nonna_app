import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';

/// Maps coordinator steps to GoRouter paths.
class OnboardingRoutes {
  OnboardingRoutes._();

  static const String inviteAccept = '/invite-accept';
  static const String legacyLogin = '/login';
  static const String legacySignup = '/signup';

  static const String ownerCarousel = '/onboarding/owner/carousel';
  static const String signup = '/onboarding/signup';
  static const String login = '/onboarding/login';
  static const String emailVerify = '/onboarding/email-verify';
  static const String completeProfile = '/onboarding/complete-profile';
  static const String ownerCreateBaby = '/onboarding/owner/create-baby';
  static const String ownerFirstMoment = '/onboarding/owner/first-moment';
  static const String ownerInvite = '/onboarding/owner/invite';
  static const String followerInvite = '/onboarding/follower/invite';
  static const String coOwnerInvite = '/onboarding/coowner/invite';
  static const String confirmRelationship =
      '/onboarding/follower/confirm-relationship';
  static const String followerCarousel = '/onboarding/follower/carousel';
  static const String coOwnerWelcome = '/onboarding/coowner/welcome';
  static const String wrongEmail = '/onboarding/wrong-email';

  static const Set<String> all = {
    ownerCarousel,
    signup,
    login,
    emailVerify,
    completeProfile,
    ownerCreateBaby,
    ownerFirstMoment,
    ownerInvite,
    followerInvite,
    coOwnerInvite,
    confirmRelationship,
    followerCarousel,
    coOwnerWelcome,
    wrongEmail,
    inviteAccept,
    legacyLogin,
    legacySignup,
  };

  static bool isOnboardingPath(String location) {
    return location.startsWith('/onboarding');
  }

  static bool isPublicPath(String location) {
    final path = _pathOnly(location);
    return isOnboardingPath(path) ||
        path == inviteAccept ||
        path == legacyLogin ||
        path == legacySignup;
  }

  static String _pathOnly(String location) {
    if (location.isEmpty) return location;
    final uri = Uri.tryParse(location);
    if (uri != null && uri.hasScheme) return uri.path;
    final q = location.indexOf('?');
    return q == -1 ? location : location.substring(0, q);
  }

  static String pathForStep(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.carousel:
        return ownerCarousel;
      case OnboardingStep.signup:
        return signup;
      case OnboardingStep.login:
        return login;
      case OnboardingStep.emailVerify:
        return emailVerify;
      case OnboardingStep.completeProfile:
        return completeProfile;
      case OnboardingStep.createBaby:
        return ownerCreateBaby;
      case OnboardingStep.firstMoment:
        return ownerFirstMoment;
      case OnboardingStep.batchInvite:
        return ownerInvite;
      case OnboardingStep.followerInvite:
        return followerInvite;
      case OnboardingStep.coOwnerInvite:
        return coOwnerInvite;
      case OnboardingStep.confirmRelationship:
        return confirmRelationship;
      case OnboardingStep.followerCarousel:
        return followerCarousel;
      case OnboardingStep.coOwnerWelcome:
        return coOwnerWelcome;
    }
  }

  static OnboardingStep? stepForPath(String location) {
    switch (location) {
      case ownerCarousel:
        return OnboardingStep.carousel;
      case signup:
        return OnboardingStep.signup;
      case login:
        return OnboardingStep.login;
      case emailVerify:
        return OnboardingStep.emailVerify;
      case completeProfile:
        return OnboardingStep.completeProfile;
      case ownerCreateBaby:
        return OnboardingStep.createBaby;
      case ownerFirstMoment:
        return OnboardingStep.firstMoment;
      case ownerInvite:
        return OnboardingStep.batchInvite;
      case followerInvite:
        return OnboardingStep.followerInvite;
      case coOwnerInvite:
        return OnboardingStep.coOwnerInvite;
      case confirmRelationship:
        return OnboardingStep.confirmRelationship;
      case followerCarousel:
        return OnboardingStep.followerCarousel;
      case coOwnerWelcome:
        return OnboardingStep.coOwnerWelcome;
      default:
        return null;
    }
  }

  static String signupPathFor(OnboardingPath path) {
    return '$signup?path=${path.name}';
  }

  static OnboardingStep initialInviteStep(OnboardingPath path) {
    switch (path) {
      case OnboardingPath.follower:
        return OnboardingStep.followerInvite;
      case OnboardingPath.coOwner:
        return OnboardingStep.coOwnerInvite;
      case OnboardingPath.owner:
        return OnboardingStep.carousel;
    }
  }

  /// Path-aware next route after complete-profile (placeholder + Phase 1).
  static String nextRouteAfterCompleteProfile(OnboardingPath path) {
    switch (path) {
      case OnboardingPath.owner:
        return ownerCreateBaby;
      case OnboardingPath.follower:
        return confirmRelationship;
      case OnboardingPath.coOwner:
        return coOwnerWelcome;
    }
  }

  /// Parse invite path from deep-link query (`role=owner` → co-owner).
  static OnboardingPath invitePathFromQuery(Map<String, String> query) {
    final role = query['role']?.toLowerCase();
    if (role == 'owner' || role == 'coowner' || role == 'co-owner') {
      return OnboardingPath.coOwner;
    }
    return OnboardingPath.follower;
  }
}
