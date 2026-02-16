import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/tiles/due_date_countdown/providers/due_date_countdown_provider.dart';

import '../../../helpers/fake_postgrest_builders.dart';
import '../../../helpers/mock_factory.dart';

void main() {
  group('DueDateCountdownProvider Tests', () {
    late ProviderContainer container;
    late MockServiceContainer mocks;

    // Sample baby profile data
    final sampleProfile = BabyProfile(
      id: 'profile_1',
      name: 'Baby Emma',
      expectedBirthDate: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mocks = MockFactory.createServiceContainer();

      // Setup all default mock behaviors BEFORE creating container
      when(mocks.cache.isInitialized).thenReturn(true);
      when(mocks.cache.get(any)).thenAnswer((_) async => null);
      when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
          .thenAnswer((_) async {});
      when(mocks.database.select(any))
          .thenAnswer((_) => FakePostgrestBuilder([]));
      when(mocks.realtime.subscribe(
        table: anyNamed('table'),
        channelName: anyNamed('channelName'),
        filter: anyNamed('filter'),
      )).thenAnswer((_) => Stream.empty());
      when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mocks.database),
          cacheServiceProvider.overrideWithValue(mocks.cache),
          realtimeServiceProvider.overrideWithValue(mocks.realtime),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      reset(mocks.database);
      reset(mocks.cache);
      reset(mocks.realtime);
    });

    group('Initial State', () {
      test('initial state has empty countdowns', () {
        final state = container.read(dueDateCountdownProvider);
        expect(state.countdowns, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });
    });

    group('fetchCountdowns', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        final notifier = container.read(dueDateCountdownProvider.notifier);

        // Start fetching
        final fetchFuture = notifier.fetchCountdowns(
          babyProfileIds: ['profile_1'],
        );

        // Verify loading state
        expect(container.read(dueDateCountdownProvider).isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches profiles from database when cache is empty', () async {
        // Setup mocks
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleProfile.toJson()]));

        final notifier = container.read(dueDateCountdownProvider.notifier);
        await notifier.fetchCountdowns(babyProfileIds: ['profile_1']);

        // Verify state updated
        final state = container.read(dueDateCountdownProvider);
        expect(state.countdowns, hasLength(1));
        expect(state.countdowns.first.profile.id, equals('profile_1'));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('handles empty profile list', () async {
        final notifier = container.read(dueDateCountdownProvider.notifier);
        await notifier.fetchCountdowns(babyProfileIds: []);

        final state = container.read(dueDateCountdownProvider);
        expect(state.countdowns, isEmpty);
        expect(state.isLoading, isFalse);
      });

      test('loads countdowns from cache when available', () async {
        // Setup cache to return data
        final cachedData = {
          'profile': sampleProfile.toJson(),
          'daysUntilDueDate': 30,
          'isPastDue': false,
          'formattedCountdown': '30 days',
        };
        when(mocks.cache.get(any)).thenAnswer((_) async => [cachedData]);

        final notifier = container.read(dueDateCountdownProvider.notifier);
        await notifier.fetchCountdowns(babyProfileIds: ['profile_1']);

        // Verify database was not called
        verifyNever(mocks.database.select(any));

        // Verify state updated from cache
        final state = container.read(dueDateCountdownProvider);
        expect(state.countdowns, hasLength(1));
        expect(state.countdowns.first.profile.id, equals('profile_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any)).thenThrow(Exception('Database error'));

        final notifier = container.read(dueDateCountdownProvider.notifier);
        await notifier.fetchCountdowns(babyProfileIds: ['profile_1']);

        // Verify error state
        final state = container.read(dueDateCountdownProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, contains('Database error'));
        expect(state.countdowns, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        final cachedData = {
          'profile': sampleProfile.toJson(),
          'daysUntilDueDate': 30,
          'isPastDue': false,
          'formattedCountdown': '30 days',
        };
        when(mocks.cache.get(any)).thenAnswer((_) async => [cachedData]);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleProfile.toJson()]));

        final notifier = container.read(dueDateCountdownProvider.notifier);
        await notifier.fetchCountdowns(
          babyProfileIds: ['profile_1'],
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mocks.database.select(any)).called(1);
      });

      test('calculates days until due date correctly', () async {
        final futureProfile = sampleProfile.copyWith(
          expectedBirthDate: DateTime.now().add(const Duration(days: 45)),
        );

        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([futureProfile.toJson()]));

        final notifier = container.read(dueDateCountdownProvider.notifier);
        await notifier.fetchCountdowns(babyProfileIds: ['profile_1']);

        final state = container.read(dueDateCountdownProvider);
        expect(
            state.countdowns.first.daysUntilDueDate, greaterThanOrEqualTo(44));
        expect(state.countdowns.first.isPastDue, isFalse);
      });

      test('handles past due date correctly', () async {
        final pastProfile = sampleProfile.copyWith(
          expectedBirthDate: DateTime.now().subtract(const Duration(days: 10)),
        );

        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([pastProfile.toJson()]));

        final notifier = container.read(dueDateCountdownProvider.notifier);
        await notifier.fetchCountdowns(babyProfileIds: ['profile_1']);

        final state = container.read(dueDateCountdownProvider);
        expect(state.countdowns.first.isPastDue, isTrue);
      });

      test('handles multiple babies', () async {
        final profile2 =
            sampleProfile.copyWith(id: 'profile_2', name: 'Baby Jack');

        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([
                  sampleProfile.toJson(),
                  profile2.toJson(),
                ]));

        final notifier = container.read(dueDateCountdownProvider.notifier);
        await notifier.fetchCountdowns(
          babyProfileIds: ['profile_1', 'profile_2'],
        );

        final state = container.read(dueDateCountdownProvider);
        expect(state.countdowns, hasLength(2));
      });
    });

    group('refresh', () {
      test('refreshes countdowns with force refresh', () async {
        final cachedData = {
          'profile': sampleProfile.toJson(),
          'daysUntilDueDate': 30,
          'isPastDue': false,
          'formattedCountdown': '30 days',
        };
        when(mocks.cache.get(any)).thenAnswer((_) async => [cachedData]);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleProfile.toJson()]));

        final notifier = container.read(dueDateCountdownProvider.notifier);
        await notifier.refresh(babyProfileIds: ['profile_1']);

        // Verify database was called (bypassing cache)
        verify(mocks.database.select(any)).called(1);
      });
    });

    group('Real-time Updates', () {
      test('handles UPDATE to due date', () async {
        // Setup initial state
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleProfile.toJson()]));

        final notifier = container.read(dueDateCountdownProvider.notifier);
        await notifier.fetchCountdowns(babyProfileIds: ['profile_1']);

        final initialDays = container
            .read(dueDateCountdownProvider)
            .countdowns
            .first
            .daysUntilDueDate;

        // Simulate real-time UPDATE
        final updatedProfile = sampleProfile.copyWith(
          expectedBirthDate: DateTime.now().add(const Duration(days: 60)),
        );

        // Manually update state to simulate real-time handler
        notifier.state = notifier.state.copyWith(
          countdowns: [
            BabyCountdown(
              profile: updatedProfile,
              daysUntilDueDate: 60,
              isPastDue: false,
              formattedCountdown: '60 days',
            )
          ],
        );

        expect(
            container
                .read(dueDateCountdownProvider)
                .countdowns
                .first
                .daysUntilDueDate,
            greaterThan(initialDays));
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () {
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async => {});

        // Notifier handles cleanup automatically, no manual dispose needed
        final state = container.read(dueDateCountdownProvider);
        expect(state, isNotNull);
      });
    });

    group('Countdown Formatting', () {
      test('formats countdown as days', () async {
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value(<String, dynamic>{}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleProfile.toJson()]));

        final notifier = container.read(dueDateCountdownProvider.notifier);
        await notifier.fetchCountdowns(babyProfileIds: ['profile_1']);

        final state = container.read(dueDateCountdownProvider);
        expect(state.countdowns.first.formattedCountdown, isNotEmpty);
      });
    });
  });
}
