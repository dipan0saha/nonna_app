import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/models/registry_purchase.dart';

/// Registry item paired with its purchase status.
///
/// Used by both the [RegistryHighlightsNotifier] provider and the
/// [RegistryHighlightsTile] widget so neither depends on the other.
class RegistryItemWithStatus {
  final RegistryItem item;
  final bool isPurchased;
  final List<RegistryPurchase> purchases;

  const RegistryItemWithStatus({
    required this.item,
    required this.isPurchased,
    this.purchases = const [],
  });
}
