import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/network/endpoints/auth_endpoints.dart';

void main() {
  group('AuthEndpoints', () {
    group('constants', () {
      test('has correct sign up endpoint', () {
        expect(AuthEndpoints.signUp, '/auth/v1/signup');
      });

      test('has correct sign in endpoint', () {
        expect(AuthEndpoints.signIn, '/auth/v1/token?grant_type=password');
      });

      test('has correct sign out endpoint', () {
        expect(AuthEndpoints.signOut, '/auth/v1/logout');
      });

      test('has correct reset password endpoint', () {
        expect(AuthEndpoints.resetPasswordRequest, '/auth/v1/recover');
      });

      test('has correct update password endpoint', () {
        expect(AuthEndpoints.updatePassword, '/auth/v1/user');
      });

      test('has correct refresh token endpoint', () {
        expect(AuthEndpoints.refreshToken,
            '/auth/v1/token?grant_type=refresh_token');
      });

      test('has correct get current user endpoint', () {
        expect(AuthEndpoints.getCurrentUser, '/auth/v1/user');
      });

      test('has correct magic link endpoint', () {
        expect(AuthEndpoints.magicLink, '/auth/v1/magiclink');
      });
    });

    group('OAuth methods', () {
      test('generates correct Google OAuth URL', () {
        final url = AuthEndpoints.googleOAuth(
            redirectUrl: 'https://example.com/callback');

        expect(url, contains('/auth/v1/authorize'));
        expect(url, contains('provider=google'));
        expect(
            url, contains('redirect_to=https%3A%2F%2Fexample.com%2Fcallback'));
      });

      test('generates correct Facebook OAuth URL', () {
        final url = AuthEndpoints.facebookOAuth(
            redirectUrl: 'https://example.com/callback');

        expect(url, contains('/auth/v1/authorize'));
        expect(url, contains('provider=facebook'));
        expect(
            url, contains('redirect_to=https%3A%2F%2Fexample.com%2Fcallback'));
      });

      test('generates correct Apple OAuth URL', () {
        final url = AuthEndpoints.appleOAuth(
            redirectUrl: 'https://example.com/callback');

        expect(url, contains('/auth/v1/authorize'));
        expect(url, contains('provider=apple'));
        expect(
            url, contains('redirect_to=https%3A%2F%2Fexample.com%2Fcallback'));
      });

      test('generates OAuth URL for custom provider', () {
        final url = AuthEndpoints.getOAuthUrl(
          provider: 'github',
          redirectUrl: 'https://example.com/callback',
        );

        expect(url, contains('/auth/v1/authorize'));
        expect(url, contains('provider=github'));
        expect(
            url, contains('redirect_to=https%3A%2F%2Fexample.com%2Fcallback'));
      });
    });

    group('helper methods', () {
      test('builds query params correctly', () {
        final params = {
          'key1': 'value1',
          'key2': 'value2',
        };

        final queryString = AuthEndpoints.buildQueryParams(params);

        expect(queryString, contains('?'));
        expect(queryString, contains('key1=value1'));
        expect(queryString, contains('key2=value2'));
        expect(queryString, contains('&'));
      });

      test('returns empty string for empty params', () {
        final queryString = AuthEndpoints.buildQueryParams({});

        expect(queryString, isEmpty);
      });

      test('encodes special characters in query params', () {
        final params = {
          'redirect': 'https://example.com/path?param=value',
        };

        final queryString = AuthEndpoints.buildQueryParams(params);

        expect(queryString, contains('redirect='));
        expect(queryString,
            isNot(contains('https://example.com/path?param=value')));
      });

      test('generates correct email confirmation URL', () {
        final url = AuthEndpoints.emailConfirmation(
          token: 'test-token-123',
          type: 'signup',
        );

        expect(url, contains('/auth/v1/verify'));
        expect(url, contains('token=test-token-123'));
        expect(url, contains('type=signup'));
      });

      test('generates correct password recovery URL', () {
        final url = AuthEndpoints.passwordRecovery(token: 'recovery-token-456');

        expect(url, contains('/auth/v1/verify'));
        expect(url, contains('token=recovery-token-456'));
        expect(url, contains('type=recovery'));
      });
    });
  });
}
