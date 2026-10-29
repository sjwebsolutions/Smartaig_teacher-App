import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teacher_app_attendance/utils/app_snackbar.dart';
import '../controller/dashboard_controller.dart';
import '../services/storage_services.dart';
import '../view/widgets/custom_crop_screen.dart';

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  var selectedImagePath = "".obs;
  var isImageUpdating = false.obs;

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image != null) {
        if (source == ImageSource.gallery) {
          final croppedResult = await Get.to(() => ImageCropScreen(imageFile: File(image.path)));
          if (croppedResult != null && croppedResult is XFile) {
            selectedImagePath.value = croppedResult.path;
            _updateProfileImage(File(croppedResult.path));
          }
        } else {
          selectedImagePath.value = image.path;
          _updateProfileImage(File(image.path));
        }
      }
    } catch (e) {
      AppSnackBar.error("Error picking image: $e");
    }
  }

  Future<void> _updateProfileImage(File imageFile) async {
    isImageUpdating.value = true;
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      try {
        final dir = await getApplicationDocumentsDirectory();
        final targetPath = '${dir.path}/teacher_profile_cache.jpg';
        await imageFile.copy(targetPath);
        await StorageService.saveProfileImagePath(targetPath);
        
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().localProfileImagePath.value = targetPath;
        }
      } catch (e) {
        print("Error saving picked image locally: $e");
      }

      AppSnackBar.success("Profile image updated successfully");
    } catch (e) {
      AppSnackBar.error("Failed to update profile image");
    } finally {
      isImageUpdating.value = false;
    }
  }
}
