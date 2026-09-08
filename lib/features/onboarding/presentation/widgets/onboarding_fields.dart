import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nonna_app/core/themes/onboarding_theme.dart';

class OnboardingHeadline extends StatelessWidget {
  const OnboardingHeadline(this.text, {super.key, this.textAlign});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.baloo2(
        fontSize: OnboardingMetrics.headlineSize,
        fontWeight: FontWeight.w700,
        color: OnboardingColors.text,
        height: 1.15,
      ),
    );
  }
}

class OnboardingSupportText extends StatelessWidget {
  const OnboardingSupportText(this.text, {super.key, this.textAlign});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.inter(
        fontSize: OnboardingMetrics.supportTextSize,
        color: OnboardingColors.muted,
        height: 1.45,
      ),
    );
  }
}

class OnboardingTextField extends StatelessWidget {
  const OnboardingTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.readOnly = false,
    this.onChanged,
    this.validator,
    this.onFieldSubmitted,
    this.textInputAction,
    this.fieldKey,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: OnboardingColors.text,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Semantics(
          label: label,
          textField: label != null,
          child: TextFormField(
            key: fieldKey,
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onChanged: onChanged,
            validator: validator,
            onFieldSubmitted: onFieldSubmitted,
            textInputAction: textInputAction,
            style: GoogleFonts.inter(
              fontSize: OnboardingMetrics.supportTextSize,
              color: OnboardingColors.text,
            ),
            decoration: InputDecoration(hintText: hint),
          ),
        ),
      ],
    );
  }
}

class OnboardingPasswordField extends StatefulWidget {
  const OnboardingPasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.hint = 'Create a password',
    this.validator,
    this.onFieldSubmitted,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final Key? fieldKey;

  @override
  State<OnboardingPasswordField> createState() =>
      _OnboardingPasswordFieldState();
}

class _OnboardingPasswordFieldState extends State<OnboardingPasswordField> {
  var _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: OnboardingColors.text,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: widget.fieldKey,
          controller: widget.controller,
          obscureText: _obscure,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          textInputAction: TextInputAction.done,
          style: GoogleFonts.inter(
            fontSize: OnboardingMetrics.supportTextSize,
            color: OnboardingColors.text,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: OnboardingColors.muted,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingDivider extends StatelessWidget {
  const OnboardingDivider({super.key, this.label = 'or sign up with email'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          const Expanded(child: Divider(color: OnboardingColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: OnboardingColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider(color: OnboardingColors.border)),
        ],
      ),
    );
  }
}

class OnboardingHelperText extends StatelessWidget {
  const OnboardingHelperText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        color: OnboardingColors.muted,
        height: 1.4,
      ),
    );
  }
}

class OnboardingDatePickerField extends StatelessWidget {
  const OnboardingDatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final display = value == null
        ? placeholder
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: OnboardingColors.text,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: OnboardingColors.border),
              borderRadius:
                  BorderRadius.circular(OnboardingMetrics.fieldRadius),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    display,
                    style: GoogleFonts.inter(
                      fontSize: OnboardingMetrics.supportTextSize,
                      color: value == null
                          ? OnboardingColors.muted
                          : OnboardingColors.text,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: OnboardingColors.muted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingBottomLink extends StatelessWidget {
  const OnboardingBottomLink({
    super.key,
    required this.prefix,
    required this.actionLabel,
    required this.onTap,
    this.actionKey,
  });

  final String prefix;
  final String actionLabel;
  final VoidCallback onTap;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: GestureDetector(
        key: actionKey,
        onTap: onTap,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 14,
              color: OnboardingColors.muted,
            ),
            children: [
              TextSpan(text: prefix),
              TextSpan(
                text: actionLabel,
                style: const TextStyle(
                  color: OnboardingColors.sageDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
