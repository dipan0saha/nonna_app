import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/router/app_router.dart';
import 'package:nonna_app/core/services/deep_link_service.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';

void main() {
  group('DeepLinkService.normalizeToRoute', () {
    test('canonical nonna://app/invite-accept', () {
      final route = DeepLinkService.normalizeToRoute(
        Uri.parse('nonna://app/invite-accept?token=abc'),
      );
      expect(route, '${AppRoutes.inviteAccept}?token=abc');
    });

    test('legacy nonna://invite-accept', () {
      final route = DeepLinkService.normalizeToRoute(
        Uri.parse('nonna://invite-accept?token=abc'),
      );
      expect(route, '${AppRoutes.inviteAccept}?token=abc');
    });

    test('https nonna.app/invite?token=', () {
      final route = DeepLinkService.normalizeToRoute(
        Uri.parse('https://nonna.app/invite?token=abc'),
      );
      expect(route, '${AppRoutes.inviteAccept}?token=abc');
    });

    test('https nonna.app/invite/{code} legacy path', () {
      final route = DeepLinkService.normalizeToRoute(
        Uri.parse('https://nonna.app/invite/ABC123'),
      );
      expect(route, '${AppRoutes.inviteAccept}?token=ABC123');
    });

    test('auth callback returns null (handled separately)', () {
      final route = DeepLinkService.normalizeToRoute(
        Uri.parse('nonna://app/auth/callback?code=xyz'),
      );
      expect(route, isNull);
    });
  });

  group('DeepLinkService auth callback parsing', () {
    test('detects PKCE code query param', () {
      expect(
        DeepLinkService.isPkceAuthCallback(
          Uri.parse('nonna://app/auth/callback?code=abc'),
        ),
        isTrue,
      );
    });

    test('extracts refresh token from hash fragment', () {
      final uri = Uri.parse(
        'nonna://app/auth/callback#access_token=at&refresh_token=rt&expires_in=3600',
      );
      expect(DeepLinkService.isPkceAuthCallback(uri), isFalse);
      expect(DeepLinkService.refreshTokenFromAuthCallback(uri), 'rt');
    });
  });

  group('OnboardingRoutes.isPublicPath', () {
    test('treats invite-accept with query as public', () {
      expect(
        OnboardingRoutes.isPublicPath(
          '${AppRoutes.inviteAccept}?token=abc',
        ),
        isTrue,
      );
    });
  });
}
