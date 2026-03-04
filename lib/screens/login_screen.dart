import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:vibely/screens/home_screen.dart';
import 'package:vibely/screens/registration_screen.dart';
import 'package:vibely/widgets/input_text_widget.dart';
import 'package:vibely/authentication/supabase_auth.dart';

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

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passWordTextEditingController = TextEditingController();

  bool showProgressBar = false;
  bool obscurePassword = true;

  // ================= VALIDATORS =================

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

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }

  // ================= LOGIN FUNCTION =================

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => showProgressBar = true);

    try {
      final response = await SupabaseAuth.supabase.auth.signInWithPassword(
        email: emailTextEditingController.text.trim(),
        password: passWordTextEditingController.text.trim(),
      );

      final user = response.user;

      if (user == null) {
        throw Exception("Login failed");
      }

      // 🔥 CHECK if profile already exists
      final existingUser = await SupabaseAuth.supabase
          .from('users')
          .select()
          .eq('uid', user.id)
          .maybeSingle();

      if (existingUser == null) {
        // 🔥 INSERT PROFILE (RLS safe because authenticated)
        await SupabaseAuth.supabase.from('users').insert({
          'uid': user.id,
          'name': widget.name ?? "New User",
          'email': user.email,
          'image': widget.imageUrl,
        });
      }

      Get.snackbar(
        "Success",
        "Login successful",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to home
       Get.offAll(() => const HomeScreen());
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

                // ================= EMAIL =================
                Container(
                  width: MediaQuery.of(context).size.width,
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

                // ================= PASSWORD =================
                Container(
                  width: MediaQuery.of(context).size.width,
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

                // ================= LOGIN BUTTON =================
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
                                  Get.to(const RegistrationScreen());
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
