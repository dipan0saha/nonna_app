import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_auth_helpers.dart';

void main() {
  group('onboardingEmailDisplayNamePlaceholder', () {
    test('uses email local part', () {
      expect(
        onboardingEmailDisplayNamePlaceholder('sarah.parker@example.com'),
        'sarah.parker',
      );
    });

    test('falls back for empty local part', () {
      expect(onboardingEmailDisplayNamePlaceholder('@example.com'), 'User');
    });
  });

  group('onboardingPathFromRoute', () {
    test('parses path query param', () {
      expect(
        onboardingPathFromRoute(Uri.parse('/onboarding/signup?path=follower')),
        OnboardingPath.follower,
      );
      expect(
        onboardingPathFromRoute(Uri.parse('/onboarding/signup?path=coOwner')),
        OnboardingPath.coOwner,
      );
    });

    test('defaults to owner', () {
      expect(
        onboardingPathFromRoute(Uri.parse('/onboarding/signup')),
        OnboardingPath.owner,
      );
    });
  });

  group('onboardingSignupBackRoute', () {
    test('returns invite routes for follower and co-owner', () {
      expect(
        onboardingSignupBackRoute(OnboardingPath.follower),
        '/onboarding/follower/invite',
      );
      expect(
        onboardingSignupBackRoute(OnboardingPath.coOwner),
        '/onboarding/coowner/invite',
      );
    });
  });

  group('onboardingDisplayNameFromMetadata', () {
    test('prefers full_name then name', () {
      expect(
        onboardingDisplayNameFromMetadata(
            {'name': 'Bob', 'full_name': 'Alice'}),
        'Alice',
      );
      expect(
        onboardingDisplayNameFromMetadata({'name': 'Bob'}),
        'Bob',
      );
    });
  });

  group('onboardingAvatarUrlFromMetadata', () {
    test('reads avatar_url and picture', () {
      expect(
        onboardingAvatarUrlFromMetadata(
            {'picture': 'https://example.com/p.jpg'}),
        'https://example.com/p.jpg',
      );
      expect(
        onboardingAvatarUrlFromMetadata(
            {'avatar_url': 'https://example.com/a.jpg'}),
        'https://example.com/a.jpg',
      );
    });
  });

  group('validateDisplayName', () {
    test('rejects empty and long names', () {
      expect(validateDisplayName(''), isNotNull);
      expect(validateDisplayName('a' * 101), isNotNull);
      expect(validateDisplayName('Sarah'), isNull);
    });
  });
}
