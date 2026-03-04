# SendGrid Setup Guide for Nonna App

## Table of Contents
1. [What is SendGrid?](#what-is-sendgrid)
2. [Why Does Nonna App Need It?](#why-does-nonna-app-need-it)
3. [Pricing & Email Limits](#pricing--email-limits)
4. [Pre-requisites](#pre-requisites)
5. [Step-by-Step Setup](#step-by-step-setup)
6. [Supabase Edge Function Integration](#supabase-edge-function-integration)
7. [Email Template Examples](#email-template-examples)
8. [Testing & Monitoring](#testing--monitoring)
9. [Troubleshooting](#troubleshooting)

---

## What is SendGrid?

**SendGrid** is a cloud-based email delivery platform that helps applications send transactional emails reliably and at scale. It provides:

- **High Deliverability** - 99% inbox placement rate
- **Email API** - Send emails programmatically
- **Templates** - Pre-built professional email templates
- **SMTP Relay** - Traditional SMTP server option
- **Sandbox Mode** - Test without actually sending emails
- **Analytics** - Track opens, clicks, bounces
- **Spam Protection** - Built-in spam filter bypass
- **Suppression Lists** - Manage unsubscribes automatically
- **Webhooks** - Real-time delivery notifications

Think of SendGrid as a **reliable postal service for digital mail** - it ensures your emails reach inboxes, not spam folders.

---

## Why Does Nonna App Need It?

SendGrid is essential for Nonna App's email communication needs:

### 1. **Event Invitations**
   - Send formal event invites to family members
   - Include event details, date, time, location
   - Track who read the invitation
   - Professional formatting and branding

### 2. **RSVP Confirmations**
   - Confirm when someone RSVPs to an event
   - Send updated attendee list to organizer
   - Automatic email on status changes
   - Beautiful HTML formatted emails

### 3. **Photo & Memory Notifications**
   - Notify family when new photos are uploaded
   - Send digest emails with weekly photos
   - Include preview thumbnails
   - Professional photo showcase

### 4. **Password Recovery**
   - Send reset link to email-based recovery
   - Secure token-based links
   - Time-limited password reset links
   - Account security notifications

### 5. **Administrative Notifications**
   - Notify admins of reported content
   - Account status changes
   - System maintenance alerts
   - Important app notifications

### 6. **Reminder Emails**
   - Send email reminders for upcoming events
   - Personalized reminder timing
   - Prevent missed family gatherings
   - Recurring event reminders

**Without SendGrid**, you'd need to:
- ❌ Build your own SMTP infrastructure
- ❌ Monitor email deliverability manually
- ❌ Handle bounces and complaints yourself
- ❌ Debug email delivery issues
- ❌ Manage server uptime for email

**With SendGrid**, you get:
- ✅ 99% guaranteed delivery
- ✅ Automatic bounce/complaint handling
- ✅ Professional email templates
- ✅ Real-time delivery tracking
- ✅ 24/7 support

---

## Pricing & Email Limits

### Free Tier
- **Cost**: $0
- **Monthly Emails**: 100 emails/day (3,000/month)
- **Features**: All core features
- **Support**: Community/email
- **Perfect for**: Development, testing, small apps
- **No credit card required** to get started

### Paid Tiers

| Plan | Cost | Monthly Emails | Best For |
|------|------|---|---|
| **Free** | $0 | 100/day | Development |
| **Essentials** | $9.95 | 55K/month | Startups |
| **Standard** | $80+ | 100K+/month | Growing apps |
| **Pro** | $300+ | 1M+/month | Large scale |

### Usage Example: Nonna App
Typical monthly emails for 500 active users:
- Event invitations: 2K/month
- RSVP confirmations: 1K/month
- Photo notifications: 2K/month
- Password resets: 100/month
- Reminders: 3K/month
- **Total**: ~8K emails/month = **Free tier sufficient!**

Only upgrade to paid when reaching 3,100+ emails/month.

---

## Pre-requisites

Before setting up SendGrid, ensure you have:

### Required
- [ ] SendGrid account (free signup)
- [ ] Domain name (for email sender)
- [ ] Access to domain DNS settings (for verification)
- [ ] Supabase project with Edge Functions enabled
- [ ] Basic understanding of API keys
- [ ] 20-30 minutes for setup

### Recommended
- [ ] Understanding of SMTP concepts
- [ ] HTML/email template knowledge
- [ ] Access to email client for testing
- [ ] Understanding of webhook concepts

---

## Step-by-Step Setup

### Phase 1: SendGrid Account & API Key

#### Step 1.1: Create SendGrid Account
1. Go to https://sendgrid.com
2. Click **"Sign up free"**
3. Fill in registration:
   - Email address
   - Password
   - First/Last name
4. Verify email address
5. Complete account setup

#### Step 1.2: Create API Key
1. In SendGrid dashboard, go to **Settings** → **API Keys**
2. Click **"Create API Key"**
3. Enter:
   - **API Key Name**: `nonna-app-supabase`
   - **API Key Permissions**:
     - Select **"Restricted Access"**
     - Check: **Mail Send**
     - Check: **Template Engine**
4. Click **"Create & Verify"**
5. **Copy and save the API key** (you won't see it again!)
   - Format: `SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
6. Store securely (we'll add to Supabase secrets)

---

### Phase 2: Sender Identity Verification

You need to verify an email address or domain for sending.

#### Option A: Single Sender (Simple, Recommended for Testing)

1. In SendGrid, go to **Settings** → **Sender Authentication**
2. Click **"Verify a Single Sender"**
3. Fill in:
   - **From Email**: `noreply@example.com` or your email
   - **From Name**: `Nonna App`
   - **Reply To**: `support@example.com`
   - **Company**: `Nonna App`
4. Click **"Create"**
5. SendGrid sends verification email
6. Check your email and click verification link
7. Status changes to **"Verified"**

#### Option B: Domain Authentication (Professional, for Production)

**Step 1: Start Domain Verification**
1. In SendGrid, go to **Settings** → **Sender Authentication**
2. Click **"Authenticate Your Domain"**
3. Select domain registrar (Namecheap, GoDaddy, etc.)
4. Choose authentication method:
   - **CNAME** (recommended, simpler)
   - **MX** (alternative)
5. Click **"Next"**

**Step 2: Add DNS Records**
SendGrid provides DNS records to add:
- 3 CNAME records AND
- 1 TXT record (for DKIM signing)

For example:
```
Name: sendgrid.example.com
Type: CNAME
Value: sendgrid.net

Name: em.example.com
Type: CNAME
Value: u1234567.wl001.sendgrid.net

Name: s1._domainkey.example.com
Type: CNAME
Value: s1.domainkey.sendgrid.net

Name: example.com
Type: TXT
Value: v=spf1 sendgrid.net ~all
```

**Step 3: Add to DNS Provider**
1. Log into your domain registrar (e.g., Namecheap, GoDaddy)
2. Find DNS settings
3. Add the CNAME records
4. Add the TXT record
5. Wait 5-30 minutes for DNS to propagate

**Step 4: Verify in SendGrid**
1. Click **"Verify"** in SendGrid
2. Wait for status to show **"Verified"**
3. You can now send from any address @example.com

---

### Phase 3: Add to Supabase

#### Step 3.1: Add SendGrid API Key to Supabase

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your **nonna-app** project
3. Go to **Settings** → **Environment variables**
4. Click **"Add new variable"**
5. Add:
   - **Name**: `SENDGRID_API_KEY`
   - **Value**: (paste your API key from Step 1.2)
6. Click **"Save"**

---

## Supabase Edge Function Integration

### Step 1: Create Email Service Function

Create a file: `supabase/functions/send-email/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.175.0/http/server.ts";

const sendGridApiKey = Deno.env.get("SENDGRID_API_KEY");

interface EmailRequest {
  to: string;
  subject: string;
  html: string;
  fromEmail?: string;
  fromName?: string;
}

serve(async (req) => {
  // Only accept POST
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const { to, subject, html, fromEmail, fromName } = await req.json() as EmailRequest;

    // Validate inputs
    if (!to || !subject || !html) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Send via SendGrid
    const response = await fetch("https://api.sendgrid.com/v3/mail/send", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${sendGridApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        personalizations: [
          {
            to: [{ email: to }],
            subject: subject,
          },
        ],
        from: {
          email: fromEmail || "noreply@example.com",
          name: fromName || "Nonna App",
        },
        content: [
          {
            type: "text/html",
            value: html,
          },
        ],
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`SendGrid error: ${error}`);
    }

    return new Response(
      JSON.stringify({ success: true, messageId: response.headers.get("X-Message-Id") }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Email send error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
```

### Step 2: Deploy the Function

```bash
supabase functions deploy send-email
```

### Step 3: Call from Your App

From Flutter, call the edge function:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailService {
  static final _supabase = Supabase.instance.client;

  static Future<void> sendEventInvitation({
    required String toEmail,
    required String eventName,
    required String eventDate,
    required String eventTime,
  }) async {
    final html = '''
      <h2>You're Invited!</h2>
      <p>You have been invited to: <strong>$eventName</strong></p>
      <p><strong>Date:</strong> $eventDate</p>
      <p><strong>Time:</strong> $eventTime</p>
      <p><a href="https://app.nonna.com/events">View Details</a></p>
    ''';

    try {
      await _supabase.functions.invoke(
        'send-email',
        body: {
          'to': toEmail,
          'subject': 'Invitation: $eventName',
          'html': html,
        },
      );
      print('Event invitation sent to $toEmail');
    } catch (e) {
      print('Failed to send invitation: $e');
      rethrow;
    }
  }

  static Future<void> sendPasswordReset({
    required String toEmail,
    required String resetLink,
  }) async {
    final html = '''
      <h2>Password Reset Request</h2>
      <p>Click the link below to reset your password:</p>
      <p><a href="$resetLink">Reset Password</a></p>
      <p>This link expires in 24 hours.</p>
      <p>If you didn't request this, ignore this email.</p>
    ''';

    try {
      await _supabase.functions.invoke(
        'send-email',
        body: {
          'to': toEmail,
          'subject': 'Password Reset Request',
          'html': html,
        },
      );
      print('Password reset email sent to $toEmail');
    } catch (e) {
      print('Failed to send reset email: $e');
      rethrow;
    }
  }

  static Future<void> sendPhotoNotification({
    required String toEmail,
    required String uploaderName,
    required List<String> photoUrls,
  }) async {
    final photoGrid = photoUrls
        .map((url) => '<img src="$url" style="width: 150px; margin: 5px;"/>')
        .join();

    final html = '''
      <h2>New Photos from $uploaderName</h2>
      <p>Check out the latest family photos:</p>
      <div>$photoGrid</div>
      <p><a href="https://app.nonna.com/photos">View All Photos</a></p>
    ''';

    try {
      await _supabase.functions.invoke(
        'send-email',
        body: {
          'to': toEmail,
          'subject': 'New Family Photos from $uploaderName',
          'html': html,
        },
      );
    } catch (e) {
      print('Failed to send photo notification: $e');
      rethrow;
    }
  }
}
```

---

## Email Template Examples

### Template 1: Event Invitation

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; }
    .container { max-width: 600px; margin: all 0; padding: 20px; }
    .header { background-color: #6366f1; color: white; padding: 20px; }
    .content { padding: 20px; background-color: #f9fafb; }
    .button { background-color: #6366f1; color: white; padding: 10px 20px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>You're Invited! 🎉</h1>
    </div>
    <div class="content">
      <p>Hi {{familyMemberName}},</p>
      <p>You're invited to <strong>{{eventName}}</strong></p>

      <h3>Event Details:</h3>
      <ul>
        <li><strong>Date:</strong> {{eventDate}}</li>
        <li><strong>Time:</strong> {{eventTime}}</li>
        <li><strong>Location:</strong> {{eventLocation}}</li>
      </ul>

      <p>{{eventDescription}}</p>

      <p>
        <a href="https://app.nonna.com/events/{{eventId}}" class="button">
          View Event & RSVP
        </a>
      </p>

      <p>Looking forward to seeing you there!</p>
      <p>- The Nonna App Family</p>
    </div>
  </div>
</body>
</html>
```

### Template 2: RSVP Confirmation

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .success { color: #10b981; }
    .details { background-color: #f3f4f6; padding: 15px; margin: 15px 0; }
  </style>
</head>
<body>
  <div class="container">
    <h2 class="success">✓ Your RSVP has been confirmed!</h2>

    <p>Hi {{name}},</p>
    <p>Thanks for RSVPing to <strong>{{eventName}}</strong>.</p>

    <div class="details">
      <h4>Event Details:</h4>
      <p><strong>Date:</strong> {{eventDate}}</p>
      <p><strong>Time:</strong> {{eventTime}}</p>
      <p><strong>Status:</strong> {{rsvpStatus}}</p>
      <p><strong>Attendees:</strong> {{attendeeCount}}</p>
    </div>

    <p>Your RSVP status: <strong style="color: #10b981;">{{rsvpStatus}}</strong></p>

    <p>Need to change your response?
      <a href="https://app.nonna.com/events/{{eventId}}">Update RSVP</a>
    </p>
  </div>
</body>
</html>
```

### Template 3: Weekly Photo Digest

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .photo-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
    .photo { max-width: 100%; }
  </style>
</head>
<body>
  <div class="container">
    <h2>📸 This Week's Family Photos</h2>

    <p>Hi {{name}},</p>
    <p>Here are the latest family photos shared this week:</p>

    <div class="photo-grid">
      {{photosHtml}}
    </div>

    <p>
      <a href="https://app.nonna.com/photos">
        View All Photos & Albums
      </a>
    </p>

    <p>Keep those memories coming!</p>
  </div>
</body>
</html>
```

---

## Testing & Monitoring

### Test 1: Send Test Email from Dashboard

1. In SendGrid, go to **Mail Send** → **Dynamic Templates**
2. Click **"Create Template"**
3. Name it: `test-template`
4. Add test content
5. Go to **API References** → **Send Test Email**
6. Send to your email address

### Test 2: Send from Edge Function

```bash
# Using curl to test the edge function
curl -X POST http://localhost:54321/functions/v1/send-email \
  -H "Content-Type: application/json" \
  -d '{
    "to": "your-email@example.com",
    "subject": "Test Email",
    "html": "<h1>Hello!</h1><p>This is a test.</p>"
  }'
```

### Test 3: Monitor Deliverability

1. In SendGrid dashboard, go to **Analytics** → **Overview**
2. Track:
   - **Delivered**: Successfully delivered
   - **Bounced**: Invalid emails
   - **Opened**: Email opened by recipient
   - **Clicked**: Links clicked in email
   - **Marked as Spam**: User marked as spam

### Test 4: Check Live Activity

1. Go to SendGrid **Activity** → **Email Activity**
2. View recent sent emails
3. Click on email to see:
   - Delivery status
   - Open/click tracking
   - Bounce reasons (if bounced)

---

## Troubleshooting

### Common Issues & Solutions

#### "Invalid From Email"

**Problem**: Error says from email not verified

**Solutions**:
1. Verify single sender or domain in SendGrid
2. Use verified email in function call
3. Check API key has Mail Send permission

#### "401 Unauthorized"

**Problem**: API key is invalid or expired

**Solutions**:
1. Verify API key in Supabase environment variables
2. Check key hasn't been revoked in SendGrid
3. Regenerate new API key if needed
4. Ensure function has access to env var

#### "Email Not Arriving"

**Problem**: Email sent successfully but not in inbox

**Solutions**:
1. Check spam/junk folder
2. Verify domain authentication (DKIM/SPF)
3. Check SendGrid Activity for bounce status
4. Review recipient's email spam settings
5. Add sender to contacts/whitelist
6. Check bounce list in SendGrid

#### "Rate Limited"

**Problem**: Getting rate limit errors after many sends

**Solutions**:
1. Free tier limited to 100 emails/day
2. Upgrade plan for higher limits
3. Batch large send operations
4. Implement queue for delayed sends

#### "Domain Verification Failed"

**Problem**: DNS records not recognized

**Solutions**:
1. Wait 5-30 minutes for DNS propagation
2. Verify DNS records exactly match (case-sensitive)
3. Check records with tools: `dig` or `nslookup`
4. Try different DNS records (MX vs CNAME)
5. Contact domain registrar support if stuck

#### "Template Variables Not Rendering"

**Problem**: {{variableName}} shows literally in email

**Solutions**:
1. Use valid template syntax: `{{variableName}}`
2. Pass variables in request body
3. Verify variable names match HTML
4. Check template engine is enabled

---

## Best Practices

### 1. **Email Design**
- ✅ Use responsive HTML (works on mobile)
- ✅ Include plain text alternative
- ✅ Add unsubscribe link (legal requirement)
- ✅ Use branded colors and logo

### 2. **Deliverability**
- ✅ Authenticate domain with DKIM/SPF
- ✅ Keep bounce rate below 5%
- ✅ Remove unengaged subscribers
- ✅ Use double opt-in for newsletters

### 3. **Security**
- ✅ Never hardcode API keys (use env vars)
- ✅ Validate email addresses before sending
- ✅ Implement rate limiting
- ✅ Log failed sends for debugging

### 4. **Performance**
- ✅ Send emails asynchronously (don't wait)
- ✅ Use queues for bulk sends
- ✅ Implement retry logic for failures
- ✅ Monitor API performance

---

## Optional: Webhook for Delivery Tracking

Track email events (opens, clicks, bounces) in real-time:

### Setup Webhook in SendGrid

1. Go to **Settings** → **Mail Send Settings** → **Event Webhook**
2. Enter webhook URL: `https://your-project.supabase.co/functions/v1/email-webhook`
3. Select events to track:
   - ✅ Delivered
   - ✅ Opened
   - ✅ Clicked
   - ✅ Bounced
   - ✅ Marked as Spam
4. Click **Save**

### Create Webhook Handler in Supabase

File: `supabase/functions/email-webhook/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.175.0/http/server.ts";

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("OK");
  }

  const events = await req.json();

  for (const event of events) {
    console.log(`Email ${event.event}:`, {
      email: event.email,
      event: event.event,
      timestamp: event.timestamp,
    });

    // Store event in database
    // Example: log opens, track bounces, etc.
  }

  return new Response("OK");
});
```

---

## Next Steps

1. ✅ Create SendGrid account
2. ✅ Create and save API key
3. ✅ Verify sender email/domain
4. ✅ Add API key to Supabase secrets
5. ✅ Deploy send-email function
6. ✅ Create email templates
7. ✅ Test sending from Edge Function
8. ✅ Implement in Flutter app
9. ✅ Monitor deliverability
10. ✅ Set up webhook tracking (optional)

---

## Useful Links

- **SendGrid Documentation**: https://docs.sendgrid.com
- **SendGrid Dashboard**: https://app.sendgrid.com
- **SendGrid Pricing**: https://sendgrid.com/pricing
- **Email Best Practices**: https://docs.sendgrid.com/ui/sending-email/email-best-practices
- **Webhook Documentation**: https://docs.sendgrid.com/for-developers/tracking-events/event

---

**Last Updated**: March 3, 2026
**Status**: Ready for Production
