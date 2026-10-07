import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../api_service/student_attendance_service.dart';
import '../models/qr_scan_model.dart';
import '../models/qr_settings_model.dart';

class StudentQrScannerController extends GetxController with GetTickerProviderStateMixin {
  final StudentAttendanceService _attendanceService = StudentAttendanceService();

  final RxBool isLoading = false.obs;
  final RxBool isSettingsLoading = false.obs;
  final RxBool isTorchOn = false.obs;

  final Rxn<QrSettingsData> qrSettings = Rxn<QrSettingsData>();
  final Rxn<QrScanModel> lastScanResult = Rxn<QrScanModel>();

  late AnimationController scanAnimation;
  final MobileScannerController mobileScannerController = MobileScannerController();

  bool _isProcessing = false;
  String? _lastScannedPayload;
  DateTime? _lastScannedTime;

  @override
  void onInit() {
    super.onInit();
    scanAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    fetchQrSettings();
  }

  Future<void> fetchQrSettings() async {
    try {
      isSettingsLoading.value = true;
      final result = await _attendanceService.getQrSettings();
      if (result.success == true && result.data != null) {
        qrSettings.value = result.data;
      }
    } catch (e) {
      debugPrint("Error fetching QR settings: $e");
    } finally {
      isSettingsLoading.value = false;
    }
  }

  void toggleTorch() async {
    try {
      await mobileScannerController.toggleTorch();
      isTorchOn.value = !isTorchOn.value;
    } catch (e) {
      debugPrint("Error toggling torch: $e");
    }
  }

  Future<void> onCodeDetected(String qrPayload) async {
    // Prevent duplicate scan of exact same QR within 3 seconds
    if (_lastScannedPayload == qrPayload && _lastScannedTime != null) {
      if (DateTime.now().difference(_lastScannedTime!).inSeconds < 3) {
        return;
      }
    }

    if (_isProcessing || isLoading.value) return;

    _isProcessing = true;
    isLoading.value = true;
    _lastScannedPayload = qrPayload;
    _lastScannedTime = DateTime.now();

    try {
      final response = await _attendanceService.scanStudentQr(qrPayload: qrPayload);
      lastScanResult.value = response;

      // Update stats in background
      fetchQrSettings();

      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      if (response.success == true && response.data != null) {
        final student = response.data?.student;
        final attendance = response.data?.attendance;
        final isAlready = response.alreadyMarked ?? false;

        final studentName = student?.studentName ?? "Student";
        final className = student?.className ?? "";
        final sectionName = student?.sectionName ?? "";
        final punchTime = attendance?.punchTime ?? "";

        String detailsText = studentName;
        if (className.isNotEmpty) {
          detailsText += " ($className${sectionName.isNotEmpty ? '-$sectionName' : ''})";
        }
        if (punchTime.isNotEmpty) {
          detailsText += "  •  $punchTime";
        }

        Get.snackbar(
          isAlready ? "Already Marked Today" : "Attendance Marked Present",
          detailsText,
          snackPosition: SnackPosition.TOP,
          backgroundColor: isAlready
              ? const Color(0xFFD97706) // Amber / Dark Orange
              : const Color(0xFF16A34A), // Solid Emerald Green
          colorText: Colors.white,
          titleText: Text(
            isAlready ? "Already Marked Today" : "Attendance Marked Present",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          messageText: Text(
            detailsText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          icon: Icon(
            isAlready ? Icons.info_outline_rounded : Icons.check_circle_rounded,
            color: Colors.white,
            size: 28,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 14,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          "Scan Failed",
          response.message ?? "Failed to mark QR attendance",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFDC2626), // Red
          colorText: Colors.white,
          titleText: const Text(
            "Scan Failed",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          messageText: Text(
            response.message ?? "Failed to mark QR attendance",
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
          icon: const Icon(Icons.cancel_rounded, color: Colors.white, size: 28),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 14,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      Get.snackbar(
        "Scan Error",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        titleText: const Text(
          "Scan Error",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        messageText: Text(
          e.toString(),
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 28),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 14,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      // Cooldown before allowing next scan for smooth continuous experience
      Future.delayed(const Duration(milliseconds: 1200), () {
        _isProcessing = false;
      });
    }
  }

  @override
  void onClose() {
    scanAnimation.dispose();
    mobileScannerController.dispose();
    super.onClose();
  }
}
