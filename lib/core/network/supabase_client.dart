import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton Supabase client for the application
/// Provides a single point of access to Supabase services
class SupabaseClientManager {
  static SupabaseClient? _client;
  static bool _isInitialized = false;

  /// Private constructor to prevent instantiation
  SupabaseClientManager._();

  /// Get the Supabase client instance
  static SupabaseClient get instance {
    if (_client == null) {
      throw StateError(
        'SupabaseClientManager not initialized. Call initialize() first.',
      );
    }
    return _client!;
  }

  /// Check if the client has been initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize the Supabase client
  ///
  /// Must be called before accessing [instance]
  /// Should be called in main() before runApp()
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️  Supabase client already initialized');
      return;
    }

    try {
      // Load environment variables
      await dotenv.load(fileName: '.env');

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception(
          'SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env file',
        );
      }

      // Initialize Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          autoRefreshToken: true,
          detectSessionInUri: true,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );

      _client = Supabase.instance.client;
      _isInitialized = true;

      debugPrint('✅ Supabase client initialized successfully');
      debugPrint('   URL: $supabaseUrl');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing Supabase client: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Dispose the client (for testing purposes)
  @visibleForTesting
  static void dispose() {
    _client = null;
    _isInitialized = false;
  }

  /// Reset the client (for testing purposes)
  @visibleForTesting
  static void reset() {
    dispose();
  }
}
