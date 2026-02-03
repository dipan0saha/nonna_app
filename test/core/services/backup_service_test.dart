import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/services/backup_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([DatabaseService, SupabaseClient, PostgrestFilterBuilder, GoTrueClient, User])
import 'backup_service_test.mocks.dart';

void main() {
  group('BackupService', () {
    late BackupService backupService;
    late MockDatabaseService mockDatabaseService;
    late MockSupabaseClient mockSupabaseClient;
    late MockPostgrestFilterBuilder mockFilterBuilder;
    late MockGoTrueClient mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockSupabaseClient = MockSupabaseClient();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      mockAuth = MockGoTrueClient();
      mockUser = MockUser();

      when(mockSupabaseClient.auth).thenReturn(mockAuth);
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn('test@example.com');

      backupService = BackupService(
        databaseService: mockDatabaseService,
        supabase: mockSupabaseClient,
      );
    });

    group('exportUserData', () {
      test('exports user data successfully', () async {
        final userId = 'test-user-id';

        // Mock database responses
        when(mockDatabaseService.select('profiles'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', userId))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.maybeSingle())
            .thenAnswer((_) async => {'user_id': userId, 'display_name': 'Test User'});

        when(mockDatabaseService.select('user_stats'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('baby_memberships'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('photos'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('photo_comments'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('event_comments'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('events'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('event_rsvps'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('registry_items'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('registry_purchases'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('name_suggestions'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('votes'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('notifications'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('photo_tags'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('photo_squishes'))
            .thenReturn(mockFilterBuilder);

        when(mockDatabaseService.select('invitations'))
            .thenReturn(mockFilterBuilder);

        // For select calls with eq(), return the filter builder
        // and stub its Future interface to return empty list
        when(mockFilterBuilder.eq(any, any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => null);
        when(mockFilterBuilder.limit(any)).thenReturn(mockFilterBuilder);
        
        // Stub the await on the filter builder itself
        when(mockFilterBuilder.then<List<Map<String, dynamic>>>(any))
            .thenAnswer((invocation) async {
          final onValue = invocation.positionalArguments[0];
          return onValue(<Map<String, dynamic>>[]);
        });

        final result = await backupService.exportUserData(userId);

        expect(result, isNotEmpty);
        expect(result, contains('export_metadata'));
      });

      test('throws error when database fails', () async {
        final userId = 'test-user-id';

        when(mockDatabaseService.select('profiles'))
            .thenThrow(Exception('Database error'));

        expect(
          () => backupService.exportUserData(userId),
          throwsException,
        );
      });
    });

    group('backupPhotos', () {
      test('returns backed up photo paths', () async {
        final userId = 'test-user-id';

        when(mockDatabaseService.select('photos', columns: 'id, storage_path'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('uploaded_by_user_id', userId))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('baby_profile_id', any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder).thenAnswer((_) async => [
              {'id': '1', 'storage_path': 'path/to/photo1.jpg'},
              {'id': '2', 'storage_path': 'path/to/photo2.jpg'},
            ]);

        final result = await backupService.backupPhotos(userId);

        expect(result, isNotEmpty);
        expect(result.length, 2);
      });

      test('returns empty list when no photos found', () async {
        final userId = 'test-user-id';

        when(mockDatabaseService.select('photos', columns: 'id, storage_path'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('uploaded_by_user_id', userId))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder).thenAnswer((_) async => []);

        final result = await backupService.backupPhotos(userId);

        expect(result, isEmpty);
      });
    });

    group('hasAutomaticBackupsEnabled', () {
      test('returns false by default', () async {
        final userId = 'test-user-id';

        final result = await backupService.hasAutomaticBackupsEnabled(userId);

        expect(result, false);
      });
    });

    group('getLastBackupDate', () {
      test('returns null when no previous backup', () async {
        final userId = 'test-user-id';

        final result = await backupService.getLastBackupDate(userId);

        expect(result, null);
      });
    });
  });
}
