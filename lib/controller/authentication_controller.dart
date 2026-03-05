import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibely/authentication/supabase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibely/screens/home_screen.dart';
import 'package:vibely/screens/login_screen.dart';
import 'package:vibely/utils/img_upload.dart';

class AuthenticationController extends GetxController {
  static AuthenticationController instanceAuth = Get.find();

  final Rx<File?> _pickedFile = Rx<File?>(null);
  File? get profileImage => _pickedFile.value;

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  // ====================== IMAGE PICKERS ======================
  Future<void> chooseImageFromGallery() async {
    final pickedImageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImageFile != null) {
      _pickedFile.value = File(pickedImageFile.path);
      Get.snackbar(
        "Profile Image",
        "You have successfully selected your profile image from gallery",
      );
    }
  }
void checkUserLoggedIn() {
  final user = SupabaseAuth.supabase.auth.currentUser;

  if (user != null) {
    Get.offAll(() => const HomeScreen());
  } else {
    Get.offAll(() => const LoginScreen());
  }
}
  Future<void> captureImageWithCamera() async {
    final pickedImageFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (pickedImageFile != null) {
      _pickedFile.value = File(pickedImageFile.path);
      Get.snackbar(
        "Profile Image",
        "You have successfully captured your profile image with the camera",
      );
    }
  }

  // ====================== TOGGLE PASSWORD VISIBILITY ======================
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // ====================== LOGIN ======================
  Future<void> login({required String email, required String password}) async {
    isLoading.value = true;
    try {
      final response = await SupabaseAuth.supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = response.user;
      if (user == null) throw Exception("Login failed");

      // Check if profile exists
      final existingUser = await SupabaseAuth.supabase
          .from('users')
          .select()
          .eq('uid', user.id)
          .maybeSingle();

      if (existingUser == null) {
        await SupabaseAuth.supabase.from('users').insert({
          'uid': user.id,
          'name': "New User",
          'email': user.email,
          'image': null,
        });
      }

      Get.snackbar(
        "Success",
        "Login successful",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAll(() => const HomeScreen());
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ====================== LOGOUT ======================
  Future<void> logout() async {
    try {
      await SupabaseAuth.supabase.auth.signOut();
      Get.offAll(() => const LoginScreen());
      Get.snackbar("Logged out", "You have been logged out");
    } catch (e) {
      Get.snackbar("Error", "Logout failed: ${e.toString()}");
    }
  }

  // ====================== REGISTER / SIGN UP ======================
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;

    try {
      // Sign up user with Supabase
      final authResponse = await SupabaseAuth.signUp(
        email: email.trim(),
        password: password.trim(),
      );

      final supabaseUser = authResponse.user;
      if (supabaseUser == null) throw Exception("Sign up failed");

      // Upload profile image if selected
      String? imageUrl;
      if (profileImage != null) {
        imageUrl = await uploadImageToImgBB(profileImage!);
      }

      Get.snackbar(
        "Success",
        "You have successfully signed up.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to LoginScreen with optional info
      Get.offAll(
        () => LoginScreen(name: name, email: email, imageUrl: imageUrl),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
