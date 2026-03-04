import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:vibely/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vibely',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

