import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/services/analytics_service.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';

/// Onboarding funnel analytics (#53) — wraps [AnalyticsService] domain events.
class OnboardingAnalytics {
  OnboardingAnalytics(this._ref);

  final Ref _ref;

  AnalyticsService get _analytics => _ref.read(analyticsServiceProvider);

  Future<void> trackStepViewed({
    required OnboardingStep step,
    required OnboardingPath path,
  }) {
    return _analytics.logOnboardingStepViewed(
      step: step.name,
      path: path.name,
    );
  }

  Future<void> trackCompleted({required OnboardingPath path}) {
    return _analytics.logOnboardingCompleted(path: path.name);
  }

  Future<void> trackSignUp({required String method}) {
    return _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> trackBabyProfileCreated({
    required String babyProfileId,
    required bool hasPhoto,
    String? gender,
  }) {
    return _analytics.logBabyProfileCreated(
      babyProfileId: babyProfileId,
      hasPhoto: hasPhoto,
      gender: gender,
    );
  }

  Future<void> trackInvitationSent({
    required String babyProfileId,
    required String relationshipType,
  }) {
    return _analytics.logInvitationSent(
      babyProfileId: babyProfileId,
      relationshipType: relationshipType,
    );
  }

  Future<void> trackInvitationAccepted({required String babyProfileId}) {
    return _analytics.logInvitationAccepted(
      babyProfileId: babyProfileId,
      timeToAcceptHours: 0,
    );
  }
}

final onboardingAnalyticsProvider = Provider<OnboardingAnalytics>(
  OnboardingAnalytics.new,
);
