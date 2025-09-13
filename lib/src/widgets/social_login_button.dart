import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SocialLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final String title;
  final Widget icon;
  final Color? titleColor;

  final double? height;
  final double borderRadius;

  const SocialLoginButton({
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    required this.title,
    required this.icon,
    this.titleColor = Colors.white,
    this.height = 54,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.8,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
