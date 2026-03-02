#!/usr/bin/env python3
"""
Supabase Database Query Executor

Executes SQL queries from a JSON configuration file against Supabase database.
Supports multiple named queries and displays results in formatted table.

Installation:
    cd /path/to/nonna_app
    source .venv/bin/activate
    pip3 install python-dotenv psycopg2-binary

Usage:
    python3 scripts/database_query.py <query_file> [query_name]
    python3 scripts/database_query.py scripts/sample_queries.json activity_events_sample
    python3 scripts/database_query.py scripts/sample_queries.json  # Lists available queries

Environment Variables Required:
    SUPABASE_URL      - Supabase project URL (https://xxx.supabase.co)
    SUPABASE_PASSWORD - Postgres password
    SHARED_POOLER     - Connection pooler URL (optional, preferred over direct connection)
"""

import json
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
    CYAN = "\033[0;36m"
    BOLD = "\033[1m"
    NC = "\033[0m"  # No Color


class SupabaseDatabaseQuery:
    """Executes queries against Supabase database and displays results."""

    def __init__(self, db_url: str, project_id: str):
        """
        Initialize with database connection details.

        Args:
            db_url: PostgreSQL connection URL
            project_id: Supabase project ID
        """
        self.db_url = db_url
        self.project_id = project_id
        self.connection = None
        self.cursor = None

    def connect(self) -> bool:
        """
        Establish database connection.

        Returns:
            True if successful, False otherwise
        """
        print(f"{Colors.BLUE}🔐 Connecting to Supabase database...{Colors.NC}")
        try:
            self.connection = psycopg2.connect(self.db_url)
            self.cursor = self.connection.cursor()
            print(f"{Colors.GREEN}✅ Connected{Colors.NC}\n")
            return True
        except psycopg2.Error as e:
            print(f"{Colors.RED}❌ Connection failed: {e}{Colors.NC}")
            return False

    def disconnect(self):
        """Close database connection."""
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()
        print(f"{Colors.CYAN}✅ Disconnected{Colors.NC}")

    def execute_query(
        self, query_sql: str
    ) -> Tuple[List[str], List[tuple], Optional[str]]:
        """
        Execute SQL query and fetch results.

        Args:
            query_sql: SQL query string

        Returns:
            Tuple of (column_names, rows, error_message)
        """
        try:
            self.cursor.execute(query_sql)
            columns = [desc[0] for desc in self.cursor.description]
            rows = self.cursor.fetchall()
            return columns, rows, None
        except psycopg2.Error as e:
            return [], [], str(e)

    def print_header(self, query_name: str, query_description: str):
        """Print formatted header for query results."""
        print("\n" + "╔" + "═" * 88 + "╗")
        print(
            f"║ {Colors.BOLD}{Colors.BLUE}📊 QUERY RESULTS{Colors.NC}" + " " * 70 + "║"
        )
        print("╚" + "═" * 88 + "╝")
        print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Project:   {self.project_id}")
        print(f"Query:     {Colors.CYAN}{query_name}{Colors.NC}")
        if query_description:
            print(f"Desc:      {query_description}")
        print()

    def print_results_table(self, columns: List[str], rows: List[tuple]):
        """Print query results in formatted table."""
        if not columns:
            print(f"{Colors.YELLOW}⚠️  No data returned{Colors.NC}\n")
            return

        if not rows:
            print(f"{Colors.YELLOW}⚠️  Query returned no rows{Colors.NC}\n")
            print(f"Columns available: {', '.join(columns)}\n")
            return

        # Calculate column widths
        col_widths = [len(col) for col in columns]
        for row in rows:
            for i, val in enumerate(row):
                col_widths[i] = max(col_widths[i], len(str(val)))

        # Limit width for display (max 30 chars per column)
        col_widths = [min(w, 30) for w in col_widths]

        # Print header
        header = " │ ".join(
            f"{Colors.BOLD}{col:{width}}{Colors.NC}"
            for col, width in zip(columns, col_widths)
        )
        sep = "─┼─".join("─" * width for width in col_widths)

        print("┌─" + sep + "─┐")
        print(f"│ {header} │")
        print("├─" + sep + "─┤")

        # Print rows
        for row in rows:
            cells = []
            for val, width in zip(row, col_widths):
                val_str = str(val) if val is not None else "NULL"
                # Truncate if too long
                if len(val_str) > width:
                    val_str = val_str[: width - 3] + "..."
                cells.append(f"{val_str:{width}}")
            print(f"│ {' │ '.join(cells)} │")

        print("└─" + sep + "─┘")
        print(f"\n{Colors.GREEN}✅ Total rows: {len(rows)}{Colors.NC}\n")

    def run_query(self, query_name: str, query_sql: str, description: str = ""):
        """Execute a query and display results."""
        self.print_header(query_name, description)

        columns, rows, error = self.execute_query(query_sql)

        if error:
            print(f"{Colors.RED}❌ Query failed: {error}{Colors.NC}\n")
            return False

        self.print_results_table(columns, rows)
        return True


def load_queries_from_json(query_file: str) -> Tuple[List[Dict], Optional[str]]:
    """
    Load queries from JSON file.

    Args:
        query_file: Path to JSON file containing queries

    Returns:
        Tuple of (queries, error_message)
    """
    try:
        with open(query_file, "r") as f:
            data = json.load(f)

        if "queries" in data and isinstance(data["queries"], list):
            return data["queries"], None
        else:
            return [], f"❌ JSON must contain 'queries' array"
    except FileNotFoundError:
        return [], f"❌ Query file not found: {query_file}"
    except json.JSONDecodeError as e:
        return [], f"❌ Invalid JSON format: {e}"


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
        error_msg = f"❌ Missing required: {', '.join(missing)}"
        return None, None, error_msg

    # Extract project ID from URL
    try:
        project_id = supabase_url.split("https://")[1].split(".")[0]
    except (IndexError, ValueError):
        project_id = "unknown"

    # Use connection pooler if available
    if shared_pooler:
        return shared_pooler, project_id, None

    # Build connection string
    db_host = f"db.{project_id}.supabase.co"
    db_url = f"postgresql://postgres:{supabase_password}@{db_host}:5432/postgres"
    return db_url, project_id, None


def list_available_queries(queries: List[Dict]):
    """Display list of available queries."""
    print(f"\n{Colors.BOLD}{Colors.BLUE}📋 AVAILABLE QUERIES{Colors.NC}\n")
    print("─" * 90)

    for i, query in enumerate(queries, 1):
        name = query.get("name", f"query_{i}")
        desc = query.get("description", "No description")
        print(f"{Colors.CYAN}{i}. {name}{Colors.NC}")
        print(f"   {desc}\n")

    print("─" * 90)


def main():
    """Main entry point."""
    print(f"{Colors.BLUE}🔍 Loading configuration...{Colors.NC}")

    # Get database connection
    db_url, project_id, error = load_environment()
    if error:
        print(f"{Colors.RED}{error}{Colors.NC}")
        sys.exit(1)

    # Get query file path
    if len(sys.argv) < 2:
        print(
            f"{Colors.RED}❌ Usage: python3 database_query.py <query_file> [query_name]{Colors.NC}"
        )
        print(f"\nExample:")
        print(f"  python3 database_query.py scripts/sample_queries.json")
        print(
            f"  python3 database_query.py scripts/sample_queries.json activity_events_sample\n"
        )
        sys.exit(1)

    query_file = sys.argv[1]
    query_name = sys.argv[2] if len(sys.argv) > 2 else None

    # Load queries from JSON
    queries, error = load_queries_from_json(query_file)
    if error:
        print(f"{Colors.RED}{error}{Colors.NC}")
        sys.exit(1)

    if not queries:
        print(f"{Colors.RED}❌ No queries found in {query_file}{Colors.NC}")
        sys.exit(1)

    # If no specific query requested, list available queries
    if not query_name:
        list_available_queries(queries)
        print(f"\n{Colors.YELLOW}💡 Run a specific query:{Colors.NC}")
        print(f"  python3 database_query.py {query_file} <query_name>\n")
        sys.exit(0)

    # Find and execute the requested query
    selected_query = None
    for query in queries:
        if query.get("name") == query_name:
            selected_query = query
            break

    if not selected_query:
        print(
            f"{Colors.RED}❌ Query '{query_name}' not found. Available queries:{Colors.NC}"
        )
        list_available_queries(queries)
        sys.exit(1)

    # Execute query
    executor = SupabaseDatabaseQuery(db_url, project_id)

    if not executor.connect():
        sys.exit(1)

    try:
        success = executor.run_query(
            selected_query.get("name", query_name),
            selected_query.get("sql", ""),
            selected_query.get("description", ""),
        )
        sys.exit(0 if success else 1)
    finally:
        executor.disconnect()


if __name__ == "__main__":
    main()
