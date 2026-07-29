import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../appColors_&_styles/app_Colors.dart';

class AppSnackBar {
  static void error(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: AppColors.red,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      margin:  EdgeInsets.all(12),
      borderRadius: 10,
    );
  }

  static void success(String message) {
    Get.snackbar(
      "Success",
      message,
      backgroundColor: AppColors.green,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      margin:  EdgeInsets.all(12),
      borderRadius: 10,
    );
  }

  static void warning(String message) {
    Get.snackbar(
      "Warning",
      message,
      backgroundColor: AppColors.primary,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }
}