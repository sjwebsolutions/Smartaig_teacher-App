import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teacher_app_attendance/api_service/student_attendance_service.dart';
import 'package:teacher_app_attendance/models/student_list_model.dart' as model;
import 'class_list_controller.dart';

class AttendanceController extends GetxController {
  final StudentAttendanceService _service = StudentAttendanceService();
  
  var isLoading = false.obs;
  var students = <model.Student>[].obs;
  var studentStatuses = <int, String>{}.obs; // Changed to RxMap<int, String>
  var errorMessage = "".obs;

  String? _currentClassId;
  String? _currentSectionId;

  void setIds(String cId, String sId) {
    if (_currentClassId == cId && _currentSectionId == sId) return;
    
    _currentClassId = cId;
    _currentSectionId = sId;
    fetchStudents(cId, sId);
  }

  Future<void> fetchStudents(String classId, String sectionId) async {
    try {
      isLoading(true);
      errorMessage("");
      final response = await _service.getStudentList(classId, sectionId);
      if (response.success == true) {
        students.value = response.data?.students ?? [];
        
        // Initialize statuses from existing attendance
        studentStatuses.clear();
        for (var student in students) {
          if (student.id != null) {
            studentStatuses[student.id!] = student.existingAttendance?.status ?? '';
          }
        }
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void updateStatus(int studentId, String status) {
    if (studentStatuses[studentId] == status) {
      studentStatuses[studentId] = '';
    } else {
      studentStatuses[studentId] = status;
    }
    studentStatuses.refresh(); // Ensure UI updates
  }

  int get totalMarked => studentStatuses.values.where((s) => s.isNotEmpty).length;
  double get progress => students.isEmpty ? 0 : totalMarked / students.length;

  Future<void> submitAttendance() async {
    if (totalMarked == 0) {
      Get.snackbar(
        "Selection Required",
        "Please mark attendance for at least one student",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Modern Custom Confirmation Dialog (Matches Screenshot)
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Question Mark Icon in Circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF233263), width: 4),
                ),
                child: const Icon(
                  Icons.question_mark_rounded,
                  size: 50,
                  color: Color(0xFF233263),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Confirm Submission",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF233263),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to submit attendance for $totalMarked students?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  // NO Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Colors.black45, width: 1.5),
                        ),
                        child: const Text(
                          "NO",
                          style: TextStyle(color: Color(0xFF233263), fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // YES Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back(); // Close dialog
                          await _performSubmission();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF233263),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "YES",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performSubmission() async {
    try {
      // Show transparent loading overlay
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );
      
      Map<String, dynamic> attendanceData = {};
      studentStatuses.forEach((studentId, status) {
        if (status.isNotEmpty) {
          attendanceData[studentId.toString()] = {
            "status": status,
            "remarks": ""
          };
        }
      });

      final success = await _service.submitAttendance(
        classId: _currentClassId!,
        sectionId: _currentSectionId!,
        attendance: attendanceData,
      );

      // Close loading overlay
      if (Get.isDialogOpen ?? false) Get.back();

      if (success) {
        Get.back(); // Return to class list
        
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar(
            "Success",
            "Today Attendance Successfully.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            margin: const EdgeInsets.all(15),
            duration: const Duration(seconds: 3),
          );
        });
        
        if (Get.isRegistered<ClassListController>()) {
          Get.find<ClassListController>().fetchClasses();
        }
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        "Error",
        "Something went wrong.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
