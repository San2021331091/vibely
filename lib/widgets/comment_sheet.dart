import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibely/controller/comment_controller.dart';
import 'package:vibely/controller/video_feed_controller.dart';
import 'package:vibely/models/comment.dart';
import 'package:vibely/models/user.dart';
import 'package:vibely/authentication/supabase_auth.dart';

class CommentSheet extends StatefulWidget {
  final String videoId;
  final String userId;
  final VoidCallback? onCommentAdded;

  const CommentSheet({
    super.key,
    required this.videoId,
    required this.userId,
    this.onCommentAdded,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final CommentController commentController = Get.put(CommentController());
  final supabase = SupabaseAuth.supabase;

  /// Cache users locally
  final RxMap<String, User> userCache = <String, User>{}.obs;

  @override
  void initState() {
    super.initState();
    commentController.fetchComments(widget.videoId);

    ever(commentController.comments, (_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<User> getUser(String userId) async {
    if (userCache.containsKey(userId)) return userCache[userId]!;

    final response =
        await supabase.from('users').select().eq('uid', userId).single()
            as Map<String, dynamic>?;

    final user = response != null
        ? User.fromMap(response)
        : User(uid: userId, name: "Unknown");

    userCache[userId] = user;
    return user;
  }

  Future<void> deleteComment(Comment comment) async {
    try {
      await supabase.from('comments').delete().eq('id', comment.id!);
      commentController.comments.remove(comment);

      if (Get.isRegistered<VideoFeedController>()) {
        final videoController = Get.find<VideoFeedController>();
        final index = videoController.videos.indexWhere(
          (v) => v.id == comment.videoId,
        );
        if (index != -1) {
          final video = videoController.videos[index];
          final newCount = (video.commentsCount ?? 1) - 1;
          videoController.videos[index] = video.copyWith(
            commentsCount: newCount,
          );
          videoController.videos.refresh();
        }
      }
    } catch (e) {
      debugPrint("Error deleting comment: $e");
    }
  }

  Future<void> editComment(Comment comment, String newText) async {
    try {
      final index = commentController.comments.indexOf(comment);
      if (index == -1) return;

      final updatedComment = Comment(
        id: comment.id,
        videoId: comment.videoId,
        userId: comment.userId,
        commentText: newText,
        createdAt: comment.createdAt,
      );

      await supabase
          .from('comments')
          .update({'comment_text': newText})
          .eq('id', comment.id!);

      commentController.comments[index] = updatedComment;
      commentController.comments.refresh();
    } catch (e) {
      debugPrint("Error editing comment: $e");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final comments = commentController.comments;
      final isLoading = commentController.isLoading.value;

      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Comments",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(),

            /// Comment List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : comments.isEmpty
                  ? const Center(
                      child: Text(
                        "No comments yet",
                        style: TextStyle(color: Colors.black45),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final Comment comment =
                            comments[comments.length - 1 - index];

                        return FutureBuilder<User>(
                          future: getUser(comment.userId),
                          builder: (context, snapshot) {
                            final user = snapshot.data;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Avatar
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage: user?.image != null
                                        ? NetworkImage(user!.image!)
                                        : null,
                                    backgroundColor: Colors.blueGrey.shade200,
                                    child: user?.image == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 18,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),

                                  /// Comment Content
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                user?.name ?? "Unknown",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),

                                              /// Edit/Delete buttons only for owner
                                              if (comment.userId ==
                                                  widget.userId)
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        size: 18,
                                                        color: Colors.brown,
                                                      ),
                                                      onPressed: () async {
                                                        final TextEditingController
                                                        editController =
                                                            TextEditingController(
                                                              text: comment
                                                                  .commentText,
                                                            );

                                                        final String?
                                                        newText = await showDialog<String>(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            title: const Text(
                                                              "Edit Comment",
                                                            ),
                                                            content: TextField(
                                                              controller:
                                                                  editController,
                                                              autofocus: true,
                                                              decoration:
                                                                  const InputDecoration(
                                                                    hintText:
                                                                        "Edit your comment",
                                                                  ),
                                                              onSubmitted:
                                                                  (value) =>
                                                                      Navigator.of(
                                                                        context,
                                                                      ).pop(
                                                                        value,
                                                                      ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(null),
                                                                child:
                                                                    const Text(
                                                                      "Cancel",
                                                                    ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(
                                                                      editController
                                                                          .text
                                                                          .trim(),
                                                                    ),
                                                                child:
                                                                    const Text(
                                                                      "Save",
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        );

                                                        if (newText != null &&
                                                            newText
                                                                .isNotEmpty) {
                                                          await editComment(
                                                            comment,
                                                            newText,
                                                          );
                                                        }
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        size: 18,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () async {
                                                        await deleteComment(
                                                          comment,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            comment.commentText,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            comment.createdAt
                                                .toLocal()
                                                .toString()
                                                .substring(0, 16),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),

            /// Comment Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: const Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blueGrey.shade200,
                    child: const Icon(
                      Icons.person,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      cursorColor: Colors.black87,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: const TextStyle(color: Colors.black45),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      await commentController.addComment(
                        videoId: widget.videoId,
                        userId: widget.userId,
                        text: text,
                      );

                      controller.clear();
                      widget.onCommentAdded?.call();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
