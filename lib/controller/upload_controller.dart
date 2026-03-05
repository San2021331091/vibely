import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:vibely/authentication/supabase_auth.dart';
import 'package:vibely/models/video.dart';
import 'package:vibely/screens/home_screen.dart';
import 'package:video_compress/video_compress.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class UploadController extends GetxController {

  final dio.Dio _dio = dio.Dio(
    dio.BaseOptions(
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
    ),
  );

  RxBool isUploading = false.obs;
  RxDouble uploadProgress = 0.0.obs;

  late final String cloudName;
  late final String uploadPreset;
  late final String imgbbKey;

  @override
  void onInit() {
    super.onInit();

    cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? "";
    uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? "";
    imgbbKey = dotenv.env['IMG_BB_API_KEY'] ?? "";
  }

  /// COMPRESS VIDEO
  Future<File?> compressVideoFile(String videoFilePath) async {
    try {

      final compressedVideo = await VideoCompress.compressVideo(
        videoFilePath,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      if (compressedVideo == null || compressedVideo.file == null) {
        debugPrint("Video compression failed");
        return null;
      }

      return compressedVideo.file;

    } catch (e) {
      debugPrint("Compression error: $e");
      return null;
    }
  }

  /// GENERATE THUMBNAIL
  Future<File?> getThumbNailImage(String videoFilePath) async {
    try {

      final thumbnail = await VideoCompress.getFileThumbnail(
        videoFilePath,
        quality: 75,
      );

      if (!await thumbnail.exists()) {
        debugPrint("Thumbnail generation failed");
        return null;
      }

      return thumbnail;

    } catch (e) {
      debugPrint("Thumbnail error: $e");
      return null;
    }
  }

  /// UPLOAD VIDEO TO CLOUDINARY
  Future<String?> uploadVideoToCloudinary({required File file}) async {
    try {

      final cloudinary = CloudinaryPublic(
        cloudName,
        uploadPreset,
        cache: false,
      );

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Video, 
        ),
        onProgress: (count, total) {

          if (total != 0) {
            uploadProgress.value = count / total;
          }

        },
      );

      Get.snackbar("Sucess", "Upload Successful");

      return response.secureUrl;

    } on CloudinaryException catch (e) {
 
       Get.snackbar("Error","Cloudinary Exception: ${e.message}");
      debugPrint("Cloudinary Request: ${e.request}");

    } catch (e) {

      debugPrint("Cloudinary Upload Error: $e");

    }

    return null;
  }

  /// UPLOAD THUMBNAIL TO IMGBB
  Future<String?> uploadThumbnailToImgBB(File file) async {
    try {

      String url = "https://api.imgbb.com/1/upload?key=$imgbbKey";

      dio.FormData formData = dio.FormData.fromMap({

        "image": await dio.MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),

      });

      dio.Response response = await _dio.post(url, data: formData);

      if (response.statusCode == 200) {
        return response.data["data"]["url"];
      }

      debugPrint("ImgBB error: ${response.data}");

    } catch (e) {

      debugPrint("ImgBB Upload Error: $e");

    }

    return null;
  }

  /// UPLOAD VIDEO + THUMBNAIL
  Future<Map<String, String?>> uploadVideoWithThumbnail(
      String videoID,
      String videoFilePath,
      ) async {

    try {

      /// Compress
      File? compressedVideo = await compressVideoFile(videoFilePath);

      if (compressedVideo == null) {
        throw Exception("Video compression failed");
      }

      /// Upload Video
      String? videoUrl = await uploadVideoToCloudinary(file: compressedVideo);

      if (videoUrl == null) {
        throw Exception("Video upload failed");
      }

      /// Thumbnail
      File? thumbnailFile = await getThumbNailImage(videoFilePath);

      if (thumbnailFile == null) {
        throw Exception("Thumbnail generation failed");
      }

      /// Upload Thumbnail
      String? thumbnailUrl = await uploadThumbnailToImgBB(thumbnailFile);

      if (thumbnailUrl == null) {
        throw Exception("Thumbnail upload failed");
      }

      return {
        "videoUrl": videoUrl,
        "thumbnailUrl": thumbnailUrl,
      };

    } catch (e) {

      debugPrint("Upload Flow Error: $e");

      return {};

    }
  }

  /// SAVE TO SUPABASE
  Future<void> saveVideoInformationToSupabaseDatabase({

    required String artistSongName,
    required String descriptionTags,
    required String videoFilePath,
    required BuildContext context,

  }) async {

    try {

      uploadProgress.value = 0;
      isUploading.value = true;

      final supabase = SupabaseAuth.supabase;
      const uuid = Uuid();

      String videoId = uuid.v4();

      final result = await uploadVideoWithThumbnail(
        videoId,
        videoFilePath,
      );

      String? videoUrl = result["videoUrl"];
      String? thumbnailUrl = result["thumbnailUrl"];

      if (videoUrl == null || thumbnailUrl == null) {
        throw Exception("Upload failed");
      }

      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      Video video = Video(
        id: videoId,
        artistSongName: artistSongName,
        descriptionTags: descriptionTags,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        userId: user.id,
        likesCount: 0,
        commentsCount: 0,
        createdAt: DateTime.now(),
      );

      await supabase
          .from('videos')
          .insert(video.toJson());

      uploadProgress.value = 1;

      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      Get.snackbar(
        "Success",
        "Video Uploaded Successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      Get.offAll(() => const HomeScreen());

    } catch (error) {

      debugPrint("Upload Error: $error");

      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      Get.snackbar(
        "Upload Failed",
        error.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

    } finally {

      isUploading.value = false;

    }
  }
}