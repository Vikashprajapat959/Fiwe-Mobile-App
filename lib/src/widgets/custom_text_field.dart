import 'package:fiwe/src/utils/colors.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final ValueChanged<String>? onChanged; // Add this line
  final BorderSide? borderSide;
  final String? lableText;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.borderSide,
    this.lableText,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (lableText != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lableText!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildTextField(),
        ],
      );
    }
    return _buildTextField();
  }

  TextFormField _buildTextField() {
    var outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: borderSide ?? BorderSide.none,
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
      onChanged: onChanged, 
      style: const TextStyle(fontSize: 16, color: Color(0xFF2D3748), fontWeight: FontWeight.w400),
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400),
        fillColor: AppColors.background,
        filled: true,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF6B7280), size: 20) : null,
        counter: const SizedBox.shrink(),
        
        border: outlineInputBorder,
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        errorBorder: outlineInputBorder.copyWith(borderSide: BorderSide(color: AppColors.errorBorder)),
        focusedErrorBorder: outlineInputBorder.copyWith(borderSide: BorderSide(color: AppColors.errorBorder)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        constraints: const BoxConstraints(minHeight: 44),
      ),
    );
  }
}
