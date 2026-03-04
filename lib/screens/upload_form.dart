import 'dart:io';

import 'package:flutter/material.dart';

class UploadForm extends StatefulWidget {
  final File videoFile;
  final String videoPath;
  const UploadForm({super.key,required this.videoFile, required this.videoPath});

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Upload Form"),)
    );
  }
}