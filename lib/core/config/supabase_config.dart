import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';

class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> initialize() async {
    // Load .env regardless of release/debug to simplify the build process
    await dotenv.load(fileName: '.env');

    // Check if we need a fallback for URL/Key just in case
    final url = supabaseUrl.isNotEmpty
        ? supabaseUrl
        : const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    final anonKey = supabaseAnonKey.isNotEmpty
        ? supabaseAnonKey
        : const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
        detectSessionInUri: true,
      ),
    );
    // Sync the singleton manager so that Riverpod providers can access the
    // Supabase client without a separate initialization call.
    SupabaseClientManager.initializeFromGlobal();
  }
}
