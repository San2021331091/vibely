import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String?> uploadImageToImgBB(File imageFile) async {
  try {
    final dio = Dio();
    final apiKey = dotenv.env['IMG_BB_API_KEY'];
    if (apiKey == null) throw Exception("IMG_BB_API_KEY not found in .env");

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await dio.post(
      'https://api.imgbb.com/1/upload',
      queryParameters: {'key': apiKey},
      data: FormData.fromMap({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return data['url'] as String; 
    } else {
      debugPrint("ImgBB upload failed: ${response.data}");
      return null;
    }
  } catch (e) {
    debugPrint("ImgBB upload error: $e");
    return null;
  }
}