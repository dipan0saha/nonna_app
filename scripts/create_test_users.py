#!/usr/bin/env python3
"""
Create test auth users for Nonna App via the Supabase Admin API.

This script creates all 150 test users (20 owners + 130 followers) with fixed
UUIDs that match the seed data SQL files.  Use it when you cannot run SQL
directly against auth.users (e.g. when the remote Supabase project only allows
access through the REST API).

Usage:
    python scripts/create_test_users.py \
        --url  https://<project-ref>.supabase.co \
        --key  <service-role-key>

    # Or via environment variables:
    export SUPABASE_URL="https://<project-ref>.supabase.co"
    export SUPABASE_SERVICE_KEY="<service-role-key>"
    python scripts/create_test_users.py

Prerequisites:
    pip install requests

After this script completes, load the application data by running
supabase/seed/seed_data.sql in the Supabase SQL Editor.

For a full guide see: docs/SEED_DATA_GUIDE.md
"""

import argparse
import os
import sys
import time

try:
    import requests
except ImportError:
    sys.exit(
        "ERROR: 'requests' library not found.\n"
        "Install it with:  pip install requests"
    )

# ---------------------------------------------------------------------------
# Test user definitions
# ---------------------------------------------------------------------------
# Each entry: (uuid, email, display_name, role_hint)
# All users share the same password.
DEFAULT_PASSWORD = "password123"

# 20 Owners: 10 mothers (prefix 1000000N) + 10 fathers (prefix 2000000N)
OWNERS = [
    ("10000000-1001-1001-1001-000000001001", "seed+10000000@example.local", "Sarah Johnson",        "owner"),
    ("20000000-2001-2001-2001-000000002001", "seed+20000000@example.local", "Michael Johnson",       "owner"),
    ("10000001-1001-1001-1001-000000001001", "seed+10000001@example.local", "Emily Davis",           "owner"),
    ("20000001-2001-2001-2001-000000002001", "seed+20000001@example.local", "John Davis",            "owner"),
    ("10000002-1001-1001-1001-000000001001", "seed+10000002@example.local", "Jennifer Smith",        "owner"),
    ("20000002-2001-2001-2001-000000002001", "seed+20000002@example.local", "David Smith",           "owner"),
    ("10000003-1001-1001-1001-000000001001", "seed+10000003@example.local", "Jessica Brown",         "owner"),
    ("20000003-2001-2001-2001-000000002001", "seed+20000003@example.local", "Robert Brown",          "owner"),
    ("10000004-1001-1001-1001-000000001001", "seed+10000004@example.local", "Amanda Wilson",         "owner"),
    ("20000004-2001-2001-2001-000000002001", "seed+20000004@example.local", "James Wilson",          "owner"),
    ("10000005-1001-1001-1001-000000001001", "seed+10000005@example.local", "Maria Martinez",        "owner"),
    ("20000005-2001-2001-2001-000000002001", "seed+20000005@example.local", "Carlos Martinez",       "owner"),
    ("10000006-1001-1001-1001-000000001001", "seed+10000006@example.local", "Sofia Garcia",          "owner"),
    ("20000006-2001-2001-2001-000000002001", "seed+20000006@example.local", "Miguel Garcia",         "owner"),
    ("10000007-1001-1001-1001-000000001001", "seed+10000007@example.local", "Michelle Lee",          "owner"),
    ("20000007-2001-2001-2001-000000002001", "seed+20000007@example.local", "Kevin Lee",             "owner"),
    ("10000008-1001-1001-1001-000000001001", "seed+10000008@example.local", "Rachel Anderson",       "owner"),
    ("20000008-2001-2001-2001-000000002001", "seed+20000008@example.local", "Christopher Anderson",  "owner"),
    ("10000009-1001-1001-1001-000000001001", "seed+10000009@example.local", "Lauren Taylor",         "owner"),
    ("20000009-2001-2001-2001-000000002001", "seed+20000009@example.local", "Daniel Taylor",         "owner"),
]

# 130 Followers (hex 0x00 – 0x81)
# Names are copied verbatim from supabase/seed/seed_data.sql to keep UUIDs and
# display names consistent.  Some names may appear gender-mismatched (e.g.
# "Grandpa Olivia") — this is intentional in the seed data for variety.
_FOLLOWER_NAMES = [
    "Grandma Emma", "Grandpa Olivia", "Aunt Ava", "Uncle Isabella", "Cousin Sophia",
    "Friend Mia", "Neighbor Charlotte", "Colleague Amelia", "Family Friend Harper",
    "Godparent Evelyn", "Grandma Liam", "Grandpa Noah", "Aunt Oliver", "Uncle Elijah",
    "Cousin William", "Friend James", "Neighbor Benjamin", "Colleague Lucas",
    "Family Friend Henry", "Godparent Alexander", "Grandma Anna", "Grandpa Grace",
    "Aunt Lily", "Uncle Zoe", "Cousin Hannah", "Friend Chloe", "Neighbor Ella",
    "Colleague Aria", "Family Friend Scarlett", "Godparent Victoria", "Grandma Mason",
    "Grandpa Ethan", "Aunt Logan", "Uncle Jacob", "Cousin Jackson", "Friend Aiden",
    "Neighbor Samuel", "Colleague Sebastian", "Family Friend Matthew", "Godparent Jack",
    "Grandma Ruby", "Grandpa Alice", "Aunt Eva", "Uncle Lucy", "Cousin Freya",
    "Friend Sophie", "Neighbor Daisy", "Colleague Phoebe", "Family Friend Florence",
    "Godparent Isabelle", "Grandma Leo", "Grandpa Oscar", "Aunt Charlie", "Uncle Max",
    "Cousin Isaac", "Friend Dylan", "Neighbor Thomas", "Colleague Ethan", "Family Friend Ryan",
    "Godparent Nathan", "Grandma Violet", "Grandpa Rosie", "Aunt Jasper", "Uncle Penelope",
    "Cousin Miles", "Friend Sienna", "Neighbor Poppy", "Colleague Ivy", "Family Friend Amber",
    "Godparent Pearl", "Grandma Theodore", "Grandpa Beatrice", "Aunt Jasmine", "Uncle Luna",
    "Cousin Phoenix", "Friend Aurora", "Neighbor Stella", "Colleague Nova", "Family Friend Iris",
    "Godparent Hazel", "Grandma Felix", "Grandpa Clara", "Aunt Hugo", "Uncle Nora",
    "Cousin Julian", "Friend Maeve", "Neighbor Cora", "Colleague Elise", "Family Friend Ada",
    "Godparent Vera", "Grandma Roman", "Grandpa Diana", "Aunt Sebastian", "Uncle Elena",
    "Cousin Marcus", "Friend Selene", "Neighbor Lyra", "Colleague Thalia", "Family Friend Celeste",
    "Godparent Orion", "Grandma Atlas", "Grandpa Athena", "Aunt Leo", "Uncle Hera",
    "Cousin Apollo", "Friend Artemis", "Neighbor Hermes", "Colleague Demeter",
    "Family Friend Hestia", "Godparent Ares", "Grandma Hephaestus", "Grandpa Aphrodite",
    "Aunt Poseidon", "Uncle Persephone", "Cousin Dionysus", "Friend Nike", "Neighbor Tyche",
    "Colleague Hecate", "Family Friend Nemesis", "Godparent Iris", "Grandma Morpheus",
    "Grandpa Hypnos", "Aunt Eos", "Uncle Selene", "Cousin Helios", "Friend Erebus",
    "Neighbor Nyx", "Colleague Chaos", "Family Friend Gaia",
]

FOLLOWERS = []
for i in range(130):
    # Follower UUIDs: 40000000-4001-4001-4001-000000004001 through 40000081-...
    first_seg = format(0x40000000 + i, "08x")
    uuid = f"{first_seg}-4001-4001-4001-000000004001"
    email = f"seed+{first_seg}@example.local"
    name = _FOLLOWER_NAMES[i] if i < len(_FOLLOWER_NAMES) else f"Follower {i}"
    FOLLOWERS.append((uuid, email, name, "follower"))

ALL_USERS = OWNERS + FOLLOWERS


# ---------------------------------------------------------------------------
# API helpers
# ---------------------------------------------------------------------------

def build_headers(service_key: str) -> dict:
    return {
        "Authorization": f"Bearer {service_key}",
        "apikey": service_key,
        "Content-Type": "application/json",
    }


def user_exists(base_url: str, headers: dict, user_id: str) -> bool:
    """Return True if the user already exists in Supabase Auth."""
    response = requests.get(
        f"{base_url}/auth/v1/admin/users/{user_id}",
        headers=headers,
        timeout=10,
    )
    return response.status_code == 200


def create_user(
    base_url: str,
    headers: dict,
    user_id: str,
    email: str,
    display_name: str,
    password: str,
) -> tuple[bool, str]:
    """
    Create a single user via the Supabase Admin API.
    Returns (success, message).
    """
    payload = {
        "id": user_id,
        "email": email,
        "password": password,
        "email_confirm": True,
        "user_metadata": {"display_name": display_name},
    }
    response = requests.post(
        f"{base_url}/auth/v1/admin/users",
        json=payload,
        headers=headers,
        timeout=15,
    )
    if response.status_code in (200, 201):
        return True, "created"
    body = response.json()
    message = body.get("message") or body.get("msg") or response.text
    return False, f"HTTP {response.status_code}: {message}"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create Nonna App test auth users via Supabase Admin API"
    )
    parser.add_argument(
        "--url",
        default=os.environ.get("SUPABASE_URL", ""),
        help="Supabase project URL (env: SUPABASE_URL)",
    )
    parser.add_argument(
        "--key",
        default=os.environ.get("SUPABASE_SERVICE_KEY", ""),
        help="Supabase service role key (env: SUPABASE_SERVICE_KEY)",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Re-create users that already exist (default: skip existing users)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print what would be created without making API calls",
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=0.1,
        help="Seconds to wait between API calls to avoid rate limiting (default: 0.1)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    if not args.url:
        sys.exit(
            "ERROR: Supabase URL is required.\n"
            "  Use --url or set SUPABASE_URL environment variable."
        )
    if not args.key:
        sys.exit(
            "ERROR: Supabase service role key is required.\n"
            "  Use --key or set SUPABASE_SERVICE_KEY environment variable."
        )

    base_url = args.url.rstrip("/")
    headers = build_headers(args.key)

    if args.dry_run:
        print(f"DRY RUN — would create {len(ALL_USERS)} users:")
        for uid, email, name, role in ALL_USERS:
            print(f"  [{role:8s}] {email}  ({name})")
        return

    print(f"Creating {len(ALL_USERS)} test users in {base_url}")
    print(f"  Owners:    {len(OWNERS)}")
    print(f"  Followers: {len(FOLLOWERS)}")
    print()

    created = 0
    skipped = 0
    failed = 0
    errors: list[str] = []

    for i, (uid, email, name, role) in enumerate(ALL_USERS, 1):
        prefix = f"[{i:3d}/{len(ALL_USERS)}] {email}"

        if not args.force and user_exists(base_url, headers, uid):
            print(f"  SKIP  {prefix}")
            skipped += 1
            continue

        success, message = create_user(base_url, headers, uid, email, name, DEFAULT_PASSWORD)

        if success:
            print(f"  OK    {prefix}  ({name})")
            created += 1
        else:
            print(f"  FAIL  {prefix}  → {message}")
            errors.append(f"{email}: {message}")
            failed += 1

        if args.delay > 0:
            time.sleep(args.delay)

    print()
    print("=" * 60)
    print(f"Done.  Created: {created}  Skipped: {skipped}  Failed: {failed}")

    if errors:
        print("\nFailed users:")
        for err in errors:
            print(f"  {err}")
        sys.exit(1)

    print()
    print("Next step: load application data in the Supabase SQL Editor.")
    print("  Run: supabase/seed/seed_data.sql")
    print("  Or see: docs/SEED_DATA_GUIDE.md")


if __name__ == "__main__":
    main()
