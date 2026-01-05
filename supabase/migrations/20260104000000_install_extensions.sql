-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pgcrypto for encryption functions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Enable pg_stat_statements for query performance monitoring
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Install pgTAP extension
CREATE EXTENSION IF NOT EXISTS "pgtap";

-- Set timezone to UTC (recommended)
ALTER DATABASE postgres SET timezone TO 'UTC';
