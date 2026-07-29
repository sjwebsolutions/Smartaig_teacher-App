import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teacher_app_attendance/utils/app_snackbar.dart';

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  var selectedImagePath = "".obs;
  var isImageUpdating = false.obs;

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );
      if (image != null) {
        selectedImagePath.value = image.path;
        // In a real app, you would upload this image to the server here
        _updateProfileImage(File(image.path));
      }
    } catch (e) {
      AppSnackBar.error("Error picking image: $e");
    }
  }

  Future<void> _updateProfileImage(File imageFile) async {
    isImageUpdating.value = true;
    try {
      // Simulate API call to upload image
      await Future.delayed(const Duration(seconds: 2));
      AppSnackBar.success("Profile image updated successfully");
    } catch (e) {
      AppSnackBar.error("Failed to update profile image");
    } finally {
      isImageUpdating.value = false;
    }
  }
}
