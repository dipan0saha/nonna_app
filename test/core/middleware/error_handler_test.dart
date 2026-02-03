import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/middleware/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('ErrorHandler', () {
    group('error type constants', () {
      test('has correct error type constants', () {
        expect(ErrorHandler.networkError, 'network_error');
        expect(ErrorHandler.authError, 'auth_error');
        expect(ErrorHandler.validationError, 'validation_error');
        expect(ErrorHandler.serverError, 'server_error');
        expect(ErrorHandler.permissionError, 'permission_error');
        expect(ErrorHandler.notFoundError, 'not_found_error');
        expect(ErrorHandler.unknownError, 'unknown_error');
      });
    });

    group('mapErrorToMessage', () {
      test('handles AuthException with 400 status code', () {
        final error = AuthException('Invalid credentials', statusCode: '400');
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, contains('Invalid'));
      });

      test('handles AuthException with 401 status code', () {
        final error = AuthException('Unauthorized', statusCode: '401');
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, contains('Session expired'));
      });

      test('handles AuthException with 403 status code', () {
        final error = AuthException('Forbidden', statusCode: '403');
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, contains('Access denied'));
      });

      test('handles AuthException with 422 status code', () {
        final error = AuthException('Email already exists', statusCode: '422');
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, anyOf(contains('email'), contains('Invalid data')));
      });

      test('handles AuthException with 429 status code', () {
        final error = AuthException('Too many requests', statusCode: '429');
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, contains('Too many attempts'));
      });

      test('handles PostgrestException with unique constraint violation', () {
        final error = PostgrestException(
          message: 'Unique constraint violation',
          code: '23505',
        );
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, contains('already exists'));
      });

      test('handles PostgrestException with foreign key violation', () {
        final error = PostgrestException(
          message: 'Foreign key violation',
          code: '23503',
        );
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, contains('Related data does not exist'));
      });

      test('handles PostgrestException with not found error', () {
        final error = PostgrestException(
          message: 'No rows found',
          code: 'PGRST116',
        );
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, contains('not found'));
      });

      test('handles PostgrestException with JWT expired', () {
        final error = PostgrestException(
          message: 'JWT expired',
          code: 'PGRST301',
        );
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, contains('Session expired'));
      });

      test('handles PostgrestException with JWT invalid', () {
        final error = PostgrestException(
          message: 'JWT invalid',
          code: 'PGRST302',
        );
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, contains('Invalid session'));
      });

      test('handles StorageException with not found error', () {
        final error = StorageException('File not found');
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, contains('not found'));
      });

      test('handles StorageException with size error', () {
        final error = StorageException('File too large');
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, contains('too large'));
      });

      test('handles FormatException', () {
        final error = FormatException('Invalid email format');
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, anyOf(contains('email'), contains('Invalid')));
      });

      test('handles TypeError', () {
        final error = TypeError();
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, contains('Data format error'));
      });

      test('handles unknown error type', () {
        final error = Exception('Unknown error');
        final message = ErrorHandler.mapErrorToMessage(error);
        
        expect(message, contains('Something went wrong'));
      });
    });

    group('handleError', () {
      test('returns user-friendly message', () {
        final error = Exception('Test error');
        final message = ErrorHandler.handleError(error);
        
        expect(message, isNotEmpty);
        expect(message, isA<String>());
      });

      test('handles error with stack trace', () {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;
        
        expect(
          () => ErrorHandler.handleError(error, stackTrace: stackTrace),
          returnsNormally,
        );
      });
    });

    group('isRetryable', () {
      test('returns true for timeout PostgrestException', () {
        final error = PostgrestException(
          message: 'Request timeout',
          code: 'TIMEOUT',
        );
        
        expect(ErrorHandler.isRetryable(error), true);
      });

      test('returns true for temporary PostgrestException', () {
        final error = PostgrestException(
          message: 'Service temporarily unavailable',
          code: '503',
        );
        
        expect(ErrorHandler.isRetryable(error), true);
      });

      test('returns true for 401 AuthException', () {
        final error = AuthException('Unauthorized', statusCode: '401');
        
        expect(ErrorHandler.isRetryable(error), true);
      });

      test('returns false for non-retryable errors', () {
        final error = FormatException('Invalid format');
        
        expect(ErrorHandler.isRetryable(error), false);
      });
    });

    group('getRetryDelay', () {
      test('returns correct delay for first retry', () {
        final delay = ErrorHandler.getRetryDelay(0);
        
        expect(delay.inMilliseconds, 500);
      });

      test('returns correct delay for second retry', () {
        final delay = ErrorHandler.getRetryDelay(1);
        
        expect(delay.inMilliseconds, 1000);
      });

      test('returns correct delay for third retry', () {
        final delay = ErrorHandler.getRetryDelay(2);
        
        expect(delay.inMilliseconds, 2000);
      });

      test('uses exponential backoff', () {
        final delay0 = ErrorHandler.getRetryDelay(0);
        final delay1 = ErrorHandler.getRetryDelay(1);
        final delay2 = ErrorHandler.getRetryDelay(2);
        
        expect(delay1.inMilliseconds, delay0.inMilliseconds * 2);
        expect(delay2.inMilliseconds, delay1.inMilliseconds * 2);
      });
    });

    group('classifyError', () {
      test('classifies AuthException as authError', () {
        final error = AuthException('Test');
        final classification = ErrorHandler.classifyError(error);
        
        expect(classification, ErrorHandler.authError);
      });

      test('classifies JWT PostgrestException as authError', () {
        final error = PostgrestException(
          message: 'JWT expired',
          code: 'PGRST301',
        );
        final classification = ErrorHandler.classifyError(error);
        
        expect(classification, ErrorHandler.authError);
      });

      test('classifies not found PostgrestException as notFoundError', () {
        final error = PostgrestException(
          message: 'No rows',
          code: 'PGRST116',
        );
        final classification = ErrorHandler.classifyError(error);
        
        expect(classification, ErrorHandler.notFoundError);
      });

      test('classifies permission PostgrestException as permissionError', () {
        final error = PostgrestException(
          message: 'Permission denied',
          code: 'PERM',
        );
        final classification = ErrorHandler.classifyError(error);
        
        expect(classification, ErrorHandler.permissionError);
      });

      test('classifies FormatException as validationError', () {
        final error = FormatException('Invalid');
        final classification = ErrorHandler.classifyError(error);
        
        expect(classification, ErrorHandler.validationError);
      });

      test('classifies StorageException as serverError', () {
        final error = StorageException('Storage error');
        final classification = ErrorHandler.classifyError(error);
        
        expect(classification, ErrorHandler.serverError);
      });

      test('classifies unknown error as unknownError', () {
        final error = Exception('Unknown');
        final classification = ErrorHandler.classifyError(error);
        
        expect(classification, ErrorHandler.unknownError);
      });
    });

    group('reportWithContext', () {
      test('reports error with context', () {
        final error = Exception('Test error');
        final context = {
          'user_id': 'user-123',
          'operation': 'create_event',
        };
        
        expect(
          () => ErrorHandler.reportWithContext(error, context),
          returnsNormally,
        );
      });

      test('reports error with context and stack trace', () {
        final error = Exception('Test error');
        final context = {'operation': 'test'};
        final stackTrace = StackTrace.current;
        
        expect(
          () => ErrorHandler.reportWithContext(
            error,
            context,
            stackTrace: stackTrace,
          ),
          returnsNormally,
        );
      });
    });
  });
}
