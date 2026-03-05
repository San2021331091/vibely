import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:vibely/controller/authentication_controller.dart';
import 'package:vibely/authentication/supabase_auth.dart';
import 'package:vibely/app.dart';

Future<void> main() async {
  
   WidgetsFlutterBinding.ensureInitialized();

  // Load .env before using Supabase
  await dotenv.load(fileName: ".env");
    // Register the AuthenticationController
  Get.put(AuthenticationController());

  try {
    await SupabaseAuth.initialize();
    runApp(const MyApp());
  } on FileSystemException catch (e) {
     debugPrint(e.toString());
  }
}

