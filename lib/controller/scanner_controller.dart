import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:teacher_app_attendance/api_service/attendance_scanner_service.dart';

import '../view/screens/dashboard/dashboard_screen_v2.dart';
import '../models/dashboard_model.dart';
import '../services/fcm_services.dart';
import 'announcement_controller.dart';
import 'dashboard_controller_v2.dart';
class ScannerController extends GetxController with GetTickerProviderStateMixin {

  final isLoading = false.obs;
  final AttendanceServices _attendanceServices = AttendanceServices();

  late AnimationController scanAnimation;
  final MobileScannerController mobileScannerController =
  MobileScannerController();

  final RxBool isTorchOn = false.obs;

  bool _isProcessing = false;

  RxString currentTime = ''.obs;
  Timer? clockTimer;
  final dashboard = Rxn<DashboardTeacherModel>();
  var isMarked = false.obs;
  var lastMarkedTime = Rxn<DateTime>();
  var attendanceStatus = "Clock In".obs;

  @override
  void onInit() {
    super.onInit();

    scanAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startClock();
  }

  void toggleTorch() async {
    try {
      await mobileScannerController.toggleTorch();
      isTorchOn.value = !isTorchOn.value;
    } catch (e) {
      debugPrint("Error toggling torch: $e");
    }
  }

  void _startClock() {
    currentTime.value =
        DateFormat('hh:mm a').format(DateTime.now());

    clockTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        currentTime.value =
            DateFormat('hh:mm a').format(DateTime.now());
      },
    );
  }

  Future<void> onQRScanned(String qrToken) async {
    if (_isProcessing || isLoading.value) return;

    _isProcessing = true;
    isLoading.value = true;

    // await mobileScannerController.stop();
    // scanAnimation.stop();

    try {
      print(" QR SCANNED ");
      print("QR TOKEN => $qrToken");
      
      // ... (location logic)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw "Please enable device location/GPS";

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) throw "Location permission denied";
      if (permission == LocationPermission.deniedForever) throw "Location permission permanently denied.";

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      final response = await _attendanceServices.markAttendance(
        qrToken: qrToken,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Dismiss loading dialog
      // if (Get.isDialogOpen ?? false) Get.back();

      if (response.success == true) {
        final NewDashboardController dash = Get.find();
        dash.updateAttendanceStatus();

        // Close Scanner Screen
        Get.back();

        // Show Success Snackbar on the background screen
        Get.snackbar(
          "Success",
          "Attendance marked successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF16A34A),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          "Failed",
          response.message ?? "Attendance failed",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );

        await mobileScannerController.start();
        scanAnimation.repeat();
      }
    } catch (e) {
      // if (Get.isDialogOpen ?? false) Get.back();

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );

      await mobileScannerController.start();
      scanAnimation.repeat();
    } finally {
      isLoading.value = false;
      _isProcessing = false;
    }
  }

  void _showLoadingDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingAnimationWidget.staggeredDotsWave(
                  color: const Color(0xFF16A34A),
                  size: 50,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Processing...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    decoration: TextDecoration.none,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }  void markSuccess() {
    isMarked.value = true;
    attendanceStatus.value = "Active";
    lastMarkedTime.value = DateTime.now();
  }
  @override
  void onClose() {
    clockTimer?.cancel();
    scanAnimation.dispose();
    mobileScannerController.dispose();
    super.onClose();
  }

}


