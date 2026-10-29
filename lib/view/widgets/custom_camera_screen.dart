import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import '../../themes/appColors_&_styles/app_Colors.dart';
import '../../themes/app_bar/app_top_bar.dart';

class CustomCameraScreen extends StatefulWidget {
  final String title;

  const CustomCameraScreen({
    super.key,
    this.title = "Camera",
  });

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final Size screenSize = MediaQuery.of(context).size;
      setState(() {
        _isProcessing = true;
      });

      final XFile imageFile = await _controller!.takePicture();

      final bytes = await File(imageFile.path).readAsBytes();
      img.Image? capturedImage = img.decodeImage(bytes);

      if (capturedImage != null) {
        capturedImage = img.bakeOrientation(capturedImage);

        double frameSize = screenSize.width * 0.85;

        double scale;
        double offsetX = 0;
        double offsetY = 0;

        double imageW = capturedImage.width.toDouble();
        double imageH = capturedImage.height.toDouble();

        if (imageH > imageW) {
          scale = imageW / frameSize;
          offsetY = (imageH - frameSize * scale) / 2;
        } else {
          scale = imageH / frameSize;
          offsetX = (imageW - frameSize * scale) / 2;
        }

        int cropSize = (frameSize * scale).toInt();
        int cropX = offsetX.toInt();
        int cropY = offsetY.toInt();

        img.Image croppedImage = img.copyCrop(
          capturedImage,
          x: cropX.clamp(0, capturedImage.width - 1),
          y: cropY.clamp(0, capturedImage.height - 1),
          width: cropSize.clamp(1, capturedImage.width - cropX),
          height: cropSize.clamp(1, capturedImage.height - cropY),
        );

        final String path = imageFile.path.replaceAll('.jpg', '_processed.jpg');
        await File(path).writeAsBytes(img.encodeJpg(croppedImage, quality: 90));

        Get.back(result: path);
      } else {
        Get.back(result: imageFile.path);
      }
    } catch (e) {
      debugPrint("Error taking picture: $e");
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primary(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppTopBar(
            title: "Camera",
            showBack: true,
            backgroundColor: Colors.transparent,
            showDivider: false,
          ),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
          ),
        ),
      );
    }

    final Size screenSize = MediaQuery.of(context).size;
    final double frameSize = screenSize.width * 0.85;

    final previewSize = _controller!.value.previewSize;
    final double previewW = previewSize != null ? previewSize.height : 3.0;
    final double previewH = previewSize != null ? previewSize.width : 4.0;

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppTopBar(
          title: widget.title,
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Camera Frame Container
              Expanded(
                child: Center(
                  child: Container(
                    width: frameSize,
                    height: frameSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Camera Live Feed inside rounded frame
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: previewW,
                                height: previewH,
                                child: CameraPreview(_controller!),
                              ),
                            ),
                          ),
                        ),

                        // Grid & Silhouette Overlay
                        Positioned.fill(
                          child: CustomPaint(
                            painter: FaceChestOutlinePainter(),
                          ),
                        ),

                        // Processing Overlay
                        if (_isProcessing)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.4),
                                child: const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Capture Button
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Center(
                  child: GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      height: 76,
                      width: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                            blurRadius: 14,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          height: 58,
                          width: 58,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4F46E5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
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
}

class FaceChestOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;
    double borderRadius = 24.0;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(borderRadius),
    );

    // 1. Draw outer rounded frame border
    final borderPaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(rrect, borderPaint);

    // 2. Draw 3x3 grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.save();
    canvas.clipRRect(rrect);

    // Vertical lines
    canvas.drawLine(Offset(w / 3, 0), Offset(w / 3, h), gridPaint);
    canvas.drawLine(Offset(2 * w / 3, 0), Offset(2 * w / 3, h), gridPaint);

    // Horizontal lines
    canvas.drawLine(Offset(0, h / 3), Offset(w, h / 3), gridPaint);
    canvas.drawLine(Offset(0, 2 * h / 3), Offset(w, 2 * h / 3), gridPaint);

    canvas.restore();

    // 3. Draw Silhouette (Head & Shoulders)
    final silhouettePaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double H = h - 10;

    Path path = Path();

    // Start from bottom-left shoulder corner (rounded)
    path.moveTo(w * 0.12, H);
    path.quadraticBezierTo(w * 0.06, H, w * 0.06, H - 15);

    // Left shoulder curve up to neck base
    path.cubicTo(
      w * 0.06, H - 65,
      w * 0.20, H * 0.76,
      w * 0.35, H * 0.72,
    );

    // Left neck up
    path.lineTo(w * 0.35, H * 0.61);

    // Left jaw to ear bottom
    path.quadraticBezierTo(w * 0.35, H * 0.58, w * 0.30, H * 0.55);

    // Left ear bump
    path.cubicTo(
      w * 0.27, H * 0.55,
      w * 0.26, H * 0.48,
      w * 0.30, H * 0.42,
    );

    // Top head dome (peak at H * 0.22) - perfect round semi-circle
    path.cubicTo(
      w * 0.30, H * 0.31,
      w * 0.39, H * 0.22,
      w * 0.50, H * 0.22,
    );
    path.cubicTo(
      w * 0.61, H * 0.22,
      w * 0.70, H * 0.31,
      w * 0.70, H * 0.42,
    );

    // Right ear bump
    path.cubicTo(
      w * 0.74, H * 0.48,
      w * 0.73, H * 0.55,
      w * 0.70, H * 0.55,
    );

    // Right jaw to neck
    path.quadraticBezierTo(w * 0.65, H * 0.58, w * 0.65, H * 0.61);

    // Right neck down
    path.lineTo(w * 0.65, H * 0.72);

    // Right shoulder curve down to bottom-right corner
    path.cubicTo(
      w * 0.80, H * 0.76,
      w * 0.94, H - 65,
      w * 0.94, H - 15,
    );

    // Round the bottom-right shoulder corner
    path.quadraticBezierTo(w * 0.94, H, w * 0.88, H);

    // Close the path to draw the straight line at the bottom
    path.close();

    canvas.drawPath(path, silhouettePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
