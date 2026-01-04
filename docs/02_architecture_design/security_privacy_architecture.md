# Security and Privacy Architecture Design

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Security & Architecture Team  
**Status**: Final  
**Section**: 1.3 - Architecture Design

## Executive Summary

This document defines the comprehensive security and privacy architecture for the Nonna App, a private, invite-only family social platform. The architecture is designed to protect sensitive family data, ensure multi-tenant isolation, enforce role-based access control, and comply with data privacy regulations including GDPR and CCPA.

The security architecture implements defense-in-depth principles with multiple layers of protection:
- **Authentication**: JWT-based with OAuth 2.0 support and secure token storage
- **Authorization**: Row-Level Security (RLS) policies enforced at database level
- **Encryption**: AES-256 at rest, TLS 1.3 in transit
- **Data Privacy**: Invite-only access model with 7-year retention compliance
- **Abuse Prevention**: Rate limiting, input validation, and monitoring

## References

This document is informed by and aligns with:

- `docs/00_requirement_gathering/business_requirements_document.md` - Privacy requirements and security objectives
- `docs/00_requirement_gathering/user_personas_document.md` - User security and privacy needs
- `docs/01_technical_requirements/functional_requirements_specification.md` - Security-related functional requirements
- `docs/01_technical_requirements/non_functional_requirements_specification.md` - Security, privacy, compliance requirements
- `docs/02_architecture_design/system_architecture_diagram.md` - Overall security architecture
- `discovery/01_discovery/02_technology_stack/Technology_Stack.md` - Security technology choices
- `discovery/02_pre_development_epics/3.1_data_encryption/data-encryption-design.md` - Encryption strategies

---

## 1. Security Architecture Overview

### 1.1 Security Principles

The Nonna App security architecture is guided by the following principles:

**1. Defense in Depth**
- Multiple layers of security controls
- No single point of failure
- Redundant security mechanisms

**2. Least Privilege**
- Users granted minimum necessary permissions
- Role-based access control (RBAC)
- Scoped API tokens

**3. Security by Default**
- Secure defaults for all configurations
- Opt-in for relaxed security (not opt-out)
- Privacy-first design

**4. Zero Trust**
- Never trust, always verify
- Authenticate and authorize every request
- Assume breach mentality

**5. Data Minimization**
- Collect only necessary data
- Retain data only as required (7-year compliance)
- Soft delete for recovery

**6. Transparency**
- Clear privacy policy
- User control over data
- Audit trails for sensitive operations

### 1.2 Security Layers

```
┌──────────────────────────────────────────────────────────────────┐
│                      SECURITY ARCHITECTURE                       │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Layer 1: Network Security                                  │ │
│  │  • TLS 1.3 Encryption (in transit)                         │ │
│  │  • Certificate Pinning (future)                            │ │
│  │  • Secure DNS (DNSSEC)                                     │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              ↓                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Layer 2: API Security                                      │ │
│  │  • JWT Authentication                                       │ │
│  │  • Rate Limiting                                            │ │
│  │  • Input Validation                                         │ │
│  │  • CORS Configuration                                       │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              ↓                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Layer 3: Application Security                              │ │
│  │  • OAuth 2.0                                                │ │
│  │  • Session Management                                       │ │
│  │  • Secure Token Storage (Keychain/Keystore)                │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              ↓                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Layer 4: Database Security                                 │ │
│  │  • Row-Level Security (RLS)                                │ │
│  │  • Database Encryption (AES-256 at rest)                   │ │
│  │  • Parameterized Queries                                    │ │
│  │  • Audit Logging                                            │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              ↓                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Layer 5: Data Security                                     │ │
│  │  • Encryption at Rest (AES-256)                            │ │
│  │  • Data Masking                                             │ │
│  │  • Soft Delete Pattern                                      │ │
│  │  • Backup Encryption                                        │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 2. Authentication Architecture

### 2.1 Authentication Mechanisms

**Supported Methods**:

1. **Email/Password**
   - Primary authentication method
   - Password hashing with bcrypt
   - Password strength requirements:
     - Minimum 6 characters
     - At least one number or special character
   - Email verification required before full access

2. **OAuth 2.0** (Social Login)
   - Google Sign-In
   - Facebook Login
   - Supabase Auth handles OAuth flow
   - User profile data synced to `profiles` table

3. **Biometric Authentication** (Future)
   - iOS: Face ID / Touch ID
   - Android: Fingerprint / Face Unlock
   - Optional, user-enabled
   - Local authentication only (no biometric data sent to server)

### 2.2 JWT Token Management

**Token Structure**:

```json
{
  "sub": "user_uuid",
  "email": "user@example.com",
  "email_verified": true,
  "role": "authenticated",
  "iss": "https://nonna.supabase.co/auth/v1",
  "iat": 1641024000,
  "exp": 1643616000
}
```

**Token Lifecycle**:

1. **Issuance**: Generated by Supabase Auth on successful login
2. **Storage**: Stored securely in:
   - iOS: Keychain with `kSecAttrAccessibleAfterFirstUnlock`
   - Android: EncryptedSharedPreferences with Android Keystore
3. **Usage**: Included in Authorization header for all API requests
4. **Expiry**: 30-day expiration with automatic refresh
5. **Refresh**: Silent refresh 5 minutes before expiry
6. **Revocation**: On logout or password change

**Token Security**:

- Never logged or exposed in error messages
- Not stored in SharedPreferences or UserDefaults (unencrypted)
- Automatically cleared on logout
- Invalidated on security-sensitive operations (password change)

### 2.3 Session Management

**Session Properties**:

- **Duration**: 30 days (configurable)
- **Idle Timeout**: None (mobile app context)
- **Concurrent Sessions**: Allowed (multi-device support)
- **Session Refresh**: Automatic, transparent to user

**Session Storage**:

```dart
// Example: Secure token storage
class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  
  Future<void> saveToken(String token) async {
    await _storage.write(
      key: 'access_token',
      value: token,
    );
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
  }
}
```

### 2.4 Password Security

**Password Policy**:

- Minimum length: 6 characters
- Complexity: At least one number OR special character
- No maximum length limit
- No password expiration (reduces security)
- Password reuse allowed (user's choice)

**Password Storage**:

- Never stored in plaintext
- Hashed with bcrypt (cost factor 10-12)
- Managed entirely by Supabase Auth
- Salt automatically generated per password

**Password Reset**:

1. User requests reset via email
2. System generates secure token (256-bit random)
3. Token expires in 1 hour
4. Email sent via SendGrid with reset link
5. User clicks link, enters new password
6. All existing sessions invalidated
7. User must log in with new password

**Rate Limiting**:

- Login attempts: 5 per 15 minutes per email
- Password reset requests: 3 per hour per email
- Implemented at Supabase Auth level

### 2.5 Email Verification

**Purpose**: Prevent fake accounts and ensure valid contact information

**Flow**:

1. User signs up with email/password
2. Account created but limited access
3. Verification email sent with 24-hour token
4. User clicks verification link
5. Email marked as verified in `auth.users`
6. Full app access granted

**Restrictions for Unverified Users**:

- Cannot create baby profiles
- Cannot send invitations
- Cannot upload photos
- Can only view limited welcome screen

---

## 3. Authorization Architecture

### 3.1 Role-Based Access Control (RBAC)

**Role Model**:

Nonna uses a relationship-based role model where roles are per-baby-profile, not global:

**Roles**:

1. **Owner** (Parent)
   - Full CRUD permissions on baby profile
   - Can invite/remove followers
   - Can upload/delete photos
   - Can create/edit/delete events and registry items
   - Maximum 2 owners per baby profile

2. **Follower** (Family/Friend)
   - Read permissions on baby profile content
   - Can comment on photos and events
   - Can RSVP to events
   - Can mark registry items as purchased
   - Can "squish" (like) photos
   - Cannot modify or delete content

**Role Assignment**:

- Stored in `baby_memberships` table
- Linked to `baby_profile_id` and `user_id`
- Includes `role` field ('owner' or 'follower')
- Includes `relationship` label (Mother, Grandma, Friend, etc.)

**Role Enforcement**:

- **Database Level**: Row-Level Security (RLS) policies
- **Application Level**: UI controls hidden/disabled based on role
- **API Level**: JWT claims used in RLS policy evaluation

### 3.2 Row-Level Security (RLS) Policies

**Purpose**: Enforce authorization at database level, preventing data access bypass

**Implementation**: PostgreSQL RLS policies on all tables

**Policy Examples**:

**1. Photos Table**:

```sql
-- Policy: Owners can CRUD photos for their baby profiles
CREATE POLICY "Owners can CRUD photos"
  ON photos
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM baby_memberships
      WHERE baby_memberships.baby_profile_id = photos.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

-- Policy: Followers can read photos for baby profiles they follow
CREATE POLICY "Followers can read photos"
  ON photos
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM baby_memberships
      WHERE baby_memberships.baby_profile_id = photos.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND photos.deleted_at IS NULL
  );

-- Policy: Followers can comment on photos
CREATE POLICY "Followers can comment on photos"
  ON photo_comments
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM baby_memberships
      WHERE baby_memberships.baby_profile_id = (
        SELECT baby_profile_id FROM photos WHERE photos.id = photo_comments.photo_id
      )
      AND baby_memberships.user_id = auth.uid()
      AND baby_memberships.removed_at IS NULL
    )
  );
```

**2. Events Table**:

```sql
-- Policy: Owners can CRUD events
CREATE POLICY "Owners can CRUD events"
  ON events
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM baby_memberships
      WHERE baby_memberships.baby_profile_id = events.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

-- Policy: Followers can read events
CREATE POLICY "Followers can read events"
  ON events
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM baby_memberships
      WHERE baby_memberships.baby_profile_id = events.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND events.deleted_at IS NULL
  );

-- Policy: Followers can RSVP to events
CREATE POLICY "Followers can RSVP to events"
  ON event_rsvps
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM baby_memberships
      WHERE baby_memberships.baby_profile_id = (
        SELECT baby_profile_id FROM events WHERE events.id = event_rsvps.event_id
      )
      AND baby_memberships.user_id = auth.uid()
      AND baby_memberships.removed_at IS NULL
    )
  );
```

**3. Registry Items Table**:

```sql
-- Policy: Owners can CRUD registry items
CREATE POLICY "Owners can CRUD registry items"
  ON registry_items
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM baby_memberships
      WHERE baby_memberships.baby_profile_id = registry_items.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

-- Policy: Followers can read registry items
CREATE POLICY "Followers can read registry items"
  ON registry_items
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM baby_memberships
      WHERE baby_memberships.baby_profile_id = registry_items.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND registry_items.deleted_at IS NULL
  );

-- Policy: Followers can mark items as purchased
CREATE POLICY "Followers can mark items as purchased"
  ON registry_purchases
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM baby_memberships
      WHERE baby_memberships.baby_profile_id = (
        SELECT baby_profile_id FROM registry_items WHERE registry_items.id = registry_purchases.registry_item_id
      )
      AND baby_memberships.user_id = auth.uid()
      AND baby_memberships.removed_at IS NULL
    )
  );
```

**RLS Testing Strategy**:

- Comprehensive test suite using pgTAP
- Test all CRUD operations for each role
- Test unauthorized access attempts
- Test edge cases (removed memberships, deleted content)
- Automated tests in CI/CD pipeline

```sql
-- Example pgTAP test
BEGIN;
  SELECT plan(5);
  
  -- Test: Owner can insert photo
  SET LOCAL jwt.claims.sub TO 'owner_user_id';
  SELECT lives_ok(
    $$INSERT INTO photos (baby_profile_id, url) VALUES ('baby1', 'photo.jpg')$$,
    'Owner can insert photo'
  );
  
  -- Test: Follower cannot insert photo
  SET LOCAL jwt.claims.sub TO 'follower_user_id';
  SELECT throws_ok(
    $$INSERT INTO photos (baby_profile_id, url) VALUES ('baby1', 'photo.jpg')$$,
    'Owner can insert photo'
  );
  
  SELECT finish();
ROLLBACK;
```

### 3.3 Multi-Tenant Isolation

**Tenant Boundary**: Baby profile (`baby_profiles.id`)

**Isolation Strategy**:

1. **Database Level**:
   - All data scoped by `baby_profile_id`
   - RLS policies enforce tenant access
   - Foreign keys ensure referential integrity

2. **Application Level**:
   - All queries filtered by accessible baby profiles
   - Tile providers scope data by role and baby IDs
   - No cross-tenant data leakage

3. **Storage Level**:
   - Photos stored with `baby_profile_id` prefix
   - Bucket policies enforce ownership
   - Signed URLs prevent unauthorized access

**Cross-Tenant Scenarios**:

- User follows multiple baby profiles: Sees aggregated data from all followed profiles
- User is owner of some, follower of others: UI shows role toggle, queries scoped accordingly
- User removed from profile: Loses all access immediately via RLS

---

## 4. Data Encryption

### 4.1 Encryption at Rest

**Database Encryption**:

- **Technology**: AES-256 encryption
- **Scope**: All data in PostgreSQL database
- **Management**: Managed by Supabase infrastructure (AWS RDS)
- **Keys**: Managed by AWS Key Management Service (KMS)
- **Compliance**: Meets GDPR, CCPA, and HIPAA requirements

**Storage Encryption**:

- **Technology**: AES-256 encryption
- **Scope**: All files in Supabase Storage (photos, thumbnails)
- **Management**: Managed by Supabase (AWS S3)
- **Keys**: Managed by AWS KMS
- **Access**: Signed URLs with expiration

**Client-Side Encryption** (Future Enhancement):

- Optional end-to-end encryption for photos
- User-controlled encryption keys
- Decrypt only on device
- Prevents server-side access to photo content

### 4.2 Encryption in Transit

**TLS Configuration**:

- **Protocol**: TLS 1.3 (minimum TLS 1.2)
- **Cipher Suites**: Strong ciphers only (AES-GCM, ChaCha20-Poly1305)
- **Certificate**: Valid SSL certificate for all endpoints
- **HSTS**: Enabled with `max-age=31536000; includeSubDomains`

**Implementation**:

- All API calls over HTTPS
- Supabase Realtime over WSS (WebSocket Secure)
- No fallback to unencrypted protocols
- Certificate pinning (future) to prevent MITM attacks

**Flutter Configuration**:

```dart
// Example: Enforce HTTPS and certificate validation
final supabase = SupabaseClient(
  supabaseUrl, // https://nonna.supabase.co
  supabaseAnonKey,
  httpClient: http.Client(), // Uses platform's cert validation
);

// Future: Certificate pinning
final pinnedClient = HttpClient()
  ..badCertificateCallback = (cert, host, port) {
    // Validate certificate fingerprint
    return cert.sha256 == expectedCertSha256;
  };
```

### 4.3 Key Management

**JWT Signing Keys**:

- Managed by Supabase Auth
- Rotated automatically
- Private key never exposed
- Public key used for verification

**API Keys**:

- **Anon Key**: Public, included in client app (restricted by RLS)
- **Service Role Key**: Private, used only in Edge Functions
- Stored in environment variables
- Never hardcoded or committed to Git

**Third-Party API Keys**:

- SendGrid API key: Stored in Edge Function environment
- OneSignal API key: Stored in Edge Function environment
- Sentry DSN: Stored in client app config (public)

**Key Rotation**:

- API keys rotated every 90 days (best practice)
- Process documented in runbook
- Zero downtime rotation via dual-key period

---

## 5. Privacy Architecture

### 5.1 Privacy-First Design

**Core Privacy Principles**:

1. **Invite-Only Access**:
   - No public profiles or content
   - All content requires invitation and acceptance
   - Invitations expire after 7 days

2. **User Control**:
   - Users control who sees their content
   - Users can remove followers anytime
   - Users can delete their data

3. **Data Minimization**:
   - Collect only necessary data
   - No tracking pixels or analytics cookies
   - Optional analytics (opt-in)

4. **Transparency**:
   - Clear privacy policy
   - Upfront disclosure of data usage
   - No hidden data collection

### 5.2 Data Privacy Compliance

**GDPR Compliance** (General Data Protection Regulation):

**Right to Access**:
- Users can export all their data via in-app feature
- Data provided in machine-readable format (JSON)
- Includes photos, events, comments, profile data

**Right to Rectification**:
- Users can edit their profile information
- Users can update or delete their comments
- Owners can edit or delete their content

**Right to Erasure** ("Right to be Forgotten"):
- Users can delete their account
- Account deletion triggers soft delete of all user data
- Data retained for 7 years for compliance, then purged
- User notified of retention period before deletion

**Right to Data Portability**:
- Users can download their data in JSON format
- Includes all photos, events, comments, profile data
- API endpoint for automated export (future)

**Right to Object**:
- Users can opt out of optional analytics
- Users can opt out of marketing emails
- Users can object to automated decision-making

**Consent Management**:
- Clear consent requested for optional features
- Granular consent (analytics, marketing, etc.)
- Easy to withdraw consent

**CCPA Compliance** (California Consumer Privacy Act):

- All GDPR rights apply
- Additional "Do Not Sell My Personal Information" option (not applicable as Nonna doesn't sell data)
- Annual privacy disclosure

### 5.3 Invitation Privacy

**Invitation Security**:

- Tokens are 256-bit random (cryptographically secure)
- Tokens hashed before storage (SHA-256)
- Tokens expire after 7 days
- Tokens single-use (marked as accepted/expired after use)
- Tokens can be revoked by owner

**Invitation Email Privacy**:

- No baby photo or sensitive data in email
- Generic subject line ("You've been invited to Nonna")
- Deep link includes token but no personal info
- Email sent via SendGrid (GDPR-compliant)

### 5.4 Data Retention

**Retention Policy**:

- **Active Data**: Retained indefinitely while account active
- **Soft Deleted Data**: Retained for 7 years after deletion
- **Hard Deleted Data**: Purged after retention period
- **Backups**: Encrypted backups retained for 30 days

**Soft Delete Implementation**:

```sql
-- Example: Soft delete pattern
CREATE TABLE photos (
  id UUID PRIMARY KEY,
  baby_profile_id UUID NOT NULL,
  url TEXT NOT NULL,
  deleted_at TIMESTAMPTZ,
  -- ... other fields
);

-- RLS policy excludes soft-deleted records
CREATE POLICY "Exclude deleted photos"
  ON photos
  FOR SELECT
  USING (deleted_at IS NULL);

-- Scheduled Edge Function for hard delete after 7 years
CREATE OR REPLACE FUNCTION hard_delete_expired_data()
RETURNS void AS $$
BEGIN
  DELETE FROM photos
  WHERE deleted_at IS NOT NULL
    AND deleted_at < NOW() - INTERVAL '7 years';
END;
$$ LANGUAGE plpgsql;
```

---

## 6. Input Validation & Sanitization

### 6.1 Client-Side Validation

**Purpose**: Improve UX and reduce server load

**Validation Types**:

1. **Format Validation**:
   - Email format
   - Password complexity
   - Date format
   - URL format

2. **Length Validation**:
   - Display name: 1-50 characters
   - Comment: 1-500 characters
   - Caption: 0-500 characters
   - Event title: 1-100 characters

3. **Type Validation**:
   - File type (JPEG, PNG only)
   - File size (max 10MB)
   - Date range (e.g., birth date not in future)

**Implementation**:

```dart
// Example: Client-side validation
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    final hasNumberOrSpecial = RegExp(r'[0-9!@#\$&*~]').hasMatch(value);
    if (!hasNumberOrSpecial) {
      return 'Password must contain at least one number or special character';
    }
    
    return null;
  }
  
  static String? comment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Comment cannot be empty';
    }
    
    if (value.length > 500) {
      return 'Comment must be 500 characters or less';
    }
    
    return null;
  }
}
```

### 6.2 Server-Side Validation

**Purpose**: Security enforcement (never trust client)

**Validation in Edge Functions**:

```typescript
// Example: Server-side validation in Edge Function
interface CreateEventRequest {
  baby_profile_id: string;
  title: string;
  event_date: string;
  description?: string;
}

async function createEvent(req: Request): Promise<Response> {
  const body: CreateEventRequest = await req.json();
  
  // Validate required fields
  if (!body.baby_profile_id || !body.title || !body.event_date) {
    return new Response(
      JSON.stringify({ error: 'Missing required fields' }),
      { status: 400 }
    );
  }
  
  // Validate title length
  if (body.title.length < 1 || body.title.length > 100) {
    return new Response(
      JSON.stringify({ error: 'Title must be 1-100 characters' }),
      { status: 400 }
    );
  }
  
  // Validate date format
  const date = new Date(body.event_date);
  if (isNaN(date.getTime())) {
    return new Response(
      JSON.stringify({ error: 'Invalid date format' }),
      { status: 400 }
    );
  }
  
  // Sanitize description (remove HTML tags)
  if (body.description) {
    body.description = body.description.replace(/<[^>]*>/g, '');
  }
  
  // Insert into database (RLS policies enforce authorization)
  const { data, error } = await supabase
    .from('events')
    .insert({
      baby_profile_id: body.baby_profile_id,
      title: body.title,
      event_date: body.event_date,
      description: body.description,
    })
    .select()
    .single();
  
  if (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500 }
    );
  }
  
  return new Response(JSON.stringify(data), { status: 201 });
}
```

### 6.3 SQL Injection Prevention

**Strategy**: Parameterized queries only

**Supabase Client** (Safe by Default):

```dart
// Good: Parameterized query
final data = await supabase
  .from('photos')
  .select()
  .eq('baby_profile_id', babyId) // Parameterized
  .order('created_at', ascending: false);

// Never use raw SQL with user input
// Bad: String interpolation (DON'T DO THIS)
// final data = await supabase.rpc('raw_query', params: {
//   'query': "SELECT * FROM photos WHERE baby_profile_id = '$babyId'"
// });
```

**Database Functions** (Parameterized):

```sql
-- Example: Safe database function
CREATE FUNCTION get_photos_for_baby(p_baby_id UUID)
RETURNS TABLE(id UUID, url TEXT, created_at TIMESTAMPTZ) AS $$
BEGIN
  RETURN QUERY
  SELECT id, url, created_at
  FROM photos
  WHERE baby_profile_id = p_baby_id
    AND deleted_at IS NULL
  ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 6.4 XSS Prevention

**Strategy**: Sanitize all user input, escape output

**Input Sanitization**:

```dart
// Example: Sanitize HTML in comments
String sanitizeHtml(String input) {
  return input
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;')
    .replaceAll('&', '&amp;');
}

// Use before storing or displaying
final sanitizedComment = sanitizeHtml(userComment);
```

**Output Escaping** (Flutter Text Widget):

- Flutter's Text widget automatically escapes HTML
- No additional escaping needed for plain text
- Use Text widget, not HtmlWidget for user content

---

## 7. Rate Limiting & Abuse Prevention

### 7.1 Rate Limiting Strategy

**Supabase Auth Rate Limits** (Enforced):

- Login attempts: 5 per 15 minutes per email
- Signup requests: 10 per hour per IP
- Password reset: 3 per hour per email
- Email verification resend: 5 per hour per email

**Custom Rate Limits** (Edge Functions):

| Operation | Limit | Window | Scope |
|-----------|-------|--------|-------|
| Photo upload | 50 | per day | per user |
| Comment creation | 20 | per hour | per user |
| Event creation | 10 | per day | per baby profile |
| Invitation send | 10 | per hour | per user |
| Registry item creation | 20 | per day | per baby profile |

**Implementation** (Edge Function):

```typescript
// Example: Rate limiting in Edge Function
import { RateLimiter } from 'rate-limiter';

const limiter = new RateLimiter({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 20, // 20 requests per hour
  keyGenerator: (req) => {
    // Rate limit per user
    const token = req.headers.get('Authorization')?.split(' ')[1];
    const payload = decodeJwt(token);
    return payload.sub; // user_id
  },
});

async function createComment(req: Request): Promise<Response> {
  // Check rate limit
  const rateLimitResult = await limiter.check(req);
  if (!rateLimitResult.allowed) {
    return new Response(
      JSON.stringify({
        error: 'Rate limit exceeded',
        retryAfter: rateLimitResult.retryAfter,
      }),
      { status: 429 }
    );
  }
  
  // Process request
  // ...
}
```

### 7.2 Abuse Prevention Measures

**1. CAPTCHA** (Future Enhancement):

- Implement on signup and login after failed attempts
- Use hCaptcha or reCAPTCHA v3
- Minimize user friction

**2. Email Verification**:

- Prevents disposable email signups
- Limits access until verified

**3. Invitation Expiry**:

- 7-day expiration prevents old invitations from being used
- Forces re-invitation for security

**4. Content Moderation** (Future):

- Automated flagging of inappropriate content
- Owner can report/remove inappropriate comments
- Manual review for flagged content

**5. IP Blocking** (Future):

- Block IPs with repeated abuse patterns
- Geo-blocking for high-risk regions (if needed)

---

## 8. Monitoring & Incident Response

### 8.1 Security Monitoring

**Monitoring Tools**:

1. **Sentry**: Error tracking, performance monitoring
2. **Supabase Dashboard**: Database metrics, query performance
3. **Edge Function Logs**: Structured logs with correlation IDs
4. **OneSignal Dashboard**: Notification delivery metrics

**Security Alerts**:

| Alert | Trigger | Action |
|-------|---------|--------|
| Failed login spike | > 100 failed logins/minute | Investigate, potentially block IP |
| RLS policy violation attempt | Any RLS error | Log, review policies |
| Unusual data access pattern | User accessing > 10 baby profiles/minute | Investigate, potential account compromise |
| Mass photo deletion | > 50 photos deleted in 1 hour | Alert owner, potential ransomware |
| Rate limit exceeded repeatedly | Same user hits limit > 5 times/day | Review user activity |

**Implementation**:

```typescript
// Example: Security event logging
function logSecurityEvent(event: SecurityEvent) {
  Sentry.captureMessage('Security Event', {
    level: 'warning',
    tags: {
      event_type: event.type,
      user_id: event.userId,
      ip_address: event.ip,
    },
    extra: {
      details: event.details,
      timestamp: event.timestamp,
    },
  });
}

// Usage
logSecurityEvent({
  type: 'rls_policy_violation',
  userId: 'user123',
  ip: '192.168.1.1',
  details: {
    table: 'photos',
    operation: 'SELECT',
    policy_name: 'Followers can read photos',
  },
  timestamp: new Date(),
});
```

### 8.2 Incident Response Plan

**Incident Categories**:

1. **Data Breach**: Unauthorized access to user data
2. **Service Disruption**: App downtime or degraded performance
3. **Security Vulnerability**: Discovered vulnerability requiring patching
4. **Abuse**: Spam, harassment, or inappropriate content

**Response Procedures**:

**1. Detection**:
- Automated alerts via Sentry, Supabase
- User reports via support channel
- Security audit findings

**2. Assessment**:
- Severity rating (Critical, High, Medium, Low)
- Impact analysis (number of users, data types)
- Root cause identification

**3. Containment**:
- Isolate affected systems
- Revoke compromised credentials
- Block abusive IPs/users

**4. Eradication**:
- Patch vulnerability
- Remove malicious content
- Reset affected accounts

**5. Recovery**:
- Restore service
- Verify data integrity
- Monitor for recurrence

**6. Communication**:
- Notify affected users (email)
- Update status page
- Prepare incident report
- Report to authorities if required (GDPR breach notification within 72 hours)

**7. Post-Mortem**:
- Document incident timeline
- Identify lessons learned
- Implement preventive measures
- Update runbooks

**Incident Response Team**:

- Incident Commander: Product Owner
- Technical Lead: Backend Engineer
- Security Lead: Security Engineer (or external consultant)
- Communications Lead: Marketing/PR

### 8.3 Audit Logging

**Purpose**: Track security-relevant events for forensics and compliance

**Logged Events**:

1. **Authentication Events**:
   - Login success/failure
   - Logout
   - Password change
   - Password reset request
   - Email verification

2. **Authorization Events**:
   - RLS policy violations
   - Unauthorized access attempts
   - Permission changes (role changes)

3. **Data Access Events**:
   - Photo uploads/deletes
   - Event creation/deletion
   - Invitation creation
   - Follower addition/removal

4. **Configuration Changes**:
   - API key rotation
   - RLS policy changes
   - Rate limit adjustments

**Audit Log Storage**:

- Stored in separate `audit_logs` table
- Retention: 1 year (compliance requirement)
- Indexed for fast querying
- Accessible only to admins

**Audit Log Schema**:

```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT NOT NULL,
  user_id UUID REFERENCES auth.users(id),
  baby_profile_id UUID REFERENCES baby_profiles(id),
  action TEXT NOT NULL,
  resource_type TEXT,
  resource_id UUID,
  ip_address INET,
  user_agent TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast querying
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
```

---

## 9. Security Testing & Validation

### 9.1 Security Testing Strategy

**1. Static Analysis**:
- **Tool**: Flutter analyzer with security rules
- **Frequency**: On every commit (CI/CD)
- **Scope**: Code quality, potential vulnerabilities

**2. Dependency Scanning**:
- **Tool**: Dependabot, Snyk
- **Frequency**: Weekly, on dependency updates
- **Scope**: Known vulnerabilities in dependencies

**3. RLS Policy Testing**:
- **Tool**: pgTAP (PostgreSQL unit testing)
- **Frequency**: On every database migration
- **Scope**: All RLS policies, all roles, all operations

**4. Penetration Testing**:
- **Tool**: External security consultant
- **Frequency**: Annually, before major releases
- **Scope**: Full application security assessment

**5. Vulnerability Scanning**:
- **Tool**: OWASP ZAP, Burp Suite
- **Frequency**: Quarterly
- **Scope**: API endpoints, authentication flows

### 9.2 Security Testing Checklist

**Authentication Testing**:
- [ ] Test password strength enforcement
- [ ] Test login rate limiting
- [ ] Test password reset flow
- [ ] Test email verification requirement
- [ ] Test OAuth flow (Google, Facebook)
- [ ] Test JWT token expiry and refresh
- [ ] Test session invalidation on logout

**Authorization Testing**:
- [ ] Test owner can CRUD their content
- [ ] Test follower cannot modify owner content
- [ ] Test follower can interact (comment, RSVP, purchase)
- [ ] Test removed follower loses access
- [ ] Test user cannot access unrelated baby profiles
- [ ] Test RLS policies block unauthorized access

**Data Security Testing**:
- [ ] Test encryption in transit (HTTPS only)
- [ ] Test secure token storage (Keychain/Keystore)
- [ ] Test photo URLs are signed and expiring
- [ ] Test soft delete prevents access
- [ ] Test data export functionality

**Input Validation Testing**:
- [ ] Test SQL injection prevention
- [ ] Test XSS prevention
- [ ] Test file upload validation (type, size)
- [ ] Test comment length validation
- [ ] Test email format validation

**Rate Limiting Testing**:
- [ ] Test login rate limit
- [ ] Test comment rate limit
- [ ] Test photo upload rate limit
- [ ] Test invitation rate limit

### 9.3 Compliance Testing

**GDPR Compliance Checklist**:
- [ ] Test data export functionality
- [ ] Test account deletion (soft delete)
- [ ] Test consent management UI
- [ ] Test opt-out of analytics
- [ ] Test data portability (JSON export)
- [ ] Verify privacy policy accessibility
- [ ] Verify data retention period enforcement

**CCPA Compliance Checklist**:
- [ ] Test "Do Not Sell" option (N/A for Nonna)
- [ ] Test data access request
- [ ] Test data deletion request
- [ ] Verify annual privacy disclosure

---

## 10. Security Architecture Validation

### 10.1 Requirements Alignment

| Security Requirement | Implementation | Status |
|---------------------|----------------|--------|
| AES-256 encryption at rest | Supabase/AWS encryption | ✅ |
| TLS 1.3 in transit | HTTPS, WSS with TLS 1.3 | ✅ |
| JWT authentication | Supabase Auth | ✅ |
| OAuth 2.0 support | Google, Facebook via Supabase | ✅ |
| Secure token storage | Keychain/Keystore | ✅ |
| Row-Level Security | PostgreSQL RLS policies | ✅ |
| Multi-tenant isolation | Baby profile tenant boundary | ✅ |
| Invite-only access | Invitation system with expiry | ✅ |
| 7-year data retention | Soft delete pattern | ✅ |
| GDPR compliance | Data export, deletion, consent | ✅ |
| CCPA compliance | Data access, deletion requests | ✅ |
| Rate limiting | Supabase Auth + Edge Functions | ✅ |
| Input validation | Client + server-side | ✅ |
| Audit logging | Audit logs table | ✅ |
| Security monitoring | Sentry integration | ✅ |

### 10.2 Security Posture Summary

**Strengths**:
- Multi-layer security with defense in depth
- Database-level authorization enforcement (RLS)
- Invite-only access model ensures privacy
- Comprehensive encryption (at rest and in transit)
- Compliance with GDPR and CCPA
- Regular security testing and monitoring

**Areas for Future Enhancement**:
- Certificate pinning for MITM prevention
- End-to-end encryption for photos
- CAPTCHA for bot prevention
- Biometric authentication for faster login
- Advanced threat detection with ML
- Bug bounty program for vulnerability disclosure

---

## 11. Conclusion

The Nonna App security and privacy architecture provides comprehensive protection for sensitive family data through multiple layers of security controls, strict authorization enforcement, and privacy-first design. Key strengths include:

**Security Highlights**:
- Database-level authorization with Row-Level Security
- JWT-based authentication with secure token storage
- AES-256 encryption at rest, TLS 1.3 in transit
- Multi-tenant isolation with baby profile boundaries
- Comprehensive input validation and sanitization
- Rate limiting and abuse prevention

**Privacy Highlights**:
- Invite-only access model (no public content)
- GDPR and CCPA compliant data controls
- User control over followers and content
- 7-year retention with soft delete
- Data export and deletion on request
- Transparent privacy policy

This security architecture ensures the Nonna App provides a safe, private, and trustworthy platform for families to share precious moments.

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Next Review**: Before Development Phase Begins  
**Approval Status**: Pending Security Team Review
