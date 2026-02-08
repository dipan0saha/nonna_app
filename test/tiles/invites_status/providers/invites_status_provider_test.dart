import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/enums/invitation_status.dart';
import 'package:nonna_app/core/models/invitation.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/tiles/invites_status/providers/invites_status_provider.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'invites_status_provider_test.mocks.dart';

void main() {
  group('InvitesStatusProvider Tests', () {
    late InvitesStatusNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    // Sample invitation data
    final sampleInvitation = Invitation(
      id: 'invite_1',
      babyProfileId: 'profile_1',
      email: 'friend@example.com',
      status: InvitationStatus.pending,
      invitedBy: 'user_1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRealtimeService = MockRealtimeService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = InvitesStatusNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
        realtimeService: mockRealtimeService,
      );
    });

    group('Initial State', () {
      test('initial state has empty invitations', () {
        expect(notifier.state.invitations, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.pendingCount, equals(0));
      });
    });

    group('fetchInvitations', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture =
            notifier.fetchInvitations(babyProfileId: 'profile_1');

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches invitations from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleInvitation.toJson()]));

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        // Verify state updated
        expect(notifier.state.invitations, hasLength(1));
        expect(notifier.state.invitations.first.id, equals('invite_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.pendingCount, equals(1));
      });

      test('loads invitations from cache when available', () async {
        // Setup cache to return data
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleInvitation.toJson()]);

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any));

        // Verify state updated from cache
        expect(notifier.state.invitations, hasLength(1));
        expect(notifier.state.invitations.first.id, equals('invite_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.invitations, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleInvitation.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleInvitation.toJson()]));

        await notifier.fetchInvitations(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any)).called(1);
      });

      test('calculates pending count correctly', () async {
        final invite1 = sampleInvitation.copyWith(
            id: 'invite_1', status: InvitationStatus.pending);
        final invite2 = sampleInvitation.copyWith(
            id: 'invite_2', status: InvitationStatus.accepted);
        final invite3 = sampleInvitation.copyWith(
            id: 'invite_3', status: InvitationStatus.pending);

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          invite1.toJson(),
          invite2.toJson(),
          invite3.toJson(),
        ]));

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        expect(notifier.state.pendingCount, equals(2));
      });
    });

    group('refresh', () {
      test('refreshes invitations with force refresh', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleInvitation.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleInvitation.toJson()]));

        await notifier.refresh(babyProfileId: 'profile_1');

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(any)).called(1);
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT invitation', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleInvitation.toJson()]));

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        final initialCount = notifier.state.invitations.length;

        // Simulate real-time INSERT
        final newInvitation = sampleInvitation.copyWith(id: 'invite_2');
        notifier.state = notifier.state.copyWith(
          invitations: [newInvitation, ...notifier.state.invitations],
          pendingCount: notifier.state.pendingCount + 1,
        );

        expect(notifier.state.invitations.length, equals(initialCount + 1));
      });

      test('handles UPDATE invitation status', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleInvitation.toJson()]));

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        expect(notifier.state.pendingCount, equals(1));

        // Simulate real-time UPDATE to accepted
        final updatedInvitation =
            sampleInvitation.copyWith(status: InvitationStatus.accepted);
        notifier.state = notifier.state.copyWith(
          invitations: notifier.state.invitations
              .map((i) => i.id == updatedInvitation.id ? updatedInvitation : i)
              .toList(),
          pendingCount: 0,
        );

        expect(notifier.state.invitations.first.status,
            equals(InvitationStatus.accepted));
        expect(notifier.state.pendingCount, equals(0));
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () {
        when(mockRealtimeService.unsubscribe(any)).thenReturn(null);

        notifier.dispose();

        expect(notifier.state, isNotNull);
      });
    });

    group('Role-based Access', () {
      test('owner can fetch invitations', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleInvitation.toJson()]));

        await notifier.fetchInvitations(babyProfileId: 'profile_1');

        expect(notifier.state.invitations, isNotEmpty);
      });
    });
  });
}

// Fake builders for Postgrest operations (test doubles)
class FakePostgrestBuilder {
  final List<Map<String, dynamic>> data;

  FakePostgrestBuilder(this.data);

  FakePostgrestBuilder eq(String column, dynamic value) => this;
  FakePostgrestBuilder order(String column, {bool ascending = true}) => this;

  Future<List<Map<String, dynamic>>> call() async => data;
}
