import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:vibely/authentication/supabase_auth.dart';
import 'package:vibely/models/video.dart';
import 'package:vibely/screens/home_screen.dart';
import 'package:vibely/utils/img_upload.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';


class UploadController extends GetxController {
  RxBool isUploading = false.obs;
  RxDouble uploadProgress = 0.0.obs;

  late final String imgbbKey;

  final int maxVideoSizeMB = 50;

  /// PROGRESS SIMULATION
  void simulateProgress() async {
    while (isUploading.value && uploadProgress.value < 0.9) {
      await Future.delayed(const Duration(milliseconds: 400));

      uploadProgress.value += 0.03;

      if (uploadProgress.value > 0.9) {
        uploadProgress.value = 0.9;
      }
    }
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
        throw Exception("Video compression failed");
      }

      final fileSizeMB =
          await compressedVideo.file!.length() ~/ (1024 * 1024);

      if (fileSizeMB > maxVideoSizeMB) {
        throw Exception("Video is too large. Max allowed size is $maxVideoSizeMB MB");
      }

      return compressedVideo.file;

    } catch (e) {
      throw Exception("Video compression error: $e");
    }
  }

  /// GENERATE THUMBNAIL
  Future<File?> getThumbNailImage(String videoFilePath) async {

    try {

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFilePath,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );

      if (thumbnailPath == null) {
        throw Exception("Thumbnail generation returned null");
      }

      final thumbnailFile = File(thumbnailPath);

      if (!await thumbnailFile.exists()) {
        throw Exception("Thumbnail file does not exist");
      }

      return thumbnailFile;

    } catch (e) {
      throw Exception("Thumbnail error: $e");
    }
  }

  /// UPLOAD VIDEO TO SUPABASE
  Future<String> uploadVideoToSupabase({
    required File file,
    required String videoId,
  }) async {

    try {

      final supabase = SupabaseAuth.supabase;

      String filePath = "$videoId.mp4";

      await supabase.storage
          .from('videos')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      return supabase.storage
          .from('videos')
          .getPublicUrl(filePath);

    } catch (e) {
      throw Exception("Supabase video upload error: $e");
    }
  }

  /// UPLOAD VIDEO + THUMBNAIL
  Future<Map<String, String>> uploadVideoWithThumbnail(
      String videoID,
      String videoFilePath,
      ) async {

    try {

      final compressedVideo = await compressVideoFile(videoFilePath);

      final thumbnailFile =
          await getThumbNailImage(compressedVideo!.path);

      final videoUrl = await uploadVideoToSupabase(
        file: compressedVideo,
        videoId: videoID,
      );

      final thumbnailUrl =
          await uploadImageToImgBB(thumbnailFile!);

      return {
        "videoUrl": videoUrl,
        "thumbnailUrl": thumbnailUrl!
      };

    } catch (e) {
      throw Exception("Upload Flow Error: $e");
    }
  }

  /// SAVE VIDEO INFO
  Future<void> saveVideoInformationToSupabaseDatabase({

    required String artistSongName,
    required String descriptionTags,
    required String videoFilePath,
    required BuildContext context,

  }) async {

    uploadProgress.value = 0;
    isUploading.value = true;

    simulateProgress();

    try {

      final supabase = SupabaseAuth.supabase;

      const uuid = Uuid();

      String videoId = uuid.v4();

      final result =
          await uploadVideoWithThumbnail(videoId, videoFilePath);

      final videoUrl = result["videoUrl"];
      final thumbnailUrl = result["thumbnailUrl"];

      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final video = Video(
        id: videoId,
        artistSongName: artistSongName,
        descriptionTags: descriptionTags,
        videoUrl: videoUrl!,
        thumbnailUrl: thumbnailUrl!,
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

    } catch (e) {

      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      Get.snackbar(
        "Upload Failed",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );

    } finally {

      isUploading.value = false;

    }
  }
}