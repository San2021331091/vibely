import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network('https://i.postimg.cc/Wp04yZRQ/upload.png',
            width: 260,),
           const SizedBox(height: 30),
           ElevatedButton(
            onPressed: (){}, 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text(
            "Upload New Video",
            style: GoogleFonts.acme(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),
           ))
          ],
        
      ),
      )
    );
  }
}