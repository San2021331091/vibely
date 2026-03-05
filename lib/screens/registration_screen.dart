import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:vibely/controller/authentication_controller.dart';
import 'package:vibely/screens/login_screen.dart';
import 'package:vibely/widgets/form_validate.dart';
import 'package:vibely/widgets/input_text_widget.dart';

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

  final FormValidate formValidate = FormValidate();

  final AuthenticationController authenticationController =
      AuthenticationController.instanceAuth;

  // ================= SIGN UP =================
  void handleSignUp() {
    if (_formKey.currentState!.validate()) {
      authenticationController.register(
        name: nameTextEditingController.text.trim(),
        email: emailTextEditingController.text.trim(),
        password: passWordTextEditingController.text.trim(),
      );
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

                // ================= PROFILE IMAGE (Reactive) =================
                Obx(
                  () => CircleAvatar(
                    radius: 80,
                    backgroundImage:
                        authenticationController.profileImage != null
                        ? FileImage(authenticationController.profileImage!)
                        : const NetworkImage(
                                "https://i.postimg.cc/v8KJX4MJ/profile-avatar.png",
                              )
                              as ImageProvider,
                  ),
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
                              title: const Text("Camera"),
                              onTap: () async {
                                Navigator.pop(context);
                                await authenticationController
                                    .captureImageWithCamera();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text("Gallery"),
                              onTap: () async {
                                Navigator.pop(context);
                                await authenticationController
                                    .chooseImageFromGallery();
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
                    validator: formValidate.validateName,
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
                    validator: formValidate.validateEmail,
                  ),
                ),

                const SizedBox(height: 25),

                // Password
                Obx(
                  () => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: InputTextWidget(
                      textEditingController: passWordTextEditingController,
                      labelString: "Password",
                      icondata: Icons.lock_outline,
                      isObscure: authenticationController.obscurePassword.value,
                      validator: formValidate.validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          authenticationController.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            authenticationController.togglePasswordVisibility,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ================= SIGN UP BUTTON (Reactive Loading) =================
                Obx(
                  () => authenticationController.isLoading.value
                      ? const SizedBox(
                          height: 80,
                          child: SimpleCircularProgressBar(
                            progressColors: [
                              Colors.purple,
                              Colors.blue,
                              Colors.cyan,
                            ],
                            size: 160,
                            backColor: Colors.blueGrey,
                            progressStrokeWidth: 12,
                            backStrokeWidth: 12,
                          ),
                        )
                      : Column(
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
                        ),
                ),

                // ================= LOGIN LINK =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: GoogleFonts.abhayaLibre(
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Get.off(() => const LoginScreen());
                      },
                      child: Text(
                        "Login Now",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
