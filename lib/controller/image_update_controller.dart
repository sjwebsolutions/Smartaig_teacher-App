import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../api_service/image_update_service.dart';
import '../models/image_update_classes_model.dart';
import '../models/image_update_students_model.dart';
import '../services/fcm_services.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import 'announcement_controller.dart';

class ImageUpdateController extends GetxController {
  final ImageUpdateService _service = ImageUpdateService();
  final _storage = const FlutterSecureStorage();
  
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final classesList = <ImageUpdateClassData>[].obs;
  final studentsList = <ImageUpdateStudentData>[].obs;
  final errorMessage = "".obs;

  // Store image paths: { "studentId_type": "path" }
  final capturedImages = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    try {
      String? data = await _storage.read(key: 'captured_images');
      if (data != null) {
        Map<String, dynamic> decoded = jsonDecode(data);
        capturedImages.assignAll(decoded.cast<String, String>());
      }
    } catch (e) {
      debugPrint("Error loading saved images: $e");
    }
  }

  Future<String?> saveCapturedImage(int studentId, String type, String path) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = "${studentId}_${type}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final String permanentPath = "${appDir.path}/$fileName";
      
      // Copy the file to permanent storage
      File tempFile = File(path);
      if (await tempFile.exists()) {
        // Delete old image if it exists
        String? oldPath = getCapturedImage(studentId, type);
        if (oldPath != null) {
          File oldFile = File(oldPath);
          if (await oldFile.exists()) {
            try {
              await oldFile.delete();
            } catch (e) {
              debugPrint("Error deleting old file: $e");
            }
          }
        }
        
        await tempFile.copy(permanentPath);
        
        String key = "${studentId}_$type";
        capturedImages[key] = permanentPath;
        await _storage.write(key: 'captured_images', value: jsonEncode(capturedImages.value));
        return permanentPath;
      }
    } catch (e) {
      debugPrint("Error saving image path: $e");
    }
    return null;
  }

  String? getCapturedImage(int studentId, String type) {
    return capturedImages["${studentId}_$type"];
  }

  void clearCapturedImages(int studentId) {
    capturedImages.remove("${studentId}_profile");
    capturedImages.remove("${studentId}_father");
    capturedImages.remove("${studentId}_mother");
    _storage.write(key: 'captured_images', value: jsonEncode(capturedImages.value));
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
