# Edge Functions Deployment Guide

Complete step-by-step guide for deploying Nonna App Edge Functions to production.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Available Functions](#available-functions)
4. [Local Testing](#local-testing)
5. [Production Deployment](#production-deployment)
6. [Post-Deployment Verification](#post-deployment-verification)
7. [Monitoring & Troubleshooting](#monitoring--troubleshooting)
8. [Rollback Procedures](#rollback-procedures)
9. [Production Checklist](#production-checklist)

---

## Overview

Edge Functions are serverless functions deployed on Supabase (Deno runtime). They power:
- Image processing and thumbnail generation
- Email notifications for invitations
- Push notifications via OneSignal
- Real-time notification triggers
- Dynamic UI tile configuration

**Deployment Target**: Supabase Project `ubptybhhrgdiyfkcqgwu`

---

## Prerequisites

Before deploying, ensure you have:

### 1. Supabase CLI Installation
```bash
npm install -g supabase
```

Verify installation:
```bash
supabase --version
```

### 2. Authentication
```bash
supabase login
```

Follow the browser prompt to authenticate with your Supabase account.

### 3. Project Linking
```bash
cd /Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app
supabase link --project-ref ubptybhhrgdiyfkcqgwu
```

Confirm linking:
```bash
supabase status
```

### 4. Environment Variables

Ensure `.env` file contains required credentials:
```env
SUPABASE_URL=https://ubptybhhrgdiyfkcqgwu.supabase.co
SUPABASE_PASSWORD=LaNonnaApp24!!
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SENDGRID_API_KEY=your_sendgrid_api_key
ONESIGNAL_APP_ID=your_onesignal_app_id
ONESIGNAL_API_KEY=your_onesignal_api_key
```

---

## Available Functions

### 1. **generate-thumbnail**
- **Purpose**: Generates thumbnail images from uploaded photos
- **Trigger**: `storage.objects` INSERT on `photos` bucket
- **Response Time**: <500ms
- **Location**: `supabase/functions/generate-thumbnail/`

### 2. **image-processing**
- **Purpose**: Advanced image optimization and format conversion
- **Formats**: WebP, JPEG, PNG
- **Features**: Metadata extraction, batch processing
- **Location**: `supabase/functions/image-processing/`

### 3. **send-invitation-email**
- **Purpose**: Email notifications for baby profile invitations
- **Features**: Template-based messages, verification links, resend capability
- **Depends On**: SendGrid API
- **Location**: `supabase/functions/send-invitation-email/`

### 4. **send-push-notification**
- **Purpose**: Push notifications to mobile devices
- **Provider**: OneSignal
- **Features**: Batch sending, delivery tracking, retry logic
- **Depends On**: OneSignal API
- **Location**: `supabase/functions/send-push-notification/`

### 5. **notification-trigger**
- **Purpose**: Real-time notification generation
- **Pattern**: Event-driven architecture
- **Features**: Multi-user broadcasting, OneSignal integration
- **Location**: `supabase/functions/notification-trigger/`

### 6. **tile-configs**
- **Purpose**: Dynamic UI tile configuration generation
- **Features**: Role-based filtering (owner vs follower), cache-friendly
- **Response Time**: <100ms
- **Location**: `supabase/functions/tile-configs/`

---

## Local Testing

### Step 1: Start Local Development Server

```bash
cd /Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app
supabase functions dev
```

**Expected Output**:
```
Listening on http://localhost:54321
```

### Step 2: Test Each Function

In a new terminal, run the following test commands:

#### Test generate-thumbnail
```bash
curl -X POST http://localhost:54321/functions/v1/generate-thumbnail \
  -H "Content-Type: application/json" \
  -d '{"bucket":"photos","file_path":"test.jpg"}'
```

#### Test image-processing
```bash
curl -X POST http://localhost:54321/functions/v1/image-processing \
  -H "Content-Type: application/json" \
  -d '{"image_url":"https://example.com/image.jpg","format":"webp"}'
```

#### Test send-invitation-email
```bash
curl -X POST http://localhost:54321/functions/v1/send-invitation-email \
  -H "Content-Type: application/json" \
  -d '{
    "to_email":"user@example.com",
    "baby_name":"Emma",
    "sender_name":"John Doe",
    "invitation_link":"https://app.example.com/invite/abc123"
  }'
```

#### Test send-push-notification
```bash
curl -X POST http://localhost:54321/functions/v1/send-push-notification \
  -H "Content-Type: application/json" \
  -d '{
    "user_ids":["user-123"],
    "title":"New Event",
    "message":"Emma has a milestone event!",
    "type":"event_notification"
  }'
```

#### Test notification-trigger
```bash
curl -X POST http://localhost:54321/functions/v1/notification-trigger \
  -H "Content-Type: application/json" \
  -d '{
    "event_type":"photo_uploaded",
    "baby_id":"baby-123",
    "data":{"photo_id":"photo-456"}
  }'
```

#### Test tile-configs
```bash
curl -X GET http://localhost:54321/functions/v1/tile-configs \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

### Step 3: Run Unit Tests

Each function includes unit tests. Run them with:

```bash
# Test generate-thumbnail
deno test --allow-all supabase/functions/generate-thumbnail/index.test.ts

# Test image-processing
deno test --allow-all supabase/functions/image-processing/index.test.ts

# Test notification-trigger
deno test --allow-all supabase/functions/notification-trigger/index.test.ts

# Test tile-configs
deno test --allow-all supabase/functions/tile-configs/index.test.ts
```

### Step 4: Verify Configuration

Ensure `supabase/config.toml` is properly configured:

```toml
[functions.generate-thumbnail]
enabled = true
verify_jwt = true
import_map = "./functions/generate-thumbnail/deno.json"
entrypoint = "./functions/generate-thumbnail/index.ts"

[functions.image-processing]
enabled = true
verify_jwt = true
import_map = "./functions/image-processing/deno.json"
entrypoint = "./functions/image-processing/index.ts"

[functions.send-invitation-email]
enabled = true
verify_jwt = true
import_map = "./functions/send-invitation-email/deno.json"
entrypoint = "./functions/send-invitation-email/index.ts"

[functions.send-push-notification]
enabled = true
verify_jwt = true
import_map = "./functions/send-push-notification/deno.json"
entrypoint = "./functions/send-push-notification/index.ts"

[functions.notification-trigger]
enabled = true
verify_jwt = true
import_map = "./functions/notification-trigger/deno.json"
entrypoint = "./functions/notification-trigger/index.ts"

[functions.tile-configs]
enabled = true
verify_jwt = true
import_map = "./functions/tile-configs/deno.json"
entrypoint = "./functions/tile-configs/index.ts"
```

---

## Production Deployment

### Step 1: Verify All Functions Exist

```bash
supabase functions list
```

**Expected Output**:
```
✓ generate-thumbnail
✓ image-processing
✓ send-invitation-email
✓ send-push-notification
✓ notification-trigger
✓ tile-configs
```

### Step 2: Deploy All Functions

**Option A: Deploy Everything at Once** (Recommended for initial setup)

```bash
supabase functions deploy
```

**Option B: Deploy Individual Functions**

Deploy one function at a time for safer rollout:

```bash
# Deploy each function
supabase functions deploy generate-thumbnail
supabase functions deploy image-processing
supabase functions deploy send-invitation-email
supabase functions deploy send-push-notification
supabase functions deploy notification-trigger
supabase functions deploy tile-configs
```

**Expected Output**:
```
✓ Deployed generate-thumbnail to version abc123def456
✓ Deployed image-processing to version def456ghi789
✓ Deployed send-invitation-email to version ghi789jkl012
✓ Deployed send-push-notification to version jkl012mno345
✓ Deployed notification-trigger to version mno345pqr678
✓ Deployed tile-configs to version pqr678stu901
```

### Step 3: Configure Environment Variables in Production

Set secrets in Supabase Dashboard:

```bash
# Navigate to: Supabase Dashboard → Functions → Secrets
# Add the following:

SENDGRID_API_KEY = your_sendgrid_key
ONESIGNAL_APP_ID = your_onesignal_app_id
ONESIGNAL_API_KEY = your_onesignal_api_key
SERVICE_ROLE_KEY = your_service_role_key
SUPABASE_URL = https://ubptybhhrgdiyfkcqgwu.supabase.co
```

Or use CLI:

```bash
supabase secrets set SENDGRID_API_KEY "your_sendgrid_key"
supabase secrets set ONESIGNAL_APP_ID "your_onesignal_app_id"
supabase secrets set ONESIGNAL_API_KEY "your_onesignal_api_key"
```

---

## Post-Deployment Verification

### Step 1: Check Deployment Status

```bash
supabase functions list
```

All functions should show with recent deployment times.

### Step 2: View Function Logs

```bash
# View logs for a specific function
supabase functions logs generate-thumbnail
supabase functions logs tile-configs
supabase functions logs notification-trigger

# Follow logs in real-time
supabase functions logs generate-thumbnail --follow
```

### Step 3: Test Production Endpoints

Get your JWT token from the app, then test:

```bash
export SUPABASE_ANON_KEY="your_anon_key"
export BASE_URL="https://ubptybhhrgdiyfkcqgwu.supabase.co"

# Test tile-configs (example)
curl -X GET "$BASE_URL/functions/v1/tile-configs" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json"

# Expected Response:
# {
#   "owner_tiles": [...],
#   "follower_tiles": [...],
#   "cached_at": "2026-03-02T10:30:00Z"
# }
```

### Step 4: Verify Database Triggers

Ensure functions are triggered by database events:

```bash
# Check trigger setup in Supabase Dashboard:
# 1. Go to Database → Functions (under Edge Functions)
# 2. Verify these triggers are active:
#    - generate-thumbnail: storage.objects INSERT
#    - notification-trigger: public.activity_events INSERT
#    - send-invitation-email: public.invitations INSERT
```

---

## Monitoring & Troubleshooting

### View Real-time Logs

```bash
# All function logs
supabase functions logs

# Specific function with filtering
supabase functions logs send-invitation-email | grep "ERROR"

# Last N lines
supabase functions logs notification-trigger | tail -20
```

### Common Issues & Solutions

#### Issue: Function Returns 401 Unauthorized
**Cause**: JWT verification failure
**Solution**: Ensure `verify_jwt = true` is set in config.toml for required functions

```bash
# Disable JWT verification for public endpoints
# Edit config.toml:
[functions.generate-thumbnail]
verify_jwt = false
```

#### Issue: Function Timeout (>60 seconds)
**Cause**: Long-running operation
**Solution**: Break into smaller tasks or use async processing

```typescript
// Example: Use background job queue
await supabaseClient
  .from('function_queue')
  .insert({ task: 'process_images', status: 'pending' });
```

#### Issue: Environment Variable Not Found
**Cause**: Secret not set in production
**Solution**:

```bash
# Check secrets are set
supabase secrets list

# Set missing secret
supabase secrets set MISSING_KEY "value"

# Redeploy function
supabase functions deploy send-invitation-email
```

#### Issue: CORS Error from Frontend
**Cause**: Cross-origin request blocked
**Solution**: Update CORS headers in function response

```typescript
// In function index.ts
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

return new Response(JSON.stringify({ data: ... }), {
  headers: { ...corsHeaders, 'Content-Type': 'application/json' },
});
```

### Debug Mode

Enable verbose logging:

```bash
# Run with debug output
DENO_LOG=debug supabase functions dev

# Check function execution
supabase functions logs --follow
```

---

## Rollback Procedures

### Rollback to Previous Version

If deployment causes issues:

```bash
# View deployment history
supabase functions describe generate-thumbnail

# List all versions
supabase functions versions generate-thumbnail

# Redeploy previous version
supabase functions deploy generate-thumbnail --version previous-hash
```

### Disable Specific Function

If a function is causing issues:

```bash
# Edit config.toml
[functions.notification-trigger]
enabled = false  # Disable without deleting

# Redeploy
supabase functions deploy notification-trigger
```

### Delete and Recreate

As last resort:

```bash
# Delete function (removes from dashboard but keeps code)
supabase functions delete generate-thumbnail

# Redeploy when ready
supabase functions deploy generate-thumbnail
```

---

## Production Checklist

Before considering deployment complete, verify:

### Functionality Tests
- [ ] All 6 functions deployed successfully
- [ ] Each function returns correct response format
- [ ] Error handling works (invalid input returns 400)
- [ ] Authentication works (valid JWT required where configured)

### Configuration
- [ ] `config.toml` has correct settings for all functions
- [ ] Environment variables set: `SENDGRID_API_KEY`, `ONESIGNAL_*`, etc.
- [ ] JWT verification enabled on secure functions
- [ ] CORS headers properly configured

### Monitoring
- [ ] Function logs accessible and readable
- [ ] Error monitoring alerts configured
- [ ] Performance metrics being tracked
- [ ] Rate limiting configured (if needed)

### Integration
- [ ] Database triggers configured for event-driven functions
- [ ] Storage bucket triggers set up (photo processing)
- [ ] Email delivery verified (test invitation)
- [ ] Push notifications tested with OneSignal

### Documentation
- [ ] API endpoint documentation updated
- [ ] Error codes documented
- [ ] Testing procedures documented for team
- [ ] Rollback procedures reviewed

### Security
- [ ] No secrets in code (all in env vars)
- [ ] JWT tokens validated for protected endpoints
- [ ] Input validation implemented
- [ ] SQL injection protection verified (if using database queries)

### Performance
- [ ] Response times < 5 seconds for most requests
- [ ] Caching implemented where applicable
- [ ] Database query optimization reviewed
- [ ] Memory/CPU limits appropriate for workload

### Disaster Recovery
- [ ] Backup of function code in version control
- [ ] Previous version accessible for rollback
- [ ] Error notification system working
- [ ] Team trained on rollback procedure

---

## Additional Resources

- [Supabase Functions Documentation](https://supabase.com/docs/guides/functions)
- [Deno Documentation](https://deno.land/manual)
- [OneSignal API Reference](https://documentation.onesignal.com/reference)
- [SendGrid Email API](https://docs.sendgrid.com/for-developers/sending-email/api-overview)

---

## Support & Maintenance

### Regular Maintenance Tasks

**Weekly**:
- [ ] Review function logs for errors
- [ ] Check OneSignal delivery rates
- [ ] Monitor SendGrid bounce rates

**Monthly**:
- [ ] Review function performance metrics
- [ ] Update dependencies (Deno modules)
- [ ] Test disaster recovery procedures

**Quarterly**:
- [ ] Full function test suite
- [ ] Security audit of function code
- [ ] Performance optimization review

### Contact & Escalation

For issues with Supabase functions:
1. Check function logs: `supabase functions logs function-name`
2. Review this guide's troubleshooting section
3. Check Supabase status page: https://status.supabase.com
4. Contact Supabase support with function name and error message

---

**Last Updated**: March 2, 2026
**Nonna App Version**: 1.0.0
**Supabase Project**: ubptybhhrgdiyfkcqgwu
