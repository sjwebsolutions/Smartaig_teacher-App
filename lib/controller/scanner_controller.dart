import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:teacher_app_attendance/api_service/attendance_scanner_service.dart';

import '../view/screens/dashboard/dashboard_screen_v2.dart';
import '../models/dashboard_model.dart';
import 'dashboard_controller_v2.dart';
class ScannerController extends GetxController with GetTickerProviderStateMixin {

  final isLoading = false.obs;
  final AttendanceServices _attendanceServices = AttendanceServices();

  late AnimationController scanAnimation;
  final MobileScannerController mobileScannerController =
  MobileScannerController();

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

    await mobileScannerController.stop();
    scanAnimation.stop();

    try {
      print(" QR SCANNED ");
      print("QR TOKEN => $qrToken");

      print(" LOCATION CHECK ");

      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      print("Location Service Enabled => $serviceEnabled");

      if (!serviceEnabled) {
        throw "Please enable device location/GPS";
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      print("Current Permission => $permission");

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        print("Permission After Request => $permission");
      }

      if (permission == LocationPermission.denied) {
        throw "Location permission denied";
      }

      if (permission == LocationPermission.deniedForever) {
        throw "Location permission permanently denied. Please enable it from Settings.";
      }

      print("FETCHING LOCATION ");

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("LATITUDE => ${position.latitude}");
      print("LONGITUDE => ${position.longitude}");

      print(" MARK ATTENDANCE ");

      final response = await _attendanceServices.markAttendance(
        qrToken: qrToken,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      print("ATTENDANCE RESPONSE => ${response.toString()}");

      if (response.success == true) {
        print("ATTENDANCE SUCCESS");

        final NewDashboardController dash = Get.find();

        dash.updateAttendanceStatus();

        Get.back();
      }
 else {
        print("ATTENDANCE FAILED => ${response.message}");

        Get.snackbar(
          "Failed",
          response.message ?? "Attendance failed",
        );

        await mobileScannerController.start();
        scanAnimation.repeat();
      }
    } catch (e, s) {
      print("ERROR ");
      print("ERRORffff => $e");
      print("STACK => $s");

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );

      await mobileScannerController.start();
      scanAnimation.repeat();
    } finally {
      isLoading.value = false;
      _isProcessing = false;
    }
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


