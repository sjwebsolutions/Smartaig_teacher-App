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
          Column(
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
                          "Smart AIG - Teachers App",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 25,
                            color: AppColors.primary,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Administrative Info Group",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14,
                            color: AppColors.primary.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 5.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                child: Container(
                  width: double.infinity,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: SizedBox(
                      height: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: LinearProgressIndicator(
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          color: AppColors.primary,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      ),
    );
  }
}
