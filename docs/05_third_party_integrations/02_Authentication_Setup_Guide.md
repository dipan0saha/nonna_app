# Authentication Setup Guide

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Team  
**Status**: Configuration Guide  
**Section**: 2.3 - Third-Party Integrations Setup

## Executive Summary

This document provides comprehensive guidance for setting up and configuring authentication for the Nonna App using Supabase Auth. It covers email/password authentication, OAuth providers (Google, Facebook), email verification, password reset flows, session management, and security best practices. Supabase Auth provides secure, scalable authentication with built-in JWT token management and Row-Level Security integration.

## References

This document is informed by:

- `docs/01_technical_requirements/api_integration_plan.md` - Authentication integration strategy
- `docs/02_architecture_design/security_privacy_architecture.md` - Authentication security requirements
- `docs/05_third_party_integrations/01_Supabase_Project_Configuration.md` - Supabase project setup
- `docs/Production_Readiness_Checklist.md` - Section 2.3 requirements

---

## 1. Supabase Auth Overview

### 1.1 Authentication Architecture

**Supabase Auth Features**:

- **Email/Password Authentication**: Traditional signup/login with email verification
- **OAuth 2.0 Providers**: Social login with Google, Facebook, GitHub, etc.
- **Magic Links**: Passwordless authentication via email (optional)
- **JWT Tokens**: JSON Web Tokens for stateless authentication
- **Session Management**: Automatic token refresh and session persistence
- **Row-Level Security Integration**: JWT claims used in database RLS policies
- **Multi-Factor Authentication**: Optional 2FA/MFA (future enhancement)

**Authentication Flow**:

```
┌─────────────┐
│  User Opens │
│  Nonna App  │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ Check Existing      │
│ Session/Token       │
└──────┬──────────────┘
       │
       ├─ No Session ──────────┐
       │                       │
       ▼                       ▼
┌──────────────┐      ┌────────────────┐
│ Login/Signup │      │  OAuth Login   │
│   Screen     │      │  (Google/FB)   │
└──────┬───────┘      └────────┬───────┘
       │                       │
       ▼                       ▼
┌──────────────────────────────────┐
│ Supabase Auth Validates          │
│ - Email/Password or OAuth Token  │
│ - Issues JWT Access Token        │
│ - Creates Session                │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────┐
│ Store JWT Token      │
│ Securely (Keychain)  │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ Navigate to Home     │
│ (Authenticated)      │
└──────────────────────┘
```

### 1.2 Prerequisites

Before configuring authentication:

- [ ] Supabase project created and configured (see `01_Supabase_Project_Configuration.md`)
- [ ] Flutter project initialized with dependencies:
  - `supabase_flutter: ^2.0.0`
  - `flutter_secure_storage: ^9.0.0` (for secure token storage)
  - `google_sign_in: ^6.0.0` (for Google OAuth)
  - `flutter_facebook_auth: ^6.0.0` (for Facebook OAuth)
- [ ] Google Cloud Console project created (for Google OAuth)
- [ ] Facebook App created (for Facebook OAuth)

---

## 2. Email/Password Authentication

### 2.1 Configure Email/Password Auth

**Step 1: Enable Email/Password in Supabase**

Email/Password authentication is enabled by default in Supabase. Verify settings:

1. Navigate to Authentication → Settings
2. Verify "Enable Email Provider" is ON
3. Configure email settings:
   - **Enable Email Confirmations**: ON (recommended for security)
   - **Secure Email Change**: ON (require re-authentication for email changes)
   - **Password Requirements**:
     - Minimum length: 6 characters
     - Require at least one number or special character

**Step 2: Configure Email Templates**

Navigate to Authentication → Email Templates and customize:

1. **Confirm signup** (Email Verification):
   
   ```html
   <h2>Confirm your signup</h2>
   <p>Follow this link to confirm your email address for Nonna:</p>
   <p><a href="{{ .ConfirmationURL }}">Confirm your email</a></p>
   ```

2. **Invite user** (Optional, for invite-only signup):
   
   ```html
   <h2>You've been invited to Nonna</h2>
   <p>You've been invited to join Nonna. Follow this link to accept the invite:</p>
   <p><a href="{{ .ConfirmationURL }}">Accept invite</a></p>
   ```

3. **Magic Link** (Optional, for passwordless login):
   
   ```html
   <h2>Your Nonna Magic Link</h2>
   <p>Click this link to sign in to Nonna:</p>
   <p><a href="{{ .ConfirmationURL }}">Sign In</a></p>
   ```

4. **Change Email Address**:
   
   ```html
   <h2>Confirm Change of Email</h2>
   <p>Follow this link to confirm your new email address:</p>
   <p><a href="{{ .ConfirmationURL }}">Confirm new email</a></p>
   ```

5. **Reset Password**:
   
   ```html
   <h2>Reset Your Password</h2>
   <p>Follow this link to reset your Nonna password:</p>
   <p><a href="{{ .ConfirmationURL }}">Reset password</a></p>
   ```

**Step 3: Configure Email Provider (SendGrid)**

For production, configure custom SMTP server (SendGrid):

1. Navigate to Project Settings → Authentication → Email
2. Select "Custom SMTP" (instead of Supabase default)
3. Enter SendGrid SMTP credentials:
   - **Host**: `smtp.sendgrid.net`
   - **Port**: `587` (or `465` for SSL)
   - **Username**: `apikey`
   - **Password**: Your SendGrid API key
   - **Sender Email**: `noreply@nonna.app`
   - **Sender Name**: `Nonna App`
4. Click "Save"
5. Send test email to verify configuration

### 2.2 Implement Signup Flow

**Flutter Implementation**:

```dart
// lib/features/auth/presentation/pages/signup_screen.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'display_name': _displayNameController.text.trim(),
        },
      );

      if (response.user != null) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sign up successful! Please check your email to verify your account.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to email verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(email: _emailController.text),
          ),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(labelText: 'Display Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.length > 50) {
                    return 'Name must be 50 characters or less';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  final hasNumberOrSpecial = RegExp(r'[0-9!@#\$&*~]').hasMatch(value);
                  if (!hasNumberOrSpecial) {
                    return 'Password must contain at least one number or special character';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Sign Up'),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                ),
                child: Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2.3 Implement Login Flow

**Flutter Implementation**:

```dart
// lib/features/auth/presentation/pages/login_screen.dart

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Check if email is verified
        if (response.user!.emailConfirmedAt == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please verify your email before logging in'),
              backgroundColor: Colors.orange,
            ),
          );
          
          // Navigate to email verification screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => EmailVerificationScreen(email: _emailController.text),
            ),
          );
          return;
        }

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Log In'),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                ),
                child: Text('Forgot password?'),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => SignupScreen()),
                ),
                child: Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2.4 Email Verification Flow

**Flutter Implementation**:

```dart
// lib/features/auth/presentation/pages/email_verification_screen.dart

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email sent! Please check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email, size: 80, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              'Verify your email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'We sent a verification link to:',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              widget.email,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Text(
              'Click the link in the email to verify your account. You may need to check your spam folder.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isResending ? null : _resendVerificationEmail,
              child: _isResending
                  ? CircularProgressIndicator()
                  : Text('Resend Verification Email'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              ),
              child: Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Handle Email Verification Callback**:

Configure deep link handling for email verification:

```dart
// lib/main.dart

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _handleAuthStateChanges();
  }

  void _handleAuthStateChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        // User signed in successfully
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else if (event == AuthChangeEvent.signedOut) {
        // User signed out
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nonna App',
      home: SplashScreen(), // Check auth state on app start
    );
  }
}
```

### 2.5 Password Reset Flow

**Flutter Implementation**:

```dart
// lib/features/auth/presentation/pages/forgot_password_screen.dart

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        redirectTo: 'io.supabase.nonna://reset-password',
      );

      setState(() => _emailSent = true);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_emailSent) {
      return Scaffold(
        appBar: AppBar(title: Text('Reset Password')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green),
              SizedBox(height: 24),
              Text(
                'Check your email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'We sent a password reset link to ${_emailController.text}',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                ),
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Send Reset Link'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Reset Password Screen** (after clicking email link):

```dart
// lib/features/auth/presentation/pages/reset_password_screen.dart

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter your new password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 3. OAuth Authentication (Google & Facebook)

### 3.1 Google OAuth Setup

**Step 1: Create Google Cloud Console Project**

1. Navigate to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project: "Nonna App"
3. Enable "Google+ API" (for profile information)

**Step 2: Create OAuth 2.0 Credentials**

1. Navigate to APIs & Services → Credentials
2. Click "Create Credentials" → "OAuth 2.0 Client ID"
3. Configure OAuth consent screen:
   - App name: "Nonna App"
   - User support email: your@email.com
   - App logo: Upload Nonna logo
   - Authorized domains: `nonna.app`
   - Developer contact: your@email.com
4. Save consent screen

**Step 3: Create OAuth Client IDs**

Create separate client IDs for each platform:

**Android**:
1. Application type: Android
2. Package name: `com.nonna.app` (from `android/app/build.gradle`)
3. SHA-1 certificate fingerprint:
   ```bash
   # Get debug SHA-1
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # Get release SHA-1 (after generating release key)
   keytool -list -v -keystore android/app/release.keystore
   ```
4. Click "Create"
5. Copy Client ID

**iOS**:
1. Application type: iOS
2. Bundle ID: `com.nonna.app` (from `ios/Runner.xcodeproj`)
3. Click "Create"
4. Copy Client ID and iOS URL scheme

**Web** (Optional, for web app):
1. Application type: Web application
2. Authorized JavaScript origins: `https://nonna.app`
3. Authorized redirect URIs: `https://nonna.app/auth/callback`
4. Click "Create"
5. Copy Client ID

**Step 4: Configure Supabase for Google OAuth**

1. Navigate to Supabase Dashboard → Authentication → Providers
2. Enable "Google"
3. Enter Google Client ID (Web client ID)
4. Enter Google Client Secret (from Google Cloud Console)
5. Configure redirect URL: `https://[your-project-ref].supabase.co/auth/v1/callback`
6. Save configuration

**Step 5: Implement Google Sign-In in Flutter**

Install dependency:

```yaml
# pubspec.yaml
dependencies:
  google_sign_in: ^6.0.0
```

```dart
// lib/features/auth/presentation/pages/login_screen.dart

import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '[YOUR_WEB_CLIENT_ID].apps.googleusercontent.com', // Web client ID
  );

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled sign-in
        return;
      }

      // Obtain Google Auth credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Sign in to Supabase with Google token
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ... existing email/password fields ...
            
            SizedBox(height: 24),
            Text('OR', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            
            // Google Sign-In Button
            ElevatedButton.icon(
              onPressed: () => _signInWithGoogle(context),
              icon: Image.asset('assets/images/google_logo.png', height: 24),
              label: Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3.2 Facebook OAuth Setup

**Step 1: Create Facebook App**

1. Navigate to [Facebook Developers](https://developers.facebook.com/)
2. Click "My Apps" → "Create App"
3. Choose "Consumer" use case
4. App Display Name: "Nonna App"
5. App Contact Email: your@email.com
6. Click "Create App"

**Step 2: Add Facebook Login Product**

1. From app dashboard, click "Add Product"
2. Find "Facebook Login" and click "Set Up"
3. Choose platform: iOS, Android, or Web

**Step 3: Configure Facebook Login Settings**

1. Navigate to Facebook Login → Settings
2. Add OAuth redirect URI:
   - `https://[your-project-ref].supabase.co/auth/v1/callback`
3. Valid OAuth Redirect URIs (for web):
   - `https://nonna.app/auth/callback`
4. Save changes

**Step 4: Get Facebook App Credentials**

1. Navigate to Settings → Basic
2. Copy "App ID"
3. Show and copy "App Secret"

**Step 5: Configure iOS and Android**

**iOS**:
1. Navigate to Facebook Login → Settings → iOS
2. Bundle ID: `com.nonna.app`
3. Enable "Single Sign-On"
4. Configure `Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>fb[APP_ID]</string>
       </array>
     </dict>
   </array>
   <key>FacebookAppID</key>
   <string>[APP_ID]</string>
   <key>FacebookDisplayName</key>
   <string>Nonna App</string>
   ```

**Android**:
1. Navigate to Facebook Login → Settings → Android
2. Package Name: `com.nonna.app`
3. Default Activity Class Name: `com.nonna.app.MainActivity`
4. Key Hash:
   ```bash
   keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
   ```
5. Enable "Single Sign-On"
6. Configure `AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.facebook.sdk.ApplicationId"
       android:value="@string/facebook_app_id"/>
   ```

**Step 6: Configure Supabase for Facebook OAuth**

1. Navigate to Supabase Dashboard → Authentication → Providers
2. Enable "Facebook"
3. Enter Facebook App ID
4. Enter Facebook App Secret
5. Save configuration

**Step 7: Implement Facebook Sign-In in Flutter**

Install dependency:

```yaml
# pubspec.yaml
dependencies:
  flutter_facebook_auth: ^6.0.0
```

```dart
// lib/features/auth/presentation/pages/login_screen.dart

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginScreen extends StatelessWidget {
  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      // Trigger Facebook Sign-In flow
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        // User cancelled or error occurred
        return;
      }

      // Get Facebook access token
      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) return;

      // Sign in to Supabase with Facebook token
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: Provider.facebook,
        idToken: accessToken.token,
      );

      if (response.user != null) {
        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Facebook sign-in failed: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ... Google Sign-In button ...
            
            SizedBox(height: 12),
            
            // Facebook Sign-In Button
            ElevatedButton.icon(
              onPressed: () => _signInWithFacebook(context),
              icon: Icon(Icons.facebook, color: Colors.white),
              label: Text('Sign in with Facebook'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1877F2), // Facebook blue
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 4. Session Management

### 4.1 JWT Token Storage

**Secure Token Storage**:

Supabase Flutter SDK automatically stores tokens securely using `flutter_secure_storage`:
- **iOS**: Keychain with `kSecAttrAccessibleAfterFirstUnlock`
- **Android**: EncryptedSharedPreferences with Android Keystore

**Manual Token Storage** (if needed):

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

### 4.2 Auto Token Refresh

Supabase automatically refreshes tokens before expiration:

```dart
// Listen to auth state changes and token refresh
Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  final event = data.event;
  final session = data.session;

  if (event == AuthChangeEvent.tokenRefreshed) {
    print('Token refreshed: ${session?.accessToken}');
    // Token is automatically stored securely
  }
});
```

### 4.3 Check Authentication State

**On App Start**:

```dart
// lib/main.dart

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(Duration(seconds: 2)); // Show splash for 2 seconds

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // User is authenticated
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      // User not authenticated
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

### 4.4 Logout Implementation

```dart
// lib/features/auth/services/auth_service.dart

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signOut(BuildContext context) async {
    try {
      await _supabase.auth.signOut();

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false, // Remove all previous routes
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign out failed: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Usage in UI
ElevatedButton(
  onPressed: () => AuthService().signOut(context),
  child: Text('Sign Out'),
)
```

---

## 5. Security Best Practices

### 5.1 Password Security

**Enforce Strong Passwords**:

- Minimum 6 characters (configurable in Supabase)
- At least one number or special character
- No common passwords (e.g., "password123")

**Client-Side Validation**:

```dart
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a password';
  }
  
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  
  if (!RegExp(r'[0-9!@#\$&*~]').hasMatch(value)) {
    return 'Password must contain at least one number or special character';
  }
  
  // Check for common weak passwords
  final commonPasswords = ['password', '123456', 'qwerty', 'abc123'];
  if (commonPasswords.contains(value.toLowerCase())) {
    return 'Password is too common. Please choose a stronger password.';
  }
  
  return null;
}
```

### 5.2 Rate Limiting

**Supabase Auth Rate Limits** (automatically enforced):

- Login attempts: 5 per 15 minutes per email
- Signup requests: 10 per hour per IP
- Password reset: 3 per hour per email

**Handle Rate Limit Errors**:

```dart
try {
  await Supabase.instance.client.auth.signInWithPassword(
    email: email,
    password: password,
  );
} on AuthException catch (e) {
  if (e.message.contains('rate_limit')) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Too many attempts. Please try again later.'),
        backgroundColor: Colors.orange,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

### 5.3 Email Verification Requirement

**Restrict Unverified Users**:

```dart
Future<void> _signIn() async {
  final response = await Supabase.instance.client.auth.signInWithPassword(
    email: email,
    password: password,
  );

  if (response.user != null) {
    // Check if email is verified
    if (response.user!.emailConfirmedAt == null) {
      // Email not verified - restrict access
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please verify your email before logging in'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Optionally, sign out the user
      await Supabase.instance.client.auth.signOut();
      
      // Navigate to email verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: email),
        ),
      );
      return;
    }

    // Email verified - proceed to home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }
}
```

**Enforce in Database with RLS**:

```sql
-- Create RLS policy to restrict unverified users
CREATE POLICY "Restrict unverified users from creating baby profiles"
  ON baby_profiles
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND auth.users.email_confirmed_at IS NOT NULL
    )
  );
```

### 5.4 Secure Token Handling

**Best Practices**:

✅ **DO**:
- Use Supabase Flutter SDK (handles token storage automatically)
- Store tokens in Keychain (iOS) / Keystore (Android)
- Never log tokens in production
- Invalidate tokens on logout
- Handle token refresh automatically

❌ **DON'T**:
- Store tokens in SharedPreferences (unencrypted)
- Store tokens in plain text files
- Expose tokens in error messages
- Share tokens between users
- Hardcode tokens in source code

**Example - Token Logging (Development Only)**:

```dart
if (kDebugMode) {
  final session = Supabase.instance.client.auth.currentSession;
  print('Access Token: ${session?.accessToken}');
} else {
  // Never log tokens in production
}
```

---

## 6. Testing Authentication

### 6.1 Unit Tests

**Test Auth Service**:

```dart
// test/features/auth/services/auth_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late AuthService authService;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    authService = AuthService(supabase: mockSupabase);
  });

  group('AuthService', () {
    test('signUp should create user successfully', () async {
      // Arrange
      final email = 'test@example.com';
      final password = 'password123';
      final mockResponse = AuthResponse(
        user: User(id: 'user123', email: email),
      );
      
      when(() => mockAuth.signUp(
        email: email,
        password: password,
        data: any(named: 'data'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await authService.signUp(email, password, 'Test User');

      // Assert
      expect(result.user, isNotNull);
      expect(result.user!.email, email);
      verify(() => mockAuth.signUp(
        email: email,
        password: password,
        data: any(named: 'data'),
      )).called(1);
    });

    test('signIn should authenticate user successfully', () async {
      // Arrange
      final email = 'test@example.com';
      final password = 'password123';
      final mockResponse = AuthResponse(
        user: User(id: 'user123', email: email, emailConfirmedAt: DateTime.now()),
        session: Session(accessToken: 'token123'),
      );
      
      when(() => mockAuth.signInWithPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await authService.signIn(email, password);

      // Assert
      expect(result.user, isNotNull);
      expect(result.session, isNotNull);
    });

    test('signOut should sign out user', () async {
      // Arrange
      when(() => mockAuth.signOut()).thenAnswer((_) async => {});

      // Act
      await authService.signOut();

      // Assert
      verify(() => mockAuth.signOut()).called(1);
    });
  });
}
```

### 6.2 Integration Tests

**Test Full Authentication Flow**:

```dart
// integration_test/auth_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('User can sign up, verify email, and log in', (tester) async {
      // Start app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Navigate to sign up screen
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      // Fill in sign up form
      await tester.enterText(find.byKey(Key('display_name_field')), 'Test User');
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123!');
      
      // Submit sign up
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify email verification screen is shown
      expect(find.text('Verify your email'), findsOneWidget);
      
      // Note: Manual step - user must verify email via link in email
      
      // Navigate to login screen
      await tester.tap(find.text('Back to Login'));
      await tester.pumpAndSettle();

      // Log in with new account (assuming email is verified)
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123!');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      // Verify home screen is shown
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('User can reset password', (tester) async {
      // Start app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Tap forgot password
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      // Enter email
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Check your email'), findsOneWidget);
    });
  });
}
```

---

## 7. Troubleshooting

### 7.1 Common Issues

**Issue: "Invalid API key"**

Solutions:
- Verify `SUPABASE_ANON_KEY` is correct (no typos)
- Check for trailing/leading spaces in key
- Ensure project is active in Supabase dashboard
- Regenerate keys if needed (Project Settings → API)

**Issue: "Email not verified"**

Solutions:
- Check spam/junk folder for verification email
- Resend verification email via app
- Verify email template is configured correctly
- Check SMTP settings if using custom email provider

**Issue: "OAuth login not working"**

Solutions:
- Verify OAuth provider is enabled in Supabase dashboard
- Check OAuth credentials (Client ID, Client Secret) are correct
- Verify redirect URIs match exactly (case-sensitive)
- Test OAuth flow in browser first
- Check OAuth consent screen is configured correctly

**Issue: "Session expired" errors**

Solutions:
- Ensure auto token refresh is enabled (default in Supabase Flutter SDK)
- Check network connectivity
- Verify token expiry settings in Supabase Auth
- Manually refresh token if needed:
  ```dart
  await Supabase.instance.client.auth.refreshSession();
  ```

**Issue: "Too many requests" (rate limiting)**

Solutions:
- Wait for rate limit window to pass (15 minutes for login)
- Implement exponential backoff for retries
- Show clear error message to user
- Consider implementing CAPTCHA for repeated failures

---

## 8. Production Checklist

Before going to production:

- [ ] Email verification enabled and tested
- [ ] Password reset flow tested end-to-end
- [ ] OAuth providers (Google, Facebook) tested on all platforms (iOS, Android, Web)
- [ ] Custom SMTP server configured (SendGrid) for reliable email delivery
- [ ] Email templates customized with brand colors and logo
- [ ] Rate limiting tested (login attempts, signup, password reset)
- [ ] Token refresh working correctly
- [ ] Secure token storage verified (Keychain/Keystore)
- [ ] RLS policies restrict unverified users
- [ ] Authentication state persistence tested
- [ ] Logout flow working correctly
- [ ] Error handling for all auth scenarios
- [ ] Integration tests passing
- [ ] Security audit completed
- [ ] Performance benchmarks met (login < 2 seconds)
- [ ] Documentation reviewed and updated

---

## Conclusion

This Authentication Setup Guide provides comprehensive instructions for configuring secure authentication for the Nonna App using Supabase Auth. Following these steps ensures robust user authentication with email/password, OAuth providers (Google, Facebook), email verification, password reset, and secure session management.

**Key Takeaways**:

- Supabase Auth provides secure, scalable authentication with built-in JWT management
- Email verification is critical for security and should be required
- OAuth provides easier, more secure login experience
- Always use secure token storage (Keychain/Keystore)
- Test all authentication flows thoroughly before production

**Next Steps**:

- Review `03_Cloud_Storage_Configuration.md` for storage setup
- Review `04_Database_Setup_Document.md` for database and RLS policies
- Review `05_Push_Notification_Configuration.md` for push notifications

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Next Review**: Before Core Development Phase (Section 3.x)  
**Status**: Configuration Guide - Ready for Implementation
