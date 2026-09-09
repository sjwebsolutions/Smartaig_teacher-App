import 'package:pinput/pinput.dart';
import '../controller/auth_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpVerify extends StatelessWidget {
  OtpVerify({super.key});

  final AuthController verifyController = Get.find<AuthController>();
  final FocusNode otpFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              // Decorative Blobs outside SafeArea
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
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -80,
                child: Container(
                  height: 170,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: 15,
                      left: 15,
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 13),
                          ),
                        ),
                      ),
                    ),
                    Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(23),
                            padding: const EdgeInsets.all(23),
                            decoration: BoxDecoration(
                              color: AppColors.neutral,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.grey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),

                                /// TITLE
                                Text(
                                  "Verify OTP",
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                /// MOBILE NUMBER
                                Obx(
                                  () => Text(
                                    "A 6 digit OTP was sent to your whatsapp:\n+91 ${verifyController.mobileNumber.value}",
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.body.copyWith(
                                      color: Colors.black.withOpacity(0.90),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                /// OTP BOXES (Pinput for Autofill)
                                Pinput(
                                  length: 6,
                                  controller: verifyController.otpController,
                                  focusNode: otpFocusNode,
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                                  onTap: () {
                                    otpFocusNode.requestFocus();
                                  },
                                  onCompleted: (pin) {
                                    verifyController.verifyOtp();
                                  },
                                  defaultPinTheme: PinTheme(
                                    width: 45,
                                    height: 50,
                                    textStyle: AppTextStyles.h2.copyWith(
                                      fontSize: 20,
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.grey),
                                    ),
                                  ),
                                  focusedPinTheme: PinTheme(
                                    width: 45,
                                    height: 50,
                                    textStyle: AppTextStyles.h2.copyWith(
                                      fontSize: 20,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.primary, width: 1.5),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                /// LOADING INDICATOR
                                Obx(() => verifyController.isLoading.value
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                        child: CircularProgressIndicator(color: AppColors.primary),
                                      )
                                    : const SizedBox.shrink()),

                                /// TIMER
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.timer, size: 18, color: AppColors.black),
                                    const SizedBox(width: 6),
                                    Text(
                                      "OTP expires in ",
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Obx(() {
                                      final sec = verifyController.seconds.value;
                                      return Text(
                                        "00:${sec.toString().padLeft(2, '0')}",
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.red,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
      ));
  }
}
