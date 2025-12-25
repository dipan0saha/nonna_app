# Local vs Production — RLS & Environment Pitfalls

Docker and local development do a great job of reproducing the runtime, but there are several "silent killers" that can make Row Level Security (RLS) policies or database functions succeed locally and fail in your Supabase production project.

This document explains the most common causes, how they impact RLS, how to detect them, and concrete mitigations.

---

## 1. Version Mismatch (PostgreSQL Extensions)

**What happens:**  
Your local Docker image can run a different extension version than Supabase production.

**Risk:**  
You may use an extension-specific feature locally that is not available or behaves differently in production.

**RLS Impact:**  
Policies that depend on extension behavior or functions can fail to evaluate correctly in production.

**How to Detect:**  
Run the same SQL/migration on a staging Supabase project and compare `SELECT extname, extversion FROM pg_extension;` on both environments.

**Mitigation:**  
- Include `CREATE EXTENSION IF NOT EXISTS ...` statements in migrations when an extension is required.  
- Use a staging project that mirrors production for final verification.

---

## 2. Auth Schema Timing / Race Conditions

**What happens:**  
Locally the auth and public schemas are tightly coupled; in production Supabase Auth is a separate service and user metadata may lag briefly.

**Risk:**  
Policies that immediately read `auth.jwt()` metadata or expect joined auth rows to exist can see `NULL` for a short time after signup/login.

**RLS Impact:**  
Policies may deny access transiently, causing surprising permission errors in production but not locally.

**How to Detect:**  
Reproduce flow in staging with short delays; add logging inside policies or function wrappers to capture `auth.jwt()` contents.

**Mitigation:**  
- Make RLS checks resilient to missing metadata (e.g., treat `NULL` as unauthenticated but allow short grace periods in your application flow).  
- If using metadata that comes from external services, add retries in the app or defer policy-critical actions until metadata is present.

---

## 3. Case Sensitivity and Collation Differences

**What happens:**  
Local filesystem/DB settings may hide case sensitivity issues that the production server enforces.

**Risk:**  
Queries comparing strings (emails, role names) without normalization can succeed locally and fail in production.

**RLS Impact:**  
Policies doing exact string matches will be brittle across environments.

**How to Detect:**  
Run queries on staging/prod that compare values with different casing. Add tests that assert case-insensitive behavior where required.

**Mitigation:**  
- Normalize comparisons using `LOWER()` (or explicit collations) in both policies and application code.

---

## 4. Search Path / Schema Qualification Issues

**What happens:**  
Locally the search_path can implicitly find functions/tables; production is stricter.

**Risk:**  
Functions or policies that call unqualified names (`check_is_admin()`) may fail because the function isn't found in the production search_path.

**RLS Impact:**  
Policies can error at runtime due to missing function references.

**How to Detect:**  
Check logs or run the failing SQL in production; errors will indicate "function not found" or similar.

**Mitigation:**  
- Always qualify function calls with schema, e.g. `public.check_is_admin()`.  
- Include `SET search_path` in migration wrappers only when necessary and explicit.

---

## 5. Extension Availability

**What happens:**  
Some extensions you enable locally may not be present in production unless installed via migrations.

**Risk:**  
Relying on an enabled extension locally without declaring it in migrations will break production.

**RLS Impact:**  
Triggers, functions, or policies using extension-provided features will fail.

**How to Detect:**  
Running migrations on staging/prod will fail if an extension is missing; logs will show missing symbols.

**Mitigation:**  
- Add `CREATE EXTENSION IF NOT EXISTS extension_name;` to a migration that runs before any objects that depend on it.

---

## 6. Timezone Discrepancies

**What happens:**  
Local containers may default to your machine timezone; Supabase production uses UTC.

**Risk:**  
Time-based policies or checks can behave differently across environments (e.g., "within 24 hours").

**RLS Impact:**  
Policies that compare `now()` against stored `timestamp` values can allow access locally and deny it in production.

**How to Detect:**  
Compare results of `SELECT now(), current_setting('TIMEZONE');` locally vs production.

**Mitigation:**  
- Use `TIMESTAMPTZ` (timestamp with time zone) everywhere for stored times.  
- Normalize to UTC in policies and application logic.

---

## Preventive Checklist (Practical Rules)

- Use `TIMESTAMPTZ` for all timestamps — never use plain `TIMESTAMP` without time zone.  
- Always qualify schema objects (e.g., `public.my_function()`), especially in policies and functions.  
- Declare required extensions in migrations via `CREATE EXTENSION IF NOT EXISTS ...`.  
- Test in a staging Supabase project that mirrors production before promoting changes.  
- Use the Supabase CLI / SQL migration files for any production changes — avoid manual edits in the dashboard UI.  
- Normalize string comparisons with `LOWER()` where case-insensitive logic is required.  
- Add lightweight integration tests that exercise RLS policies against a seeded staging DB.  
- If you rely on auth metadata immediately after signup, design the flow to tolerate a short propagation delay (or add client retries).

---

## Quick Commands & Tips

**List installed extensions:**  
```sql
SELECT extname, extversion FROM pg_extension;
```

**Ensure extension is installed in migrations:**  
```sql
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
```

**Convert a column to timestamptz safely (example):**  
```sql
ALTER TABLE my_table
    ALTER COLUMN created_at TYPE timestamptz USING created_at AT TIME ZONE 'UTC';
```

---

## Additional Help

If you'd like, I can also:  
- Create a small staging checklist script that runs these verification queries against a project, or  
- Add a CI job that runs the RLS-related integration tests against a staging database.

Happy to implement either next — which would you prefer?