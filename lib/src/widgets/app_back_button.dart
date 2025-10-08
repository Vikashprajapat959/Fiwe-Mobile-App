import 'package:flutter/material.dart';

enum BackButtonTheme { light, dark }

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.theme});
  final BackButtonTheme theme;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme == BackButtonTheme.light ? Colors.white.withAlpha(125) : Colors.black.withAlpha(125),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: theme == BackButtonTheme.light ? Colors.white : Colors.black,
        ),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
