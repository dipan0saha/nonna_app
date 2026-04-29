import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create a minimal client
  final client = SupabaseClient(
    'https://ubptybhhrgdiyfkcqgwu.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVicHR5YmhocmdkaXlma2NxZ3d1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5Njc5MTksImV4cCI6MjA4MTU0MzkxOX0.9tS0NrWR8ewWKu4A2lnqKTpUARm4AwktE4IMgW9pHbM',
  );

  try {
    final response = await client.from('tile_definitions').select().limit(1);
    print('TILE DEFINITIONS SCHEMA:');
    print(response);
  } catch (e) {
    print('Error: $e');
  }
}
