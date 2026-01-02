#!/usr/bin/env python3
import re
from pathlib import Path

seed = Path(__file__).resolve().parents[1] / "seed.sql"
out = Path(__file__).resolve().parents[1] / "auth_users_seed.sql"
text = seed.read_text()

# Extract the profiles block
profiles_block = ""
m = re.search(
    r"INSERT INTO public\.profiles[\s\S]*?ON CONFLICT \(user_id\) DO NOTHING;", text
)
if m:
    profiles_block = m.group(0)

# Extract the user_stats block
stats_block = ""
m2 = re.search(
    r"INSERT INTO public\.user_stats[\s\S]*?ON CONFLICT \(user_id\) DO NOTHING;", text
)
if m2:
    stats_block = m2.group(0)

combined = profiles_block + "\n" + stats_block

uuids = set(re.findall(r"'([0-9a-fA-F0-9\-]{36})'", combined))
# Filter out baby ids that start with 'b'
user_ids = sorted([u for u in uuids if not u.lower().startswith("b")])

if not user_ids:
    print(
        "No user IDs found in profiles/user_stats blocks; falling back to global UUID scan..."
    )
    uuids_all = set(re.findall(r"'([0-9a-fA-F0-9\-]{36})'", text))
    user_ids = sorted([u for u in uuids_all if not u.lower().startswith("b")])

# Generate INSERT statements
lines = []
lines.append("-- Generated auth.users INSERTs for seed (run as service role)")
lines.append("-- Review and run in Supabase SQL editor or via Admin API")
lines.append("\nBEGIN;")
for uid in user_ids:
    email = f"seed+{uid[:8]}@example.local"
    lines.append(
        f"INSERT INTO auth.users (id, email, aud, role, email_confirmed_at, created_at) VALUES ('{uid}', '{email}', 'authenticated', 'authenticated', NOW(), NOW()) ON CONFLICT (id) DO NOTHING;"
    )
lines.append("COMMIT;")

out.write_text("\n".join(lines))
print(f"Wrote {out} with {len(user_ids)} INSERTs")
