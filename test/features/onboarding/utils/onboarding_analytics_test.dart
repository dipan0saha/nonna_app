import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/services/analytics_service.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_analytics.dart';

import '../../../mocks/supabase_mocks.mocks.dart';

void main() {
  group('OnboardingAnalytics', () {
    late MockFirebaseAnalytics mockAnalytics;
    late ProviderContainer container;

    setUp(() {
      mockAnalytics = MockFirebaseAnalytics();
      final analytics = AnalyticsService(mockAnalytics);
      analytics.enable();

      container = ProviderContainer(
        overrides: [
          analyticsServiceProvider.overrideWithValue(analytics),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('tracks onboarding funnel events', () async {
      final onboarding = container.read(onboardingAnalyticsProvider);

      await onboarding.trackStepViewed(
        step: OnboardingStep.carousel,
        path: OnboardingPath.owner,
      );
      await onboarding.trackCompleted(path: OnboardingPath.follower);

      verify(
        mockAnalytics.logEvent(
          name: 'onboarding_step_viewed',
          parameters: {
            'step': 'carousel',
            'path': 'owner',
          },
        ),
      ).called(1);
      verify(
        mockAnalytics.logEvent(
          name: 'onboarding_completed',
          parameters: {'path': 'follower'},
        ),
      ).called(1);
    });
  });
}
