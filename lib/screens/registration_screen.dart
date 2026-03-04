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
  final TextEditingController nameTextEditingController =
      TextEditingController();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController passWordTextEditingController =
      TextEditingController();

  bool showProgressBar = false;

  final authenticationController =
      AuthenticationController.instanceAuth;



  /// 🔥 Handle Sign Up
  Future<void> handleSignUp() async {
    if (nameTextEditingController.text.isEmpty ||
        emailTextEditingController.text.isEmpty ||
        passWordTextEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => showProgressBar = true);

    try {
      // 1️⃣ Create user in Supabase Auth
      final authResponse = await SupabaseAuth.signUp(
        email: emailTextEditingController.text.trim(),
        password: passWordTextEditingController.text.trim(),
      );

      final supabaseUser = authResponse.user;

      if (supabaseUser == null) {
        throw Exception("Sign up failed");
      }

      // 2️⃣ Upload profile image to ImgBB
      String? imageUrl;

      if (authenticationController.profileImage != null) {
        imageUrl = await uploadImageToImgBB(
          authenticationController.profileImage!,
        );
      }

      // 3️⃣ Create user model
      final newUser = User(
        uid: supabaseUser.id,
        name: nameTextEditingController.text.trim(),
        email: emailTextEditingController.text.trim(),
        image: imageUrl,
      );

      // 4️⃣ Insert into Supabase users table
      await SupabaseAuth.supabase
          .from("users")
          .insert(newUser.toJson());

      // 5️⃣ Go to Login screen
      Get.offAll(() => const LoginScreen());

    } catch (e) {
      debugPrint("Sign Up Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign up failed: $e")),
      );
    } finally {
      setState(() => showProgressBar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                style: GoogleFonts.aBeeZee(
                  fontSize: 34,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 16),

              /// Profile Image
              CircleAvatar(
                radius: 80,
                backgroundImage:
                    authenticationController.profileImage != null
                        ? FileImage(authenticationController.profileImage!)
                        : const NetworkImage(
                                "https://i.postimg.cc/v8KJX4MJ/profile-avatar.png")
                            as ImageProvider,
              ),

              const SizedBox(height: 10),

              /// Camera Button
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
                              setState(() {});
                            },
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.photo_library),
                            title: const Text("Gallery"),
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

              /// Username
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: InputTextWidget(
                  textEditingController:
                      nameTextEditingController,
                  labelString: "Username",
                  icondata: Icons.person,
                  isObscure: false,
                ),
              ),

              const SizedBox(height: 25),

              /// Email
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: InputTextWidget(
                  textEditingController:
                      emailTextEditingController,
                  labelString: "Email",
                  icondata: Icons.email_outlined,
                  isObscure: false,
                ),
              ),

              const SizedBox(height: 25),

              /// Password
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: InputTextWidget(
                  textEditingController:
                      passWordTextEditingController,
                  labelString: "Password",
                  icondata: Icons.lock_outline,
                  isObscure: true,
                ),
              ),

              const SizedBox(height: 30),

              /// Sign Up Button
              showProgressBar == false
                  ? Column(
                      children: [
                        Container(
                          width:
                              MediaQuery.of(context).size.width - 38,
                          height: 50,
                          decoration:
                              const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(
                                    Radius.circular(10)),
                          ),
                          child: InkWell(
                            onTap: handleSignUp,
                            child: Center(
                              child: Text(
                                "Sign Up",
                                style:
                                    GoogleFonts.aBeeZee(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style:
                                  GoogleFonts.abhayaLibre(
                                color: Colors.grey,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () => Get.to(
                                  const LoginScreen()),
                              child: Text(
                                "Login Now",
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const SizedBox(
                      height: 80,
                      child:
                          SimpleCircularProgressBar(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}