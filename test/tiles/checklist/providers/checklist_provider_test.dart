import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/tiles/checklist/providers/checklist_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/di/providers.dart';

import '../../../mocks/mock_services.mocks.dart';
import '../../../helpers/mock_factory.dart';

void main() {
  group('ChecklistProvider Tests', () {
    late ChecklistNotifier notifier;
    late ProviderContainer container;
    late MockCacheService mockCacheService;

    setUp(() {
      mockCacheService = MockFactory.createCacheService();

      container = ProviderContainer(
        overrides: [
          cacheServiceProvider.overrideWithValue(mockCacheService),
        ],
      );

      notifier = container.read(checklistProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('initial state has empty items and zero progress', () {
        expect(notifier.state.items, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.completedCount, equals(0));
        expect(notifier.state.progressPercentage, equals(0.0));
      });
    });

    group('loadChecklist', () {
      test('sets loading state while loading', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return null;
        });

        // Start loading
        final loadFuture = notifier.loadChecklist(babyProfileId: 'profile_1');

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await loadFuture;
      });

      test('loads default checklist when cache is empty', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);

        await notifier.loadChecklist(babyProfileId: 'profile_1');

        // Verify state updated with default items
        expect(notifier.state.items, isNotEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.completedCount, equals(0));
        expect(notifier.state.progressPercentage, equals(0.0));
      });

      test('loads checklist from cache when available', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        final cachedItems = [
          {
            'id': 'setup_profile',
            'title': 'Set up baby profile',
            'description': 'Add your baby\'s name, due date, and profile photo',
            'isCompleted': true,
            'order': 1,
          },
          {
            'id': 'create_registry',
            'title': 'Create registry',
            'description': 'Add items you need for your baby',
            'isCompleted': false,
            'order': 2,
          },
        ];

        when(mockCacheService.get(any)).thenAnswer((_) async => cachedItems);

        await notifier.loadChecklist(babyProfileId: 'profile_1');

        // Verify state updated from cache
        expect(notifier.state.items, hasLength(2));
        expect(notifier.state.completedCount, equals(1));
        expect(notifier.state.progressPercentage, equals(50.0));
      });

      test('handles errors gracefully', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenThrow(Exception('Cache error'));

        await notifier.loadChecklist(babyProfileId: 'profile_1');

        // Verify error state - should fall back to default items
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.items, isNotEmpty); // Default items loaded
      });

      test('calculates progress percentage correctly', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        final cachedItems = List.generate(
          6,
          (i) => {
            'id': 'item_$i',
            'title': 'Task $i',
            'description': 'Description $i',
            'isCompleted': i < 3, // First 3 are completed
            'order': i + 1,
          },
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => cachedItems);

        await notifier.loadChecklist(babyProfileId: 'profile_1');

        expect(notifier.state.completedCount, equals(3));
        expect(notifier.state.progressPercentage, equals(50.0));
      });
    });

    group('toggleItem', () {
      test('toggles item from incomplete to complete', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        await notifier.loadChecklist(babyProfileId: 'profile_1');

        final initialCompletedCount = notifier.state.completedCount;
        final itemId = notifier.state.items.first.id;

        await notifier.toggleItem(
          itemId: itemId,
          babyProfileId: 'profile_1',
        );

        // Verify state updated
        expect(
            notifier.state.completedCount, equals(initialCompletedCount + 1));
        expect(
          notifier.state.items
              .firstWhere((item) => item.id == itemId)
              .isCompleted,
          isTrue,
        );
      });

      test('toggles item from complete to incomplete', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup initial state with completed item
        final cachedItems = [
          {
            'id': 'setup_profile',
            'title': 'Set up baby profile',
            'description': 'Add your baby\'s name, due date, and profile photo',
            'isCompleted': true,
            'order': 1,
          },
        ];

        when(mockCacheService.get(any)).thenAnswer((_) async => cachedItems);
        await notifier.loadChecklist(babyProfileId: 'profile_1');

        expect(notifier.state.completedCount, equals(1));

        await notifier.toggleItem(
          itemId: 'setup_profile',
          babyProfileId: 'profile_1',
        );

        // Verify state updated
        expect(notifier.state.completedCount, equals(0));
        expect(
          notifier.state.items
              .firstWhere((item) => item.id == 'setup_profile')
              .isCompleted,
          isFalse,
        );
      });

      test('updates cache after toggling', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        await notifier.loadChecklist(babyProfileId: 'profile_1');

        final itemId = notifier.state.items.first.id;

        await notifier.toggleItem(
          itemId: itemId,
          babyProfileId: 'profile_1',
        );

        // Verify cache was updated
        verify(mockCacheService.put(any, any)).called(greaterThanOrEqualTo(1));
      });

      test('updates progress percentage after toggle', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        await notifier.loadChecklist(babyProfileId: 'profile_1');

        final initialProgress = notifier.state.progressPercentage;
        final itemId = notifier.state.items.first.id;

        await notifier.toggleItem(
          itemId: itemId,
          babyProfileId: 'profile_1',
        );

        expect(notifier.state.progressPercentage, greaterThan(initialProgress));
      });
    });

    group('resetChecklist', () {
      test('resets checklist to default state', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup initial state with completed items
        final cachedItems = [
          {
            'id': 'setup_profile',
            'title': 'Set up baby profile',
            'description': 'Add your baby\'s name, due date, and profile photo',
            'isCompleted': true,
            'order': 1,
          },
        ];

        when(mockCacheService.get(any)).thenAnswer((_) async => cachedItems);
        await notifier.loadChecklist(babyProfileId: 'profile_1');

        expect(notifier.state.completedCount, greaterThan(0));

        await notifier.resetChecklist(babyProfileId: 'profile_1');

        // Verify state reset
        expect(notifier.state.completedCount, equals(0));
        expect(notifier.state.progressPercentage, equals(0.0));
        for (final item in notifier.state.items) {
          expect(item.isCompleted, isFalse);
        }
      });

      test('saves reset state to cache', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        await notifier.loadChecklist(babyProfileId: 'profile_1');

        await notifier.resetChecklist(babyProfileId: 'profile_1');

        // Verify cache was updated
        verify(mockCacheService.put(any, any)).called(greaterThanOrEqualTo(1));
      });
    });

    group('getIncompleteItems', () {
      test('returns only incomplete items', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        final cachedItems = [
          {
            'id': 'item_1',
            'title': 'Task 1',
            'description': 'Description 1',
            'isCompleted': true,
            'order': 1,
          },
          {
            'id': 'item_2',
            'title': 'Task 2',
            'description': 'Description 2',
            'isCompleted': false,
            'order': 2,
          },
          {
            'id': 'item_3',
            'title': 'Task 3',
            'description': 'Description 3',
            'isCompleted': false,
            'order': 3,
          },
        ];

        when(mockCacheService.get(any)).thenAnswer((_) async => cachedItems);
        await notifier.loadChecklist(babyProfileId: 'profile_1');

        final incompleteItems = notifier.getIncompleteItems();

        expect(incompleteItems, hasLength(2));
        for (final item in incompleteItems) {
          expect(item.isCompleted, isFalse);
        }
      });
    });

    group('getCompletedItems', () {
      test('returns only completed items', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        final cachedItems = [
          {
            'id': 'item_1',
            'title': 'Task 1',
            'description': 'Description 1',
            'isCompleted': true,
            'order': 1,
          },
          {
            'id': 'item_2',
            'title': 'Task 2',
            'description': 'Description 2',
            'isCompleted': false,
            'order': 2,
          },
          {
            'id': 'item_3',
            'title': 'Task 3',
            'description': 'Description 3',
            'isCompleted': true,
            'order': 3,
          },
        ];

        when(mockCacheService.get(any)).thenAnswer((_) async => cachedItems);
        await notifier.loadChecklist(babyProfileId: 'profile_1');

        final completedItems = notifier.getCompletedItems();

        expect(completedItems, hasLength(2));
        for (final item in completedItems) {
          expect(item.isCompleted, isTrue);
        }
      });
    });

    group('Default Checklist Items', () {
      test('has expected default items', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        when(mockCacheService.get(any)).thenAnswer((_) async => null);

        await notifier.loadChecklist(babyProfileId: 'profile_1');

        // Should have standard onboarding items
        expect(notifier.state.items.length, greaterThanOrEqualTo(5));
        expect(
          notifier.state.items.any((item) => item.id == 'setup_profile'),
          isTrue,
        );
        expect(
          notifier.state.items.any((item) => item.id == 'create_registry'),
          isTrue,
        );
      });

      test('default items are in correct order', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        when(mockCacheService.get(any)).thenAnswer((_) async => null);

        await notifier.loadChecklist(babyProfileId: 'profile_1');

        // Verify items are sorted by order
        for (int i = 0; i < notifier.state.items.length - 1; i++) {
          expect(
            notifier.state.items[i].order,
            lessThanOrEqualTo(notifier.state.items[i + 1].order),
          );
        }
      });
    });
  });
}
