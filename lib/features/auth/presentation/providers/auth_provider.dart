import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/models/user.dart' as app_user;
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/local_storage_service.dart';
import 'auth_state.dart';

/// Auth Provider for managing authentication state
///
/// **Functional Requirements**: Section 3.5.3 - Feature Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Authentication state management (user, session)
/// - Login/logout methods
/// - OAuth flow (Google, Facebook)
/// - Biometric authentication
/// - Auto-refresh session
/// - Session persistence
///
/// Dependencies: AuthService, DatabaseService, LocalStorageService

/// Auth Provider Notifier
class AuthNotifier extends Notifier<AuthState> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  StreamSubscription<supabase.AuthState>? _authSubscription;

  @override
  AuthState build() {
    final authService = ref.watch(authServiceProvider);
    final databaseService = ref.watch(databaseServiceProvider);
    final localStorage = ref.watch(localStorageServiceProvider);

    _initialize(authService, databaseService, localStorage);
    
    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return const AuthState.unauthenticated();
  }

  // Configuration
  static const String _sessionKey = 'auth_session';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // ==========================================
  // Initialization
  // ==========================================

  /// Initialize auth state
  void _initialize(
    AuthService authService,
    DatabaseService databaseService,
    LocalStorageService localStorage,
  ) {
    // Listen to auth state changes
    _authSubscription = authService.authStateChanges.listen((authState) {
      _handleAuthStateChange(authState, authService, databaseService, localStorage);
    });

    // Check current auth state
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      _loadUserProfile(currentUser, databaseService, localStorage);
    }
  }

  /// Handle auth state changes
  void _handleAuthStateChange(
    supabase.AuthState authState,
    AuthService authService,
    DatabaseService databaseService,
    LocalStorageService localStorage,
  ) async {
    final user = authState.session?.user;

    if (user != null) {
      await _loadUserProfile(user, databaseService, localStorage);
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  /// Load user profile from database
  Future<void> _loadUserProfile(
    supabase.User user,
    DatabaseService databaseService,
    LocalStorageService localStorage,
  ) async {
    try {
      state = const AuthState.loading();

      // Fetch user model from database
      final response = await databaseService
          .select(SupabaseTables.users)
          .eq(SupabaseTables.id, user.id)
          .maybeSingle();

      app_user.User? userModel;
      if (response != null) {
        userModel = app_user.User.fromJson(response as Map<String, dynamic>);
      }

      final authService = ref.read(authServiceProvider);
      final session = authService.currentUser != null
          ? supabase.Supabase.instance.client.auth.currentSession
          : null;

      state = AuthState.authenticated(
        user: user,
        session: session!,
        userModel: userModel,
      );

      // Persist session
      await _persistSession(session, localStorage);

      debugPrint('✅ User profile loaded: ${user.id}');
    } catch (e) {
      debugPrint('❌ Failed to load user profile: $e');
      state = AuthState.error('Failed to load user profile: $e');
    }
  }

  // ==========================================
  // Authentication Methods
  // ==========================================

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = const AuthState.loading();

      final authService = ref.read(authServiceProvider);
      final databaseService = ref.read(databaseServiceProvider);
      final localStorage = ref.read(localStorageServiceProvider);

      final response = await authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!, databaseService, localStorage);
      } else {
        state = const AuthState.error('Sign in failed');
      }
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      state = AuthState.error(e.toString());
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      state = const AuthState.loading();

      final authService = ref.read(authServiceProvider);
      final databaseService = ref.read(databaseServiceProvider);
      final localStorage = ref.read(localStorageServiceProvider);

      final response = await authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!, databaseService, localStorage);
      } else {
        state = const AuthState.error('Sign up failed');
      }
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      state = AuthState.error(e.toString());
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = const AuthState.loading();

      final authService = ref.read(authServiceProvider);
      final databaseService = ref.read(databaseServiceProvider);
      final localStorage = ref.read(localStorageServiceProvider);

      final response = await authService.signInWithGoogle();

      if (response.user != null) {
        await _loadUserProfile(response.user!, databaseService, localStorage);
      } else {
        state = const AuthState.error('Google sign in failed');
      }
    } catch (e) {
      debugPrint('❌ Google sign in error: $e');
      state = AuthState.error(e.toString());
    }
  }

  /// Sign in with Facebook
  Future<void> signInWithFacebook() async {
    try {
      state = const AuthState.loading();

      final authService = ref.read(authServiceProvider);
      final databaseService = ref.read(databaseServiceProvider);
      final localStorage = ref.read(localStorageServiceProvider);

      final response = await authService.signInWithFacebook();

      if (response.user != null) {
        await _loadUserProfile(response.user!, databaseService, localStorage);
      } else {
        state = const AuthState.error('Facebook sign in failed');
      }
    } catch (e) {
      debugPrint('❌ Facebook sign in error: $e');
      state = AuthState.error(e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      state = const AuthState.loading();

      final authService = ref.read(authServiceProvider);
      final localStorage = ref.read(localStorageServiceProvider);

      await authService.signOut();
      await _clearSession(localStorage);

      state = const AuthState.unauthenticated();
      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      state = AuthState.error(e.toString());
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.resetPassword(email);
      debugPrint('✅ Password reset email sent');
    } catch (e) {
      debugPrint('❌ Password reset error: $e');
      throw Exception(e.toString());
    }
  }

  // ==========================================
  // Biometric Authentication
  // ==========================================

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('❌ Failed to check biometrics: $e');
      return false;
    }
  }

  /// Enable biometric authentication
  Future<bool> enableBiometric() async {
    try {
      final localStorage = ref.read(localStorageServiceProvider);
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        await localStorage.put(_biometricEnabledKey, true);
        debugPrint('✅ Biometric authentication enabled');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Failed to enable biometric: $e');
      return false;
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    final localStorage = ref.read(localStorageServiceProvider);
    await localStorage.remove(_biometricEnabledKey);
    debugPrint('✅ Biometric authentication disabled');
  }

  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    final localStorage = ref.read(localStorageServiceProvider);
    return await localStorage.get(_biometricEnabledKey) ?? false;
  }

  /// Authenticate with biometric
  Future<bool> authenticateWithBiometric() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint('❌ Biometric authentication failed: $e');
      return false;
    }
  }

  // ==========================================
  // Session Management
  // ==========================================

  /// Persist session to local storage
  Future<void> _persistSession(supabase.Session session, LocalStorageService localStorage) async {
    if (!localStorage.isInitialized) return;

    try {
      final sessionData = {
        'access_token': session.accessToken,
        'refresh_token': session.refreshToken,
        'expires_at': session.expiresAt,
        'user_id': session.user.id,
      };

      await localStorage.put(_sessionKey, sessionData);
      debugPrint('✅ Session persisted');
    } catch (e) {
      debugPrint('⚠️  Failed to persist session: $e');
    }
  }

  /// Clear persisted session
  Future<void> _clearSession(LocalStorageService localStorage) async {
    if (!localStorage.isInitialized) return;

    try {
      await localStorage.remove(_sessionKey);
      debugPrint('✅ Session cleared');
    } catch (e) {
      debugPrint('⚠️  Failed to clear session: $e');
    }
  }

  /// Refresh session
  Future<void> refreshSession() async {
    try {
      final authService = ref.read(authServiceProvider);
      final databaseService = ref.read(databaseServiceProvider);
      final localStorage = ref.read(localStorageServiceProvider);
      
      final session = await authService.refreshSession();
      if (session?.user != null) {
        await _loadUserProfile(session!.user, databaseService, localStorage);
      }
      debugPrint('✅ Session refreshed');
    } catch (e) {
      debugPrint('❌ Session refresh error: $e');
      state = AuthState.error(e.toString());
    }
  }
}

/// Auth provider
///
/// Usage:
/// ```dart
/// final authState = ref.watch(authProvider);
/// final notifier = ref.read(authProvider.notifier);
/// await notifier.signInWithEmail(email: 'user@example.com', password: 'password');
/// ```
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Convenience provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// Convenience provider for getting current user
final currentAuthUserProvider = Provider<supabase.User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});
