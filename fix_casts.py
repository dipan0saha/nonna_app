import os
import glob

def replace_in_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
        
    old_str = "json as Map<String, dynamic>"
    new_str = "Map<String, dynamic>.from(json as Map)"
    
    if old_str in content:
        content = content.replace(old_str, new_str)
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed {filepath}")

for root, _, files in os.walk("lib/tiles"):
    for f in files:
        if f.endswith(".dart"):
            replace_in_file(os.path.join(root, f))
