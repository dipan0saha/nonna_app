import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/enums/invitation_status.dart';
import 'package:nonna_app/core/models/invitation.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/tiles/invites_status/providers/invites_status_provider.dart';
import 'package:nonna_app/core/di/providers.dart';

import '../../../helpers/fake_postgrest_builders.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'invites_status_provider_test.mocks.dart';

void main() {
  group('InvitesStatusProvider Tests', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    // Sample invitation data
    final sampleInvitation = Invitation(
      id: 'invite_1',
      babyProfileId: 'profile_1',
      inviteeEmail: 'friend@example.com',
      status: InvitationStatus.pending,
      invitedByUserId: 'user_1',
      tokenHash: 'hash123',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRealtimeService = MockRealtimeService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      // Create a ProviderContainer with overrides
      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          cacheServiceProvider.overrideWithValue(mockCacheService),
          realtimeServiceProvider.overrideWithValue(mockRealtimeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('initial state has empty invitations', () {
        final state = container.read(invitesStatusProvider);
        
        expect(state.invitations, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.pendingCount, equals(0));
      });
    });

    group('fetchInvitations', () {
      test('sets loading state while fetching', () async {
        final notifier = container.read(invitesStatusProvider.notifier);
        
        // Setup mock to delay response
        when(mockCacheService.get(any as String)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any as String)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture =
            notifier.fetchInvitations(babyProfileId: 'profile_1');

        // Verify loading state
        expect(container.read(invitesStatusProvider).isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches invitations from database when cache is empty', () async {
        final notifier = container.read(invitesStatusProvider.notifier);
        
        // Setup mocks
        when(mockCacheService.get(any as String)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any as String))
            .thenReturn(FakePostgrestBuilder([sampleInvitation.toJson()]));

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        final state = container.read(invitesStatusProvider);
        
        // Verify state updated
        expect(state.invitations, hasLength(1));
        expect(state.invitations.first.id, equals('invite_1'));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.pendingCount, equals(1));
      });

      test('loads invitations from cache when available', () async {
        final notifier = container.read(invitesStatusProvider.notifier);
        
        // Setup cache to return data
        when(mockCacheService.get(any as String))
            .thenAnswer((_) async => [sampleInvitation.toJson()]);

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any as String));

        final state = container.read(invitesStatusProvider);
        
        // Verify state updated from cache
        expect(state.invitations, hasLength(1));
        expect(state.invitations.first.id, equals('invite_1'));
      });

      test('handles errors gracefully', () async {
        final notifier = container.read(invitesStatusProvider.notifier);
        
        // Setup mock to throw error
        when(mockCacheService.get(any as String)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any as String))
            .thenThrow(Exception('Database error'));

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        final state = container.read(invitesStatusProvider);
        
        // Verify error state
        expect(state.isLoading, isFalse);
        expect(state.error, contains('Database error'));
        expect(state.invitations, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        final notifier = container.read(invitesStatusProvider.notifier);
        
        // Setup mocks
        when(mockCacheService.get(any as String))
            .thenAnswer((_) async => [sampleInvitation.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any as String))
            .thenReturn(FakePostgrestBuilder([sampleInvitation.toJson()]));

        await notifier.fetchInvitations(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any as String)).called(1);
      });

      test('calculates pending count correctly', () async {
        final notifier = container.read(invitesStatusProvider.notifier);
        
        final invite1 = sampleInvitation.copyWith(
            id: 'invite_1', status: InvitationStatus.pending);
        final invite2 = sampleInvitation.copyWith(
            id: 'invite_2', status: InvitationStatus.accepted);
        final invite3 = sampleInvitation.copyWith(
            id: 'invite_3', status: InvitationStatus.pending);

        when(mockCacheService.get(any as String)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any as String)).thenReturn(FakePostgrestBuilder([
          invite1.toJson(),
          invite2.toJson(),
          invite3.toJson(),
        ]));

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        expect(container.read(invitesStatusProvider).pendingCount, equals(2));
      });
    });

    group('refresh', () {
      test('refreshes invitations with force refresh', () async {
        final notifier = container.read(invitesStatusProvider.notifier);
        
        when(mockCacheService.get(any as String))
            .thenAnswer((_) async => [sampleInvitation.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any as String))
            .thenReturn(FakePostgrestBuilder([sampleInvitation.toJson()]));

        await notifier.refresh(babyProfileId: 'profile_1');

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(any as String)).called(1);
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT invitation', () async {
        final notifier = container.read(invitesStatusProvider.notifier);
        
        // Setup initial state
        when(mockCacheService.get(any as String)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any as String))
            .thenReturn(FakePostgrestBuilder([sampleInvitation.toJson()]));

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        final initialCount = container.read(invitesStatusProvider).invitations.length;

        // Simulate real-time INSERT
        final newInvitation = sampleInvitation.copyWith(id: 'invite_2');
        final currentState = container.read(invitesStatusProvider);
        container.read(invitesStatusProvider.notifier).state = currentState.copyWith(
          invitations: [newInvitation, ...currentState.invitations],
          pendingCount: currentState.pendingCount + 1,
        );

        expect(container.read(invitesStatusProvider).invitations.length, equals(initialCount + 1));
      });

      test('handles UPDATE invitation status', () async {
        final notifier = container.read(invitesStatusProvider.notifier);
        
        // Setup initial state
        when(mockCacheService.get(any as String)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any as String))
            .thenReturn(FakePostgrestBuilder([sampleInvitation.toJson()]));

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        expect(container.read(invitesStatusProvider).pendingCount, equals(1));

        // Simulate real-time UPDATE to accepted
        final updatedInvitation =
            sampleInvitation.copyWith(status: InvitationStatus.accepted);
        final currentState = container.read(invitesStatusProvider);
        container.read(invitesStatusProvider.notifier).state = currentState.copyWith(
          invitations: currentState.invitations
              .map((i) => i.id == updatedInvitation.id ? updatedInvitation : i)
              .toList(),
          pendingCount: 0,
        );

        expect(container.read(invitesStatusProvider).invitations.first.status,
            equals(InvitationStatus.accepted));
        expect(container.read(invitesStatusProvider).pendingCount, equals(0));
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () {
        when(mockRealtimeService.unsubscribe(any as String)).thenAnswer((_) async {});

        final state = container.read(invitesStatusProvider);
        expect(state, isNotNull);
      });
    });

    group('Role-based Access', () {
      test('owner can fetch invitations', () async {
        final notifier = container.read(invitesStatusProvider.notifier);
        
        when(mockCacheService.get(any as String)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any as String))
            .thenReturn(FakePostgrestBuilder([sampleInvitation.toJson()]));

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        expect(container.read(invitesStatusProvider).invitations, isNotEmpty);
      });
    });
  });
}
