import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 100,),
            
              Image.network(
                "https://i.postimg.cc/XYwxWd41/tune.png",
                width: 200,
              ),
              Text("Welcome",
               style: GoogleFonts.acme(
                fontSize: 34,
                color: Colors.grey,
                fontWeight: FontWeight.bold 
               ),
            ),
            Text("Glad to see you",
               style: GoogleFonts.abhayaLibre(
                fontSize: 34,
                color: Colors.grey,
               ),
               
            ),
            SizedBox(height: 30,),
            ],

            
          ),
        ),
      ),
    );
  }
}
