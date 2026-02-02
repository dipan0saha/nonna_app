import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/registry_item.dart';

void main() {
  group('RegistryItem', () {
    final now = DateTime.now();
    final item = RegistryItem(
      id: 'item-123',
      babyProfileId: 'baby-456',
      createdByUserId: 'user-789',
      name: 'Baby Stroller',
      description: 'Lightweight and easy to fold',
      linkUrl: 'https://store.com/stroller',
      priority: 5,
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates RegistryItem from valid JSON', () {
        final json = {
          'id': 'item-123',
          'baby_profile_id': 'baby-456',
          'created_by_user_id': 'user-789',
          'name': 'Baby Stroller',
          'description': 'Lightweight and easy to fold',
          'link_url': 'https://store.com/stroller',
          'priority': 5,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': null,
        };

        final result = RegistryItem.fromJson(json);

        expect(result.id, 'item-123');
        expect(result.babyProfileId, 'baby-456');
        expect(result.createdByUserId, 'user-789');
        expect(result.name, 'Baby Stroller');
        expect(result.description, 'Lightweight and easy to fold');
        expect(result.linkUrl, 'https://store.com/stroller');
        expect(result.priority, 5);
        expect(result.createdAt, now);
        expect(result.updatedAt, now);
        expect(result.deletedAt, null);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'item-123',
          'baby_profile_id': 'baby-456',
          'created_by_user_id': 'user-789',
          'name': 'Baby Stroller',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = RegistryItem.fromJson(json);

        expect(result.description, null);
        expect(result.linkUrl, null);
        expect(result.priority, 3); // default priority
        expect(result.deletedAt, null);
      });
    });

    group('toJson', () {
      test('converts RegistryItem to JSON', () {
        final json = item.toJson();

        expect(json['id'], 'item-123');
        expect(json['baby_profile_id'], 'baby-456');
        expect(json['created_by_user_id'], 'user-789');
        expect(json['name'], 'Baby Stroller');
        expect(json['description'], 'Lightweight and easy to fold');
        expect(json['link_url'], 'https://store.com/stroller');
        expect(json['priority'], 5);
        expect(json['created_at'], now.toIso8601String());
        expect(json['updated_at'], now.toIso8601String());
        expect(json['deleted_at'], null);
      });
    });

    group('validate', () {
      test('returns null for valid item', () {
        expect(item.validate(), null);
      });

      test('returns error for empty name', () {
        final invalidItem = item.copyWith(name: '');
        expect(invalidItem.validate(), 'Registry item name is required');
      });

      test('returns error for whitespace-only name', () {
        final invalidItem = item.copyWith(name: '   ');
        expect(invalidItem.validate(), 'Registry item name is required');
      });

      test('returns error for name exceeding 200 characters', () {
        final invalidItem = item.copyWith(name: 'a' * 201);
        expect(
          invalidItem.validate(),
          'Registry item name must be 200 characters or less',
        );
      });

      test('returns error for priority less than 1', () {
        final invalidItem = item.copyWith(priority: 0);
        expect(invalidItem.validate(), 'Priority must be between 1 and 5');
      });

      test('returns error for priority greater than 5', () {
        final invalidItem = item.copyWith(priority: 6);
        expect(invalidItem.validate(), 'Priority must be between 1 and 5');
      });

      test('returns error for description exceeding 1000 characters', () {
        final invalidItem = item.copyWith(description: 'a' * 1001);
        expect(
          invalidItem.validate(),
          'Description must be 1000 characters or less',
        );
      });

      test('returns error for linkUrl exceeding 2000 characters', () {
        final invalidItem = item.copyWith(linkUrl: 'a' * 2001);
        expect(
          invalidItem.validate(),
          'Link URL must be 2000 characters or less',
        );
      });
    });

    group('getters', () {
      test('isDeleted returns false when deletedAt is null', () {
        expect(item.isDeleted, false);
      });

      test('isDeleted returns true when deletedAt is set', () {
        final deletedItem = item.copyWith(deletedAt: now);
        expect(deletedItem.isDeleted, true);
      });

      test('isHighPriority returns true for priority 4 and 5', () {
        final highPriority4 = item.copyWith(priority: 4);
        final highPriority5 = item.copyWith(priority: 5);
        expect(highPriority4.isHighPriority, true);
        expect(highPriority5.isHighPriority, true);
      });

      test('isHighPriority returns false for priority 3 and below', () {
        final mediumPriority = item.copyWith(priority: 3);
        expect(mediumPriority.isHighPriority, false);
      });

      test('isLowPriority returns true for priority 1 and 2', () {
        final lowPriority1 = item.copyWith(priority: 1);
        final lowPriority2 = item.copyWith(priority: 2);
        expect(lowPriority1.isLowPriority, true);
        expect(lowPriority2.isLowPriority, true);
      });

      test('isLowPriority returns false for priority 3 and above', () {
        final mediumPriority = item.copyWith(priority: 3);
        expect(mediumPriority.isLowPriority, false);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = item.copyWith(
          name: 'Baby Crib',
          priority: 4,
        );

        expect(updated.id, item.id);
        expect(updated.babyProfileId, item.babyProfileId);
        expect(updated.createdByUserId, item.createdByUserId);
        expect(updated.name, 'Baby Crib');
        expect(updated.priority, 4);
        expect(updated.description, item.description);
      });

      test('maintains original values when no updates provided', () {
        final copy = item.copyWith();
        expect(copy, item);
      });
    });

    group('equality', () {
      test('equal items are equal', () {
        final item1 = RegistryItem(
          id: 'item-123',
          babyProfileId: 'baby-456',
          createdByUserId: 'user-789',
          name: 'Baby Stroller',
          priority: 5,
          createdAt: now,
          updatedAt: now,
        );
        final item2 = RegistryItem(
          id: 'item-123',
          babyProfileId: 'baby-456',
          createdByUserId: 'user-789',
          name: 'Baby Stroller',
          priority: 5,
          createdAt: now,
          updatedAt: now,
        );

        expect(item1, item2);
        expect(item1.hashCode, item2.hashCode);
      });

      test('different items are not equal', () {
        final item1 = RegistryItem(
          id: 'item-123',
          babyProfileId: 'baby-456',
          createdByUserId: 'user-789',
          name: 'Baby Stroller',
          priority: 5,
          createdAt: now,
          updatedAt: now,
        );
        final item2 = RegistryItem(
          id: 'item-456',
          babyProfileId: 'baby-789',
          createdByUserId: 'user-123',
          name: 'Baby Crib',
          priority: 3,
          createdAt: now,
          updatedAt: now,
        );

        expect(item1, isNot(item2));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = item.toString();

        expect(str, contains('RegistryItem'));
        expect(str, contains('item-123'));
        expect(str, contains('Baby Stroller'));
        expect(str, contains('priority: 5'));
      });
    });
  });
}
