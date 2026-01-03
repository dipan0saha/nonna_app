# Ethics Review: Data Handling and User Trust for Nonna App

**Document Version:** 1.0  
**Last Updated:** December 2025  
**Status:** ✅ Final  
**Part of:** Epic 10 - Ethics and Data Ethics Review (Story 10.1)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Introduction](#2-introduction)
3. [Ethical Framework](#3-ethical-framework)
4. [Data Collection Practices](#4-data-collection-practices)
5. [User Consent and Transparency](#5-user-consent-and-transparency)
6. [Privacy Protection Measures](#6-privacy-protection-measures)
7. [Data Retention and Deletion](#7-data-retention-and-deletion)
8. [Third-Party Data Sharing](#8-third-party-data-sharing)
9. [User Trust Mechanisms](#9-user-trust-mechanisms)
10. [Vulnerable Populations](#10-vulnerable-populations)
11. [Compliance and Legal Considerations](#11-compliance-and-legal-considerations)
12. [Risk Assessment and Mitigation](#12-risk-assessment-and-mitigation)
13. [Ethical Guidelines for Development](#13-ethical-guidelines-for-development)
14. [Monitoring and Accountability](#14-monitoring-and-accountability)
15. [Recommendations](#15-recommendations)
16. [Conclusion](#16-conclusion)

---

## 1. Executive Summary

### 1.1. Purpose

This ethics review evaluates the data handling practices and user trust mechanisms for the Nonna App, a mobile application designed to help new parents share pregnancy and parenting journeys with family and friends. The review examines whether the application's design, data practices, and privacy controls meet ethical standards for protecting sensitive family data, particularly information about children and newborns.

### 1.2. Key Findings

✅ **Overall Ethics Assessment: ACCEPTABLE with Recommended Enhancements**

**Strengths:**
- Strong encryption standards (AES-256 at rest, TLS 1.3 in transit)
- Granular access control with Row-Level Security (RLS)
- Private-by-default design (invitation-only access)
- 7-year data retention policy for legal compliance
- No advertising or data monetization model

**Areas Requiring Attention:**
- Need explicit parental consent mechanism for posting child photos
- Require data minimization assessment
- Need clear data export and portability features
- Require transparent privacy policy and terms of service
- Need age verification for users
- Require incident response and breach notification procedures

**Risk Level:** LOW to MEDIUM (can be reduced to LOW with recommendations)

### 1.3. Ethical Verdict

The Nonna App demonstrates a strong foundation for ethical data handling with its privacy-first architecture and robust security measures. However, given the sensitive nature of child data and family information, additional safeguards and transparency measures are essential before launch.

**Recommendation:** **APPROVE with required implementations** of critical recommendations (Section 15.1) before production deployment.

---

## 2. Introduction

### 2.1. Context

The Nonna App handles highly sensitive personal information including:
- **Child data:** Photos, names, birth dates, gender
- **Family relationships:** Familial connections and roles
- **Private life events:** Pregnancy milestones, birth announcements
- **Personal identifiers:** Email addresses, user photos, names
- **Behavioral data:** Engagement patterns, preferences

This data type requires the highest ethical standards for:
- **Privacy protection:** Preventing unauthorized access
- **User autonomy:** Ensuring informed consent
- **Child protection:** Safeguarding minors' digital footprint
- **Trust maintenance:** Building and preserving user confidence

### 2.2. Scope of Review

This ethics review covers:
- Data collection, storage, and usage practices
- User consent mechanisms and transparency
- Privacy protection and security measures
- Third-party data sharing and integrations
- Child data protection and parental rights
- Compliance with privacy laws and regulations
- Risk mitigation strategies

**Out of Scope:**
- User experience design (addressed in separate UX review)
- Performance and scalability (addressed in Epic 5)
- Business model ethics (no monetization planned for MVP)

### 2.3. Methodology

This review was conducted using:
- Analysis of Requirements.md and Technology_Stack.md
- Review of existing security and privacy implementations
- Comparison against GDPR, COPPA, and privacy best practices
- Risk assessment framework (likelihood × impact)
- Ethical principles from ACM Code of Ethics and IEEE Standards

---

## 3. Ethical Framework

### 3.1. Core Ethical Principles

The Nonna App's data handling will be evaluated against these principles:

#### 3.1.1. Respect for Persons (Autonomy)
- Users have the right to make informed decisions about their data
- Consent must be freely given, specific, informed, and unambiguous
- Users must be able to withdraw consent at any time
- Children's data requires parental/guardian consent and protection

#### 3.1.2. Beneficence (Do Good)
- The app should provide genuine value to families
- Features should strengthen family connections, not exploit them
- Data collection should serve users' interests, not just business interests

#### 3.1.3. Non-Maleficence (Do No Harm)
- Minimize risks of data breaches, misuse, or unauthorized access
- Prevent creation of permanent digital footprints for children without consent
- Avoid features that could facilitate harassment or abuse
- Protect users from algorithmic manipulation

#### 3.1.4. Justice (Fairness)
- All users should have equal access to privacy protections
- No discrimination based on technical literacy
- Transparent policies applied consistently to all users
- Fair handling of data subject rights requests

### 3.2. Privacy by Design Principles

The application will be evaluated against Privacy by Design principles:

1. **Proactive not Reactive:** Prevention over remediation
2. **Privacy as Default:** Maximum privacy out of the box
3. **Privacy Embedded in Design:** Not an add-on
4. **Full Functionality:** No false trade-offs between privacy and functionality
5. **End-to-End Security:** Lifecycle protection
6. **Visibility and Transparency:** Open and honest operations
7. **Respect for User Privacy:** User-centric design

---

## 4. Data Collection Practices

### 4.1. Data Categories Collected

#### 4.1.1. Account Data (Necessary)
- **Email address:** For authentication and communication
- **Password (hashed):** For secure access
- **User name:** For identification within app
- **Profile photo:** Optional, for personalization

**Ethical Assessment:** ✅ **Acceptable**
- Minimal data required for core functionality
- Industry-standard authentication practices
- Password hashing prevents exposure

#### 4.1.2. Baby Profile Data (Sensitive)
- **Baby name:** For profile identification
- **Birth date / Expected birth date:** For milestone tracking
- **Gender:** Optional, for personalization
- **Baby photo:** Optional, for profile
- **Relationship labels:** (e.g., Mother, Father, Grandma)

**Ethical Assessment:** ⚠️ **Requires Enhancement**

**Current State:**
- Data is necessary for core app functionality
- Privacy-by-default: Profiles are private, invitation-only

**Required Enhancements:**
- ⚠️ **Parental consent mechanism** for posting child information
- ⚠️ **Age verification** to ensure users are adults
- ⚠️ **Option to use nicknames** instead of full legal names
- ⚠️ **Warning about digital footprint** during profile creation

#### 4.1.3. Content Data (User-Generated)
- **Photos:** Up to 1,000 per gallery (JPEG/PNG, max 10MB)
- **Event details:** Calendar entries with descriptions
- **Comments:** User interactions
- **Registry items:** Baby product lists
- **RSVPs and votes:** Engagement data

**Ethical Assessment:** ✅ **Acceptable with Current Design**

**Strengths:**
- User-initiated and controlled
- Can be deleted by owners
- Access controlled via RLS policies

**Recommendations:**
- Provide bulk export feature for portability
- Clear guidance on appropriate photo sharing

#### 4.1.4. Metadata (Automatic Collection)
- **Timestamps:** For sorting and activity tracking
- **Device information:** For push notification delivery (OneSignal)
- **Usage patterns:** Implicit through database queries

**Ethical Assessment:** ⚠️ **Requires Transparency**

**Current State:**
- Minimal metadata collection
- No analytics or tracking beyond operational needs

**Required Enhancements:**
- ⚠️ **Disclose all automatic data collection** in privacy policy
- ⚠️ **Minimize analytics data** - collect only what's operationally necessary
- ⚠️ **User control over non-essential metadata** collection

### 4.2. Data Minimization Assessment

**Principle:** Collect only data necessary for stated purposes.

| Data Type | Necessary? | Purpose | Alternative Considered? |
|-----------|-----------|---------|------------------------|
| Email | ✅ Yes | Authentication, invitations | ❌ No viable alternative |
| Password | ✅ Yes | Security | ❌ No viable alternative |
| User Name | ✅ Yes | Identification | ✅ Could use email, but UX suffers |
| User Photo | ⚠️ Optional | Personalization | ✅ Should remain optional |
| Baby Name | ⚠️ Debatable | Profile identity | ✅ Could use "Baby A", "Baby B" |
| Baby Birth Date | ⚠️ Debatable | Milestone tracking | ✅ Could use age ranges instead |
| Baby Gender | ❌ No | Optional field | ✅ Already optional |
| Relationship Labels | ✅ Yes | Access context, permissions | ✅ Generic "Family" option exists |
| Device Info (OneSignal) | ✅ Yes | Push notifications | ⚠️ Requires third-party service |

**Assessment:** ✅ **Generally Minimal**

**Recommendations:**
1. Provide option to use pseudonyms for baby names (e.g., "Baby Smith")
2. Allow approximate birth dates (month/year only) for privacy-conscious users
3. Audit OneSignal data collection and ensure GDPR compliance
4. Document data necessity in privacy policy

### 4.3. Purpose Limitation

**Principle:** Data should only be used for disclosed, legitimate purposes.

**Current Purposes (from Requirements):**
- Facilitate sharing of family milestones and photos
- Enable private communication among invited family/friends
- Coordinate events and gift registries
- Send notifications about updates

**Prohibited Uses (Must be Enforced):**
- ❌ Selling data to third parties
- ❌ Advertising or profiling
- ❌ Training AI models without explicit consent
- ❌ Cross-profile analysis or data mining
- ❌ Sharing with law enforcement without valid legal process

**Assessment:** ✅ **Well-Defined Purposes**

**Recommendations:**
- Formally document prohibited uses in privacy policy
- Implement technical controls to prevent purpose creep
- Annual review of data usage practices

---

## 5. User Consent and Transparency

### 5.1. Current Consent Mechanisms

#### 5.1.1. Account Creation
**Current Implementation:**
- Email verification required
- Password meets minimum security requirements
- User creates account voluntarily

**Ethical Assessment:** ⚠️ **Incomplete**

**Missing Elements:**
- ❌ No explicit acceptance of Terms of Service
- ❌ No privacy policy presented during signup
- ❌ No age verification (must be 18+ to consent)
- ❌ No consent checkbox for data processing

**Required Implementation:**
```
During signup, users must:
1. Confirm they are 18+ years old
2. Read and accept Terms of Service (with link)
3. Read and accept Privacy Policy (with link)
4. Provide explicit consent for data processing
5. Optionally consent to push notifications (can enable later)
```

#### 5.1.2. Baby Profile Creation
**Current Implementation:**
- Parents can create baby profiles
- No explicit consent for child data processing

**Ethical Assessment:** ❌ **CRITICAL GAP**

**Required Implementation:**
```
Before creating baby profile, show consent screen:

"Creating a Child Profile
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
By creating a baby profile, you acknowledge that:

☑ You are the parent or legal guardian of this child
☑ You have the right to share this child's information
☑ You understand this creates a digital footprint for the child
☑ You can delete this profile and data at any time
☑ Only invited users will have access to this profile

[Review Privacy Policy] [Cancel] [I Consent & Create Profile]
"
```

#### 5.1.3. Photo Uploads
**Current Implementation:**
- Owners can upload photos
- No specific consent for child photo sharing

**Ethical Assessment:** ⚠️ **Needs Enhancement**

**Recommended Implementation:**
- First-time photo upload: Show educational dialog about responsible sharing
- Periodic reminders about photo privacy settings
- Option to mark photos as "private" (visible only to owners)

#### 5.1.4. Invitation Acceptance
**Current Implementation:**
- Email invitation with unique link
- User must create account to accept
- User provides relationship label

**Ethical Assessment:** ✅ **Good Foundation**

**Enhancement Recommendations:**
- Show privacy policy and terms during invitation acceptance
- Display what data they'll have access to
- Explain data handling before account creation

### 5.2. Granular Consent Controls

**Principle:** Users should be able to consent to different data processing activities separately.

**Recommended Consent Levels:**

| Activity | Required? | User Control | Current Implementation |
|----------|-----------|--------------|------------------------|
| Basic account data | ✅ Yes | Cannot opt-out (core functionality) | ✅ Implemented |
| Baby profile data | ✅ Yes (for owners) | Delete profile anytime | ✅ Implemented |
| Push notifications | ❌ No | Opt-in during/after signup | ⚠️ Needs enhancement |
| Email notifications | ⚠️ Transactional emails required | Can reduce frequency | ⚠️ Not implemented |
| Data sharing with co-owners | ✅ Yes (implied by collaboration) | Remove co-owner | ✅ Implemented |
| Analytics cookies (future) | ❌ No | Must be opt-in (GDPR) | N/A (none planned) |

**Assessment:** ⚠️ **Needs Implementation**

**Required Actions:**
1. Create consent management screen in settings
2. Allow users to review and modify consent preferences
3. Log consent changes with timestamps
4. Honor opt-outs within 24 hours

### 5.3. Transparency Requirements

#### 5.3.1. Privacy Policy (REQUIRED)

**Must Include:**
- ✅ **What data we collect:** Full list of data types
- ✅ **Why we collect it:** Purpose for each data type
- ✅ **How we use it:** Processing activities
- ✅ **Who we share it with:** Third-party services (OneSignal, SendGrid, Supabase)
- ✅ **How long we keep it:** 7-year retention policy explained
- ✅ **User rights:** Access, rectification, erasure, portability, objection
- ✅ **How to contact us:** Data protection contact
- ✅ **How we protect it:** Security measures (encryption, RLS)
- ✅ **International transfers:** If Supabase servers are outside user's country
- ✅ **Changes to policy:** How users will be notified
- ✅ **Children's data:** Special protections for minors

**Language Requirements:**
- Written in plain, understandable language (8th-grade reading level)
- Available in app and on website
- Version history maintained
- Last updated date displayed

**Assessment:** ❌ **NOT YET CREATED - CRITICAL**

#### 5.3.2. Terms of Service (REQUIRED)

**Must Include:**
- User responsibilities and acceptable use
- Intellectual property rights (user content ownership)
- Liability limitations
- Dispute resolution
- Termination conditions
- Governing law and jurisdiction

**Assessment:** ❌ **NOT YET CREATED - CRITICAL**

#### 5.3.3. In-App Transparency

**Recommended Implementations:**
- Privacy dashboard showing what data is collected
- Data access log (who accessed which profiles/photos when)
- Clear indicators when data is shared with third parties
- Settings screen explaining each permission

**Assessment:** ⚠️ **NOT IMPLEMENTED - RECOMMENDED**

---

## 6. Privacy Protection Measures

### 6.1. Technical Safeguards

#### 6.1.1. Encryption (EXCELLENT ✅)

**Data at Rest:**
- ✅ AES-256 encryption for PostgreSQL database
- ✅ AES-256 encryption for S3 storage (photos)
- ✅ Encryption keys managed by Supabase/AWS

**Data in Transit:**
- ✅ TLS 1.3 for all network communication
- ✅ Certificate pinning possible in Flutter

**Assessment:** ✅ **Exceeds Industry Standards**

#### 6.1.2. Access Control (EXCELLENT ✅)

**Row-Level Security (RLS):**
- ✅ Granular permissions enforced at database level
- ✅ Users can only access profiles they're invited to
- ✅ Owners have different permissions than followers
- ✅ Frontend restrictions backed by database policies

**Assessment:** ✅ **Strong Privacy-by-Design**

#### 6.1.3. Authentication (GOOD ✅)

**Current Implementation:**
- ✅ JWT-based authentication (OAuth 2.0)
- ✅ Secure password hashing
- ✅ Email verification required
- ✅ Password reset via secure email link
- ✅ Session tokens stored in device secure storage (Keychain/Keystore)

**Enhancement Opportunities:**
- ⚠️ Add two-factor authentication (2FA) for sensitive accounts
- ⚠️ Implement session expiry and refresh mechanisms
- ⚠️ Add device management (view and revoke sessions)
- ⚠️ Consider biometric authentication for app access

**Assessment:** ✅ **Acceptable, Enhancements Recommended**

#### 6.1.4. Data Isolation (EXCELLENT ✅)

**Architecture:**
- ✅ Each baby profile is completely isolated
- ✅ No cross-profile queries or data leakage possible
- ✅ Followers cannot discover other profiles

**Assessment:** ✅ **Optimal Privacy Architecture**

### 6.2. Operational Safeguards

#### 6.2.1. Access Logging

**Current State:** ⚠️ Not explicitly documented

**Required Implementation:**
- Log all access to baby profiles (who, when, what)
- Log administrative actions
- Retain logs for security investigations
- Provide users with access to their access logs

**Assessment:** ⚠️ **NEEDS IMPLEMENTATION**

#### 6.2.2. Incident Response

**Current State:** ❌ Not documented

**Required Components:**
1. **Breach Detection:** Monitoring and alerting
2. **Incident Response Plan:** Step-by-step procedures
3. **Breach Notification:** Legal timelines (72 hours GDPR)
4. **User Communication:** Templates and channels
5. **Post-Incident Review:** Root cause analysis

**Assessment:** ❌ **CRITICAL GAP - MUST IMPLEMENT**

#### 6.2.3. Third-Party Risk Management

**Third-Party Services:**
- **Supabase:** Database, auth, storage, realtime
- **OneSignal:** Push notifications
- **SendGrid:** Email delivery
- **AWS (via Supabase):** Infrastructure

**Required Actions:**
1. ✅ Review each vendor's privacy policy and DPA
2. ⚠️ Sign Data Processing Agreements (DPAs) with all vendors
3. ⚠️ Verify GDPR compliance for each service
4. ⚠️ Document data flows to third parties
5. ⚠️ Regular vendor security reviews
6. ⚠️ Exit strategy if vendor fails compliance

**Assessment:** ⚠️ **PARTIAL - NEEDS COMPLETION**

**Vendor Assessment:**

| Vendor | Purpose | GDPR Compliant? | DPA Available? | Risk Level |
|--------|---------|-----------------|----------------|------------|
| Supabase | Backend | ✅ Yes | ✅ Yes | ✅ Low |
| AWS (S3) | Storage | ✅ Yes | ✅ Yes | ✅ Low |
| OneSignal | Push Notifications | ✅ Yes | ✅ Yes | ⚠️ Medium (device tracking) |
| SendGrid | Email | ✅ Yes | ✅ Yes | ✅ Low |

**Action Items:**
1. Execute DPAs with all vendors before production launch
2. Review OneSignal's data collection practices in detail
3. Minimize data sent to OneSignal (user IDs only, no child data)
4. Document all vendor relationships in privacy policy

### 6.3. Privacy by Default Settings

**Principle:** Most privacy-protective settings should be default.

**Recommended Defaults:**

| Setting | Default Value | User Can Change? | Rationale |
|---------|---------------|------------------|-----------|
| Profile visibility | Private (invite-only) | ❌ No | Core privacy model |
| Push notifications | Off | ✅ Yes | Opt-in required (GDPR) |
| Email notifications | Essential only | ✅ Yes | Minimize contact |
| Photo visibility | Followers only | ⚠️ Add "Owners only" option | Enhanced privacy |
| Share to external apps | Disabled | ✅ Yes | Prevent accidental sharing |
| Data export | Available | N/A | User right |

**Assessment:** ✅ **Strong Privacy-by-Default Architecture**

**Enhancements:**
- Add "Owners only" visibility option for sensitive photos
- Implement photo download restrictions (watermark option)
- Add copy protection for photos (disable screenshots warning)

---

## 7. Data Retention and Deletion

### 7.1. Retention Policy

#### 7.1.1. Active Data
**Current Implementation:**
- Data retained while account is active
- No automatic deletion of old data

**Assessment:** ✅ **Acceptable**

**Recommendations:**
- Provide tools for users to archive or delete old content
- Annual reminder to review and clean up data

#### 7.1.2. Deleted Data (7-Year Retention)
**Current Implementation:**
- Soft delete: Data marked as deleted but retained for 7 years
- Purpose: Legal compliance (data retention policies)

**Ethical Assessment:** ⚠️ **REQUIRES TRANSPARENCY AND CONTROLS**

**Issues:**
1. **User Expectation Gap:** Users clicking "delete" expect data to be gone
2. **Storage Concerns:** Storing deleted data for 7 years increases breach risk
3. **Right to Erasure:** GDPR's "right to be forgotten" may conflict with 7-year retention

**Required Implementations:**

```
Deletion Confirmation Dialog:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Delete [Photo/Event/Profile]?

This item will be:
• Immediately hidden from all users
• Removed from app and search results
• Retained in secure backup for 7 years (legal requirement)
• Permanently deleted after 7 years

You can request immediate permanent deletion by contacting
support with a valid reason (e.g., privacy concern).

[Cancel] [Delete]
```

**Retention Policy Refinements:**

1. **Two-Tier Deletion:**
   - **Soft Delete (Default):** Hidden from users, retained for 7 years
   - **Hard Delete (On Request):** Immediate permanent deletion for valid reasons

2. **Valid Reasons for Immediate Deletion:**
   - Privacy breach or doxxing concern
   - Court order or legal requirement
   - Account compromise
   - Child protection concern
   - GDPR right to erasure (with exceptions noted)

3. **Retention Exceptions:**
   - Financial records: May require longer retention
   - Legal holds: Suspended deletion for litigation
   - Security logs: Retained for incident investigation

**Assessment:** ⚠️ **NEEDS POLICY REFINEMENT**

### 7.2. Right to Erasure (GDPR Article 17)

**User Rights:**
- Request deletion of personal data
- Receive confirmation of deletion
- Exception: Retention required by law

**Implementation Requirements:**

1. **Deletion Request Form:**
   - In-app submission
   - Email submission option
   - Processing timeline: 30 days

2. **Deletion Scope:**
   - User profile data
   - Baby profile data (if owner)
   - Photos and content
   - Comments and interactions
   - Metadata and logs (with exceptions)

3. **Exceptions (Must Be Documented):**
   - Legal retention requirements (7-year policy)
   - Ongoing legal disputes
   - Security and fraud prevention logs

4. **Verification:**
   - Identity verification required for deletion requests
   - Prevent malicious account deletion

**Assessment:** ⚠️ **NEEDS IMPLEMENTATION**

### 7.3. Data Portability (GDPR Article 20)

**User Rights:**
- Receive personal data in structured, machine-readable format
- Transfer data to another service

**Required Implementation:**

**Data Export Feature:**
```
Settings > Privacy > Download My Data

What's Included:
• Your profile information (JSON)
• Baby profiles you own (JSON)
• All photos (ZIP with metadata)
• Comments and interactions (JSON)
• Calendar events (iCal format)
• Registry items (CSV)

Format: ZIP file
Processing time: Up to 48 hours
Delivery: Secure download link via email

[Request Data Export]
```

**Data Format Standards:**
- JSON for structured data
- Original formats for photos (JPEG/PNG)
- CSV for tabular data
- iCal for calendar events

**Assessment:** ❌ **NOT IMPLEMENTED - REQUIRED**

**Priority:** HIGH (legal requirement under GDPR)

---

## 8. Third-Party Data Sharing

### 8.1. Service Providers

**Data Shared with Third Parties:**

#### 8.1.1. Supabase (Backend Infrastructure)
**Data Shared:** All application data (profiles, photos, events, etc.)
**Purpose:** Core application functionality
**User Control:** ❌ None (essential service)
**DPA Required:** ✅ Yes
**Assessment:** ✅ **Acceptable** (necessary for service delivery)

#### 8.1.2. OneSignal (Push Notifications)
**Data Shared:** 
- Device tokens
- User IDs (not child data)
- Notification content (event titles, photo captions)

**Privacy Concern:** ⚠️ **MEDIUM**
- OneSignal collects device information for targeting
- Potential for behavioral tracking

**Mitigation Strategies:**
1. ✅ Use user IDs, not email addresses
2. ⚠️ Minimize notification content (avoid child names in push notifications)
3. ⚠️ Configure OneSignal to minimize data collection
4. ⚠️ Provide opt-out mechanism
5. ⚠️ Review OneSignal DPA and privacy policy

**Recommended Enhancement:**
- Implement notifications via Supabase Realtime (in-app only) as alternative
- Make push notifications completely optional

**Assessment:** ⚠️ **ACCEPTABLE WITH ENHANCEMENTS**

#### 8.1.3. SendGrid (Email Delivery)
**Data Shared:**
- Email addresses
- Email content (invitations, password resets)

**Privacy Concern:** ✅ **LOW**
- Transactional emails only
- No marketing use

**Mitigation:**
1. ✅ Use SendGrid's email suppression lists
2. ⚠️ Sign DPA with SendGrid
3. ⚠️ Ensure GDPR-compliant email processing

**Assessment:** ✅ **ACCEPTABLE**

### 8.2. No Advertising or Analytics (EXCELLENT ✅)

**Current State:**
- ❌ No advertising networks
- ❌ No third-party analytics (Google Analytics, Facebook Pixel, etc.)
- ❌ No data monetization

**Assessment:** ✅ **EXCELLENT - Strong Privacy Position**

**Recommendation:** 
- Maintain this policy permanently
- Document commitment in privacy policy
- If future analytics are needed, use privacy-preserving alternatives:
  - Self-hosted analytics (e.g., Plausible, Matomo)
  - Opt-in only
  - Aggregated data only, no individual tracking

### 8.3. User-Initiated Sharing

**Current Implementation:**
- Native device sharing (iOS Share Sheet, Android Share Intent)
- Users can share content outside the app

**Privacy Concerns:**
- ⚠️ Users may accidentally share to public platforms
- ⚠️ Shared content loses access controls
- ⚠️ Photos may contain metadata (location, device info)

**Mitigation Strategies:**

1. **Sharing Warnings:**
```
Share this photo?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ This photo will leave Nonna's private space.

• Anyone with the link can view it
• You cannot revoke access after sharing
• Photo metadata (location, date) may be included

Consider sharing within Nonna instead by inviting
users to this baby profile.

[Cancel] [Share Anyway]
```

2. **Metadata Stripping:**
   - Remove EXIF data (GPS, device info) before sharing
   - Option to add watermark with "Private - Do Not Share"

3. **Educational Resources:**
   - Tips for safe photo sharing
   - Understanding digital footprint

**Assessment:** ⚠️ **NEEDS IMPLEMENTATION**

---

## 9. User Trust Mechanisms

### 9.1. Transparency Features

#### 9.1.1. Privacy Dashboard (RECOMMENDED)

**Proposed Features:**
- **Data Summary:** Visual overview of data stored
- **Access Log:** Who viewed which profiles/photos
- **Third-Party Sharing:** List of services with data access
- **Consent Status:** Current consent preferences
- **Data Download:** Request data export

**Assessment:** ⚠️ **NOT IMPLEMENTED - HIGHLY RECOMMENDED**

**Benefits:**
- Increases user trust and transparency
- Demonstrates commitment to privacy
- Helps users understand their data

#### 9.1.2. Security Notifications

**Recommended Notifications:**
- New device login detected
- Password changed
- Email address changed
- Baby profile created/deleted
- New owner added to profile
- Unusual access patterns

**Assessment:** ⚠️ **PARTIALLY IMPLEMENTED** (some notifications exist)

### 9.2. User Control Mechanisms

#### 9.2.1. Access Management (GOOD ✅)

**Current Features:**
- ✅ Invite/revoke followers
- ✅ Remove yourself as follower
- ✅ Manage co-owners
- ✅ Delete content

**Enhancement Opportunities:**
- ⚠️ Temporary access (e.g., 30-day visitor pass)
- ⚠️ View-only vs. interactive access levels
- ⚠️ Bulk revoke (remove all followers at once)

**Assessment:** ✅ **STRONG FOUNDATION**

#### 9.2.2. Content Control (GOOD ✅)

**Current Features:**
- ✅ Delete photos, events, comments
- ✅ Edit captions and descriptions
- ✅ Upload/remove profile photos

**Enhancement Opportunities:**
- ⚠️ Archive content (hide without deleting)
- ⚠️ Download original photos
- ⚠️ Bulk actions (delete multiple photos)
- ⚠️ Photo visibility levels (owners only, followers, specific users)

**Assessment:** ✅ **GOOD BASELINE**

### 9.3. Trust Signals

**Recommended Implementations:**

1. **Trust Badges:**
   - 🔒 "End-to-End Encrypted"
   - 🛡️ "GDPR Compliant"
   - ✅ "No Ads, No Tracking"
   - 🔐 "Private by Default"

2. **Transparent Security Practices:**
   - Public security page explaining encryption, access control
   - Annual security audit reports (summary)
   - Incident disclosure policy

3. **User Testimonials:**
   - Privacy-focused messaging in marketing
   - Case studies from privacy-conscious users

**Assessment:** ⚠️ **NOT IMPLEMENTED - RECOMMENDED FOR TRUST BUILDING**

---

## 10. Vulnerable Populations

### 10.1. Children's Data Protection

**Legal Context:**
- **COPPA (US):** Requires parental consent for children under 13
- **GDPR (EU):** Requires parental consent for children under 16 (or 13-16 depending on country)
- **General principle:** Children cannot consent to data processing

**Nonna App Context:**
- Baby profiles contain data about children (photos, names, birth dates)
- Children cannot consent to their data being shared
- Parents act as custodians of children's digital identity

#### 10.1.1. Parental Consent (CRITICAL ❌)

**Current State:** No explicit parental consent mechanism

**Required Implementation:**

**Profile Creation Consent Flow:**
```
Creating a Baby Profile
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Important Information About Your Child's Privacy

By creating this profile, you will share your child's:
• Name and photo
• Birth date and gender
• Photos and milestones
• Life events

This information will be:
✅ Encrypted and secure
✅ Visible only to people you invite
✅ Under your complete control
✅ Deletable at any time

⚠️ This creates a digital footprint for your child that may
   exist for years. Please share responsibly.

☑ I am the parent or legal guardian of this child
☑ I have the right to share this child's information  
☑ I understand the privacy implications
☑ I have read the Children's Privacy Policy

[Review Children's Privacy Policy]
[Cancel] [Create Profile]
```

**Assessment:** ❌ **CRITICAL GAP - MUST IMPLEMENT**

#### 10.1.2. Children's Privacy Policy (REQUIRED)

**Must Include:**
- What child data is collected
- How it's protected
- Who has access
- How parents can control it
- How to request deletion
- What happens when child turns 18
- No marketing or profiling of children

**Assessment:** ❌ **NOT CREATED - REQUIRED**

#### 10.1.3. Age-Appropriate Design

**Recommended Practices:**
- Minimize data collection (use nicknames, approximate dates)
- No AI/ML training on children's photos without explicit consent
- No facial recognition on children's photos
- Avoid gamification that encourages over-sharing
- Provide age-out option (transfer control to child at age 18)

**Assessment:** ⚠️ **PARTIAL IMPLEMENTATION**

**Required Actions:**
1. Document "no AI training on child data" policy
2. Implement age-out mechanism (notify parents when child turns 18)
3. Provide option to transfer profile ownership to child

### 10.2. Privacy-Conscious Users

**User Personas:**
- Users concerned about digital footprint
- Users in abusive relationships (stalking risk)
- Users with privacy-invasive family members
- Users in countries with weak privacy laws

**Recommended Features:**

#### 10.2.1. Enhanced Privacy Mode

**Features:**
- Use pseudonyms instead of real names
- Approximate dates instead of exact birth dates
- Disable location data in photos (already planned)
- Watermark photos with "Private"
- Require password to view photos

**Assessment:** ⚠️ **NOT IMPLEMENTED - RECOMMENDED**

#### 10.2.2. Safety Features

**For Abuse Prevention:**
- Ability to quickly revoke all access
- Hidden mode (temporarily hide profile without deletion)
- Emergency contact for account recovery
- Export data without notifying other users

**Assessment:** ⚠️ **NOT IMPLEMENTED - IMPORTANT**

---

## 11. Compliance and Legal Considerations

### 11.1. GDPR Compliance (EU)

**Status:** ⚠️ **PARTIAL COMPLIANCE - GAPS TO ADDRESS**

| GDPR Requirement | Status | Implementation | Priority |
|------------------|--------|----------------|----------|
| Lawful basis for processing | ⚠️ Partial | Need to document consent/legitimate interest | 🔴 HIGH |
| Data minimization | ✅ Good | Minimal data collection | ✅ Complete |
| Purpose limitation | ✅ Good | Clear purposes defined | ✅ Complete |
| Storage limitation | ⚠️ Partial | 7-year retention needs justification | 🟡 MEDIUM |
| Integrity & confidentiality | ✅ Excellent | AES-256, TLS 1.3, RLS | ✅ Complete |
| Accountability | ⚠️ Partial | Need DPO, DPIA, records of processing | 🔴 HIGH |
| User rights (access, rectify, erase) | ❌ Missing | Need to implement data export, deletion | 🔴 HIGH |
| Data Protection Impact Assessment (DPIA) | ❌ Missing | Required for child data processing | 🔴 HIGH |
| Privacy by design | ✅ Excellent | Strong architectural choices | ✅ Complete |
| Breach notification | ❌ Missing | 72-hour notification process needed | 🔴 HIGH |
| International data transfers | ⚠️ Unknown | Depends on Supabase region | 🟡 MEDIUM |
| DPAs with processors | ⚠️ Partial | Need to execute with all vendors | 🔴 HIGH |

**Critical Actions:**
1. **Conduct Data Protection Impact Assessment (DPIA):** Given processing of children's data
2. **Appoint Data Protection Officer (DPO):** Or designate responsible person
3. **Execute Data Processing Agreements:** With Supabase, OneSignal, SendGrid
4. **Implement User Rights:** Data export, deletion, access, rectification
5. **Create Records of Processing Activities (ROPA):** Document all data processing
6. **Establish Breach Notification Process:** 72-hour timeline
7. **Review Data Transfer Mechanisms:** Ensure Standard Contractual Clauses (SCCs) if EU data leaves EU

### 11.2. COPPA Compliance (US)

**Status:** ⚠️ **REQUIRES ATTENTION IF TARGETING US USERS**

**COPPA Requirements:**
- Obtain verifiable parental consent before collecting child data (under 13)
- Provide parents with access to their child's data
- Allow parents to delete child's data
- Not condition participation on collecting more data than necessary
- Maintain reasonable security for collected data

**Nonna App Context:**
- Not directly targeting children (app is for parents)
- But collects data *about* children (baby profiles)

**COPPA Applicability:** ⚠️ **UNCLEAR - LEGAL REVIEW RECOMMENDED**

**Argument for Non-Applicability:**
- App is directed at adults (parents), not children
- Children are subjects, not users
- Similar to parenting blogs, photo storage services

**Argument for Applicability:**
- App collects persistent identifiers and photos of children
- FTC may consider this "directed to children" if primary content is child-related

**Recommendation:**
- **Consult legal counsel** specialized in COPPA
- Implement parental consent mechanisms anyway (good practice)
- Document that children under 13 cannot create accounts

### 11.3. CalOPPA (California)

**Status:** ⚠️ **NEEDS COMPLIANCE IF SERVING CALIFORNIA USERS**

**Requirements:**
- Conspicuous privacy policy
- Describe data collection practices
- Explain how users can review/change data
- Disclose Do Not Track (DNT) support
- Notify users of policy changes

**Assessment:** ⚠️ **PARTIAL - Privacy policy creation required**

### 11.4. Other Jurisdictions

**Considerations:**
- **Brazil (LGPD):** Similar to GDPR
- **Canada (PIPEDA):** Consent and reasonable security
- **Australia (Privacy Act):** APP entities must comply
- **India (PDPB):** Pending legislation

**Recommendation:**
- Design for GDPR compliance (highest standard)
- Add jurisdiction-specific terms if expanding globally
- Monitor privacy law developments

### 11.5. Legal Documentation Needed

**Priority Legal Documents:**

1. **Privacy Policy** 🔴 CRITICAL
2. **Terms of Service** 🔴 CRITICAL  
3. **Children's Privacy Policy** 🔴 CRITICAL
4. **Cookie Policy** 🟡 MEDIUM (if future web version)
5. **Data Processing Agreements (DPAs)** 🔴 CRITICAL
6. **Data Protection Impact Assessment (DPIA)** 🔴 CRITICAL
7. **Records of Processing Activities (ROPA)** 🟡 MEDIUM
8. **Incident Response Plan** 🔴 CRITICAL
9. **Data Retention Policy** 🟡 MEDIUM
10. **User Rights Request Procedures** 🔴 CRITICAL

**Assessment:** ❌ **MOST LEGAL DOCUMENTS MISSING - CRITICAL GAP**

**Recommendation:** Engage privacy attorney before production launch.

---

## 12. Risk Assessment and Mitigation

### 12.1. Privacy Risk Matrix

| Risk | Likelihood | Impact | Severity | Mitigation Status |
|------|-----------|--------|----------|-------------------|
| Data breach exposing child photos | Low | Critical | 🔴 HIGH | ⚠️ Partial (encryption ✅, monitoring ❌) |
| Unauthorized access by ex-partner | Medium | High | 🟡 MEDIUM | ✅ Good (RLS, invite-only) |
| Accidental public sharing by user | Medium | High | 🟡 MEDIUM | ❌ Not mitigated (need warnings) |
| Third-party vendor breach (OneSignal) | Low | Medium | 🟡 MEDIUM | ⚠️ Partial (minimize data sharing) |
| Non-compliance with GDPR | Medium | High | 🔴 HIGH | ❌ Not mitigated (gaps exist) |
| Child identity theft from exposed data | Low | Critical | 🟡 MEDIUM | ⚠️ Partial (encryption ✅, PII minimization ❌) |
| Failure to honor deletion requests | Low | High | 🟡 MEDIUM | ❌ Not mitigated (no process) |
| Inappropriate access by followers | Low | Medium | 🟢 LOW | ✅ Good (RLS, owner controls) |
| Loss of user trust due to lack of transparency | Medium | Medium | 🟡 MEDIUM | ❌ Not mitigated (no privacy policy) |
| Litigation from privacy violation | Low | Critical | 🟡 MEDIUM | ❌ Not mitigated (legal docs needed) |

### 12.2. Mitigation Strategies

#### 12.2.1. Technical Mitigations (Mostly Implemented ✅)

**Implemented:**
- ✅ End-to-end encryption (TLS 1.3)
- ✅ Encryption at rest (AES-256)
- ✅ Row-Level Security (RLS)
- ✅ JWT authentication
- ✅ Secure password hashing
- ✅ Email verification
- ✅ Invitation-only access model

**Needed:**
- ❌ Access logging and monitoring
- ❌ Intrusion detection
- ❌ Automated security scanning
- ❌ Penetration testing
- ❌ Metadata stripping from shared photos
- ❌ Two-factor authentication (2FA)

#### 12.2.2. Policy Mitigations (Mostly Missing ❌)

**Needed:**
- ❌ Privacy Policy
- ❌ Terms of Service
- ❌ Children's Privacy Policy
- ❌ Incident Response Plan
- ❌ Data Processing Agreements
- ❌ User Rights Request Procedures
- ❌ Breach Notification Procedures

#### 12.2.3. Operational Mitigations (Needed)

**Recommended:**
- Security awareness training for team
- Regular security audits (annual)
- Third-party penetration testing
- Vendor risk assessments
- Compliance monitoring
- User education (safe sharing practices)

### 12.3. Residual Risk Assessment

**After Full Implementation of Recommendations:**

**Overall Risk Level:** 🟢 **LOW**

**Justification:**
- Strong technical foundation (encryption, RLS)
- Privacy-by-design architecture
- Minimal third-party sharing
- No advertising or tracking
- Clear access controls
- User-centric features

**Remaining Risks:**
- User error (accidental sharing) - **MEDIUM** (education can reduce)
- Sophisticated targeted attack - **LOW** (requires significant effort)
- Zero-day vulnerability in dependencies - **LOW** (keep updated)
- Legal landscape changes - **LOW** (monitor and adapt)

---

## 13. Ethical Guidelines for Development

### 13.1. Principles for Feature Development

**Before Adding Any New Feature, Ask:**

1. **Data Minimization:** Does this feature require collecting additional data?
   - If yes, is it absolutely necessary?
   - Can we achieve the goal with less data?

2. **User Benefit:** Does this feature primarily benefit users or the business?
   - Features should strengthen family connections, not engagement metrics

3. **Consent:** Can users opt out of this feature?
   - Default to opt-out for non-essential features

4. **Transparency:** Can we explain this feature in plain language?
   - If not, it may be too complex or privacy-invasive

5. **Child Impact:** Does this feature affect children's data?
   - Require additional parental consent if yes

### 13.2. Red Flags - Features to Avoid

❌ **Never Implement:**
- Facial recognition or biometric analysis on children
- Behavioral profiling or algorithmic ranking
- Geolocation tracking or location history
- Social graph analysis or "suggested friends"
- Third-party advertising or tracking pixels
- Gamification that encourages over-sharing
- Public profiles or discoverability features
- AI training on user data without explicit consent
- Data selling or monetization schemes

### 13.3. Green Lights - Ethical Feature Examples

✅ **Encouraged Features:**
- Enhanced privacy controls (granular permissions)
- Data portability and export tools
- Transparency dashboards (show what data is collected)
- User education (privacy tips, safe sharing)
- Offline mode (reduce server-side data)
- End-to-end encryption for messages (if added)
- Privacy-preserving analytics (aggregated only)
- Account security features (2FA, device management)

### 13.4. Code of Conduct for Data Handling

**For All Developers and Team Members:**

1. **Minimize Access:** Only access user data when absolutely necessary for debugging or support
2. **Log All Access:** Every access to production data must be logged and justified
3. **Anonymize When Possible:** Use anonymized data for testing and development
4. **Respect User Choices:** Honor opt-outs and deletion requests promptly
5. **Secure by Default:** Security cannot be an afterthought
6. **Question Everything:** If a feature feels privacy-invasive, speak up
7. **Educate Users:** Help users understand their privacy options
8. **Report Issues:** Immediately report potential privacy violations

---

## 14. Monitoring and Accountability

### 14.1. Metrics to Track

**Privacy Health Metrics:**

1. **User Trust Metrics:**
   - Privacy policy acceptance rate
   - Opt-in rate for push notifications
   - Data export requests (volume and frequency)
   - Account deletion requests (and reasons)
   - Support tickets about privacy

2. **Security Metrics:**
   - Failed login attempts
   - Unauthorized access attempts
   - Security incidents (count, severity)
   - Time to resolve security issues
   - Penetration test findings

3. **Compliance Metrics:**
   - User rights requests (access, deletion, rectification)
   - Response time to requests (must be <30 days)
   - Vendor DPA execution status
   - Policy update frequency
   - Training completion rates

### 14.2. Regular Reviews

**Recommended Review Schedule:**

| Review Type | Frequency | Responsibility |
|-------------|-----------|----------------|
| Privacy policy updates | Annually + as needed | Legal/Product |
| Vendor DPA renewals | Annually | Legal |
| Security audit | Annually | Security Team |
| Penetration testing | Annually | External Vendor |
| User rights requests review | Quarterly | Data Protection Officer |
| Third-party risk assessment | Annually | Security/Legal |
| Compliance check | Quarterly | Data Protection Officer |
| User education content | Semi-annually | Product/Support |

### 14.3. Accountability Mechanisms

**Roles and Responsibilities:**

1. **Data Protection Officer (DPO):**
   - Oversee GDPR compliance
   - Handle user rights requests
   - Monitor vendor compliance
   - Report to management on privacy risks

2. **Privacy Champion (Each Team):**
   - Review features for privacy impact
   - Advocate for privacy-by-design
   - Escalate privacy concerns

3. **Security Team:**
   - Monitor for security incidents
   - Conduct security assessments
   - Manage incident response

4. **Legal:**
   - Maintain legal documentation
   - Review vendor agreements
   - Monitor regulatory changes

**Escalation Path:**
User Concern → Support → Privacy Champion → DPO → Legal/Management

---

## 15. Recommendations

### 15.1. Critical (Must Implement Before Launch)

**🔴 PRIORITY 1 - Legal and Compliance:**

1. **Create Privacy Policy** - Comprehensive, GDPR-compliant
2. **Create Terms of Service** - User agreements and responsibilities
3. **Create Children's Privacy Policy** - Special protections for minors
4. **Execute Data Processing Agreements (DPAs)** - With all vendors (Supabase, OneSignal, SendGrid)
5. **Conduct Data Protection Impact Assessment (DPIA)** - Required for child data processing
6. **Implement Consent Mechanisms** - Explicit consent for account creation, baby profiles, notifications
7. **Implement User Rights** - Data export, deletion request procedures
8. **Establish Incident Response Plan** - Breach detection and 72-hour notification

**🔴 PRIORITY 1 - Technical:**

9. **Implement Age Verification** - Ensure users are 18+
10. **Add Parental Consent for Baby Profiles** - Clear acknowledgment of child data processing
11. **Add Sharing Warnings** - Warn users before sharing outside app
12. **Implement Metadata Stripping** - Remove EXIF data from shared photos
13. **Create Access Logging** - Track who accesses which profiles/photos

**Estimated Effort:** 6-8 weeks  
**Cost:** $15,000-25,000 (legal fees + development)  
**Risk if Not Implemented:** Legal liability, regulatory fines, loss of user trust

### 15.2. High Priority (Implement Within 3-6 Months)

**🟡 PRIORITY 2:**

1. **Two-Factor Authentication (2FA)** - Enhanced account security
2. **Privacy Dashboard** - Transparency into data collection and usage
3. **Enhanced Photo Privacy** - Owners-only visibility option, download restrictions
4. **Session Management** - View and revoke active sessions
5. **User Education** - In-app tips for safe sharing, digital footprint awareness
6. **Security Notifications** - New device login, password changes
7. **Vendor Risk Management** - Ongoing third-party assessments
8. **Penetration Testing** - Annual external security audit

**Estimated Effort:** 4-6 weeks  
**Cost:** $10,000-15,000

### 15.3. Medium Priority (Implement Within 6-12 Months)

**🟢 PRIORITY 3:**

1. **Enhanced Privacy Mode** - Pseudonyms, approximate dates, extra protections
2. **Safety Features** - Quick revoke-all, hidden mode for abuse cases
3. **Age-Out Mechanism** - Transfer profile control when child turns 18
4. **Temporary Access** - Time-limited visitor passes
5. **Data Archival** - User-initiated archiving of old content
6. **Photo Watermarking** - Optional "Private" watermarks
7. **Bulk Actions** - Delete/export multiple items at once

**Estimated Effort:** 3-4 weeks  
**Cost:** $7,000-10,000

### 15.4. Nice to Have (Future Consideration)

**🔵 PRIORITY 4:**

1. **End-to-End Encrypted Messaging** - If chat feature is added
2. **Biometric App Lock** - Face ID/Touch ID for app access
3. **Advanced Analytics** - Privacy-preserving, opt-in only
4. **Multi-Language Privacy Policies** - For international expansion
5. **Privacy Certifications** - ISO 27001, SOC 2 Type II
6. **Bug Bounty Program** - Incentivize security research

---

## 16. Conclusion

### 16.1. Overall Ethics Assessment

The Nonna App demonstrates a **strong commitment to privacy and ethical data handling** through its architectural design choices:

✅ **Strengths:**
- Privacy-by-design architecture (RLS, encryption, invitation-only)
- No advertising, tracking, or data monetization
- Strong encryption standards (AES-256, TLS 1.3)
- Granular access controls
- User-centric feature design

⚠️ **Areas for Improvement:**
- Legal documentation (privacy policy, terms of service)
- User consent mechanisms
- Transparency features (privacy dashboard)
- Data subject rights implementation (export, deletion)
- Third-party risk management
- Incident response procedures

### 16.2. Ethical Verdict

**APPROVE with Required Implementations**

The application's core design is ethically sound and privacy-respecting. However, given the sensitive nature of child data and family information, the **critical recommendations (Section 15.1) must be implemented before production launch** to ensure:

1. Legal compliance (GDPR, COPPA considerations)
2. User trust and transparency
3. Protection of children's privacy rights
4. Accountability and incident response capability

**Timeline:** 6-8 weeks to implement critical recommendations.

### 16.3. Ongoing Commitment

**Ethical data handling is not a one-time implementation—it requires continuous vigilance:**

- **Regular reviews** of privacy practices (quarterly)
- **Monitoring** of regulatory changes and user feedback
- **Adaptation** to evolving privacy standards
- **Education** of team members and users
- **Accountability** through metrics and oversight

**This ethics review should be revisited:**
- Annually
- When adding major new features
- When privacy laws change
- When user base expands significantly
- After any security incident

### 16.4. Final Recommendation

**The Nonna App has the potential to be a privacy-respecting, trust-building platform for families.** 

With implementation of the critical recommendations, this application will:
- ✅ Meet ethical standards for child data protection
- ✅ Comply with privacy regulations (GDPR, COPPA considerations)
- ✅ Build user trust through transparency and control
- ✅ Set a positive example for privacy-first family applications

**Status:** **READY TO PROCEED** with implementation of critical recommendations.

---

**Document Control:**
- **Version:** 1.0
- **Last Updated:** December 2025
- **Next Review:** December 2026 or upon major changes
- **Owner:** Nonna App Ethics and Privacy Team
- **Approved By:** [Pending]

**Change Log:**
- 2025-12-18: Initial ethics review completed

---

**For Questions or Concerns:**
Contact: [Data Protection Officer contact - to be assigned]
Email: privacy@nonnaapp.example.com (to be established)
