/// Auth endpoints for Supabase authentication operations
///
/// **Functional Requirements**: Section 3.2.6 - Endpoint Definitions
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Supabase Auth API endpoints
/// - OAuth provider URLs
/// - Password reset URLs
/// - Email verification endpoints
///
/// Dependencies: None
class AuthEndpoints {
  // Prevent instantiation
  AuthEndpoints._();

  // ============================================================
  // Auth Base Paths
  // ============================================================

  /// Base path for auth operations
  static const String _authBasePath = '/auth/v1';

  // ============================================================
  // Sign Up & Sign In
  // ============================================================

  /// Sign up with email and password
  static const String signUp = '$_authBasePath/signup';

  /// Sign in with email and password
  static const String signIn = '$_authBasePath/token?grant_type=password';

  /// Sign out
  static const String signOut = '$_authBasePath/logout';

  // ============================================================
  // OAuth Providers
  // ============================================================

  /// Base path for OAuth
  static const String _oauthBasePath = '$_authBasePath/authorize';

  /// Sign in with Google
  static String googleOAuth({required String redirectUrl}) {
    return '$_oauthBasePath?provider=google&redirect_to=${Uri.encodeComponent(redirectUrl)}';
  }

  /// Sign in with Facebook
  static String facebookOAuth({required String redirectUrl}) {
    return '$_oauthBasePath?provider=facebook&redirect_to=${Uri.encodeComponent(redirectUrl)}';
  }

  /// Sign in with Apple
  static String appleOAuth({required String redirectUrl}) {
    return '$_oauthBasePath?provider=apple&redirect_to=${Uri.encodeComponent(redirectUrl)}';
  }

  // ============================================================
  // Password Management
  // ============================================================

  /// Request password reset email
  static const String resetPasswordRequest = '$_authBasePath/recover';

  /// Update password
  static const String updatePassword = '$_authBasePath/user';

  // ============================================================
  // Email Verification
  // ============================================================

  /// Resend verification email
  static const String resendVerificationEmail = '$_authBasePath/resend';

  /// Verify email with token
  static const String verifyEmail = '$_authBasePath/verify';

  // ============================================================
  // Session Management
  // ============================================================

  /// Refresh access token
  static const String refreshToken = '$_authBasePath/token?grant_type=refresh_token';

  /// Get current user
  static const String getCurrentUser = '$_authBasePath/user';

  // ============================================================
  // Magic Link
  // ============================================================

  /// Send magic link for passwordless login
  static const String magicLink = '$_authBasePath/magiclink';

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Get OAuth URL for a provider
  ///
  /// [provider] OAuth provider name (google, facebook, apple, etc.)
  /// [redirectUrl] URL to redirect after successful auth
  static String getOAuthUrl({
    required String provider,
    required String redirectUrl,
  }) {
    return '$_oauthBasePath?provider=${Uri.encodeComponent(provider)}&redirect_to=${Uri.encodeComponent(redirectUrl)}';
  }

  /// Build query parameters for auth requests
  ///
  /// [params] Map of query parameters
  static String buildQueryParams(Map<String, String> params) {
    if (params.isEmpty) return '';
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '?$queryString';
  }

  /// Get email confirmation URL
  ///
  /// [token] Email confirmation token
  /// [type] Type of confirmation (signup, invite, recovery, etc.)
  static String emailConfirmation({
    required String token,
    String type = 'signup',
  }) {
    final query = buildQueryParams({
      'token': token,
      'type': type,
    });
    return '$_authBasePath/verify$query';
  }

  /// Get password recovery URL
  ///
  /// [token] Password recovery token
  static String passwordRecovery({required String token}) {
    final query = buildQueryParams({
      'token': token,
      'type': 'recovery',
    });
    return '$_authBasePath/verify$query';
  }
}
