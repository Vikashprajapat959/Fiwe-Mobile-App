import 'package:fiwe/src/utils/colors.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final int? maxLength;

  const AppTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    var outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    );
    return TextFormField(
      maxLength: maxLength,
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      obscureText: obscureText,
      maxLines: maxLines,
      textCapitalization: textCapitalization,

      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF2D3748),
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 16,
          color: Color(0xFF9CA3AF),
          fontWeight: FontWeight.w400,
        ),
        fillColor: AppColors.background,
        filled: true,
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF6B7280), size: 20),
        counter: const SizedBox.shrink(),
        border: outlineInputBorder,
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        errorBorder: outlineInputBorder.copyWith(
          borderSide: BorderSide(color: AppColors.errorBorder),
        ),
        focusedErrorBorder: outlineInputBorder.copyWith(
          borderSide: BorderSide(color: AppColors.errorBorder),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        constraints: const BoxConstraints(minHeight: 44),
      ),
    );
  }
}
