#!/usr/bin/env python3
"""
Supabase Database Statistics Tool

Connects to Supabase PostgreSQL database and displays comprehensive statistics:
- Total number of tables and views
- Row counts for each table
- Table size information
- Schema breakdown
- Column information

Installation:
    cd /path/to/nonna_app
    source .venv/bin/activate
    pip3 install python-dotenv psycopg2-binary

Usage:
    python3 scripts/database_stats.py

Environment Variables Required:
    SUPABASE_URL      - Supabase project URL (https://xxx.supabase.co)
    SUPABASE_PASSWORD - Postgres password
"""

import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

try:
    import dotenv
    import psycopg2
    from psycopg2 import sql
except ImportError as e:
    print(f"❌ Missing required package: {e}")
    print("\n📦 Installation Instructions:")
    print("  cd $(git rev-parse --show-toplevel)")
    print("  source .venv/bin/activate")
    print("  pip3 install python-dotenv psycopg2-binary")
    sys.exit(1)


class Colors:
    """ANSI color codes for terminal output."""

    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    YELLOW = "\033[1;33m"
    BLUE = "\033[0;34m"
    BOLD = "\033[1m"
    NC = "\033[0m"  # No Color


class SupabaseDatabaseStats:
    """Collects and displays statistics from Supabase database."""

    def __init__(self, db_url: str, project_id: str):
        """
        Initialize with database connection details.

        Args:
            db_url: PostgreSQL connection URL
            project_id: Supabase project ID (for display)
        """
        self.db_url = db_url
        self.project_id = project_id
        self.connection: Optional[psycopg2.extensions.connection] = None
        self.cursor: Optional[psycopg2.extensions.cursor] = None
        self.tables: List[Dict] = []

    def connect(self) -> bool:
        """Establish connection to Supabase database."""
        try:
            print(f"{Colors.BLUE}🔐 Connecting to Supabase database...{Colors.NC}")
            self.connection = psycopg2.connect(self.db_url, connect_timeout=5)
            self.cursor = self.connection.cursor()
            print(f"{Colors.GREEN}✅ Connected{Colors.NC}")
            return True
        except Exception as e:
            print(f"{Colors.RED}❌ Connection failed: {e}{Colors.NC}")
            return False

    def disconnect(self):
        """Close database connection."""
        try:
            if self.cursor:
                self.cursor.close()
            if self.connection:
                self.connection.close()
            print(f"{Colors.GREEN}✅ Disconnected{Colors.NC}")
        except Exception as e:
            print(f"{Colors.YELLOW}⚠️  Error during disconnect: {e}{Colors.NC}")

    def get_all_tables(self) -> List[Dict]:
        """
        Retrieve all tables and views from the database with their metadata.

        Returns:
            List of dicts with table information
        """
        query = """
            SELECT
                t.table_schema,
                t.table_name,
                t.table_type,
                (SELECT COUNT(*)
                 FROM information_schema.columns c
                 WHERE c.table_name = t.table_name
                 AND c.table_schema = t.table_schema) as column_count
            FROM information_schema.tables t
            WHERE t.table_schema NOT IN ('pg_catalog', 'information_schema')
            ORDER BY t.table_schema, t.table_name;
        """

        try:
            self.cursor.execute(query)
            columns = [desc[0] for desc in self.cursor.description]
            tables = []

            for row in self.cursor.fetchall():
                tables.append(dict(zip(columns, row)))

            return tables
        except psycopg2.Error as e:
            print(f"{Colors.RED}❌ Error querying tables: {e}{Colors.NC}")
            return []

    def get_row_count(self, schema: str, table: str) -> int:
        """
        Get the row count for a specific table.

        Uses pg_stat_user_tables for better permission handling with RLS.
        Falls back to COUNT(*) if statistics unavailable.

        Args:
            schema: Schema name
            table: Table name

        Returns:
            Number of rows in the table, or -1 if unable to count
        """
        # Try pg_stat_user_tables first (has better permissions with RLS)
        try:
            query = sql.SQL(
                "SELECT n_live_tup FROM pg_stat_user_tables WHERE relname = {} AND schemaname = {}"
            ).format(sql.Literal(table), sql.Literal(schema))
            self.cursor.execute(query)
            result = self.cursor.fetchone()
            if result:
                return result[0]
        except psycopg2.Error:
            pass

        # Fall back to COUNT(*) for user tables
        try:
            query = sql.SQL("SELECT COUNT(*) FROM {}.{}").format(
                sql.Identifier(schema), sql.Identifier(table)
            )
            self.cursor.execute(query)
            return self.cursor.fetchone()[0]
        except psycopg2.Error:
            # Return -1 to indicate error, will display as N/A
            return -1

    def get_table_size(self, schema: str, table: str) -> str:
        """
        Get the size of a table in human-readable format.

        Args:
            schema: Schema name
            table: Table name

        Returns:
            Size as human-readable string
        """
        try:
            query = sql.SQL(
                "SELECT pg_size_pretty(pg_total_relation_size({}.{}))"
            ).format(sql.Identifier(schema), sql.Identifier(table))
            self.cursor.execute(query)
            return self.cursor.fetchone()[0]
        except psycopg2.Error:
            return "N/A"

    def print_header(self, project_name: str):
        """Print the report header."""
        print(f"\n{Colors.BLUE}{Colors.BOLD}")
        print("╔" + "═" * 88 + "╗")
        print("║" + " " * 20 + "📊 SUPABASE DATABASE STATISTICS" + " " * 36 + "║")
        print("╚" + "═" * 88 + "╝")
        print(f"{Colors.NC}")
        print(
            f"{Colors.BOLD}Generated:{Colors.NC} {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        )
        print(f"{Colors.BOLD}Project:{Colors.NC}   {project_name}")
        print()

    def print_quick_stats(self, tables: List[Dict]):
        """Print quick statistics summary."""
        num_tables = sum(1 for t in tables if t["table_type"] == "BASE TABLE")
        num_views = sum(1 for t in tables if t["table_type"] == "VIEW")
        total = len(tables)

        print(f"{Colors.BOLD}{Colors.BLUE}📊 QUICK STATS{Colors.NC}{Colors.NC}")
        print("─" * 90)
        print(f"  {Colors.BOLD}Base Tables:{Colors.NC}     {num_tables}")
        print(f"  {Colors.BOLD}Views:{Colors.NC}           {num_views}")
        print("  " + "─" * 30)
        print(f"  {Colors.BOLD}Total Objects:{Colors.NC}   {total}")
        print()

    def print_table_listing(self, tables: List[Dict]):
        """Print detailed table listing with statistics."""
        print(f"{Colors.BOLD}{Colors.BLUE}📋 TABLE LISTING{Colors.NC}{Colors.NC}")
        print("─" * 90)
        print(
            f"{'Schema':<15} {'Table Name':<30} {'Type':<12} {'Cols':<6} {'Rows':<10} {'Size':<10}"
        )
        print("─" * 90)

        tables_by_schema = {}

        for table in tables:
            schema = table["table_schema"]
            name = table["table_name"]
            ttype = table["table_type"]
            cols = table["column_count"]

            if schema not in tables_by_schema:
                tables_by_schema[schema] = []
            tables_by_schema[schema].append(table)

            # Get row count for base tables
            if ttype == "BASE TABLE":
                row_count = self.get_row_count(schema, name)
                size = self.get_table_size(schema, name)
                rows_display = f"{row_count:,}" if row_count >= 0 else "N/A"
            else:
                rows_display = "—"
                size = "—"

            print(
                f"{schema:<15} {name:<30} {ttype:<12} {cols:<6} {rows_display:<10} {size:<10}"
            )

        print()
        return tables_by_schema

    def print_schema_summary(self, tables_by_schema: Dict[str, List]):
        """Print summary grouped by schema."""
        print(f"{Colors.BOLD}{Colors.BLUE}📦 SCHEMA SUMMARY{Colors.NC}{Colors.NC}")
        print("─" * 90)

        for schema in sorted(tables_by_schema.keys()):
            items = tables_by_schema[schema]
            base_tables = sum(1 for t in items if t["table_type"] == "BASE TABLE")
            views = sum(1 for t in items if t["table_type"] == "VIEW")

            total_rows = sum(
                count
                for count in [
                    self.get_row_count(schema, t["table_name"])
                    for t in items
                    if t["table_type"] == "BASE TABLE"
                ]
                if count >= 0
            )

            print(f"\n{Colors.BOLD}🗂️  Schema: {schema}{Colors.NC}")
            print(f"   ├─ Base Tables: {base_tables}")
            print(f"   ├─ Views: {views}")
            print(f"   ├─ Total Objects: {len(items)}")
            print(f"   └─ Total Rows: {total_rows:,}")

    def print_type_summary(self, tables: List[Dict]):
        """Print summary grouped by table type."""
        print(f"\n{Colors.BOLD}{Colors.BLUE}🏷️  TYPE SUMMARY{Colors.NC}{Colors.NC}")
        print("─" * 90)

        type_counts = {}
        for table in tables:
            ttype = table["table_type"]
            type_counts[ttype] = type_counts.get(ttype, 0) + 1

        for ttype in sorted(type_counts.keys()):
            count = type_counts[ttype]
            icon = "📄" if ttype == "BASE TABLE" else "👁️" if ttype == "VIEW" else "🔢"
            print(f"  {icon} {ttype:<25} : {count:>4} objects")

        print(f"\n  {Colors.BOLD}✅ TOTAL{Colors.NC:<25} : {len(tables):>4} objects")
        print()

    def run(self):
        """Execute full statistics collection and display."""
        if not self.connect():
            return False

        try:
            print(f"\n{Colors.BLUE}🔍 Querying database...{Colors.NC}")

            # Get all tables
            tables = self.get_all_tables()

            if not tables:
                print(f"{Colors.RED}❌ No tables found{Colors.NC}")
                return False

            # Display header
            self.print_header(self.project_id)

            # Display statistics
            self.print_quick_stats(tables)
            tables_by_schema = self.print_table_listing(tables)
            self.print_schema_summary(tables_by_schema)
            self.print_type_summary(tables)

            # Footer
            print("─" * 90)
            print(
                f"{Colors.GREEN}✅ Database statistics generated successfully{Colors.NC}\n"
            )

            return True

        except Exception as e:
            print(f"{Colors.RED}❌ Error: {e}{Colors.NC}")
            import traceback

            traceback.print_exc()
            return False
        finally:
            self.disconnect()


def load_environment() -> Tuple[str, str, Optional[str]]:
    """
    Load environment variables from .env file.

    Returns:
        Tuple of (database_url, project_id, error_message)
    """
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    env_file = project_root / ".env"

    if not env_file.exists():
        return None, None, f"❌ .env file not found at {env_file}"

    dotenv.load_dotenv(env_file)

    supabase_url = os.getenv("SUPABASE_URL")
    supabase_password = os.getenv("SUPABASE_PASSWORD")
    shared_pooler = os.getenv("SHARED_POOLER")

    if not supabase_url or not supabase_password:
        missing = []
        if not supabase_url:
            missing.append("SUPABASE_URL")
        if not supabase_password:
            missing.append("SUPABASE_PASSWORD")
        error_msg = f"❌ Missing required: {', '.join(missing)}\n"
        error_msg += "\nAdd to .env:\n"
        error_msg += "  SUPABASE_URL=https://xxx.supabase.co\n"
        error_msg += "  SUPABASE_PASSWORD=your_password"
        return None, None, error_msg

    # Extract project ID from URL (xxx.supabase.co)
    try:
        project_id = supabase_url.split("https://")[1].split(".")[0]
    except (IndexError, ValueError):
        project_id = "unknown"

    # Use connection pooler if available (works better from restricted networks)
    if shared_pooler:
        print(f"{Colors.BLUE}  (Using connection pooler){Colors.NC}")
        return shared_pooler, project_id, None

    # Build connection string: postgresql://postgres:password@db.xxx.supabase.co:5432/postgres
    db_host = f"db.{project_id}.supabase.co"
    db_url = f"postgresql://postgres:{supabase_password}@{db_host}:5432/postgres"
    return db_url, project_id, None


def main():
    """Main entry point."""
    print(f"{Colors.BLUE}🔍 Loading configuration...{Colors.NC}")

    db_url, project_id, error = load_environment()

    if error:
        print(f"{Colors.RED}{error}{Colors.NC}", file=sys.stderr)
        sys.exit(1)

    stats = SupabaseDatabaseStats(db_url, project_id)
    success = stats.run()

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
