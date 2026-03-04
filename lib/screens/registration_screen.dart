import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:vibely/authentication/authentication_controller.dart';
import 'package:vibely/screens/login_screen.dart';
import 'package:vibely/utils/img_upload.dart';
import 'package:vibely/widgets/input_text_widget.dart';
import 'package:vibely/models/user.dart';
import 'package:vibely/authentication/supabase_auth.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameTextEditingController =
      TextEditingController();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController passWordTextEditingController =
      TextEditingController();

  bool showProgressBar = false;
  bool obscurePassword = true;

  final authenticationController = AuthenticationController.instanceAuth;

  // ================= VALIDATORS =================

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Username is required";
    }
    if (value.trim().length < 3) {
      return "Minimum 3 characters required";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter valid email";
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }

    if (!RegExp(r'^(?=.*[A-Z])(?=.*[0-9]).{8,}$').hasMatch(value)) {
      return "Must contain 1 uppercase & 1 number";
    }

    return null;
  }

  // ================= SIGN UP =================

  Future<void> handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => showProgressBar = true);

    try {
      final authResponse = await SupabaseAuth.signUp(
        email: emailTextEditingController.text.trim(),
        password: passWordTextEditingController.text.trim(),
      );

      final supabaseUser = authResponse.user;

      if (supabaseUser == null) {
        throw Exception("Sign up failed");
      }

      String? imageUrl;

      if (authenticationController.profileImage != null) {
        imageUrl = await uploadImageToImgBB(
          authenticationController.profileImage!,
        );
      }

      final newUser = User(
        uid: supabaseUser.id,
        name: nameTextEditingController.text.trim(),
        email: emailTextEditingController.text.trim(),
        image: imageUrl,
      );

      await SupabaseAuth.supabase.from("users").insert(newUser.toJson());

      Get.snackbar(
        "Success",
        "You have successfully signed up",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => showProgressBar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 100),

                Text(
                  "Create Account",
                  style: GoogleFonts.acme(
                    fontSize: 34,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "To Get Started Now!",
                  style: GoogleFonts.aBeeZee(fontSize: 34, color: Colors.grey),
                ),

                const SizedBox(height: 16),

                // Profile Image
                CircleAvatar(
                  radius: 80,
                  backgroundImage: authenticationController.profileImage != null
                      ? FileImage(authenticationController.profileImage!)
                      : const NetworkImage(
                              "https://i.postimg.cc/v8KJX4MJ/profile-avatar.png",
                            )
                            as ImageProvider,
                ),

                const SizedBox(height: 10),

                IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => SizedBox(
                        height: 120,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera),
                              title: Text(
                                "Camera",
                                style: GoogleFonts.acme(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                await authenticationController
                                    .captureImageWithCamera();
                                setState(() {});
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: Text(
                                "Gallery",
                                style: GoogleFonts.acme(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                await authenticationController
                                    .chooseImageFromGallery();
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Username
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: InputTextWidget(
                    textEditingController: nameTextEditingController,
                    labelString: "Username",
                    icondata: Icons.person,
                    isObscure: false,
                    validator: validateName,
                  ),
                ),

                const SizedBox(height: 25),

                // Email
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: InputTextWidget(
                    textEditingController: emailTextEditingController,
                    labelString: "Email",
                    icondata: Icons.email_outlined,
                    isObscure: false,
                    validator: validateEmail,
                  ),
                ),

                const SizedBox(height: 25),

                // Password
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: InputTextWidget(
                    textEditingController: passWordTextEditingController,
                    labelString: "Password",
                    icondata: Icons.lock_outline,
                    isObscure: obscurePassword,
                    validator: validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                showProgressBar == false
                    ? Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 38,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: InkWell(
                              onTap: handleSignUp,
                              child: Center(
                                child: Text(
                                  "Sign Up",
                                  style: GoogleFonts.aBeeZee(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      )
                    : const SizedBox(
                        height: 80,
                        child: SimpleCircularProgressBar(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
