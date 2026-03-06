import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {

  final String videoUrl;

  const VideoPlayerItem({super.key, required this.videoUrl});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {

  late VideoPlayerController controller;

  @override
  void initState() {

    controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {

        setState(() {});

        controller.play();
        controller.setLooping(true);

      });

    super.initState();
  }

  @override
  void dispose() {

    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(

      onTap: () {

        controller.value.isPlaying
            ? controller.pause()
            : controller.play();

      },

      child: SizedBox.expand(

        child: FittedBox(

          fit: BoxFit.cover,

          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}