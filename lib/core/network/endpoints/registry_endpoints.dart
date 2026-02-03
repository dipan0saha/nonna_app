import '../../constants/supabase_tables.dart';

/// Registry endpoints for registry item and purchase operations
///
/// **Functional Requirements**: Section 3.2.6 - Endpoint Definitions
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Registry item CRUD endpoints
/// - Purchase endpoints
/// - Registry analytics queries
///
/// Dependencies: SupabaseTables
class RegistryEndpoints {
  // Prevent instantiation
  RegistryEndpoints._();

  // ============================================================
  // Registry Item CRUD Operations
  // ============================================================

  /// Get all registry items for a baby profile
  ///
  /// [babyProfileId] Baby profile ID
  static String getRegistryItems(String babyProfileId) {
    return '${SupabaseTables.registryItems}?baby_profile_id=eq.$babyProfileId&is:deleted_at.null&select=*&order=created_at.desc';
  }

  /// Get a specific registry item
  ///
  /// [itemId] Registry item ID
  static String getRegistryItem(String itemId) {
    return '${SupabaseTables.registryItems}?id=eq.$itemId&select=*';
  }

  /// Get available registry items (not fully purchased)
  ///
  /// [babyProfileId] Baby profile ID
  static String getAvailableItems(String babyProfileId) {
    return '${SupabaseTables.registryItems}?baby_profile_id=eq.$babyProfileId&is_purchased=eq.false&is:deleted_at.null&select=*&order=priority.desc,created_at.desc';
  }

  /// Get purchased registry items
  ///
  /// [babyProfileId] Baby profile ID
  static String getPurchasedItems(String babyProfileId) {
    return '${SupabaseTables.registryItems}?baby_profile_id=eq.$babyProfileId&is_purchased=eq.true&is:deleted_at.null&select=*&order=purchased_at.desc';
  }

  /// Get registry item highlights (high priority items)
  ///
  /// [babyProfileId] Baby profile ID
  /// [limit] Number of items to return
  static String getRegistryHighlights(String babyProfileId, {int limit = 5}) {
    return '${SupabaseTables.registryItems}?baby_profile_id=eq.$babyProfileId&is_purchased=eq.false&priority=gte.4&is:deleted_at.null&select=*&order=priority.desc&limit=$limit';
  }

  /// Create a new registry item
  static String createRegistryItem() {
    return SupabaseTables.registryItems;
  }

  /// Update a registry item
  ///
  /// [itemId] Registry item ID
  static String updateRegistryItem(String itemId) {
    return '${SupabaseTables.registryItems}?id=eq.$itemId';
  }

  /// Delete a registry item (soft delete)
  ///
  /// [itemId] Registry item ID
  static String deleteRegistryItem(String itemId) {
    return '${SupabaseTables.registryItems}?id=eq.$itemId';
  }

  // ============================================================
  // Registry Purchase Operations
  // ============================================================

  /// Get all purchases for a registry item
  ///
  /// [itemId] Registry item ID
  static String getItemPurchases(String itemId) {
    return '${SupabaseTables.registryPurchases}?registry_item_id=eq.$itemId&select=*&order=purchased_at.desc';
  }

  /// Get purchases by a user
  ///
  /// [babyProfileId] Baby profile ID
  /// [userId] User ID
  static String getUserPurchases(String babyProfileId, String userId) {
    return '${SupabaseTables.registryPurchases}?registry_item_id.baby_profile_id=eq.$babyProfileId&purchased_by_user_id=eq.$userId&select=*,registry_item_id(*)&order=purchased_at.desc';
  }

  /// Get recent purchases
  ///
  /// [babyProfileId] Baby profile ID
  /// [limit] Number of purchases to return
  static String getRecentPurchases(String babyProfileId, {int limit = 10}) {
    return '${SupabaseTables.registryPurchases}?registry_item_id.baby_profile_id=eq.$babyProfileId&select=*,registry_item_id(*)&order=purchased_at.desc&limit=$limit';
  }

  /// Create a new purchase
  static String createPurchase() {
    return SupabaseTables.registryPurchases;
  }

  /// Update a purchase
  ///
  /// [purchaseId] Purchase ID
  static String updatePurchase(String purchaseId) {
    return '${SupabaseTables.registryPurchases}?id=eq.$purchaseId';
  }

  /// Delete a purchase
  ///
  /// [purchaseId] Purchase ID
  static String deletePurchase(String purchaseId) {
    return '${SupabaseTables.registryPurchases}?id=eq.$purchaseId';
  }

  // ============================================================
  // Registry Analytics
  // ============================================================

  /// Get registry completion statistics
  ///
  /// [babyProfileId] Baby profile ID
  static String getRegistryStats(String babyProfileId) {
    return '${SupabaseTables.registryItems}?baby_profile_id=eq.$babyProfileId&is:deleted_at.null&select=is_purchased,quantity,purchased_quantity';
  }

  /// Get total registry value
  ///
  /// [babyProfileId] Baby profile ID
  static String getRegistryValue(String babyProfileId) {
    return '${SupabaseTables.registryItems}?baby_profile_id=eq.$babyProfileId&is:deleted_at.null&select=price,quantity,purchased_quantity';
  }

  // ============================================================
  // Registry Search & Filter
  // ============================================================

  /// Search registry items by name
  ///
  /// [babyProfileId] Baby profile ID
  /// [searchTerm] Search term
  static String searchRegistryItems(String babyProfileId, String searchTerm) {
    final encodedSearchTerm = Uri.encodeComponent(searchTerm);
    return '${SupabaseTables.registryItems}?baby_profile_id=eq.$babyProfileId&item_name=ilike.*$encodedSearchTerm*&is:deleted_at.null&select=*';
  }

  /// Get registry items by category
  ///
  /// [babyProfileId] Baby profile ID
  /// [category] Item category
  static String getItemsByCategory(String babyProfileId, String category) {
    return '${SupabaseTables.registryItems}?baby_profile_id=eq.$babyProfileId&category=eq.$category&is:deleted_at.null&select=*&order=priority.desc';
  }

  /// Get registry items by price range
  ///
  /// [babyProfileId] Baby profile ID
  /// [minPrice] Minimum price
  /// [maxPrice] Maximum price
  static String getItemsByPriceRange(
    String babyProfileId,
    double minPrice,
    double maxPrice,
  ) {
    return '${SupabaseTables.registryItems}?baby_profile_id=eq.$babyProfileId&price=gte.$minPrice&price=lte.$maxPrice&is:deleted_at.null&select=*&order=price.asc';
  }

  /// Get registry items by priority
  ///
  /// [babyProfileId] Baby profile ID
  /// [minPriority] Minimum priority (1-5)
  static String getItemsByPriority(String babyProfileId, int minPriority) {
    return '${SupabaseTables.registryItems}?baby_profile_id=eq.$babyProfileId&priority=gte.$minPriority&is_purchased=eq.false&is:deleted_at.null&select=*&order=priority.desc';
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Build registry query with pagination
  ///
  /// [babyProfileId] Baby profile ID
  /// [limit] Number of items to return
  /// [offset] Number of items to skip
  static String getItemsWithPagination(
    String babyProfileId, {
    int limit = 20,
    int offset = 0,
  }) {
    return '${SupabaseTables.registryItems}?baby_profile_id=eq.$babyProfileId&is:deleted_at.null&select=*&order=created_at.desc&limit=$limit&offset=$offset';
  }
}
