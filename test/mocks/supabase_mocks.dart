import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Generate mocks for Supabase components used in tests
@GenerateMocks([
  SupabaseClient,
  FirebaseAnalytics,
])
// ignore: unused_import
import 'supabase_mocks.mocks.dart';
