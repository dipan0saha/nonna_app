import 'package:integration_test/integration_test.dart';

import 'fd_00_auth_navigation_test.dart' as auth_navigation;
import 'fd_01_profile_followers_test.dart' as profile_followers;
import 'fd_02_feature_flows_test.dart' as feature_flows;
import 'fd_03_settings_logout_test.dart' as settings_logout;
import 'fd_04_gallery_notifications_test.dart' as gallery_notifications;
import 'fd_05_context_constraints_test.dart' as context_constraints;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  auth_navigation.main();
  profile_followers.main();
  feature_flows.main();
  settings_logout.main();
  gallery_notifications.main();
  context_constraints.main();
}
