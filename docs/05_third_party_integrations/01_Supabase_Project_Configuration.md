# Supabase Project Configuration Document

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Team  
**Status**: Configuration Guide  
**Section**: 2.3 - Third-Party Integrations Setup

## Executive Summary

This document provides comprehensive guidance for setting up and configuring a Supabase project for the Nonna App. Supabase serves as the Backend-as-a-Service (BaaS) platform, providing authentication, database (PostgreSQL), storage, real-time subscriptions, and serverless functions (Edge Functions). This guide covers project creation, environment configuration, service setup, and production readiness.

## References

This document is informed by:

- `docs/01_technical_requirements/api_integration_plan.md` - Supabase integration strategy
- `docs/02_architecture_design/database_schema_design.md` - Database configuration requirements
- `docs/02_architecture_design/security_privacy_architecture.md` - Security configurations
- `docs/Production_Readiness_Checklist.md` - Section 2.3 requirements

---

## 1. Supabase Project Setup

### 1.1 Prerequisites

Before starting, ensure you have:

- [ ] Valid email address for Supabase account creation
- [ ] GitHub account (recommended for OAuth integration)
- [ ] Credit card (optional, for paid features)
- [ ] Access to development environment (Flutter SDK installed)
- [ ] Understanding of PostgreSQL basics

**Recommended Knowledge**:
- PostgreSQL/SQL fundamentals
- REST API concepts
- JWT authentication basics
- Row-Level Security (RLS) concepts

### 1.2 Create Supabase Account

**Step 1: Sign Up**

1. Navigate to [https://supabase.com](https://supabase.com)
2. Click "Start your project" or "Sign In"
3. Choose sign-up method:
   - **GitHub OAuth** (Recommended): Click "Continue with GitHub"
   - **Email/Password**: Enter email and create password
4. Verify email address if using email/password method
5. Complete account setup

**Step 2: Accept Terms of Service**

- Review Supabase Terms of Service
- Review Privacy Policy
- Accept terms to proceed

**Step 3: Account Verification**

- Check email for verification link
- Click verification link to activate account
- Return to Supabase dashboard

### 1.3 Create Nonna App Project

**Step 1: Create New Project**

1. From Supabase dashboard, click "New Project"
2. Fill in project details:
   - **Name**: `nonna-app` (or `nonna-app-dev` for development)
   - **Database Password**: Generate strong password (save securely!)
     - Minimum 8 characters
     - Include uppercase, lowercase, numbers, special characters
     - Use password manager (e.g., 1Password, LastPass)
   - **Region**: Select closest to your primary users
     - North America: `us-east-1` (N. Virginia) or `us-west-1` (California)
     - Europe: `eu-west-1` (Ireland) or `eu-central-1` (Frankfurt)
     - Asia: `ap-southeast-1` (Singapore) or `ap-northeast-1` (Tokyo)
   - **Pricing Plan**: Start with Free tier
     - Free: 500MB database, 1GB file storage, 2GB bandwidth/month
     - Pro: $25/month - 8GB database, 100GB storage, 50GB bandwidth
     - Team: $599/month - 100GB database, 200GB storage, 250GB bandwidth
3. Click "Create new project"
4. Wait 2-3 minutes for project provisioning

**Step 2: Save Project Credentials**

⚠️ **CRITICAL**: Save these credentials immediately in a secure location (e.g., password manager)

1. Navigate to Project Settings → API
2. Copy and save the following:
   - **Project URL**: `https://[project-ref].supabase.co`
   - **Anon (public) Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (safe to expose in client apps)
   - **Service Role Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (**SECRET - never expose in client**)
   - **JWT Secret**: Used for token signing (not typically needed in app code)
3. Navigate to Project Settings → Database
4. Copy and save:
   - **Connection String**: `postgresql://postgres:[password]@[host]:5432/postgres`
   - **Connection Pooling String**: `postgresql://postgres:[password]@[host]:6543/postgres`

**Step 3: Configure Project Settings**

1. Navigate to Project Settings → General
2. Set project timezone (UTC recommended for consistency)
3. Enable/disable email notifications for project events
4. Configure project display name and icon (optional)

### 1.4 Environment Configuration

**Development Environment Setup**

Create `.env` file in project root (add to `.gitignore`):

```env
# Supabase Configuration - Development
SUPABASE_URL=https://[your-project-ref].supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
# NEVER commit SERVICE_ROLE_KEY to Git - only for Edge Functions
```

**Flutter App Configuration**

Create `lib/core/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  // Load from environment or build-time configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT_REF.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_ANON_KEY',
  );
  
  // Optionally load from secure storage or assets
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authFlowType: AuthFlowType.pkce, // Recommended for mobile
    );
  }
}
```

**Staging Environment**

Create separate Supabase project for staging:
- **Name**: `nonna-app-staging`
- Use same configuration steps as development
- Different credentials from production

**Production Environment**

Create production Supabase project:
- **Name**: `nonna-app-prod`
- Use Pro tier for better performance and support
- Configure backup strategy
- Enable point-in-time recovery
- Set up monitoring and alerts

### 1.5 Project Dashboard Overview

**Main Dashboard Sections**:

1. **Home**: Project overview, recent activity, quick links
2. **Table Editor**: Visual database table editor
3. **SQL Editor**: Execute SQL queries and migrations
4. **Database**: Schema, indexes, extensions, replication
5. **Authentication**: User management, auth settings, email templates
6. **Storage**: File buckets, upload management, policies
7. **Edge Functions**: Serverless function deployment and logs
8. **Realtime**: WebSocket connection management, subscriptions
9. **API Docs**: Auto-generated API documentation
10. **Logs**: Query logs, function logs, error tracking
11. **Reports**: Performance metrics, usage statistics
12. **Settings**: Project configuration, billing, team access

**Key Dashboard Actions**:

- **Monitor Usage**: Check database size, API calls, bandwidth
- **View Logs**: Debug issues with query logs and error messages
- **Manage Users**: View auth users, reset passwords, ban users
- **Execute Migrations**: Run SQL scripts for schema changes
- **Test APIs**: Use built-in API explorer to test endpoints

---

## 2. Service Configuration

### 2.1 Database Service Setup

**Step 1: Enable PostgreSQL Extensions**

Navigate to Database → Extensions and enable:

```sql
-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pgcrypto for additional encryption functions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Enable pg_stat_statements for query performance monitoring
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
```

**Step 2: Configure Connection Pooling**

1. Navigate to Database → Connection Pooling
2. Enable connection pooling (recommended for production)
3. Set pool size based on expected load:
   - Development: 5-10 connections
   - Staging: 10-20 connections
   - Production: 20-100 connections (adjust based on usage)

**Step 3: Set Database Timezone**

```sql
-- Set timezone to UTC (recommended)
ALTER DATABASE postgres SET timezone TO 'UTC';
```

### 2.2 Authentication Service Setup

**Step 1: Configure Auth Settings**

Navigate to Authentication → Settings:

1. **Site URL**: Set to your app's URL
   - Development: `http://localhost:3000` (or custom scheme)
   - Production: `https://nonna.app` or app deep link scheme
2. **Redirect URLs**: Add allowed redirect URLs
   - `io.supabase.nonna://login-callback/` (for mobile OAuth)
   - `https://nonna.app/auth/callback` (for web)
3. **JWT Expiry**: Set token expiration (default: 3600 seconds / 1 hour)
4. **Refresh Token Rotation**: Enable for security (recommended)
5. **Enable Email Confirmations**: Require email verification
6. **Disable Sign-ups** (Optional): If implementing invite-only signup

**Step 2: Configure Email Templates**

Navigate to Authentication → Email Templates:

1. **Confirmation Email**:
   - Customize subject: "Verify your email for Nonna"
   - Edit HTML template with brand colors and logo
   - Test email delivery

2. **Password Reset Email**:
   - Customize subject: "Reset your Nonna password"
   - Edit HTML template
   - Test password reset flow

3. **Magic Link Email** (Optional):
   - Configure if using magic link authentication
   - Customize email content

**Step 3: Configure Auth Providers**

Configure authentication methods (see `02_Authentication_Setup_Guide.md` for details):

- Email/Password (enabled by default)
- Google OAuth (requires Google Cloud Console setup)
- Facebook OAuth (requires Facebook Developer setup)

### 2.3 Storage Service Setup

**Step 1: Create Storage Buckets**

Navigate to Storage and create buckets:

1. **user-avatars** (Public bucket)
   - Public: Yes
   - File size limit: 5MB
   - Allowed MIME types: `image/jpeg`, `image/png`, `image/webp`

2. **baby-profile-photos** (Public bucket)
   - Public: Yes
   - File size limit: 5MB
   - Allowed MIME types: `image/jpeg`, `image/png`, `image/webp`

3. **gallery-photos** (Private bucket with RLS)
   - Public: No
   - File size limit: 10MB
   - Allowed MIME types: `image/jpeg`, `image/png`

4. **event-photos** (Private bucket with RLS)
   - Public: No
   - File size limit: 10MB
   - Allowed MIME types: `image/jpeg`, `image/png`

**Step 2: Configure Bucket Policies**

See `03_Cloud_Storage_Configuration.md` for detailed bucket policies and RLS setup.

### 2.4 Realtime Service Setup

**Step 1: Enable Realtime**

Navigate to Database → Replication:

1. Enable Realtime for tables:
   - `photos`
   - `events`
   - `photo_comments`
   - `event_comments`
   - `notifications`
   - `owner_update_markers` (for cache invalidation)

2. Configure realtime settings:
   - Max concurrent connections: 10,000 (Free tier: 200)
   - Max rows per query: 1000
   - Enable broadcast and presence features (optional)

**Step 2: Test Realtime Subscriptions**

```dart
// Test realtime subscription
final subscription = supabase
  .from('photos')
  .stream(primaryKey: ['id'])
  .listen((data) {
    print('New photo: $data');
  });
```

### 2.5 Edge Functions Setup

**Step 1: Install Supabase CLI**

```bash
# macOS/Linux
brew install supabase/tap/supabase

# Windows (via Scoop)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# Or via npm
npm install -g supabase
```

**Step 2: Initialize Edge Functions**

```bash
# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref [your-project-ref]

# Create Edge Functions directory
supabase functions new generate-thumbnail
supabase functions new send-invitation-email
supabase functions new send-push-notification
```

**Step 3: Configure Function Environment Variables**

```bash
# Set secrets for Edge Functions
supabase secrets set SENDGRID_API_KEY=SG.xxx
supabase secrets set ONESIGNAL_API_KEY=os_xxx
supabase secrets set ONESIGNAL_APP_ID=app_xxx
```

See `05_Push_Notification_Configuration.md` for Edge Function implementations.

---

## 3. Security Configuration

### 3.1 Row-Level Security (RLS)

**Enable RLS on All Tables**:

```sql
-- Enable RLS for all application tables
ALTER TABLE baby_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE baby_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE registry_items ENABLE ROW LEVEL SECURITY;
-- ... (enable for all 27 public schema tables)
```

**Create RLS Policies**:

See `04_Database_Setup_Document.md` for comprehensive RLS policy definitions.

### 3.2 API Key Security

**Best Practices**:

✅ **DO**:
- Store `SUPABASE_ANON_KEY` in client app (safe to expose)
- Store `SERVICE_ROLE_KEY` only in Edge Functions or secure backend
- Use environment variables for all keys
- Rotate keys periodically (every 90 days recommended)
- Use different keys for dev/staging/prod

❌ **DON'T**:
- Commit `SERVICE_ROLE_KEY` to Git
- Hardcode keys in source code
- Share keys via email or Slack
- Use production keys in development

**Key Rotation Process**:

1. Generate new API keys in Project Settings → API
2. Update environment variables in all environments
3. Deploy updated configuration
4. Verify new keys work
5. Revoke old keys after grace period (24-48 hours)

### 3.3 Database Security

**Connection Security**:

- All connections use SSL/TLS by default
- Connection strings include `sslmode=require`
- Use connection pooling for production (prevents connection exhaustion)
- Whitelist IP addresses if using direct PostgreSQL connections (not recommended)

**Backup Security**:

- Enable automatic daily backups (Pro tier)
- Enable point-in-time recovery for critical data (Pro/Team tier)
- Backups encrypted at rest (AES-256)
- Test restore process quarterly

---

## 4. Performance Optimization

### 4.1 Database Performance

**Indexing**:

```sql
-- Create indexes on foreign keys (critical for joins)
CREATE INDEX idx_photos_baby_profile_id ON photos(baby_profile_id);
CREATE INDEX idx_baby_memberships_user_id ON baby_memberships(user_id);
CREATE INDEX idx_baby_memberships_baby_profile_id ON baby_memberships(baby_profile_id);

-- Create composite indexes for common queries
CREATE INDEX idx_photos_baby_created ON photos(baby_profile_id, created_at DESC);
CREATE INDEX idx_events_baby_date ON events(baby_profile_id, event_date ASC);
```

**Query Optimization**:

- Use `EXPLAIN ANALYZE` to analyze slow queries
- Monitor query performance in Database → Query Performance
- Add indexes for frequently filtered/sorted columns
- Use pagination (LIMIT/OFFSET) for large result sets
- Avoid `SELECT *` - specify only needed columns

### 4.2 Storage Performance

**CDN Configuration**:

- Supabase Storage uses CDN by default
- Use `getPublicUrl()` with transformations for optimized images:

```dart
final url = supabase.storage
  .from('gallery-photos')
  .getPublicUrl(
    'photo.jpg',
    transform: TransformOptions(
      width: 300,
      height: 300,
      resize: ResizeMode.cover,
    ),
  );
```

**File Compression**:

- Compress images client-side before upload (target: < 1MB per photo)
- Use WebP format for better compression (70% smaller than JPEG)
- Generate thumbnails via Edge Function for faster loading

### 4.3 Realtime Performance

**Subscription Optimization**:

- Always filter subscriptions by `baby_profile_id` to reduce unnecessary data
- Unsubscribe when component unmounts to prevent memory leaks
- Use `owner_update_markers` table to batch updates (see Database Design doc)
- Limit concurrent subscriptions per user (recommend < 10)

**Example Optimized Subscription**:

```dart
// Good: Filtered subscription
final subscription = supabase
  .from('photos:baby_profile_id=eq.$babyId')
  .stream(primaryKey: ['id'])
  .listen((data) { /* handle */ });

// Bad: Unfiltered subscription (receives all updates)
// final subscription = supabase
//   .from('photos')
//   .stream(primaryKey: ['id'])
//   .listen((data) { /* handle */ });
```

---

## 5. Monitoring and Maintenance

### 5.1 Usage Monitoring

**Monitor Key Metrics**:

Navigate to Reports → Overview:

1. **Database Size**: Track growth (alert at 80% of plan limit)
2. **API Requests**: Monitor request volume and rate
3. **Bandwidth**: Track inbound/outbound data transfer
4. **Storage Size**: Monitor file storage usage
5. **Realtime Connections**: Track concurrent WebSocket connections
6. **Edge Function Invocations**: Monitor function call volume

**Set Up Alerts**:

1. Navigate to Project Settings → Alerts
2. Configure alerts for:
   - Database size > 80% of limit
   - API error rate > 5%
   - Slow query detection (> 1 second)
   - Realtime connection limit reached
3. Set notification email or webhook

### 5.2 Log Management

**Query Logs**:

- Navigate to Logs → Query Logs
- Filter by date range, status code, duration
- Export logs for further analysis
- Set up log retention policy (7 days on Free tier)

**Edge Function Logs**:

- Navigate to Edge Functions → [Function Name] → Logs
- View function execution logs, errors, and performance
- Use `console.log()` in functions for debugging
- Monitor function cold start times

**Error Tracking**:

- Integrate with Sentry for comprehensive error tracking
- Configure Sentry DSN in Flutter app
- Monitor error rates and patterns
- Set up alerts for critical errors

### 5.3 Backup and Recovery

**Automated Backups** (Pro tier and above):

1. Navigate to Database → Backups
2. Enable daily automated backups
3. Configure backup retention (7-30 days)
4. Test restore process monthly

**Manual Backup**:

```bash
# Export database schema and data
pg_dump --host=db.[project-ref].supabase.co \
  --username=postgres \
  --dbname=postgres \
  --schema=public \
  --file=nonna_backup_$(date +%Y%m%d).sql

# Restore from backup
psql --host=db.[project-ref].supabase.co \
  --username=postgres \
  --dbname=postgres \
  --file=nonna_backup_20260104.sql
```

**Point-in-Time Recovery** (Pro tier):

- Enable in Database → Backups
- Recover to any point in the last 7 days
- Useful for accidental data deletion

### 5.4 Maintenance Tasks

**Weekly Tasks**:

- [ ] Review slow query report
- [ ] Check error logs for anomalies
- [ ] Monitor storage and database size growth
- [ ] Review API usage patterns

**Monthly Tasks**:

- [ ] Test backup restore process
- [ ] Review and optimize database indexes
- [ ] Audit RLS policies for security gaps
- [ ] Review and update Edge Functions
- [ ] Check for Supabase platform updates

**Quarterly Tasks**:

- [ ] Rotate API keys (security best practice)
- [ ] Comprehensive security audit
- [ ] Performance benchmarking
- [ ] Review and adjust pricing plan if needed
- [ ] Update disaster recovery documentation

---

## 6. Migration to Production

### 6.1 Pre-Production Checklist

Before migrating to production:

- [ ] All database migrations tested in staging
- [ ] RLS policies validated with comprehensive tests
- [ ] Edge Functions deployed and tested
- [ ] Storage buckets configured with correct policies
- [ ] Authentication providers configured and tested
- [ ] Environment variables set correctly
- [ ] Monitoring and alerts configured
- [ ] Backup strategy implemented and tested
- [ ] Performance benchmarks met
- [ ] Security audit completed

### 6.2 Production Deployment

**Step 1: Create Production Project**

- Follow steps in Section 1.3 for production project
- Use Pro tier for better performance and support
- Enable point-in-time recovery
- Set up automated backups

**Step 2: Run Migrations**

```bash
# Link to production project
supabase link --project-ref [prod-project-ref]

# Apply all migrations
supabase db push

# Verify migrations
supabase db diff
```

**Step 3: Deploy Edge Functions**

```bash
# Deploy all Edge Functions to production
supabase functions deploy generate-thumbnail --project-ref [prod-ref]
supabase functions deploy send-invitation-email --project-ref [prod-ref]
supabase functions deploy send-push-notification --project-ref [prod-ref]

# Set production secrets
supabase secrets set --project-ref [prod-ref] SENDGRID_API_KEY=SG.prod.xxx
supabase secrets set --project-ref [prod-ref] ONESIGNAL_API_KEY=os.prod.xxx
```

**Step 4: Update Flutter App Configuration**

```dart
// Use environment-based configuration
class SupabaseConfig {
  static const String supabaseUrl = bool.fromEnvironment('dart.vm.product')
    ? 'https://prod-project-ref.supabase.co'
    : 'https://dev-project-ref.supabase.co';
    
  static const String supabaseAnonKey = bool.fromEnvironment('dart.vm.product')
    ? 'PROD_ANON_KEY'
    : 'DEV_ANON_KEY';
}
```

**Step 5: Smoke Test Production**

- [ ] Test user registration and email verification
- [ ] Test login with all auth providers
- [ ] Test photo upload and download
- [ ] Test realtime subscriptions
- [ ] Test Edge Function invocations
- [ ] Verify RLS policies work correctly
- [ ] Monitor logs for errors

### 6.3 Rollback Plan

If issues occur in production:

1. **Immediate**: Switch Flutter app back to staging environment
2. **Database**: Restore from backup or point-in-time recovery
3. **Edge Functions**: Roll back to previous deployment
4. **Communication**: Notify users of temporary issues
5. **Root Cause**: Investigate and fix issues in staging
6. **Re-deploy**: Once fixed, deploy to production again

---

## 7. Troubleshooting Guide

### 7.1 Common Issues

**Issue: "Failed to initialize Supabase"**

Symptoms:
- App crashes on startup
- Error: "Invalid API key" or "Invalid URL"

Solutions:
1. Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` are correct
2. Check for trailing slashes in URL (should not have one)
3. Ensure keys are not wrapped in quotes in code
4. Verify project is active in Supabase dashboard
5. Check network connectivity

**Issue: "Row-Level Security policy violation"**

Symptoms:
- Database queries return empty results or errors
- Error: "new row violates row-level security policy"

Solutions:
1. Verify user is authenticated (`supabase.auth.currentUser` is not null)
2. Check if user has required role (owner/follower) in `baby_memberships`
3. Verify RLS policies are correctly defined
4. Test policies with pgTAP or manual SQL queries
5. Check if `baby_profile_id` foreign key is correct

**Issue: "Storage bucket not found"**

Symptoms:
- Photo upload fails
- Error: "Bucket not found" or "Access denied"

Solutions:
1. Verify bucket name matches exactly (case-sensitive)
2. Check bucket exists in Storage dashboard
3. Verify storage policies allow upload for authenticated user
4. Ensure user has correct role for private buckets
5. Check file size and MIME type restrictions

**Issue: "Edge Function timeout"**

Symptoms:
- Function invocation hangs or times out
- Error: "Function execution timed out"

Solutions:
1. Check function logs for errors or performance issues
2. Optimize function code (reduce external API calls)
3. Increase function timeout (max 60 seconds on Free tier)
4. Use async/await properly
5. Test function locally with `supabase functions serve`

**Issue: "Realtime subscription not receiving updates"**

Symptoms:
- UI doesn't update in real-time
- No events received from subscription

Solutions:
1. Verify Realtime is enabled for the table (Database → Replication)
2. Check subscription filter matches the data (e.g., correct `baby_profile_id`)
3. Ensure WebSocket connection is established (check browser dev tools)
4. Verify no network firewall blocking WebSocket connections
5. Check if subscription was disposed/unsubscribed

### 7.2 Performance Issues

**Slow Database Queries**:

1. Use `EXPLAIN ANALYZE` to identify bottlenecks:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM photos
   WHERE baby_profile_id = 'uuid'
   ORDER BY created_at DESC
   LIMIT 30;
   ```
2. Check if indexes exist on filtered/sorted columns
3. Avoid `SELECT *` - specify only needed columns
4. Use pagination for large result sets
5. Monitor query performance in Database → Query Performance

**High API Latency**:

1. Check server region - should be close to users
2. Monitor API response times in Reports
3. Optimize database queries (see above)
4. Use caching where appropriate (client-side with Hive/Isar)
5. Enable connection pooling (Project Settings → Database)

**Storage Upload Slow**:

1. Compress images client-side before upload
2. Use CDN URLs for faster download
3. Check upload file size (max 10MB recommended)
4. Monitor bandwidth usage in Reports
5. Consider upgrading Supabase plan for more bandwidth

---

## 8. Security Best Practices

### 8.1 Authentication Security

✅ **DO**:
- Require email verification before full access
- Use OAuth providers for easier, more secure login
- Implement rate limiting on login attempts (done by Supabase Auth)
- Store JWT tokens securely (Keychain/Keystore)
- Invalidate tokens on logout
- Use PKCE flow for mobile OAuth (recommended)

❌ **DON'T**:
- Store passwords in plaintext (never)
- Allow weak passwords (enforce minimum complexity)
- Skip email verification for production
- Share authentication tokens between users
- Log authentication tokens

### 8.2 Database Security

✅ **DO**:
- Enable RLS on all tables (except system tables)
- Test RLS policies comprehensively
- Use parameterized queries (Supabase client does this automatically)
- Encrypt sensitive data at application level if needed
- Regularly backup database
- Use least-privilege principle for database roles

❌ **DON'T**:
- Disable RLS in production
- Use `SERVICE_ROLE_KEY` in client app (bypasses RLS)
- Construct SQL queries with string concatenation
- Grant excessive permissions to database roles
- Store unencrypted sensitive data (e.g., SSNs, credit cards)

### 8.3 Storage Security

✅ **DO**:
- Use signed URLs for private files
- Set appropriate MIME type restrictions
- Validate file size client-side and server-side
- Scan uploaded files for malware (future enhancement)
- Use RLS policies on storage buckets
- Expire signed URLs after reasonable time (e.g., 1 hour)

❌ **DON'T**:
- Make all buckets public
- Allow unrestricted file uploads
- Store executable files (security risk)
- Use predictable file names (use UUIDs)
- Skip file type validation

---

## 9. Cost Management

### 9.1 Free Tier Limits

**Supabase Free Tier**:

- **Database**: 500MB
- **File Storage**: 1GB
- **Bandwidth**: 2GB/month
- **Realtime Connections**: 200 concurrent
- **Edge Function Invocations**: 500K/month
- **API Requests**: Unlimited (soft rate limit)

**When to Upgrade**:

- Database approaching 500MB → Upgrade to Pro ($25/month)
- Storage exceeding 1GB → Upgrade or optimize image compression
- Bandwidth exceeding 2GB/month → Upgrade or use external CDN
- Need point-in-time recovery → Upgrade to Pro
- Need dedicated support → Upgrade to Pro or Team

### 9.2 Cost Optimization Strategies

**Database**:

- Archive old data beyond retention period (soft deletes after 7 years)
- Use JSONB columns sparingly (can bloat database)
- Regularly VACUUM and ANALYZE tables
- Monitor database size in Reports

**Storage**:

- Compress images before upload (target: < 1MB per photo)
- Delete orphaned files (files in storage but not in database)
- Use WebP format for smaller file sizes
- Generate thumbnails instead of loading full images

**Bandwidth**:

- Use CDN transformation URLs (cached)
- Implement client-side caching (Hive/Isar)
- Avoid re-downloading same files repeatedly
- Use pagination to limit data transfer

**Realtime**:

- Limit concurrent subscriptions per user
- Unsubscribe when component unmounts
- Use filtered subscriptions to reduce unnecessary data
- Consider polling for non-critical updates instead of realtime

---

## 10. Next Steps

After completing Supabase project setup:

1. **Review `02_Authentication_Setup_Guide.md`**: Configure authentication providers and flows
2. **Review `03_Cloud_Storage_Configuration.md`**: Set up storage buckets and policies
3. **Review `04_Database_Setup_Document.md`**: Create database schema and RLS policies
4. **Review `05_Push_Notification_Configuration.md`**: Set up OneSignal for push notifications
5. **Review `06_Analytics_Setup_Document.md`**: Configure analytics tracking

**Validation Checklist**:

- [ ] Supabase project created and accessible
- [ ] Project credentials saved securely
- [ ] Environment variables configured for all environments (dev/staging/prod)
- [ ] Database extensions enabled
- [ ] Connection pooling configured
- [ ] Storage buckets created
- [ ] Realtime enabled for required tables
- [ ] Edge Functions directory initialized
- [ ] RLS enabled on all tables
- [ ] Monitoring and alerts configured
- [ ] Backup strategy implemented
- [ ] Security best practices followed
- [ ] Performance optimization applied
- [ ] Documentation reviewed and understood

---

## Conclusion

This document provides comprehensive guidance for setting up and configuring a Supabase project for the Nonna App. Following these steps ensures a secure, performant, and scalable backend infrastructure ready for development and production deployment.

**Key Takeaways**:

- Supabase provides all-in-one BaaS platform (auth, database, storage, realtime, functions)
- Security is paramount - enable RLS, use secure token storage, rotate keys regularly
- Performance optimization is critical - use indexes, CDN, caching, pagination
- Monitoring and maintenance are ongoing - set up alerts, review logs, backup regularly
- Cost management is important - optimize database, storage, bandwidth usage

**For Issues or Questions**:

- Supabase Documentation: [https://supabase.com/docs](https://supabase.com/docs)
- Supabase Discord: [https://discord.supabase.com](https://discord.supabase.com)
- Supabase GitHub: [https://github.com/supabase/supabase](https://github.com/supabase/supabase)

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Next Review**: Before Core Development Phase (Section 3.x)  
**Status**: Configuration Guide - Ready for Implementation
