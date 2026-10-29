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
  final streamsList = <SyllabusStream>[].obs;
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
        streamsList.assignAll(filterData.streams ?? []);
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
  final uploadSelectedStreamId = Rxn<int>();
  final uploadSelectedSectionIds = <int>[].obs;
  final uploadAttachments = <File>[].obs;

  // Dynamically Filter Streams, Sections, Subjects based on Selected Class & Stream
  List<SyllabusStream> get availableStreamsForSelectedClass {
    if (uploadSelectedClassId.value == null) return [];

    final classCombos = allowedCombinationsList
        .where((e) => e.classId == uploadSelectedClassId.value)
        .toList();

    final streamIds = classCombos
        .map((e) => e.streamId)
        .where((id) => id != null)
        .toSet();

    if (streamIds.isNotEmpty) {
      return streamsList.where((s) => s.id != null && streamIds.contains(s.id)).toList();
    }

    return [];
  }

  List<SyllabusSection> get availableSectionsForSelectedClassAndStream {
    if (uploadSelectedClassId.value == null) return [];

    var classCombos = allowedCombinationsList
        .where((e) => e.classId == uploadSelectedClassId.value)
        .toList();

    if (uploadSelectedStreamId.value != null) {
      classCombos = classCombos
          .where((e) => e.streamId == uploadSelectedStreamId.value || e.streamId == null)
          .toList();
    }

    final validSectionIds = classCombos
        .map((e) => e.sectionId)
        .whereType<int>()
        .toSet();

    if (validSectionIds.isNotEmpty) {
      return sectionsList.where((sec) => sec.id != null && validSectionIds.contains(sec.id)).toList();
    }

    return sectionsList;
  }

  List<SyllabusSubject> get availableSubjectsForSelectedClassAndStream {
    if (uploadSelectedClassId.value == null) return filterSubjectsList;

    var classCombos = allowedCombinationsList
        .where((e) => e.classId == uploadSelectedClassId.value)
        .toList();

    if (uploadSelectedStreamId.value != null) {
      classCombos = classCombos
          .where((e) => e.streamId == uploadSelectedStreamId.value || e.streamId == null)
          .toList();
    }

    final validSubjectIds = classCombos
        .map((e) => e.subjectId)
        .whereType<int>()
        .toSet();

    if (validSubjectIds.isNotEmpty) {
      return filterSubjectsList.where((sub) => sub.id != null && validSubjectIds.contains(sub.id)).toList();
    }

    return filterSubjectsList;
  }

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
    
    // Set Class, Stream and Sections from targets
    if (syllabus.targets != null && syllabus.targets!.isNotEmpty) {
      final firstTarget = syllabus.targets!.first;
      uploadSelectedClassId.value = firstTarget.classId;
      uploadSelectedStreamId.value = firstTarget.streamId;
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
    
    if (uploadTitleController.text.isEmpty) {
      Get.snackbar("Error", "Please enter a title", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }
    if (uploadSelectedTermId.value == null) {
      Get.snackbar("Error", "Please select a term", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }
    if (uploadSelectedClassId.value == null) {
      Get.snackbar("Error", "Please select a class", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }

    try {
      isLoading.value = true;
      
      final selectedClass = classesList.firstWhereOrNull((c) => c.id == uploadSelectedClassId.value);
      final selectedStream = streamsList.firstWhereOrNull((s) => s.id == uploadSelectedStreamId.value);

      final targets = [
        {
          "class_id": uploadSelectedClassId.value,
          "class_name": selectedClass?.name,
          "stream_id": uploadSelectedStreamId.value,
          "stream_name": selectedStream?.name,
          "section_ids": uploadSelectedSectionIds.toList(),
        }
      ];

      final targetsJson = jsonEncode(targets);

      debugPrint("==================== STORE TEACHER SYLLABUS ====================");
      debugPrint("Title: ${uploadTitleController.text}");
      debugPrint("Term ID: ${uploadSelectedTermId.value}");
      debugPrint("Class ID: ${uploadSelectedClassId.value} (${selectedClass?.name})");
      debugPrint("Stream ID: ${uploadSelectedStreamId.value} (${selectedStream?.name})");
      debugPrint("Section IDs: ${uploadSelectedSectionIds.toList()}");
      debugPrint("Subject ID: ${uploadSelectedSubjectId.value}");
      debugPrint("Targets JSON: $targetsJson");
      debugPrint("Attachments: ${uploadAttachments.map((f) => f.path).toList()}");
      debugPrint("==================================================================");

      final result = await _syllabusService.storeSyllabus(
        title: uploadTitleController.text,
        termId: uploadSelectedTermId.value!,
        description: uploadDescController.text,
        content: uploadContentController.text,
        targetsJson: targetsJson,
        subjectId: uploadSelectedSubjectId.value,
        attachments: uploadAttachments,
      );

      if (result.success == true) {
        Get.back();
        Get.snackbar("Success", result.message ?? "Syllabus uploaded successfully", 
            backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
        fetchTeacherSyllabus();
        _clearUploadForm();
      }
    } catch (e) {
      debugPrint("❌ [SyllabusController] Store Syllabus Error: $e");
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTeacherSyllabus() async {
    if (currentUpdateId.value == null) return;

    try {
      isLoading.value = true;
      
      final selectedClass = classesList.firstWhereOrNull((c) => c.id == uploadSelectedClassId.value);
      final selectedStream = streamsList.firstWhereOrNull((s) => s.id == uploadSelectedStreamId.value);

      final targets = [
        {
          "class_id": uploadSelectedClassId.value,
          "class_name": selectedClass?.name,
          "stream_id": uploadSelectedStreamId.value,
          "stream_name": selectedStream?.name,
          "section_ids": uploadSelectedSectionIds.toList(),
        }
      ];

      final targetsJson = jsonEncode(targets);

      debugPrint("==================== UPDATE TEACHER SYLLABUS ====================");
      debugPrint("Update ID: ${currentUpdateId.value}");
      debugPrint("Title: ${uploadTitleController.text}");
      debugPrint("Term ID: ${uploadSelectedTermId.value}");
      debugPrint("Class ID: ${uploadSelectedClassId.value} (${selectedClass?.name})");
      debugPrint("Stream ID: ${uploadSelectedStreamId.value} (${selectedStream?.name})");
      debugPrint("Section IDs: ${uploadSelectedSectionIds.toList()}");
      debugPrint("Subject ID: ${uploadSelectedSubjectId.value}");
      debugPrint("Targets JSON: $targetsJson");
      debugPrint("New Attachments: ${uploadAttachments.map((f) => f.path).toList()}");
      debugPrint("Delete Attachments: $deleteAttachmentPaths");
      debugPrint("==================================================================");

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
            backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
        fetchTeacherSyllabus();
        clearUploadMode();
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
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
          dynamic rawStatus;
          if (data is Map && data['status'] != null) {
            rawStatus = data['status'];
          } else if (data != null && data is! Map) {
            rawStatus = data;
          }
          final currentStatus = teacherSyllabusList[index].status ?? 1;
          final fallbackStatus = (currentStatus == 1) ? 0 : 1;
          final parsed = SyllabusData.parseStatus(rawStatus, defaultValue: fallbackStatus);
          teacherSyllabusList[index].status = parsed;
          teacherSyllabusList.refresh();
        }
        Get.snackbar(
          "Status Updated",
          result['message'] ?? "Syllabus status toggled",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        final int index = teacherSyllabusList.indexWhere((e) => e.id == id);
        if (index != -1) {
          final current = teacherSyllabusList[index].status ?? 1;
          teacherSyllabusList[index].status = (current == 1) ? 0 : 1;
          teacherSyllabusList.refresh();
        }
        Get.snackbar(
          "Error",
          result['message'] ?? "Failed to update status",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      final int index = teacherSyllabusList.indexWhere((e) => e.id == id);
      if (index != -1) {
        final current = teacherSyllabusList[index].status ?? 1;
        teacherSyllabusList[index].status = (current == 1) ? 0 : 1;
        teacherSyllabusList.refresh();
      }
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
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
    uploadSelectedStreamId.value = null;
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
      Get.snackbar("Error", "Please select Class and Section", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
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
        snackPosition: SnackPosition.TOP);
  }
}
