import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nonna_app/core/models/user.dart' as app_user;

void main() {
  group('AuthState Tests', () {
    group('AuthStatus Enum', () {
      test('has correct values', () {
        expect(AuthStatus.values, hasLength(4));
        expect(AuthStatus.values, contains(AuthStatus.authenticated));
        expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
        expect(AuthStatus.values, contains(AuthStatus.loading));
        expect(AuthStatus.values, contains(AuthStatus.error));
      });
    });

    group('AuthState Constructors', () {
      test('default constructor creates state correctly', () {
        final state = AuthState(
          status: AuthStatus.authenticated,
          user: null,
          session: null,
          userModel: null,
          errorMessage: null,
        );

        expect(state.status, equals(AuthStatus.authenticated));
        expect(state.user, isNull);
        expect(state.session, isNull);
        expect(state.userModel, isNull);
        expect(state.errorMessage, isNull);
      });

      test('unauthenticated constructor creates correct state', () {
        const state = AuthState.unauthenticated();

        expect(state.status, equals(AuthStatus.unauthenticated));
        expect(state.user, isNull);
        expect(state.session, isNull);
        expect(state.userModel, isNull);
        expect(state.errorMessage, isNull);
      });

      test('loading constructor creates correct state', () {
        const state = AuthState.loading();

        expect(state.status, equals(AuthStatus.loading));
        expect(state.user, isNull);
        expect(state.session, isNull);
        expect(state.userModel, isNull);
        expect(state.errorMessage, isNull);
      });

      test('error constructor creates correct state', () {
        const errorMessage = 'Authentication failed';
        const state = AuthState.error(errorMessage);

        expect(state.status, equals(AuthStatus.error));
        expect(state.user, isNull);
        expect(state.session, isNull);
        expect(state.userModel, isNull);
        expect(state.errorMessage, equals(errorMessage));
      });
    });

    group('AuthState Getters', () {
      test('isAuthenticated returns true when status is authenticated', () {
        const state = AuthState(status: AuthStatus.authenticated);
        expect(state.isAuthenticated, isTrue);
      });

      test('isAuthenticated returns false when status is not authenticated',
          () {
        const state = AuthState.unauthenticated();
        expect(state.isAuthenticated, isFalse);
      });

      test('isLoading returns true when status is loading', () {
        const state = AuthState.loading();
        expect(state.isLoading, isTrue);
      });

      test('isLoading returns false when status is not loading', () {
        const state = AuthState.unauthenticated();
        expect(state.isLoading, isFalse);
      });

      test('hasError returns true when status is error', () {
        const state = AuthState.error('Test error');
        expect(state.hasError, isTrue);
      });

      test('hasError returns false when status is not error', () {
        const state = AuthState.unauthenticated();
        expect(state.hasError, isFalse);
      });
    });

    group('copyWith', () {
      test('copies state with new status', () {
        const original = AuthState.unauthenticated();
        final copied = original.copyWith(status: AuthStatus.loading);

        expect(copied.status, equals(AuthStatus.loading));
        expect(copied.user, equals(original.user));
        expect(copied.session, equals(original.session));
      });

      test('copies state with new error message', () {
        const original = AuthState.unauthenticated();
        const errorMessage = 'New error';
        final copied = original.copyWith(errorMessage: errorMessage);

        expect(copied.status, equals(original.status));
        expect(copied.errorMessage, equals(errorMessage));
      });

      test('copies state without changing when no parameters provided', () {
        const original = AuthState.unauthenticated();
        final copied = original.copyWith();

        expect(copied.status, equals(original.status));
        expect(copied.user, equals(original.user));
        expect(copied.session, equals(original.session));
        expect(copied.errorMessage, equals(original.errorMessage));
      });
    });

    group('Equality and HashCode', () {
      test('two states with same status are equal', () {
        const state1 = AuthState.unauthenticated();
        const state2 = AuthState.unauthenticated();

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('two states with different status are not equal', () {
        const state1 = AuthState.unauthenticated();
        const state2 = AuthState.loading();

        expect(state1, isNot(equals(state2)));
      });

      test('two error states with different messages are not equal', () {
        const state1 = AuthState.error('Error 1');
        const state2 = AuthState.error('Error 2');

        expect(state1, isNot(equals(state2)));
      });
    });

    group('toString', () {
      test('returns readable string representation', () {
        const state = AuthState.unauthenticated();
        final result = state.toString();

        expect(result, contains('AuthState'));
        expect(result, contains('status'));
        expect(result, contains('unauthenticated'));
      });

      test('includes error message in string when present', () {
        const state = AuthState.error('Test error');
        final result = state.toString();

        expect(result, contains('error'));
        expect(result, contains('Test error'));
      });
    });
  });
}
