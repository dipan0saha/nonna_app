import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../middleware/error_handler.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/supabase_client.dart';

/// Custom exception for database operations that preserves the original error
class DatabaseException implements Exception {
  final String message;
  final Object? originalException;
  final StackTrace? stackTrace;

  DatabaseException(
    this.message, {
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Database service for typed query execution and transaction support
/// 
/// Provides query builder wrapper, pagination helpers, and error mapping
class DatabaseService {
  final SupabaseClient _client = SupabaseClientManager.instance;
  late final AuthInterceptor _authInterceptor;

  DatabaseService() {
    _authInterceptor = AuthInterceptor(_client);
  }

  // ==========================================
  // Query Operations
  // ==========================================

  /// Select data from a table
  /// 
  /// [table] The table name
  /// [columns] Optional columns to select (default: '*')
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select(
    String table, {
    String columns = '*',
  }) {
    return _client.from(table).select(columns);
  }

  /// Insert data into a table
  /// 
  /// [table] The table name
  /// [data] The data to insert
  Future<List<Map<String, dynamic>>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        final response = await _client
            .from(table)
            .insert(data)
            .select();
        
        return response;
      } catch (e, stackTrace) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error inserting into $table: $message');
        throw DatabaseException(
          message,
          originalException: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  /// Insert multiple rows into a table
  /// 
  /// [table] The table name
  /// [data] List of data objects to insert
  Future<List<Map<String, dynamic>>> insertMany(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        final response = await _client
            .from(table)
            .insert(data)
            .select();
        
        return response;
      } catch (e, stackTrace) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error inserting multiple rows into $table: $message');
        throw DatabaseException(
          message,
          originalException: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  /// Update data in a table
  /// 
  /// [table] The table name
  /// [data] The data to update
  /// Returns a [PostgrestFilterBuilder] for adding WHERE conditions
  PostgrestFilterBuilder<dynamic> update(
    String table,
    Map<String, dynamic> data,
  ) {
    return _client.from(table).update(data);
  }

  /// Upsert data into a table
  /// 
  /// [table] The table name
  /// [data] The data to upsert
  /// [onConflict] Optional conflict target columns
  Future<List<Map<String, dynamic>>> upsert(
    String table,
    Map<String, dynamic> data, {
    String? onConflict,
  }) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        final query = onConflict != null
            ? _client.from(table).upsert(data, onConflict: onConflict)
            : _client.from(table).upsert(data);
        
        final response = await query.select();
        
        return response;
      } catch (e, stackTrace) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error upserting into $table: $message');
        throw DatabaseException(
          message,
          originalException: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  /// Upsert multiple rows into a table
  /// 
  /// [table] The table name
  /// [data] List of data objects to upsert
  /// [onConflict] Optional conflict target columns
  Future<List<Map<String, dynamic>>> upsertMany(
    String table,
    List<Map<String, dynamic>> data, {
    String? onConflict,
  }) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        final query = onConflict != null
            ? _client.from(table).upsert(data, onConflict: onConflict)
            : _client.from(table).upsert(data);
        
        final response = await query.select();
        
        return response;
      } catch (e, stackTrace) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error upserting multiple rows into $table: $message');
        throw DatabaseException(
          message,
          originalException: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  /// Delete data from a table
  /// 
  /// [table] The table name
  /// Returns a [PostgrestFilterBuilder] for adding WHERE conditions
  PostgrestFilterBuilder<dynamic> delete(String table) {
    return _client.from(table).delete();
  }

  // ==========================================
  // RPC (Remote Procedure Call)
  // ==========================================

  /// Execute a PostgreSQL function
  /// 
  /// [functionName] The name of the function
  /// [params] Optional parameters
  Future<dynamic> rpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        return await _client.rpc(functionName, params: params);
      } catch (e, stackTrace) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error executing RPC $functionName: $message');
        throw DatabaseException(
          message,
          originalException: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  // ==========================================
  // Pagination Helpers
  // ==========================================

  /// Get paginated data from a table
  /// 
  /// [table] The table name
  /// [page] The page number (0-indexed)
  /// [pageSize] Number of items per page
  /// [columns] Optional columns to select
  /// [orderBy] Optional column to order by
  /// [ascending] Sort order (default: true)
  Future<PaginatedResult> getPaginated(
    String table, {
    required int page,
    required int pageSize,
    String columns = '*',
    String? orderBy,
    bool ascending = true,
  }) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        final from = page * pageSize;
        final to = from + pageSize - 1;

        dynamic query = _client.from(table).select(columns);

        if (orderBy != null) {
          query = query.order(orderBy, ascending: ascending);
        }

        final response = await query.range(from, to);
        
        // Get total count for pagination metadata using the count() method
        final totalCount = await _client
            .from(table)
            .count();
        
        return PaginatedResult(
          data: response,
          page: page,
          pageSize: pageSize,
          totalCount: totalCount,
          totalPages: (totalCount / pageSize).ceil(),
        );
      } catch (e, stackTrace) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error getting paginated data from $table: $message');
        throw DatabaseException(
          message,
          originalException: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  // ==========================================
  // Transaction Support (via RPC)
  // ==========================================

  /// Begin a transaction (requires PostgreSQL function)
  /// 
  /// Note: Supabase doesn't support explicit transactions via REST API.
  /// Use PostgreSQL functions for complex transactions.
  Future<void> executeTransaction(
    String transactionFunctionName, {
    Map<String, dynamic>? params,
  }) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        await _client.rpc(transactionFunctionName, params: params);
      } catch (e, stackTrace) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error executing transaction: $message');
        throw DatabaseException(
          message,
          originalException: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  // ==========================================
  // Batch Operations
  // ==========================================

  /// Perform a batch insert with better error handling
  /// 
  /// [table] The table name
  /// [data] List of data objects
  /// [batchSize] Number of items per batch (default: 100)
  Future<void> batchInsert(
    String table,
    List<Map<String, dynamic>> data, {
    int batchSize = 100,
  }) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        for (var i = 0; i < data.length; i += batchSize) {
          final end = (i + batchSize < data.length) ? i + batchSize : data.length;
          final batch = data.sublist(i, end);
          
          await _client.from(table).insert(batch);
          
          debugPrint('✅ Inserted batch ${i ~/ batchSize + 1} (${batch.length} items)');
        }
      } catch (e, stackTrace) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error in batch insert: $message');
        throw DatabaseException(
          message,
          originalException: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  // ==========================================
  // Helper Methods
  // ==========================================

  /// Check if a record exists
  /// 
  /// [table] The table name
  /// [column] The column to check
  /// [value] The value to match
  Future<bool> exists(
    String table, {
    required String column,
    required dynamic value,
  }) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        final response = await _client
            .from(table)
            .select('id')
            .eq(column, value)
            .limit(1);
        
        return (response as List).isNotEmpty;
      } catch (e, stackTrace) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error checking existence in $table: $message');
        throw DatabaseException(
          message,
          originalException: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  /// Count records in a table
  /// 
  /// [table] The table name
  Future<int> count(String table) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        final response = await _client
            .from(table)
            .count();
        
        return response;
      } catch (e, stackTrace) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error counting records in $table: $message');
        throw DatabaseException(
          message,
          originalException: e,
          stackTrace: stackTrace,
        );
      }
    });
  }
}

/// Paginated result data class
class PaginatedResult {
  final List<Map<String, dynamic>> data;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  PaginatedResult({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  /// Check if there is a next page
  bool get hasNextPage => page < totalPages - 1;

  /// Check if there is a previous page
  bool get hasPreviousPage => page > 0;

  /// Get the next page number
  int? get nextPage => hasNextPage ? page + 1 : null;

  /// Get the previous page number
  int? get previousPage => hasPreviousPage ? page - 1 : null;
}
