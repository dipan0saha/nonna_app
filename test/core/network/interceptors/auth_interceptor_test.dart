import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/network/interceptors/auth_interceptor.dart';

import '../../../mocks/mock_services.mocks.dart';
import '../../../helpers/mock_factory.dart';

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late AuthInterceptor authInterceptor;

  setUp(() {
    mockClient = MockFactory.createSupabaseClient();
    mockAuth = MockFactory.createGoTrueClient();
    when(mockClient.auth).thenReturn(mockAuth);
    when(mockClient.headers).thenReturn({'apikey': 'test-api-key'});

    authInterceptor = AuthInterceptor(mockClient);
  });

  group('AuthInterceptor', () {
    group('injectAuthHeaders', () {
      test('returns headers with valid session', () async {
        final mockSession = MockSession();
        when(mockSession.accessToken).thenReturn('test-access-token');
        when(mockAuth.currentSession).thenReturn(mockSession);

        final headers = await authInterceptor.injectAuthHeaders();

        expect(headers['Authorization'], 'Bearer test-access-token');
        expect(headers['apikey'], 'test-api-key');
      });

      test('returns empty map when no session', () async {
        when(mockAuth.currentSession).thenReturn(null);

        final headers = await authInterceptor.injectAuthHeaders();

        expect(headers, isEmpty);
      });
    });

    group('hasValidSession', () {
      test('returns true for valid session', () {
        final mockSession = MockSession();
        final futureTime =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
        when(mockSession.expiresAt).thenReturn(futureTime);
        when(mockAuth.currentSession).thenReturn(mockSession);

        final result = authInterceptor.hasValidSession();

        expect(result, true);
      });

      test('returns false when session is null', () {
        when(mockAuth.currentSession).thenReturn(null);

        final result = authInterceptor.hasValidSession();

        expect(result, false);
      });

      test('returns false when session is expired', () {
        final mockSession = MockSession();
        final pastTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 3600;
        when(mockSession.expiresAt).thenReturn(pastTime);
        when(mockAuth.currentSession).thenReturn(mockSession);

        final result = authInterceptor.hasValidSession();

        expect(result, false);
      });

      test('returns false when expiresAt is null', () {
        final mockSession = MockSession();
        when(mockSession.expiresAt).thenReturn(null);
        when(mockAuth.currentSession).thenReturn(mockSession);

        final result = authInterceptor.hasValidSession();

        expect(result, false);
      });
    });

    group('getAccessToken', () {
      test('returns access token when session exists', () {
        final mockSession = MockSession();
        when(mockSession.accessToken).thenReturn('test-token');
        when(mockAuth.currentSession).thenReturn(mockSession);

        final token = authInterceptor.getAccessToken();

        expect(token, 'test-token');
      });

      test('returns null when no session', () {
        when(mockAuth.currentSession).thenReturn(null);

        final token = authInterceptor.getAccessToken();

        expect(token, null);
      });
    });

    group('getCurrentUserId', () {
      test('returns user ID when session exists', () {
        final mockUser = MockUser();
        when(mockUser.id).thenReturn('test-user-id');
        when(mockAuth.currentUser).thenReturn(mockUser);

        final userId = authInterceptor.getCurrentUserId();

        expect(userId, 'test-user-id');
      });

      test('returns null when no user', () {
        when(mockAuth.currentUser).thenReturn(null);

        final userId = authInterceptor.getCurrentUserId();

        expect(userId, null);
      });
    });

    group('executeWithRetry', () {
      test('executes operation successfully on first try', () async {
        final result = await authInterceptor.executeWithRetry<String>(
          () async => 'success',
        );

        expect(result, 'success');
      });

      test('retries on generic error and succeeds', () async {
        var attempts = 0;
        final result = await authInterceptor.executeWithRetry<String>(
          () async {
            attempts++;
            if (attempts < 2) {
              throw Exception('Temporary error');
            }
            return 'success';
          },
        );

        expect(result, 'success');
        expect(attempts, 2);
      });

      test('throws error after max retries', () async {
        expect(
          () => authInterceptor.executeWithRetry<String>(
            () async => throw Exception('Persistent error'),
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
