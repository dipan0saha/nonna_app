import re

with open('lib/features/gallery/presentation/providers/gallery_screen_provider.dart', 'r') as f:
    content = f.read()

new_func = """  Future<void> _saveToCache(String babyProfileId, UserRole role, List<TileConfig> tiles) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = '${_cacheKeyPrefix}_${babyProfileId}_${role.name}';
      final dataList = tiles.map((t) => t.toJson()).toList();
      
      await cacheService.put(
        cacheKey,
        dataList,
        ttlMinutes: PerformanceLimits.screenCacheDuration.inMinutes,
      );
    } catch (e) {
      debugPrint('⚠️  Failed to save gallery cache: $e');
    }
  }"""

pattern = r"  Future<void> _saveToCache\(String babyProfileId, UserRole role, List<TileConfig>\n?> tiles\) async \{[^\}]+\}[^\}]+\}"
import re
content = re.sub(r'  Future<void> _saveToCache\(String babyProfileId, UserRole role, List<TileConfig>\n?> tiles\) async \{.+?\}', new_func, content, flags=re.DOTALL)

with open('lib/features/gallery/presentation/providers/gallery_screen_provider.dart', 'w') as f:
    f.write(content)
