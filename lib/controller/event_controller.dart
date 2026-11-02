import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../api_service/event_service.dart';
import '../models/event_today_scans_model.dart';
import '../models/event_pass_scan_response_model.dart';
import '../models/event_check_in_response_model.dart';

class EventController extends GetxController with GetTickerProviderStateMixin {
  final EventService _eventService = EventService();

  final isLoading = false.obs;
  final eventScans = Rxn<EventTodayScansModel>();
  final scanResponseModel = Rxn<EventPassScanResponseModel>();
  final checkInResponseModel = Rxn<EventCheckInResponseModel>();
  final errorMessage = ''.obs;

  // Scanner state
  late MobileScannerController mobileScannerController;
  late AnimationController scanAnimation;
  final RxBool isTorchOn = false.obs;
  final RxBool isScanning = false.obs;
  final RxString scanResultMsg = ''.obs;
  final RxBool isScanSuccess = false.obs;
  final RxString lastScannedCode = ''.obs;

  final TextEditingController manualPassController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    scanAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    fetchTodayScans();
  }

  @override
  void onClose() {
    scanAnimation.dispose();
    mobileScannerController.dispose();
    manualPassController.dispose();
    super.onClose();
  }

  Future<void> fetchTodayScans() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _eventService.getEventTodayScans();
      eventScans.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint("Error fetching event today scans: $e");
    } finally {
      isLoading.value = false;
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

  Future<void> resumeScanning() async {
    isScanning.value = false;
    lastScannedCode.value = '';
    scanResultMsg.value = '';
    scanResponseModel.value = null;
    checkInResponseModel.value = null;
    manualPassController.clear();
    
    if (!scanAnimation.isAnimating) {
      scanAnimation.repeat(reverse: true);
    }
    try {
      await mobileScannerController.start();
    } catch (e) {
      debugPrint("Error resuming scanner: $e");
    }
  }

  Future<void> processPassScan(String passCode, {String? gateName}) async {
    final code = passCode.trim();
    if (code.isEmpty || isScanning.value) return;

    try {
      isScanning.value = true;
      lastScannedCode.value = code;
      scanResultMsg.value = '';
      scanResponseModel.value = null;

      // Stop camera while processing request
      try {
        await mobileScannerController.stop();
      } catch (_) {}

      final res = await _eventService.scanEventPass(
        qrPayload: code.length > 40 ? code : null,
        passNumber: code.length <= 40 ? code : null,
        gateName: gateName ?? "Gate 1 - Main Entrance",
      );

      scanResponseModel.value = res;
      final bool success = res.success == true;
      final bool isDuplicate = res.isAlreadyCheckedIn == true;

      isScanSuccess.value = success && !isDuplicate;
      scanResultMsg.value = res.warning ?? res.message ?? (success ? "Pass verified successfully!" : "Pass scan failed");

      // Refresh today scans list
      await fetchTodayScans();

      // Open detail screen if response has data
      if (res.data != null) {
        Get.toNamed('/eventPassDetail', arguments: res)?.then((_) {
          resumeScanning();
        });
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          resumeScanning();
        });
      }
    } catch (e) {
      isScanSuccess.value = false;
      scanResultMsg.value = e.toString();
      Future.delayed(const Duration(seconds: 2), () {
        resumeScanning();
      });
    } finally {
      isScanning.value = false;
    }
  }

  Future<EventCheckInResponseModel?> checkInPass({
    required int passId,
    required List<int> attendeeIds,
    String? gateName,
    String? remarks,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final res = await _eventService.checkInEventPass(
        passId: passId,
        attendeeIds: attendeeIds,
        gateName: gateName ?? "Main Gate",
        remarks: remarks,
      );

      checkInResponseModel.value = res;

      if (res.success == true) {
        await fetchTodayScans();
      }
      return res;
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint("Error checking in pass: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void resetScanResult() {
    resumeScanning();
  }
}
