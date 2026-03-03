import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibely/widgets/input_text_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
              // login button
              //don't have an account? sign up
              showProgressBar == false
                  ? Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width - 38,
                          height: 34,
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
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15,),
                        //not have an account? sign up button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          const Text("Don't have an ccount?",style: TextStyle(color: Colors.grey,
                          fontSize: 16),),
                          SizedBox(width: 10,),
                          InkWell(
                            onTap: (){
                            },
                            child : const Text("Sign Up Now",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),),
                          )
                          
                        ],
                        )
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
