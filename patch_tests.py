import os
import re

files_to_patch = [
    "test/core/models/registry_purchase_test.dart",
    "test/features/registry/presentation/providers/registry_screen_provider_test.dart",
    "test/tiles/recent_purchases/providers/recent_purchases_provider_test.dart",
    "test/tiles/recent_purchases/widgets/recent_purchases_tile_test.dart"
]

for file_path in files_to_patch:
    if os.path.exists(file_path):
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Remove 'createdAt: ...,'
        content = re.sub(r'\s*createdAt: [^,]+,\n', '\n', content)
        
        # Remove 'created_at' from JSON
        content = re.sub(r'\s*\'created_at\': [^,]+,\n', '\n', content)

        with open(file_path, 'w') as f:
            f.write(content)

