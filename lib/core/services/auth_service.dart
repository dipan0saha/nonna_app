import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../middleware/error_handler.dart';
import 'analytics_service.dart';
import 'app_initialization_service.dart';

/// Authentication service for managing user authentication
/// Handles email/password, Google OAuth, and Facebook OAuth
class AuthService {
  final SupabaseClient _supabase;
  final AnalyticsService _analytics;

  AuthService({
    SupabaseClient? supabase,
    AnalyticsService? analytics,
  })  : _supabase = supabase ?? Supabase.instance.client,
        _analytics = analytics ?? AnalyticsService.instance;

  // Google Sign-In configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '905947106371-7locdmnoebo4fq8959bdbioh3nbib4ac.apps.googleusercontent.com',
    scopes: [
      'email',
      'profile',
    ],
  );

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ==========================================
  // Email/Password Authentication
  // ==========================================

  /// Redirect URL used by Supabase email auth flows for mobile deep-linking.
  String get _authEmailRedirectUrl =>
      AppConfig.getDeepLinkUrl('/auth/callback');

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
        emailRedirectTo: _authEmailRedirectUrl,
      );

      if (response.user != null) {
        await _analytics.logSignUp(signUpMethod: 'email');
      }

      return response;
    } catch (e) {
      final message = ErrorHandler.mapErrorToMessage(e);
      debugPrint('❌ Error signing up with email: $message');
      throw Exception(message);
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _analytics.logLogin(loginMethod: 'email');
        // Set user ID in background, don't block on it
        _setUserIdInServices(response.user!.id);
      }

      return response;
    } catch (e) {
      final message = ErrorHandler.mapErrorToMessage(e);
      debugPrint('❌ Error signing in with email: $message');
      throw Exception(message);
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: _authEmailRedirectUrl,
      );
    } catch (e) {
      final message = ErrorHandler.mapErrorToMessage(e);
      debugPrint('❌ Error sending password reset email: $message');
      throw Exception(message);
    }
  }

  /// Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      return await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      final message = ErrorHandler.mapErrorToMessage(e);
      debugPrint('❌ Error updating password: $message');
      throw Exception(message);
    }
  }

  /// Resend verification email (requires an active session).
  Future<void> resendVerificationEmail() async {
    try {
      if (currentUser?.email == null) {
        throw Exception('No user email found');
      }
      await resendSignupVerificationEmail(currentUser!.email!);
    } catch (e) {
      final message = ErrorHandler.mapErrorToMessage(e);
      debugPrint('❌ Error resending verification email: $message');
      throw Exception(message);
    }
  }

  /// Resend signup verification email without a session (#23).
  Future<void> resendSignupVerificationEmail(String email) async {
    try {
      final trimmed = email.trim();
      if (trimmed.isEmpty) {
        throw Exception('Email is required');
      }
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: trimmed,
        emailRedirectTo: _authEmailRedirectUrl,
      );
    } catch (e) {
      final message = ErrorHandler.mapErrorToMessage(e);
      debugPrint('❌ Error resending signup verification email: $message');
      throw Exception(message);
    }
  }

  // ==========================================
  // OAuth Authentication
  // ==========================================

  /// Sign in with Google
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled sign-in
        return null;
      }

      // Obtain Google Auth credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      // Sign in to Supabase with Google token
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        await _analytics.logLogin(loginMethod: 'google');
        // Set user ID in background, don't block on it
        _setUserIdInServices(response.user!.id);
      }

      return response;
    } catch (e) {
      final message = ErrorHandler.mapErrorToMessage(e);
      debugPrint('❌ Error signing in with Google: $message');
      throw Exception(message);
    }
  }

  /// Sign in with Facebook
  Future<AuthResponse?> signInWithFacebook() async {
    try {
      // Trigger Facebook Sign-In flow
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        // User cancelled or error occurred
        return null;
      }

      // Get Facebook access token
      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) {
        throw Exception('Failed to get Facebook access token');
      }

      // Sign in to Supabase with Facebook token
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.facebook,
        idToken: accessToken.token,
      );

      if (response.user != null) {
        await _analytics.logLogin(loginMethod: 'facebook');
        // Set user ID in background, don't block on it
        _setUserIdInServices(response.user!.id);
      }

      return response;
    } catch (e) {
      final message = ErrorHandler.mapErrorToMessage(e);
      debugPrint('❌ Error signing in with Facebook: $message');
      throw Exception(message);
    }
  }

  // ==========================================
  // Sign Out
  // ==========================================

  /// Sign out user
  Future<void> signOut() async {
    try {
      // Clear user ID from all services before signing out to avoid stale
      // aliases when rapidly switching accounts.
      await AppInitializationService.clearUserId();

      // Sign out from Supabase
      await _supabase.auth.signOut();

      // Sign out from Google if signed in
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // Ignore errors if not signed in
        debugPrint('Google sign out: $e');
      }

      // Sign out from Facebook if signed in
      try {
        await FacebookAuth.instance.logOut();
      } catch (e) {
        // Ignore errors if not signed in or plugin missing
        debugPrint('Facebook sign out: $e');
      }

      debugPrint('✅ User signed out successfully');
    } catch (e) {
      final message = ErrorHandler.mapErrorToMessage(e);
      debugPrint('❌ Error signing out: $message');
      throw Exception(message);
    }
  }

  // ==========================================
  // Helper Methods
  // ==========================================

  /// Set user ID in all services (Analytics, Crashlytics, OneSignal)
  /// This is called in a fire-and-forget manner to avoid blocking authentication
  void _setUserIdInServices(String userId) {
    // Run in background, don't await
    AppInitializationService.setUserId(userId).catchError((e) {
      debugPrint('⚠️  Non-critical: Error setting user ID in services: $e');
      // Don't throw - authentication succeeded, external service sync is best-effort
    });
  }

  /// Check if email is verified
  bool get isEmailVerified {
    return currentUser?.emailConfirmedAt != null;
  }

  /// Get user email
  String? get userEmail => currentUser?.email;

  /// Get user ID
  String? get userId => currentUser?.id;
}
