import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([SupabaseClient, PostgrestFilterBuilder])
import 'database_service_test.mocks.dart';

void main() {
  group('DatabaseService', () {
    late DatabaseService databaseService;

    setUp(() {
      databaseService = DatabaseService();
    });

    group('PaginatedResult', () {
      test('hasNextPage returns true when there are more pages', () {
        final result = PaginatedResult(
          data: [],
          page: 0,
          pageSize: 10,
          totalCount: 30,
          totalPages: 3,
        );

        expect(result.hasNextPage, true);
        expect(result.nextPage, 1);
      });

      test('hasNextPage returns false on last page', () {
        final result = PaginatedResult(
          data: [],
          page: 2,
          pageSize: 10,
          totalCount: 30,
          totalPages: 3,
        );

        expect(result.hasNextPage, false);
        expect(result.nextPage, null);
      });

      test('hasPreviousPage returns true when not on first page', () {
        final result = PaginatedResult(
          data: [],
          page: 1,
          pageSize: 10,
          totalCount: 30,
          totalPages: 3,
        );

        expect(result.hasPreviousPage, true);
        expect(result.previousPage, 0);
      });

      test('hasPreviousPage returns false on first page', () {
        final result = PaginatedResult(
          data: [],
          page: 0,
          pageSize: 10,
          totalCount: 30,
          totalPages: 3,
        );

        expect(result.hasPreviousPage, false);
        expect(result.previousPage, null);
      });

      test('calculates total pages correctly', () {
        final result1 = PaginatedResult(
          data: [],
          page: 0,
          pageSize: 10,
          totalCount: 25,
          totalPages: 3,
        );

        expect(result1.totalPages, 3);

        final result2 = PaginatedResult(
          data: [],
          page: 0,
          pageSize: 10,
          totalCount: 30,
          totalPages: 3,
        );

        expect(result2.totalPages, 3);
      });
    });
  });
}
