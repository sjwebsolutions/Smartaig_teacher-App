import 'package:flutter/material.dart';

import '../controller/splash_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';

import 'package:get/get.dart';



class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final SplashController splashController = Get.find<SplashController>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppGradients.primary(),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              AnimatedBuilder(
                animation: splashController.animationController,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SlideTransition(
                        position: splashController.logoAnimation,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            "assets/images/logo.png",
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                    ],
                  );
                },
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(40),
                child: SizedBox(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
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
