# Add imports
sed -i '' -e '/import '"'"'package:nonna_app\/tiles\/registry_deals\/widgets\/registry_deals_tile.dart'"'"';/a\
import '"'"'package:nonna_app/tiles/registry_deals/providers/registry_deals_provider.dart'"'"';\
' lib/core/utils/tile_factory.dart

sed -i '' -e '/import '"'"'package:nonna_app\/tiles\/registry_highlights\/widgets\/registry_highlights_tile.dart'"'"';/a\
import '"'"'package:nonna_app/tiles/registry_highlights/providers/registry_highlights_provider.dart'"'"';\
' lib/core/utils/tile_factory.dart

# Replace case 'RegistryHighlightsTile'
sed -i '' -e 's/case '"'"'RegistryHighlightsTile'"'"':/case '"'"'RegistryHighlightsTile'"'"':\n        return const _RegistryHighlightsSmartTile();/' lib/core/utils/tile_factory.dart
sed -i '' -e '/\/\/ TODO: Implement _RegistryHighlightsSmartTile wrapper/,/return const RegistryHighlightsTile(items: \[\], isLoading: false);/d' lib/core/utils/tile_factory.dart

# Replace case 'RegistryDealsTile'
sed -i '' -e 's/case '"'"'RegistryDealsTile'"'"':/case '"'"'RegistryDealsTile'"'"':\n        return const _RegistryDealsSmartTile();/' lib/core/utils/tile_factory.dart
sed -i '' -e '/\/\/ TODO: Implement _RegistryDealsSmartTile wrapper/,/return const RegistryDealsTile(deals: \[\], isLoading: false);/d' lib/core/utils/tile_factory.dart
