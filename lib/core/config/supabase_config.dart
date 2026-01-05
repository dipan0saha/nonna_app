import 'package:flutter/foundation.dart'; // For kReleaseMode
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static String get supabaseUrl => kReleaseMode
      ? const String.fromEnvironment('SUPABASE_URL', defaultValue: '')
      : dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey => kReleaseMode
      ? const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '')
      : dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> initialize() async {
    if (!kReleaseMode) {
      await dotenv.load(fileName: '.env');
    }
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
}
