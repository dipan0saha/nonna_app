import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/services/data_deletion_handler.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([
  DatabaseService,
  StorageService,
  SupabaseClient,
  PostgrestFilterBuilder,
  PostgrestBuilder
])
import 'data_deletion_handler_test.mocks.dart';

void main() {
  group('DataDeletionHandler', () {
    late DataDeletionHandler dataDeletionHandler;
    late MockDatabaseService mockDatabaseService;
    late MockStorageService mockStorageService;
    late MockSupabaseClient mockSupabaseClient;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockStorageService = MockStorageService();
      mockSupabaseClient = MockSupabaseClient();

      dataDeletionHandler = DataDeletionHandler(
        databaseService: mockDatabaseService,
        storageService: mockStorageService,
        supabase: mockSupabaseClient,
      );
    });

    group('requestDeletionConfirmation', () {
      test('generates confirmation token', () async {
        final userId = 'test-user-id';

        final token =
            await dataDeletionHandler.requestDeletionConfirmation(userId);

        expect(token, isNotEmpty);
        expect(token, startsWith('confirmation_'));
      });
    });

    group('deleteUserAccount', () {
      test('returns false when database operations fail', () async {
        final userId = 'test-user-id';

        when(mockDatabaseService.select('photos',
                columns: 'id, storage_path, thumbnail_path'))
            .thenThrow(Exception('Database error'));

        final result = await dataDeletionHandler.deleteUserAccount(userId);

        expect(result, false);
      });

      test('returns false when confirmation token verification fails',
          () async {
        final userId = 'test-user-id';
        final token = 'invalid-token';

        // Token verification is not implemented and returns false
        final result = await dataDeletionHandler.deleteUserAccount(
          userId,
          confirmationToken: token,
        );

        // Should return false due to token verification failure
        expect(result, false);
      });
    });
  });
}
