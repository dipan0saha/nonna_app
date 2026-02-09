import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/user.dart';
import 'package:nonna_app/core/models/user_stats.dart';
import 'package:nonna_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/di/providers.dart';

import '../../../../helpers/fake_postgrest_builders.dart';
import '../../../../mocks/mock_services.mocks.dart';
import '../../../../helpers/mock_factory.dart';

void main() {
  group('ProfileProvider Tests', () {
    late ProfileNotifier notifier;
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockStorageService mockStorageService;

    // Sample data
    final sampleUser = User(
      userId: 'user_1',
      displayName: 'Jane Doe',
      avatarUrl: 'https://example.com/avatar.jpg',
      biometricEnabled: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final sampleStats = UserStats(
      eventsAttendedCount: 5,
      itemsPurchasedCount: 3,
      photosSquishedCount: 10,
      commentsAddedCount: 7,
    );

    setUp(() {
      mockDatabaseService = MockFactory.createDatabaseService();
      mockCacheService = MockFactory.createCacheService();
      mockStorageService = MockFactory.createStorageService();

      when(mockCacheService.isInitialized).thenReturn(true);

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          cacheServiceProvider.overrideWithValue(mockCacheService),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
      );

      notifier = container.read(profileProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('initial state has no profile', () {
        expect(notifier.state.profile, isNull);
        expect(notifier.state.stats, isNull);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.isSaving, isFalse);
        expect(notifier.state.isEditMode, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.saveError, isNull);
        expect(notifier.state.saveSuccess, isFalse);
      });
    });

    group('loadProfile', () {
      test('sets loading state while loading', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([sampleUser.toJson()]));

        final loadFuture = notifier.loadProfile(userId: 'user_1');

        expect(notifier.state.isLoading, isTrue);

        await loadFuture;
      });

      test('loads profile from database when cache is empty', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns'))).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleUser.toJson()]);
          } else {
            return FakePostgrestBuilder([sampleStats.toJson()]);
          }
        });

        await notifier.loadProfile(userId: 'user_1');

        expect(notifier.state.profile, isNotNull);
        expect(notifier.state.profile!.userId, equals('user_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('loads profile from cache when available', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => sampleUser.toJson());
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([sampleStats.toJson()]));

        await notifier.loadProfile(userId: 'user_1');

        expect(notifier.state.profile, isNotNull);
        expect(notifier.state.profile!.userId, equals('user_1'));
      });

      test('handles profile not found error', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        await notifier.loadProfile(userId: 'user_1');

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Profile not found'));
        expect(notifier.state.profile, isNull);
      });

      test('handles database error gracefully', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenThrow(Exception('Database error'));

        await notifier.loadProfile(userId: 'user_1');

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.profile, isNull);
      });

      test('force refresh bypasses cache', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => sampleUser.toJson());
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns'))).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleUser.toJson()]);
          } else {
            return FakePostgrestBuilder([sampleStats.toJson()]);
          }
        });

        await notifier.loadProfile(userId: 'user_1', forceRefresh: true);

        verify(mockDatabaseService.select(any)).called(greaterThan(0));
      });

      test('saves fetched profile to cache', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns'))).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleUser.toJson()]);
          } else {
            return FakePostgrestBuilder([sampleStats.toJson()]);
          }
        });

        await notifier.loadProfile(userId: 'user_1');

        verify(mockCacheService.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });

      test('loads user stats after loading profile', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns'))).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleUser.toJson()]);
          } else {
            return FakePostgrestBuilder([sampleStats.toJson()]);
          }
        });

        await notifier.loadProfile(userId: 'user_1');

        expect(notifier.state.stats, isNotNull);
        expect(notifier.state.stats!.eventsAttendedCount, equals(5));
      });
    });

    group('enterEditMode', () {
      test('enables edit mode', () {
        notifier.enterEditMode();

        expect(notifier.state.isEditMode, isTrue);
        expect(notifier.state.saveError, isNull);
        expect(notifier.state.saveSuccess, isFalse);
      });
    });

    group('cancelEdit', () {
      test('disables edit mode', () {
        notifier.enterEditMode();
        notifier.cancelEdit();

        expect(notifier.state.isEditMode, isFalse);
        expect(notifier.state.saveError, isNull);
        expect(notifier.state.saveSuccess, isFalse);
      });
    });

    group('updateProfile', () {
      test('updates profile successfully', () async {
        when(mockDatabaseService.update(any, any))
            .thenReturn(FakePostgrestUpdateBuilder());
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns'))).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleUser.toJson()]);
          } else {
            return FakePostgrestBuilder([sampleStats.toJson()]);
          }
        });
        when(mockCacheService.get(any)).thenAnswer((_) async => null);

        await notifier.updateProfile(
          userId: 'user_1',
          displayName: 'Jane Smith',
        );

        expect(notifier.state.isSaving, isFalse);
        expect(notifier.state.isEditMode, isFalse);
        expect(notifier.state.saveSuccess, isTrue);
        expect(notifier.state.saveError, isNull);
      });

      test('validates empty display name', () async {
        await notifier.updateProfile(
          userId: 'user_1',
          displayName: '   ',
        );

        expect(notifier.state.isSaving, isFalse);
        expect(notifier.state.saveError, contains('Display name is required'));
        expect(notifier.state.saveSuccess, isFalse);
      });

      test('validates display name length', () async {
        await notifier.updateProfile(
          userId: 'user_1',
          displayName: 'a' * 101,
        );

        expect(notifier.state.isSaving, isFalse);
        expect(notifier.state.saveError, contains('100 characters or less'));
        expect(notifier.state.saveSuccess, isFalse);
      });

      test('handles database error during update', () async {
        when(mockDatabaseService.update(any, any))
            .thenThrow(Exception('Update failed'));

        await notifier.updateProfile(
          userId: 'user_1',
          displayName: 'Jane Smith',
        );

        expect(notifier.state.isSaving, isFalse);
        expect(notifier.state.saveError, contains('Update failed'));
        expect(notifier.state.saveSuccess, isFalse);
      });

      test('updates profile with avatar URL', () async {
        when(mockDatabaseService.update(any, any))
            .thenReturn(FakePostgrestUpdateBuilder());
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns'))).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleUser.toJson()]);
          } else {
            return FakePostgrestBuilder([sampleStats.toJson()]);
          }
        });
        when(mockCacheService.get(any)).thenAnswer((_) async => null);

        await notifier.updateProfile(
          userId: 'user_1',
          displayName: 'Jane Smith',
          avatarUrl: 'https://example.com/new-avatar.jpg',
        );

        expect(notifier.state.saveSuccess, isTrue);
      });
    });

    group('uploadAvatar', () {
      test('uploads avatar successfully', () async {
        when(mockStorageService.uploadFile(
          filePath: 'test_file_path',
          storageKey: 'test_storage_key',
          bucket: 'test_bucket',
        )).thenAnswer((_) async => 'https://example.com/uploaded-avatar.jpg');

        final result = await notifier.uploadAvatar(
          userId: 'user_1',
          filePath: '/path/to/avatar.jpg',
        );

        expect(result, isNotNull);
        expect(result, contains('uploaded-avatar.jpg'));
      });

      test('handles upload error gracefully', () async {
        when(mockStorageService.uploadFile(
          filePath: 'test_file_path',
          storageKey: 'test_storage_key',
          bucket: 'test_bucket',
        )).thenThrow(Exception('Upload failed'));

        final result = await notifier.uploadAvatar(
          userId: 'user_1',
          filePath: '/path/to/avatar.jpg',
        );

        expect(result, isNull);
      });
    });

    group('toggleBiometric', () {
      test('enables biometric successfully', () async {
        when(mockDatabaseService.update(any, any))
            .thenReturn(FakePostgrestUpdateBuilder());
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns'))).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleUser.toJson()]);
          } else {
            return FakePostgrestBuilder([sampleStats.toJson()]);
          }
        });
        when(mockCacheService.get(any)).thenAnswer((_) async => null);

        await notifier.toggleBiometric(
          userId: 'user_1',
          enabled: true,
        );

        verify(mockDatabaseService.update(any, any)).called(1);
      });

      test('handles toggle biometric error', () async {
        when(mockDatabaseService.update(any, any))
            .thenThrow(Exception('Update failed'));

        expect(
          () => notifier.toggleBiometric(userId: 'user_1', enabled: true),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('refresh', () {
      test('refreshes profile with force refresh', () async {
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns'))).thenAnswer((_) {
          callCount++;
          if (callCount == 1 || callCount == 3) {
            return FakePostgrestBuilder([sampleUser.toJson()]);
          } else {
            return FakePostgrestBuilder([sampleStats.toJson()]);
          }
        });
        when(mockCacheService.get(any)).thenAnswer((_) async => null);

        await notifier.loadProfile(userId: 'user_1');

        final initialLoadCount =
            verify(mockDatabaseService.select(any)).callCount;

        await notifier.refresh('user_1');

        expect(verify(mockDatabaseService.select(any)).callCount,
            greaterThan(initialLoadCount));
      });
    });
  });
}
