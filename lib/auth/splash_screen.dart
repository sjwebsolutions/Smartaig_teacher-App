import 'package:flutter/material.dart';

import '../appColors_&_styles/text_styles.dart';
import '../controller/splash_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import 'package:get/get.dart';
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final SplashController splashController = Get.find<SplashController>();

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
        body: Stack(
        children: [
          // ======================================================
          // DECORATIVE BLOBS
          // ======================================================
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              height: 170,
              width: 170,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            top: 150,
            right: -100,
            child: Container(
              height: 200,
              width: 180,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ======================================================
          // CONTENT
          // ======================================================
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SlideTransition(
                      position: splashController.logoAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              "assets/images/img.png",
                              width: 200,
                              height: 200,
                            ),
                          ),
                          Text(
                            "SMARTAIG TEACHER APP",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 17,
                              color: AppColors.primary,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Administrative Informative Group",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 14,
                              color: AppColors.primary.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: SizedBox(
                    width: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        minHeight: 5,
                        backgroundColor: Color(0xFFF5F5F5),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      ),
    );
  }
}
