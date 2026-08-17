import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api_service/image_update_service.dart';
import '../models/image_update_classes_model.dart';
import '../models/image_update_students_model.dart';
import '../services/fcm_services.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import 'announcement_controller.dart';

class ImageUpdateController extends GetxController {
  final ImageUpdateService _service = ImageUpdateService();
  
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final classesList = <ImageUpdateClassData>[].obs;
  final studentsList = <ImageUpdateStudentData>[].obs;
  final errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      final result = await _service.getImageUpdateClasses();
      if (result.success == true) {
        classesList.assignAll(result.data ?? []);
      } else {
        errorMessage.value = "Failed to load classes";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStudents(int classId, int sectionId, int? streamId) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      studentsList.clear();
      final result = await _service.getImageUpdateStudents(classId, sectionId, streamId);
      if (result.success == true) {
        studentsList.assignAll(result.data ?? []);
      } else {
        errorMessage.value = "Failed to load students";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitRequest({
    required int studentId,
    String? profileImage,
    String? fatherImage,
    String? motherImage,
    VoidCallback? onSuccess,
  }) async {
    if (profileImage == null && fatherImage == null && motherImage == null) {
      Get.snackbar("Error", "Please select at least one image", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isSubmitting.value = true;
      final success = await _service.storeImageUpdate(
        studentId: studentId,
        profileImagePath: profileImage,
        fatherImagePath: fatherImage,
        motherImagePath: motherImage,
      );

      if (success) {
        // Trigger local notification and sound
        await FcmService.showLocalNotification(
          title: "Update Request Submitted",
          body: "The student image update request has been successfully sent for approval.",
        );

        // Update notification dot in app bar
        if (Get.isRegistered<AnnouncementController>()) {
          Get.find<AnnouncementController>().hasNewNotifications.value = true;
        }

        if (onSuccess != null) onSuccess();
        
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar(
            "Success", 
            "Image update request submitted successfully", 
            backgroundColor: Colors.green, 
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(15),
            duration: const Duration(seconds: 3),
          );
        });
      } else {
        Get.snackbar(
          "Error", 
          "Failed to submit request", 
          backgroundColor: Colors.red, 
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }
}
