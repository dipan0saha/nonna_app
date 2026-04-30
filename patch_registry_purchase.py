import os
import re

model_file = "lib/core/models/registry_purchase.dart"
with open(model_file, 'r') as f:
    content = f.read()

# Remove field definition
content = re.sub(r'  /// Timestamp when the record was created\n  final DateTime createdAt;\n\n', '', content)

# Remove constructor param
content = re.sub(r'    required this.createdAt,\n', '', content)

# Remove from fromJson
content = re.sub(r'      createdAt: DateTime\.parse\(json\[\'created_at\'\] as String\),\n', '', content)

# Remove from toJson
content = re.sub(r'      \'created_at\': createdAt\.toIso8601String\(\),\n', '', content)

# Remove from copyWith param
content = re.sub(r'    DateTime\? createdAt,\n', '', content)

# Remove from copyWith assignment
content = re.sub(r'      createdAt: createdAt \?\? this\.createdAt,\n', '', content)

# Remove from operator ==
content = re.sub(r' &&\n        other\.createdAt == createdAt', '', content)

# Remove from hashCode
content = re.sub(r' \^\n        createdAt\.hashCode', '', content)

with open(model_file, 'w') as f:
    f.write(content)

