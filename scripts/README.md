# Supabase Database Statistics Tool

Displays table and schema statistics from your Supabase database.

## Installation

```bash
cd /path/to/nonna_app
source .venv/bin/activate
pip3 install python-dotenv psycopg2-binary
```

## Configuration

Add these variables to your `.env` file:

```dotenv
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_PASSWORD=your_postgres_password
```

## Usage

```bash
python3 scripts/database_stats.py
```

## Output

Shows:
- Total tables and views
- Row count per table
- Table sizes
- Schema and type summaries

## Troubleshooting

**Connection error?** Verify your `.env` has the correct `SUPABASE_URL` and `SUPABASE_PASSWORD`.

**Missing packages?** Run the installation command again.
