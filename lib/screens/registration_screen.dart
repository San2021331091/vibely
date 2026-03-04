import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:vibely/authentication/authentication_controller.dart';
import 'package:vibely/widgets/form_validate.dart';
import 'package:vibely/widgets/input_text_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formValidate = FormValidate();

  final authController = AuthenticationController.instanceAuth;

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
                Obx(() => CircleAvatar(
                      radius: 80,
                      backgroundImage: authController.profileImage != null
                          ? FileImage(authController.profileImage!)
                          : const NetworkImage(
                                  "https://i.postimg.cc/v8KJX4MJ/profile-avatar.png")
                              as ImageProvider,
                    )),
                const SizedBox(height: 10),

                // Camera / Gallery buttons
                IconButton(
                  icon: const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
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
                                style: GoogleFonts.acme(color: Colors.white, fontSize: 22),
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                await authController.captureImageWithCamera();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: Text(
                                "Gallery",
                                style: GoogleFonts.acme(color: Colors.white, fontSize: 22),
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                await authController.chooseImageFromGallery();
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
                    textEditingController: nameController,
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
                    textEditingController: emailController,
                    labelString: "Email",
                    icondata: Icons.email_outlined,
                    isObscure: false,
                    validator: formValidate.validateEmail,
                  ),
                ),
                const SizedBox(height: 25),

                // Password
                Obx(() => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: InputTextWidget(
                        textEditingController: passwordController,
                        labelString: "Password",
                        icondata: Icons.lock_outline,
                        isObscure: authController.obscurePassword.value,
                        validator: formValidate.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(authController.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => authController.togglePasswordVisibility(),
                        ),
                      ),
                    )),
                const SizedBox(height: 30),

                // Sign Up Button
                Obx(() => authController.isLoading.value
                    ? const SizedBox(
                        height: 80,
                        child: SimpleCircularProgressBar(),
                      )
                    : Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 38,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: InkWell(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  authController.register(
                                    name: nameController.text.trim(),
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  );
                                }
                              },
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
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}