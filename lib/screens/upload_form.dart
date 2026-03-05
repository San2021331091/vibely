import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:vibely/controller/upload_controller.dart';
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

  final TextEditingController artistSongTextEditingControler =
      TextEditingController();
  final TextEditingController descriptionTextEditingControler =
      TextEditingController();

  final UploadController uploadController = Get.put(UploadController());

  late ValueNotifier<double> progressNotifier;

  @override
  void initState() {
    super.initState();
    initializeVideo();

    progressNotifier = ValueNotifier(0);

    /// Listen to upload progress
    ever(uploadController.uploadProgress, (value) {
      progressNotifier.value = value * 100;
    });
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
    progressNotifier.dispose();
    artistSongTextEditingControler.dispose();
    descriptionTextEditingControler.dispose();
    super.dispose();
  }

  Widget buildUploadProgress() {
    return SizedBox(
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SimpleCircularProgressBar(
            progressColors: const [
              Colors.purple,
              Colors.blue,
              Colors.cyan,
            ],
            size: 160,
            backColor: Colors.blueGrey,
            progressStrokeWidth: 12,
            backStrokeWidth: 12,
            valueNotifier: progressNotifier,
          ),

          const SizedBox(height: 20),

          Obx(() {
            if (uploadController.uploadProgress.value == 0) {
              return const Text(
                "Compressing video...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              );
            }

            return Text(
              "Uploading ${(uploadController.uploadProgress.value * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            );
          })
        ],
      ),
    );
  }

  Widget buildUploadForm() {
    return Column(
      children: [
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

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: InputTextWidget(
            textEditingController: descriptionTextEditingControler,
            labelString: "Description Tags",
            icondata: Icons.slideshow_sharp,
            isObscure: false,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          width: MediaQuery.of(context).size.width - 38,
          height: 50,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: InkWell(
            onTap: () async {
              if (artistSongTextEditingControler.text.isNotEmpty &&
                  descriptionTextEditingControler.text.isNotEmpty) {
                await uploadController.saveVideoInformationToSupabaseDatabase(
                  artistSongName: artistSongTextEditingControler.text,
                  descriptionTags: descriptionTextEditingControler.text,
                  videoFilePath: widget.videoPath,
                  context: context,
                );
              } else {
                Get.snackbar(
                  "Missing Fields",
                  "Please enter artist/song and description",
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
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

        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// VIDEO PREVIEW
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.3,
              child: isVideoInitialized
                  ? VideoPlayer(playerController!)
                  : const Center(child: CircularProgressIndicator()),
            ),

            const SizedBox(height: 30),

            /// UPLOAD UI
            Obx(() {
              if (uploadController.isUploading.value) {
                return buildUploadProgress();
              }
              return buildUploadForm();
            }),
          ],
        ),
      ),
    );
  }
}