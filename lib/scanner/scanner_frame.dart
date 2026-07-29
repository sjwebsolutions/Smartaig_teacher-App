import 'package:flutter/cupertino.dart';
import 'package:teacher_app_attendance/appColors_&_styles/app_Colors.dart';

class ScannerOverlayPainter extends CustomPainter {
  final double scanSize;

  ScannerOverlayPainter({required this.scanSize});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = AppColors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2;

    final scanRect = Rect.fromLTWH(left, top, scanSize, scanSize);

    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutOutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(18)));

    final overlayPath = Path.combine(
      PathOperation.difference,
      fullPath,
      cutOutPath,
    );

    canvas.drawPath(overlayPath, backgroundPaint);

    // CORNERS (same as before)
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const c = 30.0;
    const r = 10.0; // corner roundness

    // TOP LEFT
    final pathTL = Path()
      ..moveTo(scanRect.left + c, scanRect.top)
      ..lineTo(scanRect.left + r, scanRect.top)
      ..quadraticBezierTo(
        scanRect.left,
        scanRect.top,
        scanRect.left,
        scanRect.top + r,
      )
      ..lineTo(scanRect.left, scanRect.top + c);

    // TOP RIGHT
    final pathTR = Path()
      ..moveTo(scanRect.right - c, scanRect.top)
      ..lineTo(scanRect.right - r, scanRect.top)
      ..quadraticBezierTo(
        scanRect.right,
        scanRect.top,
        scanRect.right,
        scanRect.top + r,
      )
      ..lineTo(scanRect.right, scanRect.top + c);

    // BOTTOM LEFT
    final pathBL = Path()
      ..moveTo(scanRect.left, scanRect.bottom - c)
      ..lineTo(scanRect.left, scanRect.bottom - r)
      ..quadraticBezierTo(
        scanRect.left,
        scanRect.bottom,
        scanRect.left + r,
        scanRect.bottom,
      )
      ..lineTo(scanRect.left + c, scanRect.bottom);

    // BOTTOM RIGHT
    final pathBR = Path()
      ..moveTo(scanRect.right - c, scanRect.bottom)
      ..lineTo(scanRect.right - r, scanRect.bottom)
      ..quadraticBezierTo(
        scanRect.right,
        scanRect.bottom,
        scanRect.right,
        scanRect.bottom - r,
      )
      ..lineTo(scanRect.right, scanRect.bottom - c);

    // DRAW ALL
    canvas.drawPath(pathTL, cornerPaint);
    canvas.drawPath(pathTR, cornerPaint);
    canvas.drawPath(pathBL, cornerPaint);
    canvas.drawPath(pathBR, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
