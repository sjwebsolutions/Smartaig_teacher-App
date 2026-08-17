import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api_service/homework_service.dart';
import '../api_service/syllabus_service.dart';
import '../models/homework_form_data_model.dart';
import '../models/syllabus_model.dart';
import '../services/fcm_services.dart';
import 'announcement_controller.dart';

class SyllabusController extends GetxController {
  final HomeworkService _homeworkService = HomeworkService();
  final SyllabusService _syllabusService = SyllabusService();
  
  final isLoading = false.obs;
  final errorMessage = "".obs;
  final hasFetched = false.obs;
  
  // For Syllabus Tracker
  final homeworkFormData = Rxn<HomeworkFormDataModel>();
  final selectedClassId = Rxn<String>();
  final selectedSectionId = Rxn<String>();
  final subjects = ["English", "Maths", "Science", "History", "Physics"].obs;
  final selectedSubject = "English".obs;
  final syllabusList = <Map<String, dynamic>>[].obs;
  final chapterController = TextEditingController();
  final topicController = TextEditingController();

  // For Teacher Syllabus
  final teacherSyllabusList = <SyllabusData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTeacherSyllabus();
    _fetchFormDataInternal();
  }

  Future<void> fetchTeacherSyllabus() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      final result = await _syllabusService.getTeacherSyllabus();
      if (result.success == true) {
        teacherSyllabusList.assignAll(result.data ?? []);
        hasFetched.value = true;
      } else {
        errorMessage.value = "Failed to load syllabus data";
      }
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint("Error fetching teacher syllabus: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchFormDataInternal() async {
    try {
      final result = await _homeworkService.getHomeworkFormData();
      homeworkFormData.value = result;
    } catch (e) {
      debugPrint("Error fetching syllabus form data: $e");
    }
  }

  List<HomeworkClassData> get uniqueClasses {
    final seen = <String>{};
    final data = homeworkFormData.value?.data ?? [];
    return data.where((item) => seen.add(item.classId ?? "")).toList();
  }

  List<HomeworkClassData> get sectionsForSelectedClass {
    if (selectedClassId.value == null) return [];
    final seen = <String>{};
    final data = homeworkFormData.value?.data ?? [];
    return data
        .where((item) => item.classId == selectedClassId.value)
        .where((item) => seen.add(item.sectionId ?? ""))
        .toList();
  }

  List<Map<String, dynamic>> get filteredSyllabusList {
    return syllabusList.where((item) => item['subject'] == selectedSubject.value).toList();
  }

  Future<void> saveSyllabusTopic() async {
    if (selectedClassId.value == null || selectedSectionId.value == null) {
      Get.snackbar("Error", "Please select Class and Section", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (chapterController.text.isEmpty || topicController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Add to local list (Mock logic as seen in UI)
    syllabusList.insert(0, {
      'subject': selectedSubject.value,
      'title': chapterController.text,
      'subtitle': topicController.text,
      'status': 'pending',
    });

    final String topic = topicController.text;

    chapterController.clear();
    topicController.clear();

    // Trigger local notification and sound
    await FcmService.showLocalNotification(
      title: "Syllabus Updated",
      body: "New topic '$topic' has been added to the syllabus.",
    );

    // Update notification dot in app bar
    if (Get.isRegistered<AnnouncementController>()) {
      Get.find<AnnouncementController>().hasNewNotifications.value = true;
    }

    Get.back(); // Go back to tracker
    
    Get.snackbar("Success", "Syllabus topic added successfully",
        backgroundColor: Colors.green, colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  }
}
