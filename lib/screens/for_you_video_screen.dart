import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibely/controller/video_feed_controller.dart';
import 'package:vibely/widgets/follow_button.dart';
import 'package:vibely/widgets/profile_icon.dart';
import 'package:vibely/widgets/video_player_item.dart';
import 'package:vibely/widgets/comment_sheet.dart';
import 'package:vibely/authentication/supabase_auth.dart';

class ForYouVideoScreen extends StatelessWidget {
  const ForYouVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoFeedController());
    final currentUserId = SupabaseAuth.supabase.auth.currentUser?.id ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: controller.videos.length,
          itemBuilder: (context, index) {
            final video = controller.videos[index];

            return Stack(
              children: [
                VideoPlayerItem(videoUrl: video.videoUrl ?? ""),
                const Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "For You",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                /// Right side actions (Profile, Like, Comment, Share)
                Positioned(
                  right: 10,
                  bottom: 120,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Profile icon on top
                      ProfileIcon(userId: video.userId!, size: 50),
                      const SizedBox(height: 20),

                      // Follow Button
                      FollowButton(userId: video.userId!),
                      const SizedBox(height: 20),

                      /// Like button
                      Obx(() {
                        final isLiked =
                            controller.isLiked(video.id!) ||
                            (video.likesCount ?? 0) > 0;
                        return IconButton(
                          onPressed: () =>
                              controller.toggleLike(video.id!, index),
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.white,
                            size: 35,
                          ),
                        );
                      }),
                      Obx(
                        () => Text(
                          "${controller.videos[index].likesCount ?? 0}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Comment button
                      IconButton(
                        onPressed: () {
                          Get.bottomSheet(
                            CommentSheet(
                              videoId: video.id!,
                              userId: currentUserId,
                            ),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                        },
                        icon: const Icon(
                          Icons.comment,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      Obx(
                        () => Text(
                          "${controller.videos[index].commentsCount ?? 0}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Share button
                      IconButton(
                        onPressed: () {
                          if (video.videoUrl != null) {
                            SharePlus.instance.share(
                              ShareParams(
                                text:
                                    "Watch this video on Vibely 🔥\n${video.videoUrl}",
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Caption
                Positioned(
                  bottom: 40,
                  left: 12,
                  right: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.artistSongName ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        video.descriptionTags ?? "",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
