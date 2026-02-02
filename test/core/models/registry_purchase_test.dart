import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/registry_purchase.dart';

void main() {
  group('RegistryPurchase', () {
    final now = DateTime.now();
    final purchasedAt = now.subtract(const Duration(days: 1));
    final purchase = RegistryPurchase(
      id: 'purchase-123',
      registryItemId: 'item-456',
      purchasedByUserId: 'user-789',
      purchasedAt: purchasedAt,
      note: 'Bought at the baby shower',
      createdAt: now,
    );

    group('fromJson', () {
      test('creates RegistryPurchase from valid JSON', () {
        final json = {
          'id': 'purchase-123',
          'registry_item_id': 'item-456',
          'purchased_by_user_id': 'user-789',
          'purchased_at': purchasedAt.toIso8601String(),
          'note': 'Bought at the baby shower',
          'created_at': now.toIso8601String(),
        };

        final result = RegistryPurchase.fromJson(json);

        expect(result.id, 'purchase-123');
        expect(result.registryItemId, 'item-456');
        expect(result.purchasedByUserId, 'user-789');
        expect(result.purchasedAt, purchasedAt);
        expect(result.note, 'Bought at the baby shower');
        expect(result.createdAt, now);
      });

      test('handles null note', () {
        final json = {
          'id': 'purchase-123',
          'registry_item_id': 'item-456',
          'purchased_by_user_id': 'user-789',
          'purchased_at': purchasedAt.toIso8601String(),
          'note': null,
          'created_at': now.toIso8601String(),
        };

        final result = RegistryPurchase.fromJson(json);

        expect(result.note, null);
      });
    });

    group('toJson', () {
      test('converts RegistryPurchase to JSON', () {
        final json = purchase.toJson();

        expect(json['id'], 'purchase-123');
        expect(json['registry_item_id'], 'item-456');
        expect(json['purchased_by_user_id'], 'user-789');
        expect(json['purchased_at'], purchasedAt.toIso8601String());
        expect(json['note'], 'Bought at the baby shower');
        expect(json['created_at'], now.toIso8601String());
      });
    });

    group('validate', () {
      test('returns null for valid purchase', () {
        expect(purchase.validate(), null);
      });

      test('returns error for purchase date in the future', () {
        final invalidPurchase = purchase.copyWith(
          purchasedAt: now.add(const Duration(days: 1)),
        );
        expect(
          invalidPurchase.validate(),
          'Purchase date cannot be in the future',
        );
      });

      test('returns error for note exceeding 500 characters', () {
        final invalidPurchase = purchase.copyWith(note: 'a' * 501);
        expect(
          invalidPurchase.validate(),
          'Purchase note must be 500 characters or less',
        );
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = purchase.copyWith(
          note: 'Updated note',
        );

        expect(updated.id, purchase.id);
        expect(updated.registryItemId, purchase.registryItemId);
        expect(updated.purchasedByUserId, purchase.purchasedByUserId);
        expect(updated.purchasedAt, purchase.purchasedAt);
        expect(updated.note, 'Updated note');
        expect(updated.createdAt, purchase.createdAt);
      });

      test('maintains original values when no updates provided', () {
        final copy = purchase.copyWith();
        expect(copy, purchase);
      });
    });

    group('equality', () {
      test('equal purchases are equal', () {
        final purchase1 = RegistryPurchase(
          id: 'purchase-123',
          registryItemId: 'item-456',
          purchasedByUserId: 'user-789',
          purchasedAt: purchasedAt,
          note: 'Bought at the baby shower',
          createdAt: now,
        );
        final purchase2 = RegistryPurchase(
          id: 'purchase-123',
          registryItemId: 'item-456',
          purchasedByUserId: 'user-789',
          purchasedAt: purchasedAt,
          note: 'Bought at the baby shower',
          createdAt: now,
        );

        expect(purchase1, purchase2);
        expect(purchase1.hashCode, purchase2.hashCode);
      });

      test('different purchases are not equal', () {
        final purchase1 = RegistryPurchase(
          id: 'purchase-123',
          registryItemId: 'item-456',
          purchasedByUserId: 'user-789',
          purchasedAt: purchasedAt,
          createdAt: now,
        );
        final purchase2 = RegistryPurchase(
          id: 'purchase-456',
          registryItemId: 'item-789',
          purchasedByUserId: 'user-123',
          purchasedAt: now,
          createdAt: now,
        );

        expect(purchase1, isNot(purchase2));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = purchase.toString();

        expect(str, contains('RegistryPurchase'));
        expect(str, contains('purchase-123'));
        expect(str, contains('item-456'));
      });
    });
  });
}
