import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controller/admit_card_scanner_controller.dart';
import '../themes/appColors_&_styles/text_styles.dart';

class AdmitCardScannerScreen extends StatelessWidget {
  const AdmitCardScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdmitCardScannerController>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final cardSize = (screenWidth - 36).clamp(240.0, screenHeight * 0.46);
    final viewfinderSize = (cardSize * 0.65).clamp(180.0, 220.0);

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // 1. Top App Bar (Back Button + Centered Title)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 35,
                                height: 35,
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
                                    "ADMIT CARD SCAN",
                                    style: AppTextStyles.h2.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1E293B),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 40), // Spacer to balance back button
                            ],
                          ),
                        ),

                    SizedBox(height: 60,),

                        // 2. Camera Card Viewfinder
                        Center(
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
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

                                // Semi-transparent cutout mask over camera
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _CameraCardMaskPainter(
                                      viewfinderSize: viewfinderSize,
                                    ),
                                  ),
                                ),

                                // Neon Green Viewfinder Corner Brackets
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
                                      top: ((cardSize - viewfinderSize) / 2) +
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

                                // Top-Right Flashlight Toggle Button
                                Positioned(
                                  top: 14,
                                  right: 14,
                                  child: Obx(() {
                                    final isOn = controller.isTorchOn.value;
                                    return GestureDetector(
                                      onTap: () => controller.toggleTorch(),
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B), // Amber / Orange
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2.2,
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
                                          size: 22,
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
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF00E676), // Bright Green
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Align Admit Card QR in Frame",
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
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 3. Red Cancel Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () => Get.back(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEA384D), // Red / Coral
                                elevation: 4,
                                shadowColor: const Color(0xFFEA384D).withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.close_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Cancel",
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

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Mask that creates a subtle dark vignette outside the viewfinder box
class _CameraCardMaskPainter extends CustomPainter {
  final double viewfinderSize;

  _CameraCardMaskPainter({required this.viewfinderSize});

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

/// Neon green rounded corner brackets painter
class _GreenCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..color = const Color(0xFF00E676) // Bright Green
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
