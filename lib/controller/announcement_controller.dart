import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api_service/announcement_service.dart';
import '../models/announcement_model.dart';
import '../services/fcm_services.dart';
import '../themes/appColors_&_styles/app_Colors.dart';

class AnnouncementController extends GetxController {
  final AnnouncementService _service = AnnouncementService();

  final announcements = Rxn<AnnouncementModel>();
  final isLoading = false.obs;
  final hasNewNotifications = false.obs;
  final selectedAnnouncement = Rxn<AnnouncementData>();
  final isExpanded = false.obs;

  // Management related
  final canManage = false.obs;
  final managedAnnouncements = Rxn<AnnouncementModel>();
  final isManagedLoading = false.obs;
  final announcementTypes = <Map<String, dynamic>>[].obs;
  final targetingData = <String, dynamic>{}.obs;
  final isCreating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncements();
    fetchManagementData();
  }

  Future<void> fetchAnnouncements() async {
    try {
      isLoading.value = true;
      final result = await _service.getAnnouncements();
      if (result.data != null && result.data!.isNotEmpty) {
        if (announcements.value == null || 
            announcements.value!.data?.length != result.data?.length) {
          hasNewNotifications.value = true;
        }
      }
      announcements.value = result;
    } catch (e) {
      print("Error fetching announcements: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchManagementData() async {
    // Stub for now, or implement if service methods exist
    try {
      // Logic to fetch types and targeting data
      // For now, let's provide some default data to avoid errors if API is not ready
      announcementTypes.value = [
        {'id': 1, 'name': 'General'},
        {'id': 2, 'name': 'Urgent'},
        {'id': 3, 'name': 'Holiday'},
      ];
      targetingData.value = {
        'classes': [
          {'id': 1, 'name': 'Class 1'},
          {'id': 2, 'name': 'Class 2'},
        ]
      };
    } catch (e) {
      print("Error fetching management data: $e");
    }
  }

  Future<bool> createAnnouncement(Map<String, dynamic> data, {String? imagePath}) async {
    try {
      isCreating.value = true;
      await _service.createAnnouncement(data, imagePath: imagePath);
      await fetchAnnouncements();

      // Trigger local notification and sound
      await FcmService.showLocalNotification(
        title: "Announcement Created",
        body: "The new announcement has been successfully posted.",
      );

      // Update notification dot in app bar
      hasNewNotifications.value = true;

      Get.snackbar("Success", "Announcement created successfully", 
          backgroundColor: AppColors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), 
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  void markAsRead() {
    hasNewNotifications.value = false;
  }
}
