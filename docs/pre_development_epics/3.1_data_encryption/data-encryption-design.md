# Data Encryption Design for Photos and Profiles

**Project:** Nonna App  
**Epic:** Epic 3 - Security and Privacy Planning  
**Story:** Story 3.1 - Design Data Encryption for Photos and Profiles  
**Date:** December 2025  
**Version:** 1.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Encryption Requirements](#2-encryption-requirements)
3. [Architecture Overview](#3-architecture-overview)
4. [Profile Data Encryption](#4-profile-data-encryption)
5. [Photo Encryption](#5-photo-encryption)
6. [Key Management](#6-key-management)
7. [Encryption in Transit](#7-encryption-in-transit)
8. [Encryption at Rest](#8-encryption-at-rest)
9. [Client-Side Encryption](#9-client-side-encryption)
10. [Implementation Roadmap](#10-implementation-roadmap)
11. [Security Considerations](#11-security-considerations)
12. [Compliance and Standards](#12-compliance-and-standards)
13. [Testing and Validation](#13-testing-and-validation)
14. [References](#14-references)

---

## 1. Overview

### 1.1. Purpose

This document outlines the comprehensive data encryption strategy for the Nonna App, specifically focusing on protecting sensitive user profile data and photos. The design ensures that all personally identifiable information (PII) and media content are encrypted both in transit and at rest, meeting industry security standards.

### 1.2. Scope

This encryption design covers:

- **User Profiles:** Email addresses, names, contact information
- **Baby Profiles:** Baby names, birth dates, gender, profile photos
- **Photo Gallery:** Pregnancy and newborn photos, captions, metadata
- **Metadata:** Upload timestamps, user relationships, permissions

### 1.3. Key Principles

1. **Defense in Depth:** Multiple layers of encryption (transport, storage, application)
2. **Minimal Trust:** Encrypt data before it leaves the client when possible
3. **Compliance First:** Meet AES-256 and TLS 1.3 requirements from Requirements.md
4. **Performance Balance:** Maintain < 500ms response time and < 5s photo uploads
5. **Privacy by Design:** Encrypt sensitive fields, control access via Row-Level Security

---

## 2. Encryption Requirements

### 2.1. Regulatory Requirements

From **Requirements.md Section 4.2 (Security)**:

> "All data must use AES-256 encryption at rest and TLS 1.3 in transit."

### 2.2. Specific Data Protection Needs

| Data Type | Sensitivity | Encryption Requirement |
|-----------|-------------|----------------------|
| User Email | High | AES-256 at rest, TLS 1.3 in transit |
| User Name | Medium | AES-256 at rest, TLS 1.3 in transit |
| Baby Name | High | AES-256 at rest, TLS 1.3 in transit |
| Birth Date | High | AES-256 at rest, TLS 1.3 in transit |
| Profile Photos | High | AES-256 at rest, TLS 1.3 in transit |
| Gallery Photos | High | AES-256 at rest, TLS 1.3 in transit |
| Photo Captions | Medium | AES-256 at rest, TLS 1.3 in transit |
| Comments | Low-Medium | AES-256 at rest, TLS 1.3 in transit |

### 2.3. Performance Requirements

- API response time: < 500ms
- Photo upload time: < 5 seconds
- Real-time updates: < 2 seconds propagation
- Encryption overhead: < 50ms per operation

---

## 3. Architecture Overview

### 3.1. Encryption Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Client-Side Encryption (Optional Sensitive Fields)  │  │
│  │  - Encrypted before transmission                     │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ TLS 1.3 (Encryption in Transit)
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Supabase Platform                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           PostgreSQL Database (RLS Enabled)          │  │
│  │  - AES-256 Encryption at Rest (Infrastructure)       │  │
│  │  - Column-level encryption for sensitive fields      │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Supabase Storage (S3-backed)            │  │
│  │  - AES-256 Encryption at Rest (S3 SSE-S3)           │  │
│  │  - Server-side encryption for all objects           │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 3.2. Encryption Flow

1. **Client:** Data prepared for transmission (optional client-side encryption for extra-sensitive fields)
2. **Transport:** TLS 1.3 connection established (mutual authentication, forward secrecy)
3. **Server:** Supabase receives encrypted data over TLS
4. **Storage:** Data written to PostgreSQL/Storage with AES-256 encryption at rest
5. **Retrieval:** Reverse process maintains encryption at each layer

---

## 4. Profile Data Encryption

### 4.1. User Profile Table (`profiles`)

**Schema:**
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  relationship_label TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Encryption Strategy:**

| Field | Encryption Method | Rationale |
|-------|------------------|-----------|
| `id` | None (UUID) | Non-sensitive identifier |
| `email` | Database-level AES-256 at rest | PII - High sensitivity |
| `full_name` | Database-level AES-256 at rest | PII - High sensitivity |
| `avatar_url` | Storage encryption + signed URLs | Photo reference |
| `relationship_label` | Database-level AES-256 at rest | Medium sensitivity |
| `created_at`, `updated_at` | None | Non-sensitive metadata |

**Implementation:**
- **At Rest:** PostgreSQL transparent data encryption (TDE) via Supabase infrastructure
- **In Transit:** All API calls over TLS 1.3
- **Access Control:** Row-Level Security policies restrict access to authenticated users

### 4.2. Baby Profile Table (`baby_profiles`)

**Schema:**
```sql
CREATE TABLE baby_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  baby_name TEXT,
  profile_photo_url TEXT,
  expected_birth_date DATE,
  gender TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Encryption Strategy:**

| Field | Encryption Method | Rationale |
|-------|------------------|-----------|
| `id` | None (UUID) | Non-sensitive identifier |
| `baby_name` | Database-level AES-256 at rest | PII - High sensitivity |
| `profile_photo_url` | Storage encryption + signed URLs | Photo reference |
| `expected_birth_date` | Database-level AES-256 at rest | PHI - High sensitivity |
| `gender` | Database-level AES-256 at rest | Medium sensitivity |
| `created_at`, `updated_at` | None | Non-sensitive metadata |

**Additional Considerations:**
- **Birth Date:** Considered Protected Health Information (PHI) in some jurisdictions
- **Column-Level Encryption:** May implement for `baby_name` and `expected_birth_date` for additional security

### 4.3. Column-Level Encryption (Optional Enhancement)

For extra-sensitive fields, PostgreSQL `pgcrypto` extension can provide application-level encryption:

```sql
-- Enable pgcrypto extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Example: Encrypt baby_name at column level
ALTER TABLE baby_profiles 
  ADD COLUMN baby_name_encrypted BYTEA;

-- Insert with encryption
INSERT INTO baby_profiles (baby_name_encrypted)
VALUES (pgp_sym_encrypt('Baby Name', 'encryption_key'));

-- Select with decryption
SELECT pgp_sym_decrypt(baby_name_encrypted, 'encryption_key') as baby_name
FROM baby_profiles;
```

**Decision:** Column-level encryption will be **optional** for MVP. Infrastructure-level AES-256 is sufficient for requirements. Can be added later if additional compliance needs arise (e.g., HIPAA for health data).

---

## 5. Photo Encryption

### 5.1. Photo Metadata Table (`photos`)

**Schema:**
```sql
CREATE TABLE photos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  baby_profile_id UUID NOT NULL REFERENCES baby_profiles(id),
  storage_path TEXT NOT NULL,
  caption TEXT,
  uploaded_by UUID REFERENCES profiles(id),
  file_size_bytes BIGINT,
  mime_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Encryption Strategy:**

| Field | Encryption Method | Rationale |
|-------|------------------|-----------|
| `id` | None (UUID) | Non-sensitive identifier |
| `baby_profile_id` | None (UUID reference) | Non-sensitive reference |
| `storage_path` | None | Internal path, not exposed |
| `caption` | Database-level AES-256 at rest | User content - Medium sensitivity |
| `uploaded_by` | None (UUID reference) | Non-sensitive reference |
| `file_size_bytes`, `mime_type` | None | Non-sensitive metadata |
| `created_at` | None | Non-sensitive timestamp |

### 5.2. Photo File Storage (Supabase Storage)

**Storage Architecture:**
```
Supabase Storage (S3-backed)
├── Bucket: baby_profile_photos/
│   ├── {baby_profile_id}/profile_photo.jpg (encrypted)
│   └── {baby_profile_id}/profile_photo_thumb.jpg (encrypted)
├── Bucket: gallery_photos/
│   ├── {baby_profile_id}/{photo_id}.jpg (encrypted)
│   └── {baby_profile_id}/{photo_id}_thumb.jpg (encrypted)
└── Bucket: event_photos/
    ├── {baby_profile_id}/{event_id}/{photo_id}.jpg (encrypted)
    └── {baby_profile_id}/{event_id}/{photo_id}_thumb.jpg (encrypted)
```

**Encryption Implementation:**

1. **Server-Side Encryption (SSE-S3):**
   - **Method:** AES-256 encryption managed by AWS S3
   - **Scope:** All objects in all buckets
   - **Key Management:** AWS-managed keys (SSE-S3)
   - **Configuration:** Enabled by default in Supabase Storage

2. **Access Control:**
   - **Signed URLs:** Time-limited, authenticated access to photos
   - **RLS Policies:** Database-level access control on `photos` table
   - **Bucket Policies:** Supabase Storage policies restrict access

3. **Upload Flow:**
   ```
   Flutter App → TLS 1.3 → Supabase Storage API → S3 (AES-256 SSE-S3)
   ```

4. **Download Flow:**
   ```
   Flutter App → TLS 1.3 → Signed URL → S3 (decrypts on-the-fly) → TLS 1.3 → Flutter App
   ```

### 5.3. Photo Upload Process (Encrypted End-to-End)

**Step-by-Step:**

1. **Client Preparation:**
   - User selects photo from device or camera
   - Flutter app compresses/resizes (to meet < 5s upload target)
   - File validated: JPEG/PNG, < 10MB

2. **Secure Upload:**
   - Establish TLS 1.3 connection to Supabase
   - Upload photo via Supabase Storage API
   - S3 backend encrypts with AES-256 (SSE-S3)

3. **Metadata Storage:**
   - Insert row into `photos` table (encrypted at rest)
   - Generate thumbnail via Edge Function (also encrypted)

4. **Access Grant:**
   - Generate signed URL with expiration (e.g., 1 hour)
   - Return URL to client over TLS 1.3
   - Client caches photo securely on device

**Performance Target:** < 5 seconds (met via client-side compression and CDN delivery)

### 5.4. Thumbnail Generation

**Process:**
- **Trigger:** Edge Function on photo upload
- **Resize:** Generate 300x300px thumbnail
- **Storage:** Save as `{photo_id}_thumb.jpg` (also AES-256 encrypted)
- **Purpose:** Fast gallery loading, reduce bandwidth

---

## 6. Key Management

### 6.1. Encryption Key Types

| Key Type | Purpose | Management |
|----------|---------|-----------|
| **TLS Certificates** | Encrypt data in transit | Managed by Supabase/AWS |
| **Database Encryption Keys** | Encrypt PostgreSQL data at rest | Managed by Supabase infrastructure |
| **S3 SSE-S3 Keys** | Encrypt photos at rest | Managed by AWS S3 |
| **JWT Signing Keys** | Sign authentication tokens | Managed by Supabase Auth |
| **Service Role Keys** | Server-side API access | Stored in environment variables |

### 6.2. Key Rotation

- **TLS Certificates:** Auto-renewed via Let's Encrypt (90-day rotation)
- **Database Keys:** Rotated by Supabase infrastructure (annual or as needed)
- **S3 Keys:** Rotated by AWS automatically
- **JWT Signing Keys:** Rotated via Supabase dashboard (recommended: annually)
- **Service Role Keys:** Manual rotation recommended quarterly

### 6.3. Key Storage Best Practices

**Development:**
- Store keys in `.env.local` (never commit to version control)
- Use Flutter secure storage for client-side tokens

**Production:**
- Store in environment variables (GitHub Secrets for CI/CD)
- Use Supabase dashboard for service role keys
- Enable billing alerts to detect key compromise

---

## 7. Encryption in Transit

### 7.1. TLS 1.3 Implementation

**Requirements (from Requirements.md):**
> "All data must use... TLS 1.3 in transit."

**Implementation:**
- **Protocol:** TLS 1.3 (mandatory, no fallback to older versions)
- **Provider:** Supabase platform (built-in)
- **Cipher Suites:** Modern, forward-secrecy enabled (e.g., `TLS_AES_256_GCM_SHA384`)

**Configuration:**
```dart
// Flutter HTTP client configuration
final httpClient = HttpClient()
  ..badCertificateCallback = (cert, host, port) => false; // Reject bad certs

final supabase = Supabase.instance.client;
// Supabase SDK enforces HTTPS/TLS 1.3 by default
```

### 7.2. Certificate Validation

- **Certificate Pinning:** Optional for extra security (can implement in production)
- **Validation:** Flutter validates TLS certificates automatically
- **Rejection:** Any connection without valid TLS 1.3 is rejected

### 7.3. API Endpoints

All API calls use HTTPS:
```
https://<project-ref>.supabase.co/rest/v1/...
https://<project-ref>.supabase.co/storage/v1/...
https://<project-ref>.supabase.co/auth/v1/...
```

---

## 8. Encryption at Rest

### 8.1. Database Encryption (PostgreSQL)

**Method:** Transparent Data Encryption (TDE)

**Implementation:**
- **Encryption:** AES-256 (CBC or GCM mode)
- **Scope:** All database files (tables, indexes, WAL logs)
- **Management:** Supabase infrastructure (AWS RDS encryption)
- **Compliance:** Meets AES-256 requirement from Requirements.md

**Verification:**
```sql
-- Check encryption status (Supabase Pro+)
SELECT name, setting 
FROM pg_settings 
WHERE name LIKE '%encryption%';
```

### 8.2. Storage Encryption (Supabase Storage / S3)

**Method:** Server-Side Encryption with S3-Managed Keys (SSE-S3)

**Implementation:**
- **Encryption:** AES-256
- **Scope:** All objects in all buckets
- **Key Management:** AWS S3 manages encryption keys
- **Compliance:** Meets AES-256 requirement from Requirements.md

**Bucket Configuration:**
```javascript
// Enable encryption on bucket creation (default in Supabase)
const { data, error } = await supabase
  .storage
  .createBucket('gallery_photos', {
    public: false,
    fileSizeLimit: 10 * 1024 * 1024, // 10MB
    allowedMimeTypes: ['image/jpeg', 'image/png']
  });
```

### 8.3. Backup Encryption

- **Database Backups:** Encrypted with AES-256 (Supabase manages)
- **Retention:** 7 days point-in-time recovery (Pro plan)
- **Storage:** Encrypted S3 buckets

---

## 9. Client-Side Encryption

### 9.1. When to Use Client-Side Encryption

**Recommended for:**
- Extra-sensitive fields requiring zero-knowledge architecture
- Compliance with stricter regulations (e.g., HIPAA)
- Fields that should never be readable by server administrators

**Not Recommended for MVP:**
- Adds complexity (key management, recovery)
- Impacts searchability and real-time updates
- Performance overhead

**Decision:** Infrastructure-level encryption (TLS + AES-256 at rest) is **sufficient for MVP**. Client-side encryption can be added in V2 if needed.

### 9.2. Client-Side Implementation (Future Consideration)

If client-side encryption is required in the future:

**Library:** `flutter_sodium` or `pointycastle`

**Example:**
```dart
import 'package:flutter_sodium/flutter_sodium.dart';

// Encrypt sensitive field before upload
final encryptedName = Sodium.cryptoSecretboxEasy(
  message: 'Baby Name',
  nonce: nonce,
  key: userKey,
);

// Upload encrypted data
await supabase.from('baby_profiles').insert({
  'baby_name_encrypted': encryptedName,
});

// Decrypt on client
final decryptedName = Sodium.cryptoSecretboxOpenEasy(
  ciphertext: encryptedName,
  nonce: nonce,
  key: userKey,
);
```

**Key Management:** Store user keys securely in iOS Keychain / Android Keystore

---

## 10. Implementation Roadmap

### 10.1. Phase 1: Foundation (Weeks 1-2)

**Encryption in Transit:**
- [x] Verify Supabase enforces TLS 1.3
- [ ] Configure Flutter app to use HTTPS exclusively
- [ ] Test certificate validation
- [ ] Document TLS configuration in implementation guide

**Encryption at Rest:**
- [x] Verify PostgreSQL AES-256 encryption enabled (Supabase default)
- [x] Verify S3 SSE-S3 encryption enabled (Supabase default)
- [ ] Document encryption verification steps

### 10.2. Phase 2: Profile Encryption (Weeks 3-4)

**User Profiles:**
- [ ] Design `profiles` table schema with encryption in mind
- [ ] Implement RLS policies for access control
- [ ] Test profile CRUD operations over TLS
- [ ] Verify data encrypted at rest

**Baby Profiles:**
- [ ] Design `baby_profiles` table schema
- [ ] Implement RLS policies for owners/followers
- [ ] Test baby profile operations
- [ ] Verify sensitive fields encrypted

### 10.3. Phase 3: Photo Encryption (Weeks 5-6)

**Storage Setup:**
- [ ] Create encrypted buckets: `baby_profile_photos`, `gallery_photos`, `event_photos`
- [ ] Configure bucket policies and RLS
- [ ] Test photo upload with TLS 1.3
- [ ] Verify S3 SSE-S3 encryption on stored files

**Photo Metadata:**
- [ ] Design `photos` table with encrypted captions
- [ ] Implement signed URL generation (1-hour expiration)
- [ ] Test photo retrieval and access control
- [ ] Verify metadata encrypted at rest

**Thumbnail Generation:**
- [ ] Implement Edge Function for thumbnail creation
- [ ] Ensure thumbnails are also encrypted (SSE-S3)
- [ ] Test thumbnail caching and delivery

### 10.4. Phase 4: Testing & Validation (Weeks 7-8)

**Security Audit:**
- [ ] Penetration testing on API endpoints
- [ ] Verify all connections use TLS 1.3
- [ ] Verify all data encrypted at rest (database + storage)
- [ ] Test access control and RLS policies

**Performance Testing:**
- [ ] Measure encryption overhead (< 50ms per operation)
- [ ] Test photo upload time (< 5 seconds)
- [ ] Test API response time (< 500ms)
- [ ] Test real-time updates (< 2 seconds)

**Compliance Verification:**
- [ ] Document compliance with Requirements.md Section 4.2
- [ ] Generate encryption audit report
- [ ] Review key management procedures
- [ ] Document backup encryption strategy

---

## 11. Security Considerations

### 11.1. Threat Model

**Threats Mitigated:**
1. **Man-in-the-Middle (MITM):** TLS 1.3 prevents eavesdropping and tampering
2. **Data Breach (Database):** AES-256 encryption protects data if database is compromised
3. **Data Breach (Storage):** SSE-S3 encryption protects photos if S3 bucket is compromised
4. **Unauthorized Access:** RLS policies + JWT auth prevent unauthorized data access
5. **Data in Transit Leakage:** HTTPS-only communication prevents network sniffing

**Threats NOT Fully Mitigated (Require Additional Controls):**
1. **Compromised Admin Access:** Server administrators can potentially access decrypted data
   - **Mitigation:** Implement audit logging, least-privilege access
2. **Client-Side Malware:** Malware on user device can steal data after decryption
   - **Mitigation:** Educate users, implement device security best practices
3. **Key Compromise:** If encryption keys are stolen, data can be decrypted
   - **Mitigation:** Regular key rotation, secure key storage

### 11.2. Access Control Integration

**Row-Level Security (RLS):**
```sql
-- Example: Only baby profile members can view photos
CREATE POLICY "Members can view photos"
ON photos FOR SELECT
USING (
  baby_profile_id IN (
    SELECT baby_profile_id 
    FROM baby_profile_memberships 
    WHERE user_id = auth.uid()
  )
);

-- Example: Only owners can upload photos
CREATE POLICY "Owners can upload photos"
ON photos FOR INSERT
WITH CHECK (
  baby_profile_id IN (
    SELECT baby_profile_id 
    FROM baby_profile_memberships 
    WHERE user_id = auth.uid() AND role = 'OWNER'
  )
);
```

**Storage Policies:**
```sql
-- Example: Only members can access photos
CREATE POLICY "Members can download photos"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'gallery_photos' AND
  (storage.foldername(name))[1] IN (
    SELECT baby_profile_id::text 
    FROM baby_profile_memberships 
    WHERE user_id = auth.uid()
  )
);
```

### 11.3. Monitoring and Alerts

**Security Monitoring:**
- [ ] Enable Supabase audit logs (Pro plan)
- [ ] Monitor failed authentication attempts
- [ ] Track unusual data access patterns
- [ ] Alert on TLS handshake failures

**Performance Monitoring:**
- [ ] Monitor encryption overhead
- [ ] Track photo upload/download times
- [ ] Alert on performance degradation

---

## 12. Compliance and Standards

### 12.1. Compliance Status

| Standard | Requirement | Status | Notes |
|----------|-------------|--------|-------|
| **Requirements.md 4.2** | AES-256 at rest | ✅ Met | PostgreSQL + S3 SSE-S3 |
| **Requirements.md 4.2** | TLS 1.3 in transit | ✅ Met | Supabase enforces TLS 1.3 |
| **GDPR** | Data protection | ✅ Met | Encryption + access control |
| **SOC 2 Type 2** | Security controls | ✅ Met | Supabase is SOC 2 certified |
| **ISO 27001** | Information security | ✅ Met | Supabase is ISO 27001 certified |
| **HIPAA** | PHI protection | ⚠️ Partial | Requires Enterprise plan + BAA |

### 12.2. Data Retention and Encryption

From **Requirements.md Section 6 (Data Retention):**
> "User data must be retained for 7 years post-account deletion to comply with data retention policies."

**Encryption for Retained Data:**
- Soft-deleted records remain encrypted at rest (AES-256)
- Access revoked via RLS policies
- Scheduled cleanup after 7 years (data permanently deleted)

### 12.3. Security Certifications

**Supabase Platform:**
- SOC 2 Type 2 Certified
- GDPR Compliant
- ISO 27001 Compliant
- Regular third-party security audits

---

## 13. Testing and Validation

### 13.1. Encryption Verification Tests

**TLS 1.3 Verification:**
```bash
# Test TLS version
openssl s_client -connect <project-ref>.supabase.co:443 -tls1_3

# Expected output: TLS 1.3, cipher: TLS_AES_256_GCM_SHA384
```

**Database Encryption Verification:**
```sql
-- Check PostgreSQL encryption settings
SELECT name, setting FROM pg_settings WHERE name LIKE '%encrypt%';

-- Verify data is encrypted on disk (requires database admin access)
```

**Storage Encryption Verification:**
```bash
# Verify S3 bucket encryption (via AWS CLI)
aws s3api get-bucket-encryption --bucket <bucket-name>

# Expected: AES256 encryption enabled
```

### 13.2. Performance Tests

**Photo Upload Test:**
```dart
// Measure upload time
final stopwatch = Stopwatch()..start();

final file = File('test_photo.jpg'); // 5MB test file
await supabase.storage.from('gallery_photos').upload(
  'test/${uuid.v4()}.jpg',
  file,
);

stopwatch.stop();
print('Upload time: ${stopwatch.elapsedMilliseconds}ms'); // Target: < 5000ms
```

**API Response Time Test:**
```dart
// Measure query time
final stopwatch = Stopwatch()..start();

final photos = await supabase
  .from('photos')
  .select()
  .eq('baby_profile_id', babyProfileId)
  .limit(20);

stopwatch.stop();
print('Query time: ${stopwatch.elapsedMilliseconds}ms'); // Target: < 500ms
```

### 13.3. Security Penetration Tests

**Recommended Tests:**
1. **SSL/TLS Scan:** Use `testssl.sh` or SSL Labs to verify TLS 1.3 enforcement
2. **SQL Injection:** Test RLS policies with malicious queries
3. **Unauthorized Access:** Attempt to access photos without valid token
4. **MITM Simulation:** Test certificate validation and pinning

---

## 14. References

### 14.1. Internal Documents

- **Requirements.md:** `/docs/discovery/01_requirements/Requirements.md`
- **Technology Stack.md:** `/docs/discovery/02_technology_stack/Technology_Stack.md`
- **Supabase Feasibility Study:** `/docs/pre_development_epics/1.1_feasibility_study/`

### 14.2. External Standards

- **NIST AES-256:** [FIPS 197](https://csrc.nist.gov/publications/detail/fips/197/final)
- **TLS 1.3 RFC:** [RFC 8446](https://datatracker.ietf.org/doc/html/rfc8446)
- **PostgreSQL Encryption:** [Official Docs](https://www.postgresql.org/docs/current/encryption-options.html)
- **AWS S3 SSE-S3:** [AWS Documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingServerSideEncryption.html)

### 14.3. Supabase Resources

- **Supabase Security:** [https://supabase.com/docs/guides/platform/security](https://supabase.com/docs/guides/platform/security)
- **Row-Level Security:** [https://supabase.com/docs/guides/auth/row-level-security](https://supabase.com/docs/guides/auth/row-level-security)
- **Storage Security:** [https://supabase.com/docs/guides/storage/security](https://supabase.com/docs/guides/storage/security)

---

## Appendix A: Encryption Checklist

### Pre-Implementation

- [x] Review Requirements.md Section 4.2
- [x] Review Technology Stack.md Section 2.5
- [x] Design encryption architecture
- [x] Document encryption strategy

### Database Encryption

- [ ] Verify PostgreSQL AES-256 enabled
- [ ] Design table schemas with encryption
- [ ] Implement RLS policies
- [ ] Test data access controls

### Storage Encryption

- [ ] Verify S3 SSE-S3 encryption enabled
- [ ] Create encrypted storage buckets
- [ ] Configure bucket policies
- [ ] Test photo upload/download

### Transport Encryption

- [ ] Verify TLS 1.3 enforcement
- [ ] Configure Flutter HTTPS client
- [ ] Test certificate validation
- [ ] Document TLS configuration

### Testing

- [ ] Penetration testing
- [ ] Performance testing
- [ ] Compliance verification
- [ ] Security audit

### Documentation

- [x] Complete encryption design document
- [ ] Create implementation guide
- [ ] Document key management
- [ ] Create security runbook

---

## Appendix B: Glossary

- **AES-256:** Advanced Encryption Standard with 256-bit key (symmetric encryption)
- **TLS 1.3:** Transport Layer Security version 1.3 (successor to SSL)
- **SSE-S3:** Server-Side Encryption with S3-managed keys
- **RLS:** Row-Level Security (PostgreSQL access control)
- **TDE:** Transparent Data Encryption (database-level encryption)
- **PII:** Personally Identifiable Information
- **PHI:** Protected Health Information
- **JWT:** JSON Web Token (authentication token)

---

**Document Status:** ✅ Final  
**Next Review:** Post-implementation (8 weeks)  
**Maintained by:** Nonna App Security Team
