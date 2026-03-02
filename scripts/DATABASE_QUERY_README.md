# Database Query Tool

A Python tool to execute custom SQL queries against Supabase PostgreSQL database using queries defined in JSON configuration files.

## Features

- ✅ Read queries from JSON configuration files
- ✅ Execute multiple named queries flexibly
- ✅ Automatic connection pooling for restricted networks
- ✅ Formatted table output with smart column sizing
- ✅ Error handling with clear messages
- ✅ Batch query management

## Installation

The tool uses the same dependencies as `database_stats.py`:

```bash
cd /path/to/nonna_app
source .venv/bin/activate
pip3 install python-dotenv psycopg2-binary
```

## Usage

### List Available Queries

```bash
python3 scripts/database_query.py scripts/sample_queries.json
```

This displays all available queries from the JSON file.

### Execute a Specific Query

```bash
python3 scripts/database_query.py scripts/sample_queries.json <query_name>
```

Example:
```bash
python3 scripts/database_query.py scripts/sample_queries.json activity_events_sample
```

## Query Configuration (JSON Format)

Create a JSON file with the following structure:

```json
{
  "description": "Optional description of the query file",
  "queries": [
    {
      "name": "query_identifier",
      "description": "Human-readable description",
      "sql": "SELECT * FROM table LIMIT 10;",
      "limit": 10
    }
  ]
}
```

### Query Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier for the query (used in CLI) |
| `description` | No | Clear description of what the query does |
| `sql` | Yes | SQL query to execute |
| `limit` | No | Informational field (recommend using explicit LIMIT in SQL) |

## Example Queries File

See [sample_queries.json](sample_queries.json) for examples including:

- **activity_events_sample** - Fetch first 5 records from activity_events table
- **activity_events_count** - Count total records in activity_events table
- **app_versions** - Fetch app versions
- **baby_profiles** - Fetch baby profiles with names

## Output Format

Results are displayed in an aligned ASCII table format:

```
┌─────────────────────────────────────┬────────────────┐
│ Column Name                         │ Column Name 2  │
├─────────────────────────────────────┼────────────────┤
│ Value 1                             │ Value 2        │
│ Value 3                             │ Value 4        │
└─────────────────────────────────────┴────────────────┘

✅ Total rows: 2
```

### Features

- **Column width adjustment** - Automatically sizes columns based on content
- **Truncation** - Long values (>30 chars) are truncated with "..."
- **Row count** - Shows total rows returned
- **NULL handling** - Displays NULL values clearly

## Environment Variables

Required in `.env` file:

```bash
SUPABASE_URL=https://xxx.supabase.co       # Supabase project URL
SUPABASE_PASSWORD=your_password             # Postgres password
SHARED_POOLER=postgresql://...              # (Optional) Connection pooler URL
```

## Connection Details

- **Direct Connection**: Connects to `db.{project_id}.supabase.co` (port 5432)
- **Pooler Connection**: Uses `SHARED_POOLER` if available (recommended for restricted networks)
- **Database**: `postgres` (default)
- **User**: `postgres` (default)

## Error Handling

### Query Not Found

```
❌ Query 'invalid_name' not found. Available queries:
```

List all available queries and select the correct name.

### Connection Failed

```
❌ Connection failed: could not translate host name
```

Check:
1. Environment variables in `.env`
2. Network connectivity to Supabase
3. Supabase project status

### Invalid SQL

```
❌ Query failed: column "column_name" does not exist
```

Verify SQL syntax and column names match schema.

## Tips & Best Practices

### Query Organization

Group related queries by feature:

```json
{
  "queries": [
    {
      "name": "activity_summary",
      "description": "...",
      "sql": "..."
    },
    {
      "name": "activity_by_user",
      "description": "...",
      "sql": "..."
    }
  ]
}
```

### Complex Queries

Use subqueries and CTEs for complex operations:

```sql
WITH recent_events AS (
  SELECT * FROM public.activity_events
  WHERE created_at > NOW() - INTERVAL '7 days'
)
SELECT type, COUNT(*) as count
FROM recent_events
GROUP BY type;
```

### Performance

- Add `LIMIT` clauses to prevent large result sets
- Use indexes on frequently queried columns
- Test queries in Supabase SQL editor first
- Use `EXPLAIN` to analyze query plans:

```json
{
  "name": "query_plan",
  "sql": "EXPLAIN SELECT * FROM public.activity_events LIMIT 5;",
  "description": "Show query execution plan"
}
```

## Examples

### Count Records by Type

```json
{
  "name": "events_by_type",
  "description": "Count activity events grouped by type",
  "sql": "SELECT type, COUNT(*) as count FROM public.activity_events GROUP BY type ORDER BY count DESC;"
}
```

### Recent Activity

```json
{
  "name": "recent_activity",
  "description": "Last 10 activities in the past week",
  "sql": "SELECT * FROM public.activity_events WHERE created_at > NOW() - INTERVAL '7 days' ORDER BY created_at DESC LIMIT 10;"
}
```

### User Statistics

```json
{
  "name": "user_stats",
  "description": "User registration statistics",
  "sql": "SELECT COUNT(*) as total_users, DATE(created_at) as date FROM auth.users GROUP BY DATE(created_at) ORDER BY date DESC LIMIT 30;"
}
```

## Troubleshooting

### Script hangs or freezes

Ensure you set the connection pooler:
```bash
export SHARED_POOLER="postgresql://..."
```

### No output

Check if query returned results:
```json
{
  "name": "test",
  "sql": "SELECT COUNT(*) FROM public.activity_events;"
}
```

### Column names show as truncated UUIDs

Wrap columns in parentheses or use aliases:
```sql
SELECT id::text as identifier, name FROM table;
```

## Related Tools

- [database_stats.py](database_stats.py) - Database schema statistics and overview
- Both tools share connection pooler support and environment configuration

## License

Part of nonna_app project - Internal use only
