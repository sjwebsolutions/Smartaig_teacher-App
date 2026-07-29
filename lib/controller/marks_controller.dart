import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/marks_model.dart';
import '../models/marks_entry_model.dart';
import '../models/marks_entry_classes_model.dart';
import '../models/marks_save_model.dart';
import '../models/marks_student_model.dart';
import '../api_service/marks_service.dart';
import '../services/fcm_services.dart';

class MarksController extends GetxController {
  final MarksService _marksService = MarksService();
  var savedMarks = <MarksModel>[].obs;
  var marksEntries = <MarksEntryData>[].obs;
  var marksEntryClasses = <MarksEntryClassData>[].obs;
  var studentsList = <StudentMarkData>[].obs;
  var subjectList = <SubjectData>[].obs;
  var gradeList = <GradeData>[].obs;
  var isLocked = false.obs;
  
  var isLoading = false.obs;
  var isClassesLoading = false.obs;
  var isStudentsLoading = false.obs;
  var isSaving = false.obs;
  var selectedExamTypeId = Rxn<int>();

  var selectedClassId = Rxn<String>();
  var selectedSectionId = Rxn<String>();
  var selectedSubjectId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    
    // Listen to exam type changes to fetch classes and reset previous selections
    ever(selectedExamTypeId, (int? id) {
      if (id != null) {
        selectedClassId.value = null;
        selectedSectionId.value = null;
        selectedSubjectId.value = null;
        studentsList.clear();
        subjectList.clear();
        fetchMarksEntryClasses(id);
      }
    });

    // Reset section, subject and students when class changes
    ever(selectedClassId, (classId) {
      if (classId == null) return;

      // Check if current section is still valid for the new class
      bool isSectionValid = false;
      if (selectedSectionId.value != null) {
        isSectionValid = marksEntryClasses.any(
          (element) => element.classId == classId && element.sectionId == selectedSectionId.value
        );
      }

      if (!isSectionValid) {
        // Try to find Section 'A' as default
        final sectionA = marksEntryClasses.firstWhereOrNull(
          (element) => element.classId == classId && (element.sectionName?.toUpperCase() == 'A' || element.sectionName?.toLowerCase() == 'a')
        );
        
        if (sectionA != null) {
          selectedSectionId.value = sectionA.sectionId;
        } else {
          // Pick first available section if 'A' not found
          final firstSection = marksEntryClasses.firstWhereOrNull(
            (element) => element.classId == classId
          );
          if (firstSection != null) {
            selectedSectionId.value = firstSection.sectionId;
          } else {
            selectedSectionId.value = null;
            selectedSubjectId.value = null;
            isLocked.value = false;
            subjectList.clear();
            studentsList.clear();
          }
        }
      }
    });

    // Listen to exam type, class or section changes to fetch students
    everAll([selectedExamTypeId, selectedClassId, selectedSectionId], (_) {
      if (selectedExamTypeId.value != null && 
          selectedClassId.value != null && 
          selectedSectionId.value != null) {
        fetchStudents();
      }
    });

    // Listen to subject changes to update grade list
    ever(selectedSubjectId, (int? subId) {
      if (subId != null) {
        final subject = subjectList.firstWhereOrNull((s) => s.subjectId == subId);
        if (subject != null && subject.grades != null && subject.grades!.isNotEmpty) {
          gradeList.assignAll(subject.grades!);
        }
      }
    });

    // Fetch initial data
    fetchMarksEntries();
  }

  Future<void> fetchMarksEntries() async {
    try {
      isLoading.value = true;
      final response = await _marksService.getMarksEntries();
      if (response.success == true && response.data != null) {
        marksEntries.assignAll(response.data!);
        if (marksEntries.isNotEmpty) {
          if (selectedExamTypeId.value == null) {
            selectedExamTypeId.value = marksEntries.first.id;
          } else {
            // If already set, ensure classes are fetched for this ID
            fetchMarksEntryClasses(selectedExamTypeId.value!);
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Exam Categories: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMarksEntryClasses(int id) async {
    try {
      isClassesLoading.value = true;
      // Don't reset if we already have a selection (might be coming back from entry)
      if (selectedClassId.value == null) {
        selectedSectionId.value = null;
        selectedSubjectId.value = null;
        isLocked.value = false;
        subjectList.clear();
        studentsList.clear();
      }
      
      final response = await _marksService.getMarksEntryClasses(id);
      if (response.success == true && response.data != null) {
        marksEntryClasses.assignAll(response.data!);
        
        // Validate current selection against new class list
        if (selectedClassId.value != null && selectedSectionId.value != null) {
          bool currentValid = marksEntryClasses.any((element) => 
            element.classId == selectedClassId.value && 
            element.sectionId == selectedSectionId.value
          );
          if (!currentValid) {
            selectedClassId.value = null;
            selectedSectionId.value = null;
          }
        }
      } else {
        marksEntryClasses.clear();
        Get.snackbar("Error", "No classes found for this exam", backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      marksEntryClasses.clear();
      Get.snackbar("Error", "Classes: ${e.toString()}", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isClassesLoading.value = false;
    }
  }

  Future<void> fetchStudents() async {
    try {
      isStudentsLoading.value = true;
      studentsList.clear(); // Clear immediately to trigger loader correctly
      isLocked.value = false;
      subjectList.clear();
      gradeList.clear();

      final selectedData = marksEntryClasses.firstWhereOrNull(
        (element) => element.classId == selectedClassId.value && 
                     element.sectionId == selectedSectionId.value
      );

      final Map<String, dynamic> params = {
        "class_id": selectedClassId.value,
        "section_id": selectedSectionId.value,
        "stream_id": selectedData?.streamId,
      };

      final response = await _marksService.getStudentsForMarks(selectedExamTypeId.value!, params);
      if (response.success == true) {
        isLocked.value = response.isLocked ?? false;
        if (response.subjects != null) {
          subjectList.assignAll(response.subjects!);
          // If previous selection is no longer valid, or none selected, pick the first one
          if (selectedSubjectId.value == null || !subjectList.any((s) => s.subjectId == selectedSubjectId.value)) {
            if (subjectList.isNotEmpty) {
              selectedSubjectId.value = subjectList.first.subjectId;
            }
          }
        }
        if (response.students != null) studentsList.assignAll(response.students!);
        
        // Handle Grades: Priority 1: Global grades from response
        if (response.grades != null && response.grades!.isNotEmpty) {
          gradeList.assignAll(response.grades!);
        } else if (selectedSubjectId.value != null) {
          // Priority 2: Subject specific grades
          final subject = subjectList.firstWhereOrNull((s) => s.subjectId == selectedSubjectId.value);
          if (subject != null && subject.grades != null && subject.grades!.isNotEmpty) {
            gradeList.assignAll(subject.grades!);
          } else {
            gradeList.clear();
          }
        } else {
          gradeList.clear();
        }
      } else {
        Get.snackbar("Error", "Failed to fetch student data", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Students: ${e.toString()}", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isStudentsLoading.value = false;
    }
  }

  List<MarksEntryClassData> get uniqueClasses {
    final seen = <String>{};
    return marksEntryClasses.where((item) => seen.add(item.classId ?? "")).toList();
  }

  List<MarksEntryClassData> get sectionsForSelectedClass {
    if (selectedClassId.value == null) return [];
    return marksEntryClasses.where((item) => item.classId == selectedClassId.value).toList();
  }

  Future<bool> saveMarksToApi(MarksSaveRequest request) async {
    try {
      isSaving.value = true;
      debugPrint("Saving Marks Request: ${request.toJson()}");
      final success = await _marksService.saveMarks(request);
      if (success) {
        await fetchStudents();
        return true;
      } else {
        Get.snackbar("Error", "Failed to save marks. Server returned success: false", 
          backgroundColor: Colors.red, 
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
        return false;
      }
    } catch (e) {
      debugPrint("Save Marks Error: $e");
      Get.snackbar("Error", e.toString(), 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> submitMarksToApi(Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final success = await _marksService.submitMarks(data);
      if (success) {
        isLocked.value = true;
        // Trigger local notification
        String examName = "Marks Entry";
        if (marksEntries.isNotEmpty && selectedExamTypeId.value != null) {
          final selectedExam = marksEntries.firstWhereOrNull((e) => e.id == selectedExamTypeId.value);
          if (selectedExam != null) {
            examName = selectedExam.datesheetName ?? "Marks Entry";
          }
        }

        await FcmService.showLocalNotification(
          title: "Marks Submitted",
          body: "$examName has been successfully submitted and locked.",
        );

        Get.snackbar("Success", "Marks submitted successfully", backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void saveMarks(List<MarksModel> newMarks) {
    for (var newMark in newMarks) {
      int index = savedMarks.indexWhere((m) =>
          m.studentName == newMark.studentName &&
          m.subject == newMark.subject &&
          m.examType == newMark.examType);

      if (index != -1) {
        savedMarks[index] = newMark;
      } else {
        savedMarks.add(newMark);
      }
    }
    Get.snackbar("Success", "Marks saved successfully!",
        backgroundColor: Colors.green, 
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP);
  }
}
