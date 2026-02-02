import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:nonna_app/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([SupabaseClient, GoTrueClient, RealtimeClient, SupabaseStorageClient])
void main() {
  group('SupabaseService', () {
    late SupabaseService supabaseService;

    setUp(() {
      supabaseService = SupabaseService();
    });

    group('handleError', () {
      test('handles AuthException with 400 status', () {
        final error = AuthException('Invalid request', statusCode: '400');
        final message = supabaseService.handleError(error);
        expect(message, 'Invalid request. Please check your input.');
      });

      test('handles AuthException with 401 status', () {
        final error = AuthException('Unauthorized', statusCode: '401');
        final message = supabaseService.handleError(error);
        expect(message, 'Authentication failed. Please sign in again.');
      });

      test('handles AuthException with 422 status', () {
        final error = AuthException('Invalid credentials', statusCode: '422');
        final message = supabaseService.handleError(error);
        expect(message, 'Invalid credentials. Please check your email and password.');
      });

      test('handles PostgrestException with PGRST301 code', () {
        final error = PostgrestException(
          message: 'Access denied',
          code: 'PGRST301',
        );
        final message = supabaseService.handleError(error);
        expect(message, 'Access denied. You do not have permission to perform this action.');
      });

      test('handles PostgrestException with constraint violation', () {
        final error = PostgrestException(
          message: 'Constraint violation',
          code: '23505',
        );
        final message = supabaseService.handleError(error);
        expect(message, 'Data validation error. Please check your input.');
      });

      test('handles StorageException with 404 status', () {
        final error = StorageException(
          message: 'Not found',
          statusCode: '404',
        );
        final message = supabaseService.handleError(error);
        expect(message, 'File not found.');
      });

      test('handles StorageException with 413 status', () {
        final error = StorageException(
          message: 'File too large',
          statusCode: '413',
        );
        final message = supabaseService.handleError(error);
        expect(message, 'File is too large. Please choose a smaller file.');
      });

      test('handles unknown errors', () {
        final error = Exception('Unknown error');
        final message = supabaseService.handleError(error);
        expect(message, 'An unexpected error occurred. Please try again.');
      });
    });
  });
}
