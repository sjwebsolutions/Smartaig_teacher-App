import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api_service/homework_service.dart';
import '../models/homework_form_data_model.dart';

class SyllabusController extends GetxController {
  final HomeworkService _homeworkService = HomeworkService();
  
  final isLoading = false.obs;
  final homeworkFormData = Rxn<HomeworkFormDataModel>();
  
  final selectedClassId = Rxn<String>();
  final selectedSectionId = Rxn<String>();
  
  // Hardcoded data as requested initially
  final subjects = ["English", "Maths", "Science", "History", "Physics"].obs;
  final selectedSubject = "English".obs;

  final syllabusList = <Map<String, dynamic>>[].obs;

  final chapterController = TextEditingController();
  final topicController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchFormData();
  }

  Future<void> fetchFormData() async {
    try {
      isLoading.value = true;
      final result = await _homeworkService.getHomeworkFormData();
      homeworkFormData.value = result;
    } catch (e) {
      print("Error fetching syllabus form data: $e");
    } finally {
      isLoading.value = false;
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
}
