sed -i '' -e "/expect(json\['created_at'\], now.toIso8601String());/d" test/core/models/registry_purchase_test.dart
