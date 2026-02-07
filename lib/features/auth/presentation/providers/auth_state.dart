import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/user.dart' as app_user;

/// Authentication state model
///
/// **Functional Requirements**: Section 3.5.3 - Feature Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Represents the different states of authentication in the app:
/// - authenticated: User is logged in with valid session
/// - unauthenticated: User is not logged in
/// - loading: Authentication operation in progress
/// - error: Authentication error occurred
///
/// Dependencies: None (pure state model)

enum AuthStatus {
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// Auth state model
class AuthState {
  final AuthStatus status;
  final User? user;
  final Session? session;
  final app_user.User? userModel;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.session,
    this.userModel,
    this.errorMessage,
  });

  /// Initial unauthenticated state
  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null,
        session = null,
        userModel = null,
        errorMessage = null;

  /// Authenticated state
  const AuthState.authenticated({
    required User user,
    required Session session,
    app_user.User? userModel,
  })  : status = AuthStatus.authenticated,
        user = user,
        session = session,
        userModel = userModel,
        errorMessage = null;

  /// Loading state
  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        session = null,
        userModel = null,
        errorMessage = null;

  /// Error state
  const AuthState.error(String message)
      : status = AuthStatus.error,
        user = null,
        session = null,
        userModel = null,
        errorMessage = message;

  /// Copy with method for state updates
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Session? session,
    app_user.User? userModel,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      session: session ?? this.session,
      userModel: userModel ?? this.userModel,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Check if authentication is loading
  bool get isLoading => status == AuthStatus.loading;

  /// Check if there's an error
  bool get hasError => status == AuthStatus.error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthState &&
        other.status == status &&
        other.user?.id == user?.id &&
        other.session?.accessToken == session?.accessToken &&
        other.userModel?.id == userModel?.id &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        user.hashCode ^
        session.hashCode ^
        userModel.hashCode ^
        errorMessage.hashCode;
  }

  @override
  String toString() {
    return 'AuthState(status: $status, userId: ${user?.id}, error: $errorMessage)';
  }
}
