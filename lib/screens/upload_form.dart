import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:vibely/widgets/input_text_widget.dart';
import 'package:video_player/video_player.dart';

class UploadForm extends StatefulWidget {
  final File videoFile;
  final String videoPath;

  const UploadForm({
    super.key,
    required this.videoFile,
    required this.videoPath,
  });

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {
  VideoPlayerController? playerController;
  bool isVideoInitialized = false;
  bool showProgressBar = false;
  TextEditingController artistSongTextEditingControler =
      TextEditingController();
  TextEditingController descriptionTextEditingControler =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeVideo();
  }

  Future<void> initializeVideo() async {
    playerController = VideoPlayerController.file(widget.videoFile);

    await playerController!.initialize();

    playerController!.setLooping(true);
    playerController!.setVolume(1);
    playerController!.play();

    setState(() {
      isVideoInitialized = true;
    });
  }

  @override
  void dispose() {
    playerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.3,
              child: VideoPlayer(playerController!),
            ),
            const SizedBox(height: 30),
            //upload video
            showProgressBar == true
                ? const SizedBox(
                    height: 80,
                    child: SimpleCircularProgressBar(
                      progressColors: [Colors.purple, Colors.blue, Colors.cyan],
                      size: 160,
                      backColor: Colors.blueGrey,
                      progressStrokeWidth: 12,
                      backStrokeWidth: 12,
                    ),
                  )
                : Column(
                    children: [
                      //artist-songs
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: InputTextWidget(
                          textEditingController: artistSongTextEditingControler,
                          labelString: "Artist - Songs",
                          icondata: Icons.music_video_sharp,
                          isObscure: false,
                        ),
                      ),
                      const SizedBox(height: 10),
                      //description-tags
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: InputTextWidget(
                          textEditingController:
                              descriptionTextEditingControler,
                          labelString: "Description Tags",
                          icondata: Icons.slideshow_sharp,
                          isObscure: false,
                        ),
                      ),
                      const SizedBox(height: 10),
                      //upload now button
                      Container(
                        width: MediaQuery.of(context).size.width - 38,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: InkWell(
                          onTap: () => {

                          },
                          child: Center(
                            child: Text(
                              "Upload Now",
                              style: GoogleFonts.aBeeZee(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                             ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20,),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
