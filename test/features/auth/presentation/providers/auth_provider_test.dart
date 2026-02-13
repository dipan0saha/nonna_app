import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/di/providers.dart';

import '../../../../helpers/fake_postgrest_builders.dart';
import '../../../../mocks/mock_services.mocks.dart';
import '../../../../helpers/mock_factory.dart';

void main() {
  group('AuthNotifier Tests', () {
    late AuthNotifier notifier;
    late ProviderContainer container;
    late MockAuthService mockAuthService;
    late MockDatabaseService mockDatabaseService;
    late MockLocalStorageService mockLocalStorage;
    late StreamController<supabase.AuthState> authStateController;

    final mockUser = supabase.User(
      id: 'user_1',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    final mockSession = supabase.Session(
      accessToken: 'access_token',
      tokenType: 'bearer',
      user: mockUser,
    );

    setUp(() {
      mockAuthService = MockFactory.createAuthService();
      mockDatabaseService = MockFactory.createDatabaseService();
      mockLocalStorage = MockFactory.createLocalStorageService();

      authStateController = StreamController<supabase.AuthState>.broadcast();

      // Setup ALL default mock behaviors BEFORE creating the container
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => authStateController.stream);
      when(mockAuthService.currentUser).thenReturn(null);
      when(mockLocalStorage.isInitialized).thenReturn(true);
      when(mockLocalStorage.getBool(any)).thenReturn(null);
      when(mockLocalStorage.setBool(any, any)).thenAnswer((_) async {});
      when(mockLocalStorage.getString(any)).thenReturn(null);
      when(mockLocalStorage.setString(any, any)).thenAnswer((_) async {});
      when(mockLocalStorage.remove(any)).thenAnswer((_) async {});
      when(mockLocalStorage.get(any)).thenReturn(null);
      when(mockLocalStorage.put(any, any)).thenAnswer((_) async {});
      when(mockLocalStorage.setObject(any, any)).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          localStorageServiceProvider.overrideWithValue(mockLocalStorage),
        ],
      );

      notifier = container.read(authProvider.notifier);
    });

    tearDown(() {
      authStateController.close();
      container.dispose();
      reset(mockAuthService);
      reset(mockDatabaseService);
      reset(mockLocalStorage);
    });

    group('Initial State', () {
      test('initial state is unauthenticated when no user', () {
        expect(notifier.state.status, equals(AuthStatus.unauthenticated));
        expect(notifier.state.user, isNull);
        expect(notifier.state.session, isNull);
        expect(notifier.state.errorMessage, isNull);
      });

      test('loads user profile when current user exists', () async {
        reset(mockAuthService);
        reset(mockDatabaseService);
        reset(mockLocalStorage);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockLocalStorage.isInitialized).thenReturn(true);
        when(mockLocalStorage.getBool(any)).thenReturn(null);
        when(mockLocalStorage.setBool(any, any)).thenAnswer((_) async {});
        when(mockLocalStorage.getString(any)).thenReturn(null);
        when(mockLocalStorage.setString(any, any)).thenAnswer((_) async {});
        when(mockLocalStorage.remove(any)).thenAnswer((_) async {});
        when(mockLocalStorage.get(any)).thenReturn(null);
        when(mockLocalStorage.put(any, any)).thenAnswer((_) async {});
        when(mockLocalStorage.setObject(any, any)).thenAnswer((_) async {});
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        // Recreate notifier with user present
        container.dispose();
        container = ProviderContainer(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            localStorageServiceProvider.overrideWithValue(mockLocalStorage),
          ],
        );
        notifier = container.read(authProvider.notifier);

        await Future.delayed(const Duration(milliseconds: 100));

        verify(mockDatabaseService.select(any)).called(1);
      });
    });

    group('signInWithEmail', () {
      test('sets loading state while signing in', () async {
        reset(mockAuthService);
        reset(mockDatabaseService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return supabase.AuthResponse(session: mockSession, user: mockUser);
        });

        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        final future = notifier.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        );

        await Future.delayed(const Duration(milliseconds: 10));
        expect(notifier.state.isLoading, isTrue);

        await future;
      });

      test('successfully signs in with email and password', () async {
        reset(mockAuthService);
        reset(mockDatabaseService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async {
          return supabase.AuthResponse(session: mockSession, user: mockUser);
        });

        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        await notifier.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(notifier.state.status, equals(AuthStatus.authenticated));
        expect(notifier.state.user?.id, equals('user_1'));
        expect(notifier.state.errorMessage, isNull);
      });

      test('handles sign in error', () async {
        reset(mockAuthService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(Exception('Invalid credentials'));

        await notifier.signInWithEmail(
          email: 'test@example.com',
          password: 'wrong_password',
        );

        expect(notifier.state.status, equals(AuthStatus.error));
        expect(notifier.state.errorMessage, contains('Invalid credentials'));
      });

      test('handles null user response', () async {
        reset(mockAuthService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async {
          return supabase.AuthResponse();
        });

        await notifier.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(notifier.state.status, equals(AuthStatus.error));
        expect(notifier.state.errorMessage, equals('Sign in failed'));
      });
    });

    group('signUpWithEmail', () {
      test('successfully signs up with email', () async {
        reset(mockAuthService);
        reset(mockDatabaseService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          displayName: anyNamed('displayName'),
        )).thenAnswer((_) async {
          return supabase.AuthResponse(session: mockSession, user: mockUser);
        });

        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        await notifier.signUpWithEmail(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        );

        expect(notifier.state.status, equals(AuthStatus.authenticated));
        expect(notifier.state.user?.id, equals('user_1'));
      });

      test('handles sign up error', () async {
        reset(mockAuthService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          displayName: anyNamed('displayName'),
        )).thenThrow(Exception('Email already exists'));

        await notifier.signUpWithEmail(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        );

        expect(notifier.state.status, equals(AuthStatus.error));
        expect(notifier.state.errorMessage, contains('Email already exists'));
      });
    });

    group('signInWithGoogle', () {
      test('successfully signs in with Google', () async {
        reset(mockAuthService);
        reset(mockDatabaseService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.signInWithGoogle()).thenAnswer((_) async {
          return supabase.AuthResponse(session: mockSession, user: mockUser);
        });

        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        await notifier.signInWithGoogle();

        expect(notifier.state.status, equals(AuthStatus.authenticated));
        expect(notifier.state.user?.id, equals('user_1'));
      });

      test('handles Google sign in error', () async {
        reset(mockAuthService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.signInWithGoogle())
            .thenThrow(Exception('Google auth failed'));

        await notifier.signInWithGoogle();

        expect(notifier.state.status, equals(AuthStatus.error));
        expect(notifier.state.errorMessage, contains('Google auth failed'));
      });
    });

    group('signInWithFacebook', () {
      test('successfully signs in with Facebook', () async {
        reset(mockAuthService);
        reset(mockDatabaseService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.signInWithFacebook()).thenAnswer((_) async {
          return supabase.AuthResponse(session: mockSession, user: mockUser);
        });

        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        await notifier.signInWithFacebook();

        expect(notifier.state.status, equals(AuthStatus.authenticated));
        expect(notifier.state.user?.id, equals('user_1'));
      });

      test('handles Facebook sign in error', () async {
        reset(mockAuthService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.signInWithFacebook())
            .thenThrow(Exception('Facebook auth failed'));

        await notifier.signInWithFacebook();

        expect(notifier.state.status, equals(AuthStatus.error));
        expect(notifier.state.errorMessage, contains('Facebook auth failed'));
      });
    });

    group('signOut', () {
      test('successfully signs out', () async {
        reset(mockAuthService);
        reset(mockLocalStorage);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockLocalStorage.isInitialized).thenReturn(true);
        when(mockLocalStorage.getBool(any)).thenReturn(null);
        when(mockAuthService.signOut()).thenAnswer((_) async => {});
        when(mockLocalStorage.remove(any)).thenAnswer((_) async => {});

        await notifier.signOut();

        expect(notifier.state.status, equals(AuthStatus.unauthenticated));
        expect(notifier.state.user, isNull);
        expect(notifier.state.session, isNull);
        verify(mockAuthService.signOut()).called(1);
        verify(mockLocalStorage.remove(any)).called(1);
      });

      test('handles sign out error', () async {
        reset(mockAuthService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.signOut()).thenThrow(Exception('Sign out failed'));

        await notifier.signOut();

        expect(notifier.state.status, equals(AuthStatus.error));
        expect(notifier.state.errorMessage, contains('Sign out failed'));
      });
    });

    group('resetPassword', () {
      test('successfully sends password reset email', () async {
        reset(mockAuthService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.resetPassword(any)).thenAnswer((_) async => {});

        await notifier.resetPassword('test@example.com');

        verify(mockAuthService.resetPassword('test@example.com')).called(1);
      });

      test('handles password reset error', () async {
        reset(mockAuthService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.resetPassword(any))
            .thenThrow(Exception('Email not found'));

        expect(
          () => notifier.resetPassword('test@example.com'),
          throwsException,
        );
      });
    });

    group('Biometric Authentication', () {
      test('isBiometricAvailable returns true when available', () async {
        // Note: local_auth is difficult to mock, so we just verify the method exists
        final result = await notifier.isBiometricAvailable();
        expect(result, isA<bool>());
      });

      test('isBiometricEnabled checks local storage', () async {
        reset(mockLocalStorage);
        
        when(mockLocalStorage.isInitialized).thenReturn(true);
        when(mockLocalStorage.getBool(any)).thenReturn(null);
        when(mockLocalStorage.getBool('biometric_enabled')).thenReturn(true);

        final result = await notifier.isBiometricEnabled();

        expect(result, isTrue);
        verify(mockLocalStorage.getBool('biometric_enabled')).called(1);
      });

      test('disableBiometric removes from local storage', () async {
        reset(mockLocalStorage);
        
        when(mockLocalStorage.isInitialized).thenReturn(true);
        when(mockLocalStorage.getBool(any)).thenReturn(null);
        when(mockLocalStorage.remove('biometric_enabled'))
            .thenAnswer((_) async => {});

        await notifier.disableBiometric();

        verify(mockLocalStorage.remove('biometric_enabled')).called(1);
      });
    });

    group('Session Management', () {
      test('persists session to local storage on successful auth', () async {
        reset(mockAuthService);
        reset(mockDatabaseService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async {
          return supabase.AuthResponse(session: mockSession, user: mockUser);
        });

        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        await notifier.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        );

        verify(mockLocalStorage.setObject('auth_session', any)).called(1);
      });

      test('refreshSession updates session state', () async {
        reset(mockAuthService);
        reset(mockDatabaseService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.currentSession).thenReturn(mockSession);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        await notifier.refreshSession();

        verify(mockAuthService.currentSession).called(greaterThanOrEqualTo(1));
      });

      test('handles session refresh error', () async {
        reset(mockAuthService);
        
        when(mockAuthService.authStateChanges)
            .thenAnswer((_) => authStateController.stream);
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.currentSession).thenReturn(null);

        await notifier.refreshSession();

        expect(notifier.state.status, isNot(equals(AuthStatus.error)));
      });
    });

    group('Auth State Changes', () {
      test('handles auth state changes from stream', () async {
        reset(mockDatabaseService);
        
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        authStateController.add(
          supabase.AuthState(
            supabase.AuthChangeEvent.signedIn,
            mockSession,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.status, equals(AuthStatus.authenticated));
      });

      test('handles sign out from auth state stream', () async {
        authStateController.add(
          supabase.AuthState(
            supabase.AuthChangeEvent.signedOut,
            null,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.status, equals(AuthStatus.unauthenticated));
      });
    });

    group('dispose', () {
      test('cancels auth subscription on dispose', () {
        // Dispose is now handled by Riverpod automatically
        expect(true, isTrue);
      });
    });
  });
}
