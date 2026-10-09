import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:teacher_app_attendance/api_service/dashboard_service.dart';
import 'package:teacher_app_attendance/models/dashboard_model.dart';

import '../api_service/attendance_scanner_service.dart';
import '../services/storage_services.dart';

class NewDashboardController extends GetxController {
  final AttendanceServices _attendanceServices = AttendanceServices();
  final DashboardServices _dashboardServices = DashboardServices();
  
  final isLoading = false.obs;
  final isInitialLoading = true.obs;
  final dashboard = Rxn<DashboardTeacherModel>();
  final hasError = false.obs;
  final errorMessage = ''.obs;

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
    try {
      final cachedJson = await StorageService.getDashboardData();
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final cachedModel = DashboardTeacherModel.fromJson(json.decode(cachedJson));
        if (cachedModel.data != null) {
          _processDashboardData(cachedModel);
          isInitialLoading.value = false;
        }
      }
    } catch (e) {
      print("Error loading cached dashboard: $e");
    }

    try {
      await fetchDashboard(showLoading: false);
    } catch (e) {
      print("Initial Loading Error: $e");
    } finally {
      isInitialLoading.value = false;
    }
  }

  void _processDashboardData(DashboardTeacherModel result) {
    dashboard.value = result;

    if (result.data?.todayAttendance != null) {
      final attendance = result.data!.todayAttendance!;
      
      if (attendance.clockIn != null && attendance.clockIn!.isNotEmpty) {
        clockInTime.value = DateTime.tryParse(attendance.clockIn!);
      } else {
        clockInTime.value = null;
      }

      if (attendance.clockOut != null && attendance.clockOut!.isNotEmpty) {
        clockOutTime.value = DateTime.tryParse(attendance.clockOut!);
      } else {
        clockOutTime.value = null;
      }

      isMarked.value = clockInTime.value != null && clockOutTime.value == null;
      lastMarkedTime.value = clockInTime.value;
      attendanceStatus.value = isMarked.value ? "Clock Out" : "Clock In";
      
      print("[${DateTime.now().toIso8601String()}] Dashboard Processed: In=${attendance.clockIn}, Out=${attendance.clockOut}, isMarked=${isMarked.value}");
    } else {
      isMarked.value = false;
      clockInTime.value = null;
      clockOutTime.value = null;
      attendanceStatus.value = "Clock In";
    }

    clockInTime.refresh();
    clockOutTime.refresh();
    isMarked.refresh();

    final teacherImage = result.data?.teacher?.image;
    if (teacherImage != null && teacherImage.isNotEmpty && Get.context != null) {
      try {
        precacheImage(CachedNetworkImageProvider(teacherImage), Get.context!);
      } catch (_) {}
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
      
      if (result.success == true && result.data != null) {
        hasError.value = false;
        errorMessage.value = '';
        _processDashboardData(result);
        try {
          await StorageService.saveDashboardData(json.encode(result.toJson()));
        } catch (e) {
          print("Error saving dashboard to cache: $e");
        }
      } else {
        hasError.value = true;
        errorMessage.value = "Server Error. Please try again later.";
      }
      
    } catch (e) {
      hasError.value = true;
      errorMessage.value = "Network or Server Error. Please check your connection.";
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
          backgroundColor: const Color(0xFFEF4444), // Red
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
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
