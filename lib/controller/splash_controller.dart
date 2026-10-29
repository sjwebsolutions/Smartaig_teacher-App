import 'package:flutter/animation.dart';
import 'package:get/get.dart';

import '../services/storage_services.dart';
import 'dashboard_controller.dart';
import 'banner_controller.dart';

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
    final splashDelay = Future.delayed(const Duration(seconds: 3));

    // Pre-load token, cached dashboard, profile path and banner data in parallel
    final tokenFuture = StorageService.getToken();
    final profilePathFuture = StorageService.getProfileImagePath();
    final dashboardDataFuture = StorageService.getDashboardData();
    final bannerDataFuture = StorageService.getBannerData();

    await Future.wait([
      tokenFuture,
      profilePathFuture,
      dashboardDataFuture,
      bannerDataFuture,
    ]);

    final token = await StorageService.getToken();
    final actualToken = token?.contains('|') == true ? token!.split('|').last : token;
    print("SPLASH TOKEN => $actualToken");

    if (actualToken != null && actualToken.isNotEmpty) {
      if (!Get.isRegistered<DashboardController>()) {
        Get.put(DashboardController());
      }
      if (!Get.isRegistered<BannerController>()) {
        Get.put(BannerController());
      }
    }

    await splashDelay;

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
