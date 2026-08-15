import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teacher_app_attendance/api_service/student_attendance_service.dart';
import 'package:teacher_app_attendance/models/student_list_model.dart' as model;
import 'class_list_controller.dart';

class AttendanceController extends GetxController {
  final StudentAttendanceService _service = StudentAttendanceService();
  
  var isLoading = false.obs;
  var students = <model.Student>[].obs;
  var studentStatuses = <int, String>{}.obs; 
  var errorMessage = "".obs;

  String? _currentStreamId;
  String? _currentClassId;
  String? _currentSectionId;

  void setIds(String? sId, String cId, String secId) {
    if (_currentStreamId == sId && _currentClassId == cId && _currentSectionId == secId) return;
    
    _currentStreamId = sId;
    _currentClassId = cId;
    _currentSectionId = secId;
    fetchStudents(sId, cId, secId);
  }

  Future<void> fetchStudents(String? streamId, String classId, String sectionId) async {
    try {
      isLoading(true);
      errorMessage("");
      final response = await _service.getStudentList(
        streamId: streamId,
        classId: classId,
        sectionId: sectionId,
      );
      if (response.success == true) {
        students.value = response.data?.students ?? [];
        
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
    studentStatuses.refresh();
  }

  int get totalMarked => studentStatuses.values.where((s) => s.isNotEmpty).length;

  Future<void> submitAttendance() async {
    if (totalMarked == 0) {
      Get.snackbar("Error", "Please mark attendance", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF233263), width: 4)),
                child: const Icon(Icons.question_mark_rounded, size: 50, color: Color(0xFF233263)),
              ),
              const SizedBox(height: 24),
              const Text("Confirm Submission", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF233263))),
              const SizedBox(height: 12),
              Text("Submit attendance for $totalMarked students?", textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: const Text("NO"))),
                  const SizedBox(width: 16),
                  Expanded(child: ElevatedButton(
                    onPressed: () async { Get.back(); await _performSubmission(); },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF233263)),
                    child: const Text("YES", style: TextStyle(color: Colors.white)),
                  )),
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
      Get.dialog(const Center(child: CircularProgressIndicator(color: Colors.white)), barrierDismissible: false);
      
      // Returning to Map format as most Laravel backends use ID as key for such requests
      Map<String, dynamic> attendanceData = {};
      studentStatuses.forEach((studentId, status) {
        if (status.isNotEmpty) {
          attendanceData[studentId.toString()] = {
            "status": status,
            "remarks": ""
          };
        }
      });

      print("Final Data for Submission: class_id: $_currentClassId, section_id: $_currentSectionId, data: $attendanceData");

      final success = await _service.submitAttendance(
        streamId: _currentStreamId,
        classId: _currentClassId!,
        sectionId: _currentSectionId!,
        attendance: attendanceData,
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (success) {
        Get.back(result: true); 
        
        Get.snackbar("Success", "Attendance Submitted Successfully", backgroundColor: Colors.green, colorText: Colors.white);
        
        if (Get.isRegistered<ClassListController>()) {
          // Increased delay to 1.5s to give server time to update stats
          Future.delayed(const Duration(milliseconds: 1500), () {
            Get.find<ClassListController>().fetchClasses();
          });
        }
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
