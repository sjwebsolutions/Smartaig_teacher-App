import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../api_service/homework_service.dart';
import '../models/homework_form_data_model.dart';
import '../models/homework_model.dart';
import '../services/fcm_services.dart';
import 'announcement_controller.dart';

class HomeworkController extends GetxController {
  final HomeworkService _homeworkService = HomeworkService();
  
  final isLoading = true.obs;
  final isPosting = false.obs;
  final hasFetched = false.obs; // New flag to track if first fetch is done
  final homeworkFormData = Rxn<HomeworkFormDataModel>();
  final homeworkList = <HomeworkData>[].obs;
  final homeworkDetail = Rxn<HomeworkData>();
  
  // Selection logic
  final selectedClassId = Rxn<String>();
  final selectedSectionId = Rxn<String>(); // Keeping for single selection if needed
  final selectedSectionIds = <String>[].obs; // For multi-selection
  final selectedSubjectId = Rxn<int>();
  final selectedStreamId = Rxn<String>();
  final isDiary = false.obs;

  // Images
  final images = <File>[].obs;
  final existingAttachments = <dynamic>[].obs; // For network images during edit
  final ImagePicker _picker = ImagePicker();

  // Edit logic
  final isEditing = false.obs;
  final editingId = Rxn<int>();
  final editingDate = Rxn<String>();
  
  final homeworkContentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchHomeworkFormData();
    fetchHomeworkList();
  }

  Future<void> fetchHomeworkFormData() async {
    try {
      isLoading.value = true;
      final result = await _homeworkService.getHomeworkFormData();
      homeworkFormData.value = result;
    } catch (e) {
      Get.snackbar(
        "Message",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHomeworkList() async {
    try {
      isLoading.value = true;
      final result = await _homeworkService.getHomeworkList();
      if (result.success == true) {
        homeworkList.assignAll(result.data ?? []);
        hasFetched.value = true; // Mark as successfully fetched
      } else {
        Get.snackbar(
          "Error",
          result.message ?? "Failed to fetch homework list",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error fetching homework list: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch homework list: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      // Small delay to ensure UI transition is smooth and not flickering
      Future.delayed(const Duration(milliseconds: 300), () {
        isLoading.value = false;
      });
    }
  }

  Future<void> fetchHomeworkDetail(int id) async {
    try {
      homeworkDetail.value = null; // Clear previous data
      isLoading.value = true;
      final result = await _homeworkService.getHomeworkById(id);
      if (result.success == true) {
        homeworkDetail.value = result.data;
      } else {
        Get.snackbar("Error", result.message ?? "Failed to fetch details");
      }
    } catch (e) {
      print("Error fetching homework detail: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteHomework(int id) async {
    try {
      isLoading.value = true;
      final success = await _homeworkService.deleteHomework(id);
      if (success) {
        Get.snackbar(
          "Success",
          "Homework deleted successfully.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchHomeworkList();
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onSubjectChanged(int? subjectId) {
    selectedSubjectId.value = subjectId;
    
    // Find the item to check if it's a diary item
    final lookupId = (subjectId == -1) ? null : subjectId;
    final item = subjectsForSelectedSelection.firstWhereOrNull((e) => e.subjectId == lookupId);
    
    // Set isDiary to true if subjectId is null/-1 OR if the subject name contains "Diary"
    if (subjectId == null || subjectId == -1 || 
        (item?.subjectName?.toLowerCase().contains("diary") ?? false)) {
      isDiary.value = true;
    } else {
      isDiary.value = false;
    }

    if (item != null) {
      selectedStreamId.value = item.streamId;
    }
  }

  Future<void> pickImages([ImageSource source = ImageSource.gallery]) async {
    if (source == ImageSource.gallery) {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        images.addAll(pickedFiles.map((file) => File(file.path)));
      }
    } else {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        images.add(File(pickedFile.path));
      }
    }
  }

  void removeImage(int index) {
    images.removeAt(index);
  }

  Future<void> postHomework() async {
    final String content = homeworkContentController.text.trim();
    final bool hasImages = images.isNotEmpty;

    if (selectedClassId.value == null || 
        (selectedSectionId.value == null && selectedSectionIds.isEmpty)) {
      Get.snackbar("Required", "Please select Class and Section");
      return;
    }

    if (content.isEmpty && !hasImages) {
      Get.snackbar("Required", "Please enter homework details or add an image");
      return;
    }

    if (!isDiary.value && selectedSubjectId.value == null) {
      Get.snackbar("Required", "Please select a subject for Subject Homework");
      return;
    }

    try {
      isPosting.value = true;
      
      final List<String> sectionIds = selectedSectionIds.isNotEmpty 
          ? selectedSectionIds 
          : [selectedSectionId.value!];

      HomeworkResponseModel response;
      if (isEditing.value && editingId.value != null) {
        response = await _homeworkService.updateHomework(
          id: editingId.value!,
          classId: selectedClassId.value!,
          sectionIds: sectionIds,
          subjectId: isDiary.value ? null : selectedSubjectId.value,
          streamId: selectedStreamId.value,
          content: homeworkContentController.text.trim(),
          date: editingDate.value,
          isDiary: isDiary.value,
          attachments: images,
          existingAttachments: existingAttachments,
        );
      } else {
        response = await _homeworkService.postHomework(
          classId: selectedClassId.value!,
          sectionIds: sectionIds,
          subjectId: isDiary.value ? null : selectedSubjectId.value,
          streamId: selectedStreamId.value,
          content: homeworkContentController.text.trim(),
          isDiary: isDiary.value,
          attachments: images,
        );
      }

      if (response.success == true) {
        // Get subject name for notification
        String subjectName = isDiary.value ? "Class Diary" : "Homework";
        if (!isDiary.value && selectedSubjectId.value != null) {
          final subject = subjectsForSelectedSelection.firstWhereOrNull((s) => s.subjectId == selectedSubjectId.value);
          if (subject != null) subjectName = subject.subjectName ?? "Homework";
        }

        // Trigger local notification
        await FcmService.showLocalNotification(
          title: isEditing.value ? "Homework Updated" : "Homework Submitted",
          body: isEditing.value
              ? "$subjectName has been successfully updated."
              : "$subjectName has been successfully posted to selected sections.",
        );

        // Update notification dot in app bar
        if (Get.isRegistered<AnnouncementController>()) {
          Get.find<AnnouncementController>().hasNewNotifications.value = true;
        }

        Get.back(); // Return to list
        Get.snackbar(
          "Success",
          response.message ?? "Homework saved successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        final int? currentDetailId = homeworkDetail.value?.id;
        clearForm();
        isLoading.value = true; // Set loading BEFORE clearing
        hasFetched.value = false; // Reset fetch state to show loader
        homeworkList.clear(); 
        await fetchHomeworkList();
        
        // If we were viewing details of the same homework, refresh it
        if (currentDetailId != null) {
          await fetchHomeworkDetail(currentDetailId);
        }
      }
    } catch (e) {
      String errorMsg = e.toString();
      
      Get.snackbar(
        "Message",
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isPosting.value = false;
    }
  }

  void prepareEdit(HomeworkData homework) {
    isEditing.value = true;
    editingId.value = homework.id;
    editingDate.value = homework.date;
    selectedClassId.value = homework.classId;
    selectedSectionId.value = homework.sectionId;
    if (homework.sectionId != null) {
      selectedSectionIds.assignAll([homework.sectionId!]);
    }
    selectedSubjectId.value = homework.subjectId;
    selectedStreamId.value = homework.streamId;
    isDiary.value = homework.isDiary ?? false;
    homeworkContentController.text = homework.content ?? "";
    
    // Load existing images
    images.clear();
    existingAttachments.assignAll(homework.attachments ?? []);
  }

  void removeExistingImage(int index) {
    existingAttachments.removeAt(index);
  }

  void clearForm() {
    isEditing.value = false;
    editingId.value = null;
    editingDate.value = null;
    selectedClassId.value = null;
    selectedSectionId.value = null;
    selectedSectionIds.clear();
    selectedSubjectId.value = null;
    selectedStreamId.value = null;
    isDiary.value = false;
    images.clear();
    existingAttachments.clear();
    homeworkContentController.clear();
  }

  bool get isTodayHomeworkAdded {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return homeworkList.any((h) => h.date == today);
  }

  void handleAddHomework() {
    clearForm();
    Get.toNamed('/addHomework');
  }

  // Helper to get unique classes
  List<HomeworkClassData> get uniqueClasses {
    final seen = <String>{};
    final data = homeworkFormData.value?.data ?? [];
    return data.where((item) => seen.add(item.classId ?? "")).toList();
  }

  // Helper to get sections for selected class
  List<HomeworkClassData> get sectionsForSelectedClass {
    if (selectedClassId.value == null) return [];
    final seen = <String>{};
    final data = homeworkFormData.value?.data ?? [];
    return data
        .where((item) => item.classId == selectedClassId.value)
        .where((item) => seen.add(item.sectionId ?? ""))
        .toList();
  }

  // Helper to get subjects for selected class & section
  List<HomeworkClassData> get subjectsForSelectedSelection {
    if (selectedClassId.value == null || selectedSectionId.value == null) return [];
    final data = homeworkFormData.value?.data ?? [];
    
    // Filtering by class and section
    final filtered = data.where((item) {
      return item.classId.toString() == selectedClassId.value.toString() && 
             item.sectionId.toString() == selectedSectionId.value.toString();
    }).toList();
    
    // Ensure uniqueness by subjectId AND subjectName to avoid duplicates and show all
    final seen = <String>{};
    final uniqueSubjects = <HomeworkClassData>[];
    
    for (var item in filtered) {
      // Create a unique key using ID and Name
      final id = item.subjectId?.toString() ?? "no-id";
      final name = item.subjectName ?? "Unknown";
      final key = "${id}_${name}";

      if (seen.add(key)) {
        uniqueSubjects.add(item);
      }
    }
    
    return uniqueSubjects;
  }
}
