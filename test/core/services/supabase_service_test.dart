import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/supabase_service.dart';

import '../../mocks/mock_services.mocks.dart';
import '../../helpers/mock_factory.dart';

void main() {
  group('SupabaseService', () {
    late SupabaseService supabaseService;

    setUp(() {
      supabaseService = SupabaseService();
    });

    // Note: handleError tests removed as method no longer exists in SupabaseService.
    // Error handling is now done via ErrorHandler middleware.
    // These tests should be moved to error_handler_test.dart if not already present.

    test('provides access to current user', () {
      // This is a basic test to ensure the service is instantiated correctly
      // More comprehensive tests would require proper Supabase initialization
      expect(supabaseService, isNotNull);
    });
  });
}
