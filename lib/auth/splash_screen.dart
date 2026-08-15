import 'package:flutter/material.dart';

import '../appColors_&_styles/text_styles.dart';
import '../controller/splash_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';

import 'package:get/get.dart';



class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final SplashController splashController = Get.find<SplashController>();

    return Scaffold(
      body:
      Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      "assets/images/img.png",
                      width: 150,
                      height: 150,
                    ),
                  ),
                   const SizedBox(height: 10),
                  Text(
                    "SMARTAIG TEACHER APP",
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 17,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.primary.withOpacity(0.2),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "Administrative Informative Group",
                            style: AppTextStyles.body.copyWith(
                              fontSize: 9,
                              color: AppColors.primary.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.primary.withOpacity(0.2),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  children: [
                    SizedBox(
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          minHeight:5,
                          backgroundColor: Color(0xFFF5F5F5),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
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
      ),
      // Container(
      //   width: double.infinity,
      //   height: double.infinity,
      //   decoration: BoxDecoration(
      //     gradient: AppGradients.primary(),
      //   ),
      //   child: SafeArea(
      //     child: Column(
      //       children: [
      //         const Spacer(),
      //
      //         AnimatedBuilder(
      //           animation: splashController.animationController,
      //           builder: (context, child) {
      //             return Column(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //
      //                 SlideTransition(
      //                   position: splashController.logoAnimation,
      //                   child: ClipRRect(
      //                     borderRadius: BorderRadius.circular(18),
      //                     child: Image.asset(
      //                       "assets/images/logo.png",
      //                       width: 200,
      //                       height: 200,
      //                     ),
      //                   ),
      //                 ),
      //
      //                 SizedBox(height: 20),
      //
      //               ],
      //             );
      //           },
      //         ),
      //
      //         const Spacer(),
      //
      //         Padding(
      //           padding: const EdgeInsets.all(40),
      //           child: SizedBox(
      //             child: CircularProgressIndicator(
      //               color: AppColors.primary,
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
