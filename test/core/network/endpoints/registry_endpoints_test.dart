import 'package:flutter_test.dart';
import 'package:nonna_app/core/network/endpoints/registry_endpoints.dart';

void main() {
  group('RegistryEndpoints', () {
    const testBabyProfileId = 'baby_123';
    const testItemId = 'item_456';
    const testPurchaseId = 'purchase_789';
    const testUserId = 'user_101';
    const testCategory = 'clothing';

    group('Registry Item CRUD Operations', () {
      test('generates correct getRegistryItems endpoint', () {
        final endpoint = RegistryEndpoints.getRegistryItems(testBabyProfileId);

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('select=*'));
        expect(endpoint, contains('order=created_at.desc'));
      });

      test('generates correct getRegistryItem endpoint', () {
        final endpoint = RegistryEndpoints.getRegistryItem(testItemId);

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('id=eq.$testItemId'));
        expect(endpoint, contains('select=*'));
      });

      test('generates correct getAvailableItems endpoint', () {
        final endpoint = RegistryEndpoints.getAvailableItems(testBabyProfileId);

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is_purchased=eq.false'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=priority.desc,created_at.desc'));
      });

      test('generates correct getPurchasedItems endpoint', () {
        final endpoint = RegistryEndpoints.getPurchasedItems(testBabyProfileId);

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is_purchased=eq.true'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=purchased_at.desc'));
      });

      test('generates correct getRegistryHighlights endpoint with default limit', () {
        final endpoint = RegistryEndpoints.getRegistryHighlights(testBabyProfileId);

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is_purchased=eq.false'));
        expect(endpoint, contains('priority=gte.4'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=priority.desc'));
        expect(endpoint, contains('limit=5'));
      });

      test('generates correct getRegistryHighlights endpoint with custom limit', () {
        final endpoint = RegistryEndpoints.getRegistryHighlights(testBabyProfileId, limit: 10);

        expect(endpoint, contains('limit=10'));
      });

      test('generates correct createRegistryItem endpoint', () {
        final endpoint = RegistryEndpoints.createRegistryItem();

        expect(endpoint, equals('registry_items'));
      });

      test('generates correct updateRegistryItem endpoint', () {
        final endpoint = RegistryEndpoints.updateRegistryItem(testItemId);

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('id=eq.$testItemId'));
      });

      test('generates correct deleteRegistryItem endpoint', () {
        final endpoint = RegistryEndpoints.deleteRegistryItem(testItemId);

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('id=eq.$testItemId'));
      });
    });

    group('Registry Purchase Operations', () {
      test('generates correct getItemPurchases endpoint', () {
        final endpoint = RegistryEndpoints.getItemPurchases(testItemId);

        expect(endpoint, contains('registry_purchases'));
        expect(endpoint, contains('registry_item_id=eq.$testItemId'));
        expect(endpoint, contains('select=*'));
        expect(endpoint, contains('order=purchased_at.desc'));
      });

      test('generates correct getUserPurchases endpoint', () {
        final endpoint = RegistryEndpoints.getUserPurchases(testBabyProfileId, testUserId);

        expect(endpoint, contains('registry_purchases'));
        expect(endpoint, contains('registry_item_id.baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('purchased_by_user_id=eq.$testUserId'));
        expect(endpoint, contains('select=*,registry_item_id(*)'));
        expect(endpoint, contains('order=purchased_at.desc'));
      });

      test('generates correct getRecentPurchases endpoint with default limit', () {
        final endpoint = RegistryEndpoints.getRecentPurchases(testBabyProfileId);

        expect(endpoint, contains('registry_purchases'));
        expect(endpoint, contains('registry_item_id.baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('select=*,registry_item_id(*)'));
        expect(endpoint, contains('order=purchased_at.desc'));
        expect(endpoint, contains('limit=10'));
      });

      test('generates correct getRecentPurchases endpoint with custom limit', () {
        final endpoint = RegistryEndpoints.getRecentPurchases(testBabyProfileId, limit: 25);

        expect(endpoint, contains('limit=25'));
      });

      test('generates correct createPurchase endpoint', () {
        final endpoint = RegistryEndpoints.createPurchase();

        expect(endpoint, equals('registry_purchases'));
      });

      test('generates correct updatePurchase endpoint', () {
        final endpoint = RegistryEndpoints.updatePurchase(testPurchaseId);

        expect(endpoint, contains('registry_purchases'));
        expect(endpoint, contains('id=eq.$testPurchaseId'));
      });

      test('generates correct deletePurchase endpoint', () {
        final endpoint = RegistryEndpoints.deletePurchase(testPurchaseId);

        expect(endpoint, contains('registry_purchases'));
        expect(endpoint, contains('id=eq.$testPurchaseId'));
      });
    });

    group('Registry Analytics', () {
      test('generates correct getRegistryStats endpoint', () {
        final endpoint = RegistryEndpoints.getRegistryStats(testBabyProfileId);

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('select=is_purchased,quantity,purchased_quantity'));
      });

      test('generates correct getRegistryValue endpoint', () {
        final endpoint = RegistryEndpoints.getRegistryValue(testBabyProfileId);

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('select=price,quantity,purchased_quantity'));
      });
    });

    group('Registry Search & Filter', () {
      test('generates correct searchRegistryItems endpoint', () {
        const searchTerm = 'crib';
        final endpoint = RegistryEndpoints.searchRegistryItems(testBabyProfileId, searchTerm);

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('item_name=ilike.'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('select=*'));
      });

      test('encodes special characters in search term', () {
        const searchTerm = 'test & special chars!';
        final endpoint = RegistryEndpoints.searchRegistryItems(testBabyProfileId, searchTerm);

        expect(endpoint, contains('item_name=ilike.'));
        // Should be URL encoded
        expect(endpoint, isNot(contains('&')));
      });

      test('generates correct getItemsByCategory endpoint', () {
        final endpoint = RegistryEndpoints.getItemsByCategory(testBabyProfileId, testCategory);

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('category=eq.$testCategory'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=priority.desc'));
      });

      test('generates correct getItemsByPriceRange endpoint', () {
        const minPrice = 10.0;
        const maxPrice = 100.0;
        final endpoint = RegistryEndpoints.getItemsByPriceRange(
          testBabyProfileId,
          minPrice,
          maxPrice,
        );

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('price=gte.$minPrice'));
        expect(endpoint, contains('price=lte.$maxPrice'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=price.asc'));
      });

      test('generates correct getItemsByPriority endpoint', () {
        const minPriority = 3;
        final endpoint = RegistryEndpoints.getItemsByPriority(testBabyProfileId, minPriority);

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('priority=gte.$minPriority'));
        expect(endpoint, contains('is_purchased=eq.false'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=priority.desc'));
      });
    });

    group('Helper Methods', () {
      test('generates correct getItemsWithPagination endpoint with defaults', () {
        final endpoint = RegistryEndpoints.getItemsWithPagination(testBabyProfileId);

        expect(endpoint, contains('registry_items'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=created_at.desc'));
        expect(endpoint, contains('limit=20'));
        expect(endpoint, contains('offset=0'));
      });

      test('generates correct getItemsWithPagination endpoint with custom values', () {
        final endpoint = RegistryEndpoints.getItemsWithPagination(
          testBabyProfileId,
          limit: 50,
          offset: 100,
        );

        expect(endpoint, contains('limit=50'));
        expect(endpoint, contains('offset=100'));
      });
    });
  });
}
