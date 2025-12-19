# Nonna App - User Consent Flows

**Effective Date:** [To be determined upon launch]  
**Last Updated:** December 2025  
**Version:** 1.0 (DRAFT)

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Consent Framework](#2-consent-framework)
3. [Account Registration Flow](#3-account-registration-flow)
4. [Baby Profile Creation Flow](#4-baby-profile-creation-flow)
5. [Invitation and Access Consent Flow](#5-invitation-and-access-consent-flow)
6. [Notification Consent Flow](#6-notification-consent-flow)
7. [Photo Sharing Consent Flow](#7-photo-sharing-consent-flow)
8. [Data Rights and Preferences Flow](#8-data-rights-and-preferences-flow)
9. [Consent Withdrawal](#9-consent-withdrawal)
10. [Technical Implementation](#10-technical-implementation)
11. [Compliance and Auditing](#11-compliance-and-auditing)

---

## 1. Introduction

### 1.1 Purpose

This document outlines the user consent flows for Nonna App, ensuring:
- **Informed Consent:** Users understand what they're agreeing to
- **Explicit Consent:** Clear, affirmative actions required
- **Granular Control:** Separate consent for different data uses
- **Easy Withdrawal:** Simple process to withdraw consent
- **Legal Compliance:** GDPR, CCPA, COPPA requirements met

### 1.2 Consent Principles

Our consent mechanisms follow these principles:

#### 1.2.1 Freely Given
- No forced consent (except for essential service functionality)
- Users can refuse optional consents without penalty
- Clear distinction between required and optional consents

#### 1.2.2 Specific and Informed
- Clear, plain language explanations
- Specific purposes for each consent
- Pre-checked boxes prohibited
- Separate consent for separate purposes

#### 1.2.3 Unambiguous
- Explicit "yes" action required (no implied consent)
- Opt-in, not opt-out
- Clear consent indicators (checkboxes, buttons)

#### 1.2.4 Revocable
- Easy to withdraw consent as it was to give
- Withdrawal doesn't affect prior lawful processing
- Clear instructions for withdrawal

---

## 2. Consent Framework

### 2.1 Consent Categories

We distinguish between different types of consent:

| Consent Type | Required? | Legal Basis | Withdrawable? |
|--------------|-----------|-------------|---------------|
| **Terms of Service** | ✅ Yes | Contract | ❌ No (account closure only) |
| **Privacy Policy** | ✅ Yes | Contract | ❌ No (account closure only) |
| **Age Verification** | ✅ Yes | Legal compliance | ❌ No (legal requirement) |
| **Parental Consent for Child Data** | ✅ Yes (for baby profiles) | Legal compliance (COPPA) | ✅ Yes (delete profile) |
| **Push Notifications** | ❌ No | Consent | ✅ Yes (anytime) |
| **Email Notifications** | ❌ No | Consent | ✅ Yes (anytime) |
| **Photo Sharing** | ⚠️ Per-photo | Legitimate interest | ✅ Yes (delete photo) |
| **Marketing Communications** | ❌ No | Consent | ✅ Yes (anytime) |

### 2.2 Consent Logging

All consents are logged with:
- **User ID:** Who gave consent
- **Timestamp:** When consent was given
- **Consent Type:** What was consented to
- **Version:** Which policy/terms version
- **IP Address:** For fraud prevention
- **Device Info:** For security

**Retention:** Consent logs retained for 7 years after account deletion (legal compliance)

---

## 3. Account Registration Flow

### 3.1 Registration Screen Components

**Flow Overview:**
```
Landing Screen
    ↓
Registration Form
    ↓
Age Verification
    ↓
Terms & Privacy Acceptance
    ↓
Email Verification
    ↓
Account Created
```

### 3.2 Detailed Flow

#### Step 1: Landing Screen

**UI Elements:**
- "Create Account" button
- "Already have an account? Log in" link

**User Action:** Tap "Create Account"

---

#### Step 2: Registration Form

**UI Elements:**
```
┌─────────────────────────────────┐
│  Create Your Account            │
├─────────────────────────────────┤
│  Email: [__________________]    │
│  Password: [__________________] │
│  Confirm: [__________________]  │
│                                 │
│  (Optional)                     │
│  Full Name: [__________________]│
│                                 │
│  [Next]                         │
└─────────────────────────────────┘
```

**Validation:**
- Email format valid
- Password strength requirements met
- Passwords match

**User Action:** Fill form and tap "Next"

---

#### Step 3: Age Verification

**UI Elements:**
```
┌─────────────────────────────────┐
│  Age Verification Required      │
├─────────────────────────────────┤
│  To use Nonna App, you must be  │
│  at least 18 years old.         │
│                                 │
│  Birth Date:                    │
│  [MM] / [DD] / [YYYY]          │
│                                 │
│  ℹ️ Why we ask: Federal law    │
│  requires age verification for  │
│  apps collecting children's     │
│  information.                   │
│                                 │
│  [Verify]                       │
└─────────────────────────────────┘
```

**Validation:**
- Date indicates user is 18+ years old
- If under 18: Display error and prevent registration

**Privacy Note:**
- Birth date used ONLY for age verification
- NOT stored permanently (only verification result stored)

**User Action:** Enter birth date and tap "Verify"

---

#### Step 4: Terms and Privacy Policy Acceptance

**UI Elements:**
```
┌──────────────────────────────────────┐
│  Review and Accept                   │
├──────────────────────────────────────┤
│  Please review and accept our        │
│  policies to continue:               │
│                                      │
│  □ I have read and agree to the     │
│    [Terms of Service]                │
│                                      │
│  □ I have read and understand the   │
│    [Privacy Policy]                  │
│                                      │
│  ℹ️ These cannot be unchecked.      │
│  By using Nonna App, you must        │
│  accept these policies.              │
│                                      │
│  Highlights:                         │
│  • We never sell your data          │
│  • No ads or tracking               │
│  • You control who sees your photos │
│  • You can delete your data anytime │
│                                      │
│  [Create Account]                    │
└──────────────────────────────────────┘
```

**Implementation:**
- Checkboxes NOT pre-checked
- "Create Account" button disabled until both checked
- Links open full policies in scrollable view
- User must explicitly check both boxes

**Consent Logged:**
- Terms of Service acceptance (with version number)
- Privacy Policy acceptance (with version number)
- Timestamp and IP address

**User Action:** Check both boxes and tap "Create Account"

---

#### Step 5: Email Verification

**UI Elements:**
```
┌─────────────────────────────────┐
│  Verify Your Email              │
├─────────────────────────────────┤
│  We sent a verification link to:│
│  user@example.com               │
│                                 │
│  Please check your email and    │
│  click the link to verify.      │
│                                 │
│  Didn't receive it?             │
│  [Resend Email]                 │
│                                 │
│  [I've Verified - Continue]     │
└─────────────────────────────────┘
```

**Email Content:**
```
Subject: Verify your Nonna App email address

Hi [Name],

Welcome to Nonna App! Please verify your email address by clicking the link below:

[Verify Email Address] (button)

This link expires in 24 hours.

If you didn't create a Nonna App account, please ignore this email.

Questions? Contact us at support@nonnaapp.example.com

- The Nonna App Team
```

**Security:**
- Verification link expires in 24 hours
- One-time use token
- HTTPS only

**User Action:** Click link in email, return to app, tap "I've Verified - Continue"

---

#### Step 6: Account Created - Optional Consents

**UI Elements:**
```
┌─────────────────────────────────────┐
│  Welcome to Nonna App! 🎉           │
├─────────────────────────────────────┤
│  Your account is ready.             │
│                                     │
│  Optional: Get Notified             │
│                                     │
│  □ Send me push notifications when: │
│    • New photos are shared          │
│    • Family members comment         │
│    • Upcoming events                │
│                                     │
│  □ Send me email notifications for: │
│    • Weekly family updates          │
│    • Important announcements        │
│                                     │
│  ℹ️ You can change these anytime   │
│  in Settings.                       │
│                                     │
│  [Continue] [Skip for Now]          │
└─────────────────────────────────────┘
```

**Implementation:**
- Checkboxes NOT pre-checked (opt-in)
- "Skip for Now" button clearly visible
- No penalty for skipping
- Settings link provided for later changes

**Consent Logged (if checked):**
- Push notification consent (timestamp)
- Email notification consent (timestamp)

**User Action:** Choose preferences and tap "Continue" or "Skip for Now"

---

### 3.3 Consent Records Created

After registration, the following consents are logged:

| Consent | Status | Version | Timestamp |
|---------|--------|---------|-----------|
| Age Verification (18+) | ✅ Verified | N/A | [ISO timestamp] |
| Terms of Service | ✅ Accepted | 1.0 | [ISO timestamp] |
| Privacy Policy | ✅ Accepted | 1.0 | [ISO timestamp] |
| Push Notifications | User choice | N/A | [ISO timestamp] |
| Email Notifications | User choice | N/A | [ISO timestamp] |

---

## 4. Baby Profile Creation Flow

### 4.1 Parental Consent Flow

**Flow Overview:**
```
Profile Creation Screen
    ↓
Parental Consent Affirmation
    ↓
Child Information Entry
    ↓
Privacy Settings
    ↓
Profile Created
```

### 4.2 Detailed Flow

#### Step 1: Profile Creation Screen

**UI Elements:**
```
┌─────────────────────────────────┐
│  Create Baby Profile            │
├─────────────────────────────────┤
│  Share your baby's journey with │
│  family in a private, secure    │
│  space.                         │
│                                 │
│  [Create Profile]               │
└─────────────────────────────────┘
```

**User Action:** Tap "Create Profile"

---

#### Step 2: Parental Consent Affirmation

**UI Elements:**
```
┌──────────────────────────────────────┐
│  Parental Consent Required           │
├──────────────────────────────────────┤
│  Before creating a baby profile:     │
│                                      │
│  I affirm that:                      │
│                                      │
│  □ I am the parent or legal guardian│
│    of the child whose profile I am  │
│    creating                          │
│                                      │
│  □ I have the authority to consent  │
│    to the collection and use of my  │
│    child's information as described │
│    in the [Children's Privacy Policy]│
│                                      │
│  □ I understand that:                │
│    • My child's name, photo, and    │
│      birth date will be stored      │
│    • I control who can see this info│
│    • I can delete this profile      │
│      anytime                         │
│                                      │
│  ℹ️ This is required by law to      │
│  protect children's privacy (COPPA). │
│                                      │
│  [I Consent] [Cancel]                │
└──────────────────────────────────────┘
```

**Implementation:**
- All checkboxes must be checked to proceed
- Checkboxes NOT pre-checked
- Link to Children's Privacy Policy opens in scrollable view
- Clear explanation of what consent means

**Consent Logged:**
- Parental consent for child data collection
- Child profile ID (once created)
- Timestamp and version of Children's Privacy Policy

**User Action:** Check all boxes and tap "I Consent"

---

#### Step 3: Child Information Entry

**UI Elements:**
```
┌─────────────────────────────────┐
│  Baby's Information             │
├─────────────────────────────────┤
│  First Name: [_____________]    │
│  Middle Name: [_____________]   │
│  Last Name: [_____________]     │
│                                 │
│  Birth Date: [MM/DD/YYYY]       │
│                                 │
│  Gender (Optional):             │
│  ○ Boy  ○ Girl  ○ Other/Prefer │
│                    not to say   │
│                                 │
│  Profile Photo (Optional):      │
│  [Upload Photo]                 │
│                                 │
│  [Next]                         │
└─────────────────────────────────┘
```

**Privacy Notes:**
- Only essential information collected
- Gender optional (not required for service)
- Photos optional

**User Action:** Fill information and tap "Next"

---

#### Step 4: Privacy Settings

**UI Elements:**
```
┌──────────────────────────────────────┐
│  Who Can See This Profile?           │
├──────────────────────────────────────┤
│  ✅ Private by Default                │
│                                      │
│  Only people you invite can:         │
│  • See baby's name and photos        │
│  • View events and milestones        │
│  • Add comments                      │
│                                      │
│  You can:                            │
│  • Invite family members             │
│  • Remove access anytime             │
│  • See who viewed photos             │
│                                      │
│  ⚠️ Sharing Reminder                 │
│                                      │
│  □ Show sharing reminders when I    │
│    upload photos (recommended)       │
│                                      │
│  [Create Profile]                    │
└──────────────────────────────────────┘
```

**Implementation:**
- Default privacy is most restrictive (private)
- Sharing reminder opt-in (checked by default for safety)
- Clear explanation of privacy model

**User Action:** Configure settings and tap "Create Profile"

---

#### Step 5: Profile Created

**UI Elements:**
```
┌─────────────────────────────────┐
│  Profile Created! 🎊            │
├─────────────────────────────────┤
│  [Baby's Name]'s profile is     │
│  ready to share with family.    │
│                                 │
│  Next steps:                    │
│  • Upload first photo           │
│  • Invite family members        │
│  • Add milestones               │
│                                 │
│  [Invite Family] [Add Photo]    │
└─────────────────────────────────┘
```

---

### 4.3 Consent Records Created

| Consent | Status | Details |
|---------|--------|---------|
| Parental Authority | ✅ Affirmed | User confirms they are parent/guardian |
| Child Data Collection | ✅ Consented | Consent for child's name, birth date, photo |
| Children's Privacy Policy | ✅ Accepted | Version logged |
| Sharing Reminders | User choice | Opt-in for safety reminders |

---

## 5. Invitation and Access Consent Flow

### 5.1 Invitation Flow (Profile Owner)

**Flow Overview:**
```
Invite Family Member
    ↓
Enter Email / Select Contact
    ↓
Permission Level Selection
    ↓
Privacy Reminder
    ↓
Invitation Sent
```

### 5.2 Detailed Flow

#### Step 1: Invite Family Member

**UI Elements:**
```
┌─────────────────────────────────┐
│  Invite Family to View          │
│  [Baby's Name]'s Profile        │
├─────────────────────────────────┤
│  Email: [__________________]    │
│                                 │
│  Permission Level:              │
│  ○ Follower (view only)         │
│  ○ Contributor (can add photos) │
│                                 │
│  Personal Message (Optional):   │
│  [_________________________]    │
│  [_________________________]    │
│                                 │
│  [Send Invitation]              │
└─────────────────────────────────┘
```

**User Action:** Enter email, select permissions, tap "Send Invitation"

---

#### Step 2: Privacy Reminder (First Time)

**UI Elements (shown only on first invitation):**
```
┌──────────────────────────────────────┐
│  Privacy Reminder                    │
├──────────────────────────────────────┤
│  Before inviting family members:     │
│                                      │
│  ✅ Only invite people you trust     │
│  ✅ They'll see all photos on this   │
│     profile                          │
│  ✅ You can remove access anytime    │
│                                      │
│  ⚠️ Be cautious about:               │
│  • Sharing on social media           │
│  • Screenshots (you won't know)      │
│  • Re-sharing photos                 │
│                                      │
│  □ Don't show this again             │
│                                      │
│  [I Understand] [Cancel]             │
└──────────────────────────────────────┘
```

**User Action:** Tap "I Understand"

---

### 5.3 Acceptance Flow (Invitee)

**Flow Overview:**
```
Receive Email Invitation
    ↓
Click Link (creates account or logs in)
    ↓
Review Access Requested
    ↓
Accept or Decline
```

#### Email Invitation

```
Subject: [Parent's Name] invited you to view [Baby's Name]'s profile on Nonna App

Hi,

[Parent's Name] has invited you to view [Baby's Name]'s profile on Nonna App, a private family sharing app.

You'll be able to:
• View photos and milestones
• Comment on updates
• See family events

[Accept Invitation] (button)

About Nonna App:
Nonna App is a private, secure platform for families to share baby photos and memories. 
We never use ads, never sell data, and never share your information with third parties.

Privacy Policy: [link]

This invitation expires in 30 days.

If you don't know [Parent's Name], please ignore this email.
```

#### Acceptance Screen

**UI Elements:**
```
┌──────────────────────────────────────┐
│  Invitation to View                  │
│  [Baby's Name]'s Profile             │
├──────────────────────────────────────┤
│  [Parent's Name] has invited you to: │
│                                      │
│  ✅ View [Baby's Name]'s photos      │
│  ✅ See milestones and events        │
│  ✅ Comment on updates               │
│                                      │
│  Your access:                        │
│  • Follower (view only)              │
│  • [Parent's Name] can remove access │
│    anytime                           │
│                                      │
│  Privacy:                            │
│  • Photos are private (not public)   │
│  • Don't share without permission    │
│  • Be respectful of family privacy   │
│                                      │
│  [Accept Invitation] [Decline]       │
└──────────────────────────────────────┘
```

**Consent Logged:**
- Acceptance of invitation
- Agreement to follower terms (privacy, respect)
- Timestamp and profile ID

**User Action:** Tap "Accept Invitation"

---

## 6. Notification Consent Flow

### 6.1 Initial Consent (during registration)

See Section 3.2 Step 6 for initial notification consent.

### 6.2 In-App Notification Settings

**UI Elements:**
```
┌──────────────────────────────────────┐
│  Notification Preferences            │
├──────────────────────────────────────┤
│  Push Notifications                  │
│  ──────────────────────────          │
│  □ New photos shared                 │
│  □ New comments                      │
│  □ Upcoming events (1 day before)    │
│  □ Milestones reminders              │
│                                      │
│  Email Notifications                 │
│  ──────────────────────────          │
│  □ Daily digest                      │
│  □ Weekly summary                    │
│  □ Important announcements           │
│  □ Family member joins               │
│                                      │
│  Frequency:                          │
│  ○ Real-time                         │
│  ○ Daily digest (9 AM)               │
│  ○ Weekly digest (Sundays)           │
│                                      │
│  [Save Changes]                      │
└──────────────────────────────────────┘
```

**Granular Control:**
- Separate opt-in for each notification type
- Frequency control
- Easy to enable/disable

**Consent Logged:**
- Each notification type separately
- Changes logged with timestamp

---

### 6.3 OS-Level Permission Request

**iOS Push Notification Permission:**
```
┌─────────────────────────────────────┐
│  "Nonna App" Would Like to          │
│  Send You Notifications              │
├─────────────────────────────────────┤
│  Notifications may include alerts,  │
│  sounds, and icon badges.           │
│                                     │
│  [Don't Allow]  [Allow]             │
└─────────────────────────────────────┘
```

**Android Push Notification Permission:**
(Android 13+)
```
┌─────────────────────────────────────┐
│  Allow Nonna App to send you        │
│  notifications?                      │
├─────────────────────────────────────┤
│  [Don't allow]  [Allow]             │
└─────────────────────────────────────┘
```

**Timing:** 
- Request permission ONLY when user opts in to push notifications
- NOT on app first launch (avoid premature denial)

---

## 7. Photo Sharing Consent Flow

### 7.1 Upload with Privacy Reminder

**UI Elements:**
```
┌──────────────────────────────────────┐
│  Upload Photo                        │
├──────────────────────────────────────┤
│  [Photo Preview]                     │
│                                      │
│  Who will see this?                  │
│  ──────────────────────────          │
│  👤 You (Owner)                      │
│  👥 5 Family Members (Followers)     │
│                                      │
│  ⚠️ Privacy Reminder                 │
│                                      │
│  □ I understand that invited family │
│    members will be able to view and │
│    download this photo               │
│                                      │
│  ℹ️ We automatically remove location│
│  data (EXIF) from photos for privacy │
│                                      │
│  □ Don't show this reminder again   │
│                                      │
│  Caption (Optional):                 │
│  [_____________________________]     │
│                                      │
│  [Upload]  [Cancel]                  │
└──────────────────────────────────────┘
```

**Implementation:**
- First-time users must check consent box
- Returning users see abbreviated reminder
- EXIF removal happens automatically (user informed)
- Clear indication of audience

**User Action:** Check box (first time) and tap "Upload"

---

## 8. Data Rights and Preferences Flow

### 8.1 Privacy Dashboard

**UI Elements:**
```
┌──────────────────────────────────────┐
│  Privacy & Data                      │
├──────────────────────────────────────┤
│  Your Privacy Controls               │
│  ──────────────────────────          │
│  [Download My Data]                  │
│  Export all your data in JSON format │
│                                      │
│  [Notification Settings]             │
│  Control what notifications you get  │
│                                      │
│  [Privacy Settings]                  │
│  Manage who can see your profiles    │
│                                      │
│  Data Retention                      │
│  ──────────────────────────          │
│  Calendar Events:                    │
│  ○ Keep for 7 years (default)        │
│  ○ Delete after 1 year               │
│  ○ Delete when profile deleted       │
│                                      │
│  Legal & Policies                    │
│  ──────────────────────────          │
│  [Terms of Service]                  │
│  [Privacy Policy]                    │
│  [Children's Privacy Policy]         │
│  [Data Retention Policy]             │
│                                      │
│  Delete My Account                   │
│  ──────────────────────────          │
│  ⚠️ [Delete My Account]              │
│  Permanently delete all your data    │
└──────────────────────────────────────┘
```

---

### 8.2 Data Export Flow

**UI Elements:**
```
┌──────────────────────────────────────┐
│  Download Your Data                  │
├──────────────────────────────────────┤
│  We'll prepare a copy of all your   │
│  data including:                     │
│                                      │
│  ✅ Account information              │
│  ✅ Baby profiles                    │
│  ✅ Photos and videos                │
│  ✅ Comments and posts               │
│  ✅ Calendar events                  │
│  ✅ Registry items                   │
│                                      │
│  Format:                             │
│  • JSON file (structured data)       │
│  • ZIP file (photos/videos)          │
│                                      │
│  This may take a few minutes for     │
│  large accounts.                     │
│                                      │
│  □ I understand this download will  │
│    contain sensitive information     │
│    about my family                   │
│                                      │
│  [Start Download]  [Cancel]          │
└──────────────────────────────────────┘
```

**Process:**
1. User requests export
2. System queues export job
3. Email sent when ready (within 24-48 hours)
4. Download link valid for 7 days
5. Downloaded files deleted after 7 days

---

### 8.3 Account Deletion Flow

**UI Elements - Step 1: Warning**
```
┌──────────────────────────────────────┐
│  Delete My Account?                  │
├──────────────────────────────────────┤
│  ⚠️ WARNING: This is permanent!      │
│                                      │
│  This will delete:                   │
│  ❌ Your account                     │
│  ❌ All baby profiles you own        │
│  ❌ All photos and videos you uploaded│
│  ❌ All calendar events you created  │
│  ❌ All registry items               │
│  ❌ Access to profiles shared with you│
│                                      │
│  This will NOT delete:               │
│  ⚠️ Your comments on others' content │
│     (they'll be anonymized)          │
│                                      │
│  Recovery:                           │
│  • 90-day grace period               │
│  • Contact support to recover        │
│  • After 90 days: PERMANENT          │
│                                      │
│  [Continue to Delete]  [Cancel]      │
└──────────────────────────────────────┘
```

**UI Elements - Step 2: Confirmation**
```
┌──────────────────────────────────────┐
│  Confirm Account Deletion            │
├──────────────────────────────────────┤
│  Before you go:                      │
│                                      │
│  □ I have downloaded my data         │
│    (if I want to keep it)            │
│                                      │
│  □ I understand this is permanent    │
│    after 90 days                     │
│                                      │
│  □ I have informed family members    │
│    who follow my profiles            │
│                                      │
│  Type DELETE to confirm:             │
│  [__________________]                │
│                                      │
│  Reason (Optional, helps us improve):│
│  ○ No longer need the app            │
│  ○ Privacy concerns                  │
│  ○ Switching to another app          │
│  ○ Other: [________________]         │
│                                      │
│  [Delete My Account]  [Cancel]       │
└──────────────────────────────────────┘
```

**Consent Logged:**
- Account deletion request
- Timestamp
- Reason (if provided)
- Confirmation that warnings were shown

**User Action:** Complete all steps and tap "Delete My Account"

---

**Confirmation Email:**
```
Subject: Your Nonna App account has been scheduled for deletion

Hi [Name],

Your account deletion request has been received.

What happens next:
• Your account is now disabled (you cannot log in)
• Your data will be permanently deleted in 90 days
• If this was a mistake, contact support within 90 days to recover your account

Deletion date: [90 days from now]

Data that will be deleted:
• Your account and profiles
• All photos and videos you uploaded
• Calendar events, registry items, etc.

Data that will be anonymized (not deleted):
• Comments you made on others' content

If you did not request this, contact us immediately at support@nonnaapp.example.com

Questions? We're here to help: support@nonnaapp.example.com
```

---

## 9. Consent Withdrawal

### 9.1 How to Withdraw Consent

| Consent Type | How to Withdraw |
|--------------|-----------------|
| **Push Notifications** | Settings → Notifications → Toggle off |
| **Email Notifications** | Settings → Notifications → Toggle off OR unsubscribe link in email |
| **Photo Sharing** | Delete photo OR delete profile |
| **Parental Consent (Baby Profile)** | Delete baby profile |
| **Account/Terms/Privacy** | Delete account (only way to withdraw) |

### 9.2 Withdrawal Logging

All consent withdrawals are logged:
- User ID
- Consent type withdrawn
- Timestamp
- Method (in-app, email unsubscribe, account deletion)

### 9.3 Effect of Withdrawal

| Withdrawal | Immediate Effect | Long-term Effect |
|------------|------------------|------------------|
| **Notifications** | Stop sending notifications | No data deleted, can re-enable |
| **Photo** | Photo hidden/deleted | Permanently deleted after 30 days |
| **Baby Profile** | Profile disabled | Permanently deleted after 90 days |
| **Account** | Account disabled | Permanently deleted after 90 days |

---

## 10. Technical Implementation

### 10.1 Consent Database Schema

```sql
CREATE TABLE user_consents (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  consent_type VARCHAR(50) NOT NULL,
  consent_given BOOLEAN NOT NULL,
  policy_version VARCHAR(10),
  timestamp TIMESTAMP DEFAULT NOW(),
  ip_address INET,
  device_info JSONB,
  withdrawn_at TIMESTAMP,
  metadata JSONB
);

CREATE INDEX idx_user_consents_user_id ON user_consents(user_id);
CREATE INDEX idx_user_consents_type ON user_consents(consent_type);
CREATE INDEX idx_user_consents_timestamp ON user_consents(timestamp);
```

### 10.2 Consent Types Enumeration

```typescript
enum ConsentType {
  TERMS_OF_SERVICE = 'terms_of_service',
  PRIVACY_POLICY = 'privacy_policy',
  CHILDREN_PRIVACY_POLICY = 'children_privacy_policy',
  AGE_VERIFICATION = 'age_verification',
  PARENTAL_AUTHORITY = 'parental_authority',
  PUSH_NOTIFICATIONS = 'push_notifications',
  EMAIL_NOTIFICATIONS = 'email_notifications',
  MARKETING_COMMUNICATIONS = 'marketing_communications',
  DATA_PROCESSING = 'data_processing',
  PHOTO_SHARING = 'photo_sharing'
}
```

### 10.3 Consent Validation

```typescript
interface ConsentValidation {
  /**
   * Check if user has given required consents
   */
  hasRequiredConsents(userId: string): Promise<boolean>;
  
  /**
   * Check if specific consent is valid
   */
  isConsentValid(
    userId: string, 
    consentType: ConsentType, 
    policyVersion?: string
  ): Promise<boolean>;
  
  /**
   * Log new consent
   */
  logConsent(
    userId: string,
    consentType: ConsentType,
    given: boolean,
    metadata: ConsentMetadata
  ): Promise<void>;
  
  /**
   * Withdraw consent
   */
  withdrawConsent(
    userId: string,
    consentType: ConsentType
  ): Promise<void>;
  
  /**
   * Get consent history for audit
   */
  getConsentHistory(userId: string): Promise<ConsentRecord[]>;
}
```

### 10.4 Policy Version Management

```typescript
interface PolicyVersion {
  type: 'terms' | 'privacy' | 'children_privacy';
  version: string;
  effectiveDate: Date;
  url: string;
  changesFrom Previous?: string;
}

/**
 * When policies are updated:
 * 1. Create new version entry
 * 2. Notify users of changes
 * 3. Require re-acceptance for material changes
 * 4. Log new consent with new version
 */
```

---

## 11. Compliance and Auditing

### 11.1 GDPR Compliance Checklist

- ✅ **Freely given:** No forced consent for non-essential features
- ✅ **Specific:** Separate consent for each purpose
- ✅ **Informed:** Clear, plain language explanations
- ✅ **Unambiguous:** Explicit opt-in required
- ✅ **Withdrawable:** Easy withdrawal process
- ✅ **Granular:** Separate consent for different data uses
- ✅ **Pre-checked boxes prohibited:** All checkboxes start unchecked
- ✅ **Consent logging:** All consents logged with timestamp and version
- ✅ **Child consent:** Parental consent for children under 16

### 11.2 COPPA Compliance Checklist

- ✅ **Age gate:** Users must be 18+ to create accounts
- ✅ **Parental consent:** Required for baby profile creation
- ✅ **Notice:** Clear privacy notice for children's data
- ✅ **Limited collection:** Only essential child data collected
- ✅ **Parental access:** Parents can review, delete child data
- ✅ **Security:** Reasonable security measures in place
- ✅ **No conditioning:** Service not conditioned on unnecessary data

### 11.3 CCPA Compliance Checklist

- ✅ **Privacy Policy:** Comprehensive privacy notice
- ✅ **Opt-out:** Right to opt-out (though we don't sell data)
- ✅ **Deletion:** Easy account and data deletion
- ✅ **Access:** Users can access their data
- ✅ **Non-discrimination:** No penalty for exercising rights
- ✅ **Children:** Enhanced protections for users under 16

### 11.4 Audit Requirements

**Monthly:**
- Review consent withdrawal requests and processing time
- Monitor notification opt-out rates
- Check for consent UI/UX issues

**Quarterly:**
- Audit consent logs for completeness
- Review policy version tracking
- Validate consent validation logic

**Annually:**
- Full consent framework audit
- Update policies for regulatory changes
- Review and update this document

---

## 12. User Education

### 12.1 In-App Education

**First-Time User Tutorial:**
```
Screen 1: Welcome
"Welcome to Nonna App - Your private family sharing space"

Screen 2: Privacy First
"Your photos are private by default. Only people you invite can see them."

Screen 3: You're in Control
"You decide who sees what. Delete anything, anytime."

Screen 4: No Ads, No Tracking
"We never sell your data or use ads. Your privacy is our priority."

Screen 5: Start Sharing
"Let's create your first baby profile!"
```

### 12.2 Privacy Tips

**Displayed in app periodically:**
- "Remember: Only invite people you trust to view your baby's profile"
- "Tip: You can remove someone's access anytime in profile settings"
- "Privacy reminder: Downloaded photos can be shared. Choose wisely!"
- "Did you know? We automatically remove location data from your photos"

---

## Summary: Consent Best Practices

✅ **Always:**
- Use clear, plain language
- Require explicit opt-in (no pre-checked boxes)
- Log all consents with timestamp and version
- Make withdrawal as easy as giving consent
- Separate consent for separate purposes
- Inform users of data use before collection

❌ **Never:**
- Force consent for non-essential features
- Use legal jargon or confusing language
- Pre-check consent boxes
- Make withdrawal difficult or hidden
- Bundle consents together
- Collect data before obtaining consent

---

**Document Status:** DRAFT - For Legal Review  
**Next Steps:** UI/UX implementation, developer training, legal counsel review  
**Part of:** Story 9.3 - Draft Terms of Service and Policies  
**Epic:** 9 - Stakeholder and Legal Compliance

**Version History:**
- v1.0 (Dec 2025): Initial draft

**Related Documents:**
- Terms of Service
- Privacy Policy
- Children's Privacy Policy
- Data Retention Policy
