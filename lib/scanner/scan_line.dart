import 'package:flutter/material.dart';

import '../appColors_&_styles/app_Colors.dart';

class ScanLine extends StatelessWidget {
  final double scanSize;
  final double animationValue;

  const ScanLine({
    super.key,
    required this.scanSize,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final left = (constraints.maxWidth - scanSize) / 2;
        final top = (constraints.maxHeight - scanSize) / 2;

        return Stack(
          children: [
            Positioned(
              left: left,
              top: top + (animationValue * scanSize),
              child: Container(
                width: scanSize,
                height: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,

                      AppColors.neutral,
                      AppColors.primary,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}