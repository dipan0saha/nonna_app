# Nonna App - Data Retention Policy

**Effective Date:** [To be determined upon launch]  
**Last Updated:** December 2025  
**Version:** 1.0 (DRAFT)

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Retention Principles](#2-retention-principles)
3. [Data Categories and Retention Periods](#3-data-categories-and-retention-periods)
4. [Deletion Procedures](#4-deletion-procedures)
5. [Exceptions and Legal Holds](#5-exceptions-and-legal-holds)
6. [Backup and Archive Management](#6-backup-and-archive-management)
7. [User Control and Rights](#7-user-control-and-rights)
8. [Compliance and Auditing](#8-compliance-and-auditing)
9. [Contact Information](#9-contact-information)

---

## 1. Introduction

### 1.1 Purpose

This Data Retention Policy explains how long Nonna App retains different types of user data and the processes for data deletion. This policy supports our commitment to:
- **Privacy by Design:** Minimizing data retention
- **Legal Compliance:** Meeting regulatory requirements (GDPR, CCPA, etc.)
- **User Control:** Empowering users to manage their data
- **Data Minimization:** Keeping only what is necessary

### 1.2 Scope

This policy applies to all data collected and processed by Nonna App, including:
- User account information
- Baby/child profile data
- Photos and content
- System logs and metadata
- Backups and archives

### 1.3 Policy Owner

**Data Protection Officer:** [DPO Name]  
**Contact:** [privacy@nonnaapp.example.com]  
**Review Schedule:** Annually or upon regulatory changes

---

## 2. Retention Principles

### 2.1 Core Principles

Our data retention practices are guided by the following principles:

#### 2.1.1 Necessity
We retain data only for as long as necessary to:
- Provide the Service
- Comply with legal obligations
- Resolve disputes
- Enforce our agreements

#### 2.1.2 Minimization
We minimize retention periods while balancing:
- User expectations (families want long-term access to memories)
- Legal requirements (compliance with data protection laws)
- Operational needs (service continuity and support)

#### 2.1.3 User Control
Users can:
- Delete individual content at any time
- Request account deletion with full data removal
- Export their data before deletion

#### 2.1.4 Transparency
We are transparent about:
- What data we retain
- How long we retain it
- How to delete data
- Exceptions to retention rules

---

## 3. Data Categories and Retention Periods

### 3.1 Active Account Data

**Retention:** While account is active + grace period after inactivity

| Data Type | Retention Period | Rationale |
|-----------|------------------|-----------|
| **Account Information** | Active account + 90 days after deletion request | Necessary to provide service |
| **Email address** | Active account + 90 days | Authentication and communication |
| **Password hash** | Active account + 90 days | Authentication |
| **Profile information** | Active account + 90 days | Personalization |
| **Baby profile data** | Active profile + 90 days after deletion | Core service functionality |
| **Photos and videos** | Active profile + 30 days after deletion | User content preservation |
| **Comments and posts** | Active profile + 30 days after deletion | Social features |
| **Calendar events** | Event date + 7 years OR account deletion | Long-term family memories |
| **Registry items** | Active profile + 1 year after event date | Event-related functionality |

**Grace Periods Explained:**
- **90 days:** Account data grace period allows for accidental deletion recovery
- **30 days:** Content deletion grace period for user reconsideration
- **7 years:** Calendar events retained for long-term family history (configurable by user)

### 3.2 Deleted Account Data

**Retention:** Immediate permanent deletion with exception handling

| Data Type | After Account Deletion | Permanent Deletion |
|-----------|------------------------|-------------------|
| **Account credentials** | Immediately anonymized | 90 days (after backup rotation) |
| **Profile information** | Immediately deleted | 90 days (after backup rotation) |
| **Baby profiles** | Immediately deleted | 90 days (after backup rotation) |
| **Photos/videos (user-owned)** | Immediately deleted | 90 days (after backup rotation) |
| **Comments on others' content** | Anonymized (kept for context) | User ID removed, content may remain |
| **Shared content permissions** | Immediately revoked | Instant |
| **System logs** | Anonymized | 90 days |

**Important Notes:**
- **Immediate deletion:** Marked as deleted in production database immediately
- **Backup rotation:** Permanently removed from backups within 90 days
- **Shared content:** If you commented on someone else's profile, comments are anonymized but may remain for context

### 3.3 System and Operational Data

**Retention:** Minimum necessary for security and operations

| Data Type | Retention Period | Rationale |
|-----------|------------------|-----------|
| **Access logs** | 90 days | Security monitoring, fraud prevention |
| **Error logs** | 30 days | Bug fixing and troubleshooting |
| **Security logs** | 1 year | Security auditing, incident investigation |
| **Authentication logs** | 90 days | Security and fraud prevention |
| **Session tokens** | Until session expires (24 hours) | Active session management |
| **IP addresses** | 90 days | Security and fraud prevention |
| **Device information** | While account active | Service optimization |
| **Performance metrics** | 30 days | Service improvement |

### 3.4 Transactional and Communication Data

**Retention:** Per communication type and legal requirements

| Data Type | Retention Period | Rationale |
|-----------|------------------|-----------|
| **Email communications** | 3 years | Customer support history |
| **Support tickets** | 3 years | Quality assurance, legal defense |
| **Notification history** | 30 days | User preference management |
| **Invitation emails** | 90 days | Invitation tracking |
| **Password reset requests** | 24 hours (or until used) | Security |

### 3.5 Legal and Compliance Data

**Retention:** As required by law

| Data Type | Retention Period | Rationale |
|-----------|------------------|-----------|
| **Privacy consent records** | 7 years after account deletion | GDPR compliance (proof of consent) |
| **Terms acceptance logs** | 7 years after account deletion | Legal defense |
| **Data breach notifications** | 10 years | Regulatory compliance |
| **Data access requests** | 7 years | GDPR compliance |
| **Data deletion requests** | 7 years | Proof of compliance |
| **DPO communications** | 7 years | Regulatory compliance |
| **Audit logs** | 7 years | Compliance and legal defense |

**Rationale for 7-year retention:** Common statute of limitations for legal claims in many jurisdictions.

### 3.6 Inactive Account Handling

**Definition of Inactive:** No login for 3 consecutive years

**Process:**
1. **Year 2.5 (30 months):** Email warning about upcoming account inactivity
2. **Year 3 (36 months):** Final warning email (account will be deleted in 90 days)
3. **Year 3 + 90 days:** Account automatically deleted following standard deletion procedures

**Exception:** Accounts with recent family activity (e.g., others viewing/sharing) remain active

**User Action:** Login to reset inactivity timer

---

## 4. Deletion Procedures

### 4.1 User-Initiated Deletion

#### 4.1.1 Delete Individual Content

**What:** Photos, comments, events, registry items  
**How:** In-app delete buttons  
**Timeline:**
- **Production database:** Marked deleted immediately
- **Soft delete period:** 30 days (recoverable)
- **Hard delete:** After 30 days, permanently deleted
- **Backups:** Removed within 90 days

**User Experience:**
- Content disappears immediately from app
- Recovery possible within 30 days by contacting support
- After 30 days, deletion is permanent

#### 4.1.2 Delete Baby Profile

**What:** Entire baby profile including all associated photos, events, comments, registry  
**How:** In-app profile settings → "Delete Profile"  
**Warning:** Users must confirm understanding that all data will be permanently deleted  
**Timeline:**
- **Production database:** Marked deleted immediately
- **Soft delete period:** 30 days (recoverable)
- **Hard delete:** After 30 days, permanently deleted
- **Backups:** Removed within 90 days

#### 4.1.3 Delete Account

**What:** User account and ALL associated data (all baby profiles, all content)  
**How:** In-app account settings → "Delete My Account" OR email request  
**Warning:** Multi-step confirmation required  
**Timeline:**
- **Account access:** Immediately revoked
- **Production database:** All user data marked deleted immediately
- **Soft delete period:** 90 days (account recoverable only with identity verification)
- **Hard delete:** After 90 days, permanently deleted
- **Backups:** Removed within 90 days
- **Legal records:** Consent logs and deletion request retained for 7 years (anonymized)

**What Gets Deleted:**
- ✅ Account credentials (email, password)
- ✅ Profile information
- ✅ All baby profiles owned by user
- ✅ All photos and videos uploaded by user
- ✅ All calendar events created by user
- ✅ All registry items created by user
- ✅ Access permissions and follower relationships
- ✅ Notification preferences

**What Remains (Anonymized):**
- ⚠️ Comments on other users' content (anonymized, no link to your identity)
- ⚠️ Deletion request log (for compliance, anonymized)
- ⚠️ Consent records (anonymized, for legal compliance)

### 4.2 Automated Deletion

#### 4.2.1 Session Tokens
- **Expiration:** 24 hours of inactivity
- **Deletion:** Automatically purged upon expiration

#### 4.2.2 Expired Invitations
- **Expiration:** 30 days from invitation
- **Deletion:** Automatically deleted

#### 4.2.3 Inactive Accounts
- See Section 3.6 for inactive account deletion process

### 4.3 Administrative Deletion

**Reasons for Admin Deletion:**
- Terms of Service violations
- Illegal content
- Court orders
- Safety concerns

**Process:**
- Content immediately removed from public view
- Standard deletion timelines apply unless legal hold required
- User notified unless prohibited by law

---

## 5. Exceptions and Legal Holds

### 5.1 Legal Obligations

We may retain data longer than specified if required to:
- **Comply with legal obligations** (e.g., tax records, subpoenas)
- **Resolve disputes** (e.g., pending litigation)
- **Enforce agreements** (e.g., Terms of Service violations)
- **Protect rights and safety** (e.g., fraud investigations)

### 5.2 Legal Hold Process

When a legal hold is placed on data:
1. **Notification:** Legal team notifies Data Protection Officer
2. **Hold Implementation:** Data marked with legal hold flag
3. **Deletion Prevention:** Automated deletion processes skip flagged data
4. **Documentation:** Legal hold documented with reason and scope
5. **Review:** Legal holds reviewed quarterly
6. **Release:** When hold is lifted, standard deletion timelines resume

**User Notification:** Users are notified of legal holds when legally permissible.

### 5.3 Security Incidents

Data related to security incidents may be retained beyond standard periods:
- **Incident investigation data:** Until investigation complete + 1 year
- **Evidence preservation:** As required by law enforcement or regulators
- **Breach notification records:** 10 years (regulatory requirement)

---

## 6. Backup and Archive Management

### 6.1 Backup Policy

**Purpose:** Disaster recovery and business continuity

**Backup Schedule:**
- **Database:** Daily incremental, weekly full backup
- **File storage (photos):** Continuous replication
- **System configurations:** Daily backups

**Backup Retention:**
- **Daily backups:** 30 days
- **Weekly backups:** 90 days
- **Monthly backups:** 1 year (for disaster recovery only)

### 6.2 Deleted Data in Backups

**Challenge:** Deleted data remains in backups until backup expires

**Our Approach:**
- **Production deletion:** Immediate (soft delete with grace period)
- **Backup rotation:** Deleted data naturally purges as backups expire (max 90 days for most data)
- **Monthly backups:** Used ONLY for catastrophic disaster recovery, not for data restoration

**User Notification:** Users are informed that deleted data may persist in backups for up to 90 days.

### 6.3 Archive Policy

**Definition:** Archives are long-term, immutable copies for compliance

**What We Archive:**
- Consent records (7 years)
- Terms acceptance logs (7 years)
- Data access/deletion request logs (7 years)
- Security incident reports (10 years)

**Archive Access:** Restricted to Data Protection Officer and Legal Counsel

**Archive Deletion:** Automatically deleted after retention period expires

---

## 7. User Control and Rights

### 7.1 Right to Deletion (Right to be Forgotten)

**GDPR/CCPA Compliance:** Users have the right to request deletion of their personal data.

**How to Exercise:**
1. **In-App:** Use "Delete Account" or "Delete Profile" features
2. **Email Request:** Send request to [privacy@nonnaapp.example.com]
3. **Verification:** We may verify identity to prevent unauthorized deletion

**Timeline:**
- **Acknowledgment:** Within 48 hours
- **Completion:** Within 30 days
- **Confirmation:** Email confirmation sent when complete

**Exceptions:** We may decline deletion requests if data is required for:
- Legal compliance
- Pending litigation
- Fraud investigation
- Protecting rights and safety

### 7.2 Right to Data Portability

Before deleting your account, you can request:
- **Data export:** All your data in JSON format
- **Photo archive:** ZIP file with all your photos
- **Timeline:** Delivered within 30 days

**How to Exercise:** App settings → "Export My Data" or email request

### 7.3 Transparency

You can request information about:
- What data we have about you
- How long we've retained it
- When it will be deleted

**How to Exercise:** Email [privacy@nonnaapp.example.com]

---

## 8. Compliance and Auditing

### 8.1 Compliance Framework

This Data Retention Policy complies with:
- **GDPR** (EU General Data Protection Regulation)
- **CCPA/CPRA** (California Consumer Privacy Act)
- **COPPA** (Children's Online Privacy Protection Act)
- **PIPEDA** (Canada Personal Information Protection)
- **LGPD** (Brazil General Data Protection Law)
- **Other applicable privacy laws**

### 8.2 Regular Audits

**Annual Audit:**
- Review retention periods for appropriateness
- Verify deletion processes are working correctly
- Check compliance with updated regulations
- Audit backup and archive management

**Quarterly Review:**
- Legal holds status
- Deletion request processing times
- User complaints related to data retention

### 8.3 Accountability

**Responsible Parties:**
- **Data Protection Officer:** Policy oversight and compliance
- **Engineering Team:** Technical implementation of retention and deletion
- **Legal Team:** Legal hold management
- **Security Team:** Log retention and security incident data

### 8.4 Documentation

We maintain records of:
- Data deletion requests and fulfillment
- Legal holds applied and released
- Backup and archive inventories
- Audit findings and remediation

---

## 9. Contact Information

### 9.1 Questions or Requests

For questions about data retention or to exercise your rights:

**Email:** [privacy@nonnaapp.example.com]  
**Data Protection Officer:** [DPO Name and Contact]  
**Address:** [Company Address]

### 9.2 Complaints

If you have concerns about our data retention practices:

**EU/EEA Users:**  
Contact your local Data Protection Authority  
Directory: [https://edpb.europa.eu/about-edpb/board/members_en](https://edpb.europa.eu/about-edpb/board/members_en)

**California Users:**  
California Attorney General's Office  
[https://oag.ca.gov/contact/consumer-complaint-against-business-or-company](https://oag.ca.gov/contact/consumer-complaint-against-business-or-company)

---

## Summary Table: Quick Reference

| Data Category | Active Period | After Deletion | Backups |
|---------------|---------------|----------------|---------|
| **Account Info** | Active + 90 days | 90 days grace | 90 days |
| **Photos** | Active + 30 days | 30 days grace | 90 days |
| **Baby Profiles** | Active + 90 days | 90 days grace | 90 days |
| **Calendar Events** | 7 years OR deletion | 30 days grace | 90 days |
| **Access Logs** | 90 days | N/A | 30 days |
| **Security Logs** | 1 year | N/A | 90 days |
| **Consent Records** | 7 years after deletion | Archived | N/A |
| **Support Tickets** | 3 years | N/A | 90 days |

---

## Appendix A: Deletion Request Process Flow

```
User Requests Deletion
         ↓
Identity Verification (if needed)
         ↓
Deletion Request Logged
         ↓
[Parallel Processing]
    ↓                    ↓
Production DB         User Notified
Mark Deleted          (Acknowledgment)
    ↓
Soft Delete Grace Period
(30-90 days depending on data type)
    ↓
Hard Delete from Production
         ↓
Backup Rotation
(Up to 90 days)
         ↓
Permanent Deletion Complete
         ↓
User Notified (Confirmation)
         ↓
Deletion Request Log Archived
(7 years for compliance)
```

---

## Appendix B: Retention Period Justifications

### Why 7 Years for Legal Records?
- **Statute of Limitations:** Most legal claims must be filed within 6-7 years
- **GDPR Requirement:** Demonstrate compliance with data subject requests
- **Industry Standard:** Common retention period for legal and financial records

### Why 90 Days for Backups?
- **Disaster Recovery:** Balance between recovery capability and privacy
- **Technical Constraints:** Backup rotation cycles (daily → weekly → monthly)
- **User Expectations:** Reasonable period for accidental deletion recovery

### Why 30 Days Soft Delete for Content?
- **User Experience:** Allows users to recover accidentally deleted content
- **Family Dynamics:** Prevents impulsive deletion decisions
- **Balance:** Shorter than account deletion (90 days) for less critical data

### Why 3 Years for Inactivity?
- **User Intent:** Long period indicates account abandonment
- **Family Use Case:** Families may not need app daily but want long-term access
- **Warning Period:** Ample time (6 months of warnings) for users to reactivate

---

**Document Status:** DRAFT - For Legal Review  
**Next Steps:** Legal counsel review, technical implementation planning  
**Part of:** Story 9.3 - Draft Terms of Service and Policies  
**Epic:** 9 - Stakeholder and Legal Compliance  

**Version History:**
- v1.0 (Dec 2025): Initial draft

**Review Schedule:**
- Annual review
- Upon regulatory changes
- After significant feature updates

---

**Last Reviewed:** December 2025  
**Next Review:** December 2026  
**Policy Owner:** Data Protection Officer
