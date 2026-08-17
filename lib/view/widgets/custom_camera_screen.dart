import 'dart:io';
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
        _isInitialized = false; // Show loader
      });

      final XFile imageFile = await _controller!.takePicture();
      
      // Load and Crop
      final bytes = await File(imageFile.path).readAsBytes();
      img.Image? capturedImage = img.decodeImage(bytes);

      if (capturedImage != null) {
        capturedImage = img.bakeOrientation(capturedImage);

        final Size screenSize = MediaQuery.of(context).size;
        double frameSize = screenSize.width * 0.8;
        
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

        final String path = imageFile.path.replaceAll('.jpg', '_cropped.jpg');
        await File(path).writeAsBytes(img.encodeJpg(croppedImage));

        Get.back(result: path);
      } else {
        Get.back(result: imageFile.path);
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isInitialized = true;
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

        // Square frame for Face and Chest (matching the provided grid image)
        double frameWidth = width * 0.8;
        double frameHeight = frameWidth; // Square ratio
        double top = (height - frameHeight) / 2;

        return Stack(
          children: [
            // Dark overlay with transparent hole
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.7),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Frame Border & Outline
            Center(
              child: Container(
                width: frameWidth,
                height: frameHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomPaint(
                  painter: FaceChestOutlinePainter(),
                ),
              ),
            ),

            // Instructional Text
            Positioned(
              top: top - 50,
              width: width,
              child: const Center(
                child: Column(
                  children: [
                    Text(
                      "FACE & CHEST ALIGNMENT",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Please align student's face and upper body",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
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
    final framePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final gridPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw Rounded Frame
    final RRect frameRRect = RRect.fromLTRBR(
      0, 0, size.width, size.height,
      const Radius.circular(30),
    );
    canvas.drawRRect(frameRRect, framePaint);

    // Draw Grid Lines (extending slightly outside for the style)
    double extension = 20.0;

    // Vertical Lines (2 lines for 3 columns)
    for (int i = 1; i <= 2; i++) {
      double x = size.width * (i / 3);
      canvas.drawLine(
        Offset(x, -extension),
        Offset(x, size.height + extension),
        gridPaint,
      );
    }

    // Horizontal Lines (3 lines for 4 rows)
    for (int i = 1; i <= 3; i++) {
      double y = size.height * (i / 4);
      canvas.drawLine(
        Offset(-extension, y),
        Offset(size.width + extension, y),
        gridPaint,
      );
    }

    // Person Silhouette (Optional but helpful for alignment)
    final silhouettePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Simple head & shoulders shape
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.35), width: size.width * 0.4, height: size.height * 0.3),
      silhouettePaint,
    );
    
    Path shoulderPath = Path();
    shoulderPath.moveTo(size.width * 0.2, size.height * 0.9);
    shoulderPath.quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.8, size.height * 0.9);
    canvas.drawPath(shoulderPath, silhouettePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
