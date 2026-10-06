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
    if (_isProcessing || isLoading.value) return;

    _isProcessing = true;
    isLoading.value = true;

    try {
      await mobileScannerController.stop();
      scanAnimation.stop();

      final response = await _attendanceService.scanStudentQr(qrPayload: qrPayload);
      lastScanResult.value = response;

      // Refresh settings/stats
      fetchQrSettings();

      if (response.success == true && response.data != null) {
        _showStudentResultBottomSheet(response);
      } else {
        _showErrorBottomSheet(response.message ?? "Failed to mark QR attendance");
      }
    } catch (e) {
      _showErrorBottomSheet(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void resumeScanner() async {
    _isProcessing = false;
    try {
      await mobileScannerController.start();
      scanAnimation.repeat();
    } catch (e) {
      debugPrint("Error restarting camera: $e");
    }
  }

  void _showStudentResultBottomSheet(QrScanModel result) {
    final student = result.data?.student;
    final attendance = result.data?.attendance;
    final isAlreadyMarked = result.alreadyMarked ?? false;

    Get.bottomSheet(
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            Get.back();
            resumeScanner();
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // Status Badge / Icon Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isAlreadyMarked
                      ? const Color(0xFFFEF3C7) // Yellow / Amber
                      : const Color(0xFFDCFCE7), // Green
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isAlreadyMarked
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF22C55E),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAlreadyMarked
                          ? Icons.info_outline_rounded
                          : Icons.check_circle_rounded,
                      color: isAlreadyMarked
                          ? const Color(0xFFD97706)
                          : const Color(0xFF16A34A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAlreadyMarked ? "Already Marked Today" : "Attendance Marked Present",
                      style: TextStyle(
                        color: isAlreadyMarked
                            ? const Color(0xFFB45309)
                            : const Color(0xFF15803D),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Student Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    // Profile Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: student?.profileImage != null && student!.profileImage!.isNotEmpty
                          ? Image.network(
                              student.profileImage!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => _buildPlaceholderImage(),
                            )
                          : _buildPlaceholderImage(),
                    ),
                    const SizedBox(width: 14),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student?.studentName ?? "Student Name",
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Class: ${student?.className ?? '-'} (${student?.sectionName ?? '-'})  |  ID: ${student?.studentUniqueId ?? '-'}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (student?.fatherName != null && student!.fatherName!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              "Father: ${student.fatherName}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Time & Remarks Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (attendance?.punchTime != null)
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          "Punch Time: ${attendance!.punchTime}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  if (attendance?.date != null)
                    Text(
                      "Date: ${attendance!.date}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    resumeScanner();
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
                  label: const Text(
                    "Scan Next Student",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981), // Emerald Green
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0xFFE2E8F0),
      child: const Icon(
        Icons.person_rounded,
        size: 36,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  void _showErrorBottomSheet(String message) {
    Get.bottomSheet(
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            Get.back();
            resumeScanner();
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 48,
              ),
              const SizedBox(height: 12),

              const Text(
                "Scan Failed",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    resumeScanner();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Try Again",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }

  @override
  void onClose() {
    scanAnimation.dispose();
    mobileScannerController.dispose();
    super.onClose();
  }
}
