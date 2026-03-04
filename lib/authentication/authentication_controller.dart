import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AuthenticationController extends GetxController {
  final Rx<File?> _pickedFile = Rx<File?>(null);
  File? get profileImage => _pickedFile.value;

  static AuthenticationController instanceAuth = Get.find();

  // Pick image from gallery
  Future<void> chooseImageFromGallery() async {
    final pickedImageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImageFile != null) {
      _pickedFile.value = File(pickedImageFile.path);
      Get.snackbar(
        "Profile Image",
        "You have successfully selected your profile image from gallery",
      );
    }
  }

  // Capture image from camera
Future<void> captureImageWithCamera() async {
    final pickedImageFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (pickedImageFile != null) {
      _pickedFile.value = File(pickedImageFile.path);
      Get.snackbar(
        "Profile Image",
        "You have successfully captured your profile image with the camera",
      );
    }
  }
}