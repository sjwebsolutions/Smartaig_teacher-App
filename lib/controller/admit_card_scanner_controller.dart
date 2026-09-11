import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../api_service/admit_card_service.dart';
import '../models/admit_card_verify_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';

class AdmitCardScannerController extends GetxController with GetTickerProviderStateMixin {
  final AdmitCardService _admitCardService = AdmitCardService();

  final MobileScannerController mobileScannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  late AnimationController scanAnimation;
  final RxBool isTorchOn = false.obs;
  final RxBool isFrontCamera = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isLoading = false.obs;
  final RxString lastScannedCode = ''.obs;
  final Rxn<AdmitCardVerifyData> verificationData = Rxn<AdmitCardVerifyData>();

  @override
  void onInit() {
    super.onInit();
    scanAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void toggleTorch() async {
    try {
      await mobileScannerController.toggleTorch();
      isTorchOn.value = !isTorchOn.value;
    } catch (e) {
      debugPrint("Error toggling torch: $e");
    }
  }

  void switchCamera() async {
    try {
      await mobileScannerController.switchCamera();
      isFrontCamera.value = !isFrontCamera.value;
    } catch (e) {
      debugPrint("Error switching camera: $e");
    }
  }

  Future<void> onCodeDetected(String code) async {
    if (isProcessing.value || isLoading.value || code.trim().isEmpty) return;

    isProcessing.value = true;
    isLoading.value = true;
    lastScannedCode.value = code.trim();
    
    // Provide haptic feedback
    HapticFeedback.mediumImpact();
    
    // Pause animation and camera
    scanAnimation.stop();
    await mobileScannerController.stop();

    // Show loading dialog
    _showLoadingDialog();

    try {
      final trimmedCode = code.trim();
      int? studentId;
      if (int.tryParse(trimmedCode) != null) {
        studentId = int.tryParse(trimmedCode);
      }

      final response = await _admitCardService.verifyAdmitCard(
        qrCode: trimmedCode,
        studentId: studentId,
      );

      // Dismiss loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.success == true && response.data != null) {
        verificationData.value = response.data;

        // Fast image pre-cache so image renders instantly on the next screen
        final photoUrl = response.data?.student?.photoUrl;
        if (photoUrl != null && photoUrl.isNotEmpty) {
          try {
            final cacheKey = photoUrl.split('?').first;
            final imageProvider = CachedNetworkImageProvider(
              photoUrl,
              cacheKey: cacheKey,
              maxHeight: 250,
              maxWidth: 250,
            );
            if (Get.context != null) {
              precacheImage(imageProvider, Get.context!);
            }
          } catch (e) {
            debugPrint("Image precache notice: $e");
          }
        }

        // Show success snackbar message
        Get.snackbar(
          "Verified",
          response.message ?? "Student admit card verified successfully.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF16A34A),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );

        // Navigate to Next Screen with verified admit card data
        Get.toNamed('/admitCardDetail', arguments: response.data)?.then((_) {
          resumeScanning();
        });
      } else {
        _showErrorDialog(response.message ?? "Admit card could not be verified.");
      }
    } catch (e) {
      // Dismiss loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      _showErrorDialog(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _showLoadingDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Text(
                    "Verifying Admit Card...",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showErrorDialog(String errorMessage) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 24),
            SizedBox(width: 8),
            Text(
              "Verification Failed",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: Text(
          errorMessage,
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
              resumeScanning();
            },
            child: const Text(
              "Try Again",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void resumeScanning() {
    isProcessing.value = false;
    isLoading.value = false;
    lastScannedCode.value = '';
    verificationData.value = null;
    scanAnimation.repeat();
    mobileScannerController.start();
  }

  @override
  void onClose() {
    scanAnimation.dispose();
    mobileScannerController.dispose();
    super.onClose();
  }
}
