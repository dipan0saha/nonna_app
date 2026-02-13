import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/baby_membership.dart';
import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';

import '../../../../helpers/fake_postgrest_builders.dart';
import '../../../../helpers/mock_factory.dart';
import '../../../../mocks/mock_services.mocks.dart';

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
      mockDatabaseService = MockFactory.createDatabaseService();
      mockCacheService = MockFactory.createCacheService();
      mockStorageService = MockFactory.createStorageService();

      // Add ALL default mock behaviors BEFORE creating container
      when(mockCacheService.isInitialized).thenReturn(true);
      when(mockCacheService.get(any)).thenAnswer((_) async => null);
      when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
          .thenAnswer((_) async {});
      when(mockDatabaseService.select(any))
          .thenAnswer((_) => FakePostgrestBuilder([]));
      when(mockStorageService.uploadFile(
        filePath: anyNamed('filePath'),
        storageKey: anyNamed('storageKey'),
        bucket: anyNamed('bucket'),
      )).thenAnswer((_) async => 'https://example.com/test-photo.jpg');

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
      reset(mockDatabaseService);
      reset(mockCacheService);
      reset(mockStorageService);
    });

    group('Initial State', () {
      test('initial state has no profile', () {
        final notifier = container.read(babyProfileProvider.notifier);
        expect(notifier.state.profile, isNull);
        expect(notifier.state.memberships, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.isSaving, isFalse);
        expect(notifier.state.isEditMode, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.saveError, isNull);
        expect(notifier.state.saveSuccess, isFalse);
        expect(notifier.state.isOwner, isFalse);
      });
    });

    group('loadProfile', () {
      test('sets loading state while loading', () async {
        reset(mockDatabaseService);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        final loadFuture = notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        expect(notifier.state.isLoading, isTrue);

        await loadFuture;
      });

      test('loads profile from database when cache is empty', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        expect(notifier.state.profile, isNotNull);
        expect(notifier.state.profile!.id, equals('baby_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.isOwner, isTrue);
      });

      test('loads profile from cache when available', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final notifier = container.read(babyProfileProvider.notifier);
        when(mockCacheService.get(any))
            .thenAnswer((_) async => sampleProfile.toJson());
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        expect(notifier.state.profile, isNotNull);
        expect(notifier.state.profile!.id, equals('baby_1'));
      });

      test('loads profile with memberships', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
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

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        expect(notifier.state.memberships, hasLength(2));
        expect(notifier.state.owners, hasLength(1));
        expect(notifier.state.followers, hasLength(1));
      });

      test('handles profile not found error', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        final notifier = container.read(babyProfileProvider.notifier);

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Baby profile not found'));
        expect(notifier.state.profile, isNull);
      });

      test('handles database error gracefully', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenThrow(Exception('Database error'));

        final notifier = container.read(babyProfileProvider.notifier);

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.profile, isNull);
      });

      test('force refresh bypasses cache', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any))
            .thenAnswer((_) async => sampleProfile.toJson());
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
          forceRefresh: true,
        );

        verify(mockDatabaseService.select(any)).called(greaterThan(0));
      });

      test('saves fetched profile to cache', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await notifier.loadProfile(
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
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        notifier.enterEditMode();

        expect(notifier.state.isEditMode, isTrue);
        expect(notifier.state.saveError, isNull);
        expect(notifier.state.saveSuccess, isFalse);
      });

      test('does not enable edit mode when user is not owner', () {
        final notifier = container.read(babyProfileProvider.notifier);
        notifier.enterEditMode();

        expect(notifier.state.isEditMode, isFalse);
      });
    });

    group('cancelEdit', () {
      test('disables edit mode', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        notifier.enterEditMode();
        notifier.cancelEdit();

        expect(notifier.state.isEditMode, isFalse);
        expect(notifier.state.saveError, isNull);
        expect(notifier.state.saveSuccess, isFalse);
      });
    });

    group('createProfile', () {
      test('creates baby profile successfully', () async {
        reset(mockDatabaseService);
        when(mockDatabaseService.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([]));
        when(mockDatabaseService.insert(any, any))
            .thenAnswer((_) async => [sampleProfile.toJson()]);

        final notifier = container.read(babyProfileProvider.notifier);

        final result = await notifier.createProfile(
          name: 'Baby Jane',
          userId: 'user_1',
          expectedBirthDate: DateTime.now().add(const Duration(days: 90)),
          gender: Gender.female,
        );

        expect(result, isNotNull);
        expect(result!.name, equals('Baby Jane'));
        expect(notifier.state.isSaving, isFalse);
        expect(notifier.state.saveSuccess, isTrue);
        expect(notifier.state.isOwner, isTrue);
      });

      test('validates empty baby name', () async {
        final notifier = container.read(babyProfileProvider.notifier);
        final result = await notifier.createProfile(
          name: '   ',
          userId: 'user_1',
        );

        expect(result, isNull);
        expect(notifier.state.isSaving, isFalse);
        expect(notifier.state.saveError, contains('Baby name is required'));
        expect(notifier.state.saveSuccess, isFalse);
      });

      test('handles database error during creation', () async {
        reset(mockDatabaseService);
        when(mockDatabaseService.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([]));
        when(mockDatabaseService.insert(any, any))
            .thenThrow(Exception('Creation failed'));

        final notifier = container.read(babyProfileProvider.notifier);

        final result = await notifier.createProfile(
          name: 'Baby Jane',
          userId: 'user_1',
        );

        expect(result, isNull);
        expect(notifier.state.isSaving, isFalse);
        expect(notifier.state.saveError, contains('Creation failed'));
        expect(notifier.state.saveSuccess, isFalse);
      });
    });

    group('updateProfile', () {
      test('updates profile successfully when user is owner', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
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
            .thenAnswer((_) => FakePostgrestUpdateBuilder());

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        await notifier.updateProfile(
          babyProfileId: 'baby_1',
          name: 'Baby Jane Smith',
          gender: Gender.female,
        );

        expect(notifier.state.isSaving, isFalse);
        expect(notifier.state.isEditMode, isFalse);
        expect(notifier.state.saveSuccess, isTrue);
        expect(notifier.state.saveError, isNull);
      });

      test('does not update when user is not owner', () async {
        final notifier = container.read(babyProfileProvider.notifier);
        await notifier.updateProfile(
          babyProfileId: 'baby_1',
          name: 'Baby Jane Smith',
        );

        expect(notifier.state.saveError, contains('Only owners can update'));
        verifyNever(mockDatabaseService.update(any, any));
      });

      test('validates empty baby name', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return FakePostgrestBuilder([sampleProfile.toJson()]);
          } else if (callCount == 2) {
            return FakePostgrestBuilder([sampleMembership.toJson()]);
          } else {
            return FakePostgrestBuilder([]);
          }
        });

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        await notifier.updateProfile(
          babyProfileId: 'baby_1',
          name: '   ',
        );

        expect(notifier.state.isSaving, isFalse);
        expect(notifier.state.saveError, contains('Baby name is required'));
        expect(notifier.state.saveSuccess, isFalse);
      });

      test('handles database error during update', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
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

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        await notifier.updateProfile(
          babyProfileId: 'baby_1',
          name: 'Baby Jane Smith',
        );

        expect(notifier.state.isSaving, isFalse);
        expect(notifier.state.saveError, contains('Update failed'));
        expect(notifier.state.saveSuccess, isFalse);
      });
    });

    group('deleteProfile', () {
      test('deletes profile successfully when user is owner', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
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
            .thenAnswer((_) => FakePostgrestUpdateBuilder());

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        final result = await notifier.deleteProfile(babyProfileId: 'baby_1');

        expect(result, isTrue);
        verify(mockDatabaseService.update(any, any)).called(1);
      });

      test('does not delete when user is not owner', () async {
        final notifier = container.read(babyProfileProvider.notifier);
        final result = await notifier.deleteProfile(babyProfileId: 'baby_1');

        expect(result, isFalse);
        verifyNever(mockDatabaseService.update(any, any));
      });

      test('handles database error during deletion', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
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

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        final result = await notifier.deleteProfile(babyProfileId: 'baby_1');

        expect(result, isFalse);
      });
    });

    group('uploadProfilePhoto', () {
      test('uploads profile photo successfully', () async {
        reset(mockStorageService);
        when(mockStorageService.uploadFile(
          filePath: anyNamed('filePath'),
          storageKey: anyNamed('storageKey'),
          bucket: anyNamed('bucket'),
        )).thenAnswer((_) async => 'uploaded-photo.jpg');

        final notifier = container.read(babyProfileProvider.notifier);

        final result = await notifier.uploadProfilePhoto(
          babyProfileId: 'baby_1',
          filePath: '/path/to/photo.jpg',
        );

        expect(result, isNotNull);
        expect(result, contains('uploaded-photo.jpg'));
      });

      test('handles upload error gracefully', () async {
        reset(mockStorageService);
        when(mockStorageService.uploadFile(
          filePath: anyNamed('filePath'),
          storageKey: anyNamed('storageKey'),
          bucket: anyNamed('bucket'),
        )).thenThrow(Exception('Upload failed'));

        final notifier = container.read(babyProfileProvider.notifier);

        final result = await notifier.uploadProfilePhoto(
          babyProfileId: 'baby_1',
          filePath: '/path/to/photo.jpg',
        );

        expect(result, isNull);
      });
    });

    group('removeFollower', () {
      test('removes follower successfully when user is owner', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
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
            .thenAnswer((_) => FakePostgrestDeleteBuilder());

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        final result = await notifier.removeFollower(
          babyProfileId: 'baby_1',
          membershipId: 'membership_1',
        );

        expect(result, isTrue);
        verify(mockDatabaseService.delete(any)).called(1);
      });

      test('does not remove follower when user is not owner', () async {
        final notifier = container.read(babyProfileProvider.notifier);
        final result = await notifier.removeFollower(
          babyProfileId: 'baby_1',
          membershipId: 'membership_1',
        );

        expect(result, isFalse);
        verifyNever(mockDatabaseService.delete(any));
      });

      test('handles database error during removal', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
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

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        final result = await notifier.removeFollower(
          babyProfileId: 'baby_1',
          membershipId: 'membership_1',
        );

        expect(result, isFalse);
      });
    });

    group('refresh', () {
      test('refreshes profile with force refresh', () async {
        reset(mockCacheService);
        reset(mockDatabaseService);
        when(mockCacheService.isInitialized).thenReturn(true);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async {});
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        final notifier = container.read(babyProfileProvider.notifier);
        var callCount = 0;
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) {
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

        await notifier.loadProfile(
          babyProfileId: 'baby_1',
          currentUserId: 'user_1',
        );

        final initialLoadCount =
            verify(mockDatabaseService.select(any)).callCount;

        await notifier.refresh('baby_1', 'user_1');

        expect(verify(mockDatabaseService.select(any)).callCount,
            greaterThan(initialLoadCount));
      });
    });
  });
}
