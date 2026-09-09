import 'dart:io';
import 'dart:math' as Math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import '../../themes/appColors_&_styles/app_Colors.dart';

class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({super.key});

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
      setState(() {
        _isProcessing = true;
      });

      final XFile imageFile = await _controller!.takePicture();

      // Load and Crop
      final bytes = await File(imageFile.path).readAsBytes();
      img.Image? capturedImage = img.decodeImage(bytes);

      if (capturedImage != null) {
        capturedImage = img.bakeOrientation(capturedImage);

        final Size screenSize = MediaQuery.of(context).size;
        double frameSize = screenSize.width * 0.85;

        double screenAspect = screenSize.width / screenSize.height;
        double imageAspect = capturedImage.width / capturedImage.height;

        double scale;
        double offsetX = 0;
        double offsetY = 0;

        if (imageAspect > screenAspect) {
          scale = capturedImage.height / screenSize.height;
          offsetX = (capturedImage.width - screenSize.width * scale) / 2;
        } else {
          scale = capturedImage.width / screenSize.width;
          offsetY = (capturedImage.height - screenSize.height * scale) / 2;
        }

        int cropSize = (frameSize * scale).toInt();
        int cropX = (offsetX + (screenSize.width - frameSize) / 2 * scale).toInt();
        int cropY = (offsetY + (screenSize.height - frameSize) / 2 * scale).toInt();

        img.Image croppedImage = img.copyCrop(
          capturedImage,
          x: cropX,
          y: cropY,
          width: cropSize,
          height: cropSize,
        );


        final String path = imageFile.path.replaceAll('.jpg', '_processed.jpg');
        await File(path).writeAsBytes(img.encodeJpg(croppedImage, quality: 90));

        Get.back(result: path);
      } else {
        Get.back(result: imageFile.path);
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Center(
            child: CameraPreview(_controller!),
          ),

          // Grid Overlay
          _buildGridOverlay(),

          // Loading Overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Get.back(),
            ),
          ),

          // Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        // Square frame for Face and Chest (exactly matching the provided grid image)
        double frameWidth = width * 0.85;
        double frameHeight = frameWidth; // Square ratio
        double top = (height - frameHeight) / 2;

        return Stack(
          children: [
            // Dark dimmed overlay with transparent hole
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.75),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: frameWidth,
                      height: frameHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Frame Border & Grid & Silhouette
            Center(
              child: SizedBox(
                width: frameWidth,
                height: frameHeight,
                child: CustomPaint(
                  painter: FaceChestOutlinePainter(),
                ),
              ),
            ),

            // Instructional Text
            Positioned(
              top: top - 70,
              width: width,
              child: const Center(
                child: Column(
                  children: [
                    Text(
                      "FACE & CHEST ALIGNMENT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Please align student's face and upper body within the grid",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(rrect, borderPaint);

    // 2. Draw 3x3 grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
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
      ..color = Colors.black
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
