import 'package:flutter/animation.dart';
import 'package:get/get.dart';

import '../services/storage_services.dart';
class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<Offset> logoAnimation;
  late Animation<Offset> subtitleAnimation;


  @override
  void onInit() {
    super.onInit();
    print("SplashController onInit");

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    logoAnimation = Tween<Offset>(
      begin: const Offset(0, 2.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutBack,
      ),
    );

    subtitleAnimation = Tween<Offset>(
      begin: const Offset(2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.65,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );
    animationController.forward();

    _navigate();
  }

  void _navigate() async {
    // Animation 2s chalta hai, 3s delay dene se settle hone ka time milega
    await Future.delayed(const Duration(seconds: 3));

    final token = await StorageService.getToken();

    final actualToken = token?.contains('|') == true ? token!.split('|').last : token;
    print("SPLASH TOKEN => $actualToken");

    if (actualToken != null && actualToken.isNotEmpty) {
      Get.offAllNamed('/dashboard');
    } else {
      Get.offAllNamed('/login');
    }
  }


  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
