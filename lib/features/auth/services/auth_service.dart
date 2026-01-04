import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/app_initialization_service.dart';
import '../../analytics/services/analytics_service.dart';

/// Authentication service for managing user authentication
/// Handles email/password, Google OAuth, and Facebook OAuth
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Google Sign-In configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ==========================================
  // Email/Password Authentication
  // ==========================================

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
        data: {
          'display_name': displayName,
        },
      );

      if (response.user != null) {
        await AnalyticsService.logSignUp(signUpMethod: 'email');
      }

      return response;
    } catch (e) {
      debugPrint('Error signing up with email: $e');
      rethrow;
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
        await AnalyticsService.logLogin(loginMethod: 'email');
        await _setUserIdInServices(response.user!.id);
      }

      return response;
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      rethrow;
    }
  }

  /// Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      return await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      debugPrint('Error updating password: $e');
      rethrow;
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      if (currentUser?.email == null) {
        throw Exception('No user email found');
      }
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: currentUser!.email!,
      );
    } catch (e) {
      debugPrint('Error resending verification email: $e');
      rethrow;
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
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

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
        await AnalyticsService.logLogin(loginMethod: 'google');
        await _setUserIdInServices(response.user!.id);
      }

      return response;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
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
        idToken: accessToken.tokenString,
      );

      if (response.user != null) {
        await AnalyticsService.logLogin(loginMethod: 'facebook');
        await _setUserIdInServices(response.user!.id);
      }

      return response;
    } catch (e) {
      debugPrint('Error signing in with Facebook: $e');
      rethrow;
    }
  }

  // ==========================================
  // Sign Out
  // ==========================================

  /// Sign out user
  Future<void> signOut() async {
    try {
      // Clear user ID from all services
      await AppInitializationService.clearUserId();
      
      // Sign out from Supabase
      await _supabase.auth.signOut();
      
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      // Sign out from Facebook if signed in
      await FacebookAuth.instance.logOut();
      
      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // ==========================================
  // Helper Methods
  // ==========================================

  /// Set user ID in all services (Analytics, Crashlytics, OneSignal)
  Future<void> _setUserIdInServices(String userId) async {
    try {
      await AppInitializationService.setUserId(userId);
    } catch (e) {
      debugPrint('Error setting user ID in services: $e');
    }
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
