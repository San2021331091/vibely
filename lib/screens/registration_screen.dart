import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:vibely/screens/login_screen.dart';
import 'package:vibely/widgets/input_text_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passWordTextEditingController = TextEditingController();
  bool showProgressBar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 100),

              Text(
                "Create Account",
                style: GoogleFonts.acme(
                  fontSize: 34,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "to Get Started Now!",
                style: GoogleFonts.aBeeZee(fontSize: 34, color: Colors.grey),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => {
                  //allow user to choose images
                },
                child: const CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(
                    "https://i.postimg.cc/v8KJX4MJ/profile-avatar.png",
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Name Input
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: InputTextWidget(
                  textEditingController: nameTextEditingController,
                  labelString: "Username",
                  icondata: Icons.person,
                  isObscure: false,
                ),
              ),

              const SizedBox(height: 25),
              //email input
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: InputTextWidget(
                  textEditingController: emailTextEditingController,
                  labelString: "Email",
                  icondata: Icons.email_outlined,
                  isObscure: false,
                ),
              ),
              const SizedBox(height: 25),

              //password input
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: InputTextWidget(
                  textEditingController: passWordTextEditingController,
                  labelString: "Password",
                  icondata: Icons.lock_outline,
                  isObscure: true,
                ),
              ),

              const SizedBox(height: 30),
              // sign up button
              showProgressBar == false
                  ? Column(
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
                              setState(() {
                                showProgressBar = true;
                              });
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
                        //already have an account? login button
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
                              onTap: () => {Get.to(const LoginScreen())},
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
                    )
                  : SizedBox(
                      child: SimpleCircularProgressBar(
                        progressColors: [
                          Colors.green,
                          Colors.blueAccent,
                          Colors.red,
                          Colors.amber,
                          Colors.purpleAccent,
                        ],
                        animationDuration: 5,
                        backColor: Colors.white38,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
