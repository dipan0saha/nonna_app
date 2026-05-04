# Edge Functions Deployment Guide (Compact)

This runbook is dashboard-first and intentionally excludes local Supabase installation/setup steps.

## Overview

Project: `ubptybhhrgdiyfkcqgwu`

Edge Functions in this repo:
- `generate-thumbnail`
- `image-processing`
- `send-invitation-email`
- `send-push-notification`
- `notification-trigger`
- `tile-configs`

## Function Inventory

| Function | Status | Main Purpose | Required Inputs (request body) |
|---|---|---|---|
| `generate-thumbnail` | Partial (stub) | Simulates thumbnail generation and optional record update | `bucket`, `path`, optional `recordId`, `table` |
| `image-processing` | Partial (simulated processing) | Metadata/thumbnail/optimization response workflow | `imageUrl`, `bucketName`, `filePath`, `operations` |
| `send-invitation-email` | Implemented | Sends invite email via Resend (or mock if key missing) | `email`, `inviterName`, `babyName`, `inviteUrl` |
| `send-push-notification` | Implemented | Sends OneSignal push by external user IDs (or mock) | `targetUserIds`, `title`, `message`, optional `additionalData` |
| `notification-trigger` | Implemented | Persists notification then sends OneSignal push | `recipientUserId`, `notificationType`, `title`, `message`, optional `data`, `babyProfileId` |
| `tile-configs` | Implemented (updated) | Returns role/screen tile configs with server-side content-aware filtering | `babyProfileId`, `userRole`, optional `screenName` |

## Secrets Required In Supabase Dashboard

Set under: Supabase Dashboard -> Project Settings -> Edge Functions -> Secrets

| Secret | Used By | Notes |
|---|---|---|
| `SUPABASE_URL` | all | Project URL |
| `SUPABASE_ANON_KEY` | `tile-configs`, `notification-trigger` | User-context queries |
| `SUPABASE_SERVICE_ROLE_KEY` | `generate-thumbnail`, `image-processing` | Privileged updates/storage operations |
| `RESEND_API_KEY` | `send-invitation-email` | If missing, function logs mock success |
| `ONESIGNAL_APP_ID` | `send-push-notification`, `notification-trigger` | OneSignal app |
| `ONESIGNAL_REST_API_KEY` | `send-push-notification` | Basic auth key |
| `ONESIGNAL_API_KEY` | `notification-trigger` | Basic auth key (current code path) |

## Deployment (No Local CLI)

Use Supabase Dashboard:
1. Open Supabase Dashboard for project `ubptybhhrgdiyfkcqgwu`.
2. Go to Edge Functions.
3. For each function, open editor/deployment view and deploy latest code.
4. Confirm function is enabled and JWT verification matches your security intent.
5. Ensure all secrets above are present before production traffic.

Recommended rollout order:
1. `tile-configs`
2. `notification-trigger`
3. `send-invitation-email`
4. `send-push-notification`
5. `image-processing`
6. `generate-thumbnail`

## Post-Deployment Verification (Production)

Base URL:
`https://ubptybhhrgdiyfkcqgwu.supabase.co/functions/v1`

Use a valid logged-in user access token in `Authorization: Bearer <access_token>`.

### 1) Verify `tile-configs` (critical)

```bash
curl -X POST "https://ubptybhhrgdiyfkcqgwu.supabase.co/functions/v1/tile-configs" \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "babyProfileId": "<baby_profile_uuid>",
    "userRole": "owner",
    "screenName": "home"
  }'
```

Expected response shape:
- `tiles`: array
- `metadata.count`
- `metadata.hiddenByEmptyCount`
- `metadata.probeCount`
- `metadata.executionTimeMs`

### 2) Verify notification path

```bash
curl -X POST "https://ubptybhhrgdiyfkcqgwu.supabase.co/functions/v1/notification-trigger" \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "recipientUserId": "<user_uuid>",
    "notificationType": "photo_upload",
    "title": "Test",
    "message": "Deployment smoke test"
  }'
```

Expected:
- HTTP `200`
- Notification row persisted
- `pushSent` true/false (false is acceptable if OneSignal secrets are missing)

### 3) Verify invitation email path

```bash
curl -X POST "https://ubptybhhrgdiyfkcqgwu.supabase.co/functions/v1/send-invitation-email" \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "inviterName": "Parent",
    "babyName": "Baby",
    "inviteUrl": "https://example.com/invite/test"
  }'
```

Expected:
- HTTP `200`
- Real send when `RESEND_API_KEY` exists, mock success otherwise

## Monitoring

Use Supabase Dashboard -> Edge Functions -> Logs.

Track:
- 4xx spikes (payload/auth errors)
- 5xx spikes (runtime/db/secret failures)
- `tile-configs` latency and error rate
- notification delivery failures from OneSignal responses

## Common Issues

### 401 Unauthorized
- Confirm caller uses valid user access token.
- Confirm function JWT policy matches intended client access.

### 400 Bad Request
- Payload keys do not match function contract.
- Check exact required input fields in the Function Inventory table.

### 500 Internal Error
- Missing secrets or external provider failures.
- Check logs for missing env keys and upstream API response details.

### `tile-configs` returns fewer tiles than expected
- This is often expected with content-aware filtering.
- Review tile `params.hideWhenEmpty` behavior and underlying data availability.

## Rollback (Dashboard)

If a deployment regresses behavior:
1. Open the function in Supabase Dashboard.
2. Re-deploy the last known good version.
3. If needed, temporarily disable traffic to the affected feature in app config.
4. Re-check logs and smoke-test endpoints after rollback.

## Production Checklist

- [ ] All six functions deployed to target project
- [ ] Required secrets configured
- [ ] `tile-configs` POST smoke test passed
- [ ] Notification trigger smoke test passed
- [ ] Invitation email smoke test passed
- [ ] Logs show no sustained 5xx errors
- [ ] Rollback path verified by team

---

Last Updated: May 4, 2026
Nonna App Version: 1.0.0
Supabase Project: `ubptybhhrgdiyfkcqgwu`
