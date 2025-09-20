import 'package:fiwe/src/utils/colors.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextStyle heading = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark);

  static const TextStyle subHeading = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textDark);

  static const TextStyle body = TextStyle(fontSize: 14, color: AppColors.textDark);

  static const TextStyle caption = TextStyle(fontSize: 12, color: AppColors.textSecondary);

  static const TextStyle number = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
}
