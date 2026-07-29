import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:teacher_app_attendance/controller/scanner_controller.dart';
import 'package:teacher_app_attendance/scanner/scan_line.dart';
import 'package:teacher_app_attendance/scanner/scanner_frame.dart';

import '../appColors_&_styles/app_Colors.dart';
import '../controller/dashboard_controller_v2.dart';
import 'glass_card_widget.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controller/scanner_controller.dart';
import '../appColors_&_styles/app_Colors.dart';
import '../appColors_&_styles/text_styles.dart';
import 'scan_line.dart';
import 'glass_card_widget.dart';

class ScannerScreen extends StatelessWidget {
  ScannerScreen({super.key});

  final ScannerController scannerController = Get.find<ScannerController>();
  final dash = Get.find<NewDashboardController>();
  final double scanSize = 260;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    /// SINGLE SOURCE OF TRUTH (IMPORTANT FIX)
    final scanAreaTop = (size.height - scanSize) / 2 - size.height * 0.08;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [

          /// CAMERA
          MobileScanner(
            controller: scannerController.mobileScannerController,
            onDetect: (capture) {
              final code = capture.barcodes.first.rawValue;
              if (code != null) {
                scannerController.onQRScanned(code);
              }
            },
          ),

          /// GRADIENT OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withOpacity(0.12),
                    AppColors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),
          ),

          /// SCANNER FRAME (NOW PERFECTLY ALIGNED)
          Positioned(
            top: scanAreaTop,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: scanSize,
                height: scanSize,
                child: CustomPaint(
                  painter: ScannerOverlayPainter(scanSize: scanSize),
                ),
              ),
            ),
          ),

          /// SCAN LINE ( FIXED INSIDE FRAME)
          AnimatedBuilder(
            animation: scannerController.scanAnimation,
            builder: (context, child) {
              return Positioned(
                top: scanAreaTop,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: scanSize,
                    height: scanSize,
                    child: ScanLine(
                      scanSize: scanSize,
                      animationValue:
                      scannerController.scanAnimation.value,
                    ),
                  ),
                ),
              );
            },
          ),

          /// TOP BADGE
          Positioned(
            top: scanAreaTop - 70,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary,
                      //Color(0xff285DFF),
                      //Color(0xff4C82FF),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code_scanner,
                        color: AppColors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "SCANNING ACTIVE",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// BOTTOM TEXT
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Column(
              children: [

                Text(
                  "Align QR inside frame",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Scanning will happen automatically",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 20),

                /// INFO ROW
                Row(
                  children: [

                    Expanded(
                      child: Obx(
                            () => GlassInfoCard(
                          icon: Icons.access_time,
                          title: scannerController.currentTime.value,
                          subtitle: "Current Time",
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: GlassInfoCard(
                        icon: Icons.location_on,
                        title: "Main Gate",
                        subtitle: "Entry Point",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.white.withOpacity(0.12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Cancel Scan",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}