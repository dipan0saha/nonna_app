import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  final db = Supabase.instance.client;
  final events = await db.from('events').select();
  print('Total events in DB: ${events.length}');
  
  final tileConfigs = await db.from('tile_configs')
      .select('*, screens!inner(*), tile_definitions!inner(*)')
      .eq('screens.screen_name', 'calendar');
      
  print('Tile Configs for calendar:');
  for (var config in tileConfigs) {
    print('- ${config['tile_definitions']['tile_type']} (role: ${config['role']})');
  }
}
