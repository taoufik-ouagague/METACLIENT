import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool? isLight;

  const GlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final light = isLight ?? (Theme.of(context).brightness == Brightness.light);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(
            color: light ? const Color(0xFF0F172A) : Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            hintStyle: TextStyle(
              color: light ? const Color(0xFF94A3B8) : Colors.white.withValues(alpha: 0.4),
              fontSize: 13.5,
            ),
            labelStyle: const TextStyle(
              color: AppTheme.primaryIcons,
              fontSize: 13,
            ),
            filled: true,
            fillColor: light ? Colors.white.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.06),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppTheme.primaryIcons, size: 20)
                : null,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: light ? const Color(0xFFE2E8F0) : Colors.white.withValues(alpha: 0.18),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: light ? const Color(0xFFE2E8F0) : Colors.white.withValues(alpha: 0.18),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.primaryIcons,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.statusDanger,
                width: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
