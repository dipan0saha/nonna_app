import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/baby_membership.dart';
import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/storage_service.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';

import '../../../../helpers/fake_postgrest_builders.dart';

@GenerateMocks([DatabaseService, CacheService, StorageService])
import 'baby_profile_provider_test.mocks.dart';

void main() {
  group('BabyProfileProvider Tests', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockStorageService mockStorageService;

    // Sample data
    final sampleProfile = BabyProfile(
      id: 'baby_1',
      name: 'Baby Jane',
      gender: Gender.female,
      expectedBirthDate: DateTime.now().add(const Duration(days: 90)),
      profilePhotoUrl: 'https://example.com/baby.jpg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final sampleMembership = BabyMembership(
      babyProfileId: 'baby_1',
      userId: 'user_1',
      role: UserRole.owner,
      relationshipLabel: 'Mother',
      createdAt: DateTime.now(),
    );

    final followerMembership = BabyMembership(
      babyProfileId: 'baby_1',
      userId: 'user_2',
      role: UserRole.follower,
      relationshipLabel: 'Grandmother',
      createdAt: DateTime.now(),
    );

    setUp(() {
      // Provide dummy values for mockito null-safety
      provideDummy<String>('');
      
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockStorageService = MockStorageService();

      when(mockCacheService.isInitialized).thenReturn(true);

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          cacheServiceProvider.overrideWithValue(mockCacheService),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('initial state has no profile', () {
        final state = container.read(babyProfileProvider);
        
        expect(state.profile, isNull);
        expect(state.memberships, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.isSaving, isFalse);
        expect(state.isEditMode, isFalse);
        expect(state.error, isNull);
        expect(state.saveError, isNull);
        expect(state.saveSuccess, isFalse);
        expect(state.isOwner, isFalse);
      });
    });

    group('loadProfile', () {
      test('sets loading state while loading', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        final loadFuture = container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        expect(container.read(babyProfileProvider).isLoading, isTrue);

        await loadFuture;
      });

      test('loads profile from database when cache is empty', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        expect(container.read(babyProfileProvider).profile, isNotNull);
        expect(container.read(babyProfileProvider).profile!.id, equals('baby_1'));
        expect(container.read(babyProfileProvider).isLoading, isFalse);
        expect(container.read(babyProfileProvider).error, isNull);
        expect(container.read(babyProfileProvider).isOwner, isTrue);
      });

      test('loads profile from cache when available', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => sampleProfile.toJson());
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        expect(container.read(babyProfileProvider).profile, isNotNull);
        expect(container.read(babyProfileProvider).profile!.id, equals('baby_1'));
      });

      test('loads profile with memberships', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([
              sampleMembership.toJson(),
              followerMembership.toJson(),
            ]);
          }
        });

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        expect(container.read(babyProfileProvider).memberships, hasLength(2));
        expect(container.read(babyProfileProvider).owners, hasLength(1));
        expect(container.read(babyProfileProvider).followers, hasLength(1));
      });

      test('handles profile not found error', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([]));

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        expect(container.read(babyProfileProvider).isLoading, isFalse);
        expect(container.read(babyProfileProvider).error, contains('Baby profile not found'));
        expect(container.read(babyProfileProvider).profile, isNull);
      });

      test('handles database error gracefully', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        expect(container.read(babyProfileProvider).isLoading, isFalse);
        expect(container.read(babyProfileProvider).error, contains('Database error'));
        expect(container.read(babyProfileProvider).profile, isNull);
      });

      test('force refresh bypasses cache', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => sampleProfile.toJson());
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
          forceRefresh: true,
        );

        verify(mockDatabaseService.select(any)).called(greaterThan(0));
      });

      test('saves fetched profile to cache', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        verify(mockCacheService.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });
    });

    group('enterEditMode', () {
      test('enables edit mode when user is owner', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        notifier.enterEditMode();

        expect(container.read(babyProfileProvider).isEditMode, isTrue);
        expect(container.read(babyProfileProvider).saveError, isNull);
        expect(container.read(babyProfileProvider).saveSuccess, isFalse);
      });

      test('does not enable edit mode when user is not owner', () {
        notifier.enterEditMode();

        expect(container.read(babyProfileProvider).isEditMode, isFalse);
      });
    });

    group('cancelEdit', () {
      test('disables edit mode', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        notifier.enterEditMode();
        notifier.cancelEdit();

        expect(container.read(babyProfileProvider).isEditMode, isFalse);
        expect(container.read(babyProfileProvider).saveError, isNull);
        expect(container.read(babyProfileProvider).saveSuccess, isFalse);
      });
    });

    group('createProfile', () {
      test('creates baby profile successfully', () async {
        when(mockDatabaseService.insert(any, any))
            .thenAnswer((_) async => [sampleProfile.toJson()]);

        final result = await notifier.createProfile(
          name: 'Baby Jane',
          userId: 'user_1',
          expectedBirthDate: DateTime.now().add(const Duration(days: 90)),
          gender: Gender.female,
        );

        expect(result, isNotNull);
        expect(result!.name, equals('Baby Jane'));
        expect(container.read(babyProfileProvider).isSaving, isFalse);
        expect(container.read(babyProfileProvider).saveSuccess, isTrue);
        expect(container.read(babyProfileProvider).isOwner, isTrue);
      });

      test('validates empty baby name', () async {
        final result = await notifier.createProfile(
          name: '   ',
          userId: 'user_1',
        );

        expect(result, isNull);
        expect(container.read(babyProfileProvider).isSaving, isFalse);
        expect(container.read(babyProfileProvider).saveError, contains('Baby name is required'));
        expect(container.read(babyProfileProvider).saveSuccess, isFalse);
      });

      test('handles database error during creation', () async {
        when(mockDatabaseService.insert(any, any))
            .thenThrow(Exception('Creation failed'));

        final result = await notifier.createProfile(
          name: 'Baby Jane',
          userId: 'user_1',
        );

        expect(result, isNull);
        expect(container.read(babyProfileProvider).isSaving, isFalse);
        expect(container.read(babyProfileProvider).saveError, contains('Creation failed'));
        expect(container.read(babyProfileProvider).saveSuccess, isFalse);
      });
    });

    group('updateProfile', () {
      test('updates profile successfully when user is owner', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1 || callCount == 4) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2 || callCount == 5) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });
        when(mockDatabaseService.update(any, any))
            .thenReturn(FakePostgrestUpdateBuilder());

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        await notifier.updateProfile(
          babyProfileId: 'baby_1',
          name: 'Baby Jane Smith',
          gender: Gender.female,
        );

        expect(container.read(babyProfileProvider).isSaving, isFalse);
        expect(container.read(babyProfileProvider).isEditMode, isFalse);
        expect(container.read(babyProfileProvider).saveSuccess, isTrue);
        expect(container.read(babyProfileProvider).saveError, isNull);
      });

      test('does not update when user is not owner', () async {
        await notifier.updateProfile(
          babyProfileId: 'baby_1',
          name: 'Baby Jane Smith',
        );

        expect(container.read(babyProfileProvider).saveError, contains('Only owners can update'));
        verifyNever(mockDatabaseService.update(any, any));
      });

      test('validates empty baby name', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        await notifier.updateProfile(
          babyProfileId: 'baby_1',
          name: '   ',
        );

        expect(container.read(babyProfileProvider).isSaving, isFalse);
        expect(container.read(babyProfileProvider).saveError, contains('Baby name is required'));
        expect(container.read(babyProfileProvider).saveSuccess, isFalse);
      });

      test('handles database error during update', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });
        when(mockDatabaseService.update(any, any))
            .thenThrow(Exception('Update failed'));

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        await notifier.updateProfile(
          babyProfileId: 'baby_1',
          name: 'Baby Jane Smith',
        );

        expect(container.read(babyProfileProvider).isSaving, isFalse);
        expect(container.read(babyProfileProvider).saveError, contains('Update failed'));
        expect(container.read(babyProfileProvider).saveSuccess, isFalse);
      });
    });

    group('deleteProfile', () {
      test('deletes profile successfully when user is owner', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });
        when(mockDatabaseService.update(any, any))
            .thenReturn(FakePostgrestUpdateBuilder());

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        final result = await notifier.deleteProfile(babyProfileId: 'baby_1');

        expect(result, isTrue);
        verify(mockDatabaseService.update(any, any)).called(1);
      });

      test('does not delete when user is not owner', () async {
        final result = await notifier.deleteProfile(babyProfileId: 'baby_1');

        expect(result, isFalse);
        verifyNever(mockDatabaseService.update(any, any));
      });

      test('handles database error during deletion', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });
        when(mockDatabaseService.update(any, any))
            .thenThrow(Exception('Delete failed'));

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        final result = await notifier.deleteProfile(babyProfileId: 'baby_1');

        expect(result, isFalse);
      });
    });

    group('uploadProfilePhoto', () {
      test('uploads profile photo successfully', () async {
        when(mockStorageService.uploadFile(
          filePath: 'filePath',
          storageKey: 'storageKey',
          bucket: 'bucket',
        )).thenAnswer((_) async => 'https://example.com/uploaded-photo.jpg');

        final result = await container.read(babyProfileProvider.notifier).uploadProfilePhoto(
          babyProfileId: 'baby_1',
          filePath: '/path/to/photo.jpg',
        );

        expect(result, isNotNull);
        expect(result, contains('uploaded-photo.jpg'));
      });

      test('handles upload error gracefully', () async {
        when(mockStorageService.uploadFile(
          filePath: 'filePath',
          storageKey: 'storageKey',
          bucket: 'bucket',
        )).thenThrow(Exception('Upload failed'));

        final result = await container.read(babyProfileProvider.notifier).uploadProfilePhoto(
          babyProfileId: 'baby_1',
          filePath: '/path/to/photo.jpg',
        );

        expect(result, isNull);
      });
    });

    group('removeFollower', () {
      test('removes follower successfully when user is owner', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2 || callCount == 3) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });
        when(mockDatabaseService.delete(any))
            .thenReturn(FakePostgrestDeleteBuilder());

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        final result = await container.read(babyProfileProvider.notifier).removeFollower(
          babyProfileId: 'baby_1',
          membershipId: 'membership_1',
        );

        expect(result, isTrue);
        verify(mockDatabaseService.delete(any)).called(1);
      });

      test('does not remove follower when user is not owner', () async {
        final result = await container.read(babyProfileProvider.notifier).removeFollower(
          babyProfileId: 'baby_1',
          membershipId: 'membership_1',
        );

        expect(result, isFalse);
        verifyNever(mockDatabaseService.delete(any));
      });

      test('handles database error during removal', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });
        when(mockDatabaseService.delete(any))
            .thenThrow(Exception('Delete failed'));

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        final result = await container.read(babyProfileProvider.notifier).removeFollower(
          babyProfileId: 'baby_1',
          membershipId: 'membership_1',
        );

        expect(result, isFalse);
      });
    });

    group('refresh', () {
      test('refreshes profile with force refresh', () async {
        var callCount = 0;
        when(mockDatabaseService.select(any)).thenAnswer((_) {
          callCount++;
          if (callCount == 1 || callCount == 4) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2 ||
              callCount == 3 ||
              callCount == 5 ||
              callCount == 6) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });
        when(mockCacheService.get(any)).thenAnswer((_) async => null);

        await container.read(babyProfileProvider.notifier).loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        final initialLoadCount =
            verify(mockDatabaseService.select(any)).callCount;

        await container.read(babyProfileProvider.notifier).refresh('baby_1', 'user_1');

        expect(verify(mockDatabaseService.select(any)).callCount,
            greaterThan(initialLoadCount));
      });
    });
  });
}
