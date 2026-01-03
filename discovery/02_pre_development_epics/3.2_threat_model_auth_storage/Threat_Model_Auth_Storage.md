# Threat Model for Authentication and Storage

## 1. Introduction

This document provides a comprehensive threat model for the authentication and storage systems of the Nonna App. The threat model identifies potential security threats, analyzes attack vectors, and defines mitigation strategies to ensure the security and privacy of user data.

This analysis is based on the requirements outlined in `docs/discovery/01_requirements/Requirements.md` and the technology stack defined in `docs/discovery/02_technology_stack/Technology_Stack.md`.

### 1.1. Scope

This threat model covers:
- **Authentication System:** Supabase Auth, JWT tokens, session management, email/password authentication, OAuth 2.0
- **Storage System:** Supabase Storage, photo/media storage, file upload/download mechanisms
- **Access Control:** Row-Level Security (RLS), Role-Based Access Control (RBAC), invitation system
- **Data Protection:** Encryption at rest and in transit, secure token storage

### 1.2. Methodology

This threat model uses the **STRIDE** methodology to systematically identify threats:
- **S**poofing
- **T**ampering
- **R**epudiation
- **I**nformation Disclosure
- **D**enial of Service
- **E**levation of Privilege

## 2. System Architecture Overview

### 2.1. Authentication Architecture

```
[Mobile App (Flutter)]
         ↓ HTTPS/TLS 1.3
[Supabase Auth Service]
         ↓
[PostgreSQL with RLS]
         ↓
[User Profiles & Memberships]
```

**Key Components:**
- **Supabase Auth:** Handles user authentication, session management, and JWT token generation
- **JWT Tokens:** Secure, stateless authentication tokens stored on-device
- **Secure Storage:** iOS Keychain / Android Keystore for session token storage
- **Row-Level Security (RLS):** Database-level access control enforcement
- **Email Verification:** Required before first login
- **Password Reset:** Secure email-based password recovery

### 2.2. Storage Architecture

```
[Mobile App (Flutter)]
         ↓ HTTPS/TLS 1.3
[Supabase Storage Service]
         ↓
[S3-compatible Object Storage]
         ↓ CDN
[Encrypted Storage (AES-256)]
```

**Key Components:**
- **Supabase Storage:** Managed file storage with built-in security
- **Bucket Strategy:** Separate buckets for baby_profile_photos, event_photos, gallery_photos
- **File Validation:** Client and server-side validation for file type (JPEG/PNG) and size (max 10MB)
- **Signed URLs:** RLS-backed signed URLs for secure access
- **CDN Delivery:** Content Delivery Network for fast, cached image delivery
- **Thumbnail Generation:** Edge Functions for optimized image delivery

### 2.3. Access Control Architecture

```
[User Authentication]
         ↓
[Baby Profile Membership Check]
         ↓
[Role Determination (OWNER/FOLLOWER)]
         ↓
[RLS Policy Enforcement]
         ↓
[Resource Access Granted/Denied]
```

**Key Components:**
- **Profiles Table:** Centralized user information (1:1 with auth.users)
- **Baby Profile Memberships:** Maps users to baby profiles with roles (OWNER/FOLLOWER)
- **Invitation System:** Secure, token-based invitations with 7-day expiry
- **RLS Policies:** Enforce access control at the database layer

## 3. Data Flow Diagrams

### 3.1. User Authentication Flow

```
1. User enters credentials → Mobile App
2. App sends credentials → Supabase Auth (TLS 1.3)
3. Supabase Auth validates → PostgreSQL
4. Auth service generates JWT token
5. JWT token returned → Mobile App
6. Token stored → Secure Storage (Keychain/Keystore)
7. Subsequent requests include JWT in headers
```

### 3.2. Photo Upload Flow

```
1. User selects photo → Mobile App
2. Client-side validation (type, size) → Flutter
3. Optional compression/resize → Flutter
4. Upload request with JWT → Supabase Storage (TLS 1.3)
5. Server-side validation → Supabase
6. RLS policy check → PostgreSQL
7. File stored → Encrypted Storage (AES-256)
8. Thumbnail generation → Edge Function
9. Database record created → Photos table
10. Success response → Mobile App
```

### 3.3. Invitation Flow

```
1. Owner creates invitation → Mobile App
2. Request with JWT → Edge Function (TLS 1.3)
3. Generate unique token (UUID) → Database
4. Set expiration (7 days) → Invitations table
5. Send email with deep link → SendGrid
6. Recipient clicks link → Mobile App
7. Token validation → Edge Function
8. Check expiry/revocation status → Database
9. User accepts & selects relationship
10. Membership created → Baby Profile Memberships table
```

## 4. Threat Analysis (STRIDE)

### 4.1. Authentication Threats

#### 4.1.1. Spoofing Identity

**Threat ID:** AUTH-S-001  
**Description:** Attacker impersonates a legitimate user by stealing or guessing credentials.

**Attack Vectors:**
- Credential stuffing using leaked passwords from other breaches
- Phishing attacks to capture user credentials
- Brute force attacks on login endpoint
- Session token theft from compromised device

**Impact:** Critical - Full account takeover, access to all baby profiles and private data

**Likelihood:** Medium

**Existing Mitigations:**
- Email/password authentication with password complexity requirements (min 6 chars + number/special char) - *as defined in Requirements.md section 3.1*
- Email verification required before first login
- JWT tokens with expiration
- Secure storage using iOS Keychain / Android Keystore
- TLS 1.3 for all communications

**Additional Mitigations Required:**
- **Rate limiting** on login attempts (max 5 attempts per 15 minutes per IP/email)
- **Account lockout** after 10 failed login attempts within 1 hour
- **Multi-factor authentication (MFA)** option for enhanced security (future enhancement)
- **Suspicious login detection** (new device, location, unusual time)
- **Session timeout** after 30 days of inactivity
- **Credential breach monitoring** to detect if user passwords appear in known breaches

**Priority:** HIGH

---

#### 4.1.2. JWT Token Compromise

**Threat ID:** AUTH-S-002  
**Description:** Attacker obtains valid JWT token through various means and uses it to access the application.

**Attack Vectors:**
- Token theft from insecure storage
- Man-in-the-middle (MITM) attack intercepting tokens
- XSS attacks (less relevant for native mobile apps)
- Physical device access
- Token leaked in logs or error messages

**Impact:** Critical - Unauthorized access to user account

**Likelihood:** Low

**Existing Mitigations:**
- Secure storage (Keychain/Keystore) for tokens
- TLS 1.3 encryption for all API communications
- JWT tokens with reasonable expiration time

**Additional Mitigations Required:**
- **Token rotation** - refresh tokens before expiration
- **Short-lived access tokens** (1 hour recommended for mobile apps) with longer-lived refresh tokens (30 days)
- **Token revocation list** for compromised tokens
- **Certificate pinning** to prevent MITM attacks
- **No logging of tokens** in application logs or error reports
- **Device binding** - tokens tied to specific device identifiers
- **Biometric re-authentication** for sensitive operations (delete account, change email)

**Priority:** HIGH

---

#### 4.1.3. Email Verification Bypass

**Threat ID:** AUTH-S-003  
**Description:** Attacker creates account without verifying email address.

**Attack Vectors:**
- Exploiting race conditions in verification flow
- Manipulating verification tokens
- Using temporary/disposable email services

**Impact:** Medium - Spam accounts, invitation abuse

**Likelihood:** Low

**Existing Mitigations:**
- Email verification required before first login (enforced by Supabase Auth)
- Unique, non-guessable verification tokens

**Additional Mitigations Required:**
- **Block disposable email domains** (common temporary email services)
- **Verification token expiration** (24 hours)
- **One-time use tokens** - invalidate after successful verification
- **Monitor verification patterns** for abuse detection

**Priority:** MEDIUM

---

#### 4.1.4. Password Reset Abuse

**Threat ID:** AUTH-T-001  
**Description:** Attacker exploits password reset functionality to gain unauthorized access or cause denial of service.

**Attack Vectors:**
- Flooding user with password reset emails
- Intercepting reset emails
- Exploiting weak reset token generation
- Account enumeration via reset endpoint

**Impact:** Medium - Account takeover, user annoyance, service disruption

**Likelihood:** Medium

**Existing Mitigations:**
- Secure password reset via email
- Reset links with expiration

**Additional Mitigations Required:**
- **Rate limiting** on password reset requests (max 3 per hour per email)
- **No user enumeration** - same response whether email exists or not
- **Short-lived reset tokens** (1 hour expiration)
- **One-time use tokens** - invalidate immediately after use
- **Notification to user** when password reset is requested
- **Require old password** for password changes when logged in
- **Strong reset token generation** (cryptographically secure random tokens)

**Priority:** MEDIUM

---

#### 4.1.5. Session Hijacking

**Threat ID:** AUTH-T-002  
**Description:** Attacker steals or predicts active session tokens to impersonate authenticated user.

**Attack Vectors:**
- Network sniffing (if TLS fails)
- Session fixation attacks
- Malware on user device
- Stolen device without device lock

**Impact:** Critical - Full account access

**Likelihood:** Low

**Existing Mitigations:**
- TLS 1.3 encryption
- Secure token storage
- JWT stateless tokens

**Additional Mitigations Required:**
- **Session invalidation** on logout
- **Concurrent session limits** (max 3 active sessions)
- **Session monitoring** - alert on multiple concurrent sessions from different locations
- **Remote session termination** - ability to log out all sessions
- **Secure session generation** - use cryptographically secure random generators
- **Session binding** to device characteristics

**Priority:** HIGH

---

#### 4.1.6. Repudiation of Actions

**Threat ID:** AUTH-R-001  
**Description:** User denies performing actions (deleting content, inviting users, etc.).

**Attack Vectors:**
- Lack of audit trails
- Shared accounts
- Compromised accounts

**Impact:** Low - Disputes over actions performed

**Likelihood:** Low

**Existing Mitigations:**
- Database timestamps for all operations
- User ID associated with all actions

**Additional Mitigations Required:**
- **Comprehensive audit logging** for all critical actions:
  - Profile creation/deletion
  - Invitation sends/revocations
  - Content uploads/deletions
  - Permission changes
- **Immutable audit logs** stored separately from main database
- **Log retention** for 7 years (aligned with data retention policy)
- **IP address and device info** logged with critical actions
- **Signed audit logs** to prevent tampering

**Priority:** LOW

---

#### 4.1.7. Information Disclosure via Auth Endpoints

**Threat ID:** AUTH-I-001  
**Description:** Sensitive information leaked through authentication endpoints or error messages.

**Attack Vectors:**
- User enumeration via login/registration
- Detailed error messages revealing system information
- Timing attacks to determine valid usernames
- Metadata leakage in API responses

**Impact:** Medium - Privacy violation, reconnaissance for attacks

**Likelihood:** Medium

**Existing Mitigations:**
- Generic error messages from Supabase Auth

**Additional Mitigations Required:**
- **Consistent response times** - prevent timing attacks (constant-time comparisons)
- **Generic error messages** - "Invalid credentials" instead of "User not found" or "Wrong password"
- **No user enumeration** - same response for existing and non-existing users
- **Sanitize all error messages** - no stack traces or system details in production
- **Rate limiting** to prevent enumeration attacks
- **Monitor for enumeration attempts** and block suspicious IPs

**Priority:** MEDIUM

---

#### 4.1.8. Denial of Service on Auth System

**Threat ID:** AUTH-D-001  
**Description:** Attacker overwhelms authentication system, preventing legitimate users from logging in.

**Attack Vectors:**
- Flooding login endpoint with requests
- Mass password reset requests
- Account creation spam
- Email verification spam

**Impact:** High - Service unavailable for legitimate users

**Likelihood:** Medium

**Existing Mitigations:**
- Supabase infrastructure with built-in rate limiting

**Additional Mitigations Required:**
- **Aggressive rate limiting** on all auth endpoints (combine IP-based with user/device-based for robustness):
  - Login: 5 attempts per 15 min per IP/email combination
  - Registration: 3 attempts per hour per IP
  - Password reset: 3 attempts per hour per email
  - Email verification: 5 attempts per hour per user
- **CAPTCHA** for repeated failed attempts
- **Combined throttling** - IP-based, user-based, and device-based to handle shared NAT gateways and distributed attacks
- **Geographic rate limiting** if applicable
- **Monitoring and alerting** for abnormal traffic patterns
- **DDoS protection** at infrastructure level
- **Graceful degradation** - maintain core functionality during attacks

**Priority:** HIGH

---

#### 4.1.9. Privilege Escalation

**Threat ID:** AUTH-E-001  
**Description:** Follower gains Owner privileges or accesses profiles they're not invited to.

**Attack Vectors:**
- Exploiting bugs in RLS policies
- Manipulating JWT claims
- Race conditions in role assignment
- Direct database access (if service keys leaked)

**Impact:** Critical - Unauthorized access, data manipulation

**Likelihood:** Low

**Existing Mitigations:**
- Row-Level Security (RLS) on all tables
- Role stored in baby_profile_memberships table
- JWT tokens validated on every request
- Supabase enforces RLS automatically

**Additional Mitigations Required:**
- **Comprehensive RLS testing** - automated tests for all policies
- **RLS policy review** by security team before deployment
- **Principle of least privilege** - minimal permissions by default
- **Service role key protection** - never exposed to client, only in Edge Functions
- **Regular security audits** of RLS policies
- **Immutable role assignments** - require explicit approval for role changes
- **Separation of duties** - different keys for read vs write operations
- **Monitoring for suspicious permission changes**

**Priority:** HIGH

---

### 4.2. Storage Threats

#### 4.2.1. Unauthorized File Access

**Threat ID:** STOR-S-001  
**Description:** Attacker accesses photos or files belonging to other users.

**Attack Vectors:**
- Guessing or enumerating file URLs
- Exploiting weak RLS policies on storage buckets
- Accessing files through leaked signed URLs
- Man-in-the-middle attacks intercepting file transfers

**Impact:** Critical - Privacy breach, unauthorized access to personal photos

**Likelihood:** Medium

**Existing Mitigations:**
- RLS-backed signed URLs for storage access
- TLS 1.3 for file transfers
- Supabase Storage security policies

**Additional Mitigations Required:**
- **Non-sequential, non-guessable file names** (UUIDs)
- **Short-lived signed URLs** (expires in 1 hour)
- **Access logging** for all file downloads
- **Referrer checking** - only allow access from app
- **RLS policies on storage buckets** tied to baby profile membership
- **Regular security audits** of storage policies
- **Bucket policies** to prevent public read access
- **Monitoring for suspicious download patterns**

**Priority:** HIGH

---

#### 4.2.2. Malicious File Upload

**Threat ID:** STOR-T-001  
**Description:** Attacker uploads malicious files disguised as images.

**Attack Vectors:**
- Uploading files with double extensions (image.jpg.exe)
- Embedding malicious code in image metadata
- Uploading executables with image MIME types
- Uploading oversized files to exhaust storage
- Uploading inappropriate content

**Impact:** High - Security risk, storage exhaustion, content violations

**Likelihood:** Medium

**Existing Mitigations:**
- Client-side validation for file type (JPEG/PNG) and size (max 10MB)
- Server-side validation in Supabase

**Additional Mitigations Required:**
- **Strict server-side validation**:
  - Magic number/file signature validation (not just extension)
  - MIME type verification
  - File size limits enforced at multiple layers
- **Content scanning** - scan for malware/inappropriate content
- **Image re-encoding** - strip metadata and re-encode to remove potential threats
- **File type whitelist** - only allow specific image formats
- **Storage quotas** per user and per baby profile
- **Upload rate limiting** (max 20 photos per hour per user)
- **Automated content moderation** for inappropriate images (future enhancement)
- **Report and flag system** for users to report inappropriate content

**Priority:** HIGH

---

#### 4.2.3. File Tampering

**Threat ID:** STOR-T-002  
**Description:** Attacker modifies stored files without authorization.

**Attack Vectors:**
- Direct storage manipulation if credentials compromised
- Exploiting update vulnerabilities
- Race conditions during file updates

**Impact:** High - Data integrity compromise, trust violation

**Likelihood:** Low

**Existing Mitigations:**
- RLS policies restrict update/delete to owners only
- Immutable file storage (new uploads, not modifications)

**Additional Mitigations Required:**
- **File integrity checking** - checksums/hashes stored in database
- **Versioning** - maintain file history for audit trail
- **Write-once storage** - prevent modifications, only deletions by authorized users
- **Audit logging** for all file operations
- **Service key protection** - strict control over storage service keys
- **Regular integrity audits** - verify stored files match expected checksums

**Priority:** MEDIUM

---

#### 4.2.4. Information Disclosure via Storage

**Threat ID:** STOR-I-001  
**Description:** Sensitive information leaked through storage metadata or error messages.

**Attack Vectors:**
- Metadata in uploaded images (GPS location, camera info)
- File names revealing sensitive information
- Error messages disclosing storage structure
- Directory listing enabled

**Impact:** Medium - Privacy violation, information leakage

**Likelihood:** Medium

**Existing Mitigations:**
- Separate buckets per content type
- Signed URLs with expiration

**Additional Mitigations Required:**
- **Metadata stripping** - remove EXIF data including GPS coordinates
- **Sanitized file names** - use UUIDs instead of original names
- **Disable directory listing** on all buckets
- **Generic error messages** for storage operations
- **No enumeration** - prevent listing of all files
- **Privacy warnings** when uploading photos (inform about metadata)
- **Automated EXIF removal** in upload pipeline

**Priority:** HIGH

---

#### 4.2.5. Denial of Service via Storage

**Threat ID:** STOR-D-001  
**Description:** Attacker exhausts storage quota or bandwidth.

**Attack Vectors:**
- Uploading maximum size files repeatedly
- Rapid-fire uploads to exhaust quota
- Bandwidth exhaustion through massive downloads
- Zip bomb or decompression attacks (if implemented)

**Impact:** High - Service degradation, cost increase

**Likelihood:** Medium

**Existing Mitigations:**
- File size limit (10MB per photo)
- Gallery limit (1,000 photos per baby profile)

**Additional Mitigations Required:**
- **Per-user storage quotas** (specific values to be determined based on business requirements and cost analysis)
- **Upload rate limiting** (max 20 uploads per hour)
- **Download rate limiting** (max 100 downloads per hour)
- **Bandwidth monitoring and alerting**
- **Cost alerts** for unexpected storage/bandwidth usage
- **Automatic cleanup** of orphaned files
- **Compression enforcement** - reject uncompressed large files
- **Thumbnail serving** - serve thumbnails by default, full-size on request

**Priority:** MEDIUM

---

#### 4.2.6. Storage Bucket Misconfiguration

**Threat ID:** STOR-E-001  
**Description:** Incorrect bucket permissions allowing unauthorized access or modifications.

**Attack Vectors:**
- Public read access accidentally enabled
- Overly permissive RLS policies
- Misconfigured CORS policies
- Service key exposure

**Impact:** Critical - Data breach, unauthorized access

**Likelihood:** Low

**Existing Mitigations:**
- RLS policies on storage buckets
- Supabase default security settings

**Additional Mitigations Required:**
- **Infrastructure as Code (IaC)** - version-controlled bucket configurations
- **Automated security checks** in CI/CD pipeline
- **Regular security audits** of bucket policies
- **Principle of least privilege** - minimum necessary permissions
- **Production environment isolation** - separate buckets for dev/staging/prod
- **Configuration review process** - peer review for policy changes
- **Monitoring and alerting** for configuration changes
- **Regular penetration testing** of storage access controls

**Priority:** HIGH

---

### 4.3. Cross-Component Threats

#### 4.3.1. Invitation System Abuse

**Threat ID:** CROSS-E-001  
**Description:** Attacker abuses invitation system to gain unauthorized access or spam users.

**Attack Vectors:**
- Token prediction or brute force
- Token reuse after acceptance
- Accepting expired invitations
- Mass invitation spam
- Invitation to non-existent emails for enumeration

**Impact:** Medium - Unauthorized access, spam, privacy violation

**Likelihood:** Medium

**Existing Mitigations:**
- Unique UUID tokens for invitations
- 7-day expiration
- Revocation capability for owners

**Additional Mitigations Required:**
- **Cryptographically secure token generation**
- **One-time use tokens** - invalidate after acceptance
- **Strict expiry enforcement** in database and application
- **Rate limiting on invitation sends** (max 10 per day per owner)
- **Rate limiting on invitation acceptance** (max 5 per hour per IP)
- **Email validation** before sending invitations
- **Invitation audit log** - track who sent, to whom, when
- **Revocation notifications** - notify recipient when invitation revoked
- **Monitoring for abuse patterns** (mass invites, repeated failures)

**Priority:** MEDIUM

---

#### 4.3.2. Data Breach via Third-Party Services

**Threat ID:** CROSS-I-002  
**Description:** Sensitive data leaked through third-party services (SendGrid, OneSignal).

**Attack Vectors:**
- API key compromise
- Third-party service breach
- Data logged by third-party services
- Insecure API integration

**Impact:** High - Privacy violation, unauthorized access to user data

**Likelihood:** Low

**Existing Mitigations:**
- API keys stored in environment variables
- TLS encryption for third-party communications

**Additional Mitigations Required:**
- **Minimal data sharing** - send only necessary information to third parties
- **Data anonymization** where possible
- **API key rotation** - regular rotation of third-party API keys
- **Secret management system** - use Supabase Vault or similar
- **Third-party security assessment** - evaluate security posture
- **Data Processing Agreements** with third-party vendors
- **Monitoring third-party access** - log all API calls
- **Fallback mechanisms** if third-party service is compromised
- **Regular review** of data sent to third parties

**Priority:** MEDIUM

---

#### 4.3.3. Insufficient Logging and Monitoring

**Threat ID:** CROSS-R-002  
**Description:** Security incidents go undetected due to inadequate logging and monitoring.

**Attack Vectors:**
- Attacks that go unnoticed
- Delayed incident response
- Inability to investigate breaches
- No alerting for anomalous behavior

**Impact:** High - Prolonged security incidents, inability to respond

**Likelihood:** Medium

**Existing Mitigations:**
- Sentry for error monitoring
- Basic Supabase logging

**Additional Mitigations Required:**
- **Comprehensive security logging**:
  - All authentication events (login, logout, failures)
  - Permission changes
  - File uploads/downloads
  - Invitation sends/acceptances
  - Account modifications
- **Real-time alerting** for security events:
  - Multiple failed login attempts
  - Unusual access patterns
  - Permission escalations
  - Mass data downloads
- **Log aggregation and analysis** - centralized log management
- **Security Information and Event Management (SIEM)** integration
- **Regular log review** by security team
- **Incident response playbooks** for common scenarios
- **Log retention** for 7 years (compliance requirement)
- **Tamper-proof logging** - separate storage for audit logs

**Priority:** HIGH

---

## 5. Mitigation Priority Matrix

| Threat ID | Threat Category | Impact | Likelihood | Priority | Status |
|-----------|----------------|--------|------------|----------|--------|
| AUTH-S-001 | Spoofing | Critical | Medium | HIGH | Partial |
| AUTH-S-002 | Spoofing | Critical | Low | HIGH | Partial |
| AUTH-E-001 | Elevation | Critical | Low | HIGH | Partial |
| STOR-S-001 | Spoofing | Critical | Medium | HIGH | Partial |
| STOR-T-001 | Tampering | High | Medium | HIGH | Partial |
| STOR-I-001 | Info Disclosure | Medium | Medium | HIGH | Partial |
| STOR-E-001 | Elevation | Critical | Low | HIGH | Partial |
| CROSS-R-002 | Repudiation | High | Medium | HIGH | Minimal |
| AUTH-T-002 | Tampering | Critical | Low | HIGH | Partial |
| AUTH-D-001 | Denial of Service | High | Medium | HIGH | Partial |
| AUTH-T-001 | Tampering | Medium | Medium | MEDIUM | Partial |
| AUTH-S-003 | Spoofing | Medium | Low | MEDIUM | Partial |
| AUTH-I-001 | Info Disclosure | Medium | Medium | MEDIUM | Partial |
| STOR-T-002 | Tampering | High | Low | MEDIUM | Partial |
| STOR-D-001 | Denial of Service | High | Medium | MEDIUM | Partial |
| CROSS-E-001 | Elevation | Medium | Medium | MEDIUM | Partial |
| CROSS-I-002 | Info Disclosure | High | Low | MEDIUM | Partial |
| AUTH-R-001 | Repudiation | Low | Low | LOW | Partial |

## 6. Implementation Roadmap

### Phase 1: Critical Mitigations (Pre-Launch - Weeks 1-4)

**Authentication:**
- [ ] Implement rate limiting on all auth endpoints (combined IP/user/device-based)
- [ ] Configure short-lived access tokens (1 hour) with refresh tokens (30 days)
- [ ] Implement token rotation mechanism
- [ ] Add certificate pinning to mobile app
- [ ] Configure session timeout (30 days inactivity)
- [ ] Implement account lockout after failed attempts
- [ ] Add device binding for tokens

**Storage:**
- [ ] Implement server-side file validation (magic numbers, MIME types)
- [ ] Configure short-lived signed URLs (1 hour)
- [ ] Implement EXIF metadata stripping
- [ ] Use UUIDs for file names
- [ ] Configure storage quotas per baby profile
- [ ] Implement upload rate limiting
- [ ] Disable directory listing on all buckets

**Access Control:**
- [ ] Comprehensive RLS policy review and testing
- [ ] Implement cryptographically secure invitation tokens
- [ ] Enforce one-time use for invitation tokens
- [ ] Add rate limiting on invitation sends

**Monitoring:**
- [ ] Set up comprehensive security logging
- [ ] Configure real-time alerts for security events
- [ ] Implement audit logging for critical actions

### Phase 2: High Priority Mitigations (Post-Launch - Weeks 5-8)

**Authentication:**
- [ ] Implement suspicious login detection
- [ ] Add MFA option for enhanced security
- [ ] Implement credential breach monitoring
- [ ] Configure concurrent session limits
- [ ] Add remote session termination capability
- [ ] Implement biometric re-authentication for sensitive operations

**Storage:**
- [ ] Implement file integrity checking with checksums
- [ ] Add file versioning for audit trail
- [ ] Configure automated content moderation (future)
- [ ] Implement content scanning for malware

**Access Control:**
- [ ] Regular penetration testing of RLS policies
- [ ] Implement immutable role assignments with approval workflow

**Monitoring:**
- [ ] Integrate SIEM for advanced threat detection
- [ ] Develop incident response playbooks
- [ ] Configure log aggregation and analysis

### Phase 3: Medium Priority Mitigations (Weeks 9-12)

**Authentication:**
- [ ] Implement constant-time comparisons for timing attack prevention
- [ ] Add CAPTCHA for repeated failed attempts
- [ ] Configure geographic rate limiting
- [ ] Block disposable email domains

**Storage:**
- [ ] Implement automated cleanup of orphaned files
- [ ] Add user reporting system for inappropriate content
- [ ] Configure bandwidth monitoring and cost alerts

**Third-Party:**
- [ ] Regular API key rotation for third-party services
- [ ] Implement secret management system
- [ ] Conduct third-party security assessments
- [ ] Minimize data sharing with third parties

### Phase 4: Continuous Improvements (Ongoing)

- [ ] Quarterly security audits of all RLS policies
- [ ] Regular penetration testing (quarterly)
- [ ] Continuous monitoring and tuning of rate limits
- [ ] Regular review of third-party service security
- [ ] Ongoing log analysis and threat intelligence
- [ ] Update threat model based on new features and threats
- [ ] Annual comprehensive security assessment

## 7. Security Testing Requirements

### 7.1. Authentication Testing

**Unit Tests:**
- Password complexity validation
- Email validation
- Token generation and validation
- Session management

**Integration Tests:**
- End-to-end login flow
- Password reset flow
- Email verification flow
- Token refresh flow
- Multi-device session handling

**Security Tests:**
- Brute force attack resistance
- SQL injection attempts
- Session hijacking scenarios
- Token manipulation attempts
- Rate limiting effectiveness
- Account lockout functionality

### 7.2. Storage Testing

**Unit Tests:**
- File type validation
- File size validation
- EXIF removal
- URL signing

**Integration Tests:**
- End-to-end upload flow
- Download with signed URLs
- Thumbnail generation
- File deletion

**Security Tests:**
- Malicious file upload attempts
- Unauthorized access attempts
- Directory traversal attempts
- Storage quota enforcement
- Rate limiting effectiveness
- RLS policy enforcement

### 7.3. Access Control Testing

**Unit Tests:**
- Role assignment logic
- Permission checking
- Invitation token generation/validation

**Integration Tests:**
- Invitation accept flow
- Role-based access scenarios
- Owner vs Follower permissions

**Security Tests:**
- Privilege escalation attempts
- Cross-baby-profile access attempts
- RLS policy bypass attempts
- Invitation token abuse scenarios

## 8. Compliance and Privacy Considerations

### 8.1. Data Protection

- **Encryption at Rest:** AES-256 encryption for all stored data (database and file storage)
- **Encryption in Transit:** TLS 1.3 for all communications
- **Data Minimization:** Collect and store only necessary data
- **Purpose Limitation:** Use data only for stated purposes

### 8.2. User Privacy Rights

- **Access:** Users can view all their data
- **Rectification:** Users can correct their data
- **Erasure:** Soft delete with 7-year retention *as defined in Requirements.md section 6 for legal/compliance purposes*
- **Portability:** Ability to export user data (future enhancement)
- **Consent:** Clear consent for data collection and processing

**Note on Data Retention:** The 7-year retention policy comes from Requirements.md section 6. This retention period must be supported by specific legal grounds (e.g., regulatory requirements, legitimate business interests). For jurisdictions with stricter privacy requirements (e.g., GDPR), consider implementing:
- Clear communication of retention policy in Terms of Service
- Documentation of legal basis for retention
- Hard delete option for users in jurisdictions requiring immediate deletion
- Regular review of retention requirements with legal counsel

### 8.3. Data Retention

- **Active Data:** Available during account lifetime
- **Deleted Data:** Soft delete with 7-year retention for compliance
- **Audit Logs:** Retained for 7 years
- **Backup Data:** Retained according to backup policy

## 9. Incident Response

### 9.1. Incident Classification

**Severity Levels:**
- **Critical:** Data breach, mass unauthorized access, complete service outage
- **High:** Single account compromise, significant service degradation
- **Medium:** Failed attack attempts, minor data leakage, partial service degradation
- **Low:** Suspicious activity detected, policy violations

### 9.2. Response Procedures

**Detection:**
1. Automated monitoring and alerting
2. User reports
3. Security team review

**Analysis:**
1. Determine incident scope and severity
2. Identify affected users and data
3. Determine root cause

**Containment:**
1. Isolate affected systems
2. Revoke compromised credentials
3. Block malicious IPs/users
4. Enable additional security measures

**Eradication:**
1. Remove malicious content/access
2. Patch vulnerabilities
3. Update security policies

**Recovery:**
1. Restore normal operations
2. Verify system integrity
3. Monitor for recurring issues

**Post-Incident:**
1. Document incident details
2. Conduct post-mortem analysis
3. Update security measures
4. Notify affected users (if required)
5. Update threat model

### 9.3. Communication Plan

**Internal:**
- Security team
- Development team
- Management
- Legal/compliance

**External:**
- Affected users (if applicable)
- Regulatory bodies (if required)
- Law enforcement (if criminal activity)

## 10. Assumptions and Dependencies

### 10.1. Assumptions

- Supabase infrastructure maintains AES-256 encryption at rest
- Supabase enforces TLS 1.3 for all connections
- iOS Keychain and Android Keystore are secure for token storage
- Third-party services (SendGrid, OneSignal) maintain adequate security
- Users will keep their devices updated with security patches

### 10.2. Dependencies

- Supabase platform security updates
- Flutter security updates
- Third-party service security
- Operating system security (iOS, Android)
- CDN provider security

### 10.3. Limitations

- Limited control over client device security
- Dependence on third-party service security
- Supabase free tier limitations for security features
- Resource constraints for advanced security features

## 11. Conclusion

This threat model provides a comprehensive analysis of security threats to the Nonna App's authentication and storage systems. The identified threats span the STRIDE categories and range from critical to low priority. The implementation roadmap provides a phased approach to addressing these threats, starting with critical mitigations before launch and continuing with ongoing security improvements.

Key priorities include:
1. **Authentication hardening:** Rate limiting, token security, session management
2. **Storage security:** File validation, access control, metadata protection
3. **Access control:** RLS policy enforcement, invitation security
4. **Monitoring and logging:** Comprehensive security visibility
5. **Incident response:** Preparation for security events

Regular review and updates of this threat model are essential as the application evolves and new threats emerge. Security is an ongoing process requiring continuous monitoring, testing, and improvement.

## 12. Document Control

**Version:** 1.0  
**Date:** December 18, 2024  
**Status:** Initial Release  
**Next Review:** March 18, 2025 (Quarterly)  
**Owner:** Security Team  
**Approvers:** Product Owner, Technical Lead, Security Team

### Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2024-12-18 | Security Team | Initial threat model for authentication and storage |

### References

- Requirements Document: `docs/discovery/01_requirements/Requirements.md`
- Technology Stack: `docs/discovery/02_technology_stack/Technology_Stack.md`
- Risk Assessment: `docs/pre_development_epics/2.1_risk_assessment/Risk_Assessment.md`
- Supabase Security Documentation
- OWASP Mobile Security Project
- STRIDE Threat Modeling Methodology
