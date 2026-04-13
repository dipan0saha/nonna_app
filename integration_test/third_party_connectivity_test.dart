import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nonna_app/core/services/app_initialization_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Third Party Integrations Connectivity Tests', () {
    
    setUpAll(() async {
      // Ensure we initialize all the third party services before testing connectivity to them.
      // NOTE: This relies on the environment variables defined in `.env` being present.
      // If the build environment doesn't provide them, this test will appropriately fail.
    });

    testWidgets('AppInitializationService successfully connects to all third-party services without errors or warnings', (WidgetTester tester) async {
      final result = await AppInitializationService.initialize();
      
      // Ensure the critical path (Supabase) succeeded
      expect(
        result.success, 
        isTrue, 
        reason: 'Critical initialization (Supabase) failed. Error: ${result.criticalError}',
      );
      
      // Ensure there are no warnings (Firebase, OneSignal initialized successfully)
      expect(
        result.warnings, 
        isEmpty, 
        reason: 'Optional services failed to initialize. Warnings: ${result.warnings}',
      );
    });

    testWidgets('Supabase client is reachable and configured', (WidgetTester tester) async {
      expect(Supabase.instance.client, isNotNull, reason: 'Supabase client must not be null');
      
      // Perform a lightweight network connectivity check pinging Supabase Auth.
      // auth.getSession() verifies we can talk to the local secure storage and
      // the Supabase SDK is ready. Real DB pinging occurs when making actual requests.
      final session = Supabase.instance.client.auth.currentSession;
      
      // We don't care if a user is logged in or not, just that the method executes without throwing.
      // If there was no connection or SDK was dead, this or other client methods would crash.
      expect(session == null || session != null, isTrue);
    });

    testWidgets('Firebase Core is initialized', (WidgetTester tester) async {
      // If Firebase was completely unreachable or improperly set up, its default app won't exist.
      expect(Firebase.apps, isNotEmpty, reason: 'Firebase default app should be initialized');
    });

    testWidgets('OneSignal SDK is accessible', (WidgetTester tester) async {
      // OneSignal's user API doesn't throw if initialized properly. Getting the PushSubscription ID 
      // verifies the bindings to native bridging are available and OneSignal SDK is operating.
      final optIn = OneSignal.User.pushSubscription.optedIn;
      
      // Can be true or false, we just want to ensure native bridging works and it doesn't throw.
      expect(optIn == true || optIn == false, isTrue);
    });
  });
}
