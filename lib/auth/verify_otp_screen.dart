import '../controller/auth_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'manual_otp_screen.dart';

class OtpVerify extends StatelessWidget {
  OtpVerify({super.key});

  final AuthController verifyController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(gradient: AppGradients.primary()),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.08),

                Container(
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
                      /// BACK BUTTON
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: const Icon(Icons.arrow_back),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

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

                      /// OTP BOXES
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.15,

                                child: TextField(
                                  controller:
                                      verifyController.otpController[index],
                                  keyboardType: TextInputType.number,

                                  textAlign: TextAlign.center,

                                  maxLength: 1,

                                  onChanged: (value) {
                                    /// MOVE TO NEXT
                                    if (value.isNotEmpty && index < 5) {
                                      FocusScope.of(context).nextFocus();
                                    }

                                    /// MOVE TO PREVIOUS
                                    if (value.isEmpty && index > 0) {
                                      FocusScope.of(context).previousFocus();
                                    }
                                  },

                                  decoration: InputDecoration(
                                    counterText: "",

                                    filled: true,
                                    fillColor: AppColors.grey,
                                    //isDense: true,
                                    contentPadding: EdgeInsets.zero,

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),

                                      borderSide: BorderSide(
                                        color: AppColors.grey,
                                      ),
                                    ),

                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),

                                      borderSide: BorderSide(
                                        color: AppColors.grey,
                                      ),
                                    ),

                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),

                                      borderSide: BorderSide(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

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

                      const SizedBox(height: 10),

                      /// RESEND OTP
                      Obx(
                        () => TextButton(
                          onPressed: verifyController.canResend.value
                              ? verifyController.sendOtp
                              : null,
                          child: Text(
                            "Resend OTP via WhatsApp",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      /// VERIFY BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: ElevatedButton(
                          onPressed: () {
                            verifyController.verifyOtp();
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          child: Text(
                            "Verify & Login",

                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w400,

                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// MANUAL OTP
                      InkWell(
                        onTap: () {
                          Get.to(() => ManualOtpScreen());
                        },

                        child: Text(
                          "Use Manual OTP instead",

                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w400,

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
      ),
    );
  }
}
