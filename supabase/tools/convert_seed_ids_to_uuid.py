#!/usr/bin/env python3
"""
convert_seed_ids_to_uuid.py

Scan `supabase/seed.sql` for non-UUID IDs (bm-..., cfg-..., screen-..., tile-...)
and replace them with generated UUIDv4 values while preserving references.
Writes:
 - `supabase/seed_converted.sql` (converted SQL)
 - `supabase/seed_id_map.json` (old -> new UUID mapping)

Usage:
    python3 supabase/tools/convert_seed_ids_to_uuid.py

Review the generated file before applying to your database.
"""

import json
import re
import uuid
from pathlib import Path

ROOT = Path(__file__).parents[1]
SEED_IN = ROOT / "seed.sql"
SEED_OUT = ROOT / "seed_converted.sql"
MAP_OUT = ROOT / "seed_id_map.json"

if not SEED_IN.exists():
    raise SystemExit(f"Input seed file not found: {SEED_IN}")

text = SEED_IN.read_text(encoding="utf-8")

# Find all single-quoted tokens
tokens = re.findall(r"'([^']+)'", text)
unique = sorted(set(tokens))

# Patterns we want to replace (adjust if needed)
patterns = [
    re.compile(r"^bm-\d{6}$"),  # baby membership ids
    re.compile(r"^cfg-[\w\-]+$"),  # config ids
    re.compile(r"^screen-[\w\-]+$"),  # screen ids
    re.compile(r"^tile-[\w\-]+$"),  # tile definition ids
]

# Build mapping
mapping = {}
for t in unique:
    for p in patterns:
        if p.match(t):
            mapping[t] = str(uuid.uuid4())
            break

if not mapping:
    print("No matching non-UUID IDs found to replace.")
    raise SystemExit(0)


# Replacement function: only replace quoted whole tokens
def replace_match(m):
    inner = m.group(1)
    if inner in mapping:
        return "'" + mapping[inner] + "'"
    return m.group(0)


converted = re.sub(r"'([^']+)'", replace_match, text)

# Write outputs
SEED_OUT.write_text(converted, encoding="utf-8")
MAP_OUT.write_text(json.dumps(mapping, indent=2), encoding="utf-8")

print(f"Wrote converted seed: {SEED_OUT}")
print(f"Wrote id map: {MAP_OUT}")
print("Please review the converted SQL before applying to your database.")
