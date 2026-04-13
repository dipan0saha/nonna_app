import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'auth_integration_test.dart' as auth;
import 'baby_profile_integration_test.dart' as baby_profile;
import 'dashboard_integration_test.dart' as dashboard;
import 'gallery_integration_test.dart' as gallery;
import 'events_integration_test.dart' as events;
import 'registry_integration_test.dart' as registry;
import 'gamification_integration_test.dart' as gamification;
import 'notifications_integration_test.dart' as notifications;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Nonna App Master Integration Test Suite', () {
    // We execute these in a specific hierarchical order 
    // to prevent cascading dependency failures.
    
    auth.main();
    baby_profile.main();
    dashboard.main();
    gallery.main();
    events.main();
    registry.main();
    gamification.main();
    notifications.main();
  });
}
