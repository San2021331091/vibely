import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:vibely/screens/registration_screen.dart';
import 'package:vibely/widgets/form_validate.dart';
import 'package:vibely/widgets/input_text_widget.dart';
import 'package:vibely/controller/authentication_controller.dart';

class LoginScreen extends StatefulWidget {
  final String? name;
  final String? email;
  final String? imageUrl;

  const LoginScreen({super.key, this.name, this.email, this.imageUrl});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FormValidate formValidate = FormValidate();

  final AuthenticationController authController =
      AuthenticationController.instanceAuth;

  // ================= LOGIN FUNCTION =================
  void handleLogin() {
    if (_formKey.currentState!.validate()) {
      authController.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
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

                Image.network(
                  "https://i.postimg.cc/XYwxWd41/tune.png",
                  width: 200,
                ),

                Text(
                  "Welcome",
                  style: GoogleFonts.acme(
                    fontSize: 34,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "Glad to see you!",
                  style: GoogleFonts.aBeeZee(fontSize: 34, color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // ================= EMAIL FIELD =================
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

                // ================= PASSWORD FIELD =================
                Obx(
                  () => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: InputTextWidget(
                      textEditingController: passwordController,
                      labelString: "Password",
                      icondata: Icons.lock_outline,
                      isObscure: authController.obscurePassword.value,
                      validator: formValidate.validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          authController.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: authController.togglePasswordVisibility,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ================= LOGIN BUTTON =================
                Obx(
                  () => authController.isLoading.value
                      ? const SizedBox(
                          height: 80,
                          child: SimpleCircularProgressBar( progressColors: [
                              Colors.purple,
                              Colors.blue,
                              Colors.cyan,
                            ],
                            size: 160,
                            backColor: Colors.blueGrey,
                            progressStrokeWidth: 12,
                            backStrokeWidth: 12,),
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
                                onTap: handleLogin,
                                child: Center(
                                  child: Text(
                                    "Login",
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

                            // ================= SIGN UP LINK =================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style: GoogleFonts.abhayaLibre(
                                    color: Colors.grey,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: () {
                                    Get.off(() => const RegistrationScreen());
                                  },
                                  child: Text(
                                    "Sign Up Now",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
