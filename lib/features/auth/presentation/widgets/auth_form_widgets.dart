import 'package:flutter/material.dart';
import 'package:nonna_app/core/themes/colors.dart';

/// Reusable authentication form widgets
///
/// **Functional Requirements**: Section 3.6.1 - Authentication Screens
/// Reference: docs/Core_development_component_identification.md
///
/// Provides:
/// - AuthEmailField - email input with validation
/// - AuthPasswordField - password input with visibility toggle and validation
/// - AuthNameField - display name input with validation
/// - AuthPrimaryButton - primary action button with loading state
/// - AuthSecondaryButton - outlined secondary button
/// - AuthDivider - "OR" divider
/// - GoogleSignInButton - Google OAuth button
/// - FacebookSignInButton - Facebook OAuth button
/// - AuthErrorMessage - styled error banner

// ============================================================
// Validators
// ============================================================

/// Validates an email address string.
/// Returns null if valid, otherwise returns an error message.
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Enter a valid email address';
  }
  return null;
}

/// Validates a password string.
/// Returns null if valid, otherwise returns an error message.
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  return null;
}

/// Validates a display name string.
/// Returns null if valid, otherwise returns an error message.
String? validateDisplayName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Name is required';
  }
  if (value.trim().length < 2) {
    return 'Name must be at least 2 characters';
  }
  return null;
}

/// Validates that two passwords match.
String? validatePasswordConfirm(String? value, String? original) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }
  if (value != original) {
    return 'Passwords do not match';
  }
  return null;
}

// ============================================================
// Input Fields
// ============================================================

/// Email text field with built-in validation.
class AuthEmailField extends StatelessWidget {
  const AuthEmailField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onSubmitted,
    this.focusNode,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('auth_email_field'),
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction:
          onSubmitted != null ? TextInputAction.next : TextInputAction.done,
      autocorrect: false,
      onFieldSubmitted: onSubmitted,
      validator: validateEmail,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: Icon(Icons.email_outlined),
      ),
    );
  }
}

/// Password text field with visibility toggle and validation.
class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.labelText = 'Password',
    this.hintText = 'Enter your password',
    this.validator,
    this.onSubmitted,
    this.focusNode,
    this.fieldKey,
  });

  final TextEditingController controller;
  final bool enabled;
  final String labelText;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final Key? fieldKey;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey ?? const Key('auth_password_field'),
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      obscureText: _obscure,
      textInputAction: widget.onSubmitted != null
          ? TextInputAction.done
          : TextInputAction.next,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator ?? validatePassword,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          key: const Key('password_visibility_toggle'),
          icon:
              Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
          tooltip: _obscure ? 'Show password' : 'Hide password',
        ),
      ),
    );
  }
}

/// Display name text field with validation.
class AuthNameField extends StatelessWidget {
  const AuthNameField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onSubmitted,
    this.focusNode,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('auth_name_field'),
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      textInputAction:
          onSubmitted != null ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: onSubmitted,
      validator: validateDisplayName,
      decoration: const InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter your name',
        prefixIcon: Icon(Icons.person_outlined),
      ),
    );
  }
}

// ============================================================
// Buttons
// ============================================================

/// Primary full-width button for auth actions, with optional loading state.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.buttonKey,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        key: buttonKey ?? Key('auth_primary_button_$label'),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Outlined secondary button for auth actions.
class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        key: Key('auth_secondary_button_$label'),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

// ============================================================
// OAuth Buttons
// ============================================================

/// Google sign-in button.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Continue with Google',
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        key: const Key('google_sign_in_button'),
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
        label: Text(label),
      ),
    );
  }
}

/// Facebook sign-in button.
class FacebookSignInButton extends StatelessWidget {
  const FacebookSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Continue with Facebook',
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        key: const Key('facebook_sign_in_button'),
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.facebook, size: 24, color: Color(0xFF1877F2)),
        label: Text(label),
      ),
    );
  }
}

// ============================================================
// Divider
// ============================================================

/// Horizontal divider with a centred "OR" label, used between email and OAuth sections.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

// ============================================================
// Error / Info Banners
// ============================================================

/// Styled error banner displayed below the form.
class AuthErrorMessage extends StatelessWidget {
  const AuthErrorMessage({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('auth_error_message'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
