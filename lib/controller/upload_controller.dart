import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibely/authentication/supabase_auth.dart';
import 'package:video_compress/video_compress.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UploadController extends GetxController {
  final _dio = dio.Dio();

  RxBool isUploading = false.obs;
  RxDouble uploadProgress = 0.0.obs;

  final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
  final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

  // Compress Video
  Future<File?> compressVideoFile(String videoFilePath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoFilePath,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
    );
    return compressedVideo?.file;
  }

  // Generate Thumbnail
  Future<File> getThumbNailImage(String videoFilePath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(
      videoFilePath,
      quality: 75,
    );
    return thumbnail;
  }

  // Upload File to Cloudinary
  Future<String?> uploadFileToCloudinary({
    required File file,
    required String fileID,
    required String resourceType, // "video" or "image"
  }) async {
    try {
      isUploading.value = true;

      String url = "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload";

      dio.FormData formData = dio.FormData.fromMap({
        "file": await dio.MultipartFile.fromFile(
          file.path,
          filename: resourceType == "video" ? "$fileID.mp4" : "$fileID.jpg",
        ),
        "upload_preset": uploadPreset,
        "public_id": fileID,
      });

      dio.Response response = await _dio.post(
        url,
        data: formData,
        onSendProgress: (sent, total) {
          uploadProgress.value = sent / total;
        },
      );

      isUploading.value = false;

      if (response.statusCode == 200) {
        return response.data["secure_url"];
      }
    } catch (e) {
      isUploading.value = false;
      debugPrint("Upload Error: $e");
    }

    return null;
  }

  // Complete Flow: Compress video, generate thumbnail, and upload both
  Future<Map<String, String?>> uploadVideoWithThumbnail(String videoID, String videoFilePath) async {
    // 1️⃣ Compress video
    File? compressedVideo = await compressVideoFile(videoFilePath);
    if (compressedVideo == null) return {};

    // 2️⃣ Upload compressed video
    String? videoUrl = await uploadFileToCloudinary(
      file: compressedVideo,
      fileID: videoID,
      resourceType: "video",
    );

    // 3️⃣ Generate thumbnail
    File thumbnailFile = await getThumbNailImage(videoFilePath);

    // 4️⃣ Upload thumbnail
    String? thumbnailUrl = await uploadFileToCloudinary(
      file: thumbnailFile,
      fileID: "${videoID}_thumbnail",
      resourceType: "image",
    );

    return {
      "videoUrl": videoUrl,
      "thumbnailUrl": thumbnailUrl,
    };
  }

  Future<void> saveVideoInformationToSupabaseDatabase({
  required String videoID,
  required String artistSongName,
  required String descriptionTags,
  required String videoFilePath,
  required BuildContext context,
}) async {
  try {

    final supabase = SupabaseAuth.supabase;

    String videoId = DateTime.now().millisecondsSinceEpoch.toString();

    /// 1️⃣ Upload video + thumbnail to Cloudinary
    final result = await uploadVideoWithThumbnail(videoId, videoFilePath);

    String? videoUrl = result["videoUrl"];
    String? thumbnailUrl = result["thumbnailUrl"];

    if (videoUrl == null || thumbnailUrl == null) {
      throw Exception("Upload failed");
    }

    /// 2️⃣ Get logged in user
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    /// 3️⃣ Save to Supabase database
    await supabase.from('videos').insert({
      "id": videoId,
      "artist_song_name": artistSongName,
      "description_tags": descriptionTags,
      "video_url": videoUrl,
      "thumbnail_url": thumbnailUrl,
      "user_id": user.id,
    });

     Get.snackbar("Successful", "Video Uploaded Successfully");

  } catch (error) {
    
    debugPrint("Upload Error: $error");

      Get.snackbar("Error", "Video Upload Unsuccessful. Try Again.");
  }
}
}