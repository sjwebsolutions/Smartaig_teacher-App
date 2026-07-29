import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teacher_app_attendance/api_service/dashboard_service.dart';
import 'package:teacher_app_attendance/models/dashboard_model.dart';

import '../api_service/attendance_scanner_service.dart';
import '../themes/appColors_&_styles/app_Colors.dart';

class NewDashboardController extends GetxController {
  final AttendanceServices _attendanceServices = AttendanceServices();
  final DashboardServices _dashboardServices = DashboardServices();
  
  final isLoading = false.obs;
  final isInitialLoading = true.obs;
  final dashboard = Rxn<DashboardTeacherModel>();

  var lastMarkedTime = Rxn<DateTime>();
  var clockInTime = Rxn<DateTime>();
  var clockOutTime = Rxn<DateTime>();

  var attendanceStatus = "Clock In".obs;
  var isMarked = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _handleInitialLoading();
  }

  Future<void> _handleInitialLoading() async {
    isInitialLoading.value = true;
    try {
      await fetchDashboard(showLoading: false);
    } catch (e) {
      print("Initial Loading Error: $e");
    } finally {
      isInitialLoading.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> fetchDashboard({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      
      final result = await _dashboardServices.getDashboard();
      
      // Only update if the result is successful and contains data to avoid flickering/disappearing UI
      if (result.success == true && result.data != null) {
        dashboard.value = result;

        if (result.data?.todayAttendance != null) {
          final attendance = result.data!.todayAttendance!;
          
          // Update Clock-In
          if (attendance.clockIn != null && attendance.clockIn!.isNotEmpty) {
            clockInTime.value = DateTime.tryParse(attendance.clockIn!);
          } else {
            clockInTime.value = null;
          }

          // Update Clock-Out
          if (attendance.clockOut != null && attendance.clockOut!.isNotEmpty) {
            clockOutTime.value = DateTime.tryParse(attendance.clockOut!);
          } else {
            clockOutTime.value = null;
          }

          // isMarked should represent if the teacher is currently "Clocked In"
          // If they have clocked in but NOT clocked out yet.
          isMarked.value = clockInTime.value != null && clockOutTime.value == null;
          
          lastMarkedTime.value = clockInTime.value;
          attendanceStatus.value = isMarked.value ? "Clock Out" : "Clock In";
          
          print("[${DateTime.now().toIso8601String()}] Dashboard Updated: In=${attendance.clockIn}, Out=${attendance.clockOut}, isMarked=${isMarked.value}");
        } else {
          isMarked.value = false;
          clockInTime.value = null;
          clockOutTime.value = null;
          attendanceStatus.value = "Clock In";
        }
        
        // Force refresh of Rx variables just in case
        clockInTime.refresh();
        clockOutTime.refresh();
        isMarked.refresh();
      }
      
    } catch (e) {
      if (showLoading) Get.snackbar("Error", e.toString());
      print("Fetch Dashboard Error: $e");
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  void updateAttendanceStatus() {
    final now = DateTime.now();
    lastMarkedTime.value = now;
    
    // Status update logic based on current marked state
    if (!isMarked.value) {
      // Transitioning to Present (Clock In)
      isMarked.value = true;
      clockInTime.value = now;
      clockOutTime.value = null; // Reset clock out on new clock in
      attendanceStatus.value = "Clock Out";
    } else {
      // Transitioning to Clock Out
      isMarked.value = false;
      clockOutTime.value = now;
      attendanceStatus.value = "Clock In";
    }
    
    // Notify observers explicitly
    clockInTime.refresh();
    clockOutTime.refresh();
    isMarked.refresh();
    
    // After local update, fetch from server after 2 seconds to sync data correctly
    Future.delayed(const Duration(seconds: 2), () {
      fetchDashboard(showLoading: false);
    });
  }

  void markAttendance() {
    updateAttendanceStatus();
  }

  bool get canClockOut {
    if (!isMarked.value || clockInTime.value == null) return true;
    final now = DateTime.now();
    final difference = now.difference(clockInTime.value!);
    return difference.inMinutes >= 5;
  }

  int get minutesRemainingUntilClockOut {
    if (!isMarked.value || clockInTime.value == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(clockInTime.value!);
    final remaining = 5 - difference.inMinutes;
    return remaining > 0 ? remaining : 0;
  }

  void handleScannerTap() {
    if (isMarked.value) {
      if (canClockOut) {
        Get.toNamed('/scanner', preventDuplicates: true);
      } else {
        Get.snackbar(
          "Wait",
          "You can Clock-Out after ${minutesRemainingUntilClockOut} minutes",
          backgroundColor: AppColors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      // Not marked, allow Clock-In
      Get.toNamed('/scanner', preventDuplicates: true);
    }
  }

  Future<void> resetAttendanceForTesting() async {
    try {
      isLoading.value = true;
      final success = await _attendanceServices.deleteTodayAttendance();

      if (success) {
        isMarked.value = false;
        lastMarkedTime.value = null;
        clockInTime.value = null;
        clockOutTime.value = null;
        attendanceStatus.value = "Clock In";

        Get.snackbar("Success", "Attendance deleted successfully");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
