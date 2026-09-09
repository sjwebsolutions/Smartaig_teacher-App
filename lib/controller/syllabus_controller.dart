import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api_service/homework_service.dart';
import '../api_service/syllabus_service.dart';
import '../models/homework_form_data_model.dart';
import '../models/syllabus_model.dart';
import '../models/syllabus_form_data_model.dart';
import '../services/fcm_services.dart';
import 'announcement_controller.dart';

class SyllabusController extends GetxController {
  final HomeworkService _homeworkService = HomeworkService();
  final SyllabusService _syllabusService = SyllabusService();
  
  final isLoading = false.obs;
  final isFiltersLoading = false.obs;
  final errorMessage = "".obs;
  final hasFetched = false.obs;
  
  // For Teacher Syllabus
  final teacherSyllabusList = <SyllabusData>[].obs;

  // Filter values (For Teacher Syllabus)
  final filterTermId = Rxn<int>();
  final filterClassId = Rxn<int>();
  final filterSubjectId = Rxn<int>();

  // Filter Data (Strongly Typed from Form Data)
  final termsList = <SyllabusTerm>[].obs;
  final classesList = <SyllabusClass>[].obs;
  final filterSubjectsList = <SyllabusSubject>[].obs;
  final sectionsList = <SyllabusSection>[].obs;
  final allowedCombinationsList = <AllowedCombination>[].obs;
  
  // Settings from Form Data
  final canUpload = false.obs;
  final uploadMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    _fetchHomeworkFormData();
  }

  Future<void> fetchInitialData() async {
    await fetchFiltersData();
    await fetchTeacherSyllabus();
  }

  Future<void> fetchFiltersData() async {
    try {
      isFiltersLoading.value = true;
      final formDataResult = await _syllabusService.getSyllabusFormData();
      if (formDataResult.success == true && formDataResult.data != null) {
        final filterData = formDataResult.data!;
        termsList.assignAll(filterData.terms ?? []);
        classesList.assignAll(filterData.classes ?? []);
        filterSubjectsList.assignAll(filterData.subjects ?? []);
        sectionsList.assignAll(filterData.sections ?? []);
        allowedCombinationsList.assignAll(filterData.allowedCombinations ?? []);
        canUpload.value = filterData.canUpload ?? false;
        uploadMessage.value = filterData.message ?? "";
      }
    } catch (e) {
      debugPrint("Error fetching syllabus filters: $e");
    } finally {
      isFiltersLoading.value = false;
    }
  }

  Future<void> fetchTeacherSyllabus() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      final result = await _syllabusService.getTeacherSyllabus(
        termId: filterTermId.value,
        classId: filterClassId.value,
        subjectId: filterSubjectId.value,
      );
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

  final selectedSyllabus = Rxn<SyllabusData>();
  Future<void> fetchSyllabusById(int id) async {
    try {
      isLoading.value = true;
      final result = await _syllabusService.getSyllabusById(id);
      if (result.success == true && result.data != null && result.data!.isNotEmpty) {
        selectedSyllabus.value = result.data!.first;
      }
    } catch (e) {
      debugPrint("Error fetching specific syllabus: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- Methods for Uploading Syllabus ---
  final uploadTitleController = TextEditingController();
  final uploadDescController = TextEditingController();
  final uploadContentController = TextEditingController();
  final uploadSelectedTermId = Rxn<int>();
  final uploadSelectedSubjectId = Rxn<int>();
  final uploadSelectedClassId = Rxn<int>();
  final uploadSelectedSectionIds = <int>[].obs;
  final uploadAttachments = <File>[].obs;

  // For Update
  final isUpdateMode = false.obs;
  final currentUpdateId = Rxn<int>();
  final existingAttachments = <Attachments>[].obs;
  final deleteAttachmentPaths = <String>[].obs;

  void prepareSyllabusUpdate(SyllabusData syllabus) {
    isUpdateMode.value = true;
    currentUpdateId.value = syllabus.id;
    
    uploadTitleController.text = syllabus.title ?? "";
    uploadDescController.text = syllabus.description ?? "";
    uploadContentController.text = syllabus.content ?? "";
    
    uploadSelectedTermId.value = syllabus.term?.id;
    uploadSelectedSubjectId.value = syllabus.subject?.id;
    
    // Set Class and Sections from targets
    if (syllabus.targets != null && syllabus.targets!.isNotEmpty) {
      final firstTarget = syllabus.targets!.first;
      uploadSelectedClassId.value = firstTarget.classId;
      uploadSelectedSectionIds.assignAll(
        firstTarget.sectionIds?.map((e) => int.tryParse(e.toString()) ?? 0).where((e) => e != 0).toList() ?? []
      );
    }

    existingAttachments.assignAll(syllabus.attachments ?? []);
    deleteAttachmentPaths.clear();
    uploadAttachments.clear();

    Get.toNamed('/uploadSyllabus');
  }

  Future<void> storeTeacherSyllabus() async {
    if (isUpdateMode.value) {
      await updateTeacherSyllabus();
      return;
    }
    
    print("--- START STORE SYLLABUS ---");
    if (uploadTitleController.text.isEmpty) {
      print("Validation Error: Title is empty");
      Get.snackbar("Error", "Please enter a title", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (uploadSelectedTermId.value == null) {
      print("Validation Error: Term not selected");
      Get.snackbar("Error", "Please select a term", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (uploadSelectedClassId.value == null) {
      print("Validation Error: Class not selected");
      Get.snackbar("Error", "Please select a class", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      
      // Construct targets JSON
      final targets = [
        {
          "class_id": uploadSelectedClassId.value,
          "stream_id": null,
          "section_ids": uploadSelectedSectionIds.toList(),
        }
      ];

      final targetsJson = jsonEncode(targets);
      print("Constructed Targets JSON: $targetsJson");
      print("Uploading with: Title=${uploadTitleController.text}, Term=${uploadSelectedTermId.value}, Subject=${uploadSelectedSubjectId.value}");
      print("Attachments Count: ${uploadAttachments.length}");

      final result = await _syllabusService.storeSyllabus(
        title: uploadTitleController.text,
        termId: uploadSelectedTermId.value!,
        description: uploadDescController.text,
        content: uploadContentController.text,
        targetsJson: targetsJson,
        subjectId: uploadSelectedSubjectId.value,
        attachments: uploadAttachments,
      );

      print("Upload Result Success: ${result.success}");

      if (result.success == true) {
        Get.back();
        Get.snackbar("Success", result.message ?? "Syllabus uploaded successfully", 
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchTeacherSyllabus(); // Refresh list
        _clearUploadForm();
      }
    } catch (e) {
      print("EXCEPTION DURING UPLOAD: $e");
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      print("--- END STORE SYLLABUS ---");
    }
  }

  Future<void> updateTeacherSyllabus() async {
    if (currentUpdateId.value == null) return;

    try {
      isLoading.value = true;
      
      final targets = [
        {
          "class_id": uploadSelectedClassId.value,
          "stream_id": null,
          "section_ids": uploadSelectedSectionIds.toList(),
        }
      ];

      final result = await _syllabusService.updateSyllabus(
        id: currentUpdateId.value!,
        title: uploadTitleController.text,
        termId: uploadSelectedTermId.value!,
        description: uploadDescController.text,
        content: uploadContentController.text,
        targetsJson: jsonEncode(targets),
        subjectId: uploadSelectedSubjectId.value,
        attachments: uploadAttachments,
        deleteAttachmentPaths: deleteAttachmentPaths,
      );

      if (result.success == true) {
        Get.back();
        Get.snackbar("Success", result.message ?? "Syllabus updated successfully", 
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchTeacherSyllabus();
        clearUploadMode();
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleSyllabusStatus(int id) async {
    try {
      final result = await _syllabusService.toggleSyllabusStatus(id);
      if (result['success'] == true) {
        final data = result['data'];
        final int index = teacherSyllabusList.indexWhere((e) => e.id == id);
        if (index != -1) {
          teacherSyllabusList[index].status = data['status'];
          teacherSyllabusList.refresh();
        }
        Get.snackbar("Status Updated", result['message'] ?? "Syllabus status toggled",
            backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void clearUploadMode() {
    isUpdateMode.value = false;
    currentUpdateId.value = null;
    existingAttachments.clear();
    deleteAttachmentPaths.clear();
    _clearUploadForm();
  }

  void _clearUploadForm() {
    uploadTitleController.clear();
    uploadDescController.clear();
    uploadContentController.clear();
    uploadSelectedTermId.value = null;
    uploadSelectedSubjectId.value = null;
    uploadSelectedClassId.value = null;
    uploadSelectedSectionIds.clear();
    uploadAttachments.clear();
  }

  void resetFilters() {
    filterTermId.value = null;
    filterClassId.value = null;
    filterSubjectId.value = null;
    fetchTeacherSyllabus();
  }

  // --- Methods for Syllabus Tracker (Existing functionality) ---
  final homeworkFormData = Rxn<HomeworkFormDataModel>();
  final selectedClassId = Rxn<String>();
  final selectedSectionId = Rxn<String>();
  final subjects = ["English", "Maths", "Science", "History", "Physics"].obs;
  final selectedSubject = "English".obs;
  final syllabusTrackerList = <Map<String, dynamic>>[].obs;
  final chapterController = TextEditingController();
  final topicController = TextEditingController();

  Future<void> _fetchHomeworkFormData() async {
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
    return syllabusTrackerList
        .where((item) => item['subject'] == selectedSubject.value)
        .toList();
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

    syllabusTrackerList.insert(0, {
      'subject': selectedSubject.value,
      'title': chapterController.text,
      'subtitle': topicController.text,
      'status': 'pending',
    });

    final String topic = topicController.text;
    chapterController.clear();
    topicController.clear();

    await FcmService.showLocalNotification(
      title: "Syllabus Updated",
      body: "New topic '$topic' has been added to the syllabus.",
    );

    if (Get.isRegistered<AnnouncementController>()) {
      Get.find<AnnouncementController>().hasNewNotifications.value = true;
    }

    Get.back();
    Get.snackbar("Success", "Syllabus topic added successfully",
        backgroundColor: Colors.green, colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  }
}
