import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibely/models/video.dart';
import 'package:vibely/authentication/supabase_auth.dart';

class VideoFeedController extends GetxController {
  final supabase = SupabaseAuth.supabase;

  RxList<Video> videos = <Video>[].obs;
  RxBool isLoading = false.obs;
  RxSet<String> likedVideos = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('videos')
          .select()
          .order('created_at', ascending: false);
      videos.value = (response as List).map((e) => Video.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Video Fetch Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  bool isLiked(String videoId) => likedVideos.contains(videoId);

  Future<void> toggleLike(String videoId, int index) async {
    final video = videos[index];
    int newLikes = (video.likesCount ?? 0);

    if (likedVideos.contains(videoId)) {
      likedVideos.remove(videoId);
      newLikes--;
    } else {
      likedVideos.add(videoId);
      newLikes++;
    }

    // Update local UI immediately
    videos[index] = video.copyWith(likesCount: newLikes);
    videos.refresh();

    // Update Supabase
    try {
      await supabase
          .from('videos')
          .update({"likes_count": newLikes})
          .eq("id", videoId);
    } catch (e) {
      debugPrint("Error updating likes_count: $e");
    }
  }

  Future<void> incrementCommentsCount(String videoId) async {
    final index = videos.indexWhere((v) => v.id == videoId);
    if (index == -1) return;

    final video = videos[index];
    final newCount = (video.commentsCount ?? 0) + 1;

    videos[index] = video.copyWith(commentsCount: newCount);
    videos.refresh();

    try {
      await supabase
          .from('videos')
          .update({"comments_count": newCount})
          .eq("id", videoId);
    } catch (e) {
      debugPrint("Error updating comments_count: $e");
    }
  }
}

extension VideoCopyWith on Video {
  Video copyWith({
    int? likesCount,
    int? commentsCount,
  }) {
    return Video(
      id: id,
      artistSongName: artistSongName,
      descriptionTags: descriptionTags,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      userId: userId,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
    );
  }
}