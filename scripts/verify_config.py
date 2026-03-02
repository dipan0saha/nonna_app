#!/usr/bin/env python3
"""
Verify Supabase Database Configuration

Quick verification script to check .env configuration
without requiring a database connection.
"""

import os
from pathlib import Path

try:
    import dotenv
except ImportError:
    print("❌ Missing dotenv. Install with: pip3 install python-dotenv")
    exit(1)

# Load .env
script_dir = Path(__file__).parent
project_root = script_dir.parent
env_file = project_root / ".env"

if not env_file.exists():
    print(f"❌ .env not found at {env_file}")
    exit(1)

dotenv.load_dotenv(env_file)

# Check required credentials
supabase_url = os.getenv("SUPABASE_URL")
supabase_password = os.getenv("SUPABASE_PASSWORD")

print("✅ Configuration loaded from .env:\n")
print("┌─ Supabase Configuration")
if supabase_url:
    print(f"│  ✅ SUPABASE_URL         = {supabase_url}")
else:
    print(f"│  ❌ SUPABASE_URL         = NOT SET")

if supabase_password:
    print(f"│  ✅ SUPABASE_PASSWORD    = ***MASKED***")
else:
    print(f"│  ❌ SUPABASE_PASSWORD    = NOT SET")
print("└─")

if supabase_url and supabase_password:
    print("\n✅ All required credentials are present")
    print("\nTo run the database statistics script:")
    print("  ./.venv/bin/python3 scripts/database_stats.py")
else:
    print("\n❌ Missing required configuration")
