import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibely/screens/upload_form.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  Future<XFile?> getVideoFile(ImageSource sourceImg) async {
    final videoFile = await ImagePicker().pickVideo(source: sourceImg);
    if(videoFile != null){
      Get.to(
        UploadForm(
          videoFile: File(videoFile.path),
          videoPath: videoFile.path
        ),
      );
    }
    return null;
  }

  Future<void> displayDialogBox() {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          SimpleDialogOption(
            onPressed: () {
              getVideoFile(ImageSource.gallery);
            },
            child: Row(
              children: [
                const Icon(Icons.photo_library),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Get Video From Gallery",
                    style: GoogleFonts.acme(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          SimpleDialogOption(
            onPressed: () {
              getVideoFile(ImageSource.camera);
            },
            child: Row(
              children: [
                const Icon(Icons.camera),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Capture Video Using Camera",
                    style: GoogleFonts.acme(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          SimpleDialogOption(
            onPressed: () => Get.back(),
            child: Row(
              children: [
                const Icon(Icons.cancel_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text("Cancel", style: GoogleFonts.acme(fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://i.postimg.cc/Wp04yZRQ/upload.png',
              width: 260,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                displayDialogBox();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(
                "Upload New Video",
                style: GoogleFonts.acme(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
