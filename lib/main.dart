import 'package:firebase_core/firebase_core.dart';
import 'package:fiwe/firebase_options.dart';
import 'package:fiwe/src/views/login/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FiweApp());
}

class FiweApp extends StatelessWidget {
  const FiweApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashView(),
    );
  }
}
