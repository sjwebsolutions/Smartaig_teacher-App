import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:teacher_app_attendance/utils/app_snackbar.dart';

import '../api_service/auth_service.dart';
import '../services/fcm_services.dart';
import '../services/storage_services.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  RxString mobileNumber = "".obs; //STORED MOBILE
  RxInt seconds = 60.obs;
  RxBool canResend = false.obs;
  Timer? timer;

  final mobileController = TextEditingController();
  final manualOtpController = TextEditingController();
  final otpController = TextEditingController();
  
  final FocusNode mobileFocusNode = FocusNode();

  RxBool isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    print("AuthController INIT");
  }
  Future<void> sendOtp() async {
    if (mobileController.text.trim().length != 10) {
      AppSnackBar.error("Enter valid mobile number");
      return;
    }

    try {
      isLoading.value = true;

      mobileNumber.value = mobileController.text.trim();

      final success = await _authService.sendOtp(
        mobile: mobileController.text.trim(),
      );

      if (success) {
        AppSnackBar.success( "OTP sent successfully");
        startOtpTimer();
        Get.toNamed("/verifyOtp");
      }
    } catch (e) {
      AppSnackBar.error( e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    try {
      isLoading.value = true;

      String otp = otpController.text.trim();

      print("--- START OTP VERIFICATION ---");
      print("MOBILE: ${mobileNumber.value}");
      print("OTP ENTERED: $otp");

      if (otp.length != 6) {
        AppSnackBar.error( "Enter complete OTP");
        return;
      }

      final response = await _authService.verifyOtp(
        mobile: mobileNumber.value,
        otp: otp,
      );

      print("AUTH CONTROLLER: VERIFY SUCCESS = ${response.success}");

      if (response.success == true) {
        print("SAVING TOKEN: ${response.data?.token}");
        await StorageService.saveToken(response.data?.token ?? "");
        
        print("REGISTERING FCM TOKEN...");
        try {
          await FcmService.registerFcmToken();
        } catch (e) {
          print("FCM REGISTRATION ERROR (Non-blocking): $e");
          // On iOS, this often happens if APNS token is not ready yet
          // We don't want to block login because of this.
        }
        
        print("NAVIGATING TO DASHBOARD");
        Get.offAllNamed("/dashboard");
      } else {
        print("VERIFY FAILED: ${response.message}");
        AppSnackBar.error(response.message ?? "Verification failed");
      }
    } catch (e) {
      AppSnackBar.error( e.toString());
      print("VERIFY OTP EXCEPTION: $e");
    } finally {
      isLoading.value = false;
      print("--- END OTP VERIFICATION ---");
    }
  }

  Future<void> loginWithManualOtp() async {
    if (mobileController.text.trim().length != 10) {
      AppSnackBar.error("Enter valid mobile number");
      return;
    }
    if (manualOtpController.text.trim().length != 6) {
      AppSnackBar.error("Enter valid 6-digit OTP");
      return;
    }

    try {
      isLoading.value = true;
      print("--- START MANUAL OTP LOGIN ---");
      print("MOBILE: ${mobileController.text.trim()}");
      print("OTP: ${manualOtpController.text.trim()}");

      final response = await _authService.verifyOtp(
        mobile: mobileController.text.trim(),
        otp: manualOtpController.text.trim(),
      );

      print("AUTH CONTROLLER: MANUAL SUCCESS = ${response.success}");

      if (response.success == true) {
        await StorageService.saveToken(response.data?.token ?? "");
        try {
          await FcmService.registerFcmToken();
        } catch (e) {
          print("FCM REGISTRATION ERROR (Non-blocking): $e");
        }
        Get.offAllNamed("/dashboard");
        AppSnackBar.success("Logged in successfully");
      } else {
        print("MANUAL LOGIN FAILED: ${response.message}");
        AppSnackBar.error(response.message ?? "Login failed");
      }
    } catch (e) {
      print("MANUAL LOGIN EXCEPTION: $e");
      AppSnackBar.error(e.toString());
    } finally {
      isLoading.value = false;
      print("--- END MANUAL OTP LOGIN ---");
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      try {
        await _authService.logout();
      } catch (_) {}

      await StorageService.clearToken();
      final token = await StorageService.getToken();
      print("TOKEN AFTER LOGOUT => $token");
      Get.offAllNamed('/login');

      AppSnackBar.success(

        "Logged out successfully",
      );
    } finally {
      isLoading.value = false;
    }
  }
  void startOtpTimer() async {
    seconds.value = 60;
    canResend.value = false;

    timer?.cancel();

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (seconds.value == 0) {
        canResend.value = true;
        t.cancel();
      } else {
        seconds.value--;
      }
    });
  }

  @override
  void onClose() {
    print("AuthController CLOSE");
    //mobileController.clear();
   // mobileController.dispose();
    //
    // for (var controller in otpController) {
    //   controller.dispose();
    // }

    super.onClose();
  }
}
