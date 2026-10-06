import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../controller/student_qr_scanner_controller.dart';
import '../themes/appColors_&_styles/text_styles.dart';

class StudentQrScannerScreen extends StatelessWidget {
  const StudentQrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentQrScannerController());
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final viewfinderSize = (screenWidth * 0.70).clamp(200.0, 260.0);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB0D7FE),
            Color(0xFFE8D8FD),
            Color(0xFFD3E1FD),
            Color(0xFFD7E5FD),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF1E293B),
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "STUDENT QR ATTENDANCE",
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 38),
                  ],
                ),
              ),

              // 2. Stats Pill Card
              Obx(() {
                final stats = controller.qrSettings.value?.stats;
                final scannedCount = stats?.scannedByMeToday ?? 0;
                final totalPresent = stats?.totalPresentToday ?? 0;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("Scanned by me", "$scannedCount", const Color(0xFF2563EB)),
                      Container(height: 24, width: 1, color: Colors.grey.shade300),
                      _buildStatItem("Total Present", "$totalPresent", const Color(0xFF16A34A)),
                    ],
                  ),
                );
              }),

              const Spacer(),

              // 3. Camera Viewfinder
              Center(
                child: Container(
                  width: screenWidth * 0.85,
                  height: screenWidth * 0.85,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Camera Stream
                      Positioned.fill(
                        child: MobileScanner(
                          controller: controller.mobileScannerController,
                          onDetect: (capture) {
                            final barcodes = capture.barcodes;
                            if (barcodes.isNotEmpty) {
                              final code = barcodes.first.rawValue;
                              if (code != null && code.isNotEmpty) {
                                controller.onCodeDetected(code);
                              }
                            }
                          },
                        ),
                      ),

                      // Mask Cutout
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _StudentScannerMaskPainter(
                            viewfinderSize: viewfinderSize,
                          ),
                        ),
                      ),

                      // Corner Brackets
                      SizedBox(
                        width: viewfinderSize,
                        height: viewfinderSize,
                        child: CustomPaint(
                          painter: _GreenCornerPainter(),
                        ),
                      ),

                      // Animated Laser Scan Line
                      AnimatedBuilder(
                        animation: controller.scanAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: ((screenWidth * 0.85 - viewfinderSize) / 2) +
                                (controller.scanAnimation.value * viewfinderSize),
                            child: Container(
                              width: viewfinderSize - 16,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFF00E676),
                                    Color(0xFF69F0AE),
                                    Color(0xFF00E676),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E676).withValues(alpha: 0.9),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Torch Toggle
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Obx(() {
                          final isOn = controller.isTorchOn.value;
                          return GestureDetector(
                            onTap: () => controller.toggleTorch(),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        }),
                      ),

                      // Bottom Instruction Pill
                      Positioned(
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.4),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Color(0xFF00E676),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Align Student QR in Frame",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Loading Overlay
                      Obx(() => controller.isLoading.value
                          ? Container(
                              color: Colors.black.withValues(alpha: 0.4),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: LoadingAnimationWidget.staggeredDotsWave(
                                    color: const Color(0xFF16A34A),
                                    size: 50,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // 4. Cancel Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA384D),
                      elevation: 4,
                      shadowColor: const Color(0xFFEA384D).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          "Done Scanning",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

class _StudentScannerMaskPainter extends CustomPainter {
  final double viewfinderSize;

  _StudentScannerMaskPainter({required this.viewfinderSize});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final left = (size.width - viewfinderSize) / 2;
    final top = (size.height - viewfinderSize) / 2;

    final scanRect = Rect.fromLTWH(left, top, viewfinderSize, viewfinderSize);
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutOutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(20)));

    final overlayPath = Path.combine(
      PathOperation.difference,
      fullPath,
      cutOutPath,
    );

    canvas.drawPath(overlayPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GreenCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..color = const Color(0xFF00E676)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;
    const radius = 18.0;

    // Top-Left Corner
    final pathTL = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(cornerLength, 0);
    canvas.drawPath(pathTL, cornerPaint);

    // Top-Right Corner
    final pathTR = Path()
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(pathTR, cornerPaint);

    // Bottom-Left Corner
    final pathBL = Path()
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height - radius)
      ..quadraticBezierTo(0, size.height, radius, size.height)
      ..lineTo(cornerLength, size.height);
    canvas.drawPath(pathBL, cornerPaint);

    // Bottom-Right Corner
    final pathBR = Path()
      ..moveTo(size.width - cornerLength, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(pathBR, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
