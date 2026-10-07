import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/marks_model.dart';
import '../models/marks_entry_model.dart';
import '../models/marks_entry_classes_model.dart';
import '../models/marks_save_model.dart';
import '../models/marks_student_model.dart';
import '../api_service/marks_service.dart';
import '../services/fcm_services.dart';
import '../services/storage_services.dart';
import 'announcement_controller.dart';

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
  var searchQuery = "".obs;
  var searchType = "Name".obs;
  var isAscending = true.obs;
  String? _lastFetchKey;

  var selectedClassId = Rxn<String>();
  var selectedSectionId = Rxn<String>();
  var selectedStreamId = Rxn<String>();
  var selectedSubjectId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    _loadSortPreferences();
    
    // Listen to exam type changes to fetch classes and reset previous selections
    ever(selectedExamTypeId, (int? id) {
      if (id != null) {
        selectedClassId.value = null;
        selectedSectionId.value = null;
        selectedStreamId.value = null;
        selectedSubjectId.value = null;
        studentsList.clear();
        subjectList.clear();
        fetchMarksEntryClasses(id);
      }
    });

    // Reset section, stream, subject and students when class changes
    ever(selectedClassId, (classId) {
      if (classId == null) {
        selectedSectionId.value = null;
        selectedStreamId.value = null;
        return;
      }
      
      selectedSubjectId.value = null;

      // 1. Auto-select Stream if not already set or invalid
      final streams = uniqueStreamsForSelectedClass;
      bool isStreamValid = selectedStreamId.value != null && 
                          streams.any((s) => s.streamId == selectedStreamId.value);
      
      if (!isStreamValid) {
        if (streams.isNotEmpty) {
          selectedStreamId.value = streams.first.streamId;
        } else {
          selectedStreamId.value = null;
        }
      }

      // 2. Auto-select Section 'A' or first available for this class (+ stream)
      _autoSelectSection(classId, selectedStreamId.value);
    });

    // Reset section when stream changes
    ever(selectedStreamId, (streamId) {
      if (selectedClassId.value != null) {
        _autoSelectSection(selectedClassId.value!, streamId);
      }
    });

    // Listen to subject list changes to auto-select first subject
    ever(subjectList, (List<SubjectData> subjects) {
      if (subjects.isNotEmpty && selectedSubjectId.value == null) {
        selectedSubjectId.value = subjects.first.subjectId;
      }
    });

    // Listen to selection changes to fetch students
    everAll([selectedExamTypeId, selectedClassId, selectedSectionId, selectedStreamId], (_) {
      _checkAndFetchStudents();
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

    // Save sorting preferences when they change
    ever(searchType, (String type) {
      StorageService.saveMarksSortType(type);
    });

    ever(isAscending, (bool val) {
      StorageService.saveMarksSortOrder(val);
    });

    // Fetch initial data
    fetchMarksEntries();
  }

  Future<void> _loadSortPreferences() async {
    String? savedType = await StorageService.getMarksSortType();
    if (savedType != null) {
      searchType.value = savedType;
    }

    bool? savedOrder = await StorageService.getMarksSortOrder();
    if (savedOrder != null) {
      isAscending.value = savedOrder;
    }
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
        
        // Auto-select first class and section to show data immediately
        if (uniqueClasses.isNotEmpty) {
          if (selectedClassId.value == null) {
            selectedClassId.value = uniqueClasses.first.classId;
          } else {
            // Even if class is already selected, ensure section/students are refreshed
            _autoSelectSection(selectedClassId.value!, selectedStreamId.value);
          }
        }

        // Validate current selection against new class list
        bool currentValid = marksEntryClasses.any((element) =>
            element.classId == selectedClassId.value &&
            element.sectionId == selectedSectionId.value
        );
        if (!currentValid) {
          selectedClassId.value = null;
          selectedSectionId.value = null;
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

  void _checkAndFetchStudents() {
    bool needsStream = uniqueStreamsForSelectedClass.isNotEmpty;
    bool streamSelected = selectedStreamId.value != null && selectedStreamId.value != "null" && selectedStreamId.value!.isNotEmpty;

    if (selectedExamTypeId.value != null && 
        selectedClassId.value != null && 
        selectedSectionId.value != null &&
        (!needsStream || streamSelected)) {
      fetchStudents();
    }
  }

  Future<void> fetchStudents({bool force = false}) async {
    final currentKey = "${selectedExamTypeId.value}_${selectedClassId.value}_${selectedSectionId.value}_${selectedStreamId.value}";
    if (!force && _lastFetchKey == currentKey && studentsList.isNotEmpty) return;
    _lastFetchKey = currentKey;

    try {
      isStudentsLoading.value = true;
      isLocked.value = false;
      // Note: We clear subject list to force re-selection of subject
      subjectList.clear();
      gradeList.clear();


      final Map<String, dynamic> params = {
        "class_id": selectedClassId.value,
        "section_id": selectedSectionId.value,
      };

      if (selectedStreamId.value != null && selectedStreamId.value != "null" && selectedStreamId.value!.isNotEmpty) {
        params["stream_id"] = selectedStreamId.value;
      }

      final response = await _marksService.getStudentsForMarks(selectedExamTypeId.value!, params);
      if (response.success == true) {
        isLocked.value = response.isLocked ?? false;
        if (response.subjects != null) {
          // Ensure unique subjects by subjectId to prevent Dropdown crash
          final seen = <int>{};
          final uniqueSubjects = response.subjects!.where((s) => s.subjectId != null && seen.add(s.subjectId!)).toList();
          subjectList.assignAll(uniqueSubjects);

          // If previous selection is no longer valid, or none selected, pick the first one
          if (selectedSubjectId.value == null || !subjectList.any((s) => s.subjectId == selectedSubjectId.value)) {
            if (subjectList.isNotEmpty) {
              selectedSubjectId.value = subjectList.first.subjectId;
            }
          }
        }
        if (response.students != null) studentsList.assignAll(response.students!);

        debugPrint("=== MARKS API FETCH SUCCESS ===");
        debugPrint("Fetched ${subjectList.length} subjects and ${studentsList.length} students");
        for (var sub in subjectList) {
          debugPrint(" -> Subject ID: ${sub.subjectId}, Name: '${sub.name}', IsMisc: ${sub.isMisc}");
        }
        for (var st in studentsList) {
          debugPrint(" -> Student [ID: ${st.studentId}, Name: '${st.studentName}', AllowedSubjects: ${st.allowedSubjects}]");
        }
        
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

  List<MarksEntryClassData> get uniqueStreamsForSelectedClass {
    if (selectedClassId.value == null) return [];
    final seen = <String>{};
    return marksEntryClasses
        .where((item) => 
            item.classId == selectedClassId.value && 
            item.streamId != null && 
            item.streamId != "null" && 
            item.streamId!.isNotEmpty
        )
        .where((item) => seen.add(item.streamId!))
        .toList();
  }

  List<MarksEntryClassData> get sectionsForSelectedClassAndStream {
    if (selectedClassId.value == null) return [];
    final seen = <String>{};
    return marksEntryClasses
        .where((item) => 
            item.classId == selectedClassId.value && 
            (selectedStreamId.value == null || item.streamId == selectedStreamId.value)
        )
        .where((item) => seen.add(item.sectionId ?? ""))
        .toList();
  }

  /// Returns students enrolled in the currently selected subject
  List<StudentMarkData> get studentsForSelectedSubject {
    if (studentsList.isEmpty) return [];

    final subId = selectedSubjectId.value;
    if (subId == null) return studentsList;

    final subject = subjectList.firstWhereOrNull((s) => s.subjectId == subId);
    final subjectName = subject?.name;
    final isMisc = subject?.isMisc;

    // Check if any student has specific subject restrictions
    final hasAnyStudentWithAssignments = studentsList.any((s) =>
        (s.allowedSubjects != null && s.allowedSubjects!.isNotEmpty));

    debugPrint("--- [MARKS CONTROLLER] FILTERING STUDENTS FOR SUBJECT ---");
    debugPrint("Selected Subject ID: $subId, Name: '$subjectName', IsMisc: $isMisc");
    debugPrint("Total students in list: ${studentsList.length}");

    if (!hasAnyStudentWithAssignments) {
      debugPrint("No student subject restrictions, returning all ${studentsList.length} students.");
      return studentsList;
    }

    final filtered = studentsList.where((s) => s.hasSubject(subId, subjectName, isMisc)).toList();
    debugPrint("Enrolled students count for '$subjectName' (ID: $subId): ${filtered.length}");
    for (var s in filtered) {
      debugPrint(" -> Enrolled Student [ID: ${s.studentId}, Name: '${s.studentName}']");
    }
    debugPrint("----------------------------------------------------------");
    return filtered;
  }

  /// Returns students sorted by selected type (Name or Roll No) and order
  List<StudentMarkData> get filteredStudents {
    final students = List<StudentMarkData>.from(studentsForSelectedSubject);
    
    if (searchType.value == "Roll No") {
      students.sort((a, b) {
        final aRoll = a.rollNo?.toString() ?? "";
        final bRoll = b.rollNo?.toString() ?? "";
        
        final aInt = int.tryParse(aRoll);
        final bInt = int.tryParse(bRoll);
        
        int comparison;
        if (aInt != null && bInt != null) {
          comparison = aInt.compareTo(bInt);
        } else {
          comparison = aRoll.compareTo(bRoll);
        }
        return isAscending.value ? comparison : -comparison;
      });
    } else {
      students.sort((a, b) {
        int comparison = (a.studentName ?? "").compareTo(b.studentName ?? "");
        return isAscending.value ? comparison : -comparison;
      });
    }

    if (searchQuery.value.isEmpty) return students;

    final query = searchQuery.value.toLowerCase();
    return students.where((student) {
      if (searchType.value == "Roll No") {
        return student.rollNo?.toString().toLowerCase().contains(query) ?? false;
      } else {
        return student.studentName?.toLowerCase().contains(query) ?? false;
      }
    }).toList();
  }

  /// Get total count of students enrolled in a specific subject
  int getStudentCountForSubject(SubjectData subject) {
    if (studentsList.isEmpty) return 0;

    final hasAnyStudentWithAssignments = studentsList.any((s) =>
        (s.allowedSubjects != null && s.allowedSubjects!.isNotEmpty));

    if (!hasAnyStudentWithAssignments) {
      return studentsList.length;
    }

    return studentsList.where((s) => s.hasSubject(subject.subjectId, subject.name, subject.isMisc)).length;
  }

  /// Check if a subject has marks/attendance entered for its enrolled students
  bool isSubjectCompleted(SubjectData subject) {
    final enrolledStudents = studentsList.where((s) => s.hasSubject(subject.subjectId, subject.name, subject.isMisc)).toList();
    if (enrolledStudents.isEmpty) return false;

    for (var student in enrolledStudents) {
      final m = student.getMarksForSubject(subject.subjectId);
      if (m == null) return false;

      bool hasMarks = (m.wMarks?.isNotEmpty == true && m.wMarks != "null") ||
          (m.oMarks?.isNotEmpty == true && m.oMarks != "null") ||
          (m.tMarks?.isNotEmpty == true && m.tMarks != "null") ||
          (m.aMarks?.isNotEmpty == true && m.aMarks != "null") ||
          (m.bMarks?.isNotEmpty == true && m.bMarks != "null") ||
          (m.assMarks?.isNotEmpty == true && m.assMarks != "null") ||
          (m.pMarks?.isNotEmpty == true && m.pMarks != "null") ||
          (m.gGrade?.isNotEmpty == true && m.gGrade != "null") ||
          (m.grade?.isNotEmpty == true && m.grade != "null");

      String? att = m.attendance;
      bool hasAtt = att != null && att.trim().isNotEmpty && att != "null";

      if (!hasMarks && !hasAtt) return false;
    }
    return true;
  }

  void _autoSelectSection(String classId, String? streamId) {
    // Check if current section is still valid for this class and stream
    final sections = sectionsForSelectedClassAndStream;
    if (sections.isEmpty) return;

    final sectionA = sections.firstWhereOrNull(
      (element) => element.sectionName?.toUpperCase() == 'A'
    );
    
    final targetSectionId = sectionA?.sectionId ?? sections.first.sectionId;

    if (selectedSectionId.value != targetSectionId) {
      selectedSectionId.value = targetSectionId;
    } else {
      // If section is already set (e.g. 'A' from previous state), 
      // explicitly trigger students fetch if list is empty
      if (studentsList.isEmpty) {
        _checkAndFetchStudents();
      }
    }
  }

  Future<bool> saveMarksToApi(MarksSaveRequest request) async {
    try {
      isSaving.value = true;
      debugPrint("Saving Marks Request: ${request.toJson()}");
      final success = await _marksService.saveMarks(request);
      if (success) {
        await fetchStudents(force: true);
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

        // Update notification dot in app bar
        if (Get.isRegistered<AnnouncementController>()) {
          Get.find<AnnouncementController>().hasNewNotifications.value = true;
        }

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
