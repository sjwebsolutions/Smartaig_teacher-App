import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../appColors_&_styles/text_styles.dart';
import '../controller/splash_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SplashController splashController = Get.find<SplashController>();

    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final bool isTablet = screenWidth >= 600;
    final bool isSmallScreen = screenWidth < 360;

    // Responsive dimensions preserving design proportions
    final double logoSize = isTablet
        ? (screenWidth * 0.32).clamp(220.0, 280.0)
        : (screenWidth * 0.52).clamp(150.0, 220.0);

    final double titleFontSize = isTablet
        ? 30.0
        : (isSmallScreen ? 20.0 : 25.0);

    final double subtitleFontSize = isTablet
        ? 16.0
        : (isSmallScreen ? 12.0 : 14.0);

    final double subtitleLetterSpacing = isTablet
        ? 6.0
        : (isSmallScreen ? 3.0 : 5.0);

    final double progressContainerMargin = isTablet
        ? (screenWidth * 0.25).clamp(80.0, 160.0)
        : (screenWidth * 0.12).clamp(24.0, 60.0);

    final double bottomPadding = (screenHeight * 0.05).clamp(24.0, 50.0);

    // Decorative blob sizes
    final double topBlobSize = (screenHeight * 0.22).clamp(140.0, 240.0);
    final double bottomBlobSize = (screenHeight * 0.23).clamp(150.0, 250.0);
    final double rightBlobSize = (screenHeight * 0.25).clamp(160.0, 260.0);

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
              top: -topBlobSize * 0.3,
              left: -topBlobSize * 0.3,
              child: Container(
                height: topBlobSize,
                width: topBlobSize,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: -bottomBlobSize * 0.4,
              right: -bottomBlobSize * 0.4,
              child: Container(
                height: bottomBlobSize,
                width: bottomBlobSize,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              top: screenHeight * 0.18,
              right: -rightBlobSize * 0.5,
              child: Container(
                height: rightBlobSize,
                width: rightBlobSize * 0.9,
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
                            borderRadius: BorderRadius.circular(isTablet ? 30 : 24),
                            child: Image.asset(
                              "assets/images/img.png",
                              width: logoSize,
                              height: logoSize,
                            ),
                          ),
                          SizedBox(height: isTablet ? 16 : 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Smart AIG - Teachers App",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.h2.copyWith(
                                fontSize: titleFontSize,
                                color: AppColors.primary,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Administrative Info Group",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body.copyWith(
                                fontSize: subtitleFontSize,
                                color: AppColors.primary.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500,
                                letterSpacing: subtitleLetterSpacing,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: bottomPadding),
                  child: Container(
                    width: double.infinity,
                    height: 14,
                    margin: EdgeInsets.symmetric(horizontal: progressContainerMargin),
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
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: LinearProgressIndicator(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
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
