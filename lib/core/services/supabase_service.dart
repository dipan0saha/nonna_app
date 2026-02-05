import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';

/// Wrapper service for Supabase operations
///
/// Provides authenticated client management, connection pooling,
/// error handling, and RLS policy enforcement
class SupabaseService {
  /// Get the authenticated Supabase client
  SupabaseClient get client => SupabaseClientManager.instance;

  /// Get the current authenticated user
  User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ==========================================
  // Database Operations
  // ==========================================

  /// Execute a database query
  ///
  /// Returns a [PostgrestFilterBuilder] for building queries
  PostgrestQueryBuilder from(String table) {
    return client.from(table);
  }

  /// Execute a RPC (Remote Procedure Call)
  ///
  /// [functionName] The name of the PostgreSQL function
  /// [params] Optional parameters to pass to the function
  Future<dynamic> rpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await client.rpc(functionName, params: params);
      return response;
    } catch (e) {
      debugPrint('❌ Error executing RPC $functionName: $e');
      rethrow;
    }
  }

  // ==========================================
  // Storage Operations
  // ==========================================

  /// Get the Supabase storage client
  ///
  /// Returns a [SupabaseStorageClient] for interacting with storage buckets.
  SupabaseStorageClient storage() {
    return client.storage;
  }

  /// Get a specific bucket
  ///
  /// [bucketId] The ID of the storage bucket
  StorageFileApi bucket(String bucketId) {
    return client.storage.from(bucketId);
  }

  // ==========================================
  // Realtime Operations
  // ==========================================

  /// Create a realtime channel
  ///
  /// [channelName] The name of the channel
  RealtimeChannel channel(String channelName) {
    return client.channel(channelName);
  }

  /// Remove a realtime channel
  ///
  /// [channel] The channel to remove
  Future<void> removeChannel(RealtimeChannel channel) async {
    try {
      await client.removeChannel(channel);
    } catch (e) {
      debugPrint('❌ Error removing channel: $e');
      rethrow;
    }
  }

  /// Remove all realtime channels
  Future<void> removeAllChannels() async {
    try {
      await client.removeAllChannels();
    } catch (e) {
      debugPrint('❌ Error removing all channels: $e');
      rethrow;
    }
  }

  // ==========================================
  // Connection Management
  // ==========================================

  /// Check if the client is connected
  bool get isConnected {
    try {
      return client.realtime.isConnected;
    } catch (e) {
      return false;
    }
  }

  /// Get realtime connection status
  SocketStates? get realtimeStatus {
    return client.realtime.connState;
  }

  // ==========================================
  // Health Check
  // ==========================================

  /// Perform a health check on the Supabase connection
  ///
  /// Returns true if the connection is healthy
  Future<bool> healthCheck() async {
    try {
      // Try to query a simple table or perform a lightweight RPC
      await client.from('profiles').select('id').limit(1);
      return true;
    } catch (e) {
      debugPrint('❌ Health check failed: $e');
      return false;
    }
  }
}
