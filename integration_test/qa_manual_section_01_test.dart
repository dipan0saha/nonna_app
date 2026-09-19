import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nonna_app/core/constants/onboarding_integration_keys.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';

import 'test_helper.dart';

/// Manual QA Section 1 — fixed [kReviewPause] between steps (no pumpAndSettle).
const kReviewPause = Duration(seconds: 2);
const _ownerCarouselHeadline = "Your baby's story, in one private place";
const _device = String.fromEnvironment(
  'ANDROID_SERIAL',
  defaultValue: 'emulator-5554',
);

Future<void> reviewPause() => Future<void>.delayed(kReviewPause);

Future<void> pumpReview(WidgetTester tester, {int seconds = 2}) async {
  await tester.pump(Duration(seconds: seconds));
}

String _resolveAdb() {
  final candidates = <String>[];
  final sdk = Platform.environment['ANDROID_HOME'] ??
      Platform.environment['ANDROID_SDK_ROOT'];
  if (sdk != null) {
    candidates.add('$sdk/platform-tools/adb');
  }
  final home = Platform.environment['HOME'];
  if (home != null) {
    candidates.add('$home/Library/Android/sdk/platform-tools/adb');
  }
  for (final path in candidates) {
    if (File(path).existsSync()) return path;
  }
  return 'adb';
}

Future<void> adb(List<String> args) async {
  final result = await Process.run(_resolveAdb(), ['-s', _device, ...args]);
  if (result.exitCode != 0) {
    throw TestFailure('adb ${args.join(' ')} failed: ${result.stderr}');
  }
}

Future<void> setAirplaneMode(bool enabled) async {
  await adb([
    'shell',
    'cmd',
    'connectivity',
    'airplane-mode',
    enabled ? 'enable' : 'disable',
  ]);
}

/// Wait briefly for [finder]; does not loop indefinitely.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  int attempts = 8,
}) async {
  for (var i = 0; i < attempts; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 500));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('QA Manual — Section 1', () {
    testWidgets(
      '1.1–1.5 cold launch, carousel, follower carousel, offline',
      (WidgetTester tester) async {
        // Run `adb shell pm clear com.la_nonna.nonna_app` in your shell before this test.

        await startApp(tester);
        await pumpReview(tester);

        expect(find.text(_ownerCarouselHeadline), findsOneWidget);
        expect(
          find.byKey(OnboardingIntegrationKeys.ownerCarouselPrimary),
          findsOneWidget,
        );
        await reviewPause();

        await tester
            .tap(find.byKey(OnboardingIntegrationKeys.ownerCarouselPrimary));
        await pumpReview(tester);

        await tester
            .tap(find.byKey(OnboardingIntegrationKeys.ownerCarouselPrimary));
        await pumpReview(tester);

        await tester.tap(find.text('Skip'));
        await pumpReview(tester);
        expect(find.text('Create Account'), findsOneWidget);
        await reviewPause();

        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await pumpReview(tester);
        // Back from signup returns to owner carousel (may be last slide, not slide 1).
        expect(
          find.byKey(OnboardingIntegrationKeys.ownerCarouselPrimary),
          findsOneWidget,
        );
        await reviewPause();

        final container = integrationProviderContainer(tester);
        if (container == null) {
          throw TestFailure(
              'Could not read ProviderContainer for follower carousel');
        }
        await container
            .read(onboardingCoordinatorProvider.notifier)
            .setPath(OnboardingPath.follower);
        await container
            .read(onboardingCoordinatorProvider.notifier)
            .goToStep(OnboardingStep.followerCarousel);
        await container
            .read(onboardingCoordinatorProvider.notifier)
            .setCarouselIndex(0);
        appRouter.go(OnboardingRoutes.followerCarousel);
        await pumpReview(tester, seconds: 3);
        await waitFor(tester, find.text("Welcome, you're in!"));
        expect(find.text("Welcome, you're in!"), findsOneWidget);
        await reviewPause();

        await tester.tap(find.text('Next'));
        await pumpReview(tester);
        expect(find.textContaining('Squish photos'), findsOneWidget);
        await reviewPause();

        await setAirplaneMode(true);
        await pumpReview(tester, seconds: 3);
        await waitFor(tester, find.text('No internet connection'));
        expect(find.text('No internet connection'), findsOneWidget);
        await reviewPause();

        await setAirplaneMode(false);
        await pumpReview(tester, seconds: 4);
        expect(find.text('No internet connection'), findsNothing);
      },
      timeout: const Timeout(Duration(minutes: 4)),
    );
  });
}
