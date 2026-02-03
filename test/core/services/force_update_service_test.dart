import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/force_update_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([DatabaseService, SupabaseClient, PostgrestFilterBuilder])
import 'force_update_service_test.mocks.dart';

void main() {
  group('ForceUpdateService', () {
    late ForceUpdateService forceUpdateService;
    late MockDatabaseService mockDatabaseService;
    late MockSupabaseClient mockSupabaseClient;
    late MockPostgrestFilterBuilder mockFilterBuilder;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockSupabaseClient = MockSupabaseClient();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      
      forceUpdateService = ForceUpdateService(
        databaseService: mockDatabaseService,
        supabase: mockSupabaseClient,
      );
    });

    group('Version Comparison', () {
      test('UpdateInfo model contains correct information', () {
        final updateInfo = UpdateInfo(
          currentVersion: '1.0.0',
          minimumVersion: '1.1.0',
          needsUpdate: true,
          storeUrl: 'https://play.google.com/store',
        );

        expect(updateInfo.currentVersion, '1.0.0');
        expect(updateInfo.minimumVersion, '1.1.0');
        expect(updateInfo.needsUpdate, true);
        expect(updateInfo.storeUrl, 'https://play.google.com/store');
      });

      test('UpdateInfo toString returns formatted string', () {
        final updateInfo = UpdateInfo(
          currentVersion: '1.0.0',
          minimumVersion: '1.1.0',
          needsUpdate: true,
          storeUrl: 'https://play.google.com/store',
        );

        final str = updateInfo.toString();
        expect(str, contains('currentVersion: 1.0.0'));
        expect(str, contains('minimumVersion: 1.1.0'));
        expect(str, contains('needsUpdate: true'));
      });
    });

    group('Development Bypass', () {
      test('shouldBypassForDevelopment returns true in debug mode', () {
        final result = forceUpdateService.shouldBypassForDevelopment();
        expect(result, kDebugMode);
      });
    });

    group('needsUpdate', () {
      test('returns false when no minimum version is set', () async {
        when(mockDatabaseService.select('app_versions', columns: 'minimum_version, platform'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('platform', any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single())
            .thenThrow(Exception('No minimum version'));

        final result = await forceUpdateService.needsUpdate();
        expect(result, false);
      });

      test('returns false when there is an error checking version', () async {
        when(mockDatabaseService.select('app_versions', columns: 'minimum_version, platform'))
            .thenThrow(Exception('Database error'));

        final result = await forceUpdateService.needsUpdate();
        expect(result, false);
      });
    });

    group('getStoreUrl', () {
      test('returns null when there is an error', () async {
        when(mockDatabaseService.select('app_versions', columns: 'store_url, platform'))
            .thenThrow(Exception('Database error'));

        final result = await forceUpdateService.getStoreUrl();
        expect(result, null);
      });
    });

    group('shouldShowUpdatePrompt', () {
      test('returns false in development mode', () async {
        // In debug mode, should always return false
        if (kDebugMode) {
          final result = await forceUpdateService.shouldShowUpdatePrompt();
          expect(result, false);
        }
      });
    });

    group('getUpdateInfo', () {
      test('returns null when there is an error', () async {
        when(mockDatabaseService.select('app_versions', columns: 'minimum_version, platform'))
            .thenThrow(Exception('Database error'));

        final result = await forceUpdateService.getUpdateInfo();
        expect(result, null);
      });
    });
  });
}
